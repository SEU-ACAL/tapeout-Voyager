package voyager_tapeout.custom.harness

import chisel3._
import chisel3.util._

import org.chipsalliance.cde.config.{Parameters}

// Import chipyard harness types
import chipyard.harness.{HasHarnessInstantiators, HarnessBinder}

// Import our custom NPU types
import voyager_tapeout.custom.iobinders.{PeripheralNPUPort}
// import chipyard.iobinders.PeripheralNPUPort
import voyager_tapeout.custom.device.peripheral_npu.{PeripheralNPUIOCell}
// import chipyard.iobinders.PeripheralNPUIOCell
import voyager_tapeout.custom.harness.HasCustomHarnessInstantiators
class WithPeripheralNPUPin extends HarnessBinder({
  case (th: HasHarnessInstantiators, port: PeripheralNPUPort, chipId: Int) => {
    // Drive NPU input pins from the test harness
    port.io.npu_pin1 := true.B   // Drive input pin high
    port.io.npu_pin3 := false.B  // Drive input pin low
    // Output pins (npu_pin2, npu_pin4) are driven by the NPU peripheral
  }
})