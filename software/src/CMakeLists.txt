
execute_process(
    COMMAND git rev-parse --show-toplevel
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE CYDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(WORKLOAD_DIR ${CYDIR}/software/src/)

add_subdirectory(cpu)
add_subdirectory(npu)




add_custom_target(build-all ALL DEPENDS
    cpu-build
    template 
    gemmini-native
)

add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target clean
    COMMAND rm -rf ${CMAKE_SOURCE_DIR}/build
    COMMENT "Cleaning all build artifacts"
)

