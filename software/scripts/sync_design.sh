#!/bin/bash

CDIR=$(git rev-parse --show-toplevel)

# 默认 firesim 路径
FIRESIM_PATH="$CDIR/../firesim"

# 解析命令行参数 --firesim /path/to/your/firesim
while [[ $# -gt 0 ]]; do
    case "$1" in
        --firesim)
            if [ -z "$2" ]; then
                echo "Error: --firesim requires a path argument."
                exit 1
            fi
            FIRESIM_PATH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

SOURCE_DIR="$CDIR/generators/"
DEST_DIR="$FIRESIM_PATH/target-design/chipyard"

# 检查源文件夹是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source dir: $SOURCE_DIR not found"
    exit 1
fi

rm -rf ${DEST_DIR}/*
mkdir -p "$DEST_DIR/generators"

# 使用 rsync 命令拷贝 RTL design
rsync -av --progress "$SOURCE_DIR/" "$DEST_DIR/generators"


SOURCE_DIR="$CDIR/project/"
DEST_DIR="$FIRESIM_PATH/target-design/chipyard"

# 使用 rsync 命令拷贝 RTL design
rsync -av --progress "$SOURCE_DIR/" "$DEST_DIR/project"

SOURCE_DIR="$CDIR/sims/firesim/sim/firesim-lib"
DEST_DIR="$FIRESIM_PATH/sim/firesim-lib"

rm -rf ${DEST_DIR}/*
rsync -av --progress "$SOURCE_DIR/" "$DEST_DIR/"

echo "Sync Complete!"
