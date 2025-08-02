// See LICENSE.Sifive for license details.
#include <platform.h>
#include <smp.h>
#include "common.h"

// 理论上这段在platform.h中
#define GPIO_BASE_ADDR 0x10010000 // GPIO基地址



#define GPIO_PLL_EN 0
#define GPIO_PLL_DIV 1
#define GPIO_PLL_JUMP 3 // GPIO3 对应 PLL_JUMP: 0 直接跳出初始化, 继续等待初始化
#define GPIO_BOOT_SEL_BIT 4 // GPIO8 对应 BOOT_SEL: 1 跳去 DDR, 0 跳去 FLASH
#define GPIO_CUSTOM_BOOT_BIT 5 // GPIO7 对应 CUSTOM_BOOT: 0 不跳去 CUSTOM_BOOT(从SD卡), 1 跳去 CUSTOM_BOOT (从DDR或FLASH)
#define GPIO_LED_BIT 9 // GPIO9 对应 LED

#define CLOCK_DIV_ADDR 0X120000    // 时钟分频寄存器
#define CLOCK_SEL_ADDR 0X130000    // 时钟选择寄存器
#define CLOCK_PLL_CTRL 0X140000    // PLL 控制


#define FLASH_BASE_ADDR 0x20000000 // FLASH基地址
#define DDR_BASE_ADDR 0x80000000 // DDR基地址

  .section .text.init
  .option norvc
  .globl _prog_start

/*
smp_pause 作用：让除了主核（一般是hart0）以外的所有核暂停（等待中断），只让主核继续执行。
执行步骤
1. 设置 mie（Machine Interrupt Enable）寄存器，只允许软件中断（0x8）。
2. 判断当前核是不是主核（NONSMP_HART，默认0）。
3. 如果不是主核，直接跳到42标签，执行wfi（Wait For Interrupt），进入低功耗等待状态，直到被唤醒。
4. 只有主核会继续往下执行。
*/

/* GPIO
  ie oe = 1 输出
  ie oe = 0 输入
*/

/**
  0-5 输入 
  6-11 输出
**/

/**
gpio5 = 1 gpio4 = 1 ddr 
gpio5 = 1 gpio4 = 0 flash 
gpio5 = 0 gpio4 = 1 sd card 
*/

_prog_start:
  smp_pause(s1, s2)

// 大核心 , 晶振跑
// gpio 初始化，使能输入输出引脚


 gpio_init:
    //GPIO init , 0-5 ie,oe = 1 , 6-11 ie,oe = 0
    li t0,GPIO_BASE_ADDR 
    addi t1,t0, GPIO_OUTPUT_EN
    addi t2,t0, GPIO_INPUT_EN
    li t3 ,0x00
    sw t3, 0(t2) // 
    li t3, 0x1C0
    sw t3, 0(t1) // 
    // 所有gpio 输出0
    addi t4,t0, GPIO_OUTPUT_VAL
    li t5, 0x40  // 点亮gpio6
    sw t5, 0(t4) 

   li t4, 1000
   li t5, 0



custom_boot:
  // 如果 custom_boot == 1 , 则跳过sd卡load ,进入ddr 或者flash
  li t0, GPIO_BASE_ADDR   // 写入gpio基地址       
  lh t1, 0(t0)            // 获取2字节的gpio值
  srli t2, t1, GPIO_CUSTOM_BOOT_BIT  
  andi t2, t2, 0x1
  bnez t2, skip_sd_load // If value != 0x00000001, skip SD loading


