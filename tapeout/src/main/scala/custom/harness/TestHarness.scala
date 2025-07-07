package voyager_tapeout.custom.harness

import chisel3._
import chisel3.util._

import org.chipsalliance.cde.config.{Parameters, Config}

import chipyard.harness.{TestHarness, BuildTop}

import voyager_tapeout.custom.CustomChipTop

// import voyager_tapeout.custom.iobinders.IOCellKey
import chipyard.iobinders.IOCellKey
import voyager_tapeout.custom.CustomIOCellParams

class WithCustomIOCells extends Config((site, here, up) => {
  case IOCellKey => CustomIOCellParams()
})

class WithCustomChipTop extends Config((site, here, up) => {
  case BuildTop => (p: Parameters) => new CustomChipTop()(p)
})

// class WithCustomChipTop extends Config((site, here, up) => {
//   case BuildTop => (p: Parameters) => new CustomChipTop()(p)
// })

class CustomTestHarness(implicit val p: Parameters) extends Module with HasCustomHarnessInstantiators {
  val io = IO(new Bundle {
    val success = Output(Bool())
  })
  def success: Bool = io.success
  io.success := false.B

  override val supportsMultiChip = true

  // By default, the chipyard makefile sets the TestHarness implicit clock to be 1GHz
  // This clock shouldn't be used by this TestHarness however, as most users
  // will use the AbsoluteFreqHarnessClockInstantiator, which generates clocks
  // in verilog blackboxes
  def referenceClockFreqMHz = 1000.0
  def referenceClock = clock
  def referenceReset = reset

  val lazyDuts = instantiateChipTops()
}