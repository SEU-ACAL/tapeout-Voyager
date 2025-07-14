#ifndef __UART_H
#define __UART_H

#include <stdint.h>

// UART base address - adjust according to the specific platform
// Here we use a common address, you need to modify it according to the hardware platform
#ifndef UART_BASE
#define UART_BASE       0x10000000UL
#endif

// 16550 compatible UART register offsets
#define UART_THR        0x00    // Transmit Holding Register
#define UART_RBR        0x00    // Receive Buffer Register
#define UART_IER        0x01    // Interrupt Enable Register
#define UART_FCR        0x02    // FIFO Control Register
#define UART_IIR        0x02    // Interrupt Identification Register
#define UART_LCR        0x03    // Line Control Register
#define UART_MCR        0x04    // Modem Control Register
#define UART_LSR        0x05    // Line Status Register
#define UART_MSR        0x06    // Modem Status Register
#define UART_SCR        0x07    // Scratch Register

// Divisor Latch (when LCR.DLAB=1)
#define UART_DLL        0x00    // Divisor Latch Low
#define UART_DLM        0x01    // Divisor Latch High

// Line Status Register (LSR) bit definitions
#define UART_LSR_DR     0x01    // Data Ready
#define UART_LSR_OE     0x02    // Overrun Error
#define UART_LSR_PE     0x04    // Parity Error
#define UART_LSR_FE     0x08    // Framing Error
#define UART_LSR_BI     0x10    // Break Interrupt
#define UART_LSR_THRE   0x20    // Transmit Holding Register Empty
#define UART_LSR_TEMT   0x40    // Transmitter Empty
#define UART_LSR_FIFOE  0x80    // FIFO Error

// Line Control Register (LCR) bit definitions
#define UART_LCR_WLS0   0x01    // Word Length Select Bit 0
#define UART_LCR_WLS1   0x02    // Word Length Select Bit 1
#define UART_LCR_STB    0x04    // Stop Bit Select (0=1, 1=1.5 or 2)
#define UART_LCR_PEN    0x08    // Parity Enable
#define UART_LCR_EPS    0x10    // Even Parity Select
#define UART_LCR_SP     0x20    // Sticky Parity
#define UART_LCR_BC     0x40    // Interrupt Control
#define UART_LCR_DLAB   0x80    // Divisor Latch Access Bit

// Data bit length definitions
#define UART_LCR_8BIT   (UART_LCR_WLS1 | UART_LCR_WLS0)  // 8 data bits
#define UART_LCR_7BIT   (UART_LCR_WLS1)                  // 7 data bits
#define UART_LCR_6BIT   (UART_LCR_WLS0)                  // 6 data bits
#define UART_LCR_5BIT   (0)                              // 5 data bits

// FIFO Control Register (FCR) bit definitions
#define UART_FCR_FE     0x01    // FIFO Enable
#define UART_FCR_RFR    0x02    // Receive FIFO Reset
#define UART_FCR_TFR    0x04    // Transmit FIFO Reset
#define UART_FCR_DMS    0x08    // DMA Mode Select
#define UART_FCR_RTL0   0x40    // Receive Trigger Level Bit 0
#define UART_FCR_RTL1   0x80    // Receive Trigger Level Bit 1

// Common baud rate division values (assuming clock frequency is 1.8432MHz)
#define UART_BAUD_115200    1
#define UART_BAUD_57600     2
#define UART_BAUD_38400     3
#define UART_BAUD_19200     6
#define UART_BAUD_9600      12

// UART register read/write macro
#define UART_REG(offset)    ((volatile uint8_t*)(UART_BASE + (offset)))
#define uart_read(offset)   (*UART_REG(offset))
#define uart_write(offset, value) (*UART_REG(offset) = (value))

// UART operation function declarations
void uart_init(void);
void uart_putc(char c);
char uart_getc(void);
int uart_puts(const char *s);
int uart_tx_ready(void);
int uart_rx_ready(void);

// Inline function implementation
static inline void uart_wait_tx_ready(void)
{
    // Wait for the transmit holding register to be empty
    while (!(uart_read(UART_LSR) & UART_LSR_THRE)) {
        // Wait for the transmit holding register to be empty
    }
}

static inline void uart_wait_tx_empty(void)
{
    // Wait for the transmitter to be completely empty
    while (!(uart_read(UART_LSR) & UART_LSR_TEMT)) {
        // Busy wait
    }
}

#endif /* __UART_H */ 