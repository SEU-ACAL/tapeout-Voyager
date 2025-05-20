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

case class VecRunaheadParams(

) extends CanInstantiatePrefetcher{
  def desc = "Indirect Memory Access Runahead base on Stride Prefetcher"
  def instantiate()(implicit p: Parameters) = Module(new VecRunahead(this)(p))
}

class VecRunahead(params: VecRunaheadParams)(implicit p: Parameters) extends AbstractPrefetcher()(p) {

  val StrideDetector = Module(new StrideDetector(RefPredicTableParams()))
  StrideDetector.io.snoop := io.stride
  val stride = StrideDetector.io.stride
  val stride_pc = StrideDetector.io.stride_pc
  val stride_detected = StrideDetector.io.detected
  val flush = StrideDetector.io.flush
  dontTouch(stride)
  dontTouch(stride_pc)
  dontTouch(stride_detected)
  dontTouch(flush)
}
