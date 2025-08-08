.section .text.init
.globl _start

#define GPIO_BASE_ADDR 0x10010000 // GPIO基地址

#define NONSMP_HART 0
#define GPIO_PLL_EN 0
#define GPIO_PLL_DIV 1
#define GPIO_PLL_JUMP 3 // GPIO3 对应 PLL_JUMP: 1 直接跳出初始化, 0 继续等待初始化
#define GPIO_BOOT_SEL_BIT 4 // GPIO8 对应 BOOT_SEL: 1 跳去 DDR, 0 跳去 FLASH
#define GPIO_CUSTOM_BOOT_BIT 5 // GPIO7 对应 CUSTOM_BOOT: 0 不跳去 CUSTOM_BOOT(从SD卡), 1 跳去 CUSTOM_BOOT (从DDR或FLASH)


#define CLOCK_DIV_ADDR 0X120000    // 时钟分频寄存器
#define CLOCK_SEL_ADDR 0X130000    // 时钟选择寄存器
#define CLOCK_PLL_CTRL 0X140000    // PLL 控制

#define PLL_GATE_REG      0x00//门控寄存器
#define PLL_POWER_REG     0x04//开启pll
#define PLL_LOCK_REG      0x08//锁存寄存器
#define PLL_DIV_REG       0x0c//写入分频系数


_start:

    li   s1, NONSMP_HART
    csrr s2, mhartid		
    bne  s1, s2, jump_ddr

// 主核做
    pll_init:

/*
    li t2,GPIO_BASE_ADDR
    addi t2,t2, GPIO_OUTPUT_VAL
    li t3, 0xc0
    sw t3, 0(t2) // 点亮gpio6,7
*/


    // 启用pll电源
    li t0,CLOCK_PLL_CTRL
    addi t0,t0,PLL_POWER_REG
    li t1, 0x1
    sw t1, 0(t0) // 设置PLL控制寄存器,启用PLL
    addi t0,t0,4


    li t3,GPIO_BASE_ADDR
    li t0,CLOCK_PLL_CTRL
    addi t0,t0,PLL_LOCK_REG
    wait_pll_open:
    lb t1, 0(t0)
    andi t1,t1,1
    lh t4, 0(t3)
    srli t5,t4,GPIO_PLL_JUMP
    andi t5,t5,0x1
    bnez t5,jump_ddr
    beqz t1,wait_pll_open

/*
    li t2,GPIO_BASE_ADDR
    addi t2,t2, GPIO_OUTPUT_VAL
    li t3, 0x1c0
    sw t3, 0(t2) // 点亮gpio6,7,8
*/

    pll_sel:
    li t0, GPIO_BASE_ADDR 
    lh t1, 0(t0)        // 读取GPIO值
    srli t2, t1, GPIO_PLL_EN   
    andi t2, t2, 0x1
    li t3, CLOCK_SEL_ADDR
    sb t2, 0(t3)        // 写入时钟选择寄存器

    // 延时
    li t4, 1000
    li t5, 0
    clock_delay1:
    addi t5, t5, 1
    bne t5, t4, clock_delay1

/*
    li t2,GPIO_BASE_ADDR
    addi t2,t2, GPIO_OUTPUT_VAL
    li t3, 0x3c0
    sw t3, 0(t2) // 点亮gpio6,7,8,9
*/

/*
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
*/



/*
    li t2,GPIO_BASE_ADDR
    addi t2,t2, GPIO_OUTPUT_VAL
    li t3, 0x7c0
    sw t3, 0(t2) // 点亮gpio6,7,8,9,10
*/


jump_ddr:
    // Simple jump to DDR_BASE_ADDR (0x80000000)
    li t0, 0x80000000
    jr t0

// Add some padding to ensure the program is at least 4 bytes
.align 2
nop 