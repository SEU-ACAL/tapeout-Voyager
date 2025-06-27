package buckyball.exec.bfp

import chisel3._
import chisel3.util._
import dialect.vector._
import dialect.format._

// CITU - 真正的矩阵乘法单元
// 实现 C = A * B，其中A是MxK矩阵，B是KxN矩阵，C是MxN矩阵
// 使用流水线设计：16个mul thread计算点积，16个add thread做累加
class CITU(implicit tp: ThreadParams) extends Module {
  val io = IO(new Bundle {
    // 数据输入：流式输入矩阵数据
    val dataIn = Flipped(Decoupled(new Bundle {
      val matrixA_row = Vec(tp.lane, tp.dataFormat.dataType.cloneType)  // A矩阵的一行数据 (K个元素)
      val matrixB_col = Vec(tp.lane, tp.dataFormat.dataType.cloneType)  // B矩阵的一列数据 (K个元素)
      val rowIdx = UInt(4.W)  // 结果矩阵的行索引 (0-15)
      val colIdx = UInt(4.W)  // 结果矩阵的列索引 (0-15)
      val kIdx = UInt(4.W)    // K维度的索引 (0-15)，用于累加
      val isLastK = Bool()    // 是否是K维度的最后一个数据
    }))
    
    // 数据输出：结果矩阵元素
    val dataOut = Decoupled(new Bundle {
      val result = tp.dataFormat.dataType.cloneType  // 单个结果元素 C[i][j]
      val rowIdx = UInt(4.W)  // 结果行索引
      val colIdx = UInt(4.W)  // 结果列索引
      val valid_result = Bool() // 结果有效标志
    })
    
    // 控制信号
    val enable = Input(Bool())
    val reset_accumulator = Input(Bool())  // 重置累加器
    
    // 状态输出
    val status = Output(new Bundle {
      val busy = Bool()
      val processing_cell = new Bundle {
        val row = UInt(4.W)
        val col = UInt(4.W)
      }
      val pipeline_stages = UInt(3.W)  // 流水线阶段指示
    })
  })

  // 实例化16个mul thread - 每个thread计算一对元素的乘积
  val mulThreads = Seq.fill(16)(Module(new VecThread()(tp.copy(Ops = new SupportedFuncUnits(mul = true)))))
  
  // 实例化16个add thread - 用于累加部分积
  val addThreads = Seq.fill(16)(Module(new VecThread()(tp.copy(Ops = new SupportedFuncUnits(add = true)))))
  
  // 流水线状态机
  val s_idle :: s_multiply :: s_accumulate :: s_output :: Nil = Enum(4)
  val state = RegInit(s_idle)
  
  // 输入缓存和流水线寄存器
  val input_buffer = Reg(new Bundle {
    val matrixA_row = Vec(tp.lane, tp.dataFormat.dataType.cloneType)
    val matrixB_col = Vec(tp.lane, tp.dataFormat.dataType.cloneType)
    val rowIdx = UInt(4.W)
    val colIdx = UInt(4.W)
    val kIdx = UInt(4.W)
    val isLastK = Bool()
  })
  
  // 部分积存储 - 16x16矩阵的累加器
  val accumulator = RegInit(VecInit(Seq.fill(16)(VecInit(Seq.fill(16)(0.U.asTypeOf(tp.dataFormat.dataType.cloneType))))))
  
  // 乘法结果缓存
  val mul_results = Wire(Vec(16, tp.dataFormat.dataType.cloneType))
  val mul_valid = Wire(Vec(16, Bool()))
  
  // 累加结果缓存
  val add_results = Wire(Vec(16, tp.dataFormat.dataType.cloneType))
  val add_valid = Wire(Vec(16, Bool()))
  
  // 当前处理的单元索引
  val current_row = Reg(UInt(4.W))
  val current_col = Reg(UInt(4.W))
  val processing_k = Reg(UInt(4.W))
  
  // 输入握手逻辑
  io.dataIn.ready := (state === s_idle) || (state === s_multiply && !io.dataIn.bits.isLastK)
  
  // 状态转换和数据加载
  when (io.dataIn.fire) {
    input_buffer := io.dataIn.bits
    current_row := io.dataIn.bits.rowIdx  
    current_col := io.dataIn.bits.colIdx
    processing_k := io.dataIn.bits.kIdx
    
    when (state === s_idle) {
      state := s_multiply
    }
  }
  
  // 重置累加器
  when (io.reset_accumulator) {
    for (i <- 0 until 16) {
      for (j <- 0 until 16) {
        accumulator(i)(j) := 0.U.asTypeOf(tp.dataFormat.dataType.cloneType)
      }
    }
  }
  
