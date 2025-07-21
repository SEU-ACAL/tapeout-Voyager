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
import chisel3.experimental.Analog
class VoyagerClockSourceIO extends Bundle {
  val clk0 = Input(Clock())
  val power = Input(Bool())
  val gate = Input(Bool())
  val clk = Output(Clock())
  val lock = Output(Bool()) // PLL lock status
  val VSSA = Analog(1.W)
  val VDDP = Analog(1.W)
  val VDDB = Analog(1.W)
  val VDDA = Analog(1.W)
}


class PLL extends BlackBox
    with HasBlackBoxResource {
  val io = IO(new VoyagerClockSourceIO)

  override def desiredName = s"PLL"
  /* 
    I_PLL_PD = 1'b1;
    I_PLL_FRPD = 1'b1;
    I_PLL_VCO_OUT_PD = 1'b1;
    I_PLL_CLKDIVPD = 1'b1;
    I_PLL_CLKPHASEPD = 1'b1;
    I_PLL_BYPASS_CLKDIVPD = 1'b0;	// divided down from VCO
    I_PLL_V2I_PD = 1'b1;
    PD类似于power
    //2g VCO 100MHZ input
    I_PLL_REFDIV = 6'b000100;
    I_PLL_FBDIV_INT = 12'b10_1000;
    I_PLL_FBDIV_FRA = 24'h00_0000;
    TODO：PLL的输出是否需要缓冲，接pad？
  */
  addResource("PLL.v")
  addResource("PLL6GS28.v")
  addResource("phy_defines.v")
  // setInline(s"$desiredName.v",
  //   s"""
  //     |module $desiredName (
  //     |    input clk0,
  //     |    input power,
  //     |    inout VSSA,
  //     |    inout VDDP,
  //     |    inout VDDB,
  //     |    inout VDDA, 
  //     |    input gate,
  //     |    output clk);
  //     |
  //     |   //PLL6GS28		PLL6GS28(
  //     |   // .VSSA							(VSSA),
  //     |   // .VDDP							(VDDP),
  //     |   // .VDDB							(VDDB),
  //     |   // .VDDA							(VDDA),
  //     |   // .I_PLL_BYPASS_CLKDIVPD         	(1'b0                          ),
  //     |   // .I_PLL_CKREF                   	(clk0                          ),
  //     |   // .I_PLL_CLKDIV1                 	('b1                           ),
  //     |   // .I_PLL_CLKDIV2                 	('b1                           ),
  //     |   // .I_PLL_CLKDIVPD                	(1'b0                          ),
  //     |   // .I_PLL_CLKPHASEPD              	(1'b0                          ),
  //     |   // .I_PLL_FBDIV_FRA               	(24'h00_0000                   ),
  //     |   // .I_PLL_FBDIV_INT               	(12'b10_1000                   ),
  //     |   // .I_PLL_PD                      	(!power                        ),
  //     |   // .I_PLL_REFDIV                  	(6'b000100                     ),
  //     |   // .I_PLL_V2I_PD                  	(1'b0                          ),
  //     |   // .I_PLL_FRPD                    	(1'b0                          ),
  //     |   // .I_PLL_VCO_OUT_PD              	(1'b0                          ),
  //     |   // .O_PLL_CLK2                    	(                              ),
  //     |   // .O_PLL_CLK3                    	(                              ),
  //     |   // .O_PLL_CLK4                    	(                              ),
  //     |   // .O_PLL_CLK5                    	(                              ),
  //     |   // .O_PLL_CLKDIV                  	(                              ),
  //     |   // .O_PLL_CLKN                    	(                              ),
  //     |   // .O_PLL_CLKP                    	(                              ),
  //     |   // .O_PLL_CLKSSC                  	(                              ),
  //     |   // .O_PLL_CLK_IN                  	(                              ),
  //     |   // .O_PLL_CLK_IP                  	(                              ),
  //     |   // .O_PLL_CLK_QN                  	(                              ),
  //     |   // .O_PLL_CLK_QP                  	(                              ),
  //     |   // .O_PLL_LOCK                    	(                              ),
  //     |   // .O_PLL_VCO_OUT_CLK             	(clk)
  //     |   //);
  //     |   assign clk = clk0;
  //     |endmodule
  //     |""".stripMargin)



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
    val pllCtrlSource = BundleBridgeSource[FakePLLCtrlInBundle]()
    pllCtrlSink := pllCtrl.ctrlNode
    pllCtrl.ctrlInNode := pllCtrlSource

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
      val fake_pll = Module(new PLL())
      fake_pll.io.power := pllCtrlSink.in(0)._1.power
      fake_pll.io.gate := pllCtrlSink.in(0)._1.gate
      fake_pll.io.clk0  := clock_wire
      pllCtrlSource.out(0)._1.lock := fake_pll.io.lock // Connect PLL lock status to the output
      // 创建 PLL 电源引脚的顶层 IO（不通过 IOCell）
      val vssa_io = IO(Analog(1.W)).suggestName("PLL_VSSA")
      val vddp_io = IO(Analog(1.W)).suggestName("PLL_VDDP")
      val vddb_io = IO(Analog(1.W)).suggestName("PLL_VDDB")
      val vdda_io = IO(Analog(1.W)).suggestName("PLL_VDDA")
      
      // 直接连接 PLL 到顶层 IO
      fake_pll.io.VSSA <> vssa_io
      fake_pll.io.VDDP <> vddp_io
      fake_pll.io.VDDB <> vddb_io
      fake_pll.io.VDDA <> vdda_io
      
      pllClockSource.out.unzip._1.map { o =>
        o.clock := fake_pll.io.clk
        o.reset := reset_wire
      }

      (Seq(ClockPort(() => clock_io, 100), ResetPort(() => reset_io), PLLPort(() => vssa_io), PLLPort(() => vddp_io), PLLPort(() => vddb_io), PLLPort(() => vdda_io)), clockIOCell ++ resetIOCell)
    }
  }
})

