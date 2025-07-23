add_library(platform OBJECT
  voyager/uart.c
)

target_include_directories(platform PRIVATE
  ${CMAKE_SOURCE_DIR}/include
  ${CMAKE_SOURCE_DIR}/platform/voyager
) 