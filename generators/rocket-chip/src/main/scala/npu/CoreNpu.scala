package freechips.rocketchip.npu

import Chisel._

import org.chipsalliance.cde.config._
import freechips.rocketchip.rocket._
import freechips.rocketchip.util._
import freechips.rocketchip.tile._

trait HasCoreNpuIO extends HasTileParameters {
  implicit val p: Parameters
  val io = new CoreBundle()(p) {
    val hartid = UInt(hartIdLen.W).asInput
    val reset_vector = UInt(resetVectorLen.W).asInput
    val interrupts = new CoreInterrupts().asInput
    val imem  = new FrontendIO
    val dmem = new HellaCacheIO
    val ptw = new DatapathPTWIO().flip
    val fpu = new FPUCoreIO().flip
    val rocc = new RoCCNpuCoreIO().flip
    val trace = Vec(coreParams.retireWidth, new TracedInstruction).asOutput
    val bpwatch = Vec(coreParams.nBreakpoints, new BPWatch(coreParams.retireWidth)).asOutput
    val cease = Bool().asOutput
    val wfi = Bool().asOutput
    val traceStall = Bool().asInput

    val you = Bool().asOutput
  }
}
