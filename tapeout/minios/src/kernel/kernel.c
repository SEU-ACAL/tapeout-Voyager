
#include "platform.h"
#include "minilib.h"

#include "include/test.h"

void start_kernel(void) {
  uart_init();
  printf("Hello, miniOS!\n");

  page_test();

  while (1) {}
}