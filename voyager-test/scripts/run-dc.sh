#!/bin/bash

# exit script if any command fails
set -e
set -o pipefail

TOP_MODULE="ChipTop"
# DigitalTop
while [[ $# -gt 0 ]]; do
    case $1 in
        --config)
            CONFIG="$2"
            shift 2
            ;;
        --top)
            TOP_MODULE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 --config <design_config> --top [top_module](Optional)"
            echo "Example: $0 --config RocketConfig --top RocketTile"
            exit 1
            ;;
    esac
done

if [ -z "$CONFIG" ]; then
    echo "Error: Missing required parameter: config"
    echo "Usage: $0 --config <design_config> --top [top_module](Optional)"
    echo "Example: $0 --config RocketConfig --top RocketTile"
    exit 1
fi

CYDIR=$(git rev-parse --show-toplevel)

WORK_DIR="${CYDIR}/voyager-test/output/dc"
DESIGN_DIR="${CYDIR}/voyager-test/output/dc/design"
REPORT_DIR="${CYDIR}/voyager-test/output/dc/reports"
TMP_DIR="${CYDIR}/voyager-test/output/dc/tmp"
TCL_FILE="${CYDIR}/voyager-test/output/dc/dc_script.tcl"

mkdir -p $WORK_DIR
mkdir -p $DESIGN_DIR
mkdir -p $REPORT_DIR
mkdir -p $TMP_DIR

source ${CYDIR}/voyager-test/scripts/env-source.sh dc
#-------------------------------------------------------------------
# Step0 执行build Verilator
#-------------------------------------------------------------------
${CYDIR}/voyager-test/scripts/build-verilator.sh --config ${CONFIG}

#-------------------------------------------------------------------
# Step1 搬运对应Config的Verilog到工作目录
#-------------------------------------------------------------------
DESIGN_SOURCE_DIR="${CYDIR}/sims/verilator/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral"
cp -r ${DESIGN_SOURCE_DIR}/* ${DESIGN_DIR}/

#-------------------------------------------------------------------
# Step2 替换SRAM
#-------------------------------------------------------------------
MODEL_MEMS_V=$DESIGN_DIR/chipyard.harness.TestHarness.${CONFIG}.model.mems.v
TOP_MEMS_V=$DESIGN_DIR/chipyard.harness.TestHarness.${CONFIG}.top.mems.v
JSON_FILE=$DESIGN_DIR/metadata/seq_mems.json

if [ ! -f "$MODEL_MEMS_V" ] || [ ! -f "$TOP_MEMS_V" ] || [ ! -f "$JSON_FILE" ]; then
    echo "Error: One of the following files not found:"
    echo "  - $MODEL_MEMS_V"
    echo "  - $TOP_MEMS_V" 
    echo "  - $JSON_FILE"
    exit 1
fi

# 替换顶层SRAM和模型SRAM
echo "正在替换顶层SRAM..."
python ${CYDIR}/voyager-test/scripts/sram-replace.py $JSON_FILE $TOP_MEMS_V -o $DESIGN_DIR/chipyard.harness.TestHarness.${CONFIG}.top.mems.sv

echo "正在替换模型SRAM..."
python ${CYDIR}/voyager-test/scripts/sram-replace.py $JSON_FILE $MODEL_MEMS_V -o $DESIGN_DIR/chipyard.harness.TestHarness.${CONFIG}.model.mems.sv

# DESIGN_FILE="${DESIGN_DIR}/gen-collateral/*.v ${DESIGN_DIR}/gen-collateral/*.sv"
#-------------------------------------------------------------------
# Step3 编写tcl脚本
#-------------------------------------------------------------------
cat > $TCL_FILE << EOF
# 设置搜索路径
set search_path [list . $DESIGN_DIR]
define_design_lib work -path $TMP_DIR

# 设置目标库 m4 swbso ffg0p99v0c
set target_library "
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta1024x30m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta1024x31m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta1024x32m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta1024x36m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x12m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x16m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x20m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x22m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x23m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x25m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x26m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x27m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x30m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x31m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x33m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x50m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x59m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x64m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta160x57m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta192x43m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x12m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x16m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x20m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x22m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x23m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x25m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x27m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x28m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x29m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x31m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x32m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x33m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x36m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x64m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x72m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x78m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x8m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x12m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x16m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x22m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x23m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x24m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x25m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x27m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x31m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x32m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x36m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x4m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x5m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x72m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x78m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x8m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x20m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x31m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x32m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x58m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x61m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x64m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x69m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x72m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp12t40p140_180a/tcbn28hpcplusbwp12t40p140ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp12t40p140_180a/tcbn28hpcplusbwp12t40p140ffg0p88v0c.db \
/opt/dc/lib/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp12t40p140_180a/tcbn28hpcplusbwp12t40p140ffg1p05v0c.db \
"

set link_library "\
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta1024x30m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta1024x31m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta1024x32m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta1024x36m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x12m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x16m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x20m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x22m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x23m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x25m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x26m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x27m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x30m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x31m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x33m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x50m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x59m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta128x64m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta160x57m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta192x43m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x12m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x16m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x20m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x22m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x23m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x25m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x27m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x28m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x29m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x31m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x32m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x33m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x36m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x64m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x72m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x78m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta256x8m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x12m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x16m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x22m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x23m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x24m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x25m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x27m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x31m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x32m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x36m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x4m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x5m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x72m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x78m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta512x8m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x20m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x31m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x32m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x58m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x61m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x64m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x69m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/tem5n28hpcplvta64x72m4swbso_110a_ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp12t40p140_180a/tcbn28hpcplusbwp12t40p140ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp12t40p140_180a/tcbn28hpcplusbwp12t40p140ffg0p88v0c.db \
/opt/dc/lib/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp12t40p140_180a/tcbn28hpcplusbwp12t40p140ffg1p05v0c.db \
"

# 读取设计文件
set file_list [glob -nocomplain -directory $DESIGN_DIR *.sv ]
analyze -format sverilog \$file_list
elaborate ChipTop

# 设置顶层模块名
set current_design "$TOP_MODULE"

# 链接设计
link

# 设置约束
# create_clock -name clk -period 10 [get_ports clk]
# set_input_delay -clock clk 2 [all_inputs]
# set_output_delay -clock clk 2 [all_outputs]

# # 综合
compile_ultra

# 生成报告
report_area -hierarchy > $REPORT_DIR/area.rpt
report_timing > $REPORT_DIR/timing.rpt
report_power -hierarchy > $REPORT_DIR/power.rpt

# 保存网表
write -format verilog -output $REPORT_DIR/netlist.v

# 退出
exit
EOF

#-------------------------------------------------------------------
# Step4 运行DC
#-------------------------------------------------------------------
echo "Running DC synthesis for design: ${CONFIG}, top module: $TOP_MODULE"
dc_shell -f $TCL_FILE 

rm $TCL_FILE
rm -rf ${CYDIR}/alib-52

echo "Synthesis completed. Reports are available in $REPORT_DIR directory."
