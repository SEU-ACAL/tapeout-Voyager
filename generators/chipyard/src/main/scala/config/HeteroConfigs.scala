package chipyard

import org.chipsalliance.cde.config.{Config}

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
class OurHeterSoCConfig extends Config(
  new boom.v3.common.WithNLargeBooms(1) ++             
  new freechips.rocketchip.rocket.WithNBigCores(3) ++
  new gemmini.DefaultGemminiConfig ++                  
  new freechips.rocketchip.rocket.WithNBigNpuCores(1) ++
  new freechips.rocketchip.subsystem.WithInclusiveCache(capacityKB = 256) ++
  new chipyard.config.WithSystemBusWidth(128) ++
  // new chipyard.config.WithGPIO ++ 
  // new chipyard.config.WithI2C ++
  // new chipyard.config.WithSPI ++
  new chipyard.config.AbstractConfig)
