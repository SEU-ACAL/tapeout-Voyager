#!/bin/bash

# exit script if any command fails
set -e
set -o pipefail

CYDIR=$(git rev-parse --show-toplevel)

TOBE_REPLACED_DIR=${CYDIR}/sims/firesim/sim/make
RIGHT_FIRESIM_MAKE_DIR=${CYDIR}/scripts/firesim-make

# 检查目标目录是否存在
if [ ! -d "$TOBE_REPLACED_DIR" ]; then
    echo "Error: Target directory '$TOBE_REPLACED_DIR' does not exist"
    exit 1
fi

# 检查源目录是否存在
if [ ! -d "$RIGHT_FIRESIM_MAKE_DIR" ]; then
    echo "Error: Source directory '$RIGHT_FIRESIM_MAKE_DIR' does not exist"
    exit 1
fi

# 检查目标目录是否为空
if [ -z "$(ls -A "$TOBE_REPLACED_DIR")" ]; then
    echo "Error: Target directory '$TOBE_REPLACED_DIR' is empty"
    exit 1
fi

# 执行拷贝操作
echo "Copying files from $RIGHT_FIRESIM_MAKE_DIR to $TOBE_REPLACED_DIR..."
if cp -rv "$RIGHT_FIRESIM_MAKE_DIR"/* "$TOBE_REPLACED_DIR"/; then
    echo "Copy completed successfully"
else
    echo "Error: Copy operation failed"
    exit 1
fi

