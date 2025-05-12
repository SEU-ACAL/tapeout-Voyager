package gemmini.VecUnit

import chisel3._
import chisel3.util._
import gemmini.GemminiISA._
import gemmini.Util._
import org.chipsalliance.cde.config.Parameters
import midas.targetutils.PerfCounter
import gemmini.{GemminiArrayConfig, Arithmetic, ScratchpadReadIO, ScratchpadWriteIO, GemminiCmd}
import gemmini.{AccumulatorReadReq, AccumulatorWriteReq, AccumulatorScaleResp}

object VecConfig {
  val alu_thread_num = 8  // thread 数量
  val lut_thread_num = 8
  val spad_addr_w    = 14 // spad 地址宽度
  
}

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
    val sram0 = new Bundle {
      val read = new ScratchpadReadIO(sp_bank_entries, sp_width)
      val write = new ScratchpadWriteIO(sp_bank_entries, sp_width, (sp_width / (aligned_to * 8)) max 1)
    }
    val sram1 = new Bundle {
      val read = new ScratchpadReadIO(sp_bank_entries, sp_width)
    }
    val acc = new Bundle {
      val read_req = Vec(acc_banks, Decoupled(new AccumulatorReadReq(
          acc_bank_entries, accType, acc_scale_t
      )))

      val read_resp = Flipped(Vec(acc_banks, Decoupled(new AccumulatorScaleResp(
        Vec(meshColumns, Vec(tileColumns, inputType)),
        Vec(meshColumns, Vec(tileColumns, accType))
      ))))

      val write = Vec(acc_banks, Decoupled(new AccumulatorWriteReq(acc_bank_entries, Vec(meshColumns, Vec(tileColumns, accType)))))
    }
    val completed = Valid(UInt(log2Up(reservation_station_entries).W))
  })

  val VecID  = Module(new VecID(config, entries, heads, maxpop))
  val VecISS = Module(new VecISS())
  val VecEX  = Module(new VecEX(config))
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
  //io.cmd.pop := VecID.io.id_o.pop
  //io.completed := VecID.io.id_o.completed

// -----------------------------------------------------------------------------
// 读写SRAM
// -----------------------------------------------------------------------------
  io.sram0.read <> VecLSU.io.lsu_sram0_read
  io.sram0.write <> VecLSU.io.lsu_sram0_write

  io.sram1.read <> VecLSU.io.lsu_sram1_read

  io.cmd.pop := VecID.io.id_o.pop
  io.completed := VecID.io.id_o.completed

//---------------------------------------------------------------------------
// 读写ACC
//---------------------------------------------------------------------------

  for (i <- 0 until acc_banks) {
    io.acc.read_req(i) <> VecEX.io.acc.read_req(i)
    io.acc.read_resp(i) <> VecEX.io.acc.read_resp(i)
    io.acc.write(i) <> VecEX.io.acc.write(i)
  }


}
