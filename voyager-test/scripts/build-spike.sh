#!/bin/bash

CYDIR=$(git rev-parse --show-toplevel)

cd "$CYDIR/generators/buckyball/spike/build"
cmake ..
make install

cd "$CYDIR/toolchains/riscv-tools/riscv-isa-sim/build"
make
make install

echo "Spike Buckyball Extension Build completed!"