  // 配置mul threads - 计算向量点积的各个分量
  for (i <- 0 until 16) {
    // 每个mul thread计算A[row][k*16+i] * B[k*16+i][col]
    mulThreads(i).io.in.valid := (state === s_multiply) && io.enable
    mulThreads(i).io.in.bits.opcode := 1.U  // scalar * vector multiplication
    mulThreads(i).io.in.bits.iter := 1.U
    mulThreads(i).io.out.ready := true.B
    
    when (state === s_multiply && io.enable) {
      // 使用A矩阵行的第i个元素作为标量，B矩阵列作为向量
      val scalar_a = Mux(i.U < tp.lane.U, input_buffer.matrixA_row(i), 0.U.asTypeOf(tp.dataFormat.dataType.cloneType))
      val vector_b = input_buffer.matrixB_col
      
      mulThreads(i).io.in.bits.op1 := VecInit(Seq.fill(tp.lane)(scalar_a))
      mulThreads(i).io.in.bits.op2 := vector_b
      mulThreads(i).io.in.bits.scalar := scalar_a
    }.otherwise {
      mulThreads(i).io.in.bits.op1 := VecInit(Seq.fill(tp.lane)(0.U.asTypeOf(tp.dataFormat.dataType.cloneType)))
      mulThreads(i).io.in.bits.op2 := VecInit(Seq.fill(tp.lane)(0.U.asTypeOf(tp.dataFormat.dataType.cloneType)))
      mulThreads(i).io.in.bits.scalar := 0.U.asTypeOf(tp.dataFormat.dataType.cloneType)
    }
    
    // 收集乘法结果 - 对每个thread的向量结果求和得到点积分量
    mul_results(i) := mulThreads(i).io.out.bits.vRst.reduce((a, b) => a.asUInt + b.asUInt).asTypeOf(tp.dataFormat.dataType.cloneType)
    mul_valid(i) := mulThreads(i).io.out.valid
  }
  
  // 状态转换：乘法完成后进入累加阶段
  val all_mul_valid = mul_valid.reduce(_ && _)
  when (state === s_multiply && all_mul_valid) {
    state := s_accumulate
  }
  
  // 配置add threads - 将乘法结果累加到对应的累加器位置
  for (i <- 0 until 16) {
    addThreads(i).io.in.valid := (state === s_accumulate) && io.enable
    addThreads(i).io.in.bits.opcode := 5.U  // vector addition  
    addThreads(i).io.in.bits.iter := 1.U
    addThreads(i).io.out.ready := true.B
    
    when (state === s_accumulate && io.enable) {
      // 将mul结果加到累加器中
      val current_accum_value = accumulator(current_row)(current_col)
      val mul_result_to_add = mul_results(i)
      
      addThreads(i).io.in.bits.scalar := current_accum_value
      addThreads(i).io.in.bits.op2 := VecInit(Seq.fill(tp.lane)(mul_result_to_add))
      addThreads(i).io.in.bits.op1 := VecInit(Seq.fill(tp.lane)(0.U.asTypeOf(tp.dataFormat.dataType.cloneType)))
    }.otherwise {
      addThreads(i).io.in.bits.scalar := 0.U.asTypeOf(tp.dataFormat.dataType.cloneType)
      addThreads(i).io.in.bits.op2 := VecInit(Seq.fill(tp.lane)(0.U.asTypeOf(tp.dataFormat.dataType.cloneType)))
      addThreads(i).io.in.bits.op1 := VecInit(Seq.fill(tp.lane)(0.U.asTypeOf(tp.dataFormat.dataType.cloneType)))
    }
    
    // 收集累加结果
    add_results(i) := addThreads(i).io.out.bits.vRst(0)  // 取第一个元素作为标量结果
    add_valid(i) := addThreads(i).io.out.valid
  }
  
  // 更新累加器
  val all_add_valid = add_valid.reduce(_ && _)
  when (state === s_accumulate && all_add_valid) {
    // 将16个add thread的结果求和并更新到累加器
    val final_sum = add_results.reduce((a, b) => (a.asUInt + b.asUInt).asTypeOf(tp.dataFormat.dataType.cloneType))
    accumulator(current_row)(current_col) := final_sum
    
    // 如果是最后一个K，准备输出
    when (input_buffer.isLastK) {
      state := s_output
    }.otherwise {
      state := s_idle  // 继续接收下一个K的数据
    }
  }
  
  // 输出逻辑
  io.dataOut.valid := (state === s_output)
  io.dataOut.bits.result := accumulator(current_row)(current_col)
  io.dataOut.bits.rowIdx := current_row
  io.dataOut.bits.colIdx := current_col
  io.dataOut.bits.valid_result := true.B
  
  when (io.dataOut.fire) {
    state := s_idle
  }
  
  // 状态输出
  io.status.busy := (state =/= s_idle)
  io.status.processing_cell.row := current_row
  io.status.processing_cell.col := current_col  
  io.status.pipeline_stages := MuxCase(0.U, Seq(
    (state === s_multiply) -> 1.U,
    (state === s_accumulate) -> 2.U,
    (state === s_output) -> 3.U
  ))
}
