package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._

class VecEX extends Module {
  val io = IO(new Bundle {
    val iss_ex_i = Flipped(Decoupled(new IssExReq()))
    val ex_cmt_o = Decoupled(new ExCmtReq())
  })

  // val op1_data = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  // val op2_data = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))

  // when (io.iss_ex_i.valid) {
  //   for (i <- 0 until 16) {
  //     op1_data(i) := io.iss_ex_i.bits.op1(i)
  //     op2_data(i) := io.iss_ex_i.bits.op2(i)
  //   }
  // }
  // 记录每个Thread的busy状态
  val scoreboard = VecInit(Seq.fill(8)(0.U(1.W)))

  // 实例化8个Thread(16个Vector)和1个TC(16个Vector)
  val threads = Seq.fill(8)(Module(new VecALUThread()))
  val tensorCore = Module(new VecTC())
  
  // 根据thread_id动态连接
  io.iss_ex_i.ready := true.B
  // io.iss_ex_i.ready := threads.map(_.io.in.ready).reduce(_ || _)
  when (io.iss_ex_i.valid) {
    for (i <- 0 until 8) {
      when (io.iss_ex_i.bits.thread_id === i.U) {
        // threads(i).io.in <> io.iss_ex_i
        threads(i).io.in.valid          := true.B
        threads(i).io.in.bits.op1       := io.iss_ex_i.bits.op1
        threads(i).io.in.bits.op2       := io.iss_ex_i.bits.op2
        threads(i).io.in.bits.config    := io.iss_ex_i.bits.config
        threads(i).io.in.bits.iteration := io.iss_ex_i.bits.iteration
        threads(i).io.in.bits.thread_id := io.iss_ex_i.bits.thread_id
        threads(i).io.in.bits.rob_id    := io.iss_ex_i.bits.rob_id
      }.otherwise {
        threads(i).io.in.valid          := false.B
        threads(i).io.in.bits.op1       := VecInit(Seq.fill(16)(0.U(8.W)))
        threads(i).io.in.bits.op2       := VecInit(Seq.fill(16)(0.U(8.W)))
        threads(i).io.in.bits.config    := 0.U(13.W) 
        threads(i).io.in.bits.iteration := 0.U(4.W)
        threads(i).io.in.bits.thread_id := i.U
        threads(i).io.in.bits.rob_id    := 0.U(5.W)
      }
    } 
  }.otherwise {
    for (i <- 0 until 8) {
      threads(i).io.in.valid          := false.B
      threads(i).io.in.bits.op1       := VecInit(Seq.fill(16)(0.U(8.W)))
      threads(i).io.in.bits.op2       := VecInit(Seq.fill(16)(0.U(8.W)))
      threads(i).io.in.bits.config    := 0.U(13.W) 
      threads(i).io.in.bits.iteration := 0.U(4.W)
      threads(i).io.in.bits.thread_id := i.U
      threads(i).io.in.bits.rob_id    := 0.U(5.W)
    }
  }
  
  // 连接ALU1到TC
  for (i <- 0 until 8) { tensorCore.io.in(i) <> threads(i).io.out}
  
  // 连接TC的输出
  tensorCore.io.out.ready := true.B
  io.ex_cmt_o <> tensorCore.io.out
}
