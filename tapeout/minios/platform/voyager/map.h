#ifndef __MAP_H__
#define __MAP_H__

/*
 * MemoryMap
 * 0x0000 0000 -- FLASH Start, our code runs from here
 * 0x2000 0000 -- FLASH End / SRAM Start
 * 0x2001 0000 -- SRAM End
 * 0x4001 0800 -- Port A
 * 0x4001 3800 -- USART1
 * 0x4002 1000 -- RCC
 */
#define GPIO  0x10010000L
#define UART0 0x64000000L
#define RCC   0x00140000L

#endif /* __MAP_H__ */
