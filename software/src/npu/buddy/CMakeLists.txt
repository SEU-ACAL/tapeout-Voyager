project(npu_buddy C)

set(BUDDY_WORKLOAD_DIR ${NPU_WORKLOAD_DIR}/buddy)

#-------------------------------------------------------------------------------
# build baremetal version workload
#-------------------------------------------------------------------------------
set(ELF_CXX "riscv64-unknown-elf-g++")  
set(CXX_FLAGS -g -fno-common -O2 -static 
    -fno-builtin-printf -specs=htif_nano.specs)
set(INCLUDE_PATH include)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${WORKLOAD_BIN_DIR}/npu/buddy)

add_custom_target(gemmini-spmm ALL
    COMMAND ${ELF_CXX} ${CXX_FLAGS}
        -I ${INCLUDE_PATH}
        -o ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/spmm-baremetal
        ${BUDDY_WORKLOAD_DIR}/spmm/spmm.cpp
        ${BUDDY_WORKLOAD_DIR}/spmm/v_isa.cpp
    VERBATIM)

add_custom_target(gemmini-buddy ALL
    DEPENDS gemmini-spmm  
    COMMENT "Building Gemmini Buddy workloads"
)
