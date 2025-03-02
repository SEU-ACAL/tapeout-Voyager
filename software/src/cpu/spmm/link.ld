OUTPUT_ARCH( "riscv" )
ENTRY( _start )

MEMORY
{
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 128M
}

SECTIONS
{
  .text : {
    PROVIDE(__text_start = .);
    *(.text.init)
    *(.text .text.*)
    PROVIDE(__text_end = .);
  } >RAM

  .rodata : {
    PROVIDE(__rodata_start = .);
    *(.rodata .rodata.*)
    PROVIDE(__rodata_end = .);
  } >RAM

  .data : {
    . = ALIGN(4096);
    PROVIDE(__data_start = .);
    *(.sdata .sdata.*)
    *(.data .data.*)
    PROVIDE(__data_end = .);
  } >RAM

  .bss : {
    PROVIDE(__bss_start = .);
    *(.sbss .sbss.*)
    *(.bss .bss.*)
    *(COMMON)
    . = ALIGN(4);
    PROVIDE(__bss_end = .);
  } >RAM

  .stack : {
    . = ALIGN(16);
    . += 4K;
    PROVIDE(__stack_top = .);
  } >RAM

  PROVIDE(__memory_end = .);
} 