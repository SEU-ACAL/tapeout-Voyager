package voyager_tapeout.custom.device.peripheral_npu

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.regmapper._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.amba.axi4._
import freechips.rocketchip.util._
import freechips.rocketchip.prci._
import voyager_tapeout.custom.uncore._


// Configuration parameters for NPU
case class PeripheralNPUParams(
  address: BigInt,
  size: BigInt,
  beatBytes: Int = 8
) {
  // require(isPow2(size), s"NPU size (${size}) must be a power of 2")
  // require(address % size == 0, s"NPU address (0x${address.toString(16)}) must be aligned to size (${size})")
  // require(isPow2(beatBytes), s"NPU beatBytes (${beatBytes}) must be a power of 2")
  // require(beatBytes >= 4 && beatBytes <= 64, s"NPU beatBytes (${beatBytes}) must be between 4 and 64")
  // require(size >= beatBytes, s"NPU size (${size}) must be at least beatBytes (${beatBytes})")
}

case object PeripheralNPUKey extends Field[Option[PeripheralNPUParams]](None)

class PeripheralNPUIOCell extends Bundle {
  val npu_clk_FPGA_w             = Input(Bool())
  val npu_clk_FPGA_cim           = Input(Bool())
  val npu_rstn_FPGA              = Input(Bool())
  val npu_PLL_CLK_SEL            = Input(Bool())
  val npu_TEST_MODE	             = Input(Bool())
  val npu_FPGA_sys_load_data_vld = Output(Bool())
  val npu_FPGA_sys_load_en       = Input(Bool())
  val npu_FPGA_sys_load_addr     = Input(UInt(20.W))
  val npu_FPGA_sys_load_data     = Output(UInt(64.W))
  val npu_FPGA_sys_store_en      = Input(Bool())
  val npu_FPGA_sys_store_addr    = Input(UInt(20.W))
  val npu_FPGA_sys_store_data    = Input(UInt(64.W))
  val npu_clk_PLL_w              = Input(Bool())
  val npu_clk_PLL_cim            = Input(Bool())
}

