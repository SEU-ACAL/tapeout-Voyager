.section .text.init
.globl _start

_start:
    // Simple jump to DDR_BASE_ADDR (0x80000000)
    li t0, 0x80000000
    jr t0

// Add some padding to ensure the program is at least 4 bytes
.align 2
nop 