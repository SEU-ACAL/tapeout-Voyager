package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._
import gemmini.GemminiISA._
import gemmini.Util._
import gemmini.{GemminiArrayConfig, Arithmetic, ScratchpadReadIO, ScratchpadWriteIO}
import org.chipsalliance.cde.config.Parameters
import dataclass.data

// read sram
class LsuIssReq (implicit vc: VecConfig) extends Bundle {
  val op1 = Vec(16, UInt(8.W))
  val op2 = Vec(16, UInt(8.W))
}

class LsuIdResp (implicit vc: VecConfig) extends Bundle {
  val rd_complete = Bool()
}

// write sram
class CmtLsuReq (implicit vc: VecConfig) extends Bundle {
  val data = Vec(vc.thread_n, UInt(8.W))
  val addr = UInt(vc.sp_addr_w.W)
  val is_acc = Bool()
}

class VecLSU[T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V])
                                   (implicit p: Parameters, ev: Arithmetic[T], vc: VecConfig) extends Module {
  import config._
  import ev._
  val io = IO(new Bundle {
		val id_lsu_i  = Flipped(Decoupled(new IdLsuReq()))
		val cmt_lsu_i = Flipped(Decoupled(new CmtLsuReq()))

		val lsu_iss_o = Decoupled(new LsuIssReq())
		val lsu_id_o  = Output(new LsuIdResp())

		val lsu_sram0_read  = new ScratchpadReadIO(sp_bank_entries, sp_width)
		val lsu_sram0_write = new ScratchpadWriteIO(sp_bank_entries, sp_width, (sp_width / (aligned_to * 8)) max 1)
    val lsu_sram1_read  = new ScratchpadReadIO(sp_bank_entries, sp_width)
  })

// -----------------------------------------------------------------------------
// Read SRAM (装填操作数)
// -----------------------------------------------------------------------------
  // 遵循不会单独读取Op2的约束



// -----------------------------------------------------------------------------
// Read SRAM
// -----------------------------------------------------------------------------
  // RA
  when (io.id_lsu_i.fire) {
    io.lsu_sram0_read.req.valid        := true.B
    io.lsu_sram0_read.req.bits.addr    := io.id_lsu_i.bits.op1_addr
    io.lsu_sram1_read.req.valid        := true.B
    io.lsu_sram1_read.req.bits.addr    := io.id_lsu_i.bits.op2_addr      
  }.otherwise {
    io.lsu_sram0_read.req.valid        := false.B
    io.lsu_sram0_read.req.bits.addr    := 0.U
    io.lsu_sram1_read.req.valid        := false.B
    io.lsu_sram1_read.req.bits.addr    := 0.U
  }
  
  io.lsu_sram0_read.req.bits.fromDMA := false.B
  io.lsu_sram1_read.req.bits.fromDMA := false.B
  
  // RD
  io.lsu_sram0_read.resp.ready := true.B
  io.lsu_sram1_read.resp.ready := true.B

  val rdata0 = io.lsu_sram0_read.resp.bits.data
  val rdata1 = io.lsu_sram1_read.resp.bits.data
  val data_wire0 = Wire(Vec(16, UInt(8.W)))
  val data_wire1 = Wire(Vec(16, UInt(8.W)))
  for (i <- 0 until 16) { 
    data_wire0(i) := ((rdata0 >> (i*8)) & 0xFF.U).asUInt
    data_wire1(i) := ((rdata1 >> (i*8)) & 0xFF.U).asUInt
  }
  

// -----------------------------------------------------------------------------
// lsu<>id
// -----------------------------------------------------------------------------
  io.id_lsu_i.ready := true.B
  
  io.lsu_id_o.rd_complete := io.lsu_sram0_read.resp.fire && io.lsu_sram1_read.resp.fire

// -----------------------------------------------------------------------------
// lsu->iss
// -----------------------------------------------------------------------------
  io.lsu_iss_o.valid := io.lsu_sram0_read.resp.fire && io.lsu_sram1_read.resp.fire
  

  io.lsu_iss_o.bits.op1 := data_wire0
  io.lsu_iss_o.bits.op2 := data_wire1

// -----------------------------------------------------------------------------
// Write SRAM
// -----------------------------------------------------------------------------
  io.cmt_lsu_i.ready := true.B

  io.lsu_sram0_write.en := io.cmt_lsu_i.valid
  io.lsu_sram0_write.addr := io.cmt_lsu_i.bits.addr
  
  val wdata_uint = io.cmt_lsu_i.bits.data.zipWithIndex.map{ case (byte, i) => byte << (i * 8)}.reduce(_ | _)
  
  io.lsu_sram0_write.data := wdata_uint
  io.lsu_sram0_write.mask := VecInit(Seq.fill((sp_width / (aligned_to * 8)) max 1)(true.B))

}
