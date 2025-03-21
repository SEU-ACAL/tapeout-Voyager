package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._

import function._  


object function {
  def hs_bool_dff(handshake: Bool, bool_default: Bool, data_i: Bool): Bool = {
    val data_o = RegInit(bool_default)
    data_o := Mux(handshake, data_i, data_o)
    data_o
  }
  def hs_uint_dff(handshake: Bool, data_default: UInt, data_i: UInt): UInt = {
    val data_o = RegInit(data_default)
    data_o := Mux(handshake, data_i, data_o)
    data_o
  }
  def hs_uvec_dff(handshake: Bool, data_default: Vec[UInt], data_i: Vec[UInt]): Vec[UInt] = {
    val data_o = RegInit(data_default)
    data_o := Mux(handshake, data_i, data_o)
    data_o
  }
}

// -----------------------------------------------------------------------------
// id_iss pipeline
// -----------------------------------------------------------------------------
class IdIssReq extends Bundle {
  val op1 = Vec(16, UInt(8.W))
  val op2 = Vec(16, UInt(8.W))
  val op1_from_mem = Bool()
  val op2_from_mem = Bool()
  val config = UInt(12.W)
  val iteration = UInt(4.W) // 从0开始，循环1~16次
  val thread_id = UInt(3.W)
}

class id_iss extends Module {  
  val io = IO(new Bundle {
  val id_iss_i = Flipped(Decoupled(new IdIssReq()))
  val id_iss_o = Decoupled(new IdIssReq())
  })
  
  io.id_iss_o.valid := io.id_iss_i.valid  
  io.id_iss_i.ready := io.id_iss_o.ready   

  val id_iss_hs = io.id_iss_o.valid & io.id_iss_i.ready

  io.id_iss_o.bits.op1_from_mem := hs_bool_dff(id_iss_hs,                         false.B, io.id_iss_i.bits.op1_from_mem)
  io.id_iss_o.bits.op2_from_mem := hs_bool_dff(id_iss_hs,                         false.B, io.id_iss_i.bits.op2_from_mem)
  io.id_iss_o.bits.config       := hs_uint_dff(id_iss_hs,                       0.U(12.W), io.id_iss_i.bits.config)
  io.id_iss_o.bits.iteration    := hs_uint_dff(id_iss_hs,                        0.U(4.W), io.id_iss_i.bits.iteration)
  io.id_iss_o.bits.thread_id    := hs_uint_dff(id_iss_hs,                        0.U(3.W), io.id_iss_i.bits.thread_id)
  io.id_iss_o.bits.op1          := hs_uvec_dff(id_iss_hs, VecInit(Seq.fill(16)(0.U(8.W))), io.id_iss_i.bits.op1)
  io.id_iss_o.bits.op2          := hs_uvec_dff(id_iss_hs, VecInit(Seq.fill(16)(0.U(8.W))), io.id_iss_i.bits.op2)
}   

// -----------------------------------------------------------------------------
// id_lsu pipeline
// -----------------------------------------------------------------------------
class IdLsuReq extends Bundle {
  val op1_from_mem = Bool()
  val op2_from_mem = Bool()
  val op1_addr = UInt(14.W)
  val op2_addr = UInt(14.W)
  val is_acc   = Bool()
}

class id_lsu extends Module {
  val io = IO(new Bundle {
  val id_lsu_i = Flipped(Decoupled(new IdLsuReq()))
  val id_lsu_o = Decoupled(new IdLsuReq())
  })
  
  io.id_lsu_o.valid := io.id_lsu_i.valid  
  io.id_lsu_i.ready := io.id_lsu_o.ready   

  val id_lsu_hs = io.id_lsu_o.valid & io.id_lsu_i.ready

