project(coremark C)

set(COREMARK_DIR ${COREMARK_WORKLOAD_DIR}/coremark)
set(COREMARK_BUILD_DIR ${COREMARK_DIR}/build)

add_custom_target(coremark-build
  COMMAND cd ${COREMARK_DIR} && make PORT_DIR=../riscv64-baremetal compile
  COMMAND mkdir -p ${OUTPUT_BIN_DIR}/coremark_att
  COMMAND cp ${COREMARK_DIR}/coremark.bare.riscv ${OUTPUT_BIN_DIR}/coremark_att/coremark-baremetal
  COMMAND rm ${COREMARK_DIR}/coremark.bare.riscv
  COMMENT "Building COREMARK Components"
  VERBATIM)
