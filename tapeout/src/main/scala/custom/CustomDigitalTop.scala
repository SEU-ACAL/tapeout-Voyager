package voyager_tapeout.custom

import chisel3._
import org.chipsalliance.cde.config.{Parameters, Config}
import freechips.rocketchip.util.DontTouch

// Import chipyard base system
import chipyard.{DigitalTop, DigitalTopModule}

// Import our custom NPU peripheral
import voyager_tapeout.custom.device.peripheral_npu.{CanHavePeripheryNPU}

// ------------------------------------
// Custom Digital Top with NPU Support
// ------------------------------------

class CustomDigitalTop(implicit p: Parameters) extends DigitalTop()(p) with CanHavePeripheryNPU
{
  override lazy val module = new CustomDigitalTopModule(this)
}

class CustomDigitalTopModule(l: CustomDigitalTop) extends DigitalTopModule(l)
  with freechips.rocketchip.util.DontTouch
{
  val npuPeripheralOpt = l.npuPeripheral
}

