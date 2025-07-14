package voyager_tapeout.custom.fpga

import chisel3._
import chisel3.experimental.{Analog, attach}

import freechips.rocketchip.diplomacy.{LazyModule, LazyRawModuleImp, BundleBridgeSource}
import org.chipsalliance.cde.config.{Parameters}
import freechips.rocketchip.tilelink._
import freechips.rocketchip.diplomacy.{IdRange, TransferSizes}
import freechips.rocketchip.subsystem.{SystemBusKey}
import freechips.rocketchip.prci._
import sifive.fpgashells.shell.xilinx._
import sifive.fpgashells.ip.xilinx.{IBUF, PowerOnResetFPGAOnly}
import sifive.fpgashells.shell._
import sifive.fpgashells.clocks._

import sifive.blocks.devices.uart.{PeripheryUARTKey, UARTPortIO}
import sifive.blocks.devices.spi.{PeripherySPIKey, SPIPortIO}
import sifive.blocks.devices.gpio.{PeripheryGPIOKey, GPIOPortIO}
import chipyard._
import chipyard.harness._
import freechips.rocketchip.subsystem._
import voyager_tapeout.custom.fpga.shell._

class VCU118FPGATestHarness(override implicit val p: Parameters) extends FPGAShellBasicOverlays {

  def dp = designParameters

  val pmod_is_sdio  = p(VCU118ShellPMOD) == "SDIO"
  val jtag_location = Some(if (pmod_is_sdio) "FMC_J2" else "PMOD_J52")

  // Order matters; ddr depends on sys_clock
  val uart      = Overlay(UARTOverlayKey, new UARTVCU118ShellPlacer(this, UARTShellInput()))
  // val sdio      = if (pmod_is_sdio) Some(Overlay(SPIOverlayKey, new SDIOVCU118ShellPlacer(this, SPIShellInput()))) else None
  val jtag      = Overlay(JTAGDebugOverlayKey, new JTAGDebugVCU118ShellPlacer(this, JTAGDebugShellInput(location = jtag_location)))

// DOC include start: ClockOverlay
  // place all clocks in the shell
  require(dp(ClockInputOverlayKey).size >= 2)  // 现在需要至少2个时钟
  val sysClkNode = dp(ClockInputOverlayKey)(0).place(ClockInputDesignInput()).overlayOutput.node
  val fpgaClkNode = dp(ClockInputOverlayKey)(1).place(ClockInputDesignInput()).overlayOutput.node  // 新增ChipTop时钟节点

  /*** Connect/Generate clocks ***/

  // connect to the PLL that will generate multiple clocks
  val harnessSysPLL = dp(PLLFactoryKey)()
  harnessSysPLL := sysClkNode

  // create and connect to the dutClock (用于harness)
  val dutFreqMHz = (dp(SystemBusKey).dtsFrequency.get / (1000 * 1000)).toInt
  // chiptop的时钟
  val dutClock = ClockSinkNode(freqMHz = dutFreqMHz)
  val dutWrangler = LazyModule(new ResetWrangler)
  val dutGroup = ClockGroup()
  dutClock := dutWrangler.node := dutGroup := harnessSysPLL

  // 创建ChipTop专用时钟 (100MHz独立时钟)
  val fpgaFreqMHz = 100  // ChipTop使用100MHz时钟
  val fpgaClock = ClockSinkNode(freqMHz = fpgaFreqMHz)
  println(s"VCU118 FPGA Clock Freq: ${fpgaFreqMHz} MHz")
  val fpgaWrangler = LazyModule(new ResetWrangler)
  val fpgaGroup = ClockGroup()
  
  // 创建独立的PLL用于ChipTop时钟
  val fpgaPLL = dp(PLLFactoryKey)()
  fpgaPLL := fpgaClkNode  // 连接到独立的100MHz时钟源
  fpgaClock := fpgaWrangler.node := fpgaGroup := fpgaPLL
// DOC include end: ClockOverlay


  /*** GPIO ***/

