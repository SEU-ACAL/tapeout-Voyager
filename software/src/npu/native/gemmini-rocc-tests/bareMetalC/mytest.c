#include <stdio.h>
// #include <stdint.h>

// // 定义RoCC接口的inline汇编
// #define ROCC_INSTRUCTION_RS1_RS2(x, rs1, rs2, funct) \
//     asm volatile ("custom0 x0, %0, %1, %2" :: "r"(rs1), "r"(rs2), "i"(funct))

// void reset_counter() {
//     uint64_t rs1 = 0x1; // 设置RS1的最低位为1表示重置计数器
//     ROCC_INSTRUCTION_RS1_RS2(0, rs1, 0, 0);
// }

// uint32_t read_counter(int index) {
//     uint64_t rs1 = (index << 4); // 设置index用于选择计数器
//     uint32_t value;
//     ROCC_INSTRUCTION_RS1_RS2(0, rs1, 0, 1); // funct=1表示读取计数值
//     asm volatile ("mv %0, x10" : "=r"(value)); // 读取RoCC返回的值
//     return value;
// }

// int main() {
//     reset_counter();

//     uint32_t count = read_counter(0);
//     printf("Counter 0 Value: %u\n", count);

//     return 0;
// }
int main() {
    printf("hello\n");
    return 0;
}