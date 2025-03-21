package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._
import gemmini.GemminiISA._
import gemmini.Util._
import gemmini.{GemminiArrayConfig, Arithmetic, ScratchpadReadIO, ScratchpadWriteIO}
import org.chipsalliance.cde.config.Parameters

class LsuIssReq extends Bundle {
  val op1 = Vec(16, UInt(8.W))
  val op2 = Vec(16, UInt(8.W))
  val op1_from_mem = Bool()
  val op2_from_mem = Bool()
}

class CmtLsuReq extends Bundle {
  val data = Vec(16, UInt(8.W))
  val addr = UInt(14.W)
  val is_acc = Bool()
}

class VecLSU[T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V])
                                   (implicit p: Parameters, ev: Arithmetic[T]) extends Module {
  import config._
  import ev._
  val io = IO(new Bundle {
		val id_lsu_i  = Flipped(Decoupled(new IdLsuReq()))
		val cmt_lsu_i = Flipped(Decoupled(new CmtLsuReq()))

		val lsu_iss_o = Decoupled(new LsuIssReq())

		val lsu_sram_read  = new ScratchpadReadIO(sp_bank_entries, sp_width)
		val lsu_sram_write = new ScratchpadWriteIO(sp_bank_entries, sp_width, (sp_width / (aligned_to * 8)) max 1)
  })

  // 初始化所有ready信号
  io.id_lsu_i.ready := true.B
  io.cmt_lsu_i.ready := true.B
  
  // 初始化SRAM写操作相关信号
  io.lsu_sram_write.en := false.B
  io.lsu_sram_write.addr := 0.U
  io.lsu_sram_write.data := 0.U
  io.lsu_sram_write.mask := VecInit(Seq.fill((sp_width / (aligned_to * 8)) max 1)(false.B))

  // 初始化SRAM读请求信号
  io.lsu_sram_read.req.valid := false.B
  io.lsu_sram_read.req.bits.addr := 0.U
  io.lsu_sram_read.req.bits.fromDMA := false.B

// -----------------------------------------------------------------------------
// Read SRAM (装填操作数)
// -----------------------------------------------------------------------------
  val op1_rd_complete = RegInit(false.B)
  val op2_rd_complete = RegInit(false.B)
  val op1_data = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val op2_data = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val current_req = RegInit(0.U(1.W)) // 0: op1, 1: op2

  // op1/op2 无需读取直接标记为完成
  when (io.id_lsu_i.valid) {
		op1_rd_complete := !io.id_lsu_i.bits.op1_from_mem
		op2_rd_complete := !io.id_lsu_i.bits.op2_from_mem

		current_req := Mux(io.id_lsu_i.bits.op1_from_mem && !op1_rd_complete, 0.U,
                   Mux(io.id_lsu_i.bits.op2_from_mem && !op2_rd_complete, 1.U,
                       current_req))
  }
  // 发 RA
  io.lsu_sram_read.resp.ready          := true.B
  when (io.id_lsu_i.valid) {
		io.lsu_sram_read.req.bits.fromDMA  := false.B
		when (current_req === 0.U) {
			io.lsu_sram_read.req.valid     := true.B
			io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op1_addr
		}.elsewhen (current_req === 1.U) {
			io.lsu_sram_read.req.valid     := true.B
			io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op2_addr
		}
  }.otherwise {
		io.lsu_sram_read.req.valid     := false.B
		io.lsu_sram_read.req.bits.addr := 0.U
  }

  // 收 RD
  when (io.lsu_sram_read.resp.valid && io.lsu_sram_read.resp.ready) {
		when (current_req === 0.U) {
			op1_rd_complete := true.B
			for (i <- 0 until 16) {
					op1_data(i) := ((io.lsu_sram_read.resp.bits.data >> (i*8)) & 0xFF.U).asUInt
			}
		}.elsewhen (current_req === 1.U) {
			op2_rd_complete := true.B
			for (i <- 0 until 16) {
				op2_data(i) := ((io.lsu_sram_read.resp.bits.data >> (i*8)) & 0xFF.U).asUInt
			}
		}
  }

  // 当两个操作数都准备好时，发送到ISS Stage
  io.lsu_iss_o.valid             := op1_rd_complete && op2_rd_complete
  io.lsu_iss_o.bits.op1          := Mux(io.id_lsu_i.bits.op1_from_mem, op1_data, VecInit(Seq.fill(16)(0.U(8.W))))
  io.lsu_iss_o.bits.op2          := Mux(io.id_lsu_i.bits.op2_from_mem, op2_data, VecInit(Seq.fill(16)(0.U(8.W))))
  io.lsu_iss_o.bits.op1_from_mem := io.id_lsu_i.bits.op1_from_mem
  io.lsu_iss_o.bits.op2_from_mem := io.id_lsu_i.bits.op2_from_mem

// -----------------------------------------------------------------------------
// Write SRAM
// -----------------------------------------------------------------------------
  // io.srams.write.mask := VecInit(Seq.fill(16)(true.B))
  // io.srams.write.addr := WriteAddr
  // io.srams.write.data := WriteData
  // io.srams.write.en := VecWrite

}