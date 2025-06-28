design .
hw_server . -location 0.a
set_phc_vol -id 0.0 -bank 3 -voltage 1.2
set_phc_vol -id 0.0 -bank 4 -voltage 1.2
set_phc_vol -id 0.0 -bank 5 -voltage 1.2
set_phc_vol -id 0.0 -bank 29 -voltage 1.8
set_phc_vol -id 0.0 -bank 6 -voltage 1.8
download

#set_debug_mod -on
after 1000

force reset 1
run 10000rclk
force reset 0

#run 50000000000rclk
#run 100000000rclk

#trigger -at -readfile trigger_fsm.v
#trigger -at -listmodule
#trigger -at -addinst inst1 -module trigger_fsm -bind_ports clock {VCU118FPGATestHarness.chiptop.system.tile_prci_domain.tile_reset_domain_boom_tile.core._decode_units_0_io_deq_uop_debug_pc}

#trigger -at -listinst
#trigger -at -enable inst1

#set_trigger_stop on

#run -nowait

get_time rclk

#trigger -at -disable inst1
#trigger -at -delete inst1

#memory -write -fpga 0.A -channel 0 -file /home/tools/guochuang_backdoor_data/spec_c_22.hex
#memory -write -fpga 0.A -channel 0 -file /home/tools/guochuang_backdoor_data/br_c_22.hex
#memory -write -fpga 0.A -channel 0 -file /home/tools/guochuang_backdoor_data/brno_c_22.hex
#memory -write -fpga 0.A -channel 0 -file /home/tools/guochuang_backdoor_data/br_s_22.hex
#memory -write -fpga 0.A -channel 0 -file /home/tools/guochuang_backdoor_data/br_s2_2.hex

#set_trace_size 300000 rclk
#tracedb -open wave_trigger -xedb -overwrite
#trace_signals -add *
#run 300000 rclk
#tracedb -upload
#tracedb -close

#for {set i 0} {$i < 3} {incr i} {
#tracedb -open wave_mb$i -xedb -overwrite;
#trace_signals -add *;
#run 800000 rclk;
#tracedb -upload;
#}
#set_trigger_stop on
#trigger -lt -readfile toggle.v
#trigger -lt -addinst t_inst -module toggle -bind_ports {TestHarness.chiptop0.system.bootROMDomainWrapper.bootrom.clock} {TestHarness.chiptop0.system.bootROMDomainWrapper.bootrom.auto_in_a_ready} {TestHarness.chiptop0.system.bootROMDomainWrapper.bootrom.auto_in_d_valid}
#trigger -lt -enable t_inst
#run -nowait
#run 100000 rclk
#tracedb -upload
#tracedb -close


#exit
