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

  
  // 初始化SRAM读请求信号
  io.lsu_sram_read.req.valid := false.B
  io.lsu_sram_read.req.bits.addr := 0.U
  io.lsu_sram_read.req.bits.fromDMA := false.B

// -----------------------------------------------------------------------------
// Read SRAM (装填操作数)
// -----------------------------------------------------------------------------
  val sIdle :: sReadOp1 :: sReadOp2 :: sReadBoth :: sIssue :: Nil = Enum(5)
  val state = RegInit(sIdle)
  
  // val op1_from_mem = RegInit(false.B)
  // val op2_from_mem = RegInit(false.B)
  // val op1_addr     = RegInit(0.U(14.W))
  // val op2_addr     = RegInit(0.U(14.W))
  
  val op1_data = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val op2_data = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  
  val op1_ready = RegInit(false.B)
  val op2_ready = RegInit(false.B) // 这两个信号是屎山

  // 表示正在读取哪个操作数
  val reading_op2 = RegInit(false.B) // 屎山:遵循不会单独读Op2的约束,读一个操作数时就是Op1


  switch(state) {
    is(sIdle) {
      when (io.id_lsu_i.valid) {
        // 如果op1/op2不需要从内存读取，直接标记为就绪
        when (!io.id_lsu_i.bits.op1_from_mem) { op1_ready := true.B }
        when (!io.id_lsu_i.bits.op2_from_mem) { op2_ready := true.B }

        when (!io.lsu_sram_read.req.ready) {
          state := sIdle
        }.elsewhen (io.id_lsu_i.bits.op1_from_mem && io.id_lsu_i.bits.op2_from_mem) {
          io.lsu_sram_read.req.valid := true.B
          io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op1_addr
          reading_op2 := false.B
          state := sReadBoth // 都要读
        }.elsewhen (io.id_lsu_i.bits.op1_from_mem) {
          io.lsu_sram_read.req.valid := true.B
          io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op1_addr
          reading_op2 := false.B
          state := sReadOp1 // 只读取op1
        }.elsewhen (io.id_lsu_i.bits.op2_from_mem) {
          io.lsu_sram_read.req.valid := true.B
          io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op2_addr
          state := sReadOp2 // 只读取op2
        }.otherwise {
          state := sIssue
        }
      }
    }

    is(sIssue) {
      when (io.id_lsu_i.valid) {
        // 如果op1/op2不需要从内存读取，直接标记为就绪
        op1_ready := Mux(!io.id_lsu_i.bits.op1_from_mem, true.B, 
                       Mux(io.lsu_iss_o.ready && !io.id_lsu_i.valid, false.B, op1_ready))
        op2_ready := Mux(!io.id_lsu_i.bits.op2_from_mem, true.B, 
                       Mux(io.lsu_iss_o.ready && !io.id_lsu_i.valid, false.B, op2_ready))

        when (io.lsu_iss_o.ready && !io.id_lsu_i.valid) {
          state := sIdle
        }.elsewhen (io.id_lsu_i.bits.op1_from_mem && io.id_lsu_i.bits.op2_from_mem) {
          io.lsu_sram_read.req.valid := true.B
          io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op1_addr
          reading_op2 := false.B
          state := sReadBoth // 都要读
        }.elsewhen (io.id_lsu_i.bits.op1_from_mem) {
          io.lsu_sram_read.req.valid := true.B
          io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op1_addr
          reading_op2 := false.B
          state := sReadOp1 // 只读取op1
        }.elsewhen (io.id_lsu_i.bits.op2_from_mem) {
          io.lsu_sram_read.req.valid := true.B
          io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op2_addr
          state := sReadOp2 // 只读取op2
        }.otherwise {
          state := sIssue
        }
      }
    }
    
    is(sReadBoth) {
      when (!reading_op2) {
        io.lsu_sram_read.req.valid := true.B
        io.lsu_sram_read.req.bits.addr := io.id_lsu_i.bits.op2_addr
        reading_op2 := true.B
      }
      
      when (io.lsu_sram_read.resp.valid) {
        // when (!op1_ready) { 
          op1_ready := true.B 
          state := sIssue 
        // }//.elsewhen (!op2_ready) { 
        //   op2_ready := true.B 
        // }
      }
    }

    is(sReadOp1) {
      when(io.lsu_sram_read.resp.valid) { 
        op1_ready := true.B
        state := sIssue 
      }
    }
    
    is(sReadOp2) {
      when(io.lsu_sram_read.resp.valid) { 
        op2_ready := true.B
        state := sIssue 
      }
    }
  }

// -----------------------------------------------------------------------------
// Read SRAM
// -----------------------------------------------------------------------------
  // RA
  io.lsu_sram_read.req.bits.fromDMA := false.B
  
  // RD
  io.lsu_sram_read.resp.ready := !(state === sIdle)
  val rdata = io.lsu_sram_read.resp.bits.data
  val op1_data_wire = WireInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val op2_data_wire = WireInit(VecInit(Seq.fill(16)(0.U(8.W))))

  when(io.lsu_sram_read.resp.valid && io.lsu_sram_read.resp.ready) {
    when((state === sReadOp1) || (state === sReadBoth && !op1_ready)) {
      for (i <- 0 until 16) { op1_data_wire(i) := ((rdata >> (i*8)) & 0xFF.U).asUInt }
      op1_data := op1_data_wire
    }.elsewhen((state === sReadOp2) || (state === sReadBoth && !op2_ready)) {
      for (i <- 0 until 16) { op2_data_wire(i) := ((rdata >> (i*8)) & 0xFF.U).asUInt }
      op2_data := op2_data_wire
    }
  }


// -----------------------------------------------------------------------------
// lsu<>id
// -----------------------------------------------------------------------------
  io.id_lsu_i.ready := state === sIdle || state === sIssue
  
  // 读取完成信号
  io.lsu_id_o.rd_complete := (state === sReadBoth || state === sReadOp1 || 
                              state === sReadOp2) && io.lsu_sram_read.resp.valid//state === sIssue

// -----------------------------------------------------------------------------
// lsu->iss
// -----------------------------------------------------------------------------
  // 当op1和op2都准备好时，向ISS阶段发送数据
  // 没有考虑iss不ready的情况
  io.lsu_iss_o.valid := state === sIssue
  io.lsu_iss_o.bits.op1 := Mux(io.id_lsu_i.bits.op2_from_mem, op1_data, op1_data_wire)
  io.lsu_iss_o.bits.op2 := op2_data_wire // bypass

// -----------------------------------------------------------------------------
// Write SRAM
// -----------------------------------------------------------------------------
  io.cmt_lsu_i.ready := true.B

  io.lsu_sram_write.en := false.B
  io.lsu_sram_write.addr := 0.U
  io.lsu_sram_write.data := 0.U
  io.lsu_sram_write.mask := VecInit(Seq.fill((sp_width / (aligned_to * 8)) max 1)(false.B))

}
