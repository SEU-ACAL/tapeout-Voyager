package buckyball.exec

import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters

import dialect.vector._
import buckyball.frontend.rs.{ReservationStationIssue, ReservationStationComplete, BuckyBallCmd}
import buckyball.mem.{SramReadIO, SramWriteIO}
import buckyball.BuckyBallConfig
import buckyball.exec.bfp.{ExTop, ThreadConfigurations}
import buckyball.BBISA

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

  // 实例化 ExTop
  val (exTopConfig, exTopConnection) = ThreadConfigurations.customExConfig()
  val exTop = Module(new ExTop(exTopConfig, exTopConnection))
  
  // 状态机
  val s_idle :: s_read_both :: s_wait_both :: s_compute :: s_write :: Nil = Enum(5)
  val state = RegInit(s_idle)
  
  val rob_id_reg = RegInit(0.U(rob_id_width.W))
  val operand_a = Reg(UInt(spad_w.W))
  val operand_b = Reg(UInt(spad_w.W))
  val result = Reg(UInt(spad_w.W))
  val compute_counter = RegInit(0.U(8.W))  // 计算超时计数器
  
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

  // 通过 ExTop 进行计算
  // ExTop 数据输入 - 将操作数转换为 FP16 向量格式
  val operand_a_vec = Wire(Vec(exTopConfig.lane, UInt(16.W)))
  val operand_b_vec = Wire(Vec(exTopConfig.lane, UInt(16.W)))
  
  // 将 SRAM 数据重新打包为 FP16 向量（简化处理，实际可能需要格式转换）
  for (i <- 0 until exTopConfig.lane) {
    val byte_offset = i * 16 // 每个FP16元素占16位
    if (byte_offset + 16 <= spad_w) {
      operand_a_vec(i) := operand_a(byte_offset + 15, byte_offset)
      operand_b_vec(i) := operand_b(byte_offset + 15, byte_offset)
    } else {
      operand_a_vec(i) := 0.U(16.W)
      operand_b_vec(i) := 0.U(16.W)
    }
  }
  
  // 根据原始指令的func7来选择多个不同的chain模式
  import buckyball.BBISA._
  val thread_enable_pattern = WireDefault("b00000000000001".U(14.W)) // 默认模式，14位宽
  val opcode = WireDefault(1.U(8.W))
  val chain_mode = WireDefault(0.U(2.W))
  
  // 根据原始指令的func7直接判断thread类型
  val inst_opcode = cmd_reg.post_decode_cmd.func7
  
  // 根据指令的func7选择不同的chain模式，使用14位宽来激活所有可能的threads
  when (state === s_compute) {
    switch (inst_opcode) {
      is ("b0100001".U) {  // Chain 1: 输入端口1->vmul->reduce1->adder1->adder2, 输入端口2+adder2的输出->reduce2->citu1->mul->输出
        // 激活: vmul1(0), reduce1(1), adder1(2), reduce2(3), citu1(4), mul_chain1(5), adder2(13)
        thread_enable_pattern := "b10000000111111".U(14.W) 
        opcode := 0.U(8.W) // Chain mode 0 in opcode[1:0]
        chain_mode := 0.U
      }
      is ("b0100010".U) {  // Chain 2: 输入端口1->sub1->citu1->reduce3->adder2, 输入端口2->sub2->citu2输出+adder2的输出->div->输出
        // 激活: citu1(4), sub1(6), reduce3(7), sub2(8), div1(9), citu2(11), adder2(13)
        thread_enable_pattern := "b10001011011010".U(14.W)
        opcode := 1.U(8.W) // Chain mode 1 in opcode[1:0]
        chain_mode := 1.U
      }
      is ("b0100011".U) {  // Chain 3: 输入端口1->citu1, 输入端口2+citu1的输出->mul->输出
        // 激活: citu1(4), mul_chain3(10)
        thread_enable_pattern := "b00010000010000".U(14.W)
        opcode := 2.U(8.W) // Chain mode 2 in opcode[1:0]
        chain_mode := 2.U
      }
      is ("b0100100".U) {  // Chain 4: 输入端口1->reduce1->citu1->reduce3->输出, 输入端口2->reduce2->citu2->reduce4->输出
        // 激活: reduce1(1), reduce2(3), citu1(4), reduce3(7), citu2(11), reduce4(12)
        thread_enable_pattern := "b01001010011010".U(14.W)
        opcode := 3.U(8.W) // Chain mode 3 in opcode[1:0]
        chain_mode := 3.U
      }
      is ("b0100000".U) {  // 原有的通用矩阵乘法指令 - 激活完整pipeline
        thread_enable_pattern := "b11111111111111".U(14.W) // 激活所有14个threads（流水线模式）
        opcode := 0.U(8.W) // 默认使用chain mode 0
        chain_mode := 0.U
      }
    }
  }
  
  exTop.io.ctrl.threadEnable := thread_enable_pattern
  exTop.io.ctrl.opcode := opcode
  exTop.io.ctrl.enable := (state === s_compute)
  
  // ExTop 数据输入 - 双输入端口
  exTop.io.dataIn1.valid := (state === s_compute)
  exTop.io.dataIn1.bits := operand_a_vec // 操作数A到输入端口1
  exTop.io.dataIn2.valid := (state === s_compute)
  exTop.io.dataIn2.bits := operand_b_vec // 操作数B到输入端口2
  
  // ExTop 数据输出 - 双输出端口（使用第一个输出端口）
  exTop.io.dataOut1.ready := (state === s_compute)
  exTop.io.dataOut2.ready := (state === s_compute)
  
  // 计算状态控制
  when (state === s_compute) {
    compute_counter := compute_counter + 1.U
    
    when (exTop.io.dataOut1.fire || exTop.io.dataOut2.fire) {
      // 将 ExTop 输出转换回 SRAM 格式
      val result_vec = Mux(exTop.io.dataOut1.fire, 
                          exTop.io.dataOut1.bits.data, 
                          exTop.io.dataOut2.bits.data)
      // 将8位数据向量转换为SRAM宽度的数据，剩余位填零
      val padded_result = Wire(UInt(spad_w.W))
      val result_bits = Cat(result_vec.reverse.map(_.asUInt))
      padded_result := Cat(0.U((spad_w - result_bits.getWidth).W), result_bits)
      result := padded_result
      state := s_write
      compute_counter := 0.U
    } .elsewhen (compute_counter >= 100.U) {
      // 超时处理 - 强制继续，使用默认结果
      result := "hDEADBEEF".U(spad_w.W)  // 调试用的固定值，确保位宽正确
      state := s_write
      compute_counter := 0.U
      printf("ExecuteController: Compute timeout, thread_enable=%b, opcode=%d\n", 
             thread_enable_pattern, opcode)
    }
  } .otherwise {
    compute_counter := 0.U
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