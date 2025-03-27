package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._

import gemmini.VecUnit.ex.VecALUThread
import gemmini.VecUnit.ex.VecReduce
// import gemmini.VecUnit.ex.VecLUTThread
// import gemmini.VecUnit.ex.VecTC

class VecEX extends Module {
  val io = IO(new Bundle {
    val iss_ex_i = Flipped(Decoupled(new IssExReq()))
    val ex_cmt_o = Decoupled(new ExCmtReq())
  })

  // 记录每个Thread的busy状态
  val scoreboard = RegInit(VecInit(Seq.fill(16)(0.U(1.W))))

  // 实例化8个Thread(16个Vector)和1个TC(16个Vector)和1个Reduce(16个Vector)
  val alu_threads = Seq.fill(8)(Module(new VecALUThread()))
  // val lut_threads = Seq.fill(8)(Module(new VecLUTThread()))
  // val tc = Module(new VecTC())
  val reduce = Module(new VecReduce())

// -----------------------------------------------------------------------------
// Inputs->threads(ALUthread/LUTthread)
// -----------------------------------------------------------------------------
  io.iss_ex_i.ready := true.B

  when (io.iss_ex_i.valid) {
    for (i <- 0 until 8) {
      when (io.iss_ex_i.bits.thread_id === i.U) {
        alu_threads(i).io.in <> io.iss_ex_i
      }.otherwise {
        alu_threads(i).io.in.valid          := false.B
        alu_threads(i).io.in.bits.op1       := VecInit(Seq.fill(16)(0.U(8.W)))
        alu_threads(i).io.in.bits.op2       := VecInit(Seq.fill(16)(0.U(8.W)))
        alu_threads(i).io.in.bits.config    := 0.U(16.W) 
        alu_threads(i).io.in.bits.iteration := 0.U(4.W)
        alu_threads(i).io.in.bits.thread_id := i.U
        alu_threads(i).io.in.bits.rob_id    := 0.U(5.W)
      }
    } 
  }.otherwise {
    for (i <- 0 until 8) {
      alu_threads(i).io.in.valid          := false.B
      alu_threads(i).io.in.bits.op1       := VecInit(Seq.fill(16)(0.U(8.W)))
      alu_threads(i).io.in.bits.op2       := VecInit(Seq.fill(16)(0.U(8.W)))
      alu_threads(i).io.in.bits.config    := 0.U(16.W) 
      alu_threads(i).io.in.bits.iteration := 0.U(4.W)
      alu_threads(i).io.in.bits.thread_id := i.U
      alu_threads(i).io.in.bits.rob_id    := 0.U(5.W)
    }
  }
    
  for (i <- 0 until 8) { reduce.io.in(i) <> alu_threads(i).io.out}
  reduce.io.out.ready := true.B
  io.ex_cmt_o <> reduce.io.out
}
