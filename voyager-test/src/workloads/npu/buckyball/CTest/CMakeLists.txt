set(RISCV_GNU_TOOLCHAIN ${CYDIR}/.conda-env/riscv-tools)
set(ELF_CC "riscv64-unknown-elf-gcc")
set(LINUX_CC "riscv64-unknown-linux-gnu-g++")

set(BUDDY_BINARY_DIR ${BUDDY_MLIR_DIR}/build/bin)
set(BUDDY_OPT ${BUDDY_BINARY_DIR}/buddy-opt)
set(BUDDY_TRANSLATE ${BUDDY_BINARY_DIR}/buddy-translate)
set(BUDDY_LLC ${BUDDY_BINARY_DIR}/buddy-llc)

set(BUCKYBALL_CTEST_DIR ${BUCKYBALL_WORKLOAD_DIR}/CTest)

set(CMAKE_C_COMPILER "riscv64-unknown-linux-gnu-g++")  

#-------------------------------------------------------------------------------
# build linux version workload (current not supported)
#-------------------------------------------------------------------------------
set(LINK_FLAGS "-static -Wl,--no-dynamic-linker")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINK_FLAGS}")
# add_compile_options(-O2 -static)

add_executable(ctest_mvin_mvout-linux ${BUCKYBALL_CTEST_DIR}/mvin_mvout.c)
add_executable(ctest_vecunit_matmul-linux ${BUCKYBALL_CTEST_DIR}/vecunit_matmul.c)
add_executable(ctest_acc_matmul-linux ${BUCKYBALL_CTEST_DIR}/acc_matmul.c)

add_custom_target(buckyball-CTest-linux ALL DEPENDS
    ctest_mvin_mvout-linux
    COMMENT "Building linux workloads for Buckyball"
    VERBATIM)

#-------------------------------------------------------------------------------
# build baremetal version workload
#-------------------------------------------------------------------------------

set(C_FLAGS -std=gnu11 -g -DCHECK=1 -fno-common -O2 -static 
    -fno-builtin-printf -specs=htif_nano.specs -I${BUCKYBALL_CTEST_DIR})

set(ELF_CC "riscv64-unknown-elf-gcc")

add_custom_target(buckyball-CTest-multicore-baremetal ALL
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_mvin_mvout_multicore-baremetal ${BUCKYBALL_CTEST_DIR}/start.S
            -DMULTICORE=5
            ${BUCKYBALL_CTEST_DIR}/mvin_mvout.c 
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_vecunit_matmul_multicore-baremetal ${BUCKYBALL_CTEST_DIR}/start.S
            -DMULTICORE=5
            ${BUCKYBALL_CTEST_DIR}/vecunit_matmul.c 
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_acc_matmul_multicore-baremetal ${BUCKYBALL_CTEST_DIR}/start.S
            -DMULTICORE=5
            ${BUCKYBALL_CTEST_DIR}/acc_matmul.c
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_bbfp_matmul_multicore-baremetal ${BUCKYBALL_CTEST_DIR}/start.S
            -DMULTICORE=5
            ${BUCKYBALL_CTEST_DIR}/bbfpmatmul.c
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_bbfptest_multicore-baremetal ${BUCKYBALL_CTEST_DIR}/start.S
            -DMULTICORE=5
            ${BUCKYBALL_CTEST_DIR}/bbfptest.c
    DEPENDS ${BUCKYBALL_CTEST_DIR}/mvin_mvout.c 
            ${BUCKYBALL_CTEST_DIR}/vecunit_matmul.c 
            ${BUCKYBALL_CTEST_DIR}/acc_matmul.c
            ${BUCKYBALL_CTEST_DIR}/bbfpmatmul.c
            ${BUCKYBALL_CTEST_DIR}/bbfptest.c
            ${BUCKYBALL_CTEST_DIR}/start.S
    COMMENT "Building baremetal workloads for Buckyball"
    VERBATIM)

add_custom_target(buckyball-CTest-singlecore-baremetal ALL
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_mvin_mvout_singlecore-baremetal 
            -DMULTICORE=5
            ${BUCKYBALL_CTEST_DIR}/mvin_mvout.c 
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_vecunit_matmul_singlecore-baremetal 
            -DMULTICORE=5
            ${BUCKYBALL_CTEST_DIR}/vecunit_matmul.c 
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_acc_matmul_singlecore-baremetal 
            -DMULTICORE=5
            ${BUCKYBALL_CTEST_DIR}/acc_matmul.c
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_bbfp_matmul_singlecore-baremetal ${BUCKYBALL_CTEST_DIR}/start.S
            -DMULTICORE=5
            ${BUCKYBALL_CTEST_DIR}/bbfpmatmul.c
    COMMAND ${ELF_CC} ${C_FLAGS} -o ctest_bbfptest_singlecore-baremetal ${BUCKYBALL_CTEST_DIR}/start.S
            -DMULTICORE=5
            ${BUCKYBALL_CTEST_DIR}/bbfptest.c
    DEPENDS ${BUCKYBALL_CTEST_DIR}/mvin_mvout.c 
            ${BUCKYBALL_CTEST_DIR}/vecunit_matmul.c 
            ${BUCKYBALL_CTEST_DIR}/acc_matmul.c
            ${BUCKYBALL_CTEST_DIR}/bbfpmatmul.c
            ${BUCKYBALL_CTEST_DIR}/bbfptest.c
    COMMENT "Building baremetal workloads for Buckyball"
    VERBATIM)


add_custom_target(buckyball-CTest ALL DEPENDS
  buckyball-CTest-multicore-baremetal
  buckyball-CTest-singlecore-baremetal
  buckyball-CTest-linux
  COMMENT "Building baremetal workloads for Buckyball"
  VERBATIM
  )