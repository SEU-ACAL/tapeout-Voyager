design .
hw_server . -location 0.a
set_phc_vol -id 0.0 -bank 3 -voltage 1.2
set_phc_vol -id 0.0 -bank 4 -voltage 1.2
set_phc_vol -id 0.0 -bank 5 -voltage 1.2
set_phc_vol -id 0.0 -bank 29 -voltage 1.8
set_phc_vol -id 0.0 -bank 6 -voltage 1.8
download

after 1000

force reset 1
run 10000rclk
force reset 0

get_time rclk

# replace with the specific workload name
memory -write -fpga 0.A -channel 0 -file workload.hex 

for {set i 0} {$i < 3} {incr i} {
tracedb -open wave_mb$i -xedb -overwrite;
trace_signals -add *;
run 800000 rclk;
tracedb -upload;
}
run -nowait


# exit
