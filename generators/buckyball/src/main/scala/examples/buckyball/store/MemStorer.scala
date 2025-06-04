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

class MemStorer(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
  val rob_id_width = log2Up(bbconfig.rob_entries)
  val spad_w = bbconfig.veclane * bbconfig.inputType.getWidth
  
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

  val s_idle :: s_sram_read :: s_sram_wait :: s_dma_req :: s_dma_wait :: Nil = Enum(5)
  val state = RegInit(s_idle)
  
  val rob_id_reg = RegInit(0.U(rob_id_width.W))
  val mem_addr_reg = Reg(UInt(14.W))
  val sp_addr_reg = Reg(UInt(14.W))  // 缓存sp_addr
  val data_reg = Reg(UInt(spad_w.W))

  // 接收store指令
  io.cmdReq.ready := state === s_idle
  
  when (io.cmdReq.fire && io.cmdReq.bits.cmd.post_decode_cmd.is_store) {
    state := s_sram_read
    rob_id_reg := io.cmdReq.bits.rob_id
    mem_addr_reg := io.cmdReq.bits.cmd.post_decode_cmd.mem_addr
    sp_addr_reg := io.cmdReq.bits.cmd.post_decode_cmd.sp_addr  // 缓存sp_addr
  }

  // 从SRAM读取数据 - 使用缓存的sp_addr
  val laddr = LocalAddr.cast_to_sp_addr(bbconfig.local_addr_t, sp_addr_reg)
  val target_bank = laddr.sp_bank()
  val target_row = laddr.sp_row()
  
  for (i <- 0 until bbconfig.sp_banks) {
    io.sramRead(i).req.valid := (state === s_sram_read) && (target_bank === i.U)
    io.sramRead(i).req.bits.addr := target_row
    io.sramRead(i).req.bits.fromDMA := true.B // 标记为DMA相关的读取
  }

  when (state === s_sram_read && io.sramRead.map(_.req.fire).reduce(_ || _)) {
    state := s_sram_wait
  }

  // 等待SRAM响应
  val sram_resp_valid = io.sramRead.map(_.resp.valid).reduce(_ || _)
  val sram_resp_data = Mux1H(io.sramRead.map(_.resp.valid), io.sramRead.map(_.resp.bits.data))
  
  io.sramRead.foreach(_.resp.ready := state === s_sram_wait)
  
  when (state === s_sram_wait && sram_resp_valid) {
    data_reg := sram_resp_data
    state := s_dma_req
  }

  // 发起DMA写入请求
  io.dmaReq.valid := state === s_dma_req
  io.dmaReq.bits.vaddr := mem_addr_reg
  io.dmaReq.bits.data := data_reg
  io.dmaReq.bits.len := (bbconfig.veclane * bbconfig.inputType.getWidth / 8).U // 一行数据的字节数
  io.dmaReq.bits.status := 0.U.asTypeOf(new MStatus) // 简化：使用默认状态

  when (io.dmaReq.fire) {
    state := s_dma_wait
  }

  // 等待DMA真正完成
  io.dmaResp.ready := state === s_dma_wait
  
  when (state === s_dma_wait && io.dmaResp.fire && io.dmaResp.bits.done) {
    state := s_idle
  }

  // 发送完成信号
  io.cmdResp.valid := (state === s_dma_wait) && io.dmaResp.fire && io.dmaResp.bits.done
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

