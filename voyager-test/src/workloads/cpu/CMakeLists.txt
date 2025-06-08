
#-------------------------------------------------------------------------------
# build linux version workload
#-------------------------------------------------------------------------------
set(LINK_FLAGS "-static -Wl,--no-dynamic-linker")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINK_FLAGS}")
# add_compile_options(-O2 -static)
add_executable(hello-linux ${CPU_WORKLOAD_DIR}/hello/hello.c )
add_executable(cpu-spmm-linux ${CPU_WORKLOAD_DIR}/spmm/spmm.c)
add_executable(bfs-linux ${CPU_WORKLOAD_DIR}/prefetch/bfs/bfs.c)
add_executable(hash-linux ${CPU_WORKLOAD_DIR}/prefetch/hash/hash.c)

add_custom_target(cpu-linux-build ALL DEPENDS
    hello-linux
    cpu-spmm-linux
    bfs-linux
    hash-linux
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

# 此处开启了CHECK宏
include_directories(${CPU_WORKLOAD_DIR}/meeklib)
set(C_FLAGS -std=gnu11 -g -DCHECK=1 -fno-common -O2 -static 
    -fno-builtin-printf -specs=htif_nano.specs -I${CPU_WORKLOAD_DIR}/meeklib)

set(ELF_CC "riscv64-unknown-elf-gcc")

add_custom_target(cpu-baremetal-build ALL
    COMMAND ${ELF_CC} ${C_FLAGS} -o hello-baremetal
            ${CPU_WORKLOAD_DIR}/hello/hello.c ${CPU_WORKLOAD_DIR}/meeklib/meek.c 
    COMMAND ${ELF_CC} ${C_FLAGS} -o bfs-baremetal
            ${CPU_WORKLOAD_DIR}/prefetch/bfs/bfs.c ${CPU_WORKLOAD_DIR}/meeklib/meek.c 
    COMMAND ${ELF_CC} ${C_FLAGS} -o hash-baremetal
            ${CPU_WORKLOAD_DIR}/prefetch/hash/hash.c ${CPU_WORKLOAD_DIR}/meeklib/meek.c 
    DEPENDS ${CPU_WORKLOAD_DIR}/hello/hello.c
            ${CPU_WORKLOAD_DIR}/prefetch/bfs/bfs.c 
            ${CPU_WORKLOAD_DIR}/prefetch/hash/hash.c ${CPU_WORKLOAD_DIR}/meeklib/meek.c 
    COMMENT "Building baremetal workloads for CPU"
    VERBATIM)

#-------------------------------------------------------------------------------
# build all version workload
#-------------------------------------------------------------------------------
add_custom_target(cpu-build ALL DEPENDS
    cpu-linux-build
    cpu-baremetal-build
    VERBATIM)
