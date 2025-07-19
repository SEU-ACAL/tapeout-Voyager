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

