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

class LsuIdResp extends Bundle {
  val rd_complete = Bool()
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
		val lsu_id_o  = Output(new LsuIdResp())

		val lsu_sram_read  = new ScratchpadReadIO(sp_bank_entries, sp_width)
		val lsu_sram_write = new ScratchpadWriteIO(sp_bank_entries, sp_width, (sp_width / (aligned_to * 8)) max 1)
  })

  // 初始化所有ready信号
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
  val op1_data = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  val op2_data = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))

  val op1_rd = dontTouch(RegInit(false.B))
  val op2_rd = dontTouch(RegInit(false.B))
  val current_req  = RegInit(0.U(2.W)) // 01: op1, 10: op2
  val current_resp = RegInit(0.U(2.W)) // 01: op1, 10: op2

  // val id_lsu_hs = RegInit(false.B)
  // id_lsu_hs := io.id_lsu_i.valid && io.id_lsu_i.ready
  // val cmt_lsu_hs = io.cmt_lsu_i.valid && io.cmt_lsu_i.ready

  when (io.id_lsu_i.valid) {
    // 如果 op1/op2 无需读取直接标记为完成
    when (io.id_lsu_i.bits.op1_from_mem === false.B) { op1_rd_complete := true.B }
    when (io.id_lsu_i.bits.op2_from_mem === false.B) { op2_rd_complete := true.B }

    op1_rd := io.id_lsu_i.bits.op1_from_mem 
    op2_rd := io.id_lsu_i.bits.op2_from_mem 

		current_req := Mux(io.id_lsu_i.bits.op1_from_mem && !op1_rd_complete, 1.U,
                   Mux(io.id_lsu_i.bits.op2_from_mem && !op2_rd_complete, 2.U, current_req))
    current_resp := Mux(io.id_lsu_i.bits.op1_from_mem && !op1_rd_complete, 1.U,
                    Mux(io.id_lsu_i.bits.op2_from_mem && !op2_rd_complete, 2.U, current_resp))
  }
  // .otherwise {
	// 	op1_rd_complete := false.B
	// 	op2_rd_complete := false.B
	// 	current_req     := 0.U
  //   current_resp    := 0.U
  // }

  // 默认状态
  io.lsu_sram_read.req.valid         := false.B
  // io.lsu_sram_read.req.valid         := false.B
	io.lsu_sram_read.req.bits.fromDMA  := false.B
	io.lsu_sram_read.req.bits.addr     := 0.U

  // 发 RA
  val reading = RegInit(false.B)
  reading := Mux(io.id_lsu_i.valid, true.B, 
             Mux(op1_rd_complete && op2_rd_complete, false.B, reading))
  // 当 id 发送读请求时，进入reading状态，直到op1和op2都读取完成
  // TODO: 没考虑issue阶段不ready的情况
  
  // val lsu_sram_read_req_ready = dontTouch(WireInit(false.B))
  // lsu_sram_read_req_ready := io.lsu_sram_read.req.ready
  when (reading && io.lsu_sram_read.req.ready) {
		when (current_req === 1.U) {
			io.lsu_sram_read.req.valid     := true.B
			io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op1_addr
      current_req := current_req + 1.U
		}.elsewhen (current_req === 2.U) {
			io.lsu_sram_read.req.valid     := true.B
			io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op2_addr
      current_req := current_req + 1.U
		}//.otherwise {
		// 	io.lsu_sram_read.req.valid     := false.B
		// 	io.lsu_sram_read.req.bits.addr := 0.U
    // }
  }

  // 收 RD
  io.lsu_sram_read.resp.ready      := true.B
  val rdata = dontTouch(WireInit(0.U(128.W)))
  rdata := io.lsu_sram_read.resp.bits.data
  // val lsu_sram_read_resp_valid = dontTouch(WireInit(false.B))
  // lsu_sram_read_resp_valid := io.lsu_sram_read.resp.valid
  // val lsu_sram_read_resp_hs = dontTouch(WireInit(false.B))
  // lsu_sram_read_resp_hs := io.lsu_sram_read.resp.valid && io.lsu_sram_read.resp.ready
  when (reading && io.lsu_sram_read.resp.valid && io.lsu_sram_read.resp.ready) {
		when (current_resp === 1.U) {
			op1_rd_complete := true.B
			for (i <- 0 until 16) { op1_data(i) := ((rdata >> (i*8)) & 0xFF.U).asUInt}
      current_resp := current_resp + 1.U
    }.elsewhen (current_resp === 2.U) {
			op2_rd_complete := true.B
			for (i <- 0 until 16) { op2_data(i) := ((rdata >> (i*8)) & 0xFF.U).asUInt}
      current_resp := current_resp + 1.U
		}
  }

  // val waiting_op = RegInit(false.B)
  // waiting_op := Mux(io.id_lsu_i.valid, true.B, 
  //               Mux(reading && op1_rd_complete && op2_rd_complete, false.B, waiting_op))

  // io.id_lsu_i.ready  := !waiting_op 
  io.id_lsu_i.ready := true.B
  // io.id_lsu_i.ready := false.B
  // val latency = RegInit(0.U(1.W))
  // // when (io.id_lsu_i.valid) { latency := 1.U }
  // when (io.id_lsu_i.valid) { latency := 1.U }
  // when (reading && op1_rd_complete) { latency := 0.U }
  // // when (reading && op1_rd_complete) {
  // //   io.id_lsu_i.ready := latency === 0.U
  // // }.elsewhen (io.id_lsu_i.valid) {
  // //   io.id_lsu_i.ready := latency === 1.U
  // // }
  
  // io.id_lsu_i.ready := latency === 1.U

  // 当两个操作数都准备好时，发送完成信号到ID Stage
  // TODO:屎山代码
  io.lsu_id_o.rd_complete := reading && op1_rd_complete && op2_rd_complete

  // 当两个操作数都准备好时，发送到ISS Stage
  io.lsu_iss_o.valid             := reading && op1_rd_complete && op2_rd_complete
  io.lsu_iss_o.bits.op1_from_mem := Mux(io.lsu_iss_o.valid, op1_rd, false.B)
  io.lsu_iss_o.bits.op2_from_mem := Mux(io.lsu_iss_o.valid, op2_rd, false.B)
  io.lsu_iss_o.bits.op1          := Mux(op1_rd, op1_data, VecInit(Seq.fill(16)(0.U(8.W))))
  io.lsu_iss_o.bits.op2          := Mux(op2_rd, op2_data, VecInit(Seq.fill(16)(0.U(8.W))))

  when (io.lsu_iss_o.valid && io.lsu_iss_o.ready) {
    op1_rd_complete := false.B
    op2_rd_complete := false.B
  }
// -----------------------------------------------------------------------------
// Write SRAM
// -----------------------------------------------------------------------------
  // io.srams.write.mask := VecInit(Seq.fill(16)(true.B))
  // io.srams.write.addr := WriteAddr
  // io.srams.write.data := WriteData
  // io.srams.write.en := VecWrite

}