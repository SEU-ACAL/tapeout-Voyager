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

  io.id_iss_i.ready := true.B
  io.lsu_iss_i.ready := true.B

  io.iss_ex_o.valid          := io.id_iss_i.valid && !io.id_iss_i.bits.op1_from_mem && !io.id_iss_i.bits.op2_from_mem || // 无需访存
                                io.lsu_iss_i.valid
  io.iss_ex_o.bits.op1       := Mux(io.id_iss_i.valid && !io.id_iss_i.bits.op1_from_mem, io.id_iss_i.bits.op1, 
                          Mux(io.lsu_iss_i.valid, io.lsu_iss_i.bits.op1, VecInit(Seq.fill(16)(0.U(8.W)))))
  io.iss_ex_o.bits.op2       := Mux(io.id_iss_i.valid && !io.id_iss_i.bits.op2_from_mem, io.id_iss_i.bits.op2, 
                          Mux(io.lsu_iss_i.valid, io.lsu_iss_i.bits.op2, VecInit(Seq.fill(16)(0.U(8.W)))))
  io.iss_ex_o.bits.config    := io.id_iss_i.bits.config
  io.iss_ex_o.bits.iteration := io.id_iss_i.bits.iteration
  io.iss_ex_o.bits.thread_id := io.id_iss_i.bits.thread_id
}
