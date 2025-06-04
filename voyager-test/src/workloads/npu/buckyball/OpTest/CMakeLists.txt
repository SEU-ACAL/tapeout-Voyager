set(RISCV_GNU_TOOLCHAIN ${CYDIR}/.conda-env/riscv-tools)
set(ELF_CC "riscv64-unknown-elf-gcc")
set(LINUX_CC "riscv64-unknown-linux-gnu-g++")

set(BUDDY_BINARY_DIR ${BUDDY_MLIR_DIR}/build/bin)
set(BUDDY_OPT ${BUDDY_BINARY_DIR}/buddy-opt)
set(BUDDY_TRANSLATE ${BUDDY_BINARY_DIR}/buddy-translate)
set(BUDDY_LLC ${BUDDY_BINARY_DIR}/buddy-llc)

set(BUCKYBALL_OPTEST_DIR ${NPU_WORKLOAD_DIR}/buckyball/OpTest)

add_custom_command(
  OUTPUT  bb_mvin-baremetal bb_mvin-linux
  COMMAND ${BUDDY_OPT} ${BUCKYBALL_OPTEST_DIR}/bb_mvin.mlir 
            -lower-buckyball 
            -convert-arith-to-llvm 
            -finalize-memref-to-llvm 
            -reconcile-unrealized-casts | 
          ${BUDDY_TRANSLATE} --buddy-to-llvmir |
          ${BUDDY_LLC} -filetype=obj -mtriple=riscv64
            -mattr=+buddyext,+D -float-abi=hard
            -o log.o
  COMMAND ${ELF_CC} -O2 -static -specs=htif_nano.specs log.o -o bb_mvin-baremetal

  COMMAND ${BUDDY_OPT} ${BUCKYBALL_OPTEST_DIR}/bb_mvin.mlir 
            -lower-buckyball 
            -convert-arith-to-llvm 
            -finalize-memref-to-llvm 
            -reconcile-unrealized-casts |
          ${BUDDY_TRANSLATE} --buddy-to-llvmir |
          ${BUDDY_LLC} -filetype=obj -mtriple=riscv64
            -mattr=+buddyext,+D -float-abi=hard
            -o log.o
  COMMAND ${LINUX_CC} -O2 -static log.o -o bb_mvin-linux
  DEPENDS ${BUCKYBALL_OPTEST_DIR}/bb_mvin.mlir
  COMMENT "Generating bb_mvin"
)

add_custom_command(
  OUTPUT  bb_mvout-baremetal bb_mvout-linux
  COMMAND ${BUDDY_OPT} ${BUCKYBALL_OPTEST_DIR}/bb_mvout.mlir 
            -lower-buckyball 
            -convert-arith-to-llvm 
            -finalize-memref-to-llvm 
            -reconcile-unrealized-casts | 
          ${BUDDY_TRANSLATE} --buddy-to-llvmir |
          ${BUDDY_LLC} -filetype=obj -mtriple=riscv64
            -mattr=+buddyext,+D -float-abi=hard
            -o log.o
  COMMAND ${ELF_CC} -O2 -static -specs=htif_nano.specs log.o -o bb_mvout-baremetal

  COMMAND ${BUDDY_OPT} ${BUCKYBALL_OPTEST_DIR}/bb_mvout.mlir 
            -lower-buckyball 
            -convert-arith-to-llvm 
            -finalize-memref-to-llvm 
            -reconcile-unrealized-casts | 
          ${BUDDY_TRANSLATE} --buddy-to-llvmir |
          ${BUDDY_LLC} -filetype=obj -mtriple=riscv64
            -mattr=+buddyext,+D -float-abi=hard
            -o log.o
  COMMAND ${LINUX_CC} -O2 -static log.o -o bb_mvout-linux
  DEPENDS ${BUCKYBALL_OPTEST_DIR}/bb_mvout.mlir
  COMMENT "Generating bb_mvout"
)

add_custom_command(
  OUTPUT  bb_mul_warp16-baremetal bb_mul_warp16-linux
  COMMAND ${BUDDY_OPT} ${BUCKYBALL_OPTEST_DIR}/bb_mul_warp16.mlir 
            -lower-buckyball 
            -convert-arith-to-llvm 
            -finalize-memref-to-llvm 
            -reconcile-unrealized-casts |
          ${BUDDY_TRANSLATE} --buddy-to-llvmir |
          ${BUDDY_LLC} -filetype=obj -mtriple=riscv64
            -mattr=+buddyext,+D -float-abi=hard
            -o log.o
  COMMAND ${ELF_CC} -O2 -static -specs=htif_nano.specs log.o -o bb_mul_warp16-baremetal

  COMMAND ${BUDDY_OPT} ${BUCKYBALL_OPTEST_DIR}/bb_mul_warp16.mlir 
            -lower-buckyball 
            -convert-arith-to-llvm 
            -finalize-memref-to-llvm 
            -reconcile-unrealized-casts |
          ${BUDDY_TRANSLATE} --buddy-to-llvmir |
          ${BUDDY_LLC} -filetype=obj -mtriple=riscv64
            -mattr=+buddyext,+D -float-abi=hard
            -o log.o
  COMMAND ${LINUX_CC} -O2 -static log.o -o bb_mul_warp16-linux
          DEPENDS ${BUCKYBALL_OPTEST_DIR}/bb_mul_warp16.mlir
  COMMENT "Generating bb_mul_warp16"
)

add_custom_command(
  OUTPUT  bb_mvin_mvout-baremetal bb_mvin_mvout-linux
  COMMAND ${BUDDY_OPT} ${BUCKYBALL_OPTEST_DIR}/bb_mvin_mvout.mlir 
            # -convert-scf-to-cf
            # -llvm-request-c-wrappers
            # -lower-buckyball 
            # -arith-bufferize
            # -buffer-deallocation
            # -finalizing-bufferize
            # -convert-arith-to-llvm
            # -convert-func-to-llvm
            # -finalize-memref-to-llvm
            # -reconcile-unrealized-casts |
            -lower-buckyball |
          ${BUDDY_TRANSLATE} --buddy-to-llvmir |
          ${BUDDY_LLC} -filetype=obj -mtriple=riscv64
            -mattr=+buddyext,+D -float-abi=hard
            -relocation-model=pic
            -o log.o
  COMMAND ${ELF_CC} -O2 -static -specs=htif_nano.specs log.o -o bb_mvin_mvout-baremetal

  COMMAND ${BUDDY_OPT} ${BUCKYBALL_OPTEST_DIR}/bb_mvin_mvout.mlir 
            -lower-buckyball 
            -convert-scf-to-cf
            -convert-arith-to-llvm 
            -finalize-memref-to-llvm 
            -convert-func-to-llvm
            -reconcile-unrealized-casts |
          ${BUDDY_TRANSLATE} --buddy-to-llvmir |
          ${BUDDY_LLC} -filetype=obj -mtriple=riscv64
            -mattr=+buddyext,+D -float-abi=hard
            -o log.o
  COMMAND ${LINUX_CC} -O2 -static log.o -o bb_mvin_mvout-linux
  DEPENDS ${BUCKYBALL_OPTEST_DIR}/bb_mvin_mvout.mlir
  COMMENT "Generating bb_mvin_mvout"
)

add_custom_target(buckyball-OpTest ALL DEPENDS
  bb_mvin-baremetal
  bb_mvin-linux
  bb_mvout-baremetal
  bb_mvout-linux
  bb_mul_warp16-baremetal
  bb_mul_warp16-linux
  bb_mvin_mvout-baremetal
  bb_mvin_mvout-linux
)
