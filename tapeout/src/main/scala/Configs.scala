package voyager_tapeout

import org.chipsalliance.cde.config.Config
import chipyard._


class VoyagerVerilatorConfig extends Config(
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  new chipyard.config.AbstractConfig)

class VoyagerFPGAConfig extends Config(
  new voyager_tapeout.custom.fpga.WithChipHarnessTweaks ++
  new voyager_tapeout.custom.harness.WithCustomChipTop ++
  new voyager_tapeout.custom.harness.WithCustomIOCells ++
  new voyager_tapeout.custom.WithCustomDigitalTop ++
  new voyager_tapeout.custom.OurHeterSoCConfig ++
  new chipyard.config.AbstractConfig)

// class VoyagerFPGATestHarness extends VoyagerFPGAConfig