#! /bin/bash

source ../setup.sh

#-------------------------------------------------------------------
# Step1 获取Input文件
#-------------------------------------------------------------------
# cp

#-------------------------------------------------------------------
# Step2 分析raw SRAM需求，生成sram_analysis.csv
#-------------------------------------------------------------------
python tools/rawMemStatistic.py -i $SRAM_STAGE_DIR/raw/seq_mems.json -o $SRAM_STAGE_DIR/gen/sram_statistic.csv

#-------------------------------------------------------------------
# Step3 生成SRAM拼接方案，生成sram_solution.json 和 sram_solution.csv
#-------------------------------------------------------------------
python tools/tileMemSolutionGen.py -i $SRAM_STAGE_DIR/raw/seq_mems.json -o $SRAM_STAGE_DIR/gen/sram_solution.json -s tools/sramSpec.yaml
python tools/tileMemSolutionStatistic.py -i $SRAM_STAGE_DIR/gen/sram_solution.json -o $SRAM_STAGE_DIR/gen/sram_solution.csv
