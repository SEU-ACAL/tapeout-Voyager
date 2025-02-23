project(npu_buddy C)

# 获取 Chipyard 根目录
execute_process(
    COMMAND git rev-parse --show-toplevel
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE CYDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(CMAKE_C_COMPILER "riscv64-unknown-elf-gcc")  
set(CMAKE_EXE_SUFFIX "-bin")  

add_compile_options(
    -std=c11
    -g
    -fno-common
    -O2
    -static
    -fno-builtin-printf
    -specs=htif_nano.specs
)

add_executable(template
    ${NPU_WORKLOAD_DIR}/buddy/template.c
)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build)
