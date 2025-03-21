package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._

class VecEX extends Module {
  val io = IO(new Bundle {
  val iss_ex_i = Flipped(Decoupled(new IssExReq()))
  val ex_cmt_o = Decoupled(new ExCmtReq())
  })

  // 实例化8个Thread(16个Vector)和1个TC(16个Vector)
  val threads = Seq.fill(8)(Module(new VecALUThread()))
  val tensorCore = Module(new VecTC())
  
  // 创建一个连接数组，根据thread_id动态连接
  for (i <- 0 until 8) {
    when (io.iss_ex_i.bits.thread_id === i.U) {
      threads(i).io.in <> io.iss_ex_i
    }.otherwise {
      threads(i).io.in.valid := false.B
      threads(i).io.in.bits := DontCare
    }
  }
  
  // 连接ALU1到TC
  for (i <- 0 until 8) { tensorCore.io.in(i) <> threads(i).io.out}
  
  // 连接TC的输出
  io.ex_cmt_o <> tensorCore.io.out
  tensorCore.io.out.ready := io.ex_cmt_o.ready

  io.iss_ex_i.ready := threads.map(_.io.in.ready).reduce(_ || _)
}
