# A demo for parsecv3 workload.
# TODO: under development
project(parsecv3 C)

set(PARSECV3_DIR ${WORKLOAD_DIR}/parsecv3)
set(PARSECV3_BUILD_DIR ${PARSECV3_DIR}/build)

add_custom_target(parsecv3-build
  # COMMAND cd ${PARSECV3_DIR} && mkdir -p build && cd build 
  # COMMAND config ..
  # COMMAND cmake .. && make
  # COMMAND cd ${PARSECV3_BUILD_DIR} && cp -r . ${OUTPUT_BIN_DIR}/parsecv3
  # WORKING_DIRECTORY ${PARSECV3_DIR}
  # COMMENT "Building PARSECv3 Components"
  VERBATIM)
