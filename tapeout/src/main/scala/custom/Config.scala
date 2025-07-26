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
  new freechips.rocketchip.guardiancouncil.WithGuardianCouncilNodes ++
  new freechips.rocketchip.guardiancouncil.WithDisableROBDebug ++

  new freechips.rocketchip.rocket.WithNBuckyBallCores(1) ++ //independent Rocket for buckyball: hartid 3
  new chipyard.config.WithMultiRoCCBB ++
  new chipyard.config.WithMultiRoCCBuckyBall(3)(buckyball.BuckyBallConfigs.defaultConfig) ++ // put buckyball on hart-3 (rocket)
  
  new chipyard.config.WithMultiRoCCMEEK ++
  new chipyard.config.WithMultiSingleRoCCGHE(0, 1, 2) ++ //put custom RoCC on hart0-2 for custom0 ISA extension ++
  new freechips.rocketchip.subsystem.WithInclusiveCache(capacityKB = 32) ++ // 64 KB L2Cache
  new chipyard.config.WithSystemBusWidth(128) ++
  // new freechips.rocketchip.rocket.WithMEEKAsynchronousCDCs(
  //   AsynchronousCrossing().depth,
  //   AsynchronousCrossing().sourceSync) ++
  //  Crossing specifications+-
  new freechips.rocketchip.rocket.WithMEEKCores(GH_GlobalParams.GH_NUM_CORES - 1) ++
  new boom.meek.common.WithNMediumBooms(1) ++
  new chipyard.config.WithGPIO(width=12)  ++
  new chipyard.config.WithSPI ++
  // new voyager_tapeout.custom.harness.WithSimSPIModel++
  new voyager_tapeout.custom.iobinders.WithSPIIOCells
  // NPUPeripheral
  // new chipyard.config.AbstractConfig
)

class WithNPU extends Config (
  new voyager_tapeout.custom.harness.WithPeripheralNPUPin ++ // 连接harness和npu到chiptop的pin
  new voyager_tapeout.custom.iobinders.WithPeripheralNPUIOCell ++ // 连接npu和chiptop的pin
  new voyager_tapeout.custom.device.peripheral_npu.WithNPUPeripheral(voyager_tapeout.custom.device.peripheral_npu.PeripheralNPUParams(0x10050000, 0x25000, 4))   // 连接npu和pbus的pin 
)
//Chip config
class WithSerialConnect extends Config (
  new testchipip.serdes.WithSerialTLMem(size = BigInt("10000000",16)) ++ // 8 GB of off-chip memory
  new testchipip.serdes.WithSerialTLPHYParams(
  testchipip.serdes.ExternalSyncSerialPhyParams(phitWidth=4, flitWidth=4))++ 
  new chipyard.config.WithSerialBackingMemory  ++
  new testchipip.soc.WithOffchipBusClient(MBUS) ++                                      // offchip bus connects to MBUS, since the serial-tl needs to provide backing memory
  new testchipip.soc.WithOffchipBus
)

class WithSerialDebugConnect extends Config (
  new testchipip.serdes.WithSerialTLMem(size = BigInt("10000000",16)) ++ // 8 GB of off-chip memory
  new testchipip.serdes.WithSerialTLPHYParams(
  testchipip.serdes.ExternalSyncSerialPhyParams(phitWidth=64, flitWidth=64))++ 
  new chipyard.config.WithSerialBackingMemory  ++
  new testchipip.soc.WithOffchipBusClient(MBUS) ++                                      // offchip bus connects to MBUS, since the serial-tl needs to provide backing memory
  new testchipip.soc.WithOffchipBus
)