/*
pll_init:
  li t2,GPIO_BASE_ADDR
  addi t2,t2, GPIO_OUTPUT_VAL
  li t3, 0xc0
  sw t3, 0(t2) // 点亮gpio6,7


  li t0,CLOCK_PLL_CTRL
  addi t0,t0,4
  li t1, 0x1
  sw t1, 0(t0) // 设置PLL控制寄存器,启用PLL
  addi t0,t0,4


li t3,GPIO_BASE_ADDR
wait_pll_open:
   lb t1, 0(t0)
   andi t1,t1,1
   lh t4, 0(t3)
   srli t5,t4,GPIO_PLL_JUMP
   andi t5,t5,0x1
   bnez t5,sd_load
   beqz t1,wait_pll_open


  li t2,GPIO_BASE_ADDR
  addi t2,t2, GPIO_OUTPUT_VAL
  li t3, 0x1c0
  sw t3, 0(t2) // 点亮gpio6,7,8


pll_sel:
   li t0, GPIO_BASE_ADDR 
   lh t1, 0(t0)        // 读取GPIO值
   srli t2, t1, GPIO_CUSTOM_BOOT_BIT  
   andi t2, t2, 0x1
   li t3, CLOCK_SEL_ADDR
   sb t2, 0(t3)        // 写入时钟选择寄存器

// 延时
   li t4, 1000
   li t5, 0
clock_delay1:
   addi t5, t5, 1
   bne t5, t4, clock_delay1


  li t2,GPIO_BASE_ADDR
  addi t2,t2, GPIO_OUTPUT_VAL
  li t3, 0x3c0
  sw t3, 0(t2) // 点亮gpio6,7,8,9


clock_div:
   lh t1,0(t0)
   // 配置时钟分频
   srli t2, t1, 1      // 右移1位，获取bit 1-2
   andi t2, t2, 0x3    // 只保留这两位
   li t3, CLOCK_DIV_ADDR
   sb t2, 0(t3)        // 写入分频寄存器
   // 再次延迟等待分频设置生效
   li t4, 1000
   li t5, 0
 clock_delay2:
   addi t5, t5, 1
   bne t5, t4, clock_delay2

  li t2,GPIO_BASE_ADDR
  addi t2,t2, GPIO_OUTPUT_VAL
  li t3, 0x7c0
  sw t3, 0(t2) // 点亮gpio6,7,8,9,10
*/

sd_load:
  li t2,GPIO_BASE_ADDR
  addi t2,t2, GPIO_OUTPUT_VAL
  li t3, 0x80
  sw t3, 0(t2) // 点亮gpio7

  li sp, (DDR_BASE_ADDR + 0xffff000)

  // 执行sd_load函数
  call main



// 跳过custom boot 选择 ddr 或者flash 
skip_sd_load:
  nop

  li t2,GPIO_BASE_ADDR
  addi t2,t2, GPIO_OUTPUT_VAL
  li t3, 0x100
  sw t3, 0(t2) // 点亮gpio8
  call delay_500ms


  resume_pause(s1, s2) //判断 BOOT_SEL (GPIO4)
  li t0, GPIO_BASE_ADDR
  lh t1, 0(t0)
  srli t2, t1, GPIO_BOOT_SEL_BIT 
  andi t2, t2, 1               
  bnez t2, boot_ddr            // 如果 boot_sel == 1,跳去 DDR


boot_flash:

  li   s1, NONSMP_HART
  csrr s2, mhartid		
  bne  s1, s2, jump_led1
  
  li t2,GPIO_BASE_ADDR
  addi t2,t2, GPIO_OUTPUT_VAL
  li t3, 0xc0
  sw t3, 0(t2) // 点亮gpio6,7
  call delay_500ms

jump_led1:
  li   s3, FLASH_BASE_ADDR
  j   boot_jump


boot_ddr:

  li   s1, NONSMP_HART
  csrr s2, mhartid		
  bne  s1, s2, jump_led2

  li t2,GPIO_BASE_ADDR
  addi t2,t2, GPIO_OUTPUT_VAL
  li t3, 0x180
  sw t3, 0(t2) // 点亮gpio7,8
  call delay_500ms

jump_led2:

  li   s3, DDR_BASE_ADDR
  j   boot_jump



boot_jump:

  li   s1, NONSMP_HART
  csrr s2, mhartid		
  bne  s1, s2, jump_led3

  li t2,GPIO_BASE_ADDR
  addi t2,t2, GPIO_OUTPUT_VAL
  li t3, 0x1c0
  sw t3, 0(t2) // 点亮gpio6,7,8


jump_led3:
  csrr a0, mhartid // hartid for next level bootloader
  la a1, dtb // dtb address for next level bootloader
  jr   s3


// 延时 ， 在仿真的时候设置小一点
delay_500ms:
   li t0,12500000
   addi t0,t0,-1
   bnez t0,delay_500ms
   ret


  .section .dtb
  .align 3
dtb:



