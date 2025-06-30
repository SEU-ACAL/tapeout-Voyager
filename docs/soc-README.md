## SOC

1. 地址映射

| 地址空间 | 空间大小 | 功能 |
|---------|---------|------|
| `0x00000000 - 0x0000FFFF` | 64KB   | BootROM |
| `0x00010000 - 0x01FFFFFF` | ~32MB  | 系统保留区 |
| `0x02000000 - 0x02000FFF` | 4KB    | CLINT (Core Local Interruptor) |
| `0x08000000 - 0x0800FFFF` | 64KB   | MBus Scratchpad (片上存储) |
| `0x0C000000 - 0x0C3FFFFF` | 4MB    | PLIC (Platform Level Interrupt Controller) |
| `0x10010000 - 0x10010FFF` | 4KB    | GPIO 控制器 |
| `0x10015000 - 0x10015FFF` | 4KB    | Block Device 控制器 |
| `0x10016000 - 0x10016FFF` | 4KB    | IceNIC 网络控制器 |
| `0x10020000 - 0x10020FFF` | 4KB    | UART 串口控制器 |
| `0x10028000 - 0x10028FFF` | 4KB    | 示例设备控制器 |
| `0x10029000 - 0x10029FFF` | 4KB    | 示例AXI4设备控制器 |
| `0x1002A000 - 0x1002DFFF` | 16KB   | 示例寄存器设备组 |
| `0x10030000 - 0x10030FFF` | 4KB    | SPI Flash 控制器 |
| `0x10031000 - 0x10031FFF` | 4KB    | SPI 控制器 |
| `0x10040000 - 0x10040FFF` | 4KB    | I2C 控制器 |
| `0x10050000 - 0x1005003F` | 64B    | myPeripheral 示例外设区间 |
| `0x10050010 - 0x1FFFFFFF` | ~240MB | MMIO外设扩展区域 (预留) |
| `0x20000000 - 0x2FFFFFFF` | 256MB  | SPI Flash XIP区域 |
| `0x40000000 - 0x5FFFFFFF` | 512MB  | PCIe等特殊设备区域 |
| `0x70000000 - 0x77FFFFFF` | 128MB  | TCM (Tightly Coupled Memory) |
| `0x78000000 - 0x7FFFFFFF` | 128MB  | SGTCM (Shared Global TCM) |
| `0x80000000 - 0xFFFFFFFF` | 2GB    | 主内存区域 (DRAM) |
