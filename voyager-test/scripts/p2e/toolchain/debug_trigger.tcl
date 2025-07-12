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

# Load pin configuration from pin_config.json
if {[file exists "pin_config.json"]} {
  set pin_config_file [open "pin_config.json" r]
  set pin_config_content [read $pin_config_file]
  close $pin_config_file
  
  # Parse JSON and set pin values
  set lines [split $pin_config_content "\n"]
  foreach line $lines {
    set line [string trim $line]
    if {[regexp {^\s*"([^"]+)"\s*:\s*(\d+)\s*,?\s*$} $line -> pin_name pin_value]} {
      puts "Setting pin $pin_name to $pin_value"
      force @$pin_name $pin_value
    }
  }
  puts "Pin configuration loaded from pin_config.json"
} else {
  puts "Error: pin_config.json not found, please check the file path"
  exit 1
}

# replace with the specific workload name
memory -write -fpga 0.A -channel 0 -file ../image/interactive.hex 

# for {set i 0} {$i < 3} {incr i} {
# tracedb -open wave_mb$i -xedb -overwrite;
# trace_signals -add *;
# run 800000 rclk;
# tracedb -upload;
# }
run -nowait


# exit
