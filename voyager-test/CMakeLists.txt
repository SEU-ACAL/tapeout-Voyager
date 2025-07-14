cmake_minimum_required(VERSION 3.12)
project(VoyagerTest)

set(BUILD_ROOT "${CMAKE_BINARY_DIR}")
set(SRC_DIR "${CMAKE_SOURCE_DIR}/src")
set(BUILD_BIN_DIR "${BUILD_ROOT}/src/workloads")
set(OUTPUT_BIN_DIR "${CMAKE_SOURCE_DIR}/output/workloads")
set(RTL_BUILD_DIR "${CMAKE_SOURCE_DIR}/output")

# get the root directory of the project
execute_process(
  COMMAND git rev-parse --show-toplevel
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE CYDIR
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
set(VOYAGER_TEST_DIR ${CYDIR}/voyager-test)

#-------------------------------------------------------------------------------
# add marshal's path
#-------------------------------------------------------------------------------
set(MARSHAL ${CYDIR}/sims/firesim/sw/firesim-software/marshal)

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
file(MAKE_DIRECTORY ${OUTPUT_BIN_DIR})
file(MAKE_DIRECTORY ${OUTPUT_BIN_DIR}/npu/native)
file(MAKE_DIRECTORY ${RTL_BUILD_DIR}/verilator)
file(MAKE_DIRECTORY ${RTL_BUILD_DIR}/marshal)
file(MAKE_DIRECTORY ${RTL_BUILD_DIR}/marshal/overlay/root)

#-------------------------------------------------------------------------------
# set custom target
#-------------------------------------------------------------------------------
add_custom_target(create-dirs
  COMMAND mkdir -p ${OUTPUT_BIN_DIR}
  COMMAND mkdir -p ${OUTPUT_BIN_DIR}/npu/native
  COMMAND mkdir -p ${RTL_BUILD_DIR}/verilator
  COMMAND mkdir -p ${RTL_BUILD_DIR}/marshal
  COMMENT "Creating necessary directories"
)

add_custom_target(build-compiler
  COMMAND ${CYDIR}/voyager-test/scripts/build-compiler.sh
  COMMENT "Building Buddy Compiler"
)

add_custom_target(sync-bin
  COMMAND rsync -av --exclude="CMakeFiles" 
          --include="*/" --include="*-baremetal" --include="*-linux" 
          --exclude="*" 
          ${BUILD_BIN_DIR}/ ${OUTPUT_BIN_DIR}/
  COMMENT "Syncing binary files to output directory"
)

# 设置执行顺序：build-compiler 必须先于 buckyball-OpTest 完成，sync-bin 必须最后执行
add_dependencies(gemmini-native create-dirs)
add_dependencies(buckyball-OpTest build-compiler) # 属于 npu-build 的子目录，由于依赖需要直接指定

add_dependencies(sync-bin 
  cpu-build 
  npu-build 
  pll-build 
  tutorial-build 
  peripheral-build 
  embench-build
  parsecv3-build
  boardtest-build)
add_custom_target(build-all ALL 
  DEPENDS sync-bin
)

add_custom_target(clean-all
  COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target clean
  COMMAND rm -rf ${OUTPUT_BIN_DIR}
  COMMENT "Cleaning all build artifacts"
)

