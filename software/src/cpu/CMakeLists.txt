project(cpu C)

set(CPU_WORKLOAD_DIR ${WORKLOAD_DIR}/cpu)

#-------------------------------------------------------------------------------
# build linux version workload
#-------------------------------------------------------------------------------
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${WORKLOAD_BIN_DIR}/cpu)
add_executable(hello-linux ${CPU_WORKLOAD_DIR}/hello/hello.c)
add_executable(spmm-linux ${CPU_WORKLOAD_DIR}/spmm/spmm.c)

add_custom_target(cpu-linux-build ALL DEPENDS
    hello-linux
    spmm-linux
    COMMENT "Building linux workloads for CPU"
    VERBATIM)

#-------------------------------------------------------------------------------
# build baremetal version workload
#-------------------------------------------------------------------------------
set(ELF_CC "riscv64-unknown-elf-gcc")  

set(C_FLAGS 
    -std=c11 -g -fno-common -O2 -static 
    -fno-builtin-printf -specs=htif_nano.specs
)

add_custom_target( cpu-baremetal-build ALL
    COMMAND ${ELF_CC} ${C_FLAGS}
            -o ${WORKLOAD_BIN_DIR}/cpu/hello-baremetal
            ${CPU_WORKLOAD_DIR}/hello/hello.c
    COMMAND riscv64-unknown-elf-gcc ${C_FLAGS}
            -o ${WORKLOAD_BIN_DIR}/cpu/spmm-baremetal
            ${CPU_WORKLOAD_DIR}/spmm/spmm.c
    DEPENDS ${CPU_WORKLOAD_DIR}/hello/hello.c
            ${CPU_WORKLOAD_DIR}/spmm/spmm.c
    COMMENT "Building baremetal workloads for CPU"
    VERBATIM)

#-------------------------------------------------------------------------------
# build baremetal version workload
#-------------------------------------------------------------------------------
add_custom_target(cpu-build ALL DEPENDS
    cpu-linux-build
    cpu-baremetal-build
    VERBATIM)