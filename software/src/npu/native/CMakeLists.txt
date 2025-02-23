project(npu_native C)

set(NATIVE_DIR ${NPU_WORKLOAD_DIR}/native)
# set(GEMMINI_INCLUDE_DIR ${NATIVE_DIR}/gemmini-rocc-tests/include)

# include_directories(
#   ${GEMMINI_INCLUDE_DIR}
#   ${GEMMINI_INCLUDE_DIR}/../../libgemmini
#   ${GEMMINI_INCLUDE_DIR}/../rocc-software
# )

add_custom_target(native-bin
    COMMAND ${CMAKE_MAKE_PROGRAM} -C "${NATIVE_DIR}/libgemmini" install
    COMMAND cd ${NATIVE_DIR}/gemmini-rocc-tests && ./build.sh
    WORKING_DIRECTORY ${NATIVE_DIR}
    COMMENT "Building native components"
    VERBATIM)
# target_include_directories(native-bin PRIVATE ${INTERFACE_DIR} ${INCLUDE_DIR})

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build)

