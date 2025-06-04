package buckyball.frontend

import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters
import buckyball.BuckyBallConfig
import freechips.rocketchip.buckyball.RoCCCommandBB
import buckyball.BBISA._


class BuckyBallRawCmd(implicit p: Parameters) extends Bundle {
  val cmd = new RoCCCommandBB
}

// default values
object DefaultConstants {
  val Y = true.B
  val N = false.B

  val DOP      = VecInit(Seq.fill(16)(0.U(8.W)))
  val DADDR    = 0.U(14.W)
  val DVECIDX  = 0.U(5.W)
  val DITER    = 0.U(10.W)
  val DTC_TYPE = 0.U(2.W)
  val ZERO_VEC = VecInit(Seq.fill(16)(0.U(8.W)))
}

object LSDecodeFields extends Enumeration {
  type Field = Value
  val PID, PSTART, PEND, // PID大于1表示是流水线指令 
      LD_EN, ST_EN, MEMADDR, SPADDR, ITER = Value
}

// index of the decoded fields
object EXDecodeFields extends Enumeration {
  type Field = Value
  val PID, PSTART, PEND, // PID大于1表示是流水线指令 
      OP1_EN, OP2_EN, WR_SPAD, OP1_FROM_SPAD, OP2_FROM_SPAD, OP1_SPADDR, OP2_SPADDR, WR_SPADDR,
      ITER = Value
}

class PostDecodeCmd extends Bundle {
  val is_load       = Bool()
  val is_store      = Bool()
  val mem_addr      = UInt(14.W)
  val sp_addr       = UInt(14.W)

  val is_ex         = Bool()
  val iter          = UInt(10.W) // 迭代次数
  val op1_en        = Bool()
  val op2_en        = Bool()
  val wr_spad_en    = Bool()
  val op1_from_spad = Bool()
  val op2_from_spad = Bool()
  val op1_spaddr    = UInt(14.W)
  val op2_spaddr    = UInt(14.W)
  val wr_spaddr     = UInt(14.W)

  val pid           = UInt(8.W)   // 流水线ID
  val pstart        = Bool() // 流水线的开始
  val pend          = Bool() // 流水线的结束
}

class Decoder(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
  import DefaultConstants._

  val io = IO(new Bundle {
    val id_i = Flipped(Decoupled(new Bundle {
      val cmd = new RoCCCommandBB
    }))
    val id_rs = Decoupled(new PostDecodeCmd)
  })

  val addrLen = bbconfig.addr_length

  io.id_i.ready := io.id_rs.ready // 如果保留站阻塞了，id_i也阻塞

  val func7 = io.id_i.bits.cmd.inst.funct
  val rs1   = io.id_i.bits.cmd.rs1
  val rs2   = io.id_i.bits.cmd.rs2

// -----------------------------------------------------------------------------
// Decode Load/Store instructions
// -----------------------------------------------------------------------------
  import LSDecodeFields._
  val ls_default_decode = List(N,N,N,N,DADDR,DADDR,DITER)
  val ls_decode_list = ListLookup(func7, ls_default_decode, Array(
    MVOUT_BITPAT -> List(N,Y,N,N,rs1,rs2(addrLen-1,0),rs2(2*addrLen+9,addrLen)), // mvout
    MVIN_BITPAT  -> List(Y,N,N,N,rs1,rs2(addrLen-1,0),rs2(2*addrLen+9,addrLen)), // mvin
  ))

// -----------------------------------------------------------------------------
// Decode EX instructions
// -----------------------------------------------------------------------------
  import EXDecodeFields._
  val ex_default_decode = List(N,N,N,N,N,N,N,N,DADDR,DADDR,DADDR,DITER)
  val ex_decode_list = ListLookup(func7, ex_default_decode, Array(
    MATMUL_WARP16_BITPAT -> List(N,N,N,Y,Y,Y,N,N,rs1(2*addrLen-1,addrLen),rs1(2*addrLen+9,addrLen),rs2(addrLen-1,0),rs1(2*addrLen+9,addrLen)), // bb_matmul_warp16
  ))

  io.id_rs.valid              := io.id_i.valid
  io.id_rs.bits.is_load       := ls_decode_list(0).asBool
  io.id_rs.bits.is_store      := ls_decode_list(1).asBool
  io.id_rs.bits.mem_addr      := ls_decode_list(2).asUInt
  io.id_rs.bits.sp_addr       := ls_decode_list(3).asUInt

  io.id_rs.bits.is_ex         := !ls_decode_list(0).asBool && !ls_decode_list(1).asBool
  io.id_rs.bits.op1_en        := ex_decode_list(3).asBool
  io.id_rs.bits.op2_en        := ex_decode_list(4).asBool
  io.id_rs.bits.wr_spad_en    := ex_decode_list(5).asBool
  io.id_rs.bits.op1_from_spad := ex_decode_list(6).asBool
  io.id_rs.bits.op2_from_spad := ex_decode_list(7).asBool
  io.id_rs.bits.op1_spaddr    := ex_decode_list(8).asUInt
  io.id_rs.bits.op2_spaddr    := ex_decode_list(9).asUInt
  io.id_rs.bits.wr_spaddr     := ex_decode_list(10).asUInt
  io.id_rs.bits.iter          := ex_decode_list(11).asUInt

  io.id_rs.bits.pid           := ex_decode_list(0).asUInt | ls_decode_list(0).asUInt
  io.id_rs.bits.pstart        := ex_decode_list(1).asBool || ls_decode_list(1).asBool 
  io.id_rs.bits.pend          := ex_decode_list(2).asBool || ls_decode_list(2).asBool 
}


