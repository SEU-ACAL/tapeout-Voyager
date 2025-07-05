package voyager_tapeout.verilator

import org.chipsalliance.cde.config.{Config}
import freechips.rocketchip.guardiancouncil._
import freechips.rocketchip.prci.{AsynchronousCrossing}
import freechips.rocketchip.subsystem.{InCluster}
import freechips.rocketchip.tile._
import peripheral._

class VoyagerVerilatorHarnessConfig extends Config(
  new chipyard.config.WithTileFrequency(100, Some(0)) ++
  new chipyard.config.WithTileFrequency(100, Some(1)) ++
  new chipyard.config.WithTileFrequency(100, Some(2)) ++
  new chipyard.config.WithTileFrequency(100, Some(3)) ++
  new chipyard.config.WithTileFrequency(100, Some(4)) ++
  new chipyard.config.WithTileFrequency(100, Some(5)) ++
  new freechips.rocketchip.guardiancouncil.WithGuardianCouncilNodes++

  new freechips.rocketchip.rocket.WithNBuckyBallCores(1) ++ //independent Rocket for gemmini: hartid 5, with non-blocking L1D$
  new chipyard.config.WithMultiRoCCBB ++
  new chipyard.config.WithMultiRoCCBuckyBall(5)(buckyball.BuckyBallConfigs.defaultConfig) ++ // put gemmini on hart-5(rocket)
  
  new chipyard.config.WithMultiRoCCMEEK ++
  new chipyard.config.WithMultiSingleRoCCGHE(0, 1, 2, 3, 4) ++ //put custom RoCC on hart0-4 for custom0 ISA extension ++
  new freechips.rocketchip.subsystem.WithInclusiveCache(capacityKB = 256) ++ //256KB L2Cache
  new chipyard.config.WithSystemBusWidth(128) ++
  // new freechips.rocketchip.rocket.WithMEEKAsynchronousCDCs(
  // AsynchronousCrossing().depth,
  // AsynchronousCrossing().sourceSync) ++
  // Frequency specifications
  new chipyard.clocking.WithClockGroupsCombinedByName(("uncore",Seq("sbus", "mbus", "pbus", "fbus", "cbus", "obus", "implicit", "clock_tap"),Nil),
                                                      ("boom",Seq("tile_0"),Nil),//大核
                                                      ("rockettile",Seq("tile_1","tile_2","tile_3","tile_4","tile_5"),Nil)//meek小核
                                                      )++
  //  Crossing specifications+-
  new freechips.rocketchip.rocket.WithMEEKCores(GH_GlobalParams.GH_NUM_CORES - 1) ++
  new boom.meek.common.WithNLargeBooms(1) ++
  new peripheral.WithMyPeripheral(0x10050000, 0x1000) ++
  new chipyard.config.AbstractConfig
)
