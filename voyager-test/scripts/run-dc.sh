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
DB_FILE="/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c/"

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
rm -rf ${DESIGN_DIR}/*
cp -r ${DESIGN_SOURCE_DIR}/* ${DESIGN_DIR}/

#-------------------------------------------------------------------
# Step2 替换SRAM
#-------------------------------------------------------------------
# echo "正在检查SRAM  File..."
# python ${CYDIR}/voyager-test/scripts/read_json.py $DB_FILE $DESIGN_DIR "/home/hxm123/tapeout-Voyager/sims/verilator/generated-src/chipyard.harness.TestHarness.GemminiRocketConfig/gen-collateral/metadata/seq_mems.json"

#-------------------------------------------------------------------
# Step3 编写tcl脚本
#-------------------------------------------------------------------
db_dir="/opt/dc/lib/TSMCHOME/SRAM_m4swbsoffg0p99v0c"

# 获取所有 .db 文件的列表
db_files=$(ls ${db_dir}/*.db 2>/dev/null)

# 检查是否找到 .db 文件
if [ -z "$db_files" ]; then
  echo "错误：目录 ${db_dir} 中没有找到 .db 文件"
  exit 1
fi

# 将文件路径格式化为 Tcl 所需的字符串（以空格分隔）
tcl_db_list=$(echo "$db_files" | tr '\n' ' ')


cat > $TCL_FILE << EOF
# 设置搜索路径
set search_path [list . $DESIGN_DIR]
define_design_lib work -path $TMP_DIR

set target_library "$tcl_db_list\
/opt/dc/lib/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp12t40p140_180a/tcbn28hpcplusbwp12t40p140ffg0p99v0c.db \
/opt/dc/lib/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp12t40p140_180a/tcbn28hpcplusbwp12t40p140ffg0p88v0c.db \
/opt/dc/lib/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp12t40p140_180a/tcbn28hpcplusbwp12t40p140ffg1p05v0c.db \
"
set link_library "$tcl_db_list\
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
compile_ultra -incremental -scan
write -format ddc -hierarchy -output $REPORT_DIR/design_compiled.ddc

# 生成报告
report_area -hierarchy -nosplit > $REPORT_DIR/area.rpt
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

# rm $TCL_FILE
rm -rf ${CYDIR}/alib-52

echo "Synthesis completed. Reports are available in $REPORT_DIR directory."
