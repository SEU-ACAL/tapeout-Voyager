#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

// MyPeripheral 基地址和寄存器定义
#define PERIPHERAL_BASE     0x10050000
#define PERIPHERAL_SIZE     0x1000        // 4KB映射区域
#define CONTROL_OFFSET      0x00
#define STATUS_OFFSET       0x04  
#define DATA0_OFFSET        0x08
#define DATA1_OFFSET        0x0C

// 全局变量
static int mem_fd = -1;
static void* mapped_base = NULL;

// 初始化内存映射
int init_mmap() {
    // 打开/dev/mem设备文件
    mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) {
        printf("Error: Cannot open /dev/mem: %s\n", strerror(errno));
        printf("Note: You may need to run as root (sudo)\n");
        return -1;
    }
    
    // 映射物理地址到虚拟地址
    mapped_base = mmap(NULL, PERIPHERAL_SIZE, PROT_READ | PROT_WRITE, 
                       MAP_SHARED, mem_fd, PERIPHERAL_BASE);
    if (mapped_base == MAP_FAILED) {
        printf("Error: mmap failed: %s\n", strerror(errno));
        close(mem_fd);
        mem_fd = -1;
        return -1;
    }
    
    printf("Memory mapped successfully at %p\n", mapped_base);
    return 0;
}

// 清理内存映射
void cleanup_mmap() {
    if (mapped_base != NULL && mapped_base != MAP_FAILED) {
        munmap(mapped_base, PERIPHERAL_SIZE);
        mapped_base = NULL;
    }
    if (mem_fd >= 0) {
        close(mem_fd);
        mem_fd = -1;
    }
}

// 寄存器读写函数
static inline uint32_t read_reg(uint32_t offset) {
    if (mapped_base == NULL) {
        printf("Error: Memory not mapped\n");
        return 0;
    }
    return *(volatile uint32_t*)((char*)mapped_base + offset);
}

static inline void write_reg(uint32_t offset, uint32_t value) {
    if (mapped_base == NULL) {
        printf("Error: Memory not mapped\n");
        return;
    }
    *(volatile uint32_t*)((char*)mapped_base + offset) = value;
}

// 打印所有寄存器值
void print_regs() {
    printf("Control: 0x%08X\n", read_reg(CONTROL_OFFSET));
    printf("Status:  0x%08X\n", read_reg(STATUS_OFFSET));
    printf("Data0:   0x%08X\n", read_reg(DATA0_OFFSET));
    printf("Data1:   0x%08X\n", read_reg(DATA1_OFFSET));
    printf("\n");
}

int main() {
    // 初始化内存映射
    if (init_mmap() < 0) {
        return -1;
    }
    
    // 读取初始状态
    printf("Initial values:\n");
    print_regs();
    
    // 写入测试数据
    printf("Writing test data...\n");
    printf("Write Control: 0x%08X\n", 0x12345678);
    write_reg(CONTROL_OFFSET, 0x12345678);
    print_regs();

    printf("Write Data0: 0x%08X\n", 0xAABBCCDD);
    write_reg(DATA0_OFFSET, 0xAABBCCDD);
    print_regs();

    printf("Write Data1: 0x%08X\n", 0x11223344);
    write_reg(DATA1_OFFSET, 0x11223344);
    print_regs();
        
    // 测试不同数值
    printf("Testing different values:\n");
    uint32_t test_vals[] = {0x00000000, 0xFFFFFFFF, 0x55AA55AA, 0xDEADBEEF};
    for (int i = 0; i < 4; i++) {
        write_reg(CONTROL_OFFSET, test_vals[i]);
        printf("Control written: 0x%08X, read: 0x%08X\n", 
               test_vals[i], read_reg(CONTROL_OFFSET));
    }
    printf("\n");
    
    // 最终状态
    printf("Final values:\n");
    print_regs();
    
    // 清理资源
    cleanup_mmap();
    return 0;
}
