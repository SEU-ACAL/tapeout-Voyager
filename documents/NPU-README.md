# NPU 方向开发指南

## NPU调试配置
一核gemmini调试配置为Config=

## BuddyCompiler 安装与使用

以 BuddyCompiler 安装在外部，workload写在software为例
```
git clone https://github.com/buddy-compiler/buddy-mlir.git
cd buddy-mlir
git submodule update --init

mkdir llvm/build && cd llvm/build
cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="mlir;clang" \
    -DLLVM_TARGETS_TO_BUILD="host;RISCV" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
    -DPython3_EXECUTABLE=$(which python3)


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

按照这个链接，安装交叉编译环境
https://github.com/buddy-compiler/buddy-mlir/blob/main/docs/RVVEnvironment.md


## E2E buddy-mlir for gemmini
https://github.com/shirohasuki/buddy-examples/blob/main/BuddyGemmini/README.md