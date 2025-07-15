# A demo for parsecv3 workload.
# TODO: under development
project(parsecv3 C)

set(PARSECV3_DIR ${PARSECV3_WORKLOAD_DIR})
set(PARSECV3_SRC_DIR ${PARSECV3_WORKLOAD_DIR}/parsec-benchmark)

set(PARSECV3_BUILD_DIR ${PARSECV3_DIR}/build)

add_custom_target(parsecv3-build
  COMMAND rm -rf ${PARSECV3_DIR}/build
  COMMAND mkdir -p ${PARSECV3_DIR}/build
  COMMAND yes | ./configure
  COMMAND . ./env.sh  && cd pkgs && ./build_parsec.sh
  COMMAND sh -c "cp -rf pkgs/* ${PARSECV3_DIR}/build/ 2>/dev/null || true"
  COMMAND ${PARSECV3_DIR}/simplify_parsec.sh # Removed the unnecessary files for the workload execution
  COMMAND mkdir -p ${OUTPUT_BIN_DIR}/parsecv3
  # copy all executable files except scripts to the output directory
  COMMAND sh -c "cp -rf ${PARSECV3_DIR}/build/*  ${OUTPUT_BIN_DIR}/parsecv3/ 2>/dev/null || true"
  WORKING_DIRECTORY ${PARSECV3_SRC_DIR}
  COMMENT "Building PARSECv3 Components"
  VERBATIM)