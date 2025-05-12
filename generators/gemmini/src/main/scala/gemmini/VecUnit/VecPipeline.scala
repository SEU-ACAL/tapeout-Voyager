package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._

import function._  


object function {
  def bool_dff(handshake: Bool, bool_default: Bool, data_i: Bool): Bool = {
    val data_o = RegInit(bool_default)
    data_o := Mux(handshake, data_i, data_o)
    data_o
  }
  def uint_dff(handshake: Bool, data_default: UInt, data_i: UInt): UInt = {
    val data_o = RegInit(data_default)
    data_o := Mux(handshake, data_i, data_o)
    data_o
  }
  def uvec_dff(handshake: Bool, data_default: Vec[UInt], data_i: Vec[UInt]): Vec[UInt] = {
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
  val config = UInt(16.W)
  val iteration = UInt(4.W) // 从0开始，循环1~16次
  val thread_id = UInt(4.W)
  val rob_id = UInt(5.W)
  val funct = UInt(8.W)
  val waddr = UInt(14.W)
}

class id_iss extends Module {  
  val io = IO(new Bundle {
  val id_iss_i = Flipped(Decoupled(new IdIssReq()))
  val id_iss_o = Decoupled(new IdIssReq())
  })
  
  val id_iss_hs = io.id_iss_i.fire

  io.id_iss_o.valid := bool_dff(true.B, false.B, io.id_iss_i.valid)
  io.id_iss_i.ready := bool_dff(true.B, false.B, io.id_iss_o.ready)

  io.id_iss_o.bits.op1_from_mem := bool_dff(id_iss_hs,                         false.B, io.id_iss_i.bits.op1_from_mem)
  io.id_iss_o.bits.op2_from_mem := bool_dff(id_iss_hs,                         false.B, io.id_iss_i.bits.op2_from_mem)
  io.id_iss_o.bits.config       := uint_dff(id_iss_hs,                       0.U(16.W), io.id_iss_i.bits.config)
  io.id_iss_o.bits.iteration    := uint_dff(id_iss_hs,                        0.U(4.W), io.id_iss_i.bits.iteration)
  io.id_iss_o.bits.thread_id    := uint_dff(id_iss_hs,                        0.U(4.W), io.id_iss_i.bits.thread_id)
  io.id_iss_o.bits.op1          := uvec_dff(id_iss_hs, VecInit(Seq.fill(16)(0.U(8.W))), io.id_iss_i.bits.op1)
  io.id_iss_o.bits.op2          := uvec_dff(id_iss_hs, VecInit(Seq.fill(16)(0.U(8.W))), io.id_iss_i.bits.op2)
  io.id_iss_o.bits.rob_id       := uint_dff(id_iss_hs,                        0.U(5.W), io.id_iss_i.bits.rob_id)
  io.id_iss_o.bits.funct        := uint_dff(id_iss_hs,                        0.U(8.W), io.id_iss_i.bits.funct)
  io.id_iss_o.bits.waddr       := uint_dff(id_iss_hs,                       0.U(14.W), io.id_iss_i.bits.waddr)
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

class IdLsuResp extends Bundle {
  val rd_complete = Bool()
}

// 注意: 为了实现brust的及时喂addr, 这个版本id<>lsu是组合逻辑
class id_lsu extends Module {
  val io = IO(new Bundle {
    val id_lsu_i = Flipped(Decoupled(new IdLsuReq()))
    val id_lsu_o = Decoupled(new IdLsuReq())
  })
  
  io.id_lsu_o <> io.id_lsu_i
  // val id_lsu_hs = io.id_lsu_i.valid & io.id_lsu_o.ready

  // io.id_lsu_o.valid := bool_dff(true.B, false.B, io.id_lsu_i.valid)
  // io.id_lsu_i.ready := bool_dff(true.B, false.B, io.id_lsu_o.ready)

