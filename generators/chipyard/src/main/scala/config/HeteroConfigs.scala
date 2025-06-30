package chipyard

import org.chipsalliance.cde.config.{Config}
import freechips.rocketchip.guardiancouncil._
import freechips.rocketchip.prci.{AsynchronousCrossing}
import freechips.rocketchip.subsystem.{InCluster}
import freechips.rocketchip.tile._
import peripheral._

// ---------------------
// Heterogenous Configs
// ---------------------
class LargeBoomAndRocketConfig extends Config(
  new boom.v3.common.WithNLargeBooms(1) ++                    // single-core boom
  new freechips.rocketchip.rocket.WithNHugeCores(1) ++         // single rocket-core
  new chipyard.config.WithSystemBusWidth(128) ++
  new chipyard.config.AbstractConfig)

class DualLargeBoomAndDualRocketConfig extends Config(
  new boom.v3.common.WithNLargeBooms(2) ++             // add 2 boom cores
  new freechips.rocketchip.rocket.WithNHugeCores(2) ++  // add 2 rocket cores
  new chipyard.config.WithSystemBusWidth(128) ++
  new chipyard.config.AbstractConfig)

// DOC include start: DualBoomAndSingleRocket
class DualLargeBoomAndSingleRocketConfig extends Config(
  new boom.v3.common.WithNLargeBooms(2) ++             // add 2 boom cores
  new freechips.rocketchip.rocket.WithNHugeCores(1) ++  // add 1 rocket core
  new chipyard.config.WithSystemBusWidth(128) ++
  new chipyard.config.AbstractConfig)
// DOC include end: DualBoomAndSingleRocket

class LargeBoomAndRocketWithControlCoreConfig extends Config(
  new freechips.rocketchip.rocket.WithNSmallCores(1) ++    // Add a small "control" core
  new boom.v3.common.WithNLargeBooms(1) ++                 // Add 1 boom core
  new freechips.rocketchip.rocket.WithNHugeCores(1) ++      // add 1 rocket core
  new chipyard.config.WithSystemBusWidth(128) ++
  new chipyard.config.AbstractConfig)

/*
 * Voyager Config
 */

class GemminiPrefetchConfig extends Config(
  new barf.WithHellaCachePrefetcher(Seq(5), barf.SingleStridedPrefetcherParams()) ++   // strided prefetcher, sits in front of the L1D$, monitors core requests to prefetching into the L1D$
  new freechips.rocketchip.rocket.WithNBigNpuCores(1) ++ //independent Rocket for gemmini: hartid 5
  new chipyard.config.WithMultiRoCCNpu ++
  new chipyard.config.WithMultiRoCCGemmini(5)(gemmini.GemminiConfigs.defaultConfig) ++ // put gemmini on hart-5(rocket)
  new freechips.rocketchip.rocket.WithL1DCacheNonblocking(16) ++
  new chipyard.config.AbstractConfig
)

// class OurMutiCoreConfig extends Config(
//   new freechips.rocketchip.rocket.WithNBigCores(4) ++ //Rocket for Boom:hartid 1-4
//   new boom.v3.common.WithNLargeBooms(1) ++ //Boom:hartid 0
//   new chipyard.config.WithMultiRoCC ++
//   new chipyard.config.WithMultiSingleRoCCExample(0, 1, 2, 3, 4) ++ //put custom RoCC on hart0-4 for custom0 ISA extension
//   new freechips.rocketchip.rocket.WithL1DCacheNonblocking(0)
// )

class OurHeterSoCConfig extends Config(
  // new chipyard.config.WithTileFrequency(100, Some(0)) ++
  // new chipyard.config.WithTileFrequency(100, Some(1)) ++
  // new chipyard.config.WithTileFrequency(100, Some(2)) ++
  // new chipyard.config.WithTileFrequency(100, Some(3)) ++
  // new chipyard.config.WithTileFrequency(100, Some(4)) ++
  // new chipyard.config.WithTileFrequency(100, Some(5)) ++
  new chipyard.config.WithTileFrequency(1000, Some(0)) ++
  new chipyard.config.WithTileFrequency(500, Some(1)) ++
  new chipyard.config.WithTileFrequency(500, Some(2)) ++
  new chipyard.config.WithTileFrequency(500, Some(3)) ++
  new chipyard.config.WithTileFrequency(500, Some(4)) ++
  new chipyard.config.WithTileFrequency(500, Some(5)) ++
  new freechips.rocketchip.guardiancouncil.WithGuardianCouncilNodes++
  // new barf.WithHellaCachePrefetcher(Seq(5), barf.SingleStridedPrefetcherParams()) ++   // strided prefetcher, sits in front of the L1D$, monitors core requests to prefetching into the L1D$
  
  // new freechips.rocketchip.rocket.WithNBigNpuCores(1, nMSHRs = 16) ++ //independent Rocket for gemmini: hartid 5, with non-blocking L1D$
  // new chipyard.config.WithMultiRoCCNpu ++
  // new chipyard.config.WithMultiRoCCGemmini(5)(gemmini.GemminiConfigs.defaultConfig) ++ // put gemmini on hart-5(rocket)
  new freechips.rocketchip.rocket.WithNBuckyBallCores(1) ++ //independent Rocket for gemmini: hartid 5, with non-blocking L1D$
  new chipyard.config.WithMultiRoCCBB ++
  new chipyard.config.WithMultiRoCCBuckyBall(5)(buckyball.BuckyBallConfigs.defaultConfig) ++ // put gemmini on hart-5(rocket)
  
  new chipyard.config.WithMultiRoCCMEEK ++
  new chipyard.config.WithMultiSingleRoCCGHE(0, 1, 2, 3, 4) ++ //put custom RoCC on hart0-4 for custom0 ISA extension ++
  new freechips.rocketchip.subsystem.WithInclusiveCache(capacityKB = 256) ++ //256KB L2Cache
  new chipyard.config.WithSystemBusWidth(128) ++
  new freechips.rocketchip.rocket.WithMEEKAsynchronousCDCs(
  AsynchronousCrossing().depth,
  AsynchronousCrossing().sourceSync) ++
  // Frequency specifications
  new chipyard.clocking.WithClockGroupsCombinedByName(("uncore",Seq("sbus", "mbus", "pbus", "fbus", "cbus", "obus", "implicit", "clock_tap"),Nil),
                                                      ("boom",Seq("tile_0"),Nil),//大核
                                                      ("rockettile",Seq("tile_1","tile_2","tile_3","tile_4","tile_5"),Nil)//meek小核
                                                      // ("gemini",Seq("tile_5"),Nil)
                                                      )++
  //  Crossing specifications
  new freechips.rocketchip.rocket.WithMEEKCores(GH_GlobalParams.GH_NUM_CORES - 1) ++
  new boom.meek.common.WithNLargeBooms(1) ++
  new peripheral.WithMyPeripheral(0x10050000, 0x1000) ++
  new chipyard.config.AbstractConfig
)

