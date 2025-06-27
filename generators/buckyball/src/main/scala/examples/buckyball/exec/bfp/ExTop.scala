//===- ExTop.scala - BFP执行单元顶层设计 ---===//
package buckyball.exec.bfp

import chisel3._
import chisel3.util._
import dialect.vector._
import dialect.format._


// Thread连接配置
case class ThreadConfig(
  numThreads: Int = 4,
  lane: Int = 16,
  dataFormat: String = "FP16"
)

// thread操作配置
case class ThreadOpsConfig(
  mul: Boolean = false,
  pop: Boolean = false,
  max: Boolean = false,
  square: Boolean = false,
  add: Boolean = false,
  sub: Boolean = false,
  div: Boolean = false,
  vmul: Boolean = false,
  bfpReduce: Boolean = false,    // BFP reduction操作
  citu: Boolean = false          // CITU矩阵乘法操作
)

// 设计时连线配置
case class ThreadRoute(
  threadId: String,              // thread名称/ID
  inputSources: Seq[String],     // 从哪些thread接收输入 ("external"表示外部输入)
  outputTargets: Seq[String],    // 输出到哪些thread ("external"表示外部输出)
  operations: ThreadOpsConfig    // 此thread支持的操作
)

case class ClusterConnection(
  routes: Seq[ThreadRoute]       // thread路由配置列表
) {
  // 将命名转换为数字索引的映射
  lazy val nameToIndex: Map[String, Int] = {
    routes.map(_.threadId).zipWithIndex.toMap
  }
  
  // 根据名称获取路由配置
  def getRoute(threadName: String): Option[ThreadRoute] = {
    routes.find(_.threadId == threadName)
  }
  
  // 获取thread的输入源（转换为数字索引）
  def getInputIndices(threadName: String): Seq[Int] = {
    getRoute(threadName).map(_.inputSources.map { src =>
      if (src == "external") -1 else nameToIndex.getOrElse(src, -1)
    }).getOrElse(Seq(-1))
  }
  
  // 获取thread的输出目标（转换为数字索引）
  def getOutputIndices(threadName: String): Seq[Int] = {
    getRoute(threadName).map(_.outputTargets.map { tgt =>
      if (tgt == "external") -1 else nameToIndex.getOrElse(tgt, -1)
    }).getOrElse(Seq(-1))
  }
}

object ClusterConnection {
  def apply(): ClusterConnection = ClusterConnection(Seq.empty)
}

// 运行时控制码
class RuntimeControlCode extends Bundle {
  val threadEnable = UInt(14.W)   // 每位控制一个thread通路是否激活（14个threads）
  val opcode = UInt(8.W)         // 操作码
  val valid = Bool()             // 控制码有效
}

