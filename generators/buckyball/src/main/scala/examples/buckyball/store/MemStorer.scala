package buckyball.store

import chisel3._
import chisel3.util._
import framework.pipeline.Sisyphus
import framework.pipeline.SisyphusCmd
import framework.pipeline.SisyphusCtl
import framework.pipeline.SisyphusData
import org.chipsalliance.cde.config.Parameters
import buckyball.BuckyBallConfig
import buckyball.frontend.rs.{ReservationStationIssue, ReservationStationComplete, BuckyBallCmd}
import buckyball.mem.{SimpleWriteRequest, SimpleWriteResponse, SramReadIO, LocalAddr}
import buckyball.frontend.FrontendTLBIO
import freechips.rocketchip.rocket.MStatus
import buckyball.mem.{SimpleReadRequest, SimpleReadResponse, SramReadIO}

class MemStorer(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
  val rob_id_width = log2Up(bbconfig.rob_entries)
  val spad_w = bbconfig.veclane * bbconfig.inputType.getWidth
  val line_bytes = spad_w / 8  // 一行数据的字节数
  val align_bytes = 16  // 16字节对齐
  
  val io = IO(new Bundle {
    // 来自ReservationStation的store指令
    val cmdReq = Flipped(Decoupled(new ReservationStationIssue(new BuckyBallCmd, rob_id_width)))
    // 发送给ReservationStation的完成信号
    val cmdResp = Decoupled(new ReservationStationComplete(rob_id_width))
    // 直接连接DMA写入接口
    val dmaReq = Decoupled(new SimpleWriteRequest(spad_w))
    val dmaResp = Flipped(Decoupled(new SimpleWriteResponse))
    // 连接到Scratchpad的SRAM读取接口
    val sramRead = Vec(bbconfig.sp_banks, new SramReadIO(bbconfig.sp_bank_entries, spad_w))
  })

  val s_idle :: s_sram_req :: s_dma_wait :: Nil = Enum(3)
  val state = RegInit(s_idle)
  
  val rob_id_reg = RegInit(0.U(rob_id_width.W))
  val mem_addr_reg = Reg(UInt(bbconfig.memAddrLen.W))
  val iter_reg = Reg(UInt(10.W))
  val sram_count = Reg(UInt(log2Up(16).W))
  
  // 缓存解码好的bank信息
  val rd_bank_reg = Reg(UInt(log2Up(bbconfig.sp_banks).W))
  val rd_bank_addr_reg = Reg(UInt(log2Up(bbconfig.sp_bank_entries).W))

  // 数据缓存相关寄存器
  val data_buffer = Reg(UInt((align_bytes * 8).W))  // 16字节缓存
  val buffer_valid_bytes = Reg(UInt(log2Ceil(align_bytes + 1).W))  // 缓存中有效字节数
  val buffer_start_addr = Reg(UInt(bbconfig.memAddrLen.W))  // 缓存对应的起始地址
  
  // 接收store指令
  io.cmdReq.ready := state === s_idle
  
  when (io.cmdReq.fire && io.cmdReq.bits.cmd.post_decode_cmd.is_store) {
    state := s_sram_req
    rob_id_reg := io.cmdReq.bits.rob_id
    mem_addr_reg := io.cmdReq.bits.cmd.post_decode_cmd.mem_addr
    iter_reg := io.cmdReq.bits.cmd.post_decode_cmd.iter
    rd_bank_reg := io.cmdReq.bits.cmd.post_decode_cmd.rd_bank
    rd_bank_addr_reg := io.cmdReq.bits.cmd.post_decode_cmd.rd_bank_addr
    sram_count := 0.U
    
    // 初始化缓存状态
    buffer_valid_bytes := 0.U
  }

  // 流式读取SRAM数据
  // 计算当前读取的bank和地址
  val current_bank_addr = rd_bank_addr_reg + sram_count
  val target_bank = rd_bank_reg  // 所有读取都来自同一个bank
  val target_row = current_bank_addr
  
  for (i <- 0 until bbconfig.sp_banks) {
    io.sramRead(i).req.valid := (state === s_sram_req) && (target_bank === i.U)
    io.sramRead(i).req.bits.addr := target_row
    io.sramRead(i).req.bits.fromDMA := true.B
  }

  // SRAM响应处理
  val sram_resp_valid = io.sramRead.map(_.resp.valid).reduce(_ || _)
  val sram_resp_data = Mux1H(io.sramRead.map(_.resp.valid), io.sramRead.map(_.resp.bits.data))
  
  // 计算当前行对应的内存地址
  val current_mem_addr = mem_addr_reg + (sram_count * line_bytes.U)
  val addr_offset = current_mem_addr(log2Ceil(align_bytes) - 1, 0)  // 地址的低4位，16字节对齐时为0
  val aligned_addr = Cat(current_mem_addr(bbconfig.memAddrLen - 1, log2Ceil(align_bytes)), 0.U(log2Ceil(align_bytes).W))
  val is_aligned = addr_offset === 0.U
  dontTouch(is_aligned)
  dontTouch(aligned_addr)
  
  // 数据合并逻辑 (line_bytes = 16字节)
  val incoming_data = sram_resp_data.asUInt
  val incoming_bytes = 16.U  // 永远是16字节
  
  // 合并到缓存的数据
  val merged_data = Wire(UInt((align_bytes * 8).W))
  val total_valid_bytes = Wire(UInt(log2Ceil(align_bytes * 2).W))
  val is_last_iter = (sram_count >= iter_reg && iter_reg > 0.U) || iter_reg === 0.U
  
  when (buffer_valid_bytes === 0.U) {
    // 缓存为空
    when (addr_offset === 0.U) {
      // 地址已对齐，直接使用数据
      merged_data := incoming_data
      total_valid_bytes := incoming_bytes
    }.otherwise {
      // 地址不对齐，第一次：将新数据低位作为发送数据高位，低位补0
      val new_data_low = incoming_data & ((1.U << (addr_offset * 8.U)) - 1.U)
      merged_data := new_data_low << (addr_offset * 8.U)
      total_valid_bytes := align_bytes.U
    }
  }.otherwise {
    // 缓存有数据，拼接：新数据低位作为高位 + 缓存数据作为低位
    val new_data_low = incoming_data & ((1.U << (addr_offset * 8.U)) - 1.U)
    merged_data := (new_data_low << (addr_offset * 8.U)) | data_buffer
    total_valid_bytes := align_bytes.U  // 总是16字节
  }
  
  // 发送逻辑：除了最后一次迭代，总是能填满16字节
  val can_send_full_line = total_valid_bytes >= align_bytes.U
  val send_bytes = Mux(can_send_full_line, align_bytes.U, total_valid_bytes)
  
  // 确定发送地址 - 始终使用对齐地址
  val send_addr = Mux(buffer_valid_bytes === 0.U, aligned_addr, 
    Cat(buffer_start_addr(bbconfig.memAddrLen - 1, log2Ceil(align_bytes)), 0.U(log2Ceil(align_bytes).W)))
  
  // DMA请求逻辑
  val should_send_normal = sram_resp_valid && can_send_full_line
  val should_send_first_unaligned = sram_resp_valid && (buffer_valid_bytes === 0.U && addr_offset =/= 0.U)
  val should_send_last = sram_resp_valid && is_last_iter && !can_send_full_line
  val should_send = should_send_normal || should_send_first_unaligned || should_send_last
  
  // 迭代结束后还需要发送剩余缓存数据
  val has_remaining_data = buffer_valid_bytes > 0.U && is_last_iter
  val final_send = has_remaining_data && !sram_resp_valid
  
  // 生成mask
  val send_mask = Wire(UInt(align_bytes.W))
  when (buffer_valid_bytes === 0.U && addr_offset =/= 0.U) {
    // 第一次非对齐：发送新数据高位，mask在高位
    val valid_bytes = align_bytes.U - addr_offset
    send_mask := ((1.U << valid_bytes) - 1.U) << addr_offset  // 0xFF00 (如果addr_offset=8)
  }.elsewhen (buffer_valid_bytes > 0.U && can_send_full_line) {
    // 中间拼接：发送完整16字节
    send_mask := ~0.U(align_bytes.W)  // 0xFFFF  
  }.elsewhen (final_send) {
    // 最后发送剩余buffer数据：缓存数据在低位
    send_mask := (1.U << buffer_valid_bytes) - 1.U  // 0x00FF
  }.otherwise {
    // 对齐情况：完整数据
    send_mask := ~0.U(align_bytes.W)  // 0xFFFF
  }
  
  io.dmaReq.valid := (should_send || final_send) && (state === s_sram_req || state === s_dma_wait)
  io.dmaReq.bits.vaddr := Mux(final_send, buffer_start_addr, send_addr)
  io.dmaReq.bits.data := Mux(final_send, data_buffer, merged_data)
  io.dmaReq.bits.len := align_bytes.U
  io.dmaReq.bits.mask := Mux(final_send, (1.U << buffer_valid_bytes) - 1.U, send_mask)
  io.dmaReq.bits.status := 0.U.asTypeOf(new MStatus)

  // 连接SRAM响应ready信号
  io.sramRead.foreach(_.resp.ready := io.dmaReq.ready && (state === s_sram_req || state === s_dma_wait))

  // 状态转换和计数器更新
  when (io.sramRead.map(_.req.fire).reduce(_ || _)) {
    state := s_dma_wait
  }

  when (io.dmaReq.fire) {
    when (!final_send) {
      sram_count := sram_count + 1.U
    }
    
    // 更新缓存状态  
    when (addr_offset =/= 0.U && sram_resp_valid) {
      // 非对齐情况：缓存新数据的高位部分
      val remaining_bytes = align_bytes.U - addr_offset  // 缓存的是高位部分
      data_buffer := incoming_data >> (addr_offset * 8.U)
      buffer_valid_bytes := remaining_bytes
      // 更新buffer对应的地址（指向下一个16字节对齐地址）
      when (buffer_valid_bytes === 0.U) {
        buffer_start_addr := aligned_addr + align_bytes.U
      }.otherwise {
        buffer_start_addr := buffer_start_addr + align_bytes.U
      }
    }.elsewhen (final_send) {
      // 发送了最后的剩余数据，清空缓存
      buffer_valid_bytes := 0.U
    }
    
    // 检查是否完成所有迭代
    when (final_send) {
      // final_send 完成后才回到 idle
      state := s_idle
    }.elsewhen (sram_count + 1.U >= iter_reg && iter_reg > 0.U) {
      // 迭代结束，但可能还有缓存数据需要发送
      when (buffer_valid_bytes > 0.U && addr_offset =/= 0.U) {
        state := s_dma_wait  // 保持状态，等待 final_send
      }.otherwise {
        state := s_idle
      }
    }.elsewhen (iter_reg === 0.U) {
      state := s_idle
    }.otherwise {
      state := s_sram_req
    }
  }

  // 等待DMA真正完成
  io.dmaResp.ready := true.B

  // 发送完成信号
  io.cmdResp.valid := io.dmaReq.fire && (
    (iter_reg === 0.U) || (sram_count + 1.U >= iter_reg)
  )
  io.cmdResp.bits.rob_id := rob_id_reg
}

