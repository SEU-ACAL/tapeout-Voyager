add_library(kernel OBJECT
  start.S
  kernel.c

  mem/mem.S
  mem/page.c

  test/page_test.c
)

set_source_files_properties(start.S PROPERTIES
  LANGUAGE ASM
)

set_source_files_properties(./mem/mem.S PROPERTIES
  LANGUAGE ASM
)

target_include_directories(kernel PRIVATE
  ${CMAKE_SOURCE_DIR}/include
  ${CMAKE_SOURCE_DIR}/platform
  ${CMAKE_SOURCE_DIR}/lib
) 