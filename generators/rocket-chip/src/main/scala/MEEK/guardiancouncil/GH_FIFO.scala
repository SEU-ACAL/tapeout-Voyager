package freechips.rocketchip.guardiancouncil

import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}

case class FIFOParams(
  width: Int,
  depth: Int
)

class FIFOIO(params: FIFOParams) extends Bundle {
  val enq_valid = Input(Bool())
  val full = Output(Bool())
  val enq_bits = Input(UInt(params.width.W))
  val deq_ready= Input(Bool())
  val empty = Output(Bool())
  val deq_bits = Output(UInt(params.width.W))
  val status_fiveslots = Output(UInt(1.W))
  val status_threeslots = Output(UInt(1.W))
  val status_twoslots = Output(UInt(1.W))
  val num_content = Output(UInt(log2Ceil(params.depth).W))
  val high_watermark = Output(UInt(1.W))

  val debug_fcounter = Output(UInt(64.W))
  val debug_fdcounter = Output(UInt(64.W))
}

trait HasFIFOIO extends BaseModule {
  val params: FIFOParams
  val io = IO(new FIFOIO(params))
}

class GH_FIFO(val params: FIFOParams) extends Module with HasFIFOIO {

  def counter(depth: Int, incr: Bool): (UInt, UInt) = {
    val cntReg                  = RegInit(0.U(log2Ceil(depth).W))
    val nextVal                 = Mux(cntReg === (depth-1).U, 0.U, cntReg + 1.U)
    when (incr) {
      cntReg                   := nextVal
    }
    (cntReg, nextVal)
  }

  // the register based memory
  val memReg                    = RegInit(VecInit(Seq.fill(params.depth)(0.U(params.width.W))))

  val incrRead                  = WireInit(false.B)
  val incrWrite                 = WireInit(false.B)

  val (readPtr, nextRead)       = counter(params.depth, incrRead)
  val (writePtr, nextWrite)     = counter(params.depth, incrWrite)

  val emptyReg                  = RegInit(true.B)
  val fullReg                   = RegInit(false.B)
  val num_contentReg            = RegInit(0.U(log2Ceil(params.depth).W))
  val debug_fcounter            = RegInit(0.U(64.W))
  val debug_fdcounter           = RegInit(0.U(64.W))

  when ((io.enq_valid && !fullReg) && (io.deq_ready && !emptyReg)) {
    memReg(writePtr)           := io.enq_bits
    emptyReg                   := false.B
    fullReg                    := false.B
    incrWrite                  := true.B
    incrRead                   := true.B
    num_contentReg             := num_contentReg
    debug_fcounter             := debug_fcounter + 1.U
    debug_fdcounter            := debug_fdcounter + 1.U
  }

  when ((io.enq_valid && !fullReg) && !(io.deq_ready && !emptyReg)){
    memReg(writePtr)           := io.enq_bits
    emptyReg                   := false.B
    fullReg                    := nextWrite === readPtr
    incrWrite                  := true.B
    num_contentReg             := num_contentReg + 1.U
    debug_fcounter             := debug_fcounter + 1.U
  }
    
  when (!(io.enq_valid && !fullReg) && (io.deq_ready && !emptyReg)) {
    emptyReg                   := nextRead === writePtr
    fullReg                    := false.B
    incrRead                   := true.B
    num_contentReg             := num_contentReg - 1.U
    debug_fdcounter            := debug_fdcounter + 1.U
  }
  
  io.status_fiveslots          := Mux(num_contentReg >= ((params.depth).U - 5.U),
                                      1.U, 
                                      0.U)

  io.status_threeslots         := Mux(num_contentReg >= ((params.depth).U - 3.U),
                                      1.U, 
                                      0.U)
  
  io.status_twoslots           := Mux(num_contentReg >= ((params.depth).U - 2.U),
                                      1.U, 
                                      0.U)
  
  io.deq_bits                  := memReg(readPtr)
  io.full                      := fullReg
  io.empty                     := emptyReg
  io.num_content               := num_contentReg
  io.debug_fcounter            := debug_fcounter
  io.debug_fdcounter           := debug_fdcounter
  if (params.depth > 100){
    io.high_watermark          := Mux(num_contentReg >= ((params.depth).U - 50.U),
                                      1.U, 
                                      0.U)
  } else {
    io.high_watermark          := 0.U
  }
}


class GH_MemFIFO(val params: FIFOParams) extends Module with HasFIFOIO {
  def counter(depth: Int, incr: Bool): (UInt, UInt) = {
    val cntReg                  = RegInit(0.U(log2Ceil(depth).W))
    val nextVal                 = Mux(cntReg === (depth-1).U, 0.U, cntReg + 1.U)
    when (incr) {
      cntReg                   := nextVal
    }
    (cntReg, nextVal)
  }

  val mem                       = SyncReadMem(params.depth, UInt(params.width.W))
  val incrRead                  = WireInit(false.B)
  val incrWrite                 = WireInit(false.B)

  val (readPtr, nextRead)       = counter(params.depth, incrRead)
  val (writePtr, nextWrite)     = counter(params.depth, incrWrite)

  val emptyReg                  = RegInit(true.B)
  val fullReg                   = RegInit(false.B)
  val num_contentReg            = RegInit(0.U(log2Ceil(params.depth).W))
  val debug_fcounter            = RegInit(0.U(64.W))
  val debug_fdcounter           = RegInit(0.U(64.W))

  when ((io.enq_valid && !fullReg) && (io.deq_ready && !emptyReg)) {
    mem.write                     (writePtr, io.enq_bits)
    emptyReg                   := false.B
    fullReg                    := false.B
    incrWrite                  := true.B
    incrRead                   := true.B
    num_contentReg             := num_contentReg
    debug_fcounter             := debug_fcounter + 1.U
    debug_fdcounter            := debug_fdcounter + 1.U
  }

  when ((io.enq_valid && !fullReg) && !(io.deq_ready && !emptyReg)){
    mem.write                     (writePtr, io.enq_bits)
    emptyReg                   := false.B
    fullReg                    := nextWrite === readPtr
    incrWrite                  := true.B
    num_contentReg             := num_contentReg + 1.U
    debug_fcounter             := debug_fcounter + 1.U
  }
    
  when (!(io.enq_valid && !fullReg) && (io.deq_ready && !emptyReg)) {
    emptyReg                   := nextRead === writePtr
    fullReg                    := false.B
    incrRead                   := true.B
    num_contentReg             := num_contentReg - 1.U
    debug_fdcounter            := debug_fdcounter + 1.U
  }
  
  io.status_fiveslots          := Mux(num_contentReg >= ((params.depth).U - 5.U),
                                      1.U, 
                                      0.U)

  io.status_threeslots         := Mux(num_contentReg >= ((params.depth).U - 3.U),
                                      1.U, 
                                      0.U)
  
  io.status_twoslots           := Mux(num_contentReg >= ((params.depth).U - 2.U),
                                      1.U, 
                                      0.U)
  
  io.deq_bits                  := mem.read(readPtr, io.deq_ready)
  io.full                      := fullReg
  io.empty                     := emptyReg
  io.num_content               := num_contentReg
  io.debug_fcounter            := debug_fcounter
  io.debug_fdcounter           := debug_fdcounter

  if (params.depth > 100){
    io.high_watermark          := Mux(num_contentReg >= ((params.depth).U - 50.U),
                                      1.U, 
                                      0.U)
  } else {
    io.high_watermark          := 0.U
  }
}