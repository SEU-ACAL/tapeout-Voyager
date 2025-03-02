cmake_minimum_required(VERSION 3.12)
project(Workload)

set(BUILD_ROOT "${CMAKE_BINARY_DIR}")
set(SRC_DIR "${CMAKE_SOURCE_DIR}/src")
set(WORKLOAD_BIN_DIR "${CMAKE_SOURCE_DIR}/build-results/workloads")
set(RTL_BUILD_DIR "${CMAKE_SOURCE_DIR}/build-results")

#-------------------------------------------------------------------------------
# add_subdirectory
#-------------------------------------------------------------------------------
add_subdirectory(src)

#-------------------------------------------------------------------------------
# set Compiler
#-------------------------------------------------------------------------------
# 全局默认的是使用linux-g++作为C编译器，使用elf-gcc编译baremetal的情况在底层自行独立实现
set(CMAKE_C_COMPILER "riscv64-unknown-linux-gnu-g++")  

#-------------------------------------------------------------------------------
# setup directory
#-------------------------------------------------------------------------------
# cmake 时候就会创建
file(MAKE_DIRECTORY ${WORKLOAD_BIN_DIR})
file(MAKE_DIRECTORY ${WORKLOAD_BIN_DIR}/cpu)
file(MAKE_DIRECTORY ${WORKLOAD_BIN_DIR}/npu)
file(MAKE_DIRECTORY ${WORKLOAD_BIN_DIR}/npu/buddy)
file(MAKE_DIRECTORY ${WORKLOAD_BIN_DIR}/npu/native)
file(MAKE_DIRECTORY ${RTL_BUILD_DIR}/verilator)
file(MAKE_DIRECTORY ${RTL_BUILD_DIR}/firesim)

#-------------------------------------------------------------------------------
# set custom target
#-------------------------------------------------------------------------------
# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${WORKLOAD_BIN_DIR})
add_custom_target(create-dirs
    COMMAND mkdir -p ${WORKLOAD_BIN_DIR}
    COMMAND mkdir -p ${WORKLOAD_BIN_DIR}/cpu
    COMMAND mkdir -p ${WORKLOAD_BIN_DIR}/npu
    COMMAND mkdir -p ${WORKLOAD_BIN_DIR}/npu/buddy
    COMMAND mkdir -p ${WORKLOAD_BIN_DIR}/npu/native
    COMMAND mkdir -p ${RTL_BUILD_DIR}/verilator
    COMMAND mkdir -p ${RTL_BUILD_DIR}/firesim
    COMMENT "Creating necessary directories"
)

add_custom_target(build-all ALL DEPENDS
    create-dirs
    cpu-build
    npu-build
)

add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target clean
    COMMAND rm -rf ${WORKLOAD_BIN_DIR}
    COMMENT "Cleaning all build artifacts"
)

