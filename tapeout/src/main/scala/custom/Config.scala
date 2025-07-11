package voyager_tapeout.custom

import org.chipsalliance.cde.config.{Config, Parameters}
import freechips.rocketchip.diplomacy.LazyModule
import freechips.rocketchip.guardiancouncil._
import voyager_tapeout.custom.device.peripheral_npu.PeripheralNPUParams
import freechips.rocketchip.prci.{AsynchronousCrossing}

import testchipip.soc.{OBUS}
import freechips.rocketchip.subsystem.{MBUS, SBUS}


class OurHeterSoCConfig extends Config(
  new chipyard.config.WithTileFrequency(100, Some(0)) ++
  new chipyard.config.WithTileFrequency(100, Some(1)) ++
  new chipyard.config.WithTileFrequency(100, Some(2)) ++
  new chipyard.config.WithTileFrequency(100, Some(3)) ++
  new chipyard.config.WithTileFrequency(100, Some(4)) ++
  new chipyard.config.WithTileFrequency(100, Some(5)) ++
  new freechips.rocketchip.guardiancouncil.WithGuardianCouncilNodes++

  new freechips.rocketchip.rocket.WithNBuckyBallCores(1) ++ //independent Rocket for buckyball: hartid 5
  new chipyard.config.WithMultiRoCCBB ++
  new chipyard.config.WithMultiRoCCBuckyBall(5)(buckyball.BuckyBallConfigs.defaultConfig) ++ // put buckyball on hart-5(rocket)
  
  new chipyard.config.WithMultiRoCCMEEK ++
  new chipyard.config.WithMultiSingleRoCCGHE(0, 1, 2, 3, 4) ++ //put custom RoCC on hart0-4 for custom0 ISA extension ++
  new freechips.rocketchip.subsystem.WithInclusiveCache(capacityKB = 256) ++ //256KB L2Cache
  new chipyard.config.WithSystemBusWidth(128) ++
  // new freechips.rocketchip.rocket.WithMEEKAsynchronousCDCs(
  //   AsynchronousCrossing().depth,
  //   AsynchronousCrossing().sourceSync) ++
  //  Crossing specifications+-
  new freechips.rocketchip.rocket.WithMEEKCores(GH_GlobalParams.GH_NUM_CORES - 1) ++
  new boom.meek.common.WithNLargeBooms(1) ++
  new chipyard.config.WithGPIO(width=12)  ++
  // NPUPeripheral
  new voyager_tapeout.custom.harness.WithPeripheralNPUPin ++ // 连接harness和npu到chiptop的pin
  new voyager_tapeout.custom.iobinders.WithPeripheralNPUIOCell ++ // 连接npu和chiptop的pin
  new voyager_tapeout.custom.device.peripheral_npu.WithNPUPeripheral(voyager_tapeout.custom.device.peripheral_npu.PeripheralNPUParams(0x10050000, 0x1000))   // 连接npu和pbus的pin 
                                                  // attach a offchip bus, since the serial-tl will master some external tilelink memory

  // new chipyard.config.AbstractConfig
)

class WithSerialConnect extends Config (
  new testchipip.serdes.WithSerialTLMem(size = BigInt("10000000",16)) ++ // 8 GB of off-chip memory
  new testchipip.serdes.WithSerialTLWidth(4)++
  new chipyard.config.WithSerialBackingMemory  ++
  new testchipip.soc.WithOffchipBusClient(MBUS) ++                                      // offchip bus connects to MBUS, since the serial-tl needs to provide backing memory
  new testchipip.soc.WithOffchipBus
)
