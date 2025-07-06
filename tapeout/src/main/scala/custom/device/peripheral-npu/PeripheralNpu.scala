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
  size: BigInt = 0x40,
  beatBytes: Int = 8
)

case object PeripheralNPUKey extends Field[Option[PeripheralNPUParams]](None)

class PeripheralNPUIOCell extends Bundle {
  val npu_pin1 = Input(Bool())
  val npu_pin2 = Output(Bool())
  val npu_pin3 = Input(Bool())
  val npu_pin4 = Output(Bool())
}

class PeripheralNPU(params: PeripheralNPUParams)(implicit p: Parameters) extends ClockSinkDomain(ClockSinkParameters())(p) {
  
  val regnode = AXI4RegisterNode(
    address = AddressSet(params.address, params.size-1),
    executable = false,
    beatBytes = params.beatBytes
  )

  override lazy val module = new PeripheralNPUModuleImp(this)
  
  class PeripheralNPUModuleImp(outer: PeripheralNPU) extends Impl {
    val io = IO(new PeripheralNPUIOCell) // to chiptop
    
    withClockAndReset(clock, reset) {
      val ctrl_reg     = RegInit(0.U(32.W))
      val status_reg   = RegInit(0.U(32.W))
      val data_in_reg  = RegInit(0.U(32.W))
      val data_out_reg = RegInit(0.U(32.W))
      
      
      val npu_pin1_reg = RegInit(0.U(1.W))
      val npu_pin3_reg = RegInit(0.U(1.W))
      npu_pin1_reg := io.npu_pin1
      npu_pin3_reg := io.npu_pin3
      
      // 输出引脚从内部逻辑驱动
      io.npu_pin2 := data_out_reg(0)
      io.npu_pin4 := data_out_reg(1)
      
      // pbus接口连接：不需要额外顶层接口连接，直接在regmap中处理
      outer.regnode.regmap(
        0x00 -> Seq(RegField(32, ctrl_reg, RegFieldDesc("ctrl", "NPU Control register"))),
        0x04 -> Seq(RegField.r(32, status_reg, RegFieldDesc("status", "NPU Status register (read-only)"))),
        0x08 -> Seq(RegField(32, data_in_reg, RegFieldDesc("data_in", "NPU Data input register"))),
        0x0C -> Seq(RegField.r(32, data_out_reg, RegFieldDesc("data_out", "NPU Data output register (read-only)")))
      )
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


