
set(NPU_WORKLOAD_DIR ${WORKLOAD_DIR}/npu)


add_custom_target(npu-build ALL DEPENDS
    gemmini-buddy 
    gemmini-native
)

add_subdirectory(buddy)
add_subdirectory(native)
