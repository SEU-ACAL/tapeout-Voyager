package gemmini.VecUnit

import chisel3._
import chisel3.util._
import gemmini.GemminiISA._
import gemmini.Util._
import org.chipsalliance.cde.config.Parameters
import midas.targetutils.PerfCounter
import freechips.rocketchip.npu.CSR.S
import gemmini.{GemminiArrayConfig, Arithmetic, ScratchpadReadIO, ScratchpadWriteIO, GemminiCmd}

class VecUnit[T <: Data, U <: Data, V <: Data](xLen: Int, tagWidth: Int, config: GemminiArrayConfig[T, U, V], 
                                     entries: Int, heads: Int, maxpop: Int = 2)
                                    (implicit p: Parameters, ev: Arithmetic[T]) extends Module {
  import config._
  import ev._
  val io = IO(new Bundle {
    val cmd = new Bundle {
      val valid = Input(Vec(heads, Bool()))
      val bits = Input(Vec(heads, new GemminiCmd(reservation_station_entries)))
      val pop = Output(UInt(log2Ceil((entries min maxpop) + 1).W))
    }
    val srams = new Bundle {
      val read = new ScratchpadReadIO(sp_bank_entries, sp_width)
      val write = new ScratchpadWriteIO(sp_bank_entries, sp_width, (sp_width / (aligned_to * 8)) max 1)
    }
    val completed = Valid(UInt(log2Up(reservation_station_entries).W))
  })

  val VecID  = Module(new VecID(config, entries, heads, maxpop))
  val VecISS = Module(new VecISS())
  val VecEX  = Module(new VecEX())
  val VecCMT = Module(new VecCMT(config))
  val VecLSU = Module(new VecLSU(config))

  val IDISS = Module(new id_iss())
  val IDLSU = Module(new id_lsu())
  // val LSUID = Module(new lsu_id())
  val ISSEX = Module(new iss_ex())
  val EXCMT = Module(new ex_cmt())

// -----------------------------------------------------------------------------
// VecUnit 总输入
// -----------------------------------------------------------------------------
  // val vecIDReq = Wire(new VecIDReq(config, heads))
  // vecIDReq.cmd := io.cmd.bits
  // VecID.io.id_i.bits := vecIDReq
  // for (i <- 0 until heads) {
  //     VecID.io.id_i.valid(i) := io.cmd.valid(i)
  // }
  for (i <- 0 until heads) { VecID.io.id_i.valid(i) := io.cmd.valid(i)}
  VecID.io.id_i.cmd := io.cmd.bits

// -----------------------------------------------------------------------------
// pipeline 传递
// -----------------------------------------------------------------------------
  IDLSU.io.id_lsu_i <> VecID.io.id_lsu_o
  VecLSU.io.id_lsu_i <> IDLSU.io.id_lsu_o

  VecID.io.lsu_id_i <> VecLSU.io.lsu_id_o // 无中间寄存器
  VecISS.io.lsu_iss_i <> VecLSU.io.lsu_iss_o // 无中间寄存器

  IDISS.io.id_iss_i <> VecID.io.id_iss_o
  VecISS.io.id_iss_i <> IDISS.io.id_iss_o
  
  ISSEX.io.iss_ex_i <> VecISS.io.iss_ex_o
  VecEX.io.iss_ex_i <> ISSEX.io.iss_ex_o

  EXCMT.io.ex_cmt_i <> VecEX.io.ex_cmt_o
  VecCMT.io.ex_cmt_i <> EXCMT.io.ex_cmt_o

  VecLSU.io.cmt_lsu_i <> VecCMT.io.cmt_lsu_o
// -----------------------------------------------------------------------------
// VecUnit 总输出
// -----------------------------------------------------------------------------
  io.cmd.pop := VecID.io.id_o.pop
  io.completed.valid := VecCMT.io.cmt_o.completed.valid
  io.completed.bits := VecCMT.io.cmt_o.completed.bits

  // val completed_reg = dontTouch(RegInit(0.U(log2Up(reservation_station_entries).W)))
  // completed_reg := io.completed.bits
  
// -----------------------------------------------------------------------------
// 读写SRAM
// -----------------------------------------------------------------------------
  io.srams.read <> VecLSU.io.lsu_sram_read
  io.srams.write <> VecLSU.io.lsu_sram_write
}
