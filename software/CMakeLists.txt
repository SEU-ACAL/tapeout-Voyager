cmake_minimum_required(VERSION 3.12)
project(Workload_Collection)

set(BUILD_ROOT "${CMAKE_BINARY_DIR}")
set(SRC_DIR "${CMAKE_SOURCE_DIR}/src")
set(WORKLOAD_BIN_DIR "${CMAKE_SOURCE_DIR}/build-results/workloads")
set(RTL_BUILD_DIR "${CMAKE_SOURCE_DIR}/build-results")

# cmake 时候就会创建
file(MAKE_DIRECTORY ${WORKLOAD_BIN_DIR})
file(MAKE_DIRECTORY ${WORKLOAD_BIN_DIR}/cpu)
file(MAKE_DIRECTORY ${WORKLOAD_BIN_DIR}/npu)

file(MAKE_DIRECTORY ${RTL_BUILD_DIR}/verilator)
file(MAKE_DIRECTORY ${RTL_BUILD_DIR}/firesim)


# set(ENV{CC} "riscv64-unknown-elf-gcc")
# set(ENV{CFLAGS} "-std=c11 -g -fno-common -O2 -static -fno-builtin-printf -specs=htif_nano.specs")
# set(ENV{LDFLAGS} "")
# set(ENV{INC_PATH} "${CMAKE_SOURCE_DIR}/include")

# add_custom_target(all-bin
#     DEPENDS cpu-bin npu-bin
#     COMMENT "Building all workloads Complete."
# )

# add_custom_target(cpu-bin
#     COMMAND cd ${SRC_DIR}/cpu && make clean && make all -j
#     COMMAND cp -r ${SRC_DIR}/cpu/build/* ${WORKLOAD_BIN_DIR}/cpu/
#     COMMENT "Building CPU workload."
# )

# add_custom_target(npu-bin
#     COMMAND cd ${SRC_DIR}/npu && make clean && make all -j 
#     COMMAND cp -r ${SRC_DIR}/npu/build/* ${WORKLOAD_BIN_DIR}/npu/
#     COMMENT "Building NPU workload."
# )

add_subdirectory(src)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${WORKLOAD_BIN_DIR})

add_custom_target(build-all ALL DEPENDS
    cpu-build
    gemmini-buddy 
    gemmini-native
)

add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target clean
    COMMAND rm -rf ${CMAKE_SOURCE_DIR}/build
    COMMENT "Cleaning all build artifacts"
)

