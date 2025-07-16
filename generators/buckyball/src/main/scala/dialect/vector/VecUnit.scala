package dialect.vector
import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters

import dialect.vector._
import buckyball.frontend.rs.{ReservationStationIssue, ReservationStationComplete, BuckyBallCmd}
import buckyball.mem.{SramReadIO, SramWriteIO, SramReadResp, AccWriteIO}
import buckyball.BuckyBallConfig
import buckyball.util.Pipeline
import org.yaml.snakeyaml.events.Event.ID

class VecUnit(implicit b: BuckyBallConfig, p: Parameters) extends Module {
  val rob_id_width = log2Up(b.rob_entries)
  val spad_w = b.veclane * b.inputType.getWidth
  
  val io = IO(new Bundle {
    val cmdReq = Flipped(Decoupled(new ReservationStationIssue(new BuckyBallCmd, rob_id_width)))
    val cmdResp = Decoupled(new ReservationStationComplete(rob_id_width))
    
    // 连接到Scratchpad的SRAM读写接口
    val sramRead = Vec(b.sp_banks, new SramReadIO(b.sp_bank_entries, spad_w))
    val sramWrite = Vec(b.sp_banks, new SramWriteIO(b.sp_bank_entries, spad_w, spad_w/8))
    // 连接到Accumulator的读写接口
    val accRead = Vec(b.acc_banks, new SramReadIO(b.acc_bank_entries, b.acc_width))
    val accWrite = Vec(b.acc_banks, new AccWriteIO(b.acc_bank_entries, b.acc_width, b.acc_width/8))
  })
// -----------------------------------------------------------------------------
// VECCTRLUNIT
// -----------------------------------------------------------------------------
  val VecCtrlUnit = Module(new VecCtrlUnit)
  VecCtrlUnit.io.cmdReq <> io.cmdReq
  io.cmdResp <> VecCtrlUnit.io.cmdResp_o



// -----------------------------------------------------------------------------
// VECLOADUNIT
// -----------------------------------------------------------------------------
	val VecLoadUnit = Module(new VecLoadUnit)
	VecLoadUnit.io.ctrl_ld_i <> VecCtrlUnit.io.ctrl_ld_o
	for (i <- 0 until b.sp_banks) {
		io.sramRead(i).req <> VecLoadUnit.io.sramReadReq(i)
		VecLoadUnit.io.sramReadResp(i) <> io.sramRead(i).resp
	}

// -----------------------------------------------------------------------------
// VECEX
// -----------------------------------------------------------------------------  
	val VecEX = Module(new VecEXUnit)
	VecEX.io.ctrl_ex_i <> VecCtrlUnit.io.ctrl_ex_o
	VecEX.io.ld_ex_i <> VecLoadUnit.io.ld_ex_o


// -----------------------------------------------------------------------------
// VECSTOREUNIT
// -----------------------------------------------------------------------------
	val VecStoreUnit = Module(new VecStoreUnit)
	VecStoreUnit.io.ctrl_st_i <> VecCtrlUnit.io.ctrl_st_o
  VecStoreUnit.io.ex_st_i <> VecEX.io.ex_st_o
	for (i <- 0 until b.acc_banks) {
		io.accWrite(i) <> VecStoreUnit.io.accWrite(i)
	}
	VecCtrlUnit.io.cmdResp_i <> VecStoreUnit.io.cmdResp_o


// -----------------------------------------------------------------------------
// Set DontCare
// -----------------------------------------------------------------------------
  for (i <- 0 until b.sp_banks) {
    io.sramWrite(i) := DontCare
  }
  for (i <- 0 until b.acc_banks) {
    io.accRead(i) := DontCare
  }
}