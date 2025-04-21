## Voyager-test

Voyager-test 是 Voyager 项目的测试框架。

### 构建 Voyager-test

```bash
cd voyager-test 
mkdir build
cmake ..
make
```

### 添加自定义 workload (tutorial 案例分析)

1. 在workload的[CMakeLists.txt](src/workload/CMakeLists.txt)中添加`tutorial`的子项目, Voyager-test 中遵循上级CMakeLists中定义下级目录所在路径的规范.

```makefile
# src/workload/CMakeLists.txt
set(tutorial_WORKLOAD_DIR ${WORKLOAD_DIR}/tutorial) 
add_subdirectory(tutorial) # 添加tutorial子项目
```

2. 实现tutorial workload

- tutorial.c(src/workload/tutorial/tutorial.c): 简单实现一个hello world
- CMakeLists.txt(src/workload/tutorial/CMakeLists.txt)

#### tutorial子项目CMakeLists.txt 解读
创建tutorial子项目，默认使用编译器`riscv64-unknown-linux-gnu-gcc`用于构建linux版本workload; 如果要构建baremetal版本workload则需要单独使用`riscv64-unknown-elf-gcc`.

```makefile 
project(tutorial C)
set(CMAKE_C_COMPILER "riscv64-unknown-linux-gnu-gcc")  
```

这里是构建linux版本workload的配置，由于使用的是CMake定义的项目默认编译器，所以可以直接使用`CMAKE_EXE_LINKER_FLAGS`, `add_executable`等快捷CMake命令. tutorial-linux-build是build tutorial workload的target, 可以被其他target调用.

**文件命名规范**: `-linux` 表示构建linux版本workload, `-baremetal` 表示构建baremetal版本workload，一定要注意添加.

```makefile
#----------------------------------------------------------------
# build linux version workload
#----------------------------------------------------------------
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${WORKLOAD_BIN_DIR}/tutorial)

set(LINK_FLAGS "-static -Wl,--no-dynamic-linker")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINK_FLAGS}")

add_executable(tutorial-linux ${tutorial_WORKLOAD_DIR}/tutorial/tutorial.c)

add_custom_target(tutorial-linux-build ALL DEPENDS
    tutorial-linux
    COMMENT "Building linux workloads for tutorial"
    VERBATIM
)
```

**手动添加baremetal版本workload(敲黑板)** 由于baremetal版本workload的编译器不同于linux版本，所以需要手动添加baremetal版本workload的target，写法类似于Makefile. 无法使用CMake的脚手架.

```makefile
#----------------------------------------------------------------
# build baremetal version workload
#----------------------------------------------------------------
set(ELF_CC "riscv64-unknown-elf-gcc")  

set(C_FLAGS -std=c11 -g -fno-common -O2 -static 
            -fno-builtin-printf -specs=htif_nano.specs)

add_custom_target(tutorial-baremetal-build ALL
    COMMAND ${ELF_CC} ${C_FLAGS}
            -o ${WORKLOAD_BIN_DIR}/tutorial/tutorial-baremetal
            ${tutorial_WORKLOAD_DIR}/tutorial/tutorial.c
    DEPENDS ${tutorial_WORKLOAD_DIR}/tutorial/tutorial.c
    COMMENT "Building baremetal workloads for tutorial"
    VERBATIM)
```

汇总构建linux和baremetal版本tutorial workload的target，可以由上层的target调用.

```makefile
#----------------------------------------------------------------
# build all version workload
#----------------------------------------------------------------
add_custom_target(tutorial-build ALL DEPENDS
    tutorial-linux-build
    tutorial-baremetal-build
    VERBATIM)
```

3. 向上[CMakeLists.txt](./CMakeLists.txt)添加构建tutorial workload的target

```makefile
# ./CMakeLists.txt
add_custom_target(build-all ALL DEPENDS
    create-dirs
    cpu-build
    npu-build
    tutorial-build # 添加tutorial workload的target
)
```

4. 来到voyager-test根目录的`build`目录, 执行`make tutorial-build`命令, 可以看到顺利构建tutorial workload. Enjoy it!

### workload 进阶教程 

#### 使用 buddy-compiler 编译 pytorch workload (LeNet 案例分析)

子项目为[lenet](./src/workloads/npu/buddy/lenet/README.md)