  io.id_lsu_o.bits.op1_from_mem := hs_bool_dff(id_lsu_hs,   false.B, io.id_lsu_i.bits.op1_from_mem)
  io.id_lsu_o.bits.op2_from_mem := hs_bool_dff(id_lsu_hs,   false.B, io.id_lsu_i.bits.op2_from_mem)
  io.id_lsu_o.bits.op1_addr     := hs_uint_dff(id_lsu_hs, 0.U(14.W), io.id_lsu_i.bits.op1_addr)
  io.id_lsu_o.bits.op2_addr     := hs_uint_dff(id_lsu_hs, 0.U(14.W), io.id_lsu_i.bits.op2_addr)
  io.id_lsu_o.bits.is_acc       := hs_bool_dff(id_lsu_hs,   false.B, io.id_lsu_i.bits.is_acc)
}

// -----------------------------------------------------------------------------
// iss_ex pipeline
// -----------------------------------------------------------------------------
class IssExReq extends Bundle {
  val op1 = Vec(16, UInt(8.W))
  val op2 = Vec(16, UInt(8.W))
  val config = UInt(12.W)
  val iteration = UInt(4.W) // 从0开始，循环1~16次
  val thread_id = UInt(3.W)
}

class iss_ex extends Module {
  val io = IO(new Bundle {
  val iss_ex_i = Flipped(Decoupled(new IssExReq()))
  val iss_ex_o = Decoupled(new IssExReq())
  })
  
  io.iss_ex_o.valid := io.iss_ex_i.valid 
  io.iss_ex_i.ready := io.iss_ex_o.ready 

  val iss_ex_hs = io.iss_ex_o.valid & io.iss_ex_i.ready

  io.iss_ex_o.bits.op1       := hs_uvec_dff(iss_ex_hs, VecInit(Seq.fill(16)(0.U(8.W))), io.iss_ex_i.bits.op1)
  io.iss_ex_o.bits.op2       := hs_uvec_dff(iss_ex_hs, VecInit(Seq.fill(16)(0.U(8.W))), io.iss_ex_i.bits.op2)
  io.iss_ex_o.bits.config    := hs_uint_dff(iss_ex_hs,                       0.U(12.W), io.iss_ex_i.bits.config)
  io.iss_ex_o.bits.iteration := hs_uint_dff(iss_ex_hs,                        0.U(4.W), io.iss_ex_i.bits.iteration)
  io.iss_ex_o.bits.thread_id := hs_uint_dff(iss_ex_hs,                        0.U(3.W), io.iss_ex_i.bits.thread_id)    
}

// -----------------------------------------------------------------------------
// ex_cmt pipeline
// -----------------------------------------------------------------------------
class ExCmtReq extends Bundle {
  val wb_en   = Bool()
  val wb_data = Vec(16, UInt(8.W))
  val wb_addr = UInt(14.W)
  val is_acc  = Bool()
}

class ex_cmt extends Module {  
  val io = IO(new Bundle {
  val ex_cmt_i = Flipped(Decoupled(new ExCmtReq()))
  val ex_cmt_o = Decoupled(new ExCmtReq())
  })
  
  io.ex_cmt_o.valid := io.ex_cmt_i.valid 
  io.ex_cmt_i.ready := io.ex_cmt_o.ready 

  val ex_cmt_hs = io.ex_cmt_o.valid & io.ex_cmt_i.ready

  io.ex_cmt_o.bits.wb_en   := hs_bool_dff(ex_cmt_hs,                         false.B, io.ex_cmt_i.bits.wb_en)
  io.ex_cmt_o.bits.wb_data := hs_uvec_dff(ex_cmt_hs, VecInit(Seq.fill(16)(0.U(8.W))), io.ex_cmt_i.bits.wb_data)
  io.ex_cmt_o.bits.wb_addr := hs_uint_dff(ex_cmt_hs,                       0.U(14.W), io.ex_cmt_i.bits.wb_addr)
  io.ex_cmt_o.bits.is_acc  := hs_bool_dff(ex_cmt_hs,                         false.B, io.ex_cmt_i.bits.is_acc)
}
