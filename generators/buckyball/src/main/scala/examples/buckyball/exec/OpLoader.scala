package buckyball.exec

import chisel3._
import chisel3.util._
import framework.pipeline.Sisyphus
import framework.pipeline.SisyphusCmd
import framework.pipeline.SisyphusCtl
import framework.pipeline.SisyphusData
import buckyball.mem.SramReadIO

class OpLoader(val n: Int, val w: Int) extends Module {
  val io = IO(new Bundle {
    val dataIn = new SramReadIO(n, w)
    val dataOut = Decoupled(Vec(16, UInt(32.W)))
  })
  
  // Connect request path
  io.dataIn.req.valid := io.dataOut.ready
  io.dataIn.req.bits.addr := 0.U  // Default address, should be configured as needed
  io.dataIn.req.bits.fromDMA := false.B
  
  // Connect response path
  io.dataOut.valid := io.dataIn.resp.valid
  io.dataOut.bits := VecInit(Seq.fill(16)(io.dataIn.resp.bits.data))
  io.dataIn.resp.ready := io.dataOut.ready
} 


class OpLoaderSisyphus extends Sisyphus {
  val sramRead = IO(new SramReadIO(16, 32))
  val opLoaderModule = Module(new OpLoader(16, 32))
  
  def getProcessingCycles(): UInt = cycleCounter
  def getOperation(): UInt = io.cmd.Operation.bits
  def getIteration(): UInt = io.cmd.Iteration
  
  def processData(cycle: UInt): Vec[UInt] = {
    startSignal  := io.cmd.Operation.fire
    arriveSignal := io.data.dataOut.fire
    finishSignal := io.data.dataOut.fire && (cycleCounter === 0.U)
    
    // Connect SRAM interface to OpLoader
    opLoaderModule.io.dataIn <> sramRead
    io.data.dataOut <> opLoaderModule.io.dataOut
    
    opLoaderModule.io.dataOut.bits
  }
} 