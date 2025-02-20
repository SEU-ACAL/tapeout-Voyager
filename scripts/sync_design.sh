#!/bin/bash

CDIR=$(git rev-parse --show-toplevel)

# chipyard/generator -> firesim/target-design/chipyard
SOURCE_DIR="$CDIR/generator"
DEST_DIR="$CDIR/sims/firesim/target-design/chipyard"

# 检查源文件夹是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "source dir: $SOURCE_DIR not found"
    exit 1
fi

# 创建目标文件夹（如果不存在）
mkdir -p "$DEST_DIR"

# 使用rsync命令拷贝RTL design
rsync -av --progress "$SOURCE_DIR/" "$DEST_DIR/"

echo "Sync Complete!"
