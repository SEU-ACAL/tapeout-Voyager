add_library(lib OBJECT
  printf.c
)

target_include_directories(lib PUBLIC
  ${CMAKE_SOURCE_DIR}/include
  ${CMAKE_SOURCE_DIR}/platform
) 
