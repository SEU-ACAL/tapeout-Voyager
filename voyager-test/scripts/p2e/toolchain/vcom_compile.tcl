
 design_read -netlist VCU118FPGATestHarness.vm 
 
 design_read -netlist $env(XRAM_HOME)/P2_Emu/wrapper/xram_bbox_wrapper.v
 
netlistmacro -add {work xram_bbox_wrapper} -resource {LUT:28000 BRAM:70}
netlistmacro_param -instance VCU118FPGATestHarness.mig.island.u_xram_bbox_wrapper -attribute {NL_FILE_PATH $env(XRAM_HOME)/P2_Emu/dcp/xram_bbox_wrapper.dcp}
netlistmacro_param -module xram_bbox_wrapper -attribute {ROOT_FREE_CK rclk}

 design_load -top VCU118FPGATestHarness

 emulator_spec -add "file hw-config.hdf"

 create_clock -sig_name VCU118FPGATestHarness.clock -frequency 5Mhz


 cable_connection -def {my_uart PHC 0.A.29}
 cable_connection -def {my_sdio PHC 0.A.6}


terminal_assign  -add {my_uart A3 uart_txd} -IOSTANDARD LVCMOS18
terminal_assign  -add {my_uart A2 uart_rxd} -IOSTANDARD LVCMOS18

terminal_assign  -add {my_sdio A0 sdio_spi_clk} -IOSTANDARD LVCMOS18
###CMD
terminal_assign  -add {my_sdio A2 sdio_spi_cs} -IOSTANDARD LVCMOS18
###D0 D1 D2 D3
terminal_assign  -add {my_sdio A4 sdio_spi_dat_0} -IOSTANDARD LVCMOS18
terminal_assign  -add {my_sdio A5 sdio_spi_dat_1} -IOSTANDARD LVCMOS18
terminal_assign  -add {my_sdio A6 sdio_spi_dat_2} -IOSTANDARD LVCMOS18
terminal_assign  -add {my_sdio A7 sdio_spi_dat_3} -IOSTANDARD LVCMOS18
###D1 D2 CD WP RESET
terminal_assign  -add {my_sdio A11 sdio_sel} -IOSTANDARD LVCMOS18


#write_net
#Specify the nets that user can write, force, or release at runtime.
 write_net -add {reset}
 write_net -add {_WIRE}
 write_net -add {_fpga_power_on_power_on_reset}
 write_net -add {_harnessBinderReset_catcher_io_sync_reset}
 read_net -add  {VCU118FPGATestHarness.mig.island.mmp_ddr4_calib_done}
 #memory_access -add TestHarness.chiptop0.system.subsystem_l2_wrapper.l2.inclusive_cache_bank_sched.bankedStore.cc_banks_0.cc_banks_0_ext.mem_0_0.ram
 #memory_access -add TestHarness.chiptop0.system.subsystem_l2_wrapper.l2.inclusive_cache_bank_sched.bankedStore.cc_banks_1.cc_banks_0_ext.mem_0_0.ram
 #memory_access -add TestHarness.chiptop0.system.subsystem_l2_wrapper.l2.inclusive_cache_bank_sched.bankedStore.cc_banks_2.cc_banks_0_ext.mem_0_0.ram
 #memory_access -add TestHarness.chiptop0.system.subsystem_l2_wrapper.l2.inclusive_cache_bank_sched.bankedStore.cc_banks_3.cc_banks_0_ext.mem_0_0.ram
 #trace_net [-depth 1] -add VCU118FPGATestHarness
source $env(XRAM_HOME)/P2_Emu/tcl/xram_compile.tcl
 #emulator_util
#Adds the constraints of resource utilization for specific FPGAs
 emulator_util -add {default 80}

#specify the ddr location in fpga
 xram_compile_param VCU118FPGATestHarness.mig.island.u_xram_bbox_wrapper 0 A 1 P2
 memory_options -add {force_refresh_area ON}
#fv_monitor
#wrp command to sepcify the design top ,specify the visibility of design depth 
#fv_monitor -scope TestHarness.chiptop0.system -depth 3 -vsyndb libs.vsyn

dynamic_trigger -enable
trigger_net -add {VCU118FPGATestHarness.chiptop0.system.tile_prci_domain.tile_reset_domain_tile.core.mem_reg_pc} -clk clock
trigger_net -add {VCU118FPGATestHarness.chiptop0.system.tile_prci_domain.tile_reset_domain_tile.core.ex_reg_pc} -clk clock
trigger_net -add {VCU118FPGATestHarness.chiptop0.system.tile_prci_domain.tile_reset_domain_tile.core.wb_reg_pc} -clk clock

trace_net -add VCU118FPGATestHarness -depth 6
 #design_edit
#load the design and check the compilation constraint. vCom performs design edit according to he settings of timing, terminal assignments, instrument logic and net optimization.
 design_edit

#design_generation
#the design generation flow includes 4 steps. pre-generation, partitioning, routing and implementation. result files are netlists and some related databases.
 design_generation
 xram_io_constraints_gen
