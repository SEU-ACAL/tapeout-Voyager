package voyager_tapeout.custom

import org.chipsalliance.cde.config.{Config, Parameters}
import freechips.rocketchip.diplomacy.LazyModule
import freechips.rocketchip.guardiancouncil._
import voyager_tapeout.custom.device.peripheral_npu.PeripheralNPUParams
import freechips.rocketchip.prci.{AsynchronousCrossing}

import testchipip.soc.{OBUS}
import freechips.rocketchip.subsystem.{MBUS, SBUS}
import freechips.rocketchip.resources.{SimpleDevice}
import sifive.blocks.devices.spi.{PeripherySPIKey, SPIParams, PeripherySPIFlashKey, SPIFlashParams}
import sifive.blocks.devices.uart.{PeripheryUARTKey, UARTParams}
import freechips.rocketchip.util._
class WithCustomClockGateModel(file: String = "/ip/clock/EICG_wrapper.v") extends Config((site, here, up) => {
  case ClockGateModelFile => Some(file)
})

// Custom SPI configurations to avoid name conflicts
class WithSPIForFlash(address: BigInt = 0x10030000, fAddress: BigInt = 0x20000000, size: BigInt = 0x800000) extends Config((site, here, up) => {
  case PeripherySPIFlashKey => up(PeripherySPIFlashKey) ++ Seq(
    SPIFlashParams(rAddress = address, fAddress = fAddress, fSize = size))
})

class WithSPIForSD(address: BigInt = 0x10031000) extends Config((site, here, up) => {
  case PeripherySPIKey => up(PeripherySPIKey) ++ Seq(
    SPIParams(rAddress = address))
})

class WithUART1(baudrate: BigInt = 4800, address: BigInt = 0x10021000, txEntries: Int = 8, rxEntries: Int = 8) extends Config((site, here, up) => {
  case PeripheryUARTKey => up(PeripheryUARTKey) ++ Seq(
    UARTParams(address = address, nTxEntries = txEntries, nRxEntries = rxEntries, initBaudRate = baudrate))
})

// class WithUART2(baudrate: BigInt = 115200, address: BigInt = 0x10022000, txEntries: Int = 8, rxEntries: Int = 8) extends Config((site, here, up) => {
//   case PeripheryUARTKey => up(PeripheryUARTKey) ++ Seq(
//     UARTParams(address = address, nTxEntries = txEntries, nRxEntries = rxEntries, initBaudRate = baudrate))
// })

// class WithUART3(baudrate: BigInt = 115200, address: BigInt = 0x10023000, txEntries: Int = 8, rxEntries: Int = 8) extends Config((site, here, up) => {
//   case PeripheryUARTKey => up(PeripheryUARTKey) ++ Seq(
//     UARTParams(address = address, nTxEntries = txEntries, nRxEntries = rxEntries, initBaudRate = baudrate))
// })




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
  new freechips.rocketchip.rocket.WithMEEKCores(GH_GlobalParams.GH_NUM_CORES - 1) ++
  new boom.meek.common.WithNMediumBooms(1) ++
  new chipyard.config.WithGPIO(width=9) ++
  // new chipyard.config.WithSPI ++
  // new voyager_tapeout.custom.WithUART1 ++
  // new voyager_tapeout.custom.WithUART2 ++
  // new voyager_tapeout.custom.WithUART3 ++
  new voyager_tapeout.custom.WithSPIForSD ++
  new voyager_tapeout.custom.iobinders.WithSPISDIOCells 
  // new voyager_tapeout.custom.WithCustomClockGateModel
  // new voyager_tapeout.custom.WithSPIForFlash ++
  // new chipyard.iobinders.WithSPIFlashIOCells 
  // NPUPeripheral
  // new chipyard.config.AbstractConfig
)

class WithNPU extends Config (
  new voyager_tapeout.custom.harness.WithPeripheralNPUPin ++ // 连接harness和npu到chiptop的pin
  new voyager_tapeout.custom.iobinders.WithPeripheralNPUIOCell ++ // 连接npu和chiptop的pin
  new voyager_tapeout.custom.device.peripheral_npu.WithNPUPeripheral (voyager_tapeout.custom.device.peripheral_npu.PeripheralNPUParams(0x10050000, 0x25000, 4))   // 连接npu和pbus的pin 
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