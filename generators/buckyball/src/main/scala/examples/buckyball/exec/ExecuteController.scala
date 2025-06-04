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
    
    // 连接到Scratchpad的SRAM读取接口（读取操作数）
    val sramReadA = Vec(bbconfig.sp_banks, new SramReadIO(bbconfig.sp_bank_entries, spad_w))
    val sramReadB = Vec(bbconfig.sp_banks, new SramReadIO(bbconfig.sp_bank_entries, spad_w))
    
    // 连接到Scratchpad的SRAM写入接口（写入结果）
    val sramWrite = Vec(bbconfig.sp_banks, new SramWriteIO(bbconfig.sp_bank_entries, spad_w, spad_w/8))
  })

  // 状态机
  val s_idle :: s_read_a :: s_read_b :: s_wait_a :: s_wait_b :: s_compute :: s_write :: Nil = Enum(7)
  val state = RegInit(s_idle)
  
  val rob_id_reg = RegInit(0.U(rob_id_width.W))
  val operand_a = Reg(UInt(spad_w.W))
  val operand_b = Reg(UInt(spad_w.W))
  val result = Reg(UInt(spad_w.W))
  
  // 接收execute指令
  io.cmdReq.ready := state === s_idle
  
  when (io.cmdReq.fire && io.cmdReq.bits.cmd.post_decode_cmd.is_ex) {
    state := s_read_a
    rob_id_reg := io.cmdReq.bits.rob_id
  }

  // 读取操作数A
  for (i <- 0 until bbconfig.sp_banks) {
    io.sramReadA(i).req.valid := (state === s_read_a) && (i.U === 0.U) // 简化：只用bank 0
    io.sramReadA(i).req.bits.addr := 0.U // 简化：固定地址
    io.sramReadA(i).req.bits.fromDMA := false.B
  }
  
  when (state === s_read_a && io.sramReadA.map(_.req.fire).reduce(_ || _)) {
    state := s_wait_a
  }

  // 等待操作数A响应
  val sram_a_resp_valid = io.sramReadA.map(_.resp.valid).reduce(_ || _)
  val sram_a_resp_data = Mux1H(io.sramReadA.map(_.resp.valid), io.sramReadA.map(_.resp.bits.data))
  
  io.sramReadA.foreach(_.resp.ready := state === s_wait_a)
  
  when (state === s_wait_a && sram_a_resp_valid) {
    operand_a := sram_a_resp_data
    state := s_read_b
  }

  // 读取操作数B
  for (i <- 0 until bbconfig.sp_banks) {
    io.sramReadB(i).req.valid := (state === s_read_b) && (i.U === 0.U) // 简化：只用bank 0
    io.sramReadB(i).req.bits.addr := 1.U // 简化：固定地址
    io.sramReadB(i).req.bits.fromDMA := false.B
  }
  
  when (state === s_read_b && io.sramReadB.map(_.req.fire).reduce(_ || _)) {
    state := s_wait_b
  }

  // 等待操作数B响应
  val sram_b_resp_valid = io.sramReadB.map(_.resp.valid).reduce(_ || _)
  val sram_b_resp_data = Mux1H(io.sramReadB.map(_.resp.valid), io.sramReadB.map(_.resp.bits.data))
  
  io.sramReadB.foreach(_.resp.ready := state === s_wait_b)
  
  when (state === s_wait_b && sram_b_resp_valid) {
    operand_b := sram_b_resp_data
    state := s_compute
  }

  // 向量加法计算
  when (state === s_compute) {
    result := operand_a + operand_b // 简单的向量加法
    state := s_write
  }

  // 写入结果
  for (i <- 0 until bbconfig.sp_banks) {
    io.sramWrite(i).en := (state === s_write) && (i.U === 0.U) // 简化：只用bank 0
    io.sramWrite(i).addr := 2.U // 简化：固定结果地址
    io.sramWrite(i).data := result
    io.sramWrite(i).mask := VecInit(Seq.fill(spad_w/8)(true.B))
  }

  when (state === s_write) {
    state := s_idle
  }

  // 发送完成信号
  io.cmdResp.valid := (state === s_write)
  io.cmdResp.bits.rob_id := rob_id_reg
}