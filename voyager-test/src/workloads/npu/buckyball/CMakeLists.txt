project(npu_buckyball CXX)

# add buddy-mlir path
set(BUDDY_MLIR_DIR ${CYDIR}/tools/buddy-mlir)

set(BUCKYBALL_WORKLOAD_DIR ${NPU_WORKLOAD_DIR}/buckyball)

add_custom_target(npu-buckyball ALL DEPENDS
  buckyball-OpTest 
  COMMENT "Building Buckyball Components"
  )

add_subdirectory(OpTest)
