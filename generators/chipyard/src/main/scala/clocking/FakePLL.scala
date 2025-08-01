package chipyard.clocking

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.regmapper._
import freechips.rocketchip.util._

class FakePLLCtrlBundle extends Bundle {
  val gate = Bool()
  val power = Bool()
  val ref_div = UInt(6.W) // Reference divider input
  val fb_div_int = UInt(12.W) // Feedback divider input
  val clk_div1 = UInt(3.W) // Clock divider input
}
class FakePLLCtrlInBundle extends Bundle {
  val lock = Bool()
}
class FakePLLCtrl(address: BigInt, beatBytes: Int)(implicit p: Parameters) extends LazyModule
{
  val device = new SimpleDevice(s"pll", Nil)
  val tlNode = TLRegisterNode(Seq(AddressSet(address, 4096-1)), device, "reg/control", beatBytes=beatBytes)
  val ctrlNode = BundleBridgeSource(() => Output(new FakePLLCtrlBundle))
  val ctrlInNode = BundleBridgeSink(Some(() => (new FakePLLCtrlInBundle)))
  lazy val module = new LazyModuleImp(this) {
    // This PLL only has 2 address, the gate and power
    // Both should be set to turn on the PLL
    // TODO: Should these be reset by the top level reset pin?
    val gate_reg = Module(new AsyncResetRegVec(w=1, init=0))
    val power_reg = Module(new AsyncResetRegVec(w=1, init=0))
    val lock_reg  = Module(new AsyncResetRegVec(w=1, init=0))
    val ref_div_reg = Module(new AsyncResetRegVec(w=6, init=4))
    val fb_div_int_reg = Module(new AsyncResetRegVec(w=12, init=40))
    val clk_div1_reg = Module(new AsyncResetRegVec(w=3, init=2))
    ctrlNode.out(0)._1.gate := gate_reg.io.q
    ctrlNode.out(0)._1.power := power_reg.io.q
    ctrlNode.out(0)._1.ref_div := ref_div_reg.io.q
    ctrlNode.out(0)._1.fb_div_int := fb_div_int_reg.io.q
    ctrlNode.out(0)._1.clk_div1 := clk_div1_reg.io.q
    lock_reg.io.d  := ctrlInNode.in(0)._1.lock// PLL is always locked in this fake implementation
    lock_reg.io.en := ctrlInNode.in(0)._1.lock// PLL is always locked in this fake implementation
    tlNode.regmap(
      0 -> Seq(RegField.rwReg(1, gate_reg.io)),
      4 -> Seq(RegField.rwReg(1, power_reg.io)),
      8 -> Seq(RegField.r(1, lock_reg.io.q)),
      12 -> Seq(RegField.rwReg(6, ref_div_reg.io)),
      16 -> Seq(RegField.rwReg(12, fb_div_int_reg.io)),
      20 -> Seq(RegField.rwReg(3, clk_div1_reg.io))
    )
  }
}
