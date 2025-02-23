project(npu_buddy C)

set(BUDDY_WORKLOAD_DIR ${NPU_WORKLOAD_DIR}/buddy)

set(CMAKE_C_COMPILER "g++")  
# set(CMAKE_C_COMPILER "riscv64-unknown-elf-gcc")  
# set(CMAKE_C_COMPILER "riscv64-unknown-linux-gnu-g++")  
# set(CMAKE_EXE_SUFFIX "-bin")  

add_compile_options(
    -std=c11
    -g
    -fno-common
    -O2
    -static
    -fno-builtin-printf
    -specs=htif_nano.specs
)


include_directories(
    include
)

add_executable(gemmini-spmm 
    ${BUDDY_WORKLOAD_DIR}/spmm/spmm.cpp  
    ${BUDDY_WORKLOAD_DIR}/spmm/v_isa.cpp
)


add_custom_target(gemmini-buddy ALL
    DEPENDS gemmini-spmm  # 修正目标名称
    COMMENT "Building Gemmini Buddy workloads"
)


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build)