// NPU AXI从设备BlackBox - 包装Verilog NPU模块
class AXISlaveNPUWrapperBlackBox extends BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val clk        = Input(Clock())
    val rstn       = Input(Bool())
    // AXI4从设备接口 - 用于CPU访问NPU寄存器和内存
    val axi_awaddr = Input(UInt(20.W))
    val axi_awlen = Input(UInt(8.W))
    val axi_awsize = Input(UInt(3.W))
    val axi_awburst = Input(UInt(2.W))
    val axi_awid = Input(UInt(2.W))
    val axi_awvalid = Input(Bool())
    val axi_awready = Output(Bool())

    val axi_wdata = Input(UInt(64.W))
    val axi_wstrb = Input(UInt(8.W))
    val axi_wlast = Input(Bool())
    val axi_wvalid = Input(Bool())
    val axi_wready = Output(Bool())

    val axi_bresp = Output(UInt(2.W))
    val axi_bid = Output(UInt(2.W))
    val axi_bvalid = Output(Bool())
    val axi_bready = Input(Bool())

    val axi_araddr = Input(UInt(20.W))
    val axi_arlen = Input(UInt(8.W))
    val axi_arsize = Input(UInt(3.W))
    val axi_arburst = Input(UInt(2.W))
    val axi_arid = Input(UInt(2.W))
    val axi_arvalid = Input(Bool())
    val axi_arready = Output(Bool())

    val axi_rdata = Output(UInt(64.W))
    val axi_rresp = Output(UInt(2.W))
    val axi_rlast = Output(Bool())
    val axi_rid = Output(UInt(2.W))
    val axi_rvalid = Output(Bool())
    val axi_rready = Input(Bool())

    // NPU外部控制和状态信号
    // val clk_FPGA_w = Input(Clock())      // FPGA权重时钟
    // val clk_FPGA_cim = Input(Clock())    // FPGA CIM时钟
    val clk_FPGA_w    = Input(Bool())      // FPGA权重时钟
    val clk_FPGA_cim  = Input(Bool())    // FPGA CIM时钟
    val rstn_FPGA     = Input(Bool())        // FPGA复位信号
    val PLL_CLK_SEL   = Input(Bool())      // PLL时钟选择
    val TEST_MODE     = Input(Bool())        // 测试模式选择

    // FPGA系统接口 - 用于外部数据加载和存储
    val FPGA_sys_load_data_vld = Output(Bool())
    val FPGA_sys_load_en       = Input(Bool())
    val FPGA_sys_load_addr     = Input(UInt(17.W))
    val FPGA_sys_load_data     = Output(UInt(64.W))
    val FPGA_sys_store_en      = Input(Bool())
    val FPGA_sys_store_addr    = Input(UInt(17.W))
    val FPGA_sys_store_data    = Input(UInt(64.W))

    // PLL时钟输入
    val clk_PLL_w   = Input(Bool()) //Input(Clock())
    val clk_PLL_cim = Input(Bool()) //Input(Clock())
  })

  // 指定BlackBox使用的Verilog模块名称
  override def desiredName = "axi_slave_npu_wrapper"

  addResource("npu/AsyncResetSynchronizerPrimitiveShiftReg_d3_i0.sv")
  addResource("npu/AsyncResetSynchronizerShiftReg_w1_d3_i0_3.sv")
  addResource("npu/axi_bridge.v")
  addResource("npu/axi_slave_npu_wrapper.v")
  addResource("npu/CIML2P_512X64_DR_M2_A1.fpga.v")
  addResource("npu/CIML2P_64X64_DR_M2_A1.fpga.v")
  addResource("npu/ciml_mac.v")
  addResource("npu/CIM_memory_interface_large.v")
  addResource("npu/CIM_memory_interface_small.v")
  addResource("npu/clk_selector.v")
  addResource("npu/ClockMutexMux.sv")
  addResource("npu/ClockUtil.v")
  addResource("npu/csr_ctrl_memory_interface.v")
  addResource("npu/defines.v")
  addResource("npu/DW_minmax.v")
  addResource("npu/EICG_wrapper.v")
  addResource("npu/exponent_memory_interface.v")
  addResource("npu/feature_memory_interface_large.v")
  addResource("npu/feature_memory_interface_small.v")
  addResource("npu/Macro_large.v")
  addResource("npu/Macro_small.v")
  addResource("npu/mem_access_manager.v")
  addResource("npu/NNIN_pre_align.v")
  addResource("npu/NNIN_shifter.v")
  addResource("npu/NNIN_top.v")
  addResource("npu/NPU_core_large.v")
  addResource("npu/NPU_core_small.v")
  addResource("npu/NPU_ctrl_large.v")
  addResource("npu/NPU_ctrl_small.v")
  addResource("npu/NPU_top.v")
  addResource("npu/outlier_large_Macro_top.v")
  addResource("npu/outlier_mac_small_channel.v")
  addResource("npu/outlier_mac_small_Macro.v")
  addResource("npu/outlier_process_large_channel.v")
  addResource("npu/outlier_process_large_Macro.v")
  addResource("npu/outlier_small_Macro_top.v")
  addResource("npu/output_buffer_interface.v")
  addResource("npu/psum_self_adder.v")
  addResource("npu/psum_shift_adder.v")
  addResource("npu/smic281prf1024x64m4.v")
  addResource("npu/smic281prf128x64m4.v")
  addResource("npu/smic281prf64x64m4.v")
  addResource("npu/sys_top.v")
  addResource("npu/TEST_MODE_bridge.v")
  addResource("npu/WD_shifter_macro.v")
  addResource("npu/WD_shifter.v")
  addResource("npu/weight_memory_interface_L.v")
  addResource("npu/weight_memory_interface_S.v")
}

