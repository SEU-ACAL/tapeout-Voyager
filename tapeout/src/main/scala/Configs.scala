package voyager_tapeout

import org.chipsalliance.cde.config.Config
import chipyard._
import chipyard.harness.WithSimSPIFlashModel
import freechips.rocketchip.devices.tilelink.BootROMParams

// class VoyagerChipConfig extends Config(
//   new voyager_tapeout.VoyagerSerialVerilatorConfig  
// )

class WithMyBootROM (contentFileName: String) extends Config((site, here, up) => {
  case BootROMParams =>
    BootROMParams(contentFileName = contentFileName)
})

class VoyagerFPGAConfig extends Config(
  new voyager_tapeout.VoyagerSerialWithoutNPUFPGAConfig 
)
class VoyagerChipConfig extends Config(
  new voyager_tapeout.VoyagerSerialFPGAConfig 
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

class VoyagerVcsConfig extends Config(
  // new voyager_tapeout.custom.WithSPIForFlash ++
  // new voyager_tapeout.custom.WithSPIForSD ++
  // new voyager_tapeout.custom.iobinders.WithSPISDIOCells++
  // new chipyard.iobinders.WithSPIFlashIOCells ++
  new freechips.rocketchip.subsystem.WithoutTLMonitors++
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  new voyager_tapeout.custom.iobinders.WithVoyagerPLLSelectorDividerClockGenerator(enable=true)++
  new voyager_tapeout.custom.WithNPU ++
  // new testchipip.serdes.WithNoSerialTLClient++
  //TODO : 运行vsc 暂时注释掉
  // new testchipip.serdes.WithSerialTLMem(size = BigInt("80000000",16)) ++ // 8 GB of off-chip memory
  // new voyager_tapeout.custom.WithSerialConnect++   // 

  new chipyard.config.AbstractConfig)

// TODO:测试中
// class TetheredVoyagerConfig extends Config(
//   new chipyard.harness.WithAbsoluteFreqHarnessClockInstantiator ++   // use absolute freqs for sims in the harness
//   new chipyard.harness.WithMultiChipSerialTL(0, 1) ++                // connect the serial-tl ports of the chips together
//   new chipyard.harness.WithMultiChip(0, new VoyagerVcsConfig) ++ // ChipTop0 is the design-to-be-taped-out
//   new chipyard.harness.WithMultiChip(1, new ChipBringupHostConfig))  // ChipTop1 is the bringup design


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
