package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._

// import VecPipeline._
// import VecLSU._


class VecISS extends Module {
  val io = IO(new Bundle {
    val id_iss_i  = Flipped(Decoupled(new IdIssReq()))
    val lsu_iss_i = Flipped(Decoupled(new LsuIssReq()))

    val iss_ex_o = Decoupled(new IssExReq())
  })




  // val op1 = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  // val op2 = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))

  // when (io.id_iss_i.valid) {
  //   op1 := io.id_iss_i.bits.op1
  //   op2 := io.id_iss_i.bits.op2
  // }

  val config    = RegInit(0.U(13.W))
  val iteration = RegInit(0.U(4.W))
  val thread_id = RegInit(0.U(3.W))
  val rob_id    = RegInit(0.U(5.W))

  when (io.id_iss_i.valid) {
    config    := io.id_iss_i.bits.config
    iteration := io.id_iss_i.bits.iteration
    thread_id := io.id_iss_i.bits.thread_id
    rob_id    := io.id_iss_i.bits.rob_id
  }
  
  val bypass_lsu = io.id_iss_i.valid && !io.id_iss_i.bits.op1_from_mem && 
                   !io.id_iss_i.bits.op2_from_mem
  val ops_ready = bypass_lsu || io.lsu_iss_i.valid

  // val waiting_op = RegInit(false.B)
  // waiting_op := Mux(io.id_iss_i.valid && !bypass_lsu, true.B, 
  //               Mux(io.lsu_iss_i.valid, false.B, waiting_op))

  // io.id_iss_i.ready  := !waiting_op
  io.id_iss_i.ready  := true.B
  io.lsu_iss_i.ready := true.B

  io.iss_ex_o.valid          := ops_ready
  io.iss_ex_o.bits.op1       := Mux(bypass_lsu, io.id_iss_i.bits.op1, 
                                Mux(io.lsu_iss_i.valid, io.lsu_iss_i.bits.op1, 
                                    VecInit(Seq.fill(16)(0.U(8.W)))))
  io.iss_ex_o.bits.op2       := Mux(bypass_lsu, io.id_iss_i.bits.op2, 
                                Mux(io.lsu_iss_i.valid, io.lsu_iss_i.bits.op2, 
                                    VecInit(Seq.fill(16)(0.U(8.W)))))
  io.iss_ex_o.bits.config    := Mux(bypass_lsu,    io.id_iss_i.bits.config, config)
  io.iss_ex_o.bits.iteration := Mux(bypass_lsu, io.id_iss_i.bits.iteration, iteration)
  io.iss_ex_o.bits.thread_id := Mux(bypass_lsu, io.id_iss_i.bits.thread_id, thread_id)
  io.iss_ex_o.bits.rob_id    := Mux(bypass_lsu, io.id_iss_i.bits.rob_id, rob_id)
}
