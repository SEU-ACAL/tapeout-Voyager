#define BOOTADDR_REG 0x1000
#define CLOCK_GPIO_ADDR 0x10010000 // GPIO地址：BIT 0-时钟切换，BIT 1-2分频控制
#define CLOCK_DIV_ADDR 0X120000    // 时钟分频寄存器
#define CLOCK_SEL_ADDR 0X130000    // 时钟选择寄存器
#define CLOCK_PLL_CTRL 0X140000    // PLL 控制
// boot all cores (only hart 0) and jump to main program execution
.section .text.start, "ax", @progbits
.globl _start
_start:
  li a1, 0x2000000 // base address of clint
  csrr a0, mhartid
  bnez a0, boot_core 

# pll_init:
#   //PLL init
#   li t0,CLOCK_PLL_CTRL
#   addi t0,t0,4
#   li t1, 0x1
#   sw t1, 0(t0) // 设置PLL控制寄存器,启用PLL
#   addi t0,t0,4

# wait_pll_open:
#   lb t1, 0(t0)
#   andi t1,t1,1
#   li t2,1
#   bne t2,t1,wait_pll_open

# gpio_init:

#   //GPIO init
#   li t0,CLOCK_GPIO_ADDR
#   addi t0,t0,4
#   li t1, 0x0//使能输入
#   sw t1, 0(t0) 
#   addi t0,t0,4
#   sw t1, 0(t0) // oe=1,ie=1

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

# gpio_unset:
#   li t0,CLOCK_GPIO_ADDR
#   addi t0,t0,4
#   li t1, 0x00000000
#   sw t1, 0(t0)

set_msip:
  addi a2, a1, 4
  li a3, 1
interrupt_loop: // trigger MSIP interrupts for other harts so that they also boot
  sw a3, 0(a2)
  addi a2, a2, 4
  lw a3, -4(a2)
  bnez a3, interrupt_loop
  j boot_core_hart0

// this boot ROM doesn't know about any boot devices, so it just spins,
// waiting for the serial interface to load the program and interrupt it
.section .text.hang, "ax", @progbits
.globl _hang
_hang: // reset vector
  la a0, _start          // on MSIP interrupt, go to _start
  csrw mtvec, a0
  csrr t0, misa          // get MISA mask
  srai t0, t0, 'S' - 'A' // get 'S' supervisor bit
  andi t0, t0, 0x1
  beqz t0, 1f            // only zero mideleg if supported
  csrw mideleg, zero     // no delegation
  li a0, 0x222           // clear spurious seip/stip/ssip left over after reset
  csrc mip, a0
1:
  li a0, 8               // MIE or MSIP bit
  csrw mie, a0           // set only MSIP in MIE CSR
  csrs mstatus, a0       // set MIE in mstatus CSR

wfi_loop: // wait for MSIP interrupt to start program execution
  wfi
  j wfi_loop

// jump to reset vector
.section .text.hang80, "ax", @progbits
.globl _hang80
_hang80:
  j _hang

// other harts must wait until MSIP of hart 0 is cleared to continue
boot_core:
  lw t0, 0(a1)       // load hart 0 MSIP
  bnez t0, boot_core // block until hart 0 clears own MSIP
  sll a0, a0, 2      // offset for hart MSIP
  add a1, a0, a1
boot_core_hart0:      // begin executing code at DRAM_BASE
  sw zero, 0(a1)      // clear the interrupt
  li a0, BOOTADDR_REG // program reset vector
#if __riscv_xlen == 32
  lw a0, 0(a0)        // get boot address from bootaddr_reg SCR
#else
  ld a0, 0(a0)        // get boot address from bootaddr_reg SCR
#endif
  csrw mepc, a0       // return from interrupt to start of user program
  csrr a0, mhartid    // hartid for next level bootloader
  la a1, _dtb         // dtb address for next level bootloader
  li a2, 0x80         // set mstatus MPIE to 0
  csrc mstatus, a2
  mret

.align 3
_dtb:
