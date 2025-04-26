project(cpu C)

#-------------------------------------------------------------------------------
# build linux version workload
#-------------------------------------------------------------------------------
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${WORKLOAD_BIN_DIR}/cpu)

set(LINK_FLAGS "-static -Wl,--no-dynamic-linker")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINK_FLAGS}")
# add_compile_options(-O2 -static)
add_executable(hello-linux ${CPU_WORKLOAD_DIR}/hello/hello.c)
add_executable(cpu-spmm-linux ${CPU_WORKLOAD_DIR}/spmm/spmm.c)

add_custom_target(cpu-linux-build ALL DEPENDS
    hello-linux
    cpu-spmm-linux
    COMMENT "Building linux workloads for CPU"
    VERBATIM)

#-------------------------------------------------------------------------------
# build baremetal version workload
#-------------------------------------------------------------------------------
set(C_FLAGS -std=c11 -g -fno-common -O2 -static 
    -fno-builtin-printf -specs=htif_nano.specs)
set(ELF_CC "riscv64-unknown-elf-gcc")  

add_custom_target( cpu-baremetal-build ALL
    COMMAND ${ELF_CC} ${C_FLAGS}
            -o ${WORKLOAD_BIN_DIR}/cpu/hello-baremetal
            ${CPU_WORKLOAD_DIR}/hello/hello.c
    DEPENDS ${CPU_WORKLOAD_DIR}/hello/hello.c
    COMMENT "Building baremetal workloads for CPU"
    VERBATIM)

#-------------------------------------------------------------------------------
# build all version workload
#-------------------------------------------------------------------------------
add_custom_target(cpu-build ALL DEPENDS
    cpu-linux-build
    cpu-baremetal-build
    VERBATIM)
