project(cpu C)

set(CPU_WORKLOAD_DIR ${WORKLOAD_DIR}/cpu)
set(CMAKE_C_COMPILER "riscv64-unknown-elf-gcc")  

add_compile_options(
    -std=c11
    -g
    -fno-common
    -O2
    -static
    -fno-builtin-printf
    -specs=htif_nano.specs
)

add_executable(hello ${CPU_WORKLOAD_DIR}/hello/hello.c)
add_executable(spmm ${CPU_WORKLOAD_DIR}/spmm/spmm.c)


add_custom_target(cpu-build ALL DEPENDS
    hello
    spmm
    VERBATIM)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build)
