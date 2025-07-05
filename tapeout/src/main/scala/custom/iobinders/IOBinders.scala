package voyager_tapeout.custom.iobinders

import chisel3._
import chisel3.reflect.DataMirror
import chisel3.experimental.Analog

import org.chipsalliance.cde.config._
import org.chipsalliance.diplomacy._
import org.chipsalliance.diplomacy.nodes._
import org.chipsalliance.diplomacy.aop._
import org.chipsalliance.diplomacy.lazymodule._
import org.chipsalliance.diplomacy.bundlebridge._
import freechips.rocketchip.diplomacy.{Resource, ResourceBinding, ResourceAddress}
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.jtag.{JTAGIO}
import freechips.rocketchip.subsystem._
import freechips.rocketchip.system.{SimAXIMem}
import freechips.rocketchip.amba.axi4.{AXI4Bundle, AXI4SlaveNode, AXI4MasterNode, AXI4EdgeParameters}
import freechips.rocketchip.util._
import freechips.rocketchip.prci._
import freechips.rocketchip.groundtest.{GroundTestSubsystemModuleImp, GroundTestSubsystem}
import freechips.rocketchip.tilelink.{TLBundle}

import sifive.blocks.devices.gpio._
import sifive.blocks.devices.uart._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.i2c._
import tracegen.{TraceGenSystemModuleImp}

import chipyard.iocell._

import voyager_tapeout.custom.device.peripheral_npu.{CanHavePeripheryNPU, PeripheralNPUPunchthroughIO}
import voyager_tapeout.custom.iobinders.Port

import scala.reflect.{ClassTag}

object IOBinderTypes {
  type IOBinderTuple = (Seq[Port[_]], Seq[IOCell])
  type IOBinderFunction = (Boolean, => Any) => ModuleValue[IOBinderTuple]
}
import IOBinderTypes._

// System for instantiating binders based
// on the scala type of the Target (_not_ its IO). This avoids needing to
// duplicate harnesses (essentially test harnesses) for each target.

// IOBinders is map between string representations of traits to the desired
// IO connection behavior for tops matching that trait. We use strings to enable
// composition and overriding of IOBinders, much like how normal Keys in the config
// system are used/ At elaboration, the testharness traverses this set of functions,
// and functions which match the type of the DigitalTop are evaluated.

// You can add your own binder by adding a new (key, fn) pair, typically by using
// the OverrideIOBinder or ComposeIOBinder macros
case object IOBinders extends Field[Map[String, Seq[IOBinderFunction]]](
  Map[String, Seq[IOBinderFunction]]().withDefaultValue(Nil)
)

class IOBinder[T](composer: Seq[IOBinderFunction] => Seq[IOBinderFunction])(implicit tag: ClassTag[T]) extends Config((site, here, up) => {
  case IOBinders => {
    val upMap = up(IOBinders)
    upMap + (tag.runtimeClass.toString -> composer(upMap(tag.runtimeClass.toString)))
  }
})

class ConcreteIOBinder[T](composes: Boolean, fn: T => IOBinderTuple)(implicit tag: ClassTag[T]) extends IOBinder[T](
  up => (if (composes) up else Nil) ++ Seq(((_, t) => { InModuleBody {
    t match {
      case system: T => fn(system)
      case _ => (Nil, Nil)
    }
  }}): IOBinderFunction)
)

// The "Override" binders override any previous IOBinders (lazy or concrete) defined on the same trait.
// The "Compose" binders do not override previously defined IOBinders on the same trait
// The default IOBinders evaluate only in the concrete "ModuleImp" phase of elaboration
// The "Lazy" IOBinders evaluate in the LazyModule phase, but can also generate hardware through InModuleBody

class OverrideIOBinder[T](fn: T => IOBinderTuple)(implicit tag: ClassTag[T]) extends ConcreteIOBinder[T](false, fn)
class ComposeIOBinder[T](fn: T => IOBinderTuple)(implicit tag: ClassTag[T]) extends ConcreteIOBinder[T](true, fn)

class WithPeripheralNPUPunchthrough extends OverrideIOBinder({
  (system: CanHavePeripheryNPU) => system.npuPeripheralIO.map { npu =>
    val io_device_npu = IO(new PeripheralNPUPunchthroughIO).suggestName("npu_peripheral")
    io_device_npu <> npu
    (Seq(PeripheralNPUPort(() => io_device_npu)), Nil)
  }.getOrElse((Nil, Nil))
})
