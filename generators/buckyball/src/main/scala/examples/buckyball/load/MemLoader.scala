package buckyball.load

import chisel3._
import chisel3.util._
import framework.pipeline.Sisyphus
import framework.pipeline.SisyphusCmd
import framework.pipeline.SisyphusCtl
import framework.pipeline.SisyphusData
import org.chipsalliance.cde.config.Parameters
import buckyball.BuckyBallConfig
import buckyball.frontend.rs.{ReservationStationIssue, ReservationStationComplete, BuckyBallCmd}
import buckyball.mem.{SimpleReadRequest, SimpleReadResponse, SramWriteIO, LocalAddr}
import buckyball.frontend.FrontendTLBIO
import freechips.rocketchip.rocket.MStatus

class MemLoader(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
  val rob_id_width = log2Up(bbconfig.rob_entries)
  val spad_w = bbconfig.veclane * bbconfig.inputType.getWidth
  val mask_len = (spad_w / (bbconfig.aligned_to * 8)) max 1
  
  val io = IO(new Bundle {
    // 来自ReservationStation的load指令
    val cmdReq = Flipped(Decoupled(new ReservationStationIssue(new BuckyBallCmd, rob_id_width)))
    // 发送给ReservationStation的完成信号
    val cmdResp = Decoupled(new ReservationStationComplete(rob_id_width))
    // 直接连接DMA读取接口
    val dmaReq = Decoupled(new SimpleReadRequest())
    val dmaResp = Flipped(Decoupled(new SimpleReadResponse(spad_w)))
    // 连接到Scratchpad的SRAM写入接口
    val sramWrite = Vec(bbconfig.sp_banks, new SramWriteIO(bbconfig.sp_bank_entries, spad_w, mask_len))
  })

  val s_idle :: s_dma_req :: s_dma_wait :: s_sram_write :: Nil = Enum(4)
  val state = RegInit(s_idle)
  
  val rob_id_reg = RegInit(0.U(rob_id_width.W))
  val sp_addr_reg = Reg(UInt(14.W))
  val mem_addr_reg = Reg(UInt(14.W))  // 缓存mem_addr
  val data_reg = Reg(UInt(spad_w.W))

  // 接收load指令
  io.cmdReq.ready := state === s_idle
  
  when (io.cmdReq.fire && io.cmdReq.bits.cmd.post_decode_cmd.is_load) {
    state := s_dma_req
    rob_id_reg := io.cmdReq.bits.rob_id
    sp_addr_reg := io.cmdReq.bits.cmd.post_decode_cmd.sp_addr
    mem_addr_reg := io.cmdReq.bits.cmd.post_decode_cmd.mem_addr  // 缓存mem_addr
  }

  // 发起DMA读取请求 - 使用缓存的mem_addr
  io.dmaReq.valid := state === s_dma_req
  io.dmaReq.bits.vaddr := mem_addr_reg
  io.dmaReq.bits.len := (bbconfig.veclane * bbconfig.inputType.getWidth / 8).U // 一行数据的字节数
  io.dmaReq.bits.status := 0.U.asTypeOf(new MStatus) // 简化：使用默认状态

  when (io.dmaReq.fire) {
    state := s_dma_wait
  }

  // 等待DMA响应
  io.dmaResp.ready := state === s_dma_wait
  
  when (io.dmaResp.fire) {
    data_reg := io.dmaResp.bits.data
    state := s_sram_write
  }

  // 写入SRAM
  val laddr = LocalAddr.cast_to_sp_addr(bbconfig.local_addr_t, sp_addr_reg)
  val target_bank = laddr.sp_bank()
  val target_row = laddr.sp_row()
  
  for (i <- 0 until bbconfig.sp_banks) {
    io.sramWrite(i).en := (state === s_sram_write) && (target_bank === i.U)
    io.sramWrite(i).addr := target_row
    io.sramWrite(i).data := data_reg
    io.sramWrite(i).mask := VecInit(Seq.fill(mask_len)(true.B))
  }

  when (state === s_sram_write) {
    state := s_idle
  }

  // 发送完成信号
  io.cmdResp.valid := (state === s_sram_write)
  io.cmdResp.bits.rob_id := rob_id_reg
}

class MemLoaderSisyphus(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Sisyphus {
  val memLoader = Module(new MemLoader())
  
  def getProcessingCycles(): UInt = io.cmd.Iteration
  def getOperation(): UInt = io.cmd.Operation.bits
  def getIteration(): UInt = io.cmd.Iteration
  
  def processData(cycle: UInt): Vec[UInt] = {
    // 开始信号：当收到load指令并且MemLoader准备好时
    startSignal := io.cmd.Operation.fire && memLoader.io.cmdReq.ready
    
    // 到达信号：当DMA开始工作时
    arriveSignal := memLoader.io.dmaReq.fire
    
    // 完成信号：当SRAM写入完成时
    finishSignal := memLoader.io.cmdResp.fire
    
    // 输出操作状态信息
    val status = Cat(
      memLoader.io.dmaReq.valid,
      memLoader.io.dmaResp.valid,
      finishSignal,
      0.U(29.W)
    )
    VecInit(Seq.fill(16)(status))
  }
  
  // 暴露接口给外部连接
  val memLoaderCmdReq = memLoader.io.cmdReq
  val memLoaderCmdResp = memLoader.io.cmdResp
  val memLoaderDmaReq = memLoader.io.dmaReq
  val memLoaderDmaResp = memLoader.io.dmaResp

  val memLoaderSramWrite = memLoader.io.sramWrite
} 