class MemStorerSisyphus(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Sisyphus {
  val memStorer = Module(new MemStorer())
  
  def getProcessingCycles(): UInt = io.cmd.Iteration
  def getOperation(): UInt = io.cmd.Operation.bits
  def getIteration(): UInt = io.cmd.Iteration
  
  def processData(cycle: UInt): Vec[UInt] = {
    // 开始信号：当收到store指令并且MemStorer准备好时
    startSignal := io.cmd.Operation.fire && memStorer.io.cmdReq.ready
    
    // 到达信号：当SRAM读取开始时
    arriveSignal := memStorer.io.sramRead.map(_.req.fire).reduce(_ || _)
    
    // 完成信号：当DMA写入完成时
    finishSignal := memStorer.io.cmdResp.fire
    
    // 输出操作状态信息
    val status = Cat(
      memStorer.io.sramRead.map(_.req.valid).reduce(_ || _),
      memStorer.io.dmaReq.valid,
      finishSignal,
      0.U(29.W)
    )
    VecInit(Seq.fill(16)(status))
  }
  
  // 暴露接口给外部连接
  val memStorerCmdReq = memStorer.io.cmdReq
  val memStorerCmdResp = memStorer.io.cmdResp
  val memStorerDmaReq = memStorer.io.dmaReq
  val memStorerDmaResp = memStorer.io.dmaResp
  val memStorerSramRead = memStorer.io.sramRead
}

