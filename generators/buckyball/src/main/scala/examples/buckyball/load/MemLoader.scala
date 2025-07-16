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
import buckyball.mem.{SimpleReadRequest, SimpleReadResponse, SramWriteIO, AccWriteIO}
import buckyball.frontend.FrontendTLBIO
import freechips.rocketchip.rocket.MStatus
import buckyball.mem.AccWriteIO

class MemLoader(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
  val rob_id_width = log2Up(bbconfig.rob_entries)
  val spad_w = bbconfig.veclane * bbconfig.inputType.getWidth
  val acc_w = bbconfig.accveclane * bbconfig.accType.getWidth
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
    val accWrite = Vec(bbconfig.acc_banks,new AccWriteIO(bbconfig.acc_bank_entries, acc_w, (acc_w / (bbconfig.aligned_to * 8)) max 1))
  })

  val s_idle :: s_dma_req :: s_dma_wait :: Nil = Enum(3)
  val state = RegInit(s_idle)
  
  val rob_id_reg = RegInit(0.U(rob_id_width.W))
  val mem_addr_reg = Reg(UInt(bbconfig.memAddrLen.W))  // 缓存mem_addr
  val iter_reg = Reg(UInt(10.W))  // 缓存迭代次数
  val resp_count = Reg(UInt(log2Up(16).W))  // 计数接收到的响应数量，最多支持16个响应
  
  // 缓存解码好的bank信息
  val wr_bank_reg = Reg(UInt(log2Up(bbconfig.sp_banks).W))
  val wr_bank_addr_reg = Reg(UInt(log2Up(bbconfig.sp_bank_entries).W))
  val is_acc_reg = RegInit(false.B) // 是否是acc bank的操作

  // 接收load指令
  io.cmdReq.ready := state === s_idle
  
  when (io.cmdReq.fire && io.cmdReq.bits.cmd.post_decode_cmd.is_load) {
    state := s_dma_req
    rob_id_reg := io.cmdReq.bits.rob_id
    mem_addr_reg := io.cmdReq.bits.cmd.post_decode_cmd.mem_addr
    iter_reg := io.cmdReq.bits.cmd.post_decode_cmd.iter
    wr_bank_reg := io.cmdReq.bits.cmd.post_decode_cmd.wr_bank
    wr_bank_addr_reg := io.cmdReq.bits.cmd.post_decode_cmd.wr_bank_addr
    is_acc_reg := io.cmdReq.bits.cmd.post_decode_cmd.is_acc
    resp_count := 0.U
  }

  // 发起DMA读取请求 - 读取iter_reg行数据
  io.dmaReq.valid := state === s_dma_req
  io.dmaReq.bits.vaddr := mem_addr_reg
  io.dmaReq.bits.len := iter_reg * (bbconfig.veclane * bbconfig.inputType.getWidth / 8).U // iter行数据的字节数
  io.dmaReq.bits.status := 0.U.asTypeOf(new MStatus) // 简化：使用默认状态

  when (io.dmaReq.fire) {
    state := s_dma_wait
    resp_count := 0.U  // 重置响应计数器
  }

  // 等待DMA响应
  io.dmaResp.ready := state === s_dma_wait
  
  when (io.dmaResp.fire) {
    resp_count := resp_count + 1.U
    // 收到最后一个响应时转回idle状态
    when (io.dmaResp.bits.last) {
      state := s_idle
    }
  }

  // 流式写入SRAM - 每收到一个响应就立即写入
  // 计算当前写入的bank和地址
  val current_bank_addr = wr_bank_addr_reg + io.dmaResp.bits.addrcounter // 使用DMA响应中的地址计数器
  val target_bank = wr_bank_reg  // 所有响应都写入同一个bank
  val target_row = current_bank_addr
  
  for (i <- 0 until bbconfig.sp_banks) {
    io.sramWrite(i).en := io.dmaResp.fire && (target_bank === i.U)
    io.sramWrite(i).addr := target_row
    io.sramWrite(i).data := io.dmaResp.bits.data
    io.sramWrite(i).mask := VecInit(Seq.fill(mask_len)(true.B))
  }
  for (i <- 0 until bbconfig.acc_banks) {
    io.accWrite(i).en   := io.dmaResp.fire && is_acc_reg && (target_row(log2Ceil(bbconfig.acc_banks) - 1, 0) === i.U)
    io.accWrite(i).addr := wr_bank_addr_reg + (io.dmaResp.bits.addrcounter >> log2Ceil(bbconfig.acc_banks))
    io.accWrite(i).data := io.dmaResp.bits.data
    io.accWrite(i).mask := VecInit(Seq.fill(mask_len)(true.B))
    io.accWrite(i).acc  :=  false.B
  }

  // 发送完成信号 - 只有收到最后一个响应时才发送
  io.cmdResp.valid := io.dmaResp.fire && io.dmaResp.bits.last
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