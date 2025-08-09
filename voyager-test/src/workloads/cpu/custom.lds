/* 自定义链接脚本 - 将程序加载到 0x20000000 */
OUTPUT_ARCH(riscv)
ENTRY(_start)

SECTIONS
{
    /* 程序加载到 0x20000000 */
    . = 0x20000000;
    
    .text : {
        *(.text)
        *(.text.*)
    }
    
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }
    
    .data : {
        *(.data)
        *(.data.*)
    }
    
    .bss : {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    }
    
    /* 堆栈区域 */
    . = ALIGN(16);
    _end = .;
} 