  // val io_gpio_bb = BundleBridgeSource(() => (new GPIOPortIO(dp(PeripheryGPIOKey).head)))
  // dp(GPIOOverlayKey).head.place(GPIODesignInput(dp(PeripheryGPIOKey).head, io_gpio_bb))
  /*** UART ***/

// DOC include start: UartOverlay
  // 1st UART goes to the VCU118 dedicated UART

  val io_uart_bb = BundleBridgeSource(() => (new UARTPortIO(dp(PeripheryUARTKey).head)))
  dp(UARTOverlayKey).head.place(UARTDesignInput(io_uart_bb))
// DOC include end: UartOverlay

  /*** SPI ***/
  // 1st SPI goes to the VCU118 SDIO port

  val io_spi_bb = BundleBridgeSource(() => (new SPIPortIO(dp(PeripherySPIKey).head)))
  dp(SPIOverlayKey).head.place(SPIDesignInput(dp(PeripherySPIKey).head, io_spi_bb))

  /*** DDR ***/
  val ddrNode = dp(DDROverlayKey)(1).place(DDRDesignInput(dp(ExtSerialMem).get.master.base, fpgaWrangler.node, fpgaPLL)).overlayOutput.ddr


  // connect 1 mem. channel to the FPGA DDR
  val ddrClient = TLClientNode(Seq(TLMasterPortParameters.v1(Seq(TLMasterParameters.v1(
    name = "chip_ddr",
    sourceId = IdRange(0, 1 << dp(ExtSerialMem).get.master.idBits)
  )))))
  ddrNode := TLWidthWidget(dp(ExtSerialMem).get.master.beatBytes) := ddrClient

  /*** JTAG ***/
  val jtagPlacedOverlay = dp(JTAGDebugOverlayKey).head.place(JTAGDebugDesignInput())

  // module implementation
  override lazy val module = new VCU118FPGATestHarnessImp(this)
}

class VCU118FPGATestHarnessImp(_outer: VCU118FPGATestHarness) extends LazyRawModuleImp(_outer) with HasHarnessInstantiators {
  override def provideImplicitClockToLazyChildren = true
  val vcu118Outer = _outer

  val reset = IO(Input(Bool())).suggestName("reset")
  _outer.xdc.addPackagePin(reset, "L19")
  _outer.xdc.addIOStandard(reset, "LVCMOS12")

  val gpiowidth = _outer.dp(PeripheryGPIOKey).head.width 
  val gpio_pins = IO(Vec(gpiowidth,Analog(1.W))).suggestName("gpio_pins")
  gpio_pins.zipWithIndex.foreach { case (pin, i) =>
    val ioPin = IOPin(pin)
    _outer.xdc.addPackagePin(ioPin, s"D$i")
    _outer.xdc.addIOStandard(ioPin, "LVCMOS12")
  }



  val resetIBUF = Module(new IBUF)
  resetIBUF.io.I := reset

  val sysclk: Clock = _outer.sysClkNode.out.head._1.clock

  val powerOnReset: Bool = PowerOnResetFPGAOnly(sysclk)
  _outer.sdc.addAsyncPath(Seq(powerOnReset))

  val ereset: Bool = _outer.chiplink.get() match {
    case Some(x: ChipLinkVCU118PlacedOverlay) => !x.ereset_n
    case _ => false.B
  }

  _outer.pllReset := (resetIBUF.io.O || powerOnReset || ereset)

  // reset setup
  val hReset = Wire(Reset())
  hReset := _outer.dutClock.in.head._1.reset
  
  // ChipTop reset setup
  val fpgaReset = Wire(Reset())
  fpgaReset := _outer.fpgaClock.in.head._1.reset

  def referenceClockFreqMHz = _outer.dutFreqMHz
  def referenceClock = _outer.dutClock.in.head._1.clock
  def referenceReset = hReset
  def success = { require(false, "Unused"); false.B }
  
  // ChipTop时钟访问方法
  def fpgaFreqMHz = _outer.fpgaFreqMHz
  def fpgaClock = _outer.fpgaClock.in.head._1.clock
  def fpgaResetSigned = fpgaReset

  // 使用FPGAClock作为子模块的默认时钟，而不是referenceClock
  childClock := fpgaClock
  childReset := fpgaResetSigned

  instantiateChipTops()
}
