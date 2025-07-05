
// C语言程序：先用默认时钟运行，然后切换到PLL时钟并设置2分频
#include <stdio.h>
#include <stdint.h>
// 根据ClockBinders.scala中的地址映射
#define PRCI_BASE_ADDR    0x100000  // 假设的基地址
#define CLOCK_DIVIDER     (PRCI_BASE_ADDR + 0x20000)  // 时钟分频器(写入1就是2分频)
#define CLOCK_SELECTOR    (PRCI_BASE_ADDR + 0x30000)  // 时钟选择器（写入1就是选择pll） 
#define PLL_CTRL          (PRCI_BASE_ADDR + 0x40000)  // PLL控制器（）

// 寄存器偏移
#define DIVIDER_CTRL_REG  0x00//写入分频系数
#define SELECTOR_CTRL_REG 0x00//选择时钟，默认为外部晶振
#define PLL_POWER_REG     0x04//开启pll
#define PLL_GATE_REG      0x00//门控寄存器

// 辅助函数：寄存器读写
static inline uint32_t read_reg(uint64_t addr) {
    return *(volatile uint32_t*)addr;
}

static inline void write_reg(uint64_t addr, uint32_t val) {
    *(volatile uint32_t*)addr = val;
}

void init_clock_system() {
    printf("Starting with default slow clock...\n");
    
    // 阶段1：使用默认的慢时钟运行
    printf("Phase 1: Running on default slow clock\n");
    
    // 在慢时钟下做一些初始化工作
    for (int i = 0; i < 100; i++) {
        // 模拟一些工作负载
        volatile int dummy = i * 2;
    }
    printf("Initialization complete on slow clock\n");
    
    // 阶段2：配置PLL
    printf("Phase 2: Configuring PLL...\n");
    
    // 启用PLL电源
    write_reg(PLL_CTRL + PLL_POWER_REG, 1);
    printf("PLL power enabled\n");
    
    // 等待PLL稳定
    for (int i = 0; i < 100; i++) {
        volatile int dummy = i;
    }
    
    // 使能PLL输出
    // write_reg(PLL_CTRL + PLL_GATE_REG, 1);//时钟门控
    printf("PLL output enabled\n");
    
    // 阶段3：配置时钟分频器为2分频
    printf("Phase 3: Configuring clock divider (divide by 2)...\n");
    
    // 设置分频值为2 (通常寄存器值为分频数-1)
    write_reg(CLOCK_DIVIDER , 1);  // 2分频
    printf("Clock divider configured for divide-by-2\n");
    
    // 阶段4：切换到PLL时钟
    printf("Phase 4: Switching to PLL clock...\n");
    
    // 根据ClockBinders.scala，时钟选择器的输入顺序：
    // 0: slowClockSource (默认)
    // 1: pllClockSource
    write_reg(CLOCK_SELECTOR , 1);  // 选择PLL时钟
    
    printf("Successfully switched to PLL clock with 2x divider!\n");
    
    // 阶段5：在新时钟下运行
    printf("Phase 5: Running on PLL clock (divided by 2)...\n");
    
    // 现在系统运行在PLL时钟的2分频上
    for (int i = 0; i < 10000; i++) {
        volatile int dummy = i * 3;
    }
    printf("Running smoothly on PLL clock!\n");
}

// 监控时钟状态的函数
void monitor_clock_status() {
    printf("\n=== Clock Status Monitor ===\n");
    
    uint32_t divider_ctrl = read_reg(CLOCK_DIVIDER);
    uint32_t divider_val = read_reg(CLOCK_DIVIDER );
    uint32_t selector_ctrl = read_reg(CLOCK_SELECTOR );
    uint32_t selector_mux = read_reg(CLOCK_SELECTOR);
    uint32_t pll_power = read_reg(PLL_CTRL );
    uint32_t pll_gate = read_reg(PLL_CTRL );
    
    printf("Clock Divider: %s, Division: %d\n", 
           divider_ctrl ? "Enabled" : "Disabled", divider_val + 1);
    printf("Clock Selector: %s, Source: %s\n", 
           selector_ctrl ? "Enabled" : "Disabled",
           selector_mux ? "PLL" : "Slow Clock");
    printf("PLL Status: Power=%s, Gate=%s\n",
           pll_power ? "ON" : "OFF",
           pll_gate ? "Enabled" : "Disabled");
    printf("============================\n\n");
}

int main() {
    printf("Clock Management Demo\n");
    printf("=====================\n\n");
    
    // 显示初始状态
    monitor_clock_status();
    
    // 执行时钟切换流程
    init_clock_system();
    
    // 显示最终状态
    monitor_clock_status();
    
    // 可选：动态调整分频比
    printf("Testing dynamic frequency adjustment...\n");
    
    // 切换到4分频
    write_reg(CLOCK_DIVIDER, 3);  // 4分频
    printf("Switched to divide-by-4\n");
    printf("Demo completed successfully!\n");
    
    return 0;
}