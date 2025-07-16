#!/bin/bash

# 获取项目根目录
# CYDIR=$(git rev-parse --show-toplevel)
# SCRIPT_DIR=$CYDIR/voyager-test/scripts/p2e
# OUTPUT_DIR=$SCRIPT_DIR/../../output/p2e
# GEN_DIR=$OUTPUT_DIR/gen-collateral

# # 查找所有 GenericDigitalGPIOCell.v 文件
# find "$OUTPUT_DIR" -name "GenericDigitalGPIOCell.v" | while read -r file; do
#   echo "处理文件: $file"
  
#   # 检查文件是否包含 "assign pad =" 行
#   if grep -q "assign pad =" "$file"; then
#     # 创建临时文件
#     tmp_file=$(mktemp)
    
#     # 使用 sed 将 "assign pad =" 行注释掉（如果尚未注释）
#     sed -E 's/^([[:space:]]*)assign pad =(.*)$/\1\/\/ assign pad =\2/' "$file" > "$tmp_file"
    
#     # 替换原文件
#     mv "$tmp_file" "$file"
#     echo "已将 'assign pad =' 行注释掉"
#   else
#     echo "未找到 'assign pad =' 行，或该行已被注释"
#   fi
# done

# echo "处理完成。"