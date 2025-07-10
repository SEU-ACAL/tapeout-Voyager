package voyager_tapeout.custom.harness

import chisel3._
import scala.collection.mutable.{ArrayBuffer, LinkedHashMap}
import freechips.rocketchip.diplomacy.{LazyModule}
import org.chipsalliance.cde.config.{Field, Parameters, Config}
import freechips.rocketchip.util.{ResetCatchAndSync, DontTouch}
import chipyard.stage.phases.TargetDirKey
import chipyard.harness.{ApplyHarnessBinders, ApplyMultiHarnessBinders}
import chipyard.iobinders.HasChipyardPorts

trait HasCustomHarnessInstantiators extends chipyard.harness.HasHarnessInstantiators {
  // 继承原有的抽象成员
  def referenceClockFreqMHz: Double
  def referenceClock: Clock
  def referenceReset: Reset
  def success: Bool
  
  // 重写instantiateChipTops方法，确保this是HasCustomHarnessInstantiators类型
  override def instantiateChipTops(): Seq[LazyModule] = {
    require(p(chipyard.harness.MultiChipNChips).isEmpty || supportsMultiChip,
      s"Selected Harness does not support multi-chip")

    val lazyDuts = chipParameters.zipWithIndex.map { case (q,i) =>
      LazyModule(q(chipyard.harness.BuildTop)(q)).suggestName(s"chiptop$i")
    }
    val duts = lazyDuts.map(l => Module(l.module))

    withClockAndReset (harnessBinderClock, harnessBinderReset) {
      lazyDuts.zipWithIndex.foreach {
        case (d: HasChipyardPorts, i: Int) => {
          // 关键：这里的this是HasCustomHarnessInstantiators类型
          ApplyHarnessBinders(this, d.ports, i)(chipParameters(i))
        }
        case _ =>
      }
      ApplyMultiHarnessBinders(this, lazyDuts)
    }

    if (p(chipyard.harness.DontTouchChipTopPorts)) {
      duts.map(_ match {
        case d: DontTouch => d.dontTouchPorts()
        case _ =>
      })
    }

    val harnessBinderClk = harnessClockInstantiator.requestClockMHz("harnessbinder_clock", getHarnessBinderClockFreqMHz)
    println(s"Harness binder clock is ${getHarnessBinderClockFreqMHz}")
    harnessBinderClock := harnessBinderClk
    harnessBinderReset := ResetCatchAndSync(harnessBinderClk, referenceReset.asBool)

    harnessClockInstantiator.instantiateHarnessClocks(referenceClock, referenceClockFreqMHz)

    lazyDuts
  }
}

