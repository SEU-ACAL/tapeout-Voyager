package dialect.vector
import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters

import dialect.vector._
import buckyball.frontend.rs.{ReservationStationIssue, ReservationStationComplete, BuckyBallCmd}
import buckyball.mem.{SramReadIO, SramWriteIO}
import buckyball.BuckyBallConfig
import org.yaml.snakeyaml.events.Event.ID

class VecUnit(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
    val rob_id_width = log2Up(bbconfig.rob_entries)
    val spad_w = bbconfig.veclane * bbconfig.inputType.getWidth
  
    val io = IO(new Bundle {
        val cmdReq = Flipped(Decoupled(new ReservationStationIssue(new BuckyBallCmd, rob_id_width)))
        val cmdResp = Decoupled(new ReservationStationComplete(rob_id_width))
        
        // 连接到Scratchpad的SRAM读写接口
        val sramRead = Vec(bbconfig.sp_banks, new SramReadIO(bbconfig.sp_bank_entries, spad_w))
        val sramWrite = Vec(bbconfig.sp_banks, new SramWriteIO(bbconfig.sp_bank_entries, spad_w, spad_w/8))
  })
// -----------------------------------------------------------------------------
// VECID
// -----------------------------------------------------------------------------
    val VecID = Module(new VecID)
    VecID.io.cmdReq <> io.cmdReq
    io.cmdResp <> VecID.io.cmdResp
// -----------------------------------------------------------------------------
// ID_LU
// -----------------------------------------------------------------------------
    val ID_LU = Module(new ID_LU)
    ID_LU.io.id_lu_i <> VecID.io.id_lu_o

// -----------------------------------------------------------------------------
// VECLOADUNIT
// ----------------------------------------------------------------------------- 
    val VecLoadUnit = Module(new VecLoadUnit)
    VecLoadUnit.io.id_lu_i <> ID_LU.io.ld_lu_o
    for (i <- 0 until bbconfig.sp_banks) {
        io.sramRead(i).req <> VecLoadUnit.io.sramReadReq(i)
    }
// -----------------------------------------------------------------------------
// LU_EX
// -----------------------------------------------------------------------------    
    val LU_EX = Module(new LU_EX)
    LU_EX.io.lu_ex_i <> VecLoadUnit.io.lu_ex_o
// -----------------------------------------------------------------------------
// VECEX
// -----------------------------------------------------------------------------    
    val VecEX = Module(new VecEX)
    VecEX.io.lu_ex_i <> LU_EX.io.lu_ex_o
    for (i <- 0 until bbconfig.sp_banks) {
        VecEX.io.sramReadResp(i) <> io.sramRead(i).resp
        io.sramWrite(i) <> VecEX.io.sramWrite(i)
    }
}