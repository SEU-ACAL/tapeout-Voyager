# Accelerator Platform Development Manual

## Overview
This platform is designed for verification of silicon architecture code, providing the following main functions:
1. Large-scale design verification
2. FPGA parallel simulation verification  
3. Processor/accelerator microarchitecture debugging

## Quick Start

### 1. Environment Setup
```bash
source setup.sh
```

### 2. Compilation Flow

#### 2.1 Generate Original RTL Code
```bash
# Generate Verilog code from chipyard FPGA directory, default is RocketConfig
# To modify, edit /home/rain/chipyard/fpga/src/main/scala/vcu118/Configs.scala
cd $CHIPYARD/fpga
make SUB_PROJECT=vcu118 CONFIG=RocketVCU118Config bitstream
# Copy the generated gen-collateral folder to project directory
```
> **⚠️ NOTE:** Ignore board type not found errors, only need successful verilog generation



#### 2.2 Run Platform Migration Script
```bash
./migrate.sh -h

# Use default output directory (modified_v)
./migrate.sh gen-collateral

```

#### 2.3 Verify Migration Results
```bash
# Check generated RTL files
ls -la modified_v/

# Verify XEPIC macro definitions
grep -c "XEPIC_P2E" modified_v/*.sv

# Verify reset logic format
grep -A 2 -B 1 "com_reset" modified_v/XilinxVCU118MIGIsland.sv

# Verify XRAM interface
grep -A 5 -B 5 "xram0_read" modified_v/XilinxVCU118MIGIsland.sv

# Verify conditional compilation blocks
grep -A 3 -B 3 "ifdef XEPIC_P2E" modified_v/VCU118FPGATestHarness.sv
```

#### 2.4 Compile Design
```bash
# Synthesis
make vsyn    # Generate VCU118FPGATestHarness.vm and area.log

# Compilation
make vcom    # Run vcom_compile.tcl script

# Place and Route
make pnr     # Execute in fpgaCompDir directory
```
> **⚠️ NOTE:** No need to change directory for make pnr, run in working directory

### 3. Execution Flow
```bash
# Modify .debug_info file
vim .design_info    # Modify div:15

# Enter vdbg tool
vdbg    

# Run tcl script
source debug_trigger.tcl     

# Backdoor write test program
memory -write -fpga 0.A -channel 0 -file /home/tools/guochuang_backdoor_data/brno_c_22.hex 

# Continue execution
run -nowait 

```
> **⚠️ NOTE:** Your workload requires hex format

## Script Functionality Details

### migrate.sh Parameters
```bash
./migrate.sh -h

# Basic syntax
./migrate.sh <source_directory> [output_directory]

# Parameter:
# source_directory   - Source directory containing Verilog files (e.g., gen-collateral)
# output_directory   - Output directory (default: modified_v)

# Usage examples
./migrate.sh gen-collateral           
./migrate.sh gen-collateral modified_v  
```

### Architecture
```bash
migrate.sh              # Main script
lib/
├── utils.sh            # Utility functions (logging, file operations, etc.)
├── pattern.sh          # Pattern definitions (centralized regex and replacement templates)
└── migrate_processor.sh # Core processing logic (file conversion and modification)
```

## Common Functions

### 1. Switch FPGA Board
```bash
# Modify hardware configuration file
vim hw-config.hdf

# Modify the last two digits of IP address, options:
# 192.168.100.10
# 192.168.100.11  
# 192.168.100.12
# 192.168.100.13
# 192.168.100.14

# Example: Switch to FPGA board 11
BOARD += {"index": 0, "type": "FOUR_CHIP_BOARD", "SN": "RRD00000026AFE0", "CLK": 0, "IP": "192.168.100.11"}

```

### 2. FPGA Multi-board Co-verification
- Use hw-config_union.hdf
- Select resource percentage for each board in compile script
- Example of dual-board co-verification (modify vcom_compile.tcl script):

