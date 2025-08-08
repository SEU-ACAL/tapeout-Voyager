#!/bin/bash

CYDIR=$(git rev-parse --show-toplevel)

#-------------------------------------------------------------------
# 已知Verilator，VCS代码与流片代码以下文件存在不同
#            Verilator              VCS          FPGA    Chip 
# PLL:   直接连线(无法验证)    厂商提供的行为模型            db
# pad:   直接连线(无法验证)    厂商提供的行为模型            db
# SRAM:  Verilator行为模型    厂商提供的行为模型            db
#-------------------------------------------------------------------
TOOL=""
CONFIG=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --tool)
      TOOL="$2"
      shift 2
      ;;
    --config)
      CONFIG="$2"
      shift 2
      ;;
    *)
      echo "Usage: $0 --tool [verilator|vcs|chip] [--config <config_name>]"
      exit 1
      ;;
  esac
 done

if [[ -z "$TOOL" ]]; then
  echo "Usage: $0 --tool [verilator|vcs|chip] [--config <config_name>]"
  exit 1
fi

# 添加文件头,为filelist中所有.v文件头部加指定语句
add_header() {
  filelist="$1"
  header_line="$2"
  while read -r vfile; do
    if [ -f "$vfile" ]; then
      tmpfile="${vfile}.tmpheader"
      echo "$header_line" > "$tmpfile"
      cat "$vfile" >> "$tmpfile"
      mv "$tmpfile" "$vfile"
    fi
  done < "$filelist"
}

# 添加条件编译,为filelist中所有.v文件头部加`ifdef VERILATOR，尾部加`endif
add_ifdef() {
  filelist="$1"
  cond="$2"
  while read -r vfile; do
    if [ -f "$vfile" ]; then
      tmpfile="${vfile}.tmpwrap"
      echo "\`ifdef $cond" > "$tmpfile"
      cat "$vfile" >> "$tmpfile"
      echo "\`endif" >> "$tmpfile"
      mv "$tmpfile" "$vfile"
    fi
  done < "$filelist"
}

# 将filelist中的所有.v文件拼接为一个文件
concat_verilog_files() {
  filelist="$1"
  output_file="$2"
  
  if [ -z "$filelist" ] || [ -z "$output_file" ]; then
    echo "ERROR: concat_verilog_files requires filelist and output_file parameters"
    exit 1
  fi
  
  if [ ! -f "$filelist" ]; then
    echo "ERROR: filelist $filelist does not exist"
    exit 1
  fi
  
  # 清空输出文件
  > "$output_file"
  
  # 遍历filelist中的每个.v文件并拼接
  while read -r vfile; do
    if [ -f "$vfile" ]; then
      echo "// File: $vfile" >> "$output_file"
      echo "// =========================================" >> "$output_file"
      cat "$vfile" >> "$output_file"
      echo "" >> "$output_file"
      echo "// =========================================" >> "$output_file"
      echo "" >> "$output_file"
    else
      echo "WARNING: File $vfile not found, skipping"
    fi
  done < "$filelist"
  
  echo "Successfully concatenated all .v files from $filelist into $output_file"
}


#-------------------------------------------------------------------
# step1. 代码预生成 IP 整合 
#-------------------------------------------------------------------
# 1.0 切换模式
# Replace all `define chip/vcs/verilator with `define ${TOOL} recursively in .v files
cd ${CYDIR}/tapeout/src/main/resources/ip
find ./ -type f -name "*.v" -exec sed -i \
  -e 's/define[ ]*chip/define '"${TOOL}"'/g' \
  -e 's/define[ ]*vcs/define '"${TOOL}"'/g' \
  -e 's/define[ ]*verilator/define '"${TOOL}"'/g' \
  {} +
# === 1.1 SRAM替换 ==================================================
cd ${CYDIR}
if [ "$TOOL" == "verilator" ]; then
  ./voyager-test/scripts/build-verilator.sh --config ${CONFIG} --project voyager_tapeout --sub-project voyager_tapeout 
  ORINGIN_DIR="${CYDIR}/sims/verilator/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral"
elif [ "$TOOL" == "vcs" ]; then
  cd ${CYDIR}/sims/vcs && make clean
  cd ${CYDIR}
  ./voyager-test/scripts/build-vcs.sh --config ${CONFIG} --project voyager_tapeout --sub-project voyager_tapeout --debug
  ORINGIN_DIR="${CYDIR}/sims/vcs/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral"
elif [ "$TOOL" == "chip" ]; then
  cd ${CYDIR}/sims/vcs && make clean
  cd ${CYDIR}
  ./voyager-test/scripts/build-vcs.sh --config ${CONFIG} --project voyager_tapeout --sub-project voyager_tapeout
  ORINGIN_DIR="${CYDIR}/sims/vcs/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral"
fi

# verilator --------------------------------------------------------
TMP_DIR="${CYDIR}/tapeout/scripts/tmp"
rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR} && cd ${TMP_DIR}
if [ "$TOOL" == "verilator"  ]; then
  cp ${CYDIR}/sims/${TOOL}/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral/chipyard.harness.TestHarness.${CONFIG}.top.mems.v ${TMP_DIR}/mems.v 
  rm ${CYDIR}/sims/${TOOL}/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral/chipyard.harness.TestHarness.${CONFIG}.top.mems.v 
