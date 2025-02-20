cmake_minimum_required(VERSION 3.12)
project(Workload_Collection)

set(BUILD_ROOT "${CMAKE_BINARY_DIR}")
set(BIN_DIR "${CMAKE_SOURCE_DIR}/bin")
set(SRC_DIR "${CMAKE_SOURCE_DIR}/src")

file(MAKE_DIRECTORY ${BIN_DIR})
file(MAKE_DIRECTORY ${BIN_DIR}/cpu)
file(MAKE_DIRECTORY ${BIN_DIR}/npu)

# set(ENV{CC} "riscv64-unknown-elf-gcc")
# set(ENV{CFLAGS} "-std=c11 -g -fno-common -O2 -static -fno-builtin-printf -specs=htif_nano.specs")
# set(ENV{LDFLAGS} "")
# set(ENV{INC_PATH} "${CMAKE_SOURCE_DIR}/include")

add_custom_target(all-bin
    DEPENDS cpu-bin npu-bin
    COMMENT "Building all workloads Complete."
)

add_custom_target(cpu-bin
    COMMAND cd ${SRC_DIR}/cpu && make clean && make all -j
    COMMAND cp -r ${SRC_DIR}/cpu/build/* ${BIN_DIR}/cpu/
    COMMENT "Building CPU workload."
)

add_custom_target(npu-bin
    COMMAND cd ${SRC_DIR}/npu && make clean && make all -j 
    COMMAND cp -r ${SRC_DIR}/npu/build/* ${BIN_DIR}/npu/
    COMMENT "Building NPU workload."
)

add_custom_target(clean_all
    COMMAND make -C ${BIN_DIR}/cpu clean
    COMMAND make -C ${BIN_DIR}/npu clean
)
