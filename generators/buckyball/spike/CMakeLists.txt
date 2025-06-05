cmake_minimum_required(VERSION 3.16)
project(buckyball)

# Check if RISCV environment variable is set
if(NOT DEFINED ENV{RISCV})
  message(FATAL_ERROR "RISCV is unset")
else()
  message(STATUS "Running with RISCV=$ENV{RISCV}")
endif()

# Set prefix
if(NOT DEFINED PREFIX)
  set(PREFIX "$ENV{RISCV}/")
endif()

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -O3")

# Add library directories and rpath
link_directories("$ENV{RISCV}/lib")
set(CMAKE_INSTALL_RPATH "$ENV{RISCV}/lib")
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

add_subdirectory(cycle-model)
add_subdirectory(func-model)

add_custom_target(buckyballCycle-install
  COMMAND ${CMAKE_COMMAND} --build ${CMAKE_CURRENT_BINARY_DIR}/cycle-model --target install
  DEPENDS cycle-model
  COMMENT "Installing buckyballCycle library to $ENV{RISCV}/lib"
)

add_custom_target(buckyballFunc-install
  COMMAND ${CMAKE_COMMAND} --build ${CMAKE_CURRENT_BINARY_DIR}/func-model --target install
  DEPENDS func-model
  COMMENT "Installing buckyballFunc library to $ENV{RISCV}/lib"
)

add_custom_target(buckyball-install
  DEPENDS buckyballCycle-install
  DEPENDS buckyballFunc-install
  COMMENT "Installing all buckyball components"
)

# Add custom target for clean (CMake handles this automatically, but for compatibility)
add_custom_target(clean-all
  COMMAND ${CMAKE_COMMAND} -E remove *.o *.so
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  COMMENT "Cleaning object and shared library files"
) 