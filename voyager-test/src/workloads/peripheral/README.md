## 外设内存映射

本测试程序用于验证外设内存映射区域的读写功能。

**设备基地址**: `0x10050000`

## 内存映射区域

系统包含以下主要测试区域:

| 地址范围 | 描述 |
|----------|------|
| 0x00000~0x0FFFF | 权重内存大区域 (Weight Memory Large) |
| 0x24A00~0x24A7F | 控制状态寄存器 (CSR) |

**特殊地址**: 地址 0x24A7F (CSR最后地址) 存储特殊值 0x0123456789ABCDEF

## 编译和运行

### 编译程序

```bash
# 编译程序
make peripheral-baremetal
```

### 运行测试

```bash
# 运行内存映射访问测试
./peripheral-baremetal
```

## 程序功能

peripheral-baremetal.c 是一个内存映射访问测试程序，包含：

- 权重内存大区域测试 - 验证Weight Memory Large区域的读写功能
- CSR寄存器测试 - 测试控制状态寄存器的读写功能
- 多地址顺序访问 - 验证连续内存区域的读写操作
- 64位数据访问 - 测试64位数据读写功能

## 运行示例输出

```
===============================================
peripheral memory access test
===============================================

test the weight memory large area (Weight Memory Large):
---------------------------------------------
write the address 0x00000000: 0xABCD1234
address 0x00000000: 0xABCD1234
result: success

test multiple address...
address 0x00000000: write 0xA0000000, read 0xA0000000
address 0x00000004: write 0xA0000001, read 0xA0000001
address 0x00000008: write 0xA0000002, read 0xA0000002
address 0x0000000C: write 0xA0000003, read 0xA0000003
address 0x00000010: write 0xA0000004, read 0xA0000004
---------------------------------------------

CSR:
---------------------------------------------
CSR last register value: 0x0123456789ABCDEF

test csr write and read...
CSR 0x00024A00: write 0xC5000000, read 0xC5000000
CSR 0x00024A04: write 0xC5000001, read 0xC5000001
CSR 0x00024A08: write 0xC5000002, read 0xC5000002
---------------------------------------------

all tests done!
===============================================
```

## 编程参考

### 1. 内存地址定义

```c
// 基地址
#define PERIPHERAL_BASE     0x10050000
// 内存映射
#define WEIGHT_MEM_LARGE_BASE   0x00000     // 20'h00000~20'h0FFFF
#define CSR_BASE                0x24A00     // 20'h24A00~20'h24A7F
#define CSR_LAST_ADDR           0x24A7F     // CSR区域最后地址
```

### 2. 内存访问函数

```c
// 32位读写
static inline uint32_t read32(uint32_t addr) {
    return *(volatile uint32_t*)addr;
}

static inline void write32(uint32_t addr, uint32_t value) {
    *(volatile uint32_t*)addr = value;
}

// 64位读写
static inline uint64_t read64(uint64_t addr) {
    return *(volatile uint64_t*)addr;
}

static inline void write64(uint64_t addr, uint64_t value) {
    *(volatile uint64_t*)addr = value;
}
```

### 3. 访问示例

```c
// 写入测试数据
uint32_t test_addr = WEIGHT_MEM_LARGE_BASE;
uint32_t test_data = 0xABCD1234;
write32(test_addr, test_data);

// 读取并验证
uint32_t read_data = read32(test_addr);
if (read_data == test_data) {
    printf("success");
}

// 读取64位特殊值
uint64_t csr_last_value = read64(CSR_LAST_ADDR);
```

- 所有内存访问使用 volatile 关键字，确保编译器不会优化掉寄存器访问
- 地址对齐 - 所有32位访问应该是4字节对齐
- CSR特殊地址 (0x24A7F) 存储64位预设值
