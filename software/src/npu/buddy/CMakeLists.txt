project(npu_buddy CXX)

set(BUDDY_WORKLOAD_DIR ${NPU_WORKLOAD_DIR}/buddy)

# set(CMAKE_C_COMPILER "g++")  
set(CMAKE_C_COMPILER "riscv64-unknown-elf-g++")  
# set(CMAKE_C_COMPILER "riscv64-unknown-linux-gnu-gcc")  

# set(CMAKE_CXX_FLAGS "-O2")
# set(CMAKE_EXE_LINKER_FLAGS "-specs=htif_nano.specs -specs=htif_argv.specs") 
# 不知道为啥在这用htif_nano.specs识别不到，只能用command写了

include_directories(
    include
)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${WORKLOAD_BIN_DIR}/npu/buddy)

# add_executable(gemmini-spmm 
#     ${BUDDY_WORKLOAD_DIR}/spmm/spmm.cpp  
#     ${BUDDY_WORKLOAD_DIR}/spmm/v_isa.cpp
# )

add_custom_target(gemmini-spmm ALL
    COMMAND riscv64-unknown-elf-g++ -O2
        -specs=htif_nano.specs
        -specs=htif_argv.specs
        -o ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/spmm
        ${BUDDY_WORKLOAD_DIR}/spmm/spmm.cpp
        ${BUDDY_WORKLOAD_DIR}/spmm/v_isa.cpp
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    VERBATIM)

add_custom_target(gemmini-buddy ALL
    DEPENDS gemmini-spmm  
    COMMENT "Building Gemmini Buddy workloads"
)
