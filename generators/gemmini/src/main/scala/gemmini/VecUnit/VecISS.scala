package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._


class VecISS extends Module {
  val io = IO(new Bundle {
    val id_iss_i  = Flipped(Decoupled(new IdIssReq()))
    val lsu_iss_i = Flipped(Decoupled(new LsuIssReq()))

    val iss_ex_o = Decoupled(new IssExReq())
  })

  
  val bypass_lsu = io.id_iss_i.valid && !io.id_iss_i.bits.op1_from_mem && 
                   !io.id_iss_i.bits.op2_from_mem
  val ops_ready = bypass_lsu || io.lsu_iss_i.valid

  io.id_iss_i.ready  := true.B

// -----------------------------------------------------------------------------
// lsu->iss
// -----------------------------------------------------------------------------
  io.lsu_iss_i.ready         := true.B

// -----------------------------------------------------------------------------
// iss->ex
// -----------------------------------------------------------------------------
  io.iss_ex_o.valid          := ops_ready
  io.iss_ex_o.bits.op1       := Mux(bypass_lsu, io.id_iss_i.bits.op1, 
                                Mux(io.lsu_iss_i.valid, io.lsu_iss_i.bits.op1, 
                                    VecInit(Seq.fill(16)(0.U(8.W)))))
  io.iss_ex_o.bits.op2       := Mux(bypass_lsu, io.id_iss_i.bits.op2, 
                                Mux(io.lsu_iss_i.valid, io.lsu_iss_i.bits.op2, 
                                    VecInit(Seq.fill(16)(0.U(8.W)))))
  io.iss_ex_o.bits.config    := io.id_iss_i.bits.config
  io.iss_ex_o.bits.iteration := io.id_iss_i.bits.iteration
  io.iss_ex_o.bits.thread_id := io.id_iss_i.bits.thread_id
  io.iss_ex_o.bits.rob_id    := io.id_iss_i.bits.rob_id
}
