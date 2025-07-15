package voyager_tapeout.custom.fpga

import chisel3._
import chisel3.experimental.{BaseModule}

import org.chipsalliance.diplomacy.nodes.{HeterogeneousBag}
import freechips.rocketchip.tilelink.{TLBundle}
import freechips.rocketchip.diplomacy._

import sifive.blocks.devices.uart.{UARTPortIO}
import sifive.blocks.devices.spi.{HasPeripherySPI, SPIPortIO}

import chipyard._
import chipyard.harness._
import chipyard.iobinders._
import voyager_tapeout.custom.fpga.VCU118FPGATestHarnessImp
import voyager_tapeout.custom.fpga.Serial
import testchipip.serdes._
import voyager_tapeout.custom.iobinders.{SPIChipPort}

/*** UART ***/
class WithUART extends HarnessBinder({
  case (th: VCU118FPGATestHarnessImp, port: UARTPort, chipId: Int) => {
    th.vcu118Outer.io_uart_bb.bundle <> port.io
  }
})


/*** Experimental DDR ***/
class WithDDRMem extends HarnessBinder({
  case (th: VCU118FPGATestHarnessImp, port: TLMemPort, chipId: Int) => {
    val bundles = th.vcu118Outer.ddrClient.out.map(_._1)
    val ddrClientBundle = Wire(new HeterogeneousBag(bundles.map(_.cloneType)))
    bundles.zip(ddrClientBundle).foreach { case (bundle, io) => bundle <> io }
    ddrClientBundle <> port.io
  }
})

class WithJTAG extends HarnessBinder({
  case (th: VCU118FPGATestHarnessImp, port: JTAGPort, chipId: Int) => {
    val jtag_io = th.vcu118Outer.jtagPlacedOverlay.overlayOutput.jtag.getWrappedValue
    port.io.TCK := jtag_io.TCK
    port.io.TMS := jtag_io.TMS
    port.io.TDI := jtag_io.TDI
    jtag_io.TDO.data := port.io.TDO
    jtag_io.TDO.driven := true.B
    // ignore srst_n
    jtag_io.srst_n := DontCare

  }
})

class WithGPIO extends HarnessBinder({
  case (th: VCU118FPGATestHarnessImp, port: GPIOPort, chipId: Int) => {

      th.gpio_pins(port.pinId) <> port.io
  }
})

class WithChipSPI extends HarnessBinder({
  case (th: VCU118FPGATestHarnessImp, port: SPIChipPort, chipId: Int) => {
    th.spi_pins <> port.io
  }
})

/** TLSerdes */
class WithSerialTL2DDR extends HarnessBinder({
  case (th: VCU118FPGATestHarnessImp, port: SerialTLPort, chipId: Int) => {
    // 获取DDR客户端接口
    val bundles = th.vcu118Outer.ddrClient.out.map(_._1)
    
    // 创建Serial模块
    val serial = LazyModule(new Serial(port.serdesser, port.params)(port.serdesser.p))
    // 创建DDR客户端连接
    val ddrClientBundle = Wire(new HeterogeneousBag(bundles.map(_.cloneType)))
    bundles.zip(ddrClientBundle).foreach { case (bundle, io) => bundle <> io }
    // 实例化模块
    val serialModule = withClockAndReset(th.fpgaClock, th.fpgaResetSigned) {Module(serial.module)}
    // 连接SerialTL接口
    port.io match {
      case io: DecoupledFlitIO => {
        val clock = port.io match {
          case io: InternalSyncPhitIO => io.clock_out
          case io: ExternalSyncPhitIO => th.harnessBinderClock
        }
        withClock(clock) {
          serialModule.io.ser.in <> io.out
          serialModule.io.ser.out <> io.in
          serialModule.io.tl.foreach { tlIO =>
            try {
              ddrClientBundle <> tlIO
            } catch {
              case e: Exception => 
                println(s"连接错误: ${e.getMessage}")
                e.printStackTrace()
            }
          }
        }
      }
      case io: ExternalSyncPhitIO => {
          // 系统输入的时钟Jk
          io.clock_in := th.fpgaClock
          serialModule.io.ser.in <> io.out
          serialModule.io.ser.out <> io.in
          serialModule.io.tl.foreach { tlIO =>
            try {
              tlIO <> ddrClientBundle(0)
            } catch {
              case e: Exception => 
                println(s"连接错误: ${e.getMessage}")
                e.printStackTrace()
            }
          }
      }
      case other => {
        throw new Exception(s"Unsupported SerialTL IO type: ${other.getClass}")
      }
    }
  }
})
