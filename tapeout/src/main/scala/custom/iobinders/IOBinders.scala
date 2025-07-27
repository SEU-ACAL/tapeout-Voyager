package voyager_tapeout.custom.iobinders

import chisel3._
import chisel3.reflect.DataMirror
import chisel3.experimental.Analog

import org.chipsalliance.cde.config._
import org.chipsalliance.diplomacy._
import org.chipsalliance.diplomacy.nodes._
import org.chipsalliance.diplomacy.aop._
import org.chipsalliance.diplomacy.lazymodule._
import org.chipsalliance.diplomacy.bundlebridge._
import freechips.rocketchip.diplomacy.{Resource, ResourceBinding, ResourceAddress}
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.jtag.{JTAGIO}
import freechips.rocketchip.subsystem._
import freechips.rocketchip.system.{SimAXIMem}
import freechips.rocketchip.amba.axi4.{AXI4Bundle, AXI4SlaveNode, AXI4MasterNode, AXI4EdgeParameters}
import freechips.rocketchip.util._
import freechips.rocketchip.prci._
import freechips.rocketchip.groundtest.{GroundTestSubsystemModuleImp, GroundTestSubsystem}
import freechips.rocketchip.tilelink.{TLBundle}

import sifive.blocks.devices.gpio._
import sifive.blocks.devices.uart._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.i2c._
import tracegen.{TraceGenSystemModuleImp}

import chipyard.iocell._
import chipyard.iobinders.SPIPort
import testchipip.spi._

import voyager_tapeout.custom.device.peripheral_npu.{CanHavePeripheryNPU, PeripheralNPUIOCell}
import chipyard.iobinders.IOCellKey

import scala.reflect.{ClassTag}

// Use chipyard's IOBinder infrastructure
import chipyard.iobinders.{OverrideIOBinder}
import chipyard.iobinders.IOBinderTypes.IOBinderTuple
import chipyard.iobinders.SPIFlashPort

// Import our custom Port types
import voyager_tapeout.custom.iobinders.{PeripheralNPUPort}

class WithPeripheralNPUIOCell extends OverrideIOBinder({
  (system: CanHavePeripheryNPU) => {
    system.NpuChipTopIO.map({ p =>
      val sys = system.asInstanceOf[BaseSubsystem]
      val (port, cells) = IOCell.generateIOFromSignal(p.getWrappedValue, "peripheralNpuIOCellPin", sys.p(IOCellKey), abstractResetAsAsync = true)
      
      // Input pins: from IOCell (external) to NPU peripheral (internal)
      p.getWrappedValue.npu_clk_FPGA_w         := port.npu_clk_FPGA_w         
      p.getWrappedValue.npu_clk_FPGA_cim       := port.npu_clk_FPGA_cim       
      p.getWrappedValue.npu_rstn_FPGA          := port.npu_rstn_FPGA          
      p.getWrappedValue.npu_PLL_CLK_SEL        := port.npu_PLL_CLK_SEL        
      p.getWrappedValue.npu_TEST_MODE	         := port.npu_TEST_MODE	         
      p.getWrappedValue.npu_FPGA_sys_load_en   := port.npu_FPGA_sys_load_en   
      p.getWrappedValue.npu_FPGA_sys_load_addr := port.npu_FPGA_sys_load_addr 
      p.getWrappedValue.npu_FPGA_sys_store_en  := port.npu_FPGA_sys_store_en  
      p.getWrappedValue.npu_FPGA_sys_store_addr:= port.npu_FPGA_sys_store_addr
      p.getWrappedValue.npu_FPGA_sys_store_data:= port.npu_FPGA_sys_store_data
      p.getWrappedValue.npu_clk_PLL_w          := port.npu_clk_PLL_w          
      p.getWrappedValue.npu_clk_PLL_cim        := port.npu_clk_PLL_cim        

      // Output pins: from NPU peripheral (internal) to IOCell (external)
      port.npu_FPGA_sys_load_data_vld      := p.getWrappedValue.npu_FPGA_sys_load_data_vld 
      port.npu_FPGA_sys_load_data          := p.getWrappedValue.npu_FPGA_sys_load_data     
      (Seq(PeripheralNPUPort(() => port)), cells)
    }).getOrElse((Nil, Nil))
  }
})

