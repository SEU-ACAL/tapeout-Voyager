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
add_executable(cpu-bfs-linux ${CPU_WORKLOAD_DIR}/prefetch/bfs/bfs.c)
add_executable(cpu-hash-linux ${CPU_WORKLOAD_DIR}/prefetch/hash/hash.c)

add_custom_target(cpu-linux-build ALL DEPENDS
    hello-linux
    cpu-spmm-linux
    cpu-bfs-linux
    cpu-hash-linux
    COMMENT "Building linux workloads for CPU"
    VERBATIM)

#-------------------------------------------------------------------------------
# build baremetal version workload
#
# add your new baremetal workload here
# COMMAND ${ELF_CC} ${C_FLAGS} 
#        -o ${WORKLOAD_BIN_DIR}/cpu/cpu-test-baremetal
#        ${CPU_WORKLOAD_DIR}/test/test.c
# DEPENDS ${CPU_WORKLOAD_DIR}/test/test.c
#
# this method may be ugly, but it's easy to be understood by everyone 
# and easy to be extended. I suggest you to add your new workload with name not 
# vague like "mytest", but with a specific name, for example, "hash"
#-------------------------------------------------------------------------------
set(C_FLAGS -std=c11 -g -fno-common -O2 -static 
    -fno-builtin-printf -specs=htif_nano.specs)
set(ELF_CC "riscv64-unknown-elf-gcc")

add_custom_target(cpu-baremetal-build ALL
    COMMAND ${ELF_CC} ${C_FLAGS} 
            -o ${WORKLOAD_BIN_DIR}/cpu/hello-baremetal
            ${CPU_WORKLOAD_DIR}/hello/hello.c
    COMMAND ${ELF_CC} ${C_FLAGS} 
            -o ${WORKLOAD_BIN_DIR}/cpu/bfs-baremetal
            ${CPU_WORKLOAD_DIR}/prefetch/bfs/bfs.c
    COMMAND ${ELF_CC} ${C_FLAGS} 
            -o ${WORKLOAD_BIN_DIR}/cpu/hash-baremetal
            ${CPU_WORKLOAD_DIR}/prefetch/hash/hash.c
    DEPENDS ${CPU_WORKLOAD_DIR}/hello/hello.c
            ${CPU_WORKLOAD_DIR}/prefetch/bfs/bfs.c
            ${CPU_WORKLOAD_DIR}/prefetch/hash/hash.c
    COMMENT "Building baremetal workloads for CPU"
    VERBATIM)

#-------------------------------------------------------------------------------
# build all version workload
#-------------------------------------------------------------------------------
add_custom_target(cpu-build ALL DEPENDS
    cpu-linux-build
    cpu-baremetal-build
    VERBATIM)
