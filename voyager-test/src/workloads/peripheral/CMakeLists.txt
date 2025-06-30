project(peripheral C)

#-------------------------------------------------------------------------------
# build linux version workload
#-------------------------------------------------------------------------------
set(LINK_FLAGS "-static -Wl,--no-dynamic-linker")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINK_FLAGS}")

add_executable(peripheral-linux ${PERIPHERAL_WORKLOAD_DIR}/peripheral.c)

add_custom_target(peripheral-linux-build ALL DEPENDS
    peripheral-linux
    COMMENT "Building linux workloads for tutorial"
    VERBATIM)

#-------------------------------------------------------------------------------
# build baremetal version workload
#-------------------------------------------------------------------------------
set(ELF_CC "riscv64-unknown-elf-gcc")  

set(C_FLAGS -std=c11 -g -fno-common -O2 -static 
            -fno-builtin-printf -specs=htif_nano.specs)

add_custom_target(peripheral-baremetal-build ALL
    COMMAND ${ELF_CC} ${C_FLAGS} -o peripheral-baremetal ${PERIPHERAL_WORKLOAD_DIR}/peripheral.c
    DEPENDS ${PERIPHERAL_WORKLOAD_DIR}/peripheral.c
    COMMENT "Building baremetal workloads for tutorial"
    VERBATIM)

#-------------------------------------------------------------------------------
# build all version workload
#-------------------------------------------------------------------------------
add_custom_target(peripheral-build ALL DEPENDS
    peripheral-linux-build
    peripheral-baremetal-build
    VERBATIM)
