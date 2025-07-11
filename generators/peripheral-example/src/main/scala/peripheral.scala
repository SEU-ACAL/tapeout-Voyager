package peripheral

import chisel3._
import chisel3.util._

import org.chipsalliance.cde.config._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.regmapper._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.amba.axi4._
import freechips.rocketchip.util._
import freechips.rocketchip.prci._

// Configuration parameters for the device
case class MyPeripheralParams(
  address: BigInt,
  size: BigInt = 0x40,
  beatBytes: Int = 8
)

case object MyPeripheralKey extends Field[Option[MyPeripheralParams]](None)

// IO trait for the peripheral 拉到ChipTop的IO
class MyPeripheralTopIO extends Bundle {
  val my_peripheral_status = Output(UInt(32.W))
}

// The actual device implementation
class MyPeripheral(params: MyPeripheralParams)(implicit p: Parameters) extends ClockSinkDomain(ClockSinkParameters())(p) {
  
  // Create AXI4 register node that will handle the register mapping
  val regnode = AXI4RegisterNode(
    address = AddressSet(params.address, params.size-1),
    executable = false,
    beatBytes = params.beatBytes
  )

  override lazy val module = new MyPeripheralModuleImp(this)
  
  class MyPeripheralModuleImp(outer: MyPeripheral) extends Impl {
    val io = IO(new MyPeripheralTopIO)
    
    withClockAndReset(clock, reset) {
      // Create some example registers
      val control = RegInit(0.U(32.W))
      val status = RegInit(0.U(32.W))
      val data0 = RegInit(0.U(32.W))
      val data1 = RegInit(0.U(32.W))
      
      // Simple counter for demonstration
      val counter = RegInit(0.U(32.W))
      counter := counter + 1.U
      status := counter
      
      // Connect status to IO
      io.my_peripheral_status := status
      
      // Create the register mapping
      outer.regnode.regmap(
        0x00 -> Seq(RegField(32, control, RegFieldDesc("control", "Control register"))),
        0x04 -> Seq(RegField.r(32, status, RegFieldDesc("status", "Status register (read-only)"))),
        0x08 -> Seq(RegField(32, data0, RegFieldDesc("data0", "Data register 0"))),
        0x0C -> Seq(RegField(32, data1, RegFieldDesc("data1", "Data register 1")))
      )
    }
  }
}

// Trait to add the device to the subsystem
trait CanHavePeripheryMyPeripheral { this: BaseSubsystem =>
  private val portName = "my-peripheral"
  private val pbus = locateTLBusWrapper(PBUS)
  
  val myPeripheral = p(MyPeripheralKey).map { params =>
    val device = LazyModule(new MyPeripheral(params.copy(beatBytes = pbus.beatBytes)))
    // 添加时钟连接
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
  
  // Expose status signal for IOBinder
  val myPeripheralStatus = p(MyPeripheralKey) match {
    case Some(params) => {
      val statusSignal = InModuleBody {
        val status = IO(Output(UInt(32.W))).suggestName("my_peripheral_status")
        myPeripheral.map { device =>
          status := device.module.io.my_peripheral_status
        }.getOrElse {
          status := 0.U
        }
        status
      }
      Some(statusSignal)
    }
    case None => None
  }
}

// Mixin for the module implementation
trait CanHavePeripheryMyPeripheralModuleImp extends LazyModuleImp {
  val outer: CanHavePeripheryMyPeripheral
  
  // Expose any signals you need here
  val myPeripheralOpt = outer.myPeripheral.map { device =>
    // You can expose internal signals here if needed
    device
  }
}

// Config fragment to enable the device
class WithMyPeripheral(
  address: BigInt = 0x10050000,
  size: BigInt = 0x40
) extends Config((site, here, up) => {
  case MyPeripheralKey => Some(MyPeripheralParams(
    address = address,
    size = size
  ))
})
