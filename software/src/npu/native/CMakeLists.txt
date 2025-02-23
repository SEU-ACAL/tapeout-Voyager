project(npu_native C)

set(NATIVE_DIR ${NPU_WORKLOAD_DIR}/native)
# set(GEMMINI_INCLUDE_DIR ${NATIVE_DIR}/gemmini-rocc-tests/include)

# include_directories(
#   ${GEMMINI_INCLUDE_DIR}
#   ${GEMMINI_INCLUDE_DIR}/../../libgemmini
#   ${GEMMINI_INCLUDE_DIR}/../rocc-software
# )
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${WORKLOAD_BIN_DIR}/npu/native)

add_custom_target(gemmini-native
    COMMAND ${CMAKE_MAKE_PROGRAM} -C "${NATIVE_DIR}/libgemmini" install
    COMMAND cd ${NATIVE_DIR}/gemmini-rocc-tests && ./build.sh
    WORKING_DIRECTORY ${NATIVE_DIR}
    COMMENT "Building Gemmini Native Components"
    VERBATIM)
# target_include_directories(native-bin PRIVATE ${INTERFACE_DIR} ${INCLUDE_DIR})


