project(template C)

set(CMAKE_C_COMPILER "riscv64-unknown-linux-gnu-gcc")  

#-------------------------------------------------------------------------------
# build linux version workload
#-------------------------------------------------------------------------------
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${WORKLOAD_BIN_DIR}/template)

set(LINK_FLAGS "-static -Wl,--no-dynamic-linker")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LINK_FLAGS}")

add_executable(template-linux ${TEMPLATE_WORKLOAD_DIR}/template.c)

add_custom_target(template-linux-build ALL DEPENDS
    template-linux
    COMMENT "Building linux workloads for template"
    VERBATIM)

#-------------------------------------------------------------------------------
# build baremetal version workload
#-------------------------------------------------------------------------------
set(ELF_CC "riscv64-unknown-elf-gcc")  

set(C_FLAGS -std=c11 -g -fno-common -O2 -static 
            -fno-builtin-printf -specs=htif_nano.specs)

add_custom_target(template-baremetal-build ALL
    COMMAND ${ELF_CC} ${C_FLAGS}
            -o ${WORKLOAD_BIN_DIR}/template/template-baremetal
            ${TEMPLATE_WORKLOAD_DIR}/template.c
    DEPENDS ${TEMPLATE_WORKLOAD_DIR}/template.c
    COMMENT "Building baremetal workloads for template"
    VERBATIM)

#-------------------------------------------------------------------------------
# build all version workload
#-------------------------------------------------------------------------------
add_custom_target(template-build ALL DEPENDS
    template-linux-build
    template-baremetal-build
    VERBATIM)
