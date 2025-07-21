// See LICENSE.Sifive for license details.
#include <platform.h>
#include <smp.h>
#include "common.h"
#define CLOCK_GPIO_ADDR 0x10010000 // GPIO地址：BIT 0-时钟切换，BIT 1-2 rw en控制
#define CLOCK_DIV_ADDR 0X120000    // 时钟分频寄存器
#define CLOCK_SEL_ADDR 0X130000    // 时钟选择寄存器
#define CLOCK_PLL_CTRL 0X140000    // PLL 控制

  .section .text.init
  .option norvc
  .globl _prog_start
_prog_start:
  smp_pause(s1, s2)

# pll_init:
#   //PLL init
#   li t0,CLOCK_PLL_CTRL
#   addi t0,t0,4
#   li t1, 0x1
#   sw t1, 0(t0) // 设置PLL控制寄存器,启用PLL
#   addi t0,t0,4

# # wait_pll_open:
# #   lb t1, 0(t0)
# #   andi t1,t1,1
# #   li t2,1
# #   bne t2,t1,wait_pll_open

# gpio_init:

#   //GPIO init
#   li t0,CLOCK_GPIO_ADDR
#   addi t0,t0,4
#   li t1, 0xffffffff//使能输入。
#   sw t1, 0(t0) 

# clock_set:
# //clcok init start
#   // 只有hart 0执行时钟配置
#   // 读取GPIO值并配置时钟
#   li t0, CLOCK_GPIO_ADDR
#   lb t1, 0(t0)        // 读取GPIO值
#   andi t1, t1, 0xf    // 确保只使用低4位
  
#   // 配置时钟切换
#   andi t2, t1, 0x1    // 提取bit 0用于时钟切换
#   li t3, CLOCK_SEL_ADDR
#   sb t2, 0(t3)        // 写入时钟选择寄存器
  
#   // 延迟一段时间等待时钟稳定
#   li t4, 1000
#   li t5, 0
# clock_delay1:
#   addi t5, t5, 1
#   bne t5, t4, clock_delay1
  
#   // 配置时钟分频
#   srli t2, t1, 1      // 右移1位，获取bit 1-2
#   andi t2, t2, 0x3    // 只保留这两位
#   # addi t2, t2, 1      // 确保分频系数至少为1
#   li t3, CLOCK_DIV_ADDR
#   sb t2, 0(t3)        // 写入分频寄存器
  
#   // 再次延迟等待分频设置生效
#   li t4, 1000
#   li t5, 0
# clock_delay2:
#   addi t5, t5, 1
#   bne t5, t4, clock_delay2

#   // clock init finish
#   addi a2, a1, 4
#   li a3, 1
# gpio_unset:
#   li t0,CLOCK_GPIO_ADDR
#   addi t0,t0,4
#   li t1, 0x00000000//使能输入。
#   sw t1, 0(t0)


  li sp, (PAYLOAD_DEST + 0xffff000)
    
  // Check boot address register at 0x1000
  li t0, 0x1000           // Load address 0x1000
  ld t1, 0(t0)            // Load 64-bit value from 0x1000
  li t2, 0x00000001       // Load expected custom boot address
  bne t1, t2, skip_sd_load // If value != 0x00000001, skip SD loading

  // Normal SD card loading path
//  call main
  j continue_boot
  
skip_sd_load:
  // Skip SD card loading, payload should already be at PAYLOAD_DEST
  // For bare metal: ensure clean state for custom boot
  nop
continue_boot:
  smp_resume(s1, s2)
  csrr a0, mhartid // hartid for next level bootloader
  la a1, dtb // dtb address for next level bootloader
  li s1, PAYLOAD_DEST
  jr s1

  .section .dtb
  .align 3
dtb:
