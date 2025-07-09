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
import testchipip.tsi._
import testchipip.serdes._

/*** UART ***/
class WithUART extends HarnessBinder({
  case (th: VCU118FPGATestHarnessImp, port: UARTPort, chipId: Int) => {
    th.vcu118Outer.io_uart_bb.bundle <> port.io
  }
})

/*** SPI ***/
class WithSPISDCard extends HarnessBinder({
  case (th: VCU118FPGATestHarnessImp, port: SPIPort, chipId: Int) => {
    th.vcu118Outer.io_spi_bb.bundle <> port.io
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

/** TLSerdes */
class WithVCU118SerialTL2DDR extends HarnessBinder({
  case (th: VCU118FPGATestHarnessImp, port: SerialTLPort, chipId: Int) => {
    // 获取DDR客户端接口
    val bundles = th.vcu118Outer.ddrClient.out.map(_._1)
    
    // 打印DDR客户端Bundle的详细信息
    println("=========== DDR Client Bundles 信息 ===========")
    println(s"DDR客户端bundle数量: ${bundles.length}")
    bundles.zipWithIndex.foreach { case (bundle, idx) =>
      println(s"Bundle[$idx] 类型: ${bundle.getClass}")
      println(s"Bundle[$idx] 参数: ${bundle.params}")
      println(s"Bundle[$idx] hasBCE: ${bundle.params.hasBCE}")
      println(s"Bundle[$idx] 可用通道: ${bundle.elements.keys.mkString(", ")}")
    }
    println("=============================================")

    // 创建Serial模块
    val serial = LazyModule(new Serial(port.serdesser, port.params)(port.serdesser.p))

    // 创建DDR客户端连接
    println("创建 ddrClientBundle...")
    val ddrClientBundle = Wire(new HeterogeneousBag(bundles.map(_.cloneType)))
    println(s"ddrClientBundle创建完成，类型: ${ddrClientBundle.getClass}")
    println(s"ddrClientBundle elements: ${ddrClientBundle.elements.keys.mkString(", ")}")


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
          
          // 直接连接TileLink到DDR客户端 - 打印更多调试信息
          serialModule.io.tl.foreach { tlIO =>
            println("=========== SerialTL TileLink 接口信息 ===========")
            println(s"TileLink bundle 类型: ${tlIO.getClass}")
            println(s"TileLink bundle 参数: ${tlIO.params}")
            println(s"TileLink bundle hasBCE: ${tlIO.params.hasBCE}")
            println(s"TileLink bundle 可用通道: ${tlIO.elements.keys.mkString(", ")}")
            println(s"DDR client bundle 类型: ${ddrClientBundle.getClass}")
            println("============================================")

            // 尝试连接并捕获可能的错误
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
          // serialModule.io.ser.viewAsSupertype(new DecoupledPhitIO(serialModule.ser.io.phitWidth)).out <> io.in
          // serialModule.io.ser.viewAsSupertype(new DecoupledPhitIO(serialModule.ser.io.phitWidth)).in <> io.out
          // 如果需要直接连接TileLink到DDR客户端
          serialModule.io.tl.foreach { tlIO =>
            println("=========== ExternalSyncPhitIO模式: SerialTL TileLink 接口信息 ===========")
            println(s"TileLink bundle 类型: ${tlIO.getClass}")
            println(s"TileLink bundle 参数: ${tlIO.params}")
            println(s"TileLink bundle hasBCE: ${tlIO.params.hasBCE}")
            println(s"TileLink bundle 可用通道: ${tlIO.elements.keys.mkString(", ")}")
            println("============================================")
            
            // 尝试连接并捕获可能的错误
            try {
              // println("通道连接完成")
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