elif [ "$TOOL" == "vcs" ] || [ "$TOOL" == "chip" ]; then
  cp ${CYDIR}/sims/vcs/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral/chipyard.harness.TestHarness.${CONFIG}.top.mems.v ${TMP_DIR}/mems.v 
  rm ${CYDIR}/sims/vcs/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral/chipyard.harness.TestHarness.${CONFIG}.top.mems.v 
fi
cd ${TMP_DIR}
../split.sh ./mems.v && rm mems.v
ls *.v > filelist
ls split_*.v > split_filelist
add_ifdef split_filelist verilator
add_header split_filelist "\`define ${TOOL}"

# vcs --------------------------------------------------------------
SRAM_MODEL_DIR="${CYDIR}/tapeout/src/main/resources/ip/sram/sram-model"

# 将sram-model目录下同名.v文件内容合并到tmp目录下
cd $TMP_DIR
if [ -f split_filelist ]; then
  while read -r vfile; do
    if [ -f "$TMP_DIR/$vfile" ] && [ -f "$SRAM_MODEL_DIR/$vfile" ]; then
      cat "$SRAM_MODEL_DIR/$vfile" >> "$TMP_DIR/$vfile"
    fi
  done < split_filelist
fi

# 将sram-model/v-model目录下.v文件内容合并到tmp目录下
if [ "$TOOL" == "vcs" ]; then
  SRAM_V_DIR="${CYDIR}/tapeout/src/main/resources/ip/sram/sram-model/v-model"
  cp -r ${SRAM_V_DIR}/* ${TMP_DIR}
fi


# chip --------------------------------------------------------------
SRAM_DB_DIR="${CYDIR}/tapeout/src/main/resources/ip/sram/sram-db"
# cd ${SRAM_DB_DIR} && ls *.v > filelist

# 将sram-db目录下同名.v文件内容合并到tmp目录下
cd $TMP_DIR
if [ -f split_filelist ]; then
  while read -r vfile; do
    if [ -f "$TMP_DIR/$vfile" ] && [ -f "$SRAM_DB_DIR/$vfile" ]; then
      cat "$SRAM_DB_DIR/$vfile" >> "$TMP_DIR/$vfile"
    fi
  done < split_filelist
fi

#-------------------------------------------------------------------
# step2. 加入IP文件, 替换仿真模型: 只有 VCS 和 Chip 需要
#-------------------------------------------------------------------
if [ "$TOOL" == "vcs" ] || [ "$TOOL" == "chip" ]; then
  # 替换sram文件
  cd ${ORINGIN_DIR} && rm -rf *.top.mems.v 
  cd ${TMP_DIR} && ls *.v > sram_filelist.v
  # 拼接各版本 sram ---------------------------------------------------
  concat_verilog_files sram_filelist.v chipyard.harness.TestHarness.${CONFIG}.top.mems.v
  cp chipyard.harness.TestHarness.${CONFIG}.top.mems.v ${ORINGIN_DIR}
  # cp -r ${TMP_DIR}/* ${ORINGIN_DIR} 
  # Append the filelist from SRAM_DB_DIR to the filelist in TMP_DIR
  # cd ${ORINGIN_DIR} && cat sram_filelist.v >> filelist.f
  python ${CYDIR}/tapeout/scripts/iocell.py ${CYDIR}/sims/vcs/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral
  ## 加入这个可以从flash启动
  # python ${CYDIR}/tapeout/scripts/gpio_set.py ${CYDIR}/sims/vcs/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral/TestHarness.sv 3:0 4:0 5:1 --remove-gpio 6,7,8
fi

#-------------------------------------------------------------------
# step3. 正式生成仿真代码 
#-------------------------------------------------------------------
cd ${CYDIR}
ORINGIN_DIR=""
# TARGET_DIR="${CYDIR}/tapeout/generated-src"
if [ "$TOOL" == "verilator" ]; then
  # ./voyager-test/scripts/build-verilator.sh --config ${CONFIG} --project voyager_tapeout --sub-project voyager_tapeout --debug
  ORINGIN_DIR="${CYDIR}/sims/verilator/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral"
elif [ "$TOOL" == "vcs" ]; then
  ./voyager-test/scripts/build-vcs.sh --config ${CONFIG} --project voyager_tapeout --sub-project voyager_tapeout --debug
  ORINGIN_DIR="${CYDIR}/sims/vcs/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral"
elif [ "$TOOL" == "chip" ]; then
  ./voyager-test/scripts/build-vcs.sh --config ${CONFIG} --project voyager_tapeout --sub-project voyager_tapeout 
  ORINGIN_DIR="${CYDIR}/sims/vcs/generated-src/chipyard.harness.TestHarness.${CONFIG}/gen-collateral"
fi

if [ -z "$ORINGIN_DIR" ]; then
  echo "ERROR: ORINGIN_DIR is not set"
  exit 1
fi


#-------------------------------------------------------------------
# step4. 代码后处理: 只有 Chip Config需要 
#-------------------------------------------------------------------
# 4.1 还原头文件
if [ "$TOOL" == "chip" ]; then
  cd ${ORINGIN_DIR}
  # Replace all `include "../gen-collateral/defines.v" with `include "defines.v" recursively
  find . -type f -name "*.v" -exec sed -i 's#`include "../gen-collateral/defines.v"#`include "defines.v"#g' {} +
fi

#-------------------------------------------------------------------
# step4. 清除垃圾 
#-------------------------------------------------------------------
rm -rf ${TMP_DIR}