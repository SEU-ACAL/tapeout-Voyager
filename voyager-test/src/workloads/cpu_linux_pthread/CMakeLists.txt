project(cpu_linux_pthread C)

set(CPU_LINUX_PTHREAD_DIR ${CPU_LINUX_PTHREAD_WORKLOAD_DIR})
set(CPU_LINUX_PTHREAD_BUILD_DIR ${CPU_LINUX_PTHREAD_WORKLOAD_DIR}/build)

add_custom_target(cpu_linux_pthread-build
  COMMAND rm -rf ${CPU_LINUX_PTHREAD_DIR}/build
  COMMAND mkdir -p ${CPU_LINUX_PTHREAD_DIR}/build
  COMMAND cd ${CPU_LINUX_PTHREAD_DIR} && make clean && make
  COMMAND sh -c "mv *.o ${CPU_LINUX_PTHREAD_DIR}/build 2>/dev/null || true"
  COMMAND mkdir -p ${OUTPUT_BIN_DIR}/cpu_linux_pthread
  COMMAND sh -c "cp -rf ${CPU_LINUX_PTHREAD_DIR}/build/*  ${OUTPUT_BIN_DIR}/cpu_linux_pthread/ 2>/dev/null || true"
  WORKING_DIRECTORY ${CPU_LINUX_PTHREAD_DIR}
  COMMENT "Building CPU_LINUX_PTHREAD Components"
  VERBATIM)