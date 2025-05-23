
package freechips.rocketchip.guardiancouncil

import org.chipsalliance.cde.config._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.tile._
import freechips.rocketchip.meek._

class WithGHE extends Config((site, here, up) => {
  case BuildRoCCMEEK => List(
    (p: Parameters) => {
        val ghe = LazyModule(new GHE(OpcodeSet.custom1)(p))
        ghe
    })
})
class WithGuardianCouncilNodes extends Config((site, here, up) => {
  case EnableGuardianCouncilNodes => true
})