package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters
import gemmini.GemminiISA._
import gemmini.{GemminiArrayConfig, Arithmetic, GemminiCmd}

// default values
object DefaultConstants {
  val Y = true.B
  val N = false.B

  val DOP      = VecInit(Seq.fill(16)(0.U(8.W)))
  val DADDR    = 0.U(14.W)
  val DVECIDX  = 0.U(5.W)
  val DITER    = 0.U(4.W)
  val DTC_TYPE = 0.U(2.W)
}

// index of the decoded fields
object DecodeFields extends Enumeration {
  type Field = Value
  val OP1, OP2, OP1_from_MEM, OP2_from_MEM, OP1_ADDR, OP2_ADDR, 
      WR_OP1, WR_OP2, OP1_IS_SCALAR, OP2_IS_SCALAR, MUL, ADD, MAX, DIV, LUT,
      INT32, INT16, TC_EN, REDUCE, OP_EN, RD_ACC, WR_ACC,
      V1_IDX, V2_IDX, VD_IDX, VD_WEN, TC_TYPE, ITER = Value
}

class VecIDReq[T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V], heads: Int = 1)
                                     (implicit p: Parameters) extends Bundle {
  import config._
  val valid = Vec(heads, Bool())
  val cmd   = Vec(heads, new GemminiCmd(reservation_station_entries))
}

class VecID[T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V], 
                                             entries: Int, heads: Int, maxpop: Int = 2)
                                   (implicit p: Parameters, ev: Arithmetic[T]) extends Module {
  import config._
  import ev._
  import DefaultConstants._
  import DecodeFields._
  
  val io = IO(new Bundle {
    val id_i = Input(new VecIDReq(config, heads))
    val id_o = new Bundle {
      val pop   = Output(UInt(log2Ceil((entries min maxpop) + 1).W))
      val completed = Valid(UInt(log2Up(reservation_station_entries).W))
    } // to top
    val id_iss_o = Decoupled(new IdIssReq())
    val id_lsu_o = Decoupled(new IdLsuReq())
    val lsu_id_i = Input(new LsuIdResp())
  })

  val functs = io.id_i.cmd.map(_.cmd.inst.funct)
  val rs1s = VecInit(io.id_i.cmd.map(_.cmd.rs1))
  val rs2s = VecInit(io.id_i.cmd.map(_.cmd.rs2))   

// -----------------------------------------------------------------------------
// Decode instructions
// -----------------------------------------------------------------------------
  val func7 = functs(0)
  val rs1   = rs1s(0)
  val rs2   = rs2s(0)
  val rob_id = io.id_i.cmd(0).rob_id.bits

  val default_decode = 
                          //  op1                          wr_op1 wr_op2                             v1_idx                                    
                          //   |  op2                           | | op1_is_scalar                     |  v2_idx                               
                          //   |   | op1_from_mem               | | | op2_is_scalar                   |   |       vd_idx  vd_wen                
                          //   |   |   | op2_from_mem           | | | | mul   div                     |   |         |      | tc_type         
                          //   |   |   | |    op1_addr          | | | | | add | lut                   |   |         |      | |             iteration
                          //   |   |   | |      |       op2_addr| | | | | |max| | int32               |   |         |      | |             |        
                          //   |   |   | |      |         |     | | | | | | | | | | int16             |   |         |      | |             |        
                          //   |   |   | |      |         |     | | | | | | | | | | | tc_en           |   |         |      | |             |        
                          //   |   |   | |      |         |     | | | | | | | | | | | | redece        |   |         |      | |             |        
                          //   |   |   | |      |         |     | | | | | | | | | | | | | op_en       |   |         |      | |             |        
                          //   |   |   | |      |         |     | | | | | | | | | | | | | | rd_acc    |   |         |      | |             |        
                          //   |   |   | |      |         |     | | | | | | | | | | | | | | | wr_acc  |   |         |      | |             |        
                          //   |   |   | |      |         |     | | | | | | | | | | | | | | | |       |   |         |      | |             |        
                          List(DOP,DOP,N,N,    DADDR,     DADDR,N,N,N,N,N,N,N,N,N,N,N,N,N,N,N,N, DVECIDX,DVECIDX,  DVECIDX,N,DTC_TYPE     ,DITER)
  val decode_list = ListLookup(func7, default_decode, Array(
    BitPat("b0011101") -> List(DOP,DOP,N,N,    DADDR,     DADDR,Y,Y,N,N,N,N,N,N,N,N,N,N,N,N,N,N, DVECIDX,DVECIDX,  DVECIDX,N,DTC_TYPE,     DITER), // INST_Vec_Reduce_CMD
    BitPat("b0011111") -> List(DOP,DOP,Y,Y,rs1(16,2),rs1(30,16),Y,Y,N,N,Y,N,N,N,N,N,N,N,N,N,N,N,rs2(5,0),DVECIDX,rs2(10,5),N,DTC_TYPE,rs2(14,10)), // INST_Vec_LoopMul_CMD
  ))

// -----------------------------------------------------------------------------
// id<>iss
// -----------------------------------------------------------------------------
  io.id_iss_o.valid              := io.id_i.valid(0)
  io.id_iss_o.bits.rob_id        := rob_id
  io.id_iss_o.bits.op1           := decode_list(OP1.id)
  io.id_iss_o.bits.op2           := decode_list(OP2.id)
  io.id_iss_o.bits.op1_from_mem  := decode_list(OP1_from_MEM.id)
  io.id_iss_o.bits.op2_from_mem  := decode_list(OP2_from_MEM.id)
  io.id_iss_o.bits.config        :=
    (WR_OP1.id to WR_ACC.id).foldLeft(0.U)((acc, id) => Cat(decode_list(id).asUInt, acc))(13, 1)
  io.id_iss_o.bits.thread_id     := decode_list(V1_IDX.id)
  io.id_iss_o.bits.iteration     := decode_list(ITER.id)

// -----------------------------------------------------------------------------
// id<>mem
// -----------------------------------------------------------------------------
  val need_mem_access = 
    decode_list(OP1_from_MEM.id).asInstanceOf[Bool] || decode_list(OP2_from_MEM.id).asInstanceOf[Bool]
  
  // id->lsu 发送 load op 的请求
  io.id_lsu_o.valid             := need_mem_access && io.id_i.valid(0) 
  io.id_lsu_o.bits.op1_from_mem := Mux(need_mem_access, decode_list(OP1_from_MEM.id), false.B)
  io.id_lsu_o.bits.op2_from_mem := Mux(need_mem_access, decode_list(OP2_from_MEM.id), false.B)
  io.id_lsu_o.bits.op1_addr     := Mux(need_mem_access, decode_list(OP1_ADDR.id), 0.U(14.W))
  io.id_lsu_o.bits.op2_addr     := Mux(need_mem_access, decode_list(OP2_ADDR.id), 0.U(14.W))
  io.id_lsu_o.bits.is_acc       := Mux(need_mem_access, decode_list(WR_ACC.id), false.B)

  // lsu->id 接收 load op 完成的响应
  val lsu_rd_complete = io.lsu_id_i.rd_complete

// -----------------------------------------------------------------------------
// id<>top
// -----------------------------------------------------------------------------
  // 当 load op 完成时，pop 一条指令
  io.id_o.pop                    := Mux(lsu_rd_complete, 0.U.bitSet(0.U, true.B), 0.U)
  io.id_o.completed.bits         := Mux(lsu_rd_complete, rob_id, 0.U)
  io.id_o.completed.valid        := lsu_rd_complete
}


