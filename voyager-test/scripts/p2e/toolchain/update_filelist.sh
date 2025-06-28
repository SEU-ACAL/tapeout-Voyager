#!/bin/bash

CYDIR=$(git rev-parse --show-toplevel)
SCRIPT_DIR=$CYDIR/voyager-test/scripts/p2e
OUTPUT_DIR=$SCRIPT_DIR/../../output/p2e
GEN_DIR=$OUTPUT_DIR/gen-collateral
FILELIST_F=$GEN_DIR/filelist.f


# 1 添加XRAM的文件列表
cp -r $SCRIPT_DIR/xram/xramfile.f $GEN_DIR/

# 2. 先收集所有 .sv/.v 文件名（不加前缀/不加include）
find $GEN_DIR -maxdepth 1 -type f \( -name "*.sv" -o -name "*.v" \) | sort | xargs -n1 basename > $FILELIST_F

# 3. 统一加前缀并加include路径
{
  echo "+incdir+\${VSRC_PATH}"
  for f in $(cat "$FILELIST_F"); do
    echo "\${VSRC_PATH}/$f"
  done
  # 4. 添加特殊文件
  for f in $(cat $GEN_DIR/xramfile.f); do
    echo "\${VSRC_PATH}/$f"
  done
  echo "\${VSRC_PATH}/xepic_golden_ip.sv" 
  echo "\${XRAM_HOME}/P2_Emu/wrapper/xram_bbox_wrapper.v" 
} > $FILELIST_F.tmp && mv $FILELIST_F.tmp $FILELIST_F

# 1. 实际添加XRAM相关文件
cp -r $SCRIPT_DIR/xram/* $GEN_DIR/

echo "处理完成，已更新 $FILELIST_F"
