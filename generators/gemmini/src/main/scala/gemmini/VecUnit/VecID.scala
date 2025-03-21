package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters
import gemmini.GemminiISA._
import gemmini.{GemminiArrayConfig, Arithmetic, GemminiCmd}

class VecIDReq[T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V], heads: Int = 1)
                                     (implicit p: Parameters) extends Bundle {
  import config._
  val valid = Vec(heads, Bool())
  val cmd   = Vec(heads, new GemminiCmd(reservation_station_entries))
}

class VecID[T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V], heads: Int = 1)
                                   (implicit p: Parameters, ev: Arithmetic[T]) extends Module {
  import config._
  import ev._
  val io = IO(new Bundle {
		val id_i = Input(new VecIDReq(config, heads))
		val id_iss_o = Decoupled(new IdIssReq())
		val id_lsu_o = Decoupled(new IdLsuReq())
  })

  // val is_valid = io.id_i.valid.reduce(_ || _)
  val functs = io.id_i.cmd.map(_.cmd.inst.funct)
  val rs1s = VecInit(io.id_i.cmd.map(_.cmd.rs1))
  val rs2s = VecInit(io.id_i.cmd.map(_.cmd.rs2))   

// -----------------------------------------------------------------------------
// Decode instructions
// -----------------------------------------------------------------------------
  val func7    = functs(0)
  val rs1      = rs1s(0)
  val rs2      = rs2s(0)
  //  List(op1, op2, 
  //       op1_from_mem, op2_from_mem, op1_addr, op2_addr, 
  //       Config(wr_op1, wr_op2, 
  //       op1_is_scalar, op2_is_scalar, 
  //       is_mul, is_add,
  //       is_int32, is_int16,
  //       tc_en, reduce_en, op_en, rd_acc, wr_acc)
  //       v1_idx, v2_idx, vd_idx, vd_wen, 
  //       tensor_core_type, iteration)
  val default_decode_list = List(VecInit(Seq.fill(16)(0.U(8.W))), VecInit(Seq.fill(16)(0.U(8.W))), // ----- op1, op2
                         false.B, false.B, 0.U(14.W), 0.U(14.W), // ----- op1_from_mem, op2_from_mem, op1_addr, op2_addr
                         "b0000000000000000".U(13.W), // Config: wr_op1, wr_op2, op1_is_scalar, op2_is_scalar, 
                                                      // is_mul, is_add, is_int32, is_int16, tc_en, reduce_en, 
                                                      // op_en, rd_acc, wr_acc
                         0.U(5.W), 0.U(5.W), 0.U(5.W), false.B, // ----- v1_idx, v2_idx, vd_idx, vd_wen, 
                         0.U(2.W), 0.U(4.W))          // ----- tensor_core_type, iteration
  val decode_list  = ListLookup(func7, default_decode_list, Array(
  // INST_Vec_Load       -> List(), 
  // INST_Vec_Store      -> List(),
  // INST_Vec_Broadcast  -> List(),
  // INST_Scalar_Dispatch-> List(),

		// INST_Vec_Reduce_CMD
		BitPat("b0011110") -> List(VecInit(Seq.fill(16)(0.U(8.W))), VecInit(Seq.fill(16)(0.U(8.W))), true.B,  true.B,  rs1, rs1, "b000110100010100".U(13.W), rs2, rs2, rs2, true.B, 0.U, 0.U),
		// INST_Vec_LoopMul_CMD
		BitPat("b0011111") -> List(VecInit(Seq.fill(16)(0.U(8.W))), VecInit(Seq.fill(16)(0.U(8.W))), false.B, false.B, 0.U,      0.U,            "b000110100010100".U(13.W), rs2, rs2, rs2, true.B, 0.U, 0.U),
  ))

// -----------------------------------------------------------------------------
// id<>iss
// -----------------------------------------------------------------------------
  io.id_iss_o.valid              := io.id_i.valid(0)
  io.id_iss_o.bits.op1           := decode_list(0)
  io.id_iss_o.bits.op2           := decode_list(1)
  io.id_iss_o.bits.op1_from_mem  := decode_list(2)
  io.id_iss_o.bits.op2_from_mem  := decode_list(3)
  io.id_iss_o.bits.config        := decode_list(4)
  io.id_iss_o.bits.thread_id     := decode_list(6)
  io.id_iss_o.bits.iteration     := decode_list(11)

// -----------------------------------------------------------------------------
// id<>mem
// -----------------------------------------------------------------------------
  when (decode_list(2) === true.B || decode_list(3) === true.B) {
		io.id_lsu_o.valid             := true.B
		io.id_lsu_o.bits.op1_from_mem := decode_list(2)
		io.id_lsu_o.bits.op2_from_mem := decode_list(3)
		io.id_lsu_o.bits.op1_addr     := decode_list(4)
		io.id_lsu_o.bits.op2_addr     := decode_list(5)
		io.id_lsu_o.bits.is_acc       := decode_list(6).asUInt()(1)
  }.otherwise {
		io.id_lsu_o.valid             := false.B
		io.id_lsu_o.bits.op1_from_mem := false.B
		io.id_lsu_o.bits.op2_from_mem := false.B
		io.id_lsu_o.bits.op1_addr     := 0.U(14.W)
		io.id_lsu_o.bits.op2_addr     := 0.U(14.W)
		io.id_lsu_o.bits.is_acc       := false.B
  }
}