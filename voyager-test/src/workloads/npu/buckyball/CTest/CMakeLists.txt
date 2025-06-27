set(RISCV_GNU_TOOLCHAIN ${CYDIR}/.conda-env/riscv-tools)
set(ELF_CC "riscv64-unknown-elf-gcc")
set(LINUX_CC "riscv64-unknown-linux-gnu-g++")

set(BUDDY_BINARY_DIR ${BUDDY_MLIR_DIR}/build/bin)
set(BUDDY_OPT ${BUDDY_BINARY_DIR}/buddy-opt)
set(BUDDY_TRANSLATE ${BUDDY_BINARY_DIR}/buddy-translate)
set(BUDDY_LLC ${BUDDY_BINARY_DIR}/buddy-llc)

set(BUCKYBALL_CTEST_DIR ${BUCKYBALL_WORKLOAD_DIR}/CTest)

#-------------------------------------------------------------------------------
# build linux version workload (current not supported)
#-------------------------------------------------------------------------------
# set(LINK_FLAGS "-static -Wl,--no-dynamic-linker")
# set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINK_FLAGS}")
# # add_compile_options(-O2 -static)

# add_executable(ctest_mvin_mvout-linux ${BUCKYBALL_CTEST_DIR}/mvin_mvout.c)

# add_custom_target(buckyball-CTest-linux ALL DEPENDS
#     ctest_mvin_mvout-linux
#     COMMENT "Building linux workloads for Buckyball"
#     VERBATIM)

#-------------------------------------------------------------------------------
# build baremetal version workload
#-------------------------------------------------------------------------------

set(C_FLAGS -std=gnu11 -g -DCHECK=1 -fno-common -O2 -static 
    -fno-builtin-printf -specs=htif_nano.specs -I${BUCKYBALL_CTEST_DIR})

set(ELF_CC "riscv64-unknown-elf-gcc")

add_custom_target(buckyball-CTest-baremetal ALL
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_mvin_mvout-baremetal
            ${BUCKYBALL_CTEST_DIR}/mvin_mvout.c 
    DEPENDS ${BUCKYBALL_CTEST_DIR}/mvin_mvout.c 
    COMMENT "Building baremetal workloads for Buckyball"
    VERBATIM)

# 添加新的 vecunit_matmul.c 编译目标
add_custom_target(buckyball-vecunit-matmul-baremetal ALL
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_vecunit_matmul-baremetal
            ${BUCKYBALL_CTEST_DIR}/vecunit_matmul.c 
    DEPENDS ${BUCKYBALL_CTEST_DIR}/vecunit_matmul.c 
    COMMENT "Building vecunit_matmul baremetal workload for Buckyball"
    VERBATIM)

add_custom_target(buckyball-CTest ALL DEPENDS
  buckyball-CTest-baremetal
  buckyball-vecunit-matmul-baremetal
  )