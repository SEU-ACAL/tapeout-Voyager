// See LICENSE.Sifive for license details.
#include <platform.h>
#include <smp.h>
#include "common.h"

// 理论上这段在platform.h中
#define GPIO_BASE_ADDR 0x10010000 // GPIO基地址
#define GPIO_CUSTOM_BOOT_BIT 7 // GPIO7 对应 CUSTOM_BOOT: 0 不跳去 CUSTOM_BOOT(从SD卡), 1 跳去 CUSTOM_BOOT (从DDR或FLASH)
#define GPIO_BOOT_SEL_BIT 8 // GPIO8 对应 BOOT_SEL: 0 跳去 DDR, 1 跳去 FLASH
#define GPIO_LED_BIT 9 // GPIO9 对应 LED

#define FLASH_BASE_ADDR 0x20000000 // FLASH基地址
#define DDR_BASE_ADDR 0x80000000 // DDR基地址

  .section .text.init
  .option norvc
  .globl _prog_start

_prog_start:
/*
smp_pause 作用：让除了主核（一般是hart0）以外的所有核暂停（等待中断），只让主核继续执行。
执行步骤
1. 设置 mie（Machine Interrupt Enable）寄存器，只允许软件中断（0x8）。
2. 判断当前核是不是主核（NONSMP_HART，默认0）。
3. 如果不是主核，直接跳到42标签，执行wfi（Wait For Interrupt），进入低功耗等待状态，直到被唤醒。
4. 只有主核会继续往下执行。
*/
  smp_pause(s1, s2)
  j hello
  
hello:
  li   t0, GPIO_BASE_ADDR   // GPIO 基地址
  li   t1, 1 << GPIO_LED_BIT       // 只设置 GPIO9
  sw   t1, 0(t0)        // 写寄存器，点亮LED
  j custom_boot

custom_boot:
/*
smp_resume 作用：唤醒所有被暂停的核，让它们恢复执行。
执行步骤
1. 主核向所有核的CLINT（Core Local Interruptor）软件中断寄存器写1，触发软件中断。
2. 所有核收到中断后被唤醒，清除自己的软件中断pending位。
3. 等待所有核的软件中断pending位都被清零，确保所有核都已恢复。
*/
  smp_resume(s1, s2)
  csrr a0, mhartid // hartid for next level bootloader
  la a1, dtb // 设备树 address for next level bootloader

  li   t0, GPIO_BASE_ADDR      // t0 = GPIO base address
  lw   t1, 0(t0)               // t1 = GPIO input value

  // 先判断 CUSTOM_BOOT (GPIO7)
  srli t2, t1, GPIO_CUSTOM_BOOT_BIT // t2 = t1 >> 7
  andi t2, t2, 1               // t2 = t2 & 1
  beqz t2, boot_sd             // 如果 t2 == 0，跳去 SD 卡

  // CUSTOM_BOOT == 1，判断 BOOT_SEL (GPIO8)
  srli t2, t1, GPIO_BOOT_SEL_BIT // t2 = t1 >> 8
  andi t2, t2, 1               // t2 = t2 & 1
  beqz t2, boot_ddr            // 如果 t2 == 0，跳去 DDR

  // BOOT_SEL == 1，跳去 FLASH
  li   s1, FLASH_BASE_ADDR
  j    boot_jump

boot_ddr:
  li   s1, DDR_BASE_ADDR
  j    boot_jump

boot_sd:
  li   s1, PAYLOAD_DEST

boot_jump:
  jr   s1

  .section .dtb
  .align 3
dtb:



