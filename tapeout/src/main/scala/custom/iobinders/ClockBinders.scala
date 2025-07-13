package voyager_tapeout.custom.iobinders

import chisel3._
import chisel3.util._
import chipyard.iobinders._
import freechips.rocketchip.prci._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.tilelink._
import chipyard.iocell._
import chipyard.clocking._

class VoyagerClockSourceIO extends Bundle {
  val clk0 = Input(Clock())
  val power = Input(Bool())
  val gate = Input(Bool())
  val clk = Output(Clock())
}


class VoyagerClockSourceAtFreqFromPlusArg(val plusArgName: String) extends BlackBox
    with HasBlackBoxInline {
  val io = IO(new VoyagerClockSourceIO)

  override def desiredName = s"ClockSourceAtFreqFromPlusArg$plusArgName"

  setInline(s"$desiredName.v",
    s"""
      |module $desiredName (
      |    input clk0,
      |    input power,
      |    input gate,
      |    output clk);
      |    assign clk = clk0;
      |endmodule
      |""".stripMargin)
}


// simulators (Verilator) which do not model reset properly
class WithVoyagerPLLSelectorDividerClockGenerator(enable: Boolean = true) extends OverrideLazyIOBinder({
  (system: HasChipyardPRCI) => {
    // Connect the implicit clock
    implicit val p = GetSystemParameters(system)
    val tlbus = system.asInstanceOf[BaseSubsystem].locateTLBusWrapper(system.prciParams.slaveWhere)
    val baseAddress = system.prciParams.baseAddress
    val clockDivider  = system.prci_ctrl_domain { LazyModule(new TLClockDivider (baseAddress + 0x20000, tlbus.beatBytes, enable=enable)) }
    val clockSelector = system.prci_ctrl_domain { LazyModule(new TLClockSelector(baseAddress + 0x30000, tlbus.beatBytes, enable=enable)) }
    val pllCtrl       = system.prci_ctrl_domain { LazyModule(new FakePLLCtrl    (baseAddress + 0x40000, tlbus.beatBytes)) }

    clockDivider.tlNode  := system.prci_ctrl_domain { TLFragmenter(tlbus, Some("ClockDivider")) := system.prci_ctrl_bus.get }
    clockSelector.tlNode := system.prci_ctrl_domain { TLFragmenter(tlbus, Some("ClockSelector")) := system.prci_ctrl_bus.get }
    pllCtrl.tlNode       := system.prci_ctrl_domain { TLFragmenter(tlbus, Some("PLLCtrl")) := system.prci_ctrl_bus.get }

    system.chiptopClockGroupsNode := clockDivider.clockNode := clockSelector.clockNode

    // Connect all other requested clocks
    val slowClockSource = ClockSourceNode(Seq(ClockSourceParameters()))
    val pllClockSource = ClockSourceNode(Seq(ClockSourceParameters()))

    // The order of the connections to clockSelector.clockNode configures the inputs
    // of the clockSelector's clockMux. Default to using the slowClockSource,
    // software should enable the PLL, then switch to the pllClockSource
    clockSelector.clockNode := slowClockSource
    clockSelector.clockNode := pllClockSource

    val pllCtrlSink = BundleBridgeSink[FakePLLCtrlBundle]()
    pllCtrlSink := pllCtrl.ctrlNode

    InModuleBody {
      val clock_wire = Wire(Input(Clock())) // 连接digitaltop
      val reset_wire = Wire(Input(AsyncReset()))
      val (clock_io, clockIOCell) = IOCell.generateIOFromSignal(clock_wire, "clock", p(IOCellKey))
      val (reset_io, resetIOCell) = IOCell.generateIOFromSignal(reset_wire, "reset", p(IOCellKey))

      slowClockSource.out.unzip._1.map { o =>
        o.clock := clock_wire
        o.reset := reset_wire
      }

      // For a real chip you should replace this ClockSourceAtFreqFromPlusArg
      // with a blackbox of whatever PLL is being integrated
      val fake_pll = Module(new VoyagerClockSourceAtFreqFromPlusArg("pll_freq_mhz"))
      fake_pll.io.power := pllCtrlSink.in(0)._1.power
      fake_pll.io.gate := pllCtrlSink.in(0)._1.gate
      fake_pll.io.clk0  := clock_wire

      pllClockSource.out.unzip._1.map { o =>
        o.clock := fake_pll.io.clk
        o.reset := reset_wire
      }

      (Seq(ClockPort(() => clock_io, 100), ResetPort(() => reset_io)), clockIOCell ++ resetIOCell)
    }
  }
})