class PeripheralNPU(params: PeripheralNPUParams)(implicit p: Parameters) extends ClockSinkDomain(ClockSinkParameters())(p) {
  
  val regnode = AXI4SlaveNode(Seq(AXI4SlavePortParameters(
    Seq(AXI4SlaveParameters(
      address = Seq(AddressSet(params.address, params.size - 1)),
      executable = false,
      // 支持的传输大小：从1字节到beatBytes，必须是2的幂次
      supportsWrite = TransferSizes(1, params.beatBytes),
      supportsRead = TransferSizes(1, params.beatBytes),
      // 添加AXI4特定的参数
      interleavedId = Some(0)
    )),
    beatBytes = params.beatBytes,
    // 确保与TileLink兼容的参数
    minLatency = 1
  )))

  override lazy val module = new PeripheralNPUModuleImp(this)
  
  class PeripheralNPUModuleImp(outer: PeripheralNPU) extends Impl {
    val io = IO(new PeripheralNPUIOCell) // to chiptop
    val (axi, edge) = outer.regnode.in(0)
    
    withClockAndReset(clock, reset) {
    val npuBlackBox = Module(new AXISlaveNPUWrapperBlackBox)

      //clk
    npuBlackBox.io.clk  := clock
    npuBlackBox.io.rstn := ~reset.asBool
    // 连接AXI4接口到BlackBox
    // 写地址通道 - 处理位宽转换
    // require(axi.aw.bits.addr.getWidth >= 29, s"AXI4 address width (${axi.aw.bits.addr.getWidth}) must be >= 29 bits")
    require(axi.aw.bits.id.getWidth >= 1, s"AXI4 ID width (${axi.aw.bits.id.getWidth}) must be >= 1 bits")
    npuBlackBox.io.axi_awaddr := axi.aw.bits.addr(19, 0)  // BlackBox期望29位地址
    npuBlackBox.io.axi_awlen := axi.aw.bits.len
    npuBlackBox.io.axi_awsize := axi.aw.bits.size
    npuBlackBox.io.axi_awburst := axi.aw.bits.burst
    npuBlackBox.io.axi_awid := axi.aw.bits.id
    npuBlackBox.io.axi_awvalid := axi.aw.valid
    axi.aw.ready := npuBlackBox.io.axi_awready

    // 写数据通道
    npuBlackBox.io.axi_wdata := axi.w.bits.data
    npuBlackBox.io.axi_wstrb := axi.w.bits.strb
    npuBlackBox.io.axi_wlast := axi.w.bits.last
    npuBlackBox.io.axi_wvalid := axi.w.valid
    axi.w.ready := npuBlackBox.io.axi_wready

    // 写响应通道 - 处理位宽转换
    // require(axi.b.bits.id.getWidth >= 1, s"AXI4 response ID width (${axi.b.bits.id.getWidth}) must be >= 1 bits")
    axi.b.bits.resp := npuBlackBox.io.axi_bresp
    axi.b.bits.id := npuBlackBox.io.axi_bid
    axi.b.valid := npuBlackBox.io.axi_bvalid
    npuBlackBox.io.axi_bready := axi.b.ready

    // 读地址通道 - 处理位宽转换
    // require(axi.ar.bits.addr.getWidth >= 29, s"AXI4 address width (${axi.ar.bits.addr.getWidth}) must be >= 29 bits")
    // require(axi.ar.bits.id.getWidth >= 1, s"AXI4 ID width (${axi.ar.bits.id.getWidth}) must be >= 1 bits")
    npuBlackBox.io.axi_araddr := axi.ar.bits.addr(19, 0)  // BlackBox期望29位地址
    npuBlackBox.io.axi_arlen := axi.ar.bits.len
    npuBlackBox.io.axi_arsize := axi.ar.bits.size
    npuBlackBox.io.axi_arburst := axi.ar.bits.burst
    npuBlackBox.io.axi_arid := axi.ar.bits.id
    npuBlackBox.io.axi_arvalid := axi.ar.valid
    axi.ar.ready := npuBlackBox.io.axi_arready

    // 读数据通道 - 处理位宽转换
    // require(axi.r.bits.id.getWidth >= 1, s"AXI4 response ID width (${axi.r.bits.id.getWidth}) must be >= 1 bits")
    axi.r.bits.data := npuBlackBox.io.axi_rdata
    axi.r.bits.resp := npuBlackBox.io.axi_rresp
    axi.r.bits.last := npuBlackBox.io.axi_rlast
    axi.r.bits.id := npuBlackBox.io.axi_rid
    axi.r.valid := npuBlackBox.io.axi_rvalid
    npuBlackBox.io.axi_rready := axi.r.ready

    npuBlackBox.io.clk_FPGA_w            := io.npu_clk_FPGA_w             
    npuBlackBox.io.clk_FPGA_cim          := io.npu_clk_FPGA_cim           
    npuBlackBox.io.rstn_FPGA             := io.npu_rstn_FPGA              
    npuBlackBox.io.PLL_CLK_SEL           := io.npu_PLL_CLK_SEL            
    npuBlackBox.io.TEST_MODE	           := io.npu_TEST_MODE	             
    npuBlackBox.io.FPGA_sys_load_en      := io.npu_FPGA_sys_load_en       
    npuBlackBox.io.FPGA_sys_load_addr    := io.npu_FPGA_sys_load_addr(16,0)     
    npuBlackBox.io.FPGA_sys_store_en     := io.npu_FPGA_sys_store_en      
    npuBlackBox.io.FPGA_sys_store_addr   := io.npu_FPGA_sys_store_addr(16,0)    
    npuBlackBox.io.FPGA_sys_store_data   := io.npu_FPGA_sys_store_data    
    npuBlackBox.io.clk_PLL_w             := io.npu_clk_PLL_w              
    npuBlackBox.io.clk_PLL_cim           := io.npu_clk_PLL_cim         

    io.npu_FPGA_sys_load_data_vld        := npuBlackBox.io.FPGA_sys_load_data_vld
    io.npu_FPGA_sys_load_data            := npuBlackBox.io.FPGA_sys_load_data    
    }
  }
}