  // io.id_lsu_o.bits.op1_from_mem := bool_dff(id_lsu_hs,   false.B, io.id_lsu_i.bits.op1_from_mem)
  // io.id_lsu_o.bits.op2_from_mem := bool_dff(id_lsu_hs,   false.B, io.id_lsu_i.bits.op2_from_mem)
  // io.id_lsu_o.bits.op1_addr     := uint_dff(id_lsu_hs, 0.U(14.W), io.id_lsu_i.bits.op1_addr)
  // io.id_lsu_o.bits.op2_addr     := uint_dff(id_lsu_hs, 0.U(14.W), io.id_lsu_i.bits.op2_addr)
  // io.id_lsu_o.bits.is_acc       := bool_dff(id_lsu_hs,   false.B, io.id_lsu_i.bits.is_acc)
}

// -----------------------------------------------------------------------------
// iss_ex pipeline
// -----------------------------------------------------------------------------
class IssExReq extends Bundle {
  val op1 = Vec(16, UInt(8.W))
  val op2 = Vec(16, UInt(8.W))
  val config = UInt(16.W)
  val iteration = UInt(4.W) // 从0开始，循环1~16次
  val thread_id = UInt(4.W)
  val rob_id = UInt(5.W)
  val funct = UInt(8.W)
  val waddr = UInt(14.W)
}

class iss_ex extends Module {
  val io = IO(new Bundle {
  val iss_ex_i = Flipped(Decoupled(new IssExReq()))
  val iss_ex_o = Decoupled(new IssExReq())
  })
  
  val iss_ex_hs = io.iss_ex_i.fire

  io.iss_ex_o.valid := bool_dff(true.B, false.B, io.iss_ex_i.valid)
  io.iss_ex_i.ready := bool_dff(true.B, false.B, io.iss_ex_o.ready)

  io.iss_ex_o.bits.op1       := uvec_dff(iss_ex_hs, VecInit(Seq.fill(16)(0.U(8.W))), io.iss_ex_i.bits.op1)
  io.iss_ex_o.bits.op2       := uvec_dff(iss_ex_hs, VecInit(Seq.fill(16)(0.U(8.W))), io.iss_ex_i.bits.op2)
  io.iss_ex_o.bits.config    := uint_dff(iss_ex_hs,                       0.U(16.W), io.iss_ex_i.bits.config)
  io.iss_ex_o.bits.iteration := uint_dff(iss_ex_hs,                        0.U(4.W), io.iss_ex_i.bits.iteration)
  io.iss_ex_o.bits.thread_id := uint_dff(iss_ex_hs,                        0.U(4.W), io.iss_ex_i.bits.thread_id)    
  io.iss_ex_o.bits.rob_id    := uint_dff(iss_ex_hs,                        0.U(5.W), io.iss_ex_i.bits.rob_id)
  io.iss_ex_o.bits.funct     := uint_dff(iss_ex_hs,                        0.U(8.W), io.iss_ex_i.bits.funct)
  io.iss_ex_o.bits.waddr     := uint_dff(iss_ex_hs,                       0.U(14.W), io.iss_ex_i.bits.waddr)
}

// -----------------------------------------------------------------------------
// ex_cmt pipeline
// -----------------------------------------------------------------------------
class ExCmtReq extends Bundle {
  val wb_en   = Bool()
  val wb_data = Vec(16, UInt(8.W))
  val wb_addr = UInt(14.W)
  val is_acc  = Bool()
  val rob_id  = UInt(5.W)
  val funct   = UInt(8.W)
}

class ex_cmt extends Module {  
  val io = IO(new Bundle {
    val ex_cmt_i = Flipped(Decoupled(new ExCmtReq()))
    val ex_cmt_o = Decoupled(new ExCmtReq())
  })
  
  val ex_cmt_hs = io.ex_cmt_i.fire

  io.ex_cmt_o.valid        := bool_dff(true.B, false.B, io.ex_cmt_i.valid)
  io.ex_cmt_i.ready        := bool_dff(true.B, false.B, io.ex_cmt_o.ready)

  io.ex_cmt_o.bits.wb_en   := bool_dff(true.B,                         false.B, io.ex_cmt_i.bits.wb_en)
  io.ex_cmt_o.bits.wb_data := uvec_dff(true.B, VecInit(Seq.fill(16)(0.U(8.W))), io.ex_cmt_i.bits.wb_data)
  io.ex_cmt_o.bits.wb_addr := uint_dff(true.B,                       0.U(14.W), io.ex_cmt_i.bits.wb_addr)
  io.ex_cmt_o.bits.is_acc  := bool_dff(true.B,                         false.B, io.ex_cmt_i.bits.is_acc)
  io.ex_cmt_o.bits.rob_id  := uint_dff(true.B,                        0.U(5.W), io.ex_cmt_i.bits.rob_id)
  io.ex_cmt_o.bits.funct   := uint_dff(true.B,                        0.U(8.W), io.ex_cmt_i.bits.funct)
}
