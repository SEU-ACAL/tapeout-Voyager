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
  val npu_pin1 = Input(Bool())
  val npu_pin2 = Output(Bool())
  val npu_pin3 = Input(Bool())
  val npu_pin4 = Output(Bool())
}

// NPU AXI从设备BlackBox - 包装Verilog NPU模块
class AXISlaveNPUWrapperBlackBox extends BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    // AXI4从设备接口 - 用于CPU访问NPU寄存器和内存
    val axi_awaddr = Input(UInt(29.W))
    val axi_awlen = Input(UInt(8.W))
    val axi_awsize = Input(UInt(3.W))
    val axi_awburst = Input(UInt(2.W))
    val axi_awid = Input(UInt(1.W))
    val axi_awvalid = Input(Bool())
    val axi_awready = Output(Bool())

    val axi_wdata = Input(UInt(64.W))
    val axi_wstrb = Input(UInt(8.W))
    val axi_wlast = Input(Bool())
    val axi_wvalid = Input(Bool())
    val axi_wready = Output(Bool())

    val axi_bresp = Output(UInt(2.W))
    val axi_bid = Output(UInt(1.W))
    val axi_bvalid = Output(Bool())
    val axi_bready = Input(Bool())

    val axi_araddr = Input(UInt(29.W))
    val axi_arlen = Input(UInt(8.W))
    val axi_arsize = Input(UInt(3.W))
    val axi_arburst = Input(UInt(2.W))
    val axi_arid = Input(UInt(1.W))
    val axi_arvalid = Input(Bool())
    val axi_arready = Output(Bool())

    val axi_rdata = Output(UInt(64.W))
    val axi_rresp = Output(UInt(2.W))
    val axi_rlast = Output(Bool())
    val axi_rid = Output(UInt(1.W))
    val axi_rvalid = Output(Bool())
    val axi_rready = Input(Bool())

    // NPU外部控制和状态信号
    // val clk_FPGA_w = Input(Clock())      // FPGA权重时钟
    // val clk_FPGA_cim = Input(Clock())    // FPGA CIM时钟
    val clk_FPGA_w = Input(Bool())      // FPGA权重时钟
    val clk_FPGA_cim = Input(Bool())    // FPGA CIM时钟
    val rstn_FPGA = Input(Bool())        // FPGA复位信号
    val PLL_CLK_SEL = Input(Bool())      // PLL时钟选择
    val TEST_MODE = Input(Bool())        // 测试模式选择

    // FPGA系统接口 - 用于外部数据加载和存储
    val FPGA_sys_load_en = Input(Bool())
    val FPGA_sys_load_addr = Input(UInt(20.W))
    val FPGA_sys_load_data = Output(UInt(64.W))
    val FPGA_sys_store_en = Input(Bool())
    val FPGA_sys_store_addr = Input(UInt(20.W))
    val FPGA_sys_store_data = Input(UInt(64.W))

    // PLL时钟输入
    val clk_PLL_w   = Input(Bool()) //Input(Clock())
    val clk_PLL_cim = Input(Bool()) //Input(Clock())
  })

  // 指定BlackBox使用的Verilog模块名称
  override def desiredName = "axi_slave_npu_wrapper"

  // 添加Verilog资源文件 - 指定NPU相关的所有Verilog文件
  addResource("axi_slave_npu_wrapper.v")
  addResource("axi_bridge.v")
  addResource("sys_top.v")
  addResource("TEST_MODE_bridge.v")
  addResource("NPU_top.v")
  addResource("defines.v")
  addResource("csr_ctrl_memory_interface.v")
  addResource("feature_memory_interface.v")
  addResource("weight_memory_interface_L.v")
  addResource("weight_memory_interface_S.v")
  addResource("output_buffer_interface.v")
  addResource("mem_access_manager.v")
  addResource("CIM_memory_interface_large.v")
  addResource("NPU_core_large.v")
  addResource("NPU_core_small.v")
  addResource("Macro_large.v")
  addResource("Macro_small.v")
  addResource("NNIN.v")
  addResource("NNIN_NOC.v")
  addResource("NNIN_shifter.v")
  addResource("NNIN_shifter_x8.v")
  addResource("ciml_mac.v")
  addResource("psum_self_adder.v")
  addResource("psum_shift_adder.v")
  addResource("WD_shifter.v")
  addResource("WD_shifter_macro.v")
  addResource("outlier_large_Macro_top.v")
  addResource("outlier_small_Macro_top.v")
  addResource("outlier_mac_small_Macro.v")
  addResource("outlier_mac_small_channel.v")
  addResource("outlier_process_large_Macro.v")
  addResource("outlier_process_large_channel.v")
  // 添加SRAM库文件
  addResource("smic281prf1024x64m4.v")
  addResource("smic281prf128x64m4.v")
  addResource("smic281prf64x64m4.v")
  // 添加CIM宏文件
  addResource("CIML2P_512X64_DR_M2_A1.fpga.v")
  addResource("CIML2P_64X64_DR_M2_A1.fpga.v")
  addResource("ciml_mac.v")
  // 添加查找最大值模块
  addResource("DW_minmax.v")
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
    val (axi, _) = outer.regnode.in(0)
    
    withClockAndReset(clock, reset) {
     val npuBlackBox = Module(new AXISlaveNPUWrapperBlackBox)

    // 连接AXI4接口到BlackBox
    // 写地址通道 - 处理位宽转换
    require(axi.aw.bits.addr.getWidth >= 29, s"AXI4 address width (${axi.aw.bits.addr.getWidth}) must be >= 29 bits")
    require(axi.aw.bits.id.getWidth >= 1, s"AXI4 ID width (${axi.aw.bits.id.getWidth}) must be >= 1 bits")
    npuBlackBox.io.axi_awaddr := axi.aw.bits.addr(28, 0)  // BlackBox期望29位地址
    npuBlackBox.io.axi_awlen := axi.aw.bits.len
    npuBlackBox.io.axi_awsize := axi.aw.bits.size
    npuBlackBox.io.axi_awburst := axi.aw.bits.burst
    npuBlackBox.io.axi_awid := axi.aw.bits.id(0, 0)  // BlackBox期望1位ID
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
    axi.b.bits.id := Cat(0.U((axi.b.bits.id.getWidth - 1).W), npuBlackBox.io.axi_bid)  // 扩展1位ID到系统宽度
    axi.b.valid := npuBlackBox.io.axi_bvalid
    npuBlackBox.io.axi_bready := axi.b.ready

    // 读地址通道 - 处理位宽转换
    // require(axi.ar.bits.addr.getWidth >= 29, s"AXI4 address width (${axi.ar.bits.addr.getWidth}) must be >= 29 bits")
    // require(axi.ar.bits.id.getWidth >= 1, s"AXI4 ID width (${axi.ar.bits.id.getWidth}) must be >= 1 bits")
    npuBlackBox.io.axi_araddr := axi.ar.bits.addr(28, 0)  // BlackBox期望29位地址
    npuBlackBox.io.axi_arlen := axi.ar.bits.len
    npuBlackBox.io.axi_arsize := axi.ar.bits.size
    npuBlackBox.io.axi_arburst := axi.ar.bits.burst
    npuBlackBox.io.axi_arid := axi.ar.bits.id(0, 0)  // BlackBox期望1位ID
    npuBlackBox.io.axi_arvalid := axi.ar.valid
    axi.ar.ready := npuBlackBox.io.axi_arready

    // 读数据通道 - 处理位宽转换
    // require(axi.r.bits.id.getWidth >= 1, s"AXI4 response ID width (${axi.r.bits.id.getWidth}) must be >= 1 bits")
    axi.r.bits.data := npuBlackBox.io.axi_rdata
    axi.r.bits.resp := npuBlackBox.io.axi_rresp
    axi.r.bits.last := npuBlackBox.io.axi_rlast
    axi.r.bits.id := Cat(0.U((axi.r.bits.id.getWidth - 1).W), npuBlackBox.io.axi_rid)  // 扩展1位ID到系统宽度
    axi.r.valid := npuBlackBox.io.axi_rvalid
    npuBlackBox.io.axi_rready := axi.r.ready

    // 连接外部时钟信号 - 使用系统时钟作为默认值
    npuBlackBox.io.clk_FPGA_w := io.npu_pin1
    npuBlackBox.io.clk_FPGA_cim := io.npu_pin1
    npuBlackBox.io.rstn_FPGA := !io.npu_pin3

    // 连接控制信号到IO接口
    npuBlackBox.io.PLL_CLK_SEL := io.npu_pin1  // 使用外部引脚1控制PLL时钟选择
    npuBlackBox.io.TEST_MODE := io.npu_pin3    // 使用外部引脚3控制测试模式

    // 连接FPGA系统接口 - 默认禁用外部加载/存储
    npuBlackBox.io.FPGA_sys_load_en := false.B
    npuBlackBox.io.FPGA_sys_load_addr := 0.U
    npuBlackBox.io.FPGA_sys_store_en := false.B
    npuBlackBox.io.FPGA_sys_store_addr := 0.U
    npuBlackBox.io.FPGA_sys_store_data := 0.U

    // 连接PLL时钟 - 使用系统时钟
    npuBlackBox.io.clk_PLL_w := io.npu_pin1
    npuBlackBox.io.clk_PLL_cim := io.npu_pin1

    // 连接输出信号到IO接口
    // npu_pin2用于指示NPU状态（从FPGA系统加载数据的有效性）
    io.npu_pin2 := npuBlackBox.io.FPGA_sys_load_data.orR
    // npu_pin4用于指示NPU计算完成状态
    io.npu_pin4 := npuBlackBox.io.axi_rvalid && npuBlackBox.io.axi_rready
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
      AXI4Buffer() :=
      TLToAXI4() :=
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
        npu.npu_pin2 := false.B
        npu.npu_pin4 := false.B
      }
        npu
      }
      Some(npuIO)
    }
    case None => None
  }
}


