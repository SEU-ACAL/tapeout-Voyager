package voyager_tapeout

import org.chipsalliance.cde.config.Config
import chipyard._

// class VoyagerChipConfig extends Config(
//   new voyager_tapeout.VoyagerSerialVerilatorConfig  
// )

class VoyagerFPGAConfig extends Config(
  new voyager_tapeout.VoyagerSerialWithoutNPUFPGAConfig 
)
class VoyagerChipConfig extends Config(
  new voyager_tapeout.VoyagerSerialFPGAConfig 
)
class VoyagerVerilatorConfig extends Config(
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  new voyager_tapeout.custom.WithNPU ++
  new chipyard.config.AbstractConfig)


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
