#ifndef _UART_CONFIG_H
#define _UART_CONFIG_H

/**
 * UART baud rate configuration 
 * 
 * This file provides the baud rate configuration for SiFive UART
 * The original code remains unchanged, these are additional configuration options
 * 
 * Usage:
 * 1. Keep the original initialization code: REG32(uart, UART_REG_TXCTRL) = UART_TXEN;
 * 2. If you need a specific baud rate, you can replace it with the functions provided in this file
 * 
 * Note: Before using, you need to confirm that the system clock frequency is 100MHz
 */

#include <stdint.h>
#include "devices/uart.h"

// UART base address definition (from platform.h)
#define UART_CTRL_ADDR 0x64000000UL

// UART register access macro
#define UART_REG(offset) (*(volatile uint32_t*)(UART_CTRL_ADDR + (offset)))

// SiFive UART baud rate configuration
// Assume the system clock frequency is 100MHz
#define UART_CLOCK_FREQ     100000000UL

// Common baud rate division values
// Division value = clock frequency / baud rate
#define UART_BAUD_115200    (UART_CLOCK_FREQ / 115200)  // 869
#define UART_BAUD_57600     (UART_CLOCK_FREQ / 57600)   // 1736
#define UART_BAUD_38400     (UART_CLOCK_FREQ / 38400)   // 2604
#define UART_BAUD_19200     (UART_CLOCK_FREQ / 19200)   // 5208
#define UART_BAUD_9600      (UART_CLOCK_FREQ / 9600)    // 10417

// Default baud rate
#ifndef DEFAULT_BAUD_RATE
#define DEFAULT_BAUD_RATE   UART_BAUD_115200
#endif

/**
 * Configure UART baud rate
 * @param baud_div baud rate division value
 */
static inline void uart_set_baud_rate(uint32_t baud_div) {
    // Set the division value to UART_REG_DIV register
    UART_REG(UART_REG_DIV) = baud_div;
}

/**
 * Initialize UART and set baud rate
 * @param baud_div baud rate division value
 */
static inline void uart_init_with_baud_rate(uint32_t baud_div) {
    // 1. Set the baud rate
    uart_set_baud_rate(baud_div);
    
    // 2. Enable the transmitter
    UART_REG(UART_REG_TXCTRL) = UART_TXEN;
    
    // 3. Enable the receiver
    UART_REG(UART_REG_RXCTRL) = UART_RXEN;
    
    // 4. Clear the interrupt
    UART_REG(UART_REG_IE) = 0;
}

/**
 * Initialize UART with predefined baud rate
 */
static inline void uart_init_115200(void) {
    uart_init_with_baud_rate(UART_BAUD_115200);
}

static inline void uart_init_57600(void) {
    uart_init_with_baud_rate(UART_BAUD_57600);
}

static inline void uart_init_38400(void) {
    uart_init_with_baud_rate(UART_BAUD_38400);
}

static inline void uart_init_19200(void) {
    uart_init_with_baud_rate(UART_BAUD_19200);
}

static inline void uart_init_9600(void) {
    uart_init_with_baud_rate(UART_BAUD_9600);
}

/**
 * Initialize UART with default baud rate
 */
static inline void uart_init_default(void) {
    uart_init_with_baud_rate(DEFAULT_BAUD_RATE);
}

#endif /* _UART_CONFIG_H */ 