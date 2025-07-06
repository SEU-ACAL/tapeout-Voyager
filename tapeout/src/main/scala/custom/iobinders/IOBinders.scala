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

import voyager_tapeout.custom.device.peripheral_npu.{CanHavePeripheryNPU, PeripheralNPUIOCell}
import chipyard.iobinders.IOCellKey

import scala.reflect.{ClassTag}

// Use chipyard's IOBinder infrastructure
import chipyard.iobinders.{OverrideIOBinder}
import chipyard.iobinders.IOBinderTypes.IOBinderTuple

// Import our custom Port types
import voyager_tapeout.custom.iobinders.{PeripheralNPUPort}

class WithPeripheralNPUIOCell extends OverrideIOBinder({
  (system: CanHavePeripheryNPU) => {
    system.NpuChipTopIO.map({ p =>
      val sys = system.asInstanceOf[BaseSubsystem]
      val (port, cells) = IOCell.generateIOFromSignal(p.getWrappedValue, "peripheralNpuIOCellPin", sys.p(IOCellKey), abstractResetAsAsync = true)
      
      // Input pins: from IOCell (external) to NPU peripheral (internal)
      p.getWrappedValue.npu_pin1 := port.npu_pin1  
      p.getWrappedValue.npu_pin3 := port.npu_pin3
      
      // Output pins: from NPU peripheral (internal) to IOCell (external)
      port.npu_pin2 := p.getWrappedValue.npu_pin2
      port.npu_pin4 := p.getWrappedValue.npu_pin4
      
      (Seq(PeripheralNPUPort(() => port)), cells)
    }).getOrElse((Nil, Nil))
  }
})
