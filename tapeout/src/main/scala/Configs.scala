package voyager_tapeout

import org.chipsalliance.cde.config.Config
import chipyard._
import chipyard.harness.WithSimSPIFlashModel
import freechips.rocketchip.devices.tilelink.BootROMParams
import freechips.rocketchip.devices.tilelink.{DevNullParams, BootROMLocated}
import freechips.rocketchip.subsystem.{SystemBusKey, PeripheryBusKey, ControlBusKey, ExtMem}
import scala.sys.process._
import freechips.rocketchip.subsystem.{MBUS, SBUS}
import freechips.rocketchip.diplomacy._
import testchipip.soc.{OBUS}

// class VoyagerChipConfig extends Config(
//   new voyager_tapeout.VoyagerSerialVerilatorConfig  
// )

// class WithMyBootROM (contentFileName: String) extends Config((site, here, up) => {
//   case BootROMParams =>
//     BootROMParams(contentFileName = contentFileName)
// })

class WithVoyagerBootROM extends Config((site, here, up) => {
  case BootROMLocated(x) => up(BootROMLocated(x), site).map { p =>
    // invoke makefile for sdboot
    // val freqMHz = (site(SystemBusKey).dtsFrequency.get / (1000 * 1000)).toLong
    val freqMHz = 25000000
    val make = s"make -C tapeout/boot PBUS_CLK=${freqMHz} bin"
    require (Process(make).! == 0, "Failed to build bootrom")
    p.copy(hang = 0x10000, contentFileName = s"./tapeout/boot/build/sdboot.bin")
  }
})


class VoyagerFPGAConfig extends Config(
  new voyager_tapeout.VoyagerSerialWithoutNPUFPGAConfig 
)
class VoyagerChipConfig extends Config(
  // new voyager_tapeout.VoyagerSerialFPGAConfig
  new voyager_tapeout.VoyagerVcsChipConfig
)
class VoyagerVerilatorConfig extends Config(
  // new WithMyBootROM("/home/mio/Code/Voyager/tapeout/boot/build/.img") ++
  // new chipyard.harness.WithSimSPIFlashModel(false) ++       // add the SPI flash model in the harness (writeable)
  // new chipyard.iobinders.WithSPIFlashIOCells ++
  // new voyager_tapeout.custom.WithSPIForFlash ++


  // new freechips.rocketchip.subsystem.WithNoMemPort ++

  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  // new voyager_tapeout.custom.iobinders.WithVoyagerPLLSelectorDividerClockGenerator(enable=false)++
  new voyager_tapeout.custom.WithNPU ++
  
  // new chipyard.config.WithSPIFlash(0x100000) ++ 
  
  new chipyard.config.AbstractConfig)
class VoyagerVcsConfig1 extends Config(
  // new voyager_tapeout.custom.WithSPIForFlash ++
  // new voyager_tapeout.custom.WithSPIForSD ++
  // new voyager_tapeout.custom.iobinders.WithSPISDIOCells++
  // new chipyard.iobinders.WithSPIFlashIOCells ++
  // new voyager_tapeout.custom.WithSPIForFlash ++
  // new chipyard.iobinders.WithSPIFlashIOCells ++
  // new voyager_tapeout.WithVoyagerBootROM++
  new freechips.rocketchip.subsystem.WithoutTLMonitors++
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  new voyager_tapeout.custom.iobinders.WithVoyagerPLLSelectorDividerClockGenerator(enable=true)++
  new voyager_tapeout.custom.WithCustomClockGateModel++
  // new voyager_tapeout.custom.WithNPU ++
  // new testchipip.serdes.WithNoSerialTLClient++
  //TODO : 运行vsc 暂时注释掉
  // new testchipip.serdes.WithSerialTLMem(size = BigInt("80000000",16)) ++ // 8 GB of off-chip memory
  // new voyager_tapeout.custom.WithSerialConnect++   // 

  new chipyard.config.AbstractConfig)
