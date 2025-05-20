package chipyard.config

import chisel3._

import org.chipsalliance.cde.config.{Field, Parameters, Config}
import freechips.rocketchip.tile._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.npu._
import freechips.rocketchip.meek._
import freechips.rocketchip.guardiancouncil._
import gemmini._

import chipyard.{TestSuitesKey, TestSuiteHelper}

/**
 * Map from a tileId to a particular RoCC accelerator
 */
case object MultiRoCCKey extends Field[Map[Int, Seq[Parameters => LazyRoCC]]](Map.empty[Int, Seq[Parameters => LazyRoCC]])
case object MultiRoCCNpuKey extends Field[Map[Int, Seq[Parameters => LazyRoCCNpu]]](Map.empty[Int, Seq[Parameters => LazyRoCCNpu]])
case object MultiRoCCMEEKKey extends Field[Map[Int, Seq[Parameters => LazyRoCCMEEK]]](Map.empty[Int, Seq[Parameters => LazyRoCCMEEK]])
/**
 * Config fragment to enable different RoCCs based on the tileId
 */
class WithMultiRoCC extends Config((site, here, up) => {
  case BuildRoCC => site(MultiRoCCKey).getOrElse(site(TileKey).tileId, Nil)
})

class WithMultiRoCCNpu extends Config((site, here, up) => {
  case BuildRoCCNpu => site(MultiRoCCNpuKey).getOrElse(site(TileKey).tileId, Nil)
})

class WithMultiRoCCMEEK extends Config((site, here, up) => {
  case BuildRoCCMEEK => site(MultiRoCCMEEKKey).getOrElse(site(TileKey).tileId, Nil)
})
/**
 * Assigns what was previously in the BuildRoCC key to specific harts with MultiRoCCKey
 * Must be paired with WithMultiRoCC
 */
class WithMultiRoCCFromBuildRoCC(harts: Int*) extends Config((site, here, up) => {
  case BuildRoCC => Nil
  case MultiRoCCKey => up(MultiRoCCKey, site) ++ harts.distinct.map { i =>
    (i -> up(BuildRoCC, site))
  }
})

class WithMultiRoCCGemmini[T <: Data : Arithmetic, U <: Data, V <: Data](
  harts: Int*)(gemminiConfig: GemminiArrayConfig[T,U,V] = GemminiConfigs.defaultConfig) extends Config((site, here, up) => {
  case MultiRoCCNpuKey => up(MultiRoCCNpuKey, site) ++ harts.distinct.map { i =>
    (i -> Seq((p: Parameters) => {
      implicit val q = p
      val gemmini = LazyModule(new Gemmini(gemminiConfig))
      gemmini
    }))
  }
})

class WithAccumulatorRoCC(op: OpcodeSet = OpcodeSet.custom1) extends Config((site, here, up) => {
  case BuildRoCC => up(BuildRoCC) ++ Seq((p: Parameters) => {
    val accumulator = LazyModule(new AccumulatorExample(op, n = 4)(p))
    accumulator
  })
})

class WithCharacterCountRoCC(op: OpcodeSet = OpcodeSet.custom2) extends Config((site, here, up) => {
  case BuildRoCC => up(BuildRoCC) ++ Seq((p: Parameters) => {
    val counter = LazyModule(new CharacterCountExample(op)(p))
    counter
  })
})

 //以官方给的accumulator为例子，后面可以换成我们自己的RoCC模块
class WithMultiSingleRoCCExample(harts: Int*) extends Config(
  new Config((site, here, up) => {
    case MultiRoCCKey => {
      up(MultiRoCCKey, site) ++ harts.distinct.map{ i =>
        (i -> Seq((p: Parameters) => {
          val accumulator = LazyModule(new AccumulatorExample(OpcodeSet.custom0, n = 4)(p))
        accumulator
        }))
      }
    }
  })
)
class WithMultiSingleRoCCGHE(harts: Int*) extends Config(
  new Config((site, here, up) => {
    case MultiRoCCMEEKKey => {
      up(MultiRoCCMEEKKey, site) ++ harts.distinct.map{ i =>
        (i -> Seq((p: Parameters) => {
          val ghe = LazyModule(new GHE(OpcodeSet.custom1)(p))
          ghe
        }))
      }
    }
  })
)