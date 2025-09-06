#include <stdio.h>
#include <stdlib.h>
#include "perf.h"
int main() {
  perf_start();
  printf("hello world!");
  perf_end();
  return 0;
}