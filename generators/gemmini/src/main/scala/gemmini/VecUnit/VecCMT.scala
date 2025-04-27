package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters
import gemmini.{GemminiArrayConfig}

// class VecCMT_output[T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V])
//                                           (implicit p: Parameters) extends Bundle {
//   import config._
//   val completed = Valid(UInt(log2Up(reservation_station_entries).W))
// }

class VecCMT[T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V])
                                  (implicit p: Parameters, vc: VecConfig) extends Module {
  import config._
  val io = IO(new Bundle {
    val ex_cmt_i  = Flipped(Decoupled(new ExCmtReq()))
    
    val cmt_lsu_o = Decoupled(new CmtLsuReq())
    // val lsu_cmt_i = Flipped(Decoupled(new LsuCmtReq()))
    
    // val cmt_o     = new VecCMT_output(config) // to the top
  })

  io.ex_cmt_i.ready := true.B
// -----------------------------------------------------------------------------
// Write Back to SRAM
// -----------------------------------------------------------------------------
  when (io.ex_cmt_i.bits.wb_en) {
    io.cmt_lsu_o.valid       := true.B
    io.cmt_lsu_o.bits.data   := io.ex_cmt_i.bits.wb_data
    io.cmt_lsu_o.bits.addr   := io.ex_cmt_i.bits.wb_addr
    io.cmt_lsu_o.bits.is_acc := io.ex_cmt_i.bits.is_acc
  }.otherwise {
    io.cmt_lsu_o.valid       := false.B
    io.cmt_lsu_o.bits.data   := VecInit(Seq.fill(16)(0.U(8.W)))
    io.cmt_lsu_o.bits.addr   := 0.U
    io.cmt_lsu_o.bits.is_acc := false.B
  }
// -----------------------------------------------------------------------------
// Inst Commit
// -----------------------------------------------------------------------------
  // when (io.ex_cmt_i.valid) {
  //   io.cmt_o.completed.valid := io.ex_cmt_i.bits.rob_id_valid
  //   io.cmt_o.completed.bits  := io.ex_cmt_i.bits.rob_id
  // }.otherwise {
  //   io.cmt_o.completed.valid := false.B
  //   io.cmt_o.completed.bits  := 0.U
  // }
}
