package buckyball.exec

import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters
import dialect.bbfp._
import dialect.vector._
import buckyball.frontend.rs.{ReservationStationIssue, ReservationStationComplete, BuckyBallCmd}
import buckyball.mem.{SramReadIO, SramWriteIO, AccWriteIO}
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
    // 连接到Accumulator的读写接口
    val accRead = Vec(bbconfig.acc_banks, new SramReadIO(bbconfig.acc_bank_entries, bbconfig.acc_width))
    val accWrite = Vec(bbconfig.acc_banks, new AccWriteIO(bbconfig.acc_bank_entries, bbconfig.acc_width, bbconfig.acc_width/8))
  })

  val BBFP_Control = Module(new BBFP_Control)
  val VecUnit = Module(new VecUnit)
  val sel = WireInit(false.B)
  val sel_reg = RegInit(false.B)
  val real_sel = WireInit(false.B)
  val real_is_matmul_ws = WireInit(false.B)
  val reg_is_matmul_ws = RegInit(false.B)
  when(io.cmdReq.valid){
    reg_is_matmul_ws := io.cmdReq.bits.cmd.post_decode_cmd.is_matmul_ws
  }
  real_is_matmul_ws := Mux(io.cmdReq.valid, io.cmdReq.bits.cmd.post_decode_cmd.is_matmul_ws, reg_is_matmul_ws)
  when(io.cmdReq.valid){
    sel := (!io.cmdReq.bits.cmd.post_decode_cmd.is_vec) && io.cmdReq.bits.cmd.post_decode_cmd.is_bbfp
  }
  when(io.cmdReq.fire){
    sel_reg := sel
  }.otherwise{
    sel_reg := sel_reg
  }
  BBFP_Control.io.is_matmul_ws := real_is_matmul_ws
  real_sel := Mux(io.cmdReq.valid, sel, sel_reg)
  // cmdResp输出分发
  io.cmdResp.valid := Mux(real_sel, BBFP_Control.io.cmdResp.valid, VecUnit.io.cmdResp.valid)// only valid need
  io.cmdResp.bits  := Mux(real_sel, BBFP_Control.io.cmdResp.bits, VecUnit.io.cmdResp.bits)
  BBFP_Control.io.cmdResp.ready := io.cmdResp.ready && real_sel
  VecUnit.io.cmdResp.ready      := io.cmdResp.ready && !real_sel

  // 连接到Scratchpad的SRAM读写接口
  for (i <- 0 until bbconfig.sp_banks) {
    // sramRead(i).req - Decoupled接口
    io.sramRead(i).req.valid := Mux(real_sel, BBFP_Control.io.sramRead(i).req.valid, VecUnit.io.sramRead(i).req.valid)
    io.sramRead(i).req.bits  := Mux(real_sel, BBFP_Control.io.sramRead(i).req.bits, VecUnit.io.sramRead(i).req.bits)
    BBFP_Control.io.sramRead(i).req.ready := io.sramRead(i).req.ready && real_sel
    VecUnit.io.sramRead(i).req.ready      := io.sramRead(i).req.ready && !real_sel

    // sramRead(i).resp - Flipped Decoupled接口
    BBFP_Control.io.sramRead(i).resp.valid := io.sramRead(i).resp.valid && real_sel
    BBFP_Control.io.sramRead(i).resp.bits  := io.sramRead(i).resp.bits
    VecUnit.io.sramRead(i).resp.valid      := io.sramRead(i).resp.valid && !real_sel
    VecUnit.io.sramRead(i).resp.bits       := io.sramRead(i).resp.bits
    io.sramRead(i).resp.ready := Mux(real_sel, BBFP_Control.io.sramRead(i).resp.ready, VecUnit.io.sramRead(i).resp.ready)

    // sramWrite(i) - 普通Bundle字段分发
    io.sramWrite(i).en   := Mux(real_sel, BBFP_Control.io.sramWrite(i).en,   VecUnit.io.sramWrite(i).en)
    io.sramWrite(i).addr := Mux(real_sel, BBFP_Control.io.sramWrite(i).addr, VecUnit.io.sramWrite(i).addr)
    io.sramWrite(i).data := Mux(real_sel, BBFP_Control.io.sramWrite(i).data, VecUnit.io.sramWrite(i).data)
    io.sramWrite(i).mask := Mux(real_sel, BBFP_Control.io.sramWrite(i).mask, VecUnit.io.sramWrite(i).mask)
  }

  // 连接到Accumulator的读写接口
  for (i <- 0 until bbconfig.acc_banks) {
    // accRead(i).req - Decoupled接口
    io.accRead(i).req.valid := Mux(real_sel, BBFP_Control.io.accRead(i).req.valid, VecUnit.io.accRead(i).req.valid)
    io.accRead(i).req.bits  := Mux(real_sel, BBFP_Control.io.accRead(i).req.bits, VecUnit.io.accRead(i).req.bits)
    BBFP_Control.io.accRead(i).req.ready := io.accRead(i).req.ready && real_sel
    VecUnit.io.accRead(i).req.ready      := io.accRead(i).req.ready && !real_sel

    // accRead(i).resp - Flipped Decoupled接口
    BBFP_Control.io.accRead(i).resp.valid := io.accRead(i).resp.valid && real_sel
    BBFP_Control.io.accRead(i).resp.bits  := io.accRead(i).resp.bits
    VecUnit.io.accRead(i).resp.valid      := io.accRead(i).resp.valid && !real_sel
    VecUnit.io.accRead(i).resp.bits       := io.accRead(i).resp.bits
    io.accRead(i).resp.ready := Mux(real_sel, BBFP_Control.io.accRead(i).resp.ready, VecUnit.io.accRead(i).resp.ready)

    // accWrite(i) - 普通Bundle字段分发
    io.accWrite(i).en   := Mux(real_sel, BBFP_Control.io.accWrite(i).en,   VecUnit.io.accWrite(i).en)
    io.accWrite(i).addr := Mux(real_sel, BBFP_Control.io.accWrite(i).addr, VecUnit.io.accWrite(i).addr)
    io.accWrite(i).data := Mux(real_sel, BBFP_Control.io.accWrite(i).data, VecUnit.io.accWrite(i).data)
    io.accWrite(i).mask := Mux(real_sel, BBFP_Control.io.accWrite(i).mask, VecUnit.io.accWrite(i).mask)
    io.accWrite(i).acc  := Mux(real_sel, BBFP_Control.io.accWrite(i).acc, VecUnit.io.accWrite(i).acc)
  }


  // cmdReq输入分发
  BBFP_Control.io.cmdReq.valid := io.cmdReq.valid && sel
  BBFP_Control.io.cmdReq.bits  := io.cmdReq.bits
  VecUnit.io.cmdReq.valid      := io.cmdReq.valid && !sel
  VecUnit.io.cmdReq.bits       := io.cmdReq.bits
  io.cmdReq.ready := Mux(real_sel, BBFP_Control.io.cmdReq.ready, VecUnit.io.cmdReq.ready)
}