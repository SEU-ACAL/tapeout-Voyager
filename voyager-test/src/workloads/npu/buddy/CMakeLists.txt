project(npu_buddy CXX)

# add buddy-mlir path
set(BUDDY_MLIR_DIR ${CYDIR}/tools/buddy-mlir)

set(BUDDY_WORKLOAD_DIR ${NPU_WORKLOAD_DIR}/buddy)

add_subdirectory(${BUDDY_WORKLOAD_DIR}/lenet)

add_custom_target(gemmini-buddy ALL DEPENDS
    buddy-gemmini-lenet-run
)