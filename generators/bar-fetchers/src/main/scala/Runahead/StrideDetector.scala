package barf

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.{Field, Parameters}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.util._
import freechips.rocketchip.tile._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.subsystem.{CacheBlockBytes}
import freechips.rocketchip.rocket.{ExpandedInstruction}
import freechips.rocketchip.rocket.InlineInstance

case class RefPredicTableParams(
  nSets: Int = 32,
  nStrideBit: Int = 16
) 

class StrideDetector(params:RefPredicTableParams)(implicit p: Parameters) extends CoreModule()(p) {
  val io = IO(new Bundle {
    val snoop     = Input(Valid(new StrideMonitor)) // snoop the pc and addr
    val stride    = Output(UInt(params.nStrideBit.W)) // stride
    val stride_pc = Output(UInt(vaddrBitsExtended.W))
    val detected  = Output(Bool()) // stride detected
    val flush     = Output(Bool()) // flush taint tracker
  })

  val idSz = log2Ceil(params.nSets)

  val rpt = Module(new RefPredicTable(params.nSets, params.nStrideBit))
  rpt.io.pc := io.snoop.bits.pc
  rpt.io.addr.bits := io.snoop.bits.addr
  rpt.io.addr.valid := io.snoop.valid
  rpt.io.read := io.snoop.bits.read
  rpt.io.s1_kill := io.snoop.bits.kill
  
  val stride = rpt.io.stride.bits
  val stride_valid = rpt.io.stride.valid

  val idx = io.snoop.bits.pc(idSz-1,0)
  val s1_pc = RegNext(io.snoop.bits.pc)

  val s_idle :: s_discover :: Nil = Enum(2)
  val state = RegInit(s_idle)


  val stride_pc_record = RegEnable(s1_pc, 0.U(vaddrBitsExtended.W), stride_valid & state === s_idle)

  val detected = state === s_discover

  // timeout is used to detect the stride is not valid
  val (timer, timeout) = Counter(0 until 256, detected, state === s_idle)

  val stride_again = s1_pc === stride_pc_record
  val quit_discover = timeout || stride_again

  // if this stride in discover has seen
  val SeenBit = RegInit(0.U(params.nSets.W))
  
  val seen = Mux(detected && stride_valid, SeenBit(idx), false.B)

  when(detected && stride_valid && !seen) {
    SeenBit := UIntToOH(idx) | SeenBit
  }.elsewhen(!detected || seen) {
    SeenBit := 0.U
  }

  when(stride_valid && state === s_idle) {
    state := s_discover
  }

  when(state === s_discover && quit_discover) {
    state := s_idle
  }

  io.flush     := seen
  io.stride    := RegEnable(stride, stride_valid)
  io.stride_pc := stride_pc_record
  io.detected  := detected
}