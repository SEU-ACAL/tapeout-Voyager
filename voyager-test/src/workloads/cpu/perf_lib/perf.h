#include "rocc.h"
static inline void perf_ctrl (uint64_t ctrl_code)
{
  ROCC_INSTRUCTION_S (1,ctrl_code, 0x76);
}


static inline uint64_t perf_read ()
{
  uint64_t perf_val;
  ROCC_INSTRUCTION_D (1, perf_val, 0x77);
  return perf_val;
}
void perf_start();
void perf_end();