// Thread集群管理器 - 恢复使用你的VecThread系统
class ThreadCluster(
  val config: ThreadConfig, 
  val connection: ClusterConnection
) extends Module {
  
  // 为每个thread创建参数 - 混合VecThread、BfpThread和CITU
  val vecThreads = Seq.tabulate(config.numThreads) { i =>
    val threadName = if (i < connection.routes.length) connection.routes(i).threadId else s"thread$i"
    val threadRoute = connection.getRoute(threadName)
    val ops = threadRoute.map(_.operations).getOrElse(ThreadOpsConfig(bfpReduce = true))
    
    implicit val tp = ThreadParams(
      lane = config.lane,
      dataFormat = DataFormatParams(config.dataFormat),
      Ops = new SupportedFuncUnits(
        mul = ops.mul,
        pop = ops.pop,
        max = ops.max,
        square = ops.square,
        add = ops.add,
        sub = ops.sub,
        div = ops.div,
        vmul = ops.vmul
      )
    )
    
    // 只创建普通VecThread（不包括bfpReduce和citu）
    if (!ops.citu && !ops.bfpReduce) {
      Some((i, Module(new VecThread()(tp))))
    } else {
      None
    }
  }.collect { case Some((idx, thread)) => (idx, thread) }
  
  // 为BfpThread（reduce操作）创建单独的实例
  val bfpThreads = Seq.tabulate(config.numThreads) { i =>
    val threadName = if (i < connection.routes.length) connection.routes(i).threadId else s"thread$i"
    val threadRoute = connection.getRoute(threadName)
    val ops = threadRoute.map(_.operations).getOrElse(ThreadOpsConfig(bfpReduce = true))
    
    if (ops.bfpReduce && !ops.citu) {
      implicit val tp = ThreadParams(
        lane = config.lane,
        dataFormat = DataFormatParams(config.dataFormat),
        Ops = new SupportedFuncUnits(
          mul = ops.mul,
          pop = ops.pop,
          max = ops.max,
          square = ops.square,
          add = ops.add,
          sub = ops.sub,
          div = ops.div,
          vmul = ops.vmul
        )
      )
      Some((i, Module(new BfpThread()(tp))))
    } else {
      None
    }
  }.collect { case Some((idx, thread)) => (idx, thread) }
  
  // 为CITU threads创建单独的实例
  val cituThreads = Seq.tabulate(config.numThreads) { i =>
    val threadName = if (i < connection.routes.length) connection.routes(i).threadId else s"thread$i"
    val threadRoute = connection.getRoute(threadName)
    val ops = threadRoute.map(_.operations).getOrElse(ThreadOpsConfig(bfpReduce = true))
    
    if (ops.citu) {
      implicit val tp = ThreadParams(
        lane = config.lane,
        dataFormat = DataFormatParams(config.dataFormat),
        Ops = new SupportedFuncUnits(mul = true, add = true)
      )
      Some((i, Module(new CITU()(tp))))
    } else {
      None
    }
  }.collect { case Some((idx, thread)) => (idx, thread) }
  
  // 集群级别的IO接口 - 支持多输入多输出
  val io = IO(new Bundle {
    // 数据输入输出 - 2个输入端口，2个输出端口
    val dataIn1 = Flipped(Decoupled(Vec(config.lane, UInt(16.W))))
    val dataIn2 = Flipped(Decoupled(Vec(config.lane, UInt(16.W))))
    val dataOut1 = Decoupled(new Bundle {
      val data = Vec(config.lane, UInt(8.W))
      val blockExp = UInt(5.W)
    })
    val dataOut2 = Decoupled(new Bundle {
      val data = Vec(config.lane, UInt(8.W))
      val blockExp = UInt(5.W)
    })
    
    // 控制码
    val controlCode = Input(new RuntimeControlCode())
    
    // 状态
    val status = Output(new Bundle {
      val activeThreads = UInt(config.numThreads.W)
      val activeLanes = UInt(config.lane.W)
      val ready = Bool()
      val busy = Bool()
    })
  })
  
  // 复杂的多链路连接 - 支持混合VecThread和CITU
  implicit val defaultThreadParams: ThreadParams = ThreadParams(
    lane = config.lane,
    dataFormat = DataFormatParams(config.dataFormat),
    Ops = new SupportedFuncUnits(mul = true)
  )
  
  val threadInputs = Wire(Vec(config.numThreads, Decoupled(new tOpLoad())))
  val threadOutputs = Wire(Vec(config.numThreads, Decoupled(new tOut())))
  
  // 连接所有threads
  for (i <- 0 until config.numThreads) {
    val threadName = if (i < connection.routes.length) connection.routes(i).threadId else s"thread$i"
    val threadRoute = connection.getRoute(threadName)
    val ops = threadRoute.map(_.operations).getOrElse(ThreadOpsConfig(bfpReduce = true))
    
    // 找到对应的thread实例并连接
    val vecThreadOpt = vecThreads.find(_._1 == i)
    val bfpThreadOpt = bfpThreads.find(_._1 == i)
    val cituThreadOpt = cituThreads.find(_._1 == i)
    
    // 为每个thread类型分别连接 - 避免else if导致的遗漏
    if (vecThreadOpt.isDefined) {
      // 连接VecThread
      val (_, vecThread) = vecThreadOpt.get
      vecThread.io.in <> threadInputs(i)
      threadOutputs(i) <> vecThread.io.out
    }
    
    if (bfpThreadOpt.isDefined) {
      // 连接BfpThread - 注意BfpThread的输出有blockExp字段
      val (_, bfpThread) = bfpThreadOpt.get
      bfpThread.io.in <> threadInputs(i)
      threadOutputs(i).valid := bfpThread.io.out.valid
      threadOutputs(i).bits.vRst := bfpThread.io.out.bits.vRst  
      threadOutputs(i).bits.sRst := bfpThread.io.out.bits.sRst
      bfpThread.io.out.ready := threadOutputs(i).ready
    }
    
    if (cituThreadOpt.isDefined) {
      // 连接CITU - 实现真正的矩阵乘法数据流
      val (_, citu) = cituThreadOpt.get
      
      // CITU的输入连接 - 从threadInputs转换数据格式
      citu.io.dataIn.valid := threadInputs(i).valid
      citu.io.dataIn.bits.matrixA_row := threadInputs(i).bits.op1
      citu.io.dataIn.bits.matrixB_col := threadInputs(i).bits.op2
      citu.io.dataIn.bits.rowIdx := threadInputs(i).bits.opcode(3,0)  // 使用opcode的低4位作为行索引
      citu.io.dataIn.bits.colIdx := threadInputs(i).bits.iter        // 使用iter作为列索引
      citu.io.dataIn.bits.kIdx := (threadInputs(i).bits.opcode >> 4).asUInt(3,0)  // 使用opcode的高4位作为K索引
      citu.io.dataIn.bits.isLastK := threadInputs(i).bits.scalar.asUInt =/= 0.U  // 使用scalar作为isLastK标志
      threadInputs(i).ready := citu.io.dataIn.ready
      
      // CITU的输出连接 - 转换为threadOutputs格式
      threadOutputs(i).valid := citu.io.dataOut.valid
      threadOutputs(i).bits.sRst := citu.io.dataOut.bits.result
      threadOutputs(i).bits.vRst := VecInit(Seq.fill(config.lane)(citu.io.dataOut.bits.result))  // 广播标量结果到向量
      citu.io.dataOut.ready := threadOutputs(i).ready
      
      // 控制信号连接
      citu.io.enable := io.controlCode.valid && ((io.controlCode.threadEnable >> i) & 1.U) === 1.U
      citu.io.reset_accumulator := io.controlCode.opcode === 255.U  // 特殊操作码用于重置
    }
    
    // 如果没有任何thread实例，设置默认值
    if (vecThreadOpt.isEmpty && bfpThreadOpt.isEmpty && cituThreadOpt.isEmpty) {
      threadInputs(i).ready := true.B
      threadOutputs(i).valid := false.B
      threadOutputs(i).bits := DontCare
    }
  }
  
  // 完整的数据流连接 - 根据配置建立真实的thread间连接
  // 首先为所有threads设置默认值，确保所有信号都被初始化
  for (i <- 0 until config.numThreads) {
    threadInputs(i).valid := false.B
    threadInputs(i).bits.op1 := VecInit(Seq.fill(config.lane)(0.U.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)))
    threadInputs(i).bits.op2 := VecInit(Seq.fill(config.lane)(0.U.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)))
    threadInputs(i).bits.scalar := 0.U.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    threadInputs(i).bits.opcode := 0.U
    threadInputs(i).bits.iter := 0.U
    threadOutputs(i).ready := true.B
  }
  
  // 根据4个不同的chain模式建立数据流连接
  val chainMode = io.controlCode.opcode(1,0)  // 使用opcode低2位区分4个chain
  
  // 获取thread索引映射
  val vmul1_idx = connection.nameToIndex.getOrElse("vmul1", 0)
  val reduce1_idx = connection.nameToIndex.getOrElse("reduce1", 1)
  val adder1_idx = connection.nameToIndex.getOrElse("adder1", 2)
  val reduce2_idx = connection.nameToIndex.getOrElse("reduce2", 3)
  val citu1_idx = connection.nameToIndex.getOrElse("citu1", 4)
  val mul_chain1_idx = connection.nameToIndex.getOrElse("mul_chain1", 5)
  val sub1_idx = connection.nameToIndex.getOrElse("sub1", 6)
  val reduce3_idx = connection.nameToIndex.getOrElse("reduce3", 7)
  val sub2_idx = connection.nameToIndex.getOrElse("sub2", 8)
  val div1_idx = connection.nameToIndex.getOrElse("div1", 9)
  val mul_chain3_idx = connection.nameToIndex.getOrElse("mul_chain3", 10)
  val citu2_idx = connection.nameToIndex.getOrElse("citu2", 11)
  val reduce4_idx = connection.nameToIndex.getOrElse("reduce4", 12)
  val adder2_idx = connection.nameToIndex.getOrElse("adder2", 13)
  
  // 设置默认ready信号
  io.dataIn1.ready := true.B
  io.dataIn2.ready := true.B
  
  // Chain1: 输入端口1->vmul->reduce1->adder1->adder2, 输入端口2+adder2的输出->reduce2->citu1->mul->输出1
  when (io.controlCode.valid && chainMode === 0.U) {
    // 路径1: 输入端口1->vmul1->reduce1->adder1->adder2
    threadInputs(vmul1_idx).valid := io.dataIn1.valid
    threadInputs(vmul1_idx).bits.op1 := io.dataIn1.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(vmul1_idx).bits.op2 := io.dataIn2.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(vmul1_idx).bits.opcode := 8.U  // vmul operation
    threadInputs(vmul1_idx).bits.iter := 1.U
    threadInputs(vmul1_idx).bits.scalar := 1.U.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(reduce1_idx).valid := threadOutputs(vmul1_idx).valid
    threadInputs(reduce1_idx).bits.op1 := threadOutputs(vmul1_idx).bits.vRst
    threadInputs(reduce1_idx).bits.opcode := 10.U  // bfp reduce operation
    threadInputs(reduce1_idx).bits.iter := 1.U
    threadInputs(reduce1_idx).bits.scalar := threadOutputs(vmul1_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(adder1_idx).valid := threadOutputs(reduce1_idx).valid
    threadInputs(adder1_idx).bits.op1 := threadOutputs(reduce1_idx).bits.vRst
    threadInputs(adder1_idx).bits.op2 := threadOutputs(reduce1_idx).bits.vRst
    threadInputs(adder1_idx).bits.opcode := 5.U  // add operation
    threadInputs(adder1_idx).bits.iter := 1.U
    threadInputs(adder1_idx).bits.scalar := threadOutputs(reduce1_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(adder2_idx).valid := threadOutputs(adder1_idx).valid
    threadInputs(adder2_idx).bits.op1 := threadOutputs(adder1_idx).bits.vRst
    threadInputs(adder2_idx).bits.op2 := threadOutputs(adder1_idx).bits.vRst
    threadInputs(adder2_idx).bits.opcode := 5.U  // add operation  
    threadInputs(adder2_idx).bits.iter := 1.U
    threadInputs(adder2_idx).bits.scalar := threadOutputs(adder1_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    // 路径2: 输入端口2+adder2的输出->reduce2->citu1->mul->输出1
    threadInputs(reduce2_idx).valid := io.dataIn2.valid && threadOutputs(adder2_idx).valid
    threadInputs(reduce2_idx).bits.op1 := io.dataIn2.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(reduce2_idx).bits.op2 := threadOutputs(adder2_idx).bits.vRst
    threadInputs(reduce2_idx).bits.opcode := 10.U  // bfp reduce operation
    threadInputs(reduce2_idx).bits.iter := 1.U
    threadInputs(reduce2_idx).bits.scalar := threadOutputs(adder2_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(citu1_idx).valid := threadOutputs(reduce2_idx).valid
    threadInputs(citu1_idx).bits.op1 := threadOutputs(reduce2_idx).bits.vRst
    threadInputs(citu1_idx).bits.op2 := threadOutputs(reduce2_idx).bits.vRst
    threadInputs(citu1_idx).bits.opcode := 1.U  // citu uses mul operation internally
    threadInputs(citu1_idx).bits.iter := 1.U
    threadInputs(citu1_idx).bits.scalar := threadOutputs(reduce2_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(mul_chain1_idx).valid := threadOutputs(citu1_idx).valid
    threadInputs(mul_chain1_idx).bits.op1 := threadOutputs(citu1_idx).bits.vRst
    threadInputs(mul_chain1_idx).bits.op2 := threadOutputs(citu1_idx).bits.vRst
    threadInputs(mul_chain1_idx).bits.opcode := 1.U  // mul operation
    threadInputs(mul_chain1_idx).bits.iter := 1.U
    threadInputs(mul_chain1_idx).bits.scalar := threadOutputs(citu1_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    // 设置ready信号
    io.dataIn1.ready := threadInputs(vmul1_idx).ready
    io.dataIn2.ready := threadInputs(reduce2_idx).ready
    threadOutputs(vmul1_idx).ready := threadInputs(reduce1_idx).ready
    threadOutputs(reduce1_idx).ready := threadInputs(adder1_idx).ready
    threadOutputs(adder1_idx).ready := threadInputs(adder2_idx).ready
    threadOutputs(adder2_idx).ready := threadInputs(reduce2_idx).ready
    threadOutputs(reduce2_idx).ready := threadInputs(citu1_idx).ready
    threadOutputs(citu1_idx).ready := threadInputs(mul_chain1_idx).ready
  }
  
  // Chain2: 输入端口1->sub1->citu1->reduce3->adder2, 输入端口2->sub2->citu2输出+adder2的输出->div->输出2
  when (io.controlCode.valid && chainMode === 1.U) {
    // 路径1: 输入端口1->sub1->citu1->reduce3->adder2
    threadInputs(sub1_idx).valid := io.dataIn1.valid
    threadInputs(sub1_idx).bits.op1 := io.dataIn1.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(sub1_idx).bits.op2 := io.dataIn1.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(sub1_idx).bits.opcode := 6.U  // sub operation
    threadInputs(sub1_idx).bits.iter := 1.U
    threadInputs(sub1_idx).bits.scalar := 1.U.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(citu1_idx).valid := threadOutputs(sub1_idx).valid
    threadInputs(citu1_idx).bits.op1 := threadOutputs(sub1_idx).bits.vRst
    threadInputs(citu1_idx).bits.op2 := threadOutputs(sub1_idx).bits.vRst
    threadInputs(citu1_idx).bits.opcode := 1.U  // citu uses mul operation internally
    threadInputs(citu1_idx).bits.iter := 1.U
    threadInputs(citu1_idx).bits.scalar := threadOutputs(sub1_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(reduce3_idx).valid := threadOutputs(citu1_idx).valid
    threadInputs(reduce3_idx).bits.op1 := threadOutputs(citu1_idx).bits.vRst
    threadInputs(reduce3_idx).bits.opcode := 10.U  // bfp reduce operation
    threadInputs(reduce3_idx).bits.iter := 1.U
    threadInputs(reduce3_idx).bits.scalar := threadOutputs(citu1_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(adder2_idx).valid := threadOutputs(reduce3_idx).valid
    threadInputs(adder2_idx).bits.op1 := threadOutputs(reduce3_idx).bits.vRst
    threadInputs(adder2_idx).bits.op2 := threadOutputs(reduce3_idx).bits.vRst
    threadInputs(adder2_idx).bits.opcode := 5.U  // add operation
    threadInputs(adder2_idx).bits.iter := 1.U
    threadInputs(adder2_idx).bits.scalar := threadOutputs(reduce3_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    // 路径2: 输入端口2->sub2->citu2输出+adder2的输出->div->输出2
    threadInputs(sub2_idx).valid := io.dataIn2.valid
    threadInputs(sub2_idx).bits.op1 := io.dataIn2.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(sub2_idx).bits.op2 := io.dataIn2.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(sub2_idx).bits.opcode := 6.U  // sub operation
    threadInputs(sub2_idx).bits.iter := 1.U
    threadInputs(sub2_idx).bits.scalar := 1.U.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(citu2_idx).valid := threadOutputs(sub2_idx).valid
    threadInputs(citu2_idx).bits.op1 := threadOutputs(sub2_idx).bits.vRst
    threadInputs(citu2_idx).bits.op2 := threadOutputs(sub2_idx).bits.vRst
    threadInputs(citu2_idx).bits.opcode := 1.U  // citu uses mul operation internally
    threadInputs(citu2_idx).bits.iter := 1.U
    threadInputs(citu2_idx).bits.scalar := threadOutputs(sub2_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(div1_idx).valid := threadOutputs(citu2_idx).valid && threadOutputs(adder2_idx).valid
    threadInputs(div1_idx).bits.op1 := threadOutputs(citu2_idx).bits.vRst
    threadInputs(div1_idx).bits.op2 := threadOutputs(adder2_idx).bits.vRst
    threadInputs(div1_idx).bits.opcode := 7.U  // div operation
    threadInputs(div1_idx).bits.iter := 1.U
    threadInputs(div1_idx).bits.scalar := threadOutputs(citu2_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    // 设置ready信号
    io.dataIn1.ready := threadInputs(sub1_idx).ready
    io.dataIn2.ready := threadInputs(sub2_idx).ready
    threadOutputs(sub1_idx).ready := threadInputs(citu1_idx).ready
    threadOutputs(citu1_idx).ready := threadInputs(reduce3_idx).ready
    threadOutputs(reduce3_idx).ready := threadInputs(adder2_idx).ready
    threadOutputs(sub2_idx).ready := threadInputs(citu2_idx).ready
    threadOutputs(citu2_idx).ready := threadInputs(div1_idx).ready
    threadOutputs(adder2_idx).ready := threadInputs(div1_idx).ready
  }
  
  // Chain3: 输入端口1->citu1, 输入端口2+citu1的输出->mul->输出1
  when (io.controlCode.valid && chainMode === 2.U) {
    threadInputs(citu1_idx).valid := io.dataIn1.valid
    threadInputs(citu1_idx).bits.op1 := io.dataIn1.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(citu1_idx).bits.op2 := io.dataIn1.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(citu1_idx).bits.opcode := 1.U  // citu uses mul operation internally
    threadInputs(citu1_idx).bits.iter := 1.U
    threadInputs(citu1_idx).bits.scalar := 1.U.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(mul_chain3_idx).valid := io.dataIn2.valid && threadOutputs(citu1_idx).valid
    threadInputs(mul_chain3_idx).bits.op1 := io.dataIn2.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(mul_chain3_idx).bits.op2 := threadOutputs(citu1_idx).bits.vRst
    threadInputs(mul_chain3_idx).bits.opcode := 1.U  // mul operation
    threadInputs(mul_chain3_idx).bits.iter := 1.U
    threadInputs(mul_chain3_idx).bits.scalar := threadOutputs(citu1_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    // 设置ready信号
    io.dataIn1.ready := threadInputs(citu1_idx).ready
    io.dataIn2.ready := threadInputs(mul_chain3_idx).ready
    threadOutputs(citu1_idx).ready := threadInputs(mul_chain3_idx).ready
  }
  
  // Chain4: 输入端口1->reduce1->citu1->reduce3->输出1, 输入端口2->reduce2->citu2->reduce4->输出2
  when (io.controlCode.valid && chainMode === 3.U) {
    // 路径1: 输入端口1->reduce1->citu1->reduce3->输出1
    threadInputs(reduce1_idx).valid := io.dataIn1.valid
    threadInputs(reduce1_idx).bits.op1 := io.dataIn1.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(reduce1_idx).bits.opcode := 10.U  // bfp reduce operation
    threadInputs(reduce1_idx).bits.iter := 1.U
    threadInputs(reduce1_idx).bits.scalar := 1.U.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(citu1_idx).valid := threadOutputs(reduce1_idx).valid
    threadInputs(citu1_idx).bits.op1 := threadOutputs(reduce1_idx).bits.vRst
    threadInputs(citu1_idx).bits.op2 := threadOutputs(reduce1_idx).bits.vRst
    threadInputs(citu1_idx).bits.opcode := 1.U  // citu uses mul operation internally
    threadInputs(citu1_idx).bits.iter := 1.U
    threadInputs(citu1_idx).bits.scalar := threadOutputs(reduce1_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(reduce3_idx).valid := threadOutputs(citu1_idx).valid
    threadInputs(reduce3_idx).bits.op1 := threadOutputs(citu1_idx).bits.vRst
    threadInputs(reduce3_idx).bits.opcode := 10.U  // bfp reduce operation
    threadInputs(reduce3_idx).bits.iter := 1.U
    threadInputs(reduce3_idx).bits.scalar := threadOutputs(citu1_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    // 路径2: 输入端口2->reduce2->citu2->reduce4->输出2
    threadInputs(reduce2_idx).valid := io.dataIn2.valid
    threadInputs(reduce2_idx).bits.op1 := io.dataIn2.bits.asTypeOf(Vec(config.lane, defaultThreadParams.dataFormat.dataType.cloneType))
    threadInputs(reduce2_idx).bits.opcode := 10.U  // bfp reduce operation
    threadInputs(reduce2_idx).bits.iter := 1.U
    threadInputs(reduce2_idx).bits.scalar := 1.U.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(citu2_idx).valid := threadOutputs(reduce2_idx).valid
    threadInputs(citu2_idx).bits.op1 := threadOutputs(reduce2_idx).bits.vRst
    threadInputs(citu2_idx).bits.op2 := threadOutputs(reduce2_idx).bits.vRst
    threadInputs(citu2_idx).bits.opcode := 1.U  // citu uses mul operation internally
    threadInputs(citu2_idx).bits.iter := 1.U
    threadInputs(citu2_idx).bits.scalar := threadOutputs(reduce2_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    threadInputs(reduce4_idx).valid := threadOutputs(citu2_idx).valid
    threadInputs(reduce4_idx).bits.op1 := threadOutputs(citu2_idx).bits.vRst
    threadInputs(reduce4_idx).bits.opcode := 10.U  // bfp reduce operation
    threadInputs(reduce4_idx).bits.iter := 1.U
    threadInputs(reduce4_idx).bits.scalar := threadOutputs(citu2_idx).bits.sRst.asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    
    // 设置ready信号
    io.dataIn1.ready := threadInputs(reduce1_idx).ready
    io.dataIn2.ready := threadInputs(reduce2_idx).ready
    threadOutputs(reduce1_idx).ready := threadInputs(citu1_idx).ready
    threadOutputs(citu1_idx).ready := threadInputs(reduce3_idx).ready
    threadOutputs(reduce2_idx).ready := threadInputs(citu2_idx).ready
    threadOutputs(citu2_idx).ready := threadInputs(reduce4_idx).ready
  }
  
  // 输出连接：根据不同chain的最终输出选择正确的输出端口
  val defaultDataOut = VecInit(Seq.fill(config.lane)(0.U(8.W)))
  
  // 默认初始化所有输出信号
  io.dataOut1.valid := false.B
  io.dataOut1.bits.data := defaultDataOut
  io.dataOut1.bits.blockExp := 0.U(5.W)
  io.dataOut2.valid := false.B
  io.dataOut2.bits.data := defaultDataOut
  io.dataOut2.bits.blockExp := 0.U(5.W)
  
  switch (chainMode) {
    is (0.U) {  // Chain1: mul_chain1 -> 输出1
      io.dataOut1.valid := threadOutputs(mul_chain1_idx).valid && io.controlCode.valid
      io.dataOut1.bits.data := VecInit(threadOutputs(mul_chain1_idx).bits.vRst.map(_.asUInt(7,0)))
      io.dataOut1.bits.blockExp := threadOutputs(mul_chain1_idx).bits.sRst.asUInt(4,0)
      threadOutputs(mul_chain1_idx).ready := io.dataOut1.ready
    }
    is (1.U) {  // Chain2: div1 -> 输出2
      io.dataOut2.valid := threadOutputs(div1_idx).valid && io.controlCode.valid
      io.dataOut2.bits.data := VecInit(threadOutputs(div1_idx).bits.vRst.map(_.asUInt(7,0)))
      io.dataOut2.bits.blockExp := threadOutputs(div1_idx).bits.sRst.asUInt(4,0)
      threadOutputs(div1_idx).ready := io.dataOut2.ready
    }
    is (2.U) {  // Chain3: mul_chain3 -> 输出1
      io.dataOut1.valid := threadOutputs(mul_chain3_idx).valid && io.controlCode.valid
      io.dataOut1.bits.data := VecInit(threadOutputs(mul_chain3_idx).bits.vRst.map(_.asUInt(7,0)))
      io.dataOut1.bits.blockExp := threadOutputs(mul_chain3_idx).bits.sRst.asUInt(4,0)
      threadOutputs(mul_chain3_idx).ready := io.dataOut1.ready
    }
    is (3.U) {  // Chain4: reduce3 -> 输出1, reduce4 -> 输出2
      io.dataOut1.valid := threadOutputs(reduce3_idx).valid && io.controlCode.valid
      io.dataOut1.bits.data := VecInit(threadOutputs(reduce3_idx).bits.vRst.map(_.asUInt(7,0)))
      io.dataOut1.bits.blockExp := threadOutputs(reduce3_idx).bits.sRst.asUInt(4,0)
      threadOutputs(reduce3_idx).ready := io.dataOut1.ready
      
      io.dataOut2.valid := threadOutputs(reduce4_idx).valid && io.controlCode.valid
      io.dataOut2.bits.data := VecInit(threadOutputs(reduce4_idx).bits.vRst.map(_.asUInt(7,0)))
      io.dataOut2.bits.blockExp := threadOutputs(reduce4_idx).bits.sRst.asUInt(4,0)
      threadOutputs(reduce4_idx).ready := io.dataOut2.ready
    }
  }
  

  
  // 为未连接到最终输出的threads设置ready信号
  for (i <- 0 until config.numThreads) {
    when (!io.controlCode.valid) {
      threadOutputs(i).ready := true.B
    } .elsewhen (chainMode === 0.U && i.U =/= mul_chain1_idx.U) {
      threadOutputs(i).ready := true.B
    } .elsewhen (chainMode === 1.U && i.U =/= div1_idx.U) {
      threadOutputs(i).ready := true.B
    } .elsewhen (chainMode === 2.U && i.U =/= mul_chain3_idx.U) {
      threadOutputs(i).ready := true.B
    } .elsewhen (chainMode === 3.U && i.U =/= reduce3_idx.U && i.U =/= reduce4_idx.U) {
      threadOutputs(i).ready := true.B
    }
  }
  
  // 状态输出
  io.status.activeThreads := io.controlCode.threadEnable
  io.status.activeLanes := Fill(config.lane, 1.U)
  io.status.ready := io.dataIn1.ready && io.dataIn2.ready
  io.status.busy := (io.dataIn1.valid && !io.dataIn1.ready) || (io.dataIn2.valid && !io.dataIn2.ready)
  
  // 防止thread被优化掉的保持信号 - 确保所有thread的输出都被用到
  val threadKeepAlive = Wire(UInt(1.W))
  threadKeepAlive := threadOutputs.map(_.valid).reduce(_ | _) |
                    threadInputs.map(_.ready).reduce(_ | _)
  
  // 为了防止输入数据被常数传播优化，添加一个动态扰动
  val cycleCounter = RegInit(0.U(8.W))
  cycleCounter := cycleCounter + 1.U
  val dataPerturbation = cycleCounter(2, 0)  // 使用低3位作为扰动
  
  // 修改所有默认输入，添加轻微的非零扰动
  for (i <- 0 until config.numThreads) {
    when(!threadInputs(i).valid) {
      // 当没有有效输入时，提供带扰动的默认值
      threadInputs(i).bits.op1 := VecInit(Seq.fill(config.lane)(
        Cat(dataPerturbation, 0.U(5.W)).asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
      ))
      threadInputs(i).bits.op2 := VecInit(Seq.fill(config.lane)(
        Cat((~dataPerturbation).asUInt, 0.U(5.W)).asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
      ))
      threadInputs(i).bits.scalar := Cat(dataPerturbation, 0.U(5.W)).asTypeOf(defaultThreadParams.dataFormat.dataType.cloneType)
    }
  }
  
  // 将保持信号连接到一个虚拟寄存器，确保综合工具不会优化掉thread
  val keepAliveReg = RegInit(false.B)
  when (threadKeepAlive === 0.U) {
    // 这个条件永远不会为真，但确保threadKeepAlive被使用
    keepAliveReg := true.B
  }
  
  // 确保所有thread输出都被观察到（即使没有使用）
  val allThreadOutputs = threadOutputs.map(out => out.bits.vRst.asUInt ^ out.bits.sRst.asUInt).reduce(_ ^ _)
  val outputObserver = RegInit(0.U(32.W))
  outputObserver := outputObserver ^ allThreadOutputs
}

// ExTop主设计 - 简化版本
class ExTop(
  val config: ThreadConfig,
  val connection: ClusterConnection
) extends Module {
  val io = IO(new Bundle {
    // 主要数据接口 - 支持双输入双输出
    val dataIn1 = Flipped(Decoupled(Vec(config.lane, UInt(16.W))))
    val dataIn2 = Flipped(Decoupled(Vec(config.lane, UInt(16.W))))
    val dataOut1 = Decoupled(new Bundle {
      val data = Vec(config.lane, UInt(8.W))
      val blockExp = UInt(5.W)
    })
    val dataOut2 = Decoupled(new Bundle {
      val data = Vec(config.lane, UInt(8.W))
      val blockExp = UInt(5.W)
    })
    
    // 控制接口
    val ctrl = Input(new Bundle {
      val threadEnable = UInt(14.W)   // 运行时thread使能码（14个threads）
      val opcode = UInt(8.W)         // 操作码
      val enable = Bool()
    })
    
    // 状态接口
    val status = Output(new Bundle {
      val activeThreads = UInt(config.numThreads.W)
      val ready = Bool()
      val busy = Bool()
    })
  })
  
  // 实例化thread集群 - 使用你的VecThread
  val processor = Module(new ThreadCluster(config, connection))
  
  // 控制码生成
  val controlCode = Wire(new RuntimeControlCode())
  controlCode.threadEnable := io.ctrl.threadEnable
  controlCode.opcode := io.ctrl.opcode
  controlCode.valid := io.ctrl.enable
  
  // 连接数据通路 - 多输入多输出
  processor.io.dataIn1 <> io.dataIn1
  processor.io.dataIn2 <> io.dataIn2
  io.dataOut1 <> processor.io.dataOut1
  io.dataOut2 <> processor.io.dataOut2
  processor.io.controlCode := controlCode
  
  // 连接状态信号
  io.status.activeThreads := io.ctrl.threadEnable
  io.status.ready := processor.io.status.ready
  io.status.busy := processor.io.status.busy
}
