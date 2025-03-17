# NPU 方向开发指南

## NPU调试配置
gemmini单独调试配置为--config CustomGemminiSoCConfig

## BuddyCompiler 安装与使用

以 BuddyCompiler 安装在外部，workload写在software为例
```
mkdir buddy-mlir && cd buddy-mlir
git clone https://github.com/SEU-ACAL/tapeout-Compiler.git .
git checkout voyager 
git submodule update --init

conda create -n BuddyMLIR python=3.10
conda activate BuddyMLIR
conda install numpy pybind11

cd buddy-mlir
mkdir llvm/build && cd llvm/build
cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="mlir;clang" \
    -DLLVM_TARGETS_TO_BUILD="host;RISCV" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
    -DPython3_EXECUTABLE=$(which python3)
ninja check-mlir check-clang

cd buddy-mlir
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
export BUDDY_MLIR_BUILD_DIR=$PWD
export LLVM_MLIR_BUILD_DIR=$PWD/../llvm/build
export PYTHONPATH=${LLVM_MLIR_BUILD_DIR}/tools/mlir/python_packages/mlir_core:${BUDDY_MLIR_BUILD_DIR}/python_packages:${PYTHONPATH}
```


## E2E buddy-mlir for gemmini
https://github.com/shirohasuki/buddy-examples/blob/main/BuddyGemmini/README.md