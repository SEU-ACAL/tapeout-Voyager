project(npu_native C)

set(NATIVE_DIR ${NPU_WORKLOAD_DIR}/native)
set(ROCC_TESTS_DIR ${NATIVE_DIR}/gemmini-rocc-tests)
set(ROCC_TESTS_BUILD_DIR ${NATIVE_DIR}/gemmini-rocc-tests/build)
set(OUTPUT_DIRECTORY ${OUTPUT_BIN_DIR}/npu/native)
set(GEMMINI_INCLUDE_DIR ${NATIVE_DIR}/gemmini-rocc-tests/include)

# include_directories(
#   ${GEMMINI_INCLUDE_DIR}
#   ${GEMMINI_INCLUDE_DIR}/../../libgemmini
#   ${GEMMINI_INCLUDE_DIR}/../rocc-software
# )

add_custom_target(gemmini-native
    COMMAND ${CMAKE_MAKE_PROGRAM} -C "${NATIVE_DIR}/libgemmini" install
    COMMAND cd ${ROCC_TESTS_DIR} && ./build.sh
    COMMAND cp -r ${ROCC_TESTS_BUILD_DIR}/bareMetalC ${OUTPUT_DIRECTORY}
    COMMAND cp -r ${ROCC_TESTS_BUILD_DIR}/imagenet ${OUTPUT_DIRECTORY}
    COMMAND cp -r ${ROCC_TESTS_BUILD_DIR}/mlps ${OUTPUT_DIRECTORY}
    COMMAND cp -r ${ROCC_TESTS_BUILD_DIR}/transformers ${OUTPUT_DIRECTORY}
    WORKING_DIRECTORY ${NATIVE_DIR}
    COMMENT "Building Gemmini Native Components"
    VERBATIM)
