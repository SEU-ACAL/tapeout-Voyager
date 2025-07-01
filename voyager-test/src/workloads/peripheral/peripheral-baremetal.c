#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

// MyPeripheral 基地址和寄存器定义
#define PERIPHERAL_BASE     0x10050000
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

// 打印所有寄存器值
void print_regs() {
    printf("Control: 0x%08X\n", read32(CONTROL_REG));
    printf("Status:  0x%08X\n", read32(STATUS_REG));
    printf("Data0:   0x%08X\n", read32(DATA0_REG));
    printf("Data1:   0x%08X\n", read32(DATA1_REG));
    printf("\n");
}

int main() {    
    // 读取初始状态
    printf("Initial values:\n");
    print_regs();
    
    // 写入测试数据
    printf("Writing test data...\n");
    printf("Write Control: 0x%08X\n", 0x12345678);
    write32(CONTROL_REG, 0x12345678);
    print_regs();

    printf("Write Data0: 0x%08X\n", 0xAABBCCDD);
    write32(DATA0_REG, 0xAABBCCDD);
    print_regs();

    printf("Write Data1: 0x%08X\n", 0x11223344);
    write32(DATA1_REG, 0x11223344);
    print_regs();
    
    // 观察Status计数器变化
    // printf("Status counter (5 readings):\n");
    // for (int i = 0; i < 5; i++) {
    //     printf("Status[%d]: 0x%08X\n", i, read32(STATUS_REG));
    // }
    // printf("\n");
    
    // 测试不同数值
    printf("Testing different values:\n");
    uint32_t test_vals[] = {0x00000000, 0xFFFFFFFF, 0x55AA55AA, 0xDEADBEEF};
    for (int i = 0; i < 4; i++) {
        write32(CONTROL_REG, test_vals[i]);
        printf("Control written: 0x%08X, read: 0x%08X\n", 
               test_vals[i], read32(CONTROL_REG));
    }
    printf("\n");
    
    // 最终状态
    printf("Final values:\n");
    print_regs();
    
    return 0;
}
