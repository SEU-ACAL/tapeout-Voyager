project(buckyballCycle)

# Check if RISCV environment variable is set
if(NOT DEFINED ENV{RISCV})
  message(FATAL_ERROR "RISCV is unset")
else()
  message(STATUS "Running with RISCV=$ENV{RISCV}")
endif()

# Set compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -O3")

# Add library directories and rpath
link_directories("$ENV{RISCV}/lib")
set(CMAKE_INSTALL_RPATH "$ENV{RISCV}/lib")
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

# Create shared library
add_library(buckyballCycle SHARED
  buckyball.cc
  buckyball_intrOp.cc
  
  model/buckyball_vecModel.cc
  model/buckyball_matModel.cc
  model/buckyball_memModel.cc

  frame/buckyball_pipeline.cc
  frame/buckyball_sisyphus.cc
)

# Add include directories (modern CMake approach)
target_include_directories(buckyballCycle PRIVATE
  "$ENV{RISCV}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

# Set output name to match Makefile
set_target_properties(buckyballCycle PROPERTIES OUTPUT_NAME "buckyballCycle")

# Install target
install(TARGETS buckyballCycle
  LIBRARY DESTINATION "$ENV{RISCV}/lib"
)
