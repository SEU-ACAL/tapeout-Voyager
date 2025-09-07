#include <stdio.h>
#ifdef CHECK 
#include "meek.h"
#endif
int main() {
  #ifdef CHECK 
  rStartup();
  #endif
  printf("hello world!");
  #ifdef CHECK 
  rCleanup();
  #endif
  return 0;
}
