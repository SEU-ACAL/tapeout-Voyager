#!/bin/bash

export HPE_HOME=/home/tools/HPE_24_12_00_d103
export VCOM_HOME=$HPE_HOME
export VDBG_HOME=$HPE_HOME
export VSYN_HOME=$HPE_HOME
export VVAC_HOME=$HPE_HOME
export XRAM_HOME=$HPE_HOME/public/xram
export DBGIP_HOME=$HPE_HOME/share/pnr/dbg_ip
export VIVADO_PATH=/home/tools/vivado/Vivado/2022.2
export PATH=$VIVADO_PATH/bin:$PATH
export PATH=$VIVADO_PATH/gnu/microblaze/lin/bin:$PATH
source /home/tools/HPE_24_12_00_d103/setup.sh
export PATH=$HPE_HOME/bin:$PATH
export PATH=$HPE_HOME/tools/xwave/bin:$PATH
export RLM_LICENSE=5053@192.168.99.15
export LM_LICENSE_FILE=/home/tools/vivado/license.lic

# source目录是执行目录，所以记得跳到 setup.sh 的同级目录进行source
script_dir=$(pwd)
script_name=$(basename "$script_dir")
export VSRC_PATH=$script_dir/../gen-collateral

# export CASE_NAME=$script_name
# export CASE_PATH=$VSRC_DIR
# export SRC_PATH=$CASE_PATH/gen-collateral
# export MODIFIED_PATH=$CASE_PATH/modified_v
# export XRAM_PATH=$CASE_PATH/xaxi4_slave_emb
# export XAXI_RTL_HOME=/home/youdean
