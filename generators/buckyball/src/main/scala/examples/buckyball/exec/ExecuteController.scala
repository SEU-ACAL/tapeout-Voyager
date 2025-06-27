package buckyball.exec

import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters

import dialect.vector._
import buckyball.frontend.rs.{ReservationStationIssue, ReservationStationComplete, BuckyBallCmd}
import buckyball.mem.{SramReadIO, SramWriteIO}
import buckyball.BuckyBallConfig

class ExecuteController(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
  val rob_id_width = log2Up(bbconfig.rob_entries)
  val spad_w = bbconfig.veclane * bbconfig.inputType.getWidth
  
  val io = IO(new Bundle {
    val cmdReq = Flipped(Decoupled(new ReservationStationIssue(new BuckyBallCmd, rob_id_width)))
    val cmdResp = Decoupled(new ReservationStationComplete(rob_id_width))
    
    // 连接到Scratchpad的SRAM读写接口
    val sramRead = Vec(bbconfig.sp_banks, new SramReadIO(bbconfig.sp_bank_entries, spad_w))
    val sramWrite = Vec(bbconfig.sp_banks, new SramWriteIO(bbconfig.sp_bank_entries, spad_w, spad_w/8))
  })
  val VecUnit = Module(new VecUnit)
  VecUnit.io.cmdReq <> io.cmdReq
  io.cmdResp <> VecUnit.io.cmdResp
  // 连接到Scratchpad的SRAM读写接口
  for (i <- 0 until bbconfig.sp_banks) {
    io.sramRead(i).req <> VecUnit.io.sramRead(i).req
    io.sramRead(i).resp <> VecUnit.io.sramRead(i).resp
    io.sramWrite(i) <> VecUnit.io.sramWrite(i)
  }
}