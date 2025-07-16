# CoreMark Bare-metal RISC-V

Bare-metal CoreMark performance benchmark with configurable UART baud rate support.

## Features
- Removed syscalls for bare-metal implementation
- Integrated sifive uart library for serial output
- Configurable UART baud rates (9600/115200/38400/57600)
- Support P2E platform

## Project Structure
```
coremark_att/
├── coremark/               # CoreMark source code
│   ├── core_main.c        # Main benchmark logic
│   ├── core_list_join.c   # List operations
│   └── core_matrix.c      # Matrix operations
├── riscv64-baremetal/     # RISC-V bare-metal port
│   ├── include/
│   │   ├── platform.h     # Hardware platform definitions
│   │   ├── uart_config.h  # UART baud rate configuration
│   │   └── devices/uart.h # SiFive UART register definitions
│   ├── syscalls.c         # System calls and UART initialization
│   ├── kprintf.c          # Printf implementation
│   └── Makefile           # Build configuration
└── README.md
```

## Build & Run
```bash

# Build
cd coremark/
make PORT_DIR=../riscv64-baremetal compile

# Convert to big-endian hex for P2E platform backdoor DDR
python3 hex_to_readmemh.py ./coremark/coremark.bare.riscv cm_bigendianv3.hex --big-endian --remap-to-zero

# Clean
make PORT_DIR=../riscv64-baremetal clean
```

## P2E Platform Support
The P2E platform backdoor DDR requires big-endian hex files. 
e.g., Use the conversion script:
- Input: `coremark.bare.riscv` (ELF binary)
- Output: `cm_bigendian.hex` (big-endian hex format)  
- Script: `hex_to_readmemh.py` with `--big-endian --remap-to-zero` flags

## UART Baud Rate Configuration
Modify UART initialization in `riscv64-baremetal/syscalls.c`:

```c
// Default (TX enable only)
REG32(uart, UART_REG_TXCTRL) = UART_TXEN;

// Configure specific baud rate (replace above line)
uart_init_9600();     // 9600 baud
uart_init_115200();   // 115200 baud  
uart_init_38400();    // 38400 baud
uart_init_57600();    // 57600 baud
```

## Technical Specifications
- **Architecture**: RISC-V 64-bit
- **UART Base**: 0x64000000 (SiFive UART)
- **Clock Frequency**: 100MHz (for baud rate calculation)
- **Optimization**: -O2
- **Output**: `coremark.bare.riscv` (~24KB ELF)

## Program Flow
1. Initialize UART with configured baud rate
2. Output startup information
3. Execute CoreMark benchmark
4. Display performance results
5. Enter WFI (Wait For Interrupt)

## Baud Rate Calculation
```
Divisor = Clock_Frequency / Baud_Rate
        = 100,000,000 / Baud_Rate

Examples:
- 115200 baud: divisor = 869
- 9600 baud:   divisor = 10417
- 38400 baud:  divisor = 2604
``` 