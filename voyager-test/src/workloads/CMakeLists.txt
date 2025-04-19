set(CPU_WORKLOAD_DIR ${WORKLOAD_DIR}/cpu)
set(NPU_WORKLOAD_DIR ${WORKLOAD_DIR}/npu)
set(TEMPLATE_WORKLOAD_DIR ${WORKLOAD_DIR}/template)

add_subdirectory(cpu)
add_subdirectory(npu)
add_subdirectory(template)
