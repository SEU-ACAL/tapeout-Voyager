//===- BfpThread.scala - Level 1: BFP Thread ---===//
package buckyball.exec.bfp

import chisel3._
import chisel3.util._
import chisel3.stage._
import dialect.vector._
import dialect.format._



// BFP专用的规约操作（FP16 -> 共用指数 + 8位尾数向量）
class BfpReduceOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val data = Vec(t.lane, UInt(16.W))  // FP16输入向量
    }))
    val out = Valid(new Bundle {
      val blockExp = UInt(5.W)                // FP16的5位共用指数
      val mantissas = Vec(t.lane, UInt(8.W))  // 8位截断尾数向量
    })
  })
  
  io.out.valid := io.in.valid
  
  // 提取所有FP16数据的指数 (14:10)
  val exponents = Wire(Vec(t.lane, UInt(5.W)))
  val mantissas = Wire(Vec(t.lane, UInt(10.W)))
  
  for (i <- 0 until t.lane) {
    exponents(i) := io.in.bits.data(i)(14, 10)  // FP16指数位
    mantissas(i) := io.in.bits.data(i)(9, 0)    // FP16尾数位
  }
  
  // 找到最大指数作为块指数
  val blockExp = exponents.reduce((a, b) => Mux(a > b, a, b))
  io.out.bits.blockExp := blockExp
  
  // 将所有尾数对齐到块指数，并截断为8位
  io.out.bits.mantissas := (mantissas zip exponents).map { case (mantissa, exp) =>
    val expDiff = blockExp - exp
    val alignedMantissa = Mux(expDiff > 8.U, 0.U,
                             Mux(expDiff === 0.U, mantissa, mantissa >> expDiff))
    
    // 截断为8位，取高8位
    alignedMantissa(9, 2)  // 取10位尾数的高8位
  }
}

// BFP Thread类，继承自BaseThread并添加BFP特定功能
abstract class BfpBaseThread(
  override val hasMul           : Boolean       = false,
  override val hasMax           : Boolean       = false,
  override val hasPop           : Boolean       = false,
  override val hasSquare        : Boolean       = false,
  override val hasAdd           : Boolean       = false,  
  override val hasSub           : Boolean       = false,
  override val hasDiv           : Boolean       = false,
  override val hasVecMul        : Boolean       = false,
  val hasBfpReduce     : Boolean       = false   // BFP规约操作
)(implicit p: ThreadParams) extends BaseThread(
  hasMul = hasMul,
  hasMax = hasMax, 
  hasPop = hasPop,
  hasSquare = hasSquare,
  hasAdd = hasAdd,
  hasSub = hasSub,
  hasDiv = hasDiv,
  hasVecMul = hasVecMul
) {
  // 不重新定义io，保持与BaseThread兼容
  // BFP特定的字段通过其他方式暴露
}

// 具体的BFP Thread实现
class BfpThread(implicit t: ThreadParams) extends BfpBaseThread(
  hasMul       = t.Ops.mul,
  hasMax       = t.Ops.max,
  hasPop       = t.Ops.pop,
  hasSquare    = t.Ops.square,
  hasAdd       = t.Ops.add,
  hasSub       = t.Ops.sub,
  hasDiv       = t.Ops.div,
  hasVecMul    = t.Ops.vmul,
  hasBfpReduce = true      // 默认启用BFP规约
) {

//===----------------------------------------------------------------------===//
// BFP专用寄存器
//===----------------------------------------------------------------------===//
  val busy      = RegInit(false.B)
  val op1       = RegInit(VecInit(Seq.fill(t.lane)(0.U(16.W))))     // FP16输入
  val op2       = RegInit(VecInit(Seq.fill(t.lane)(0.U(16.W))))     // FP16输入
  val scalar    = RegInit(0.U(16.W))                                // FP16标量
  val blockExp  = RegInit(0.U(5.W))                                 // 共用的5位指数
  val mantissas = RegInit(VecInit(Seq.fill(t.lane)(0.U(8.W))))     // 8位尾数向量
  val opcode    = RegInit(0.U(8.W))
  val iter      = RegInit(0.U(4.W))
  
  // BFP专用操作模块
  var bfpReduce: BfpReduceOp = null
  
  // 输入处理逻辑
  io.in.ready := !busy
  when (io.in.fire) {
    op1       := io.in.bits.op1.asTypeOf(Vec(t.lane, UInt(16.W)))
    op2       := io.in.bits.op2.asTypeOf(Vec(t.lane, UInt(16.W)))
    scalar    := io.in.bits.scalar.asTypeOf(UInt(16.W))
    opcode    := io.in.bits.opcode
    iter      := io.in.bits.iter
    busy      := true.B
  }.otherwise {
    busy := iter =/= 0.U
  }
  
  // BFP规约操作实例化
  if (hasBfpReduce) {
    bfpReduce = Module(new BfpReduceOp())
    // 默认值
    bfpReduce.io.in.valid := false.B
    bfpReduce.io.in.bits.data := VecInit(Seq.fill(t.lane)(0.U(16.W)))
    
    when ((io.in.fire && (opcode === 10.U)) || opcode === 10.U) {
      bfpReduce.io.in.valid := true.B
      bfpReduce.io.in.bits.data := op1
      iter := iter - 1.U
    }
  }
  
  // BFP输出逻辑
  io.out.valid := false.B
  io.out.bits.sRst := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
  io.out.bits.vRst := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
  
  if (hasBfpReduce) {
    when (opcode === 10.U) {
      // 保存规约结果到寄存器
      blockExp := bfpReduce.io.out.bits.blockExp
      mantissas := bfpReduce.io.out.bits.mantissas
      
      io.out.valid := bfpReduce.io.out.valid
      io.out.bits.vRst := bfpReduce.io.out.bits.mantissas.asTypeOf(Vec(t.lane, t.dataFormat.dataType.cloneType))
      // blockExp信息保存在内部寄存器中，不需要额外输出
    }
  }
}

