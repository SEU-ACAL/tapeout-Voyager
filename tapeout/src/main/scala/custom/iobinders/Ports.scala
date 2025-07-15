package voyager_tapeout.custom.iobinders

import chisel3._
import chisel3.experimental.{Analog}
import org.chipsalliance.cde.config.{Parameters}
import voyager_tapeout.custom.device.peripheral_npu.{PeripheralNPUIOCell}
import testchipip.spi.SPIChipIO

// Use chipyard's Port type
import chipyard.iobinders.Port

// Our custom Port implementation inheriting from chipyard's Port
case class PeripheralNPUPort (val getIO: () => PeripheralNPUIOCell)
    extends Port[PeripheralNPUIOCell]

case class SPIChipPort (val getIO : () => SPIChipIO)
extends Port[SPIChipIO]
