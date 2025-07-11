project(embench C)

set(EMBENCH_DIR ${WORKLOAD_DIR}/embench)
set(EMBENCH_BUILD_DIR ${EMBENCH_DIR}/build)

add_custom_target(embench-build
  COMMAND cd ${EMBENCH_DIR} && ./build.sh
  COMMAND cd ${EMBENCH_BUILD_DIR} && cp -r . ${OUTPUT_BIN_DIR}/embench
  WORKING_DIRECTORY ${EMBENCH_DIR}
  COMMENT "Building EMBENCH Components"
  VERBATIM)
