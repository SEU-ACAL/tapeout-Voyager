.section .text.init
.globl _start
_start:
    # 设置全局指针(gp)
    # .option push
    # .option norelax
    # la gp, __global_pointer$
    # .option pop

    # 设置栈指针
    la sp, __stack_top

    # 清除BSS段
    la t0, __bss_start
    la t1, __bss_end
1:
    beq t0, t1, 2f
    sw zero, 0(t0)
    addi t0, t0, 4
    j 1b
2:
    # 跳转到主函数
    call main

    # 程序结束，进入无限循环
    j . 