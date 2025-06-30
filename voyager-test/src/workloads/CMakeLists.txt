set(CPU_WORKLOAD_DIR ${WORKLOAD_DIR}/cpu)
set(NPU_WORKLOAD_DIR ${WORKLOAD_DIR}/npu)
set(PERIPHERAL_WORKLOAD_DIR ${WORKLOAD_DIR}/peripheral)
set(TUTORIAL_WORKLOAD_DIR ${WORKLOAD_DIR}/tutorial)

add_subdirectory(cpu)
add_subdirectory(npu)
add_subdirectory(peripheral)
add_subdirectory(tutorial)