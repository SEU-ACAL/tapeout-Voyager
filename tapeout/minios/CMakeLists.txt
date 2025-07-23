cmake_minimum_required(VERSION 3.10)

project(miniOS LANGUAGES C ASM)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -nostdlib -fno-builtin -march=rv32imac_zicsr -mabi=ilp32 -g -Wall")
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS}")

set(CMAKE_C_COMPILER riscv64-unknown-elf-gcc)
set(CMAKE_ASM_COMPILER riscv64-unknown-elf-gcc)
set(CMAKE_OBJCOPY riscv64-unknown-elf-objcopy)
set(CMAKE_OBJDUMP riscv64-unknown-elf-objdump)

set(KERNEL_PATH ${CMAKE_SOURCE_DIR}/src/kernel)

add_subdirectory(src/kernel)
add_subdirectory(platform)
add_subdirectory(lib)

add_executable(miniOS.elf
  $<TARGET_OBJECTS:kernel>
  $<TARGET_OBJECTS:platform>
  $<TARGET_OBJECTS:lib>
)

set_target_properties(miniOS.elf PROPERTIES
  LINK_FLAGS "-T${KERNEL_PATH}/minios.ld"
)

add_custom_command(TARGET miniOS.elf POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary miniOS.elf miniOS.bin
  COMMAND ${CMAKE_OBJCOPY} -O ihex miniOS.elf miniOS.hex
  COMMENT "Generate binary and hex file"
)

add_custom_target(flash
  COMMAND openocd -f openocd.cfg -c init -c halt -c "program miniOS.bin" -c exit
  DEPENDS miniOS.elf
  COMMENT "Flashing miniOS.bin to board"
)

add_custom_target(code
  COMMAND ${CMAKE_OBJDUMP} -S miniOS.elf | less
  DEPENDS miniOS.elf
  COMMENT "Disassembling miniOS.elf"
) 
