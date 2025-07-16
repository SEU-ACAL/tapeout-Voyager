package voyager_tapeout.custom.harness

import chisel3._
import chisel3.util._

import org.chipsalliance.cde.config.{Parameters}
import testchipip.spi.{SimSPIFlashModel}
import voyager_tapeout.custom.iobinders.{PeripheralNPUPort, SPIChipPort}

// Import chipyard harness types
import chipyard.harness.{HasHarnessInstantiators, HarnessBinder}

// Import our custom NPU types
import voyager_tapeout.custom.iobinders.{PeripheralNPUPort}
import voyager_tapeout.custom.device.peripheral_npu.{PeripheralNPUIOCell}
import voyager_tapeout.custom.harness.HasCustomHarnessInstantiators

class WithPeripheralNPUPin extends HarnessBinder({
  case (th: HasHarnessInstantiators, port: PeripheralNPUPort, chipId: Int) => {
    // Drive NPU input pins from the test harness
    port.io.npu_pin1 := true.B   // Drive input pin high
    port.io.npu_pin3 := false.B  // Drive input pin low
    // Output pins (npu_pin2, npu_pin4) are driven by the NPU peripheral
  }
})

class WithSimSPIModel(rdOnly: Boolean = true) extends HarnessBinder({
  case (th: HasHarnessInstantiators, port: SPIChipPort, chipId: Int) => {
    val spi_mem = Module(new SimSPIFlashModel(100000, 0, rdOnly)).suggestName(s"spi_mem${0}")
    spi_mem.io.sck := port.io.sck
    spi_mem.io.cs(0) := port.io.cs(0)
    spi_mem.io.dq.zip(port.io.dq).foreach { case (x, y) => x <> y }
    spi_mem.io.reset := th.harnessBinderReset
  }
})

