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

  // 状态机
  val s_idle :: s_read_both :: s_wait_both :: s_compute :: s_write :: Nil = Enum(5)
  val state = RegInit(s_idle)
  
  val rob_id_reg = RegInit(0.U(rob_id_width.W))
  val operand_a = Reg(UInt(spad_w.W))
  val operand_b = Reg(UInt(spad_w.W))
  val result = Reg(UInt(spad_w.W))
  
  // 直接使用解码好的bank和本地地址信息
  val cmd_reg = Reg(new BuckyBallCmd)
  
  val opA_bank = cmd_reg.post_decode_cmd.op1_bank        // OpA使用op1_bank
  val opA_bank_addr = cmd_reg.post_decode_cmd.op1_bank_addr
  val opB_bank = cmd_reg.post_decode_cmd.op2_bank        // OpB使用op2_bank
  val opB_bank_addr = cmd_reg.post_decode_cmd.op2_bank_addr
  val dest_bank = cmd_reg.post_decode_cmd.wr_bank        // 结果使用wr_bank
  val dest_bank_addr = cmd_reg.post_decode_cmd.wr_bank_addr
  
  // 断言：确保OpA和OpB访问不同的bank
  assert(!(state === s_read_both && opA_bank === opB_bank), 
    "ExecuteController: OpA and OpB cannot access the same bank")
  
  // 接收execute指令
  io.cmdReq.ready := state === s_idle
  
  when (io.cmdReq.fire && io.cmdReq.bits.cmd.post_decode_cmd.is_ex) {
    state := s_read_both
    rob_id_reg := io.cmdReq.bits.rob_id
    cmd_reg := io.cmdReq.bits.cmd
  }

  // 同时读取OpA和OpB（因为它们在不同bank，可以并行）
  for (i <- 0 until bbconfig.sp_banks) {
    // 同时向OpA和OpB的bank发出读请求
    io.sramRead(i).req.valid := (state === s_read_both) && 
                                ((opA_bank === i.U) || (opB_bank === i.U))
    io.sramRead(i).req.bits.addr := Mux(opA_bank === i.U, opA_bank_addr, opB_bank_addr)
    io.sramRead(i).req.bits.fromDMA := false.B
  }
  
  when (state === s_read_both) {
    // 检查两个bank的请求是否都发出了
    val opA_req_fired = io.sramRead(opA_bank).req.fire
    val opB_req_fired = io.sramRead(opB_bank).req.fire
    when (opA_req_fired && opB_req_fired) {
      state := s_wait_both
    }
  }

  // 等待两个操作数响应 - 根据响应的bank来区分OpA和OpB
  val sram_resp_valid = io.sramRead.map(_.resp.valid).reduce(_ || _)
  val sram_resp_data = Mux1H(io.sramRead.map(_.resp.valid), io.sramRead.map(_.resp.bits.data))
  val resp_bank = OHToUInt(VecInit(io.sramRead.map(_.resp.valid)))
  
  io.sramRead.foreach(_.resp.ready := state === s_wait_both)
  
  val a_received = RegInit(false.B)
  val b_received = RegInit(false.B)
  
  when (state === s_wait_both) {
    when (sram_resp_valid) {
      // 根据响应的bank来判断这是OpA还是OpB的数据
      when (resp_bank === opA_bank && !a_received) {
        operand_a := sram_resp_data
        a_received := true.B
      }
      when (resp_bank === opB_bank && !b_received) {
        operand_b := sram_resp_data  
        b_received := true.B
      }
    }
    when (a_received && b_received) {
      state := s_compute
      a_received := false.B
      b_received := false.B
    }
  }

  // 向量加法计算
  when (state === s_compute) {
    result := operand_a + operand_b // 简单的向量加法
    state := s_write
  }

  // 写入结果
  for (i <- 0 until bbconfig.sp_banks) {
    io.sramWrite(i).en := (state === s_write) && (dest_bank === i.U)
    io.sramWrite(i).addr := dest_bank_addr
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