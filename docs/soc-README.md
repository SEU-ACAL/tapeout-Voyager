## SOC

1. 地址映射

| 地址空间 | 空间大小 | 功能 |
|---------|---------|------|
| `0x00000000 - 0x00000FFF` | 4KB    | Debug Controller |
| `0x00001000 - 0x00001FFF` | 4KB    | Boot Address Register |
| `0x00003000 - 0x00003FFF` | 4KB    | Error Device |
| `0x00010000 - 0x0001FFFF` | 64KB   | BootROM  |
| `0x00100000 - 0x00100FFF` | 4KB    | Clock Gater |
| `0x00110000 - 0x00110FFF` | 4KB    | Tile Reset Setter |
| `0x00120000 - 0x00120FFF` | 4KB    | Clock Divider Controller |
| `0x00130000 - 0x00130FFF` | 4KB    | Clock Select Controller |
| `0x00140000 - 0x00140FFF` | 4KB    | PLL |
| `0x02000000 - 0x0200FFFF` | 64KB   | CLINT (Core Local Interruptor) |
| `0x02010000 - 0x02010FFF` | 4KB    | Cache Controller |
| `0x08000000 - 0x08001FFF` | 8KB    | MBus Scratchpad (片上存储) |
| `0x0C000000 - 0x0FFFFFFF` | 64MB   | PLIC (Platform Level Interrupt Controller) |
| `0x10010000 - 0x10010FFF` | 4KB    | GPIO 控制器 |
| `0x10015000 - 0x10015FFF` | 4KB    | Block Device 控制器 |
| `0x10016000 - 0x10016FFF` | 4KB    | IceNIC 网络控制器 |
| `0x10020000 - 0x10020FFF` | 4KB    | UART 串口控制器 (`serial@10020000`) |
| `0x10028000 - 0x10028FFF` | 4KB    | 示例设备控制器 |
| `0x10029000 - 0x10029FFF` | 4KB    | 示例AXI4设备控制器 |
| `0x1002A000 - 0x1002DFFF` | 16KB   | 示例寄存器设备组 |
| `0x10030000 - 0x10030FFF` | 4KB    | SPI Flash 控制器 |
| `0x10031000 - 0x10031FFF` | 4KB    | SPI 控制器 |
| `0x10050000 - 0x10074FFF` | 148KB  | Periphery-NPU |
| `0x10075000 - 0x1FFFFFFF` | ~255MB | MMIO外设扩展区域 (预留) |
| `0x20000000 - 0x2FFFFFFF` | 256MB  | SPI Flash XIP区域 (`spi@10030000` -> FLASH) |
| `0x40000000 - 0x5FFFFFFF` | 512MB  | PCIe等特殊设备区域 |
| `0x64000000 - 0x64000FFF` | 4KB    | Serial Port (`serial@64000000`) |
| `0x64001000 - 0x64001FFF` | 4KB    | Serial Port (`serial@64001000`) |
| `0x64002000 - 0x64002FFF` | 4KB    | Serial Port (`serial@64002000`) |
| `0x64003000 - 0x64003FFF` | 4KB    | Serial Port (`serial@64003000`) |
| `0x64004000 - 0x64004FFF` | 4KB    | SPI SD Card Controller (`spi@64004000`) |
| `0x80000000 - 0xFFFFFFFF` | 2GB    | 主内存区域 (DRAM / DDR) |
