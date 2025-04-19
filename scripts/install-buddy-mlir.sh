#!/usr/bin/env bash

# exit script if any command fails
set -e
set -o pipefail

CYDIR=$(git rev-parse --show-toplevel)

source ${CYDIR}/env.sh
conda install python=3.10
conda install numpy pybind11

cd ${CYDIR}/tools/buddy-mlir
mkdir llvm/build && cd llvm/build
cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="mlir;clang" \
    -DLLVM_TARGETS_TO_BUILD="host;RISCV" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
    -DPython3_EXECUTABLE=$(which python3)
ninja check-mlir check-clang

cd ${CYDIR}/tools/buddy-mlir
mkdir build && cd build
cmake -G Ninja .. \
    -DMLIR_DIR=$PWD/../llvm/build/lib/cmake/mlir \
    -DLLVM_DIR=$PWD/../llvm/build/lib/cmake/llvm \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DBUDDY_MLIR_ENABLE_PYTHON_PACKAGES=ON \
    -DPython3_EXECUTABLE=$(which python3)
ninja
ninja check-buddy

export BUDDY_MLIR_BUILD_DIR=${CYDIR}/tools/buddy-mlir/build
export LLVM_MLIR_BUILD_DIR=${CYDIR}/tools/buddy-mlir/llvm/build
export PYTHONPATH=${LLVM_MLIR_BUILD_DIR}/tools/mlir/python_packages/mlir_core:${BUDDY_MLIR_BUILD_DIR}/python_packages:${PYTHONPATH}

echo "Buddy MLIR installed successfully!"
echo "PYTHONPATH is set to: ${PYTHONPATH}"
