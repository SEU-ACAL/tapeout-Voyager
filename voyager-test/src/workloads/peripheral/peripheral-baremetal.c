#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

// MyPeripheral 基地址和寄存器定义
#define PERIPHERAL_BASE     0x10050000
#define TEST_REG            (PERIPHERAL_BASE + 15*0x08)
#define CONTROL_REG         (PERIPHERAL_BASE + 0x00)
#define STATUS_REG          (PERIPHERAL_BASE + 0x04)  
#define DATA0_REG           (PERIPHERAL_BASE + 0x08)
#define DATA1_REG           (PERIPHERAL_BASE + 0x0C)

// 寄存器读写函数
static inline uint32_t read32(uint32_t addr) {
    return *(volatile uint32_t*)addr;
}

static inline void write32(uint32_t addr, uint32_t value) {
    *(volatile uint32_t*)addr = value;
}

// // 打印所有寄存器值
// void print_regs() {
//     printf("Control: 0x%08X\n", read32(CONTROL_REG));
//     printf("Status:  0x%08X\n", read32(STATUS_REG));
//     printf("Data0:   0x%08X\n", read32(DATA0_REG));
//     printf("Data1:   0x%08X\n", read32(DATA1_REG));
//     printf("\n");
// }

int main() {    
    // 读取初始状态
    printf("Initial values:\n");
    uint64_t test=(*(volatile uint32_t*)CONTROL_REG);
    printf("read data %lx\n",test);
    return 0;
}
