package freechips.rocketchip.boom_perf

import org.chipsalliance.cde.config._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.tile._

class WithPERF extends Config((site, here, up) => {
    case BuildRoCC=> List(
    (p: Parameters) => {
        val perf = LazyModule(new PERF(OpcodeSet.custom1)(p))
        perf
    })
    case HasPERF => true
})