```bash

 emulator_spec -add "file hw-config_union.hdf"

 emulator_util -add {default 0}
 emulator_util -add {0.A 60}
 emulator_util -add {0.B 60}
 emulator_util -add {0.C 60}
 emulator_util -add {0.D 60}
 emulator_util -add {1.A 60}
 emulator_util -add {1.B 60}
 emulator_util -add {1.C 60}
 emulator_util -add {1.D 60}

```

### 3. Add Writable/Readable Signals
```bash
# Add to vcom_compile script
 write_net -add {reset}
 write_net -add {_WIRE}
 write_net -add {_fpga_power_on_power_on_reset}
 write_net -add {_harnessBinderReset_catcher_io_sync_reset}
 read_net -add  {VCU118FPGATestHarness.mig.island.mmp_ddr4_calib_done}
```
> **⚠️ NOTE:** in vdbg, write_net signal use force to set value; read_net signal use get_value to get value. 
 ```bash
# Add to debug_trigger.tcl script
 force _fpga_power_on_power_on_reset 1
 run 10000 rclk
 force _fpga_power_on_power_on_reset 0
 run 1000000 rclk
 get_value VCU118FPGATestHarness.mig.island.mmp_ddr4_calib_done
```

### 4. Backdoor Test Program Input
```bash
# Add to debug_trigger.tcl script
memory -write -fpga 0.A -channel 0 -file /home/tools/guochuang_backdoor_data/brno_c_22.hex
memory -write -fpga 0.A -channel 0 -file /home/youdean/cm_bigendianv2.hex

run -nowait

```

### 5. Waveform Generation and Viewing (modify debug_trigger.tcl script)
```bash
# Generate waveform files
set_trace_size 100000 rclk

for {set i 0} {$i < 3} {incr i} {
tracedb -open wave_mb$i -vcd -overwrite; # also can use -xvcf
trace_signals -add *;
run 800000 rclk;
tracedb -upload;
}

# View waveforms using xWave / gtkwave, gtkwave need to download to native.
xwave -wdb wave_mb0.xvcf
gtkwave wave_mb0.vcd
```
> **⚠️ NOTE:** Modify debug_trigger.tcl

### 6. How to use trigger_net ?
```bash

# modified in vcom_compile.tcl
dynamic_trigger -enable
trigger_net -add {VCU118FPGATestHarness.chiptop0.system.tile_prci_domain.tile_reset_domain_tile.core.ex_reg_pc} -clk clock
trigger_net -add {VCU118FPGATestHarness.chiptop0.system.tile_prci_domain.tile_reset_domain_tile.core.wb_reg_pc} -clk clock

```
> **⚠️ NOTE:** need to add your trigger_fsm.v in vdbg.
```bash
trigger -at -readfile trigger_fsm.v
trigger -at -listmodule
trigger -at -addinst inst1 -module trigger_fsm -bind_ports clock {VCU118FPGATestHarness.chiptop0.system.tile_prci_domain.tile_reset_domain_tile.core.ex_reg_pc}

trigger -at -listinst
trigger -at -enable inst1

set_trigger_stop on
```

### 7. How to set trace_depth ?
```bash
#modified in vcom_compile.tcl
trace_net -add VCU118FPGATestHarness -depth 6
# add net or add specified instance; default depth is 0.
```

## Output Files

### Script Generated Files
- `modified_v/` - Modified RTL files directory
  - `VCU118FPGATestHarness.sv` - Test platform with XEPIC support and conditional compilation
  - `XilinxVCU118MIGIsland.sv` - Memory island with XRAM interface and correct reset logic
  - Other files copied directly from source directory, maintaining original functionality

### Script Lib
- `lib/utils.sh` - Utility functions (logging, safe file operations, etc.)
- `lib/pattern.sh` - Pattern definitions (all regex and replacement templates)
- `lib/migrate_processor.sh` - Core processing logic (file conversion and modification)

### Some Compilation Generated Files
- `VCU118FPGATestHarness.vm` - Synthesis results
- `area.log` - Area report
- `vsyn.log` - Synthesis log
- `vcom_compile.log` - Compilation log
- `fpgaCompDir/` - Place and route results directory
- `waveform.vcd` - Waveform file

---