//hart id 从下到上依次增加（和cde机制有关）
class TestHeterSoCConfig extends Config(
  new chipyard.config.WithTileFrequency(100, Some(0)) ++
  new chipyard.config.WithTileFrequency(50, Some(1)) ++
  new chipyard.config.WithTileFrequency(50, Some(2)) ++
  new chipyard.config.WithTileFrequency(50, Some(3)) ++
  new chipyard.config.WithTileFrequency(50, Some(4)) ++
  new chipyard.config.WithTileFrequency(50, Some(5)) ++
  new freechips.rocketchip.guardiancouncil.WithGuardianCouncilNodes++
  new barf.WithHellaCachePrefetcher(Seq(5), barf.SingleStridedPrefetcherParams()) ++   // strided prefetcher, sits in front of the L1D$, monitors core requests to prefetching into the L1D$
  
  // new freechips.rocketchip.rocket.WithNBigNpuCores(1, nMSHRs = 16) ++ //independent Rocket for gemmini: hartid 5, with non-blocking L1D$
  // new chipyard.config.WithMultiRoCCNpu ++
  // new chipyard.config.WithMultiRoCCGemmini(5)(gemmini.GemminiConfigs.defaultConfig) ++ // put gemmini on hart-5(rocket)
  new freechips.rocketchip.rocket.WithNBuckyBallCores(1, nMSHRs = 16) ++ //independent Rocket for buckyball: hartid 5, with non-blocking L1D$
  new chipyard.config.WithMultiRoCCBB ++
  new chipyard.config.WithMultiRoCCBuckyBall(5)(buckyball.BuckyBallConfigs.defaultConfig) ++ // put buckyball on hart-5(rocket)
  
  new chipyard.config.WithMultiRoCCMEEK ++
  new chipyard.config.WithMultiSingleRoCCGHE(0, 1, 2, 3, 4) ++ //put custom RoCC on hart0-4 for custom0 ISA extension ++
  new freechips.rocketchip.subsystem.WithInclusiveCache(capacityKB = 256) ++ //256KB L2Cache
  new chipyard.config.WithSystemBusWidth(128) ++
  new freechips.rocketchip.rocket.WithMEEKAsynchronousCDCs(
  AsynchronousCrossing().depth,
  AsynchronousCrossing().sourceSync) ++
  // Frequency specifications
  new chipyard.clocking.WithClockGroupsCombinedByName(("uncore",Seq("sbus", "mbus", "pbus", "fbus", "cbus", "obus", "implicit", "clock_tap"),Nil),
                                                      ("boom",Seq("tile_0"),Nil),//大核
                                                      ("rockettile",Seq("tile_1","tile_2","tile_3","tile_4","tile_5"),Nil)//meek小核
                                                      // ("gemmini",Seq("tile_5"),Nil)
                                                      )++
  //  Crossing specifications
  new freechips.rocketchip.rocket.WithMEEKCores(GH_GlobalParams.GH_NUM_CORES - 1) ++
  new boom.meek.common.WithNLargeBooms(1) ++
  new chipyard.config.AbstractConfig
)

// BuckyBall配置
class BuckyBallRocketConfig extends Config(
  new freechips.rocketchip.rocket.WithNBuckyBallCores(1) ++      
  new chipyard.config.WithMultiRoCCBB ++
  new chipyard.config.WithMultiRoCCBuckyBall(0)(buckyball.BuckyBallConfigs.defaultConfig) ++
  new chipyard.config.WithSystemBusWidth(128) ++
  new peripheral.WithMyPeripheral(0x10050000, 0x40) ++
  new chipyard.config.AbstractConfig
)
