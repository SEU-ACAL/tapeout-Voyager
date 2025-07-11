package voyager_tapeout.custom.device.peripheral_npu

import org.chipsalliance.cde.config.{Config, Parameters, Field}
import voyager_tapeout.custom.device.peripheral_npu.PeripheralNPUParams

class WithNPUPeripheral (params: PeripheralNPUParams = PeripheralNPUParams(
  address = 0x10050000, 
  size = 0x40, 
  beatBytes = 8
)) extends Config((site, here, up) => {
  case PeripheralNPUKey => Some(params)
})

