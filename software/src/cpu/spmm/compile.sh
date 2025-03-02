#!/bin/bash

# 确保RISCV工具链在PATH中
# 请根据您的实际环境设置RISCV路径
# export RISCV=/path/to/riscv/toolchain

# 静态编译spmm程序
riscv64-unknown-elf-gcc -static -O2 -march=rv64g -mabi=lp64d \
    -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
    -DBAREMETAL \
    -T link.ld \
    -o spmm-baremetal spmm.c crt.S

# 如果需要普通Linux环境下的版本
riscv64-unknown-linux-gnu-gcc -static -O2 \
    -o spmm-linux spmm.c

echo "编译完成！" 