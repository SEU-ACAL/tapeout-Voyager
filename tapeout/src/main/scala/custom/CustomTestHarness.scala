package voyager_tapeout.custom

import org.chipsalliance.cde.config.{Parameters, Config}

// 使用我们自定义的harness包
import voyager_tapeout.custom.harness.{CustomTestHarness, WithCustomChipTop}

// 导出自定义TestHarness，以便外部使用
// class VoyagerCustomTestHarness(implicit p: Parameters) extends CustomTestHarness
