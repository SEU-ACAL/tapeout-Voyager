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
  val fpga_clock = Overlay(ClockInputOverlayKey, new SysClockVCU118ShellPlacer(this, ClockInputShellInput()))
}

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
