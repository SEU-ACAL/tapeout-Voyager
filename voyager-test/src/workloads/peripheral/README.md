# MyAXI4Device 测试程序

本目录包含用于测试MyAXI4Device外设的C语言程序。

## 📋 文件说明

| 文件 | 描述 |
|------|------|
| `myaxi4_test.c` | 完整的功能测试程序 |
| `simple_example.c` | 简单的使用示例程序 |
| `Makefile` | 编译脚本 |
| `README.md` | 使用说明文档 |

## 🔧 外设寄存器映射

MyAXI4Device外设包含4个32位寄存器：

| 偏移地址 | 寄存器名 | 访问权限 | 功能描述 |
|----------|----------|----------|----------|
| `0x00` | Control | 读写 | 控制寄存器 |
| `0x04` | Status | 只读 | 状态寄存器 (自动递增的计数器) |
| `0x08` | Data0 | 读写 | 数据寄存器0 |
| `0x0C` | Data1 | 读写 | 数据寄存器1 |

**设备基地址**: `0x10050000`

## 🚀 编译和运行

### 1. 编译程序

```bash
# 编译所有程序
make all

# 或者单独编译
make myaxi4_test      # 完整测试程序
make simple_example   # 简单示例程序
```

### 2. 运行测试

```bash
# 运行完整测试 (推荐)
./myaxi4_test

# 运行简单示例
./simple_example
```

### 3. 清理编译文件

```bash
make clean
```

## 📖 程序功能

### myaxi4_test.c - 完整测试程序

这是一个全面的测试程序，包含以下测试：

- ✅ **寄存器读写测试** - 验证Control、Data0、Data1寄存器的读写功能
- ✅ **Status只读测试** - 验证Status寄存器的只读特性
- ✅ **计数器功能测试** - 观察Status寄存器的自动递增
- ✅ **数据完整性测试** - 验证数据读写的正确性
- ✅ **寄存器独立性测试** - 确保各寄存器互不影响

### simple_example.c - 简单示例程序

这是一个简单的使用示例，展示：

- 📖 基本的寄存器读写操作
- 📊 Status寄存器计数器的观察
- ✅ 只读特性的验证
- 📝 基本的编程模式

## 🎯 预期输出

### 成功运行示例

```
===============================================
MyAXI4Device 功能测试程序
设备基地址: 0x10050000
===============================================

>> 初始寄存器状态:
=== MyAXI4Device Register Status ===
Control Register (0x10050000): 0x00000000
Status Register  (0x10050004): 0x00001234
Data0 Register   (0x10050008): 0x00000000
Data1 Register   (0x1005000C): 0x00000000
=====================================

>> 测试寄存器读写功能...
测试Control寄存器 (读写):
  写入: 0x12345678, 读出: 0x12345678 ✓
  ...

🎉 所有测试通过! MyAXI4Device工作正常
===============================================
```

## 🔍 编程要点

### 1. 寄存器访问

```c
// 基地址定义
#define MYAXI4_BASE     0x10050000
#define CONTROL_REG     (MYAXI4_BASE + 0x00)

// 读写函数
uint32_t read32(uint32_t addr) {
    return *(volatile uint32_t*)addr;
}

void write32(uint32_t addr, uint32_t value) {
    *(volatile uint32_t*)addr = value;
}
```

### 2. 使用示例

```c
// 写入控制寄存器
write32(CONTROL_REG, 0x12345678);

// 读取状态寄存器
uint32_t status = read32(STATUS_REG);

// 读取数据寄存器
uint32_t data = read32(DATA0_REG);
```

### 3. 注意事项

- **Status寄存器只读** - 写入操作会被忽略
- **Status寄存器自动递增** - 作为计数器使用
- **地址对齐** - 所有寄存器都是32位对齐
- **volatile关键字** - 确保编译器不会优化掉寄存器访问


## 📚 参考资料

- [MyAXI4Device硬件实现](../generators/peripheral-example/peripheral.scala)
- [IOBinder配置](../generators/chipyard/src/main/scala/iobinders/IOBinders.scala)
- [地址映射文档](../docs/soc-README.md)