class WithSPISDIOCells extends OverrideIOBinder({
  (system: HasPeripherySPI) => {
    val (ports:Seq[SPIChipPort], cells2d) = system.spi.zipWithIndex.map { case (s, i) =>
      val p = system.asInstanceOf[BaseSubsystem].p
      val name = s"spi_${i}"
      // 生成顶层 IO, port 是连接到chiptop的
      val port = IO(new SPIChipIO(s.c.csWidth)).suggestName(name)
      val iocellBase = s"iocell_${name}"


      // SCK 和 CS 是单向输出
      val sckIOs = IOCell.generateFromSignal(s.sck, port.sck, Some(s"${iocellBase}_sck"), p(IOCellKey), IOCell.toAsyncReset)
      val csIOs = IOCell.generateFromSignal(s.cs, port.cs, Some(s"${iocellBase}_cs"), p(IOCellKey), IOCell.toAsyncReset)
      

      // DQ 是双向,s是digitaltop
      val dqIOs = s.dq.zip(port.dq).zipWithIndex.map { case ((pin, ana), j) =>
        val iocell = p(IOCellKey).gpio().suggestName(s"${iocellBase}_dq_${j}")
        iocell.io.o := pin.o
        iocell.io.oe := pin.oe
        iocell.io.ie := true.B
        pin.i := iocell.io.i
        iocell.io.pad <> ana
        iocell
      }

      (SPIChipPort(() => port), dqIOs ++ csIOs ++ sckIOs)
    }.unzip
    (ports, cells2d.flatten)
  }
})

// class WithSPIFlashIOCells extends OverrideIOBinder({
//   (system: HasPeripherySPIFlash) => {
//     val (ports: Seq[SPIFlashPort], cells2d) = system.qspi.zipWithIndex.map({ case (s, i) =>
//       val p = system.asInstanceOf[BaseSubsystem].p
//       val name = s"spiflash_${i}"
//       val port = IO(new SPIFlashIO()).suggestName(name)
//       val iocellBase = s"iocell_${name}"

//       // SCK and CS are unidirectional outputs
//       val sckIOs = IOCell.generateFromSignal(s.sck, port.sck, Some(s"${iocellBase}_sck"), p(IOCellKey), IOCell.toAsyncReset)
//       val csIOs = IOCell.generateFromSignal(s.cs, port.cs, Some(s"${iocellBase}_cs"), p(IOCellKey), IOCell.toAsyncReset)

//       // DQ are bidirectional, so then need special treatment
//       val dqIOs = s.dq.zip(port.dq).zipWithIndex.map { case ((pin, ana), j) =>
//         val iocell = p(IOCellKey).gpio().suggestName(s"${iocellBase}_dq_${j}")
//         iocell.io.o := pin.o
//         iocell.io.oe := pin.oe
//         iocell.io.ie := true.B
//         pin.i := iocell.io.i
//         iocell.io.pad <> ana
//         iocell
//       }

//       // Drive the reset signal for SPIFlashIO
//       port.reset := false.B

//       (SPIFlashPort(() => port), dqIOs ++ csIOs ++ sckIOs)
//     }).unzip
//     (ports, cells2d.flatten)
//   }
// })


class WithSPIFlashIOCells extends OverrideIOBinder({
  (system: HasPeripherySPIFlash) => {
    val (ports: Seq[SPIFlashPort], cells2d) = system.qspi.zipWithIndex.map({ case (s, i) =>
      val p = system.asInstanceOf[BaseSubsystem].p
      val name = s"spi_flash_${i}"
      val port = IO(new SPIChipIO(s.c.csWidth)).suggestName(name)
      val iocellBase = s"iocell_${name}"

      // SCK and CS are unidirectional outputs
      val sckIOs = IOCell.generateFromSignal(s.sck, port.sck, Some(s"${iocellBase}_sck"), p(IOCellKey), IOCell.toAsyncReset)
      val csIOs = IOCell.generateFromSignal(s.cs, port.cs, Some(s"${iocellBase}_cs"), p(IOCellKey), IOCell.toAsyncReset)

      // DQ are bidirectional, so then need special treatment
      val dqIOs = s.dq.zip(port.dq).zipWithIndex.map { case ((pin, ana), j) =>
        val iocell = p(IOCellKey).gpio().suggestName(s"${iocellBase}_dq_${j}")
        iocell.io.o := pin.o
        iocell.io.oe := pin.oe
        iocell.io.ie := true.B
        pin.i := iocell.io.i
        iocell.io.pad <> ana
        iocell
      }

      (SPIFlashPort(() => port, p(PeripherySPIFlashKey)(i), i), dqIOs ++ csIOs ++ sckIOs)
    }).unzip
    (ports, cells2d.flatten)
  }
})
