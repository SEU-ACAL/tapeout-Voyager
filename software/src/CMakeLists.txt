
execute_process(
    COMMAND git rev-parse --show-toplevel
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE CYDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(WORKLOAD_DIR ${CYDIR}/software/src/)

add_subdirectory(cpu)
add_subdirectory(npu)


