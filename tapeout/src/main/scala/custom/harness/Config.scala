package voyager_tapeout.custom.harness

import org.chipsalliance.cde.config.{Config}

import chipyard.harness._


class CustomHarnessTweaks extends Config(
  new WithSimAXIMMIO 
)
