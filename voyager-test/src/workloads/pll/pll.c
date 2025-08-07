#include <stdio.h>
#include <stdint.h>

// GPIO寄存器定义
#define GPIO_BASE_ADDR 0x10010000 // GPIO基地址
#define GPIO_INPUT_EN  0x4        // 输入使能寄存器偏移
#define GPIO_OUTPUT_EN 0x8        // 输出使能寄存器偏移
#define GPIO_OUTPUT_VAL 0xC       // 输出值寄存器偏移
#define GPIO_INPUT_VAL 0x0        // 输入值寄存器偏移

// 内存映射读写函数
static inline uint32_t read32(uintptr_t addr) {
    return *(volatile uint32_t *)addr;
}

static inline void write32(uintptr_t addr, uint32_t data) {
    *(volatile uint32_t *)addr = data;
}

// 配置GPIO0为输入模式 (ie=0, oe=0)
void gpio0_set_as_input() {
    // 输入使能置1
    write32(GPIO_BASE_ADDR + GPIO_INPUT_EN, 
            read32(GPIO_BASE_ADDR + GPIO_INPUT_EN) | 0x1);
    // 输出使能置0
    write32(GPIO_BASE_ADDR + GPIO_OUTPUT_EN, 
            read32(GPIO_BASE_ADDR + GPIO_OUTPUT_EN) & ~0x1);
    
    printf("GPIO0设置为输入模式\n");
}

// 配置GPIO0为输出模式 (ie=1, oe=1)
void gpio0_set_as_output() {
    // 输入使能置0
    write32(GPIO_BASE_ADDR + GPIO_INPUT_EN, 
            read32(GPIO_BASE_ADDR + GPIO_INPUT_EN) & ~0x1);
    // 输出使能置1
    write32(GPIO_BASE_ADDR + GPIO_OUTPUT_EN, 
            read32(GPIO_BASE_ADDR + GPIO_OUTPUT_EN) | 0x1);
    
    printf("GPIO0设置为输出模式\n");
}

// 向GPIO0写入值
void gpio0_write(int value) {
    if (value)
        write32(GPIO_BASE_ADDR + GPIO_OUTPUT_VAL, 
                read32(GPIO_BASE_ADDR + GPIO_OUTPUT_VAL) | 0x1);
    else
        write32(GPIO_BASE_ADDR + GPIO_OUTPUT_VAL, 
                read32(GPIO_BASE_ADDR + GPIO_OUTPUT_VAL) & ~0x1);
    
    printf("GPIO0输出值设置为: %d\n", value);
}

// 读取GPIO0的值
int gpio0_read() {
    int value = (read32(GPIO_BASE_ADDR + GPIO_INPUT_VAL) & 0x1) ? 1 : 0;
    printf("GPIO0读取值: %d\n", value);
    return value;
}

// 简单延时函数
void delay(int cycles) {
    for (int i = 0; i < cycles; i++) {
        asm volatile("nop");
    }
}

// 打印GPIO0当前配置
void print_gpio0_config() {
    uint32_t input_en = read32(GPIO_BASE_ADDR + GPIO_INPUT_EN) & 0x1;
    uint32_t output_en = read32(GPIO_BASE_ADDR + GPIO_OUTPUT_EN) & 0x1;
    uint32_t output_val = read32(GPIO_BASE_ADDR + GPIO_OUTPUT_VAL) & 0x1;
    uint32_t input_val = read32(GPIO_BASE_ADDR + GPIO_INPUT_VAL) & 0x1;
    
    printf("GPIO0配置状态:\n");
    printf("  输入使能(IE): %d\n", input_en);
    printf("  输出使能(OE): %d\n", output_en);
    printf("  输出值: %d\n", output_val);
    printf("  输入值: %d\n", input_val);
    
    if (input_en && !output_en)
        printf("  当前模式: 输入模式 (ie=1, oe=0)\n");
    else if (!input_en && output_en)
        printf("  当前模式: 输出模式 (ie=0, oe=1)\n");
    else
        printf("  当前模式: 未知模式 (ie=%d, oe=%d)\n", input_en, output_en);
}

int main() {
    printf("===== GPIO0读写测试程序开始 =====\n\n");
    
    // 1. 打印初始状态
    printf("初始状态:\n");
    print_gpio0_config();
    printf("\n");
    
    // 2. 输出模式测试
    printf("测试1: 输出模式测试\n");
    gpio0_set_as_output();
    print_gpio0_config();
    
    // 输出高电平
    printf("\n输出高电平测试:\n");
    gpio0_write(1);
    delay(100);
    print_gpio0_config();
    
    // 输出低电平
    printf("\n输出低电平测试:\n");
    gpio0_write(0);
    delay(100);
    print_gpio0_config();
    
    // 3. 输入模式测试
    printf("\n测试2: 输入模式测试\n");
    gpio0_set_as_input();
    print_gpio0_config();
    
    // 读取输入值
    printf("\n读取输入值:\n");
    gpio0_read();
    delay(100);
    
    // 4. 输入/输出切换测试
    printf("\n测试3: 模式切换测试\n");
    
    // 先设为输出并输出高电平
    printf("设置为输出模式并输出高电平:\n");
    gpio0_set_as_output();
    gpio0_write(1);
    print_gpio0_config();
    delay(100);
    
    // 切换到输入模式读取
    printf("\n切换到输入模式并读取:\n");
    gpio0_set_as_input();
    gpio0_read();
    print_gpio0_config();
    
    printf("\n===== GPIO0读写测试程序结束 =====\n");
    return 0;
}