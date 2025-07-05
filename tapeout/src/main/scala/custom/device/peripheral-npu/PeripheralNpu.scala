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

// IO trait for the NPU peripheral
class PeripheralNPUPBusIO extends Bundle {
  val ctrl     = Output(UInt(32.W))    
  val status   = Input(UInt(32.W))  
  val data_in  = Output(UInt(32.W)) 
  val data_out = Input(UInt(32.W)) 
}

class PeripheralNPUPunchthroughIO extends Bundle {
  val npu_pin1 = Input(UInt(32.W))
  val npu_pin2 = Output(UInt(32.W))
  val npu_pin3 = Input(UInt(32.W))
  val npu_pin4 = Output(UInt(32.W))
}

class PeripheralNPU(params: PeripheralNPUParams)(implicit p: Parameters) extends ClockSinkDomain(ClockSinkParameters())(p) {
  
  val regnode = AXI4RegisterNode(
    address = AddressSet(params.address, params.size-1),
    executable = false,
    beatBytes = params.beatBytes
  )

  override lazy val module = new PeripheralNPUModuleImp(this)
  
  class PeripheralNPUModuleImp(outer: PeripheralNPU) extends Impl {
    val io = IO(new PeripheralNPUPBusIO)
    
    withClockAndReset(clock, reset) {
      val ctrl_reg     = RegInit(0.U(32.W))
      val status_reg   = RegInit(0.U(32.W))
      val data_in_reg  = RegInit(0.U(32.W))
      val data_out_reg = RegInit(0.U(32.W))
      
      io.ctrl      := ctrl_reg
      io.data_in   := data_in_reg
      status_reg   := io.status
      data_out_reg := io.data_out
      
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
  private val portName = "npu-peripheral"
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
  val npuPeripheralIO = p(PeripheralNPUKey) match {
    case Some(params) => {
      val npuIO = InModuleBody {
        val npu = IO(new PeripheralNPUPunchthroughIO).suggestName("npu_peripheral")
        npuPeripheral.map { device =>
          npu <> device.module.io
        }.getOrElse {
          npu.npu_pin1 := 0.U
          npu.npu_pin2 := 0.U
          npu.npu_pin3 := 0.U
          npu.npu_pin4 := 0.U
        }
        npu
      }
      Some(npuIO)
    }
    case None => None
  }
}

// Mixin for the module implementation
trait CanHavePeripheryNPUModuleImp extends LazyModuleImp {
  val outer: CanHavePeripheryNPU
  
  // Expose NPU device if needed
  val npuPeripheralOpt = outer.npuPeripheral.map { device =>
    device
  }
}

// Config fragment to enable the NPU device
class WithNPUPeripheral(
  address: BigInt = 0x10050000,
  size: BigInt = 0x40
) extends Config((site, here, up) => {
  case PeripheralNPUKey => Some(PeripheralNPUParams(
    address = address,
    size = size
  ))
})
