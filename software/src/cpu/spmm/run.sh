#!/bin/bash

# 运行裸机版本
echo "运行裸机版本 (spmm-baremetal)..."
spike --isa=rv64gc -m0x80000000:0x8000000 spmm-baremetal

# 如果有Linux版本，也可以运行
if [ -f "spmm-linux" ]; then
    echo "运行Linux版本 (spmm-linux)..."
    spike pk spmm-linux
fi

echo "运行完成!" 