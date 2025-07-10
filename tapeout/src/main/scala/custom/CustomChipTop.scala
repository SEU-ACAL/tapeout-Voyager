package voyager_tapeout.custom

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.{Config, Parameters}
import freechips.rocketchip.diplomacy.{InModuleBody}
import chipyard.ChipTop
import chipyard.BuildSystem
import chipyard.iobinders.HasIOBinders

import chipyard.iocell.IOCell
import chipyard.iocell.IOCellTypeParams
import chipyard.iocell.GenericDigitalGPIOCell
import chipyard.iocell.GenericDigitalOutIOCell
import chipyard.iocell.GenericDigitalInIOCell
import chipyard.iocell.DigitalInIOCellBundle
import chipyard.iocell.DigitalInIOCell
import chipyard.iocell.GenericIOCell
import chipyard.iocell.GenericAnalogIOCell

import voyager_tapeout.custom.device.peripheral_npu.PeripheralNPUIOCell

class WithCustomDigitalTop extends Config((site, here, up) => {
  case BuildSystem => (p: Parameters) => new CustomDigitalTop()(p)
})

// Custom NPU bundle for IOCell - all ports are outputs to avoid undriven inputs
class CustomNPUIOCellBundle extends Bundle {
  val npu_pin1 = Output(Bool())  // Drive NPU peripheral input port
  val npu_pin2 = Output(Bool())  // NPU peripheral output port (output in IOCell)
  val npu_pin3 = Output(Bool())  // Drive NPU peripheral input port
  val npu_pin4 = Output(Bool())  // NPU peripheral output port (output in IOCell)
}

// A custom IOCell with additional NPU I/O
class CustomDigitalInIOCellBundle extends DigitalInIOCellBundle {
  val npu_bundle = new CustomNPUIOCellBundle
}

// Using a custom digital in iocell instead of the default one
class CustomDigitalInIOCell extends RawModule with DigitalInIOCell {
  val io = IO(new CustomDigitalInIOCellBundle)
  // Connect required DigitalInIOCell io.i port
  io.i := io.pad
  // Connect NPU pins
  io.npu_bundle.npu_pin1 := io.pad    // Send signal from pad to NPU peripheral
  io.npu_bundle.npu_pin2 := false.B   // NPU peripheral output, default value here
  io.npu_bundle.npu_pin3 := io.pad    // Send signal from pad to NPU peripheral
  io.npu_bundle.npu_pin4 := false.B   // NPU peripheral output, default value here
}

case class CustomIOCellParams() extends IOCellTypeParams {
  def analog() = Module(new GenericAnalogIOCell)
  def gpio() = Module(new GenericDigitalGPIOCell)
  def input() = Module(new CustomDigitalInIOCell)
  def output() = Module(new GenericDigitalOutIOCell)
}

class CustomChipTop(implicit p: Parameters) extends ChipTop with HasIOBinders {
  // making the module name ChipTop instead of CustomChipTop means
  // we don't have to set the TOP make variable to CustomChipTop
  override lazy val desiredName = "ChipTop"

  // InModuleBody blocks are executed within the LazyModuleImp of this block
  InModuleBody {
    // Print IOCell summary for debugging
    println("IOCell Summary:")
    iocellMap.foreach { case (interface, cells) => {
      if (cells.nonEmpty) {
        val cellTypes = cells.map(_.getClass.getSimpleName).groupBy(identity).mapValues(_.size)
        println(s"  $interface: ${cellTypes.map { case (t, c) => s"$c×$t" }.mkString(", ")}")
      }
    }}
    
    iocellMap.foreach { case (interface, cells) => {
      cells.foreach { cell => 
        cell match {
          case c: CustomDigitalInIOCell => {
            // NPU pins are already connected to io.pad inside CustomDigitalInIOCell
          }
          case c: GenericDigitalInIOCell => {
            // Standard input cell, no special handling needed
          }
          case c: GenericDigitalOutIOCell => {
            // Standard output cell, no special handling needed
          }
          case c: GenericDigitalGPIOCell => {
            // c.io.i := false.B
          }
          case c => {
            require(false, s"Unsupported iocell type ${c.getClass} in interface $interface")
          }
        }
      }
    }}
  }
}

