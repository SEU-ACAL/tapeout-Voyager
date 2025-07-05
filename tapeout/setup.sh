#! /bin/bash

#-------------------------------------------------------------------
# 设置统一变量
#-------------------------------------------------------------------

CYDIR=$(git rev-parse --show-toplevel)

SCRIPT_DIR=$CYDIR/voyager-test/scripts
TAPEOUT_DIR=$CYDIR/tapeout

SOC_STAGE_DIR=$TAPEOUT_DIR/1_soc
SRAM_STAGE_DIR=$TAPEOUT_DIR/2_sram

#-------------------------------------------------------------------
# 创建目录
#-------------------------------------------------------------------
mkdir -p $SOC_STAGE_DIR/raw
mkdir -p $SRAM_STAGE_DIR/raw
mkdir -p $SOC_STAGE_DIR/gen
mkdir -p $SRAM_STAGE_DIR/gen
