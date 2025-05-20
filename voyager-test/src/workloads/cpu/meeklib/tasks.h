#include <stdint.h>
#include <stdio.h>

extern int uart_lock;
extern char* shadow;

int checker (int hart_id);
uint64_t task_synthetic_malloc (uint64_t base);