class VoyagerVcsConfig extends Config(
  // new voyager_tapeout.custom.WithSPIForFlash ++
  // new voyager_tapeout.custom.WithSPIForSD ++
  // new voyager_tapeout.custom.iobinders.WithSPISDIOCells++
  // new chipyard.iobinders.WithSPIFlashIOCells ++
  // new voyager_tapeout.custom.WithSPIForFlash ++
  // new chipyard.iobinders.WithSPIFlashIOCells ++
  new voyager_tapeout.WithVoyagerBootROM++
  new freechips.rocketchip.subsystem.WithoutTLMonitors++
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  new voyager_tapeout.custom.iobinders.WithVoyagerPLLSelectorDividerClockGenerator(enable=true)++
  new voyager_tapeout.custom.WithCustomClockGateModel++
  new voyager_tapeout.custom.WithNPU ++
  new voyager_tapeout.custom.WithSPIForFlash ++
  new voyager_tapeout.custom.iobinders.WithSPIFlashIOCells ++
  // new testchipip.serdes.WithNoSerialTLClient++
  //TODO : 运行vcs 暂时注释掉
  // new testchipip.serdes.WithSerialTLMem(size = BigInt("80000000",16)) ++ // 8 GB of off-chip memory
  // new voyager_tapeout.custom.WithSerialConnect++   // 

  new chipyard.config.AbstractConfig)

class VoyagerVcsChipConfig extends Config(
  new voyager_tapeout.WithVoyagerBootROM++
  new freechips.rocketchip.subsystem.WithoutTLMonitors++
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  new voyager_tapeout.custom.iobinders.WithVoyagerPLLSelectorDividerClockGenerator(enable=true)++
  new voyager_tapeout.custom.WithNPU ++
  new voyager_tapeout.custom.WithUART1 ++

  new voyager_tapeout.custom.WithSPIForFlash ++
  new voyager_tapeout.custom.iobinders.WithSPIFlashIOCells ++
  new voyager_tapeout.custom.WithCustomClockGateModel++// new CLOCK GATE
  //TODO : 运行vsc 暂时注释掉
  new testchipip.serdes.WithSerialTLMem(size = BigInt("80000000",16)) ++ // 8 GB of off-chip memory
  new voyager_tapeout.custom.WithSerialConnect++   // 
  new chipyard.config.AbstractConfig)

class VoyagerVcsChipTestConfig extends Config(
  // new voyager_tapeout.WithVoyagerBootROM++
  new freechips.rocketchip.subsystem.WithoutTLMonitors++
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  // new voyager_tapeout.custom.iobinders.WithVoyagerPLLSelectorDividerClockGenerator(enable=true)++
  // new voyager_tapeout.custom.WithNPU ++
  // new voyager_tapeout.custom.WithUART1 ++

  // new voyager_tapeout.custom.WithSPIForFlash ++
  new voyager_tapeout.custom.iobinders.WithSPIFlashIOCells ++
  // new voyager_tapeout.custom.WithCustomClockGateModel++// new CLOCK GATE
  //TODO : 运行vsc 暂时注释掉
  new testchipip.serdes.WithSerialTLMem(size = BigInt("80000000",16)) ++ // 8 GB of off-chip memory
  new voyager_tapeout.custom.WithSerialConnect++   // 
  new chipyard.config.AbstractConfig)
// TODO:测试中
class TetheredVoyagerConfig extends Config(
  new chipyard.harness.WithAbsoluteFreqHarnessClockInstantiator ++   // use absolute freqs for sims in the harness
  new chipyard.harness.WithMultiChipSerialTL(0, 1) ++                // connect the serial-tl ports of the chips together
  new chipyard.harness.WithMultiChip(0, new voyager_tapeout.VoyagerVcsChipConfig) ++ // ChipTop0 is the design-to-be-taped-out
  new chipyard.harness.WithMultiChip(1, new voyager_tapeout.ChipBringupHostConfig))  // ChipTop1 is the bringup design


// class VoyagerSerialVerilatorConfig extends Config(
//   new voyager_tapeout.custom.harness.WithCustomChipTop ++
//   new voyager_tapeout.custom.harness.WithCustomIOCells ++
//   new voyager_tapeout.custom.WithCustomDigitalTop ++
//   new voyager_tapeout.custom.OurHeterSoCConfig ++
//   new voyager_tapeout.custom.WithSerialConnect++
//   new chipyard.config.AbstractConfig)

class VoyagerSerialFPGAConfig extends Config(
  new voyager_tapeout.custom.fpga.WithChipHarnessTweaks ++
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  new voyager_tapeout.custom.WithNPU ++
  new voyager_tapeout.custom.WithSerialConnect++
  new chipyard.config.AbstractConfig)

class VoyagerSerialDebugConfig extends Config(
  new voyager_tapeout.custom.fpga.WithChipHarnessTweaks ++
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  // new voyager_tapeout.custom.WithNPU ++
  new voyager_tapeout.custom.WithSerialDebugConnect++
  new chipyard.config.AbstractConfig)

class VoyagerSerialWithoutNPUFPGAConfig extends Config(
  new voyager_tapeout.custom.fpga.WithChipHarnessTweaks ++
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  new voyager_tapeout.custom.WithSerialConnect++
  new chipyard.config.AbstractConfig)


class VoyagerTLFPGAConfig extends Config(
  new voyager_tapeout.custom.fpga.WithChipTLMemHarnessTweaks ++
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  new chipyard.config.AbstractConfig)
// class VoyagerFPGATestHarness extends VoyagerFPGAConfig


// 无核心soc 配置 ， 作为fpga 使用
class ChipBringupHostConfig extends Config(
  new freechips.rocketchip.subsystem.WithoutTLMonitors++
  new chipyard.harness.WithAbsoluteFreqHarnessClockInstantiator ++  // Generate absolute frequencies
  new chipyard.harness.WithSerialTLTiedOff ++                       // when doing standalone sim, tie off the serial-tl port
  new chipyard.harness.WithSimTSIToUARTTSI ++                       // Attach SimTSI-over-UART to the UART-TSI port
  new chipyard.iobinders.WithSerialTLPunchthrough ++                // Don't generate IOCells for the serial TL (this design maps to FPGA)
  new testchipip.serdes.WithSerialTL(Seq(testchipip.serdes.SerialTLParams(
    manager = Some(testchipip.serdes.SerialTLManagerParams(
      memParams = Seq(testchipip.serdes.ManagerRAMParams(
        address = BigInt("00000000", 16),    // 0x00000000
        size    = BigInt("80000000", 16)     // 2GB: 到 0x7FFFFFFF
      ))
    )),
    client = Some(testchipip.serdes.SerialTLClientParams()),                                        // Allow chip to access this device's memory (DRAM)
    phyParams = testchipip.serdes.InternalSyncSerialPhyParams(phitWidth=4, flitWidth=16, freqMHz = 75) // bringup platform provides the clock
  ))) ++
  new testchipip.soc.WithOffchipBusClient(SBUS,                                // offchip bus hangs off the SBUS
    blockRange = AddressSet.misaligned(0x80000000L, (BigInt(1) << 30) * 4)) ++ // offchip bus should not see the main memory of the testchip, since that can be accessed directly
  new testchipip.soc.WithOffchipBus ++                                         // offchip bus
  new freechips.rocketchip.subsystem.WithExtMemSize((1 << 30) * 4L) ++         // match what the chip believes the max size should be
  new testchipip.tsi.WithUARTTSIClient(initBaudRate = BigInt(921600)) ++       // nonstandard baud rate to improve performance
  new chipyard.clocking.WithPassthroughClockGenerator ++ // pass all the clocks through, since this isn't a chip
  new chipyard.config.WithUniformBusFrequencies(75.0) ++   // run all buses of this system at 75 MHz
  // Base is the no-cores config
  new chipyard.NoCoresConfig)

class TestTimeConfig extends Config(
  new chipyard.config.WithTileFrequency(100, Some(0)) ++
  new chipyard.config.WithTileFrequency(100, Some(1)) ++
  // new chipyard.config.WithTileFrequency(100, Some(2)) ++
  new freechips.rocketchip.guardiancouncil.WithGuardianCouncilNodes ++
  new freechips.rocketchip.guardiancouncil.WithDisableROBDebug ++
  // new freechips.rocketchip.rocket.WithNBuckyBallCores(1) ++ //independent Rocket for buckyball: hartid 3
  // new chipyard.config.WithMultiRoCCBB ++
  // new chipyard.config.WithMultiRoCCBuckyBall(3)(buckyball.BuckyBallConfigs.defaultConfig) ++ // put buckyball on hart-3 (rocket)
  
  new chipyard.config.WithMultiRoCCMEEK ++
  new chipyard.config.WithMultiSingleRoCCGHE(0, 1,2) ++ //put custom RoCC on hart0-2 for custom0 ISA extension ++
  new freechips.rocketchip.subsystem.WithInclusiveCache(capacityKB = 32) ++ // 64 KB L2Cache
  new chipyard.config.WithSystemBusWidth(128) ++
  new freechips.rocketchip.rocket.WithMEEKCores(2) ++
  new boom.meek.common.WithNMediumBooms(1) ++
  // new voyager_tapeout.custom.WithSPIForFlash ++
  // new chipyard.iobinders.WithSPIFlashIOCells 
  // NPUPeripheral
  // new chipyard.config.AbstractConfig
  new chipyard.config.AbstractConfig
)