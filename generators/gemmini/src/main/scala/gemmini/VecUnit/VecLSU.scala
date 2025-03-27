package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._
import gemmini.GemminiISA._
import gemmini.Util._
import gemmini.{GemminiArrayConfig, Arithmetic, ScratchpadReadIO, ScratchpadWriteIO}
import org.chipsalliance.cde.config.Parameters

// read sram
class LsuIssReq extends Bundle {
  val op1 = Vec(16, UInt(8.W))
  val op2 = Vec(16, UInt(8.W))
}

class LsuIdResp extends Bundle {
  val rd_complete = Bool()
}

// write sram
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
		val lsu_id_o  = Output(new LsuIdResp())

		val lsu_sram_read  = new ScratchpadReadIO(sp_bank_entries, sp_width)
		val lsu_sram_write = new ScratchpadWriteIO(sp_bank_entries, sp_width, (sp_width / (aligned_to * 8)) max 1)
  })

// -----------------------------------------------------------------------------
// Read SRAM (装填操作数)
// -----------------------------------------------------------------------------
  val sIdle :: sRead :: sIssue :: Nil = Enum(3)
  val state = RegInit(sIdle)
  // 遵循不会单独读取Op2的约束

  val op1_data = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val op2_data = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  
  val one_operand  = RegInit(false.B)
  val op1_addr = RegInit(0.U(14.W))
  val op2_addr = RegInit(0.U(14.W))

  switch (state) {
    is(sIdle) {
      when (io.id_lsu_i.fire) {
          state := sRead
        }.otherwise {
          state := sIdle
        }
    }

    is(sRead) {
      when (io.lsu_sram_read.resp.fire) {
        state := sIssue
      }.otherwise {
        state := sRead
      }
    }

    is(sIssue) {
      when (io.lsu_iss_o.fire) {
        when (io.id_lsu_i.fire) {
          state := sRead
        }.otherwise {
          state := sIdle
        }
      }
    }
  }

// -----------------------------------------------------------------------------
// Read SRAM
// -----------------------------------------------------------------------------
  // RA
  when (state === sIdle && io.id_lsu_i.fire) {
    io.lsu_sram_read.req.valid        := true.B
    io.lsu_sram_read.req.bits.addr    := io.id_lsu_i.bits.op1_addr
  }.elsewhen (state === sRead && !one_operand) {
    io.lsu_sram_read.req.valid        := true.B
    io.lsu_sram_read.req.bits.addr    := io.id_lsu_i.bits.op2_addr
  }.elsewhen (state === sIssue && io.id_lsu_i.fire) {
    io.lsu_sram_read.req.valid        := true.B
    io.lsu_sram_read.req.bits.addr    := io.id_lsu_i.bits.op1_addr
  }.otherwise {
    io.lsu_sram_read.req.valid        := false.B
    io.lsu_sram_read.req.bits.addr    := 0.U
  }
  
  io.lsu_sram_read.req.bits.fromDMA := false.B
  
  // RD
  io.lsu_sram_read.resp.ready := true.B

  val rdata = io.lsu_sram_read.resp.bits.data
  val data_wire = Wire(Vec(16, UInt(8.W)))
  for (i <- 0 until 16) { data_wire(i) := ((rdata >> (i*8)) & 0xFF.U).asUInt }
  
  // when(io.lsu_sram_read.resp.fire && !one_operand) { op1_data := data_wire }
  op1_data := data_wire

// -----------------------------------------------------------------------------
// lsu<>id
// -----------------------------------------------------------------------------
  io.id_lsu_i.ready := state === sIdle || state === sIssue
  
  io.lsu_id_o.rd_complete := (state === sRead) && io.lsu_sram_read.resp.fire

// -----------------------------------------------------------------------------
// lsu->iss
// -----------------------------------------------------------------------------
  io.lsu_iss_o.valid := state === sIssue
  
  io.lsu_iss_o.bits.op1 := op1_data
  io.lsu_iss_o.bits.op2 := Mux(!one_operand, data_wire, VecInit(Seq.fill(16)(0.U(8.W))))

// -----------------------------------------------------------------------------
// Write SRAM
// -----------------------------------------------------------------------------
  io.cmt_lsu_i.ready := true.B

  io.lsu_sram_write.en := io.cmt_lsu_i.valid
  io.lsu_sram_write.addr := io.cmt_lsu_i.bits.addr
  
  val wdata_uint = io.cmt_lsu_i.bits.data.zipWithIndex.map{ case (byte, i) => byte << (i * 8)}.reduce(_ | _)
  
  io.lsu_sram_write.data := wdata_uint
  io.lsu_sram_write.mask := VecInit(Seq.fill((sp_width / (aligned_to * 8)) max 1)(true.B))

}
