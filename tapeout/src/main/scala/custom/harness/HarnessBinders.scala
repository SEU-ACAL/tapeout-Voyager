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

import testchipip.tsi.{SimTSI, SerialRAM, TSI, TSIIO}
import testchipip.serdes._
import chipyard.iobinders._
import freechips.rocketchip.diplomacy.{LazyModule, LazyModuleImpLike}

class WithPeripheralNPUPin extends HarnessBinder({
  case (th: HasHarnessInstantiators, port: PeripheralNPUPort, chipId: Int) => {
    port.io.npu_clk_FPGA_w             := false.B 
    port.io.npu_clk_FPGA_cim           := false.B 
    port.io.npu_rstn_FPGA              := false.B 
    port.io.npu_PLL_CLK_SEL            := false.B 
    port.io.npu_TEST_MODE	             := false.B 
    port.io.npu_FPGA_sys_load_en       := false.B 
    port.io.npu_FPGA_sys_load_addr     := false.B 
    // port.io.npu_FPGA_sys_load_data     := 0.U(64.W)
    port.io.npu_FPGA_sys_store_en      := false.B 
    port.io.npu_FPGA_sys_store_addr    := 0.U(20.W)
    port.io.npu_FPGA_sys_store_data    := 0.U(64.W)
    port.io.npu_clk_PLL_w              := false.B 
    port.io.npu_clk_PLL_cim            := false.B 
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


class WithVoyagerSimTSIOverSerialTL extends HarnessBinder({
  case (th: HasHarnessInstantiators, port: SerialTLPort, chipId: Int) if (port.portId == 0) => {
    port.io match {
      case io: InternalSyncPhitIO =>
      case io: ExternalSyncPhitIO => io.clock_in := th.harnessBinderClock
      case io: SourceSyncPhitIO => io.clock_in := th.harnessBinderClock; io.reset_in := th.harnessBinderReset
    }

    port.io match {
      case io: DecoupledPhitIO => {
        // If the port is locally synchronous (provides a clock), drive everything with that clock
        // Else, drive everything with the harnes clock
        val clock = port.io match {
          case io: InternalSyncPhitIO => io.clock_out
          case io: ExternalSyncPhitIO => th.harnessBinderClock
        }
        withClock(clock) {
          val ram = Module(LazyModule(new SerialDRAM(port.serdesser, port.params)(port.serdesser.p)).module)
          ram.io.ser.in <> io.out
          io.in <> ram.io.ser.out

          val success = SimTSI.connect(ram.io.tsi, clock, th.harnessBinderReset, chipId)
          when (success) { th.success := true.B }
        }
      }
    }
  }
})