// Trait to add the NPU device to the subsystem
trait CanHavePeripheryNPU { this: BaseSubsystem =>
  private val portName = "peripheralNpuPBusPort"
  private val pbus = locateTLBusWrapper(PBUS)
  
  val npuPeripheral = p(PeripheralNPUKey).map { params =>
    val device = LazyModule(new PeripheralNPU(params.copy(beatBytes = pbus.beatBytes)))
    // Add clock connection
    device.clockNode := pbus.fixedClockNode
    // Connect to peripheral bus using AXI4 protocol
    pbus.coupleTo(portName) {
      device.regnode :=
      AXI4UserYanker() :=
      AXI4Buffer() :=
      TLToAXI4() :=
      TLRequestFifoFalse() :=
      TLSourceShrinker(1 << 2) :=
      TLFragmenter(pbus.beatBytes, pbus.blockBytes, holdFirstDeny = true) := _
    }
    device
  }
  
  // Expose NPU signals for IOBinder
  val NpuChipTopIO = p(PeripheralNPUKey) match {
    case Some(params) => {
      val npuIO = InModuleBody {
        val npu = IO(new PeripheralNPUIOCell).suggestName("peripheralNpuIOCellPin")
          npuPeripheral.map { device =>
            npu <> device.module.io
      }.getOrElse {
        npu.npu_FPGA_sys_load_data_vld := false.B
        npu.npu_FPGA_sys_load_data := 0.U
      }
        npu
      }
      Some(npuIO)
    }
    case None => None
  }
}


