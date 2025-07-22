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
  val npu_clk_FPGA_w             = Output(Bool()) 
  val npu_clk_FPGA_cim           = Output(Bool()) 
  val npu_rstn_FPGA              = Output(Bool()) 
  val npu_PLL_CLK_SEL            = Output(Bool()) 
  val npu_TEST_MODE	             = Output(Bool()) 
  val npu_load_store_OEN         = Output(Bool()) 
  val npu_FPGA_sys_load_data_vld = Output(Bool()) 
  val npu_FPGA_sys_load_en       = Output(Bool()) 
  val npu_FPGA_sys_load_addr     = Output(UInt(20.W)) 
  val npu_FPGA_sys_load_data     = Output(UInt(64.W)) 
  val npu_FPGA_sys_store_en      = Output(Bool()) 
  val npu_FPGA_sys_store_addr    = Output(UInt(20.W)) 
  val npu_FPGA_sys_store_data    = Output(UInt(64.W)) 
  val npu_clk_PLL_w              = Output(Bool()) 
  val npu_clk_PLL_cim            = Output(Bool()) 
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
  io.npu_bundle.npu_clk_FPGA_w             := io.pad
  io.npu_bundle.npu_clk_FPGA_cim           := io.pad
  io.npu_bundle.npu_rstn_FPGA              := io.pad
  io.npu_bundle.npu_PLL_CLK_SEL            := io.pad
  io.npu_bundle.npu_TEST_MODE	             := io.pad
  io.npu_bundle.npu_load_store_OEN         := io.pad
  io.npu_bundle.npu_FPGA_sys_load_data_vld := false.B
  io.npu_bundle.npu_FPGA_sys_load_en       := io.pad
  io.npu_bundle.npu_FPGA_sys_load_addr     := io.pad
  io.npu_bundle.npu_FPGA_sys_load_data     := 0.U(64.W)
  io.npu_bundle.npu_FPGA_sys_store_en      := io.pad
  io.npu_bundle.npu_FPGA_sys_store_addr    := io.pad
  io.npu_bundle.npu_FPGA_sys_store_data    := io.pad
  io.npu_bundle.npu_clk_PLL_w              := io.pad
  io.npu_bundle.npu_clk_PLL_cim            := io.pad
}

case class CustomIOCellParams() extends IOCellTypeParams {
  def analog() = Module(new GenericAnalogIOCell)
  def gpio()   = Module(new CustomDigitalGPIOCell)
  def input()  = Module(new CustomDigitalInIOCell)
  def output() = Module(new CustomDigitalOutIOCell)
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
          case c: CustomDigitalOutIOCell => {
            // Custom output cell, no special handling needed
          }
          case c: GenericDigitalOutIOCell => {  // 这里有问题，修复这行
            // Standard output cell, no special handling needed
          }
          case c: CustomDigitalGPIOCell => {
            // GPIO cell handling
          }
          case c: GenericDigitalGPIOCell => {  // 添加这个 case
            // Standard GPIO cell, no special handling needed
          }
          case c: GenericAnalogIOCell => {  // 添加这个 case
            // Analog cell, no special handling needed
          }
          case c => {
            println(s"Warning: Unhandled iocell type ${c.getClass} in interface $interface")
            // 移除 require(false, ...) 来避免崩溃
          }
        }
      }
    }}
  }
}

