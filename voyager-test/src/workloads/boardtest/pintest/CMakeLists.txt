project(pintest C)

#-------------------------------------------------------------------------------
# build linux version workload
#-------------------------------------------------------------------------------
set(LINK_FLAGS "-static -Wl,--no-dynamic-linker")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINK_FLAGS}")

set(CMAKE_C_COMPILER "riscv64-unknown-linux-gnu-g++")  

add_executable(pintest-linux ${BOARDTEST_WORKLOAD_DIR}/pintest/pintest.c)
add_custom_target(pintest-linux-build ALL DEPENDS
    pintest-linux
    COMMENT "Building linux workloads for pintest"
    VERBATIM)

#-------------------------------------------------------------------------------
# build all version workload
#-------------------------------------------------------------------------------
add_custom_target(pintest-build ALL DEPENDS
    pintest-linux-build
    VERBATIM)
