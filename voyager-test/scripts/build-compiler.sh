#!/bin/bash

CYDIR=$(git rev-parse --show-toplevel)
# 切换环境变量
source ${CYDIR}/env.sh

cd ${CYDIR}/tools/buddy-mlir/build || { echo "Cannot enter the directory: ${CYDIR}/tools/buddy-mlir/build"; exit 1; }
ninja -j256
