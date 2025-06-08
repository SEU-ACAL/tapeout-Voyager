package buckyball.exec

import chisel3._
import chisel3.util._
import framework.pipeline.Sisyphus
import framework.pipeline.SisyphusCmd
import framework.pipeline.SisyphusCtl
import framework.pipeline.SisyphusData
import buckyball.mem.SramWriteIO

class WBStorer(val n: Int, val w: Int) extends Module {
  val io = IO(new Bundle {
    val dataIn = Flipped(Decoupled(UInt(w.W)))
    val dataOut = new SramWriteIO(n, w, w/8)
    val addr = Input(UInt(log2Ceil(n).W))
    val enable = Input(Bool())
  })
  
  // Connect write path
  io.dataOut.en := io.enable && io.dataIn.valid
  io.dataOut.addr := io.addr
  io.dataOut.data := io.dataIn.bits
  io.dataOut.mask := VecInit(Seq.fill(w/8)(true.B)) // 全部字节都写入
  
  // Ready when not busy
  io.dataIn.ready := !io.dataOut.en || true.B // 简化：总是ready
}

class WBStorerSisyphus extends Sisyphus {
  val sramWrite = IO(new SramWriteIO(16, 32, 4))
  val wbStorerModule = Module(new WBStorer(16, 32))
  
  def getProcessingCycles(): UInt = cycleCounter
  def getOperation(): UInt = io.cmd.Operation.bits
  def getIteration(): UInt = io.cmd.Iteration
  
  def processData(cycle: UInt): Vec[UInt] = {
    startSignal  := io.cmd.Operation.fire
    arriveSignal := io.data.dataIn.fire
    finishSignal := wbStorerModule.io.dataOut.en
    
    // Connect SRAM interface to WBStorer
    wbStorerModule.io.dataOut <> sramWrite
    io.data.dataIn <> wbStorerModule.io.dataIn
    wbStorerModule.io.addr := 0.U // 默认地址
    wbStorerModule.io.enable := true.B
    
    VecInit(Seq.fill(16)(wbStorerModule.io.dataIn.bits))
  }
}

