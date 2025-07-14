package voyager_tapeout.custom.fpga.shell

import chisel3._
import chisel3.experimental.{Analog, attach}
import chisel3.experimental.dataview._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.prci._
import org.chipsalliance.cde.config._
import sifive.fpgashells.clocks._
import sifive.fpgashells.devices.xilinx.xdma._
import sifive.fpgashells.devices.xilinx.xilinxvcu118mig._
import sifive.fpgashells.ip.xilinx._
import sifive.fpgashells.ip.xilinx.xxv_ethernet._
import sifive.fpgashells.ip.xilinx.vcu118mig._
import sifive.fpgashells.shell._
import sifive.fpgashells.shell.xilinx._


abstract class FPGAShellBasicOverlays()(implicit p: Parameters) extends VCU118ShellBasicOverlays{
  // PLL reset causes
  val fpga_clock = Overlay(ClockInputOverlayKey, new FPGAClockFPGAShellPlacer(this, ClockInputShellInput()))
  val ddr1 = Overlay(DDROverlayKey, new DDRFPGAShellPlacer(this,DDRShellInput()))
  // val gpio = Overlay(GPIOOverlayKey, new GPIOXilinxPlacedOverlay(this, GPIOShellInput()))

}


// class GPIOFPGAPlacedOverlay(val shell: FPGAShellBasicOverlays, name: String, val designInput: GPIODesignInput, val shellInput: GPIOShellInput)
//   extends GPIOXilinxPlacedOverlay(name, designInput, shellInput) {
//     shell { InModuleBody {
//       val allgpioPins = Seq ("D15", "B14", "B12", "C13", "C15", "A13", "A14",
//       "A15", "A16", "B12", "C12", "B13")
//       (IOPin.of(io) zip allgpioPins) foreach { case (io, pin) => shell.xdc.addPackagePin(io, pin) }
//     }
//     }
// }

// class GPIOFPGAShellPlacer(shell: FPGAShellBasicOverlays, val shellInput: GPIOShellInput)(implicit val valName: ValName)
//   extends GPIOShellPlacer[FPGAShellBasicOverlays] {
//   def place(designInput: GPIODesignInput) = new GPIOFPGAPlacedOverlay(shell, valName.name, designInput, shellInput)
// }



class FPGAClockFPGAPlacedOverlay(val shell: FPGAShellBasicOverlays, name: String, val designInput: ClockInputDesignInput, val shellInput: ClockInputShellInput)
  extends LVDSClockInputXilinxPlacedOverlay(name, designInput, shellInput) {
  // 创建100MHz的ChipTop时钟节点
  val node = shell { ClockSourceNode(freqMHz = 100, jitterPS = 50)(ValName(name)) }

  shell { InModuleBody {
    // 使用GPIO引脚作为时钟输入 (可根据需要修改)
    shell.xdc.addPackagePin(io.p, "H13")  // GPIO引脚，可根据实际需要选择
    shell.xdc.addPackagePin(io.n, "G13")  // GPIO引脚，可根据实际需要选择
    shell.xdc.addIOStandard(io.p, "LVDS")
    shell.xdc.addIOStandard(io.n, "LVDS")
  } }
}

class FPGAClockFPGAShellPlacer(shell: FPGAShellBasicOverlays, val shellInput: ClockInputShellInput)(implicit val valName: ValName)
  extends ClockInputShellPlacer[FPGAShellBasicOverlays] {
  def place(designInput: ClockInputDesignInput) = new FPGAClockFPGAPlacedOverlay(shell, valName.name, designInput, shellInput)
}

case object FPGADDRSize extends Field[BigInt](0x40000000L * 2) // 2GB
class DDRFPGAPlacedOverlay(val shell: FPGAShellBasicOverlays, name: String, val designInput: DDRDesignInput, val shellInput: DDRShellInput)
  extends DDRPlacedOverlay[XilinxVCU118MIGPads](name, designInput, shellInput)
{
  val size = p(FPGADDRSize)

  val migParams = XilinxVCU118MIGParams(address = AddressSet.misaligned(di.baseAddress, size))
  val mig = LazyModule(new XilinxVCU118MIG(migParams))
  val ddrUI     = shell { ClockSourceNode(freqMHz = 200) }
  val areset    = shell { ClockSinkNode(Seq(ClockSinkParameters())) }
  areset := designInput.wrangler := ddrUI

  def overlayOutput = DDROverlayOutput(ddr = mig.node)
  def ioFactory = new XilinxVCU118MIGPads(size)

  shell { InModuleBody {
    require (shell.fpga_clock.get.isDefined, "Use of DDRFPGAOverlay depends on SysClockVCU118Overlay")
    val (sys, _) = shell.fpga_clock.get.get.overlayOutput.node.out(0)
    val (ui, _) = ddrUI.out(0)
    val (ar, _) = areset.in(0)
    val port = mig.module.io.port
    io <> port.viewAsSupertype(new VCU118MIGIODDR(mig.depth))
    ui.clock := port.c0_ddr4_ui_clk
    ui.reset := /*!port.mmcm_locked ||*/ port.c0_ddr4_ui_clk_sync_rst
    port.c0_sys_clk_i := sys.clock.asUInt
    port.sys_rst := sys.reset // pllReset
    port.c0_ddr4_aresetn := !(ar.reset.asBool)

    val allddrpins = Seq(  "D14", "B15", "B16", "C14", "C15", "A13", "A14",
      "A15", "A16", "B12", "C12", "B13", "C13", "D15", "H14", "H15", "F15",
      "H13", "G15", "G13", "N20", "E13", "E14", "F14", "A10", "F13", "C8",
      "F11", "E11", "F10", "F9",  "H12", "G12", "E9",  "D9",  "R19", "P19",
      "M18", "M17", "N19", "N18", "N17", "M16", "L16", "K16", "L18", "K18",
      "J17", "H17", "H19", "H18", "F19", "F18", "E19", "E18", "G20", "F20",
      "E17", "D16", "D17", "C17", "C19", "C18", "D20", "D19", "C20", "B20",
      "N23", "M23", "R21", "P21", "R22", "P22", "T23", "R23", "K24", "J24",
      "M21", "L21", "K21", "J21", "K22", "J22", "H23", "H22", "E23", "E22",
      "F21", "E21", "F24", "F23", "D10", "P16", "J19", "E16", "A18", "M22",
      "L20", "G23", "D11", "P17", "K19", "F16", "A19", "N22", "M20", "H24",
      "G11", "R18", "K17", "G18", "B18", "P20", "L23", "G22")

    (IOPin.of(io) zip allddrpins) foreach { case (io, pin) => shell.xdc.addPackagePin(io, pin) }
  } }

  shell.sdc.addGroup(pins = Seq(mig.island.module.blackbox.io.c0_ddr4_ui_clk))
}
class DDRFPGAShellPlacer(shell: FPGAShellBasicOverlays, val shellInput: DDRShellInput)(implicit val valName: ValName)
  extends DDRShellPlacer[FPGAShellBasicOverlays] {
  def place(designInput: DDRDesignInput) = new DDRFPGAPlacedOverlay(shell, valName.name, designInput, shellInput)
}

/*
   Copyright 2016 SiFive, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
