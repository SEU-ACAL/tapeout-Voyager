// See LICENSE for license details.

#include <stdint.h>
#include <stddef.h>
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#ifndef BAREMETAL
#include <sys/mman.h>
#endif
#include "include/gemmini_testutils.h"

int main() {
#ifndef BAREMETAL
    if (mlockall(MCL_CURRENT | MCL_FUTURE) != 0) {
      perror("mlockall failed");
      exit(1);
    }
#endif

  printf("Flush Gemmini TLB of stale virtual addresses\n");
  gemmini_flush(0);

  printf("Initialize our input and output matrices in main memory\n");
  elem_t In[DIM][DIM] = {0};
  elem_t Out[DIM][DIM] = {0};

  elem_t Identity[DIM][DIM] = {0};
  for (size_t i = 0; i < 1; i++)
    for (size_t j = 0; j < DIM; j++){
      Identity[i][j] = 2;
      In[i][j] = 1;
    }

  printf("Calculate the scratchpad addresses of all our matrices\n");
  printf("  Note: The scratchpad is \"row-addressed\", where each address contains one matrix row\n");
  size_t In_sp_addr = 0;
  size_t Out_sp_addr = DIM;
  size_t Identity_sp_addr = 2*DIM;

  printf("Move \"In\" vec from main memory into Gemmini's scratchpad\n");
  gemmini_config_ld(DIM * sizeof(elem_t));
  gemmini_config_st(DIM * sizeof(elem_t));
  gemmini_mvin(In, In_sp_addr);

  printf("Move \"Identity\" vec from main memory into Gemmini's scratchpad\n");
  gemmini_mvin(Identity, Identity_sp_addr);

 // printf("Multiply \"In\" matrix with \"Identity\" matrix with a bias of 0\n");
  //gemmini_config_ex(OUTPUT_STATIONARY, 0, 0);
  //gemmini_preload_zeros(Out_sp_addr);
  //gemmini_compute_preloaded(In_sp_addr, Identity_sp_addr);

  //VEC MUL UINT
  printf("---------------Perform vector mul Uint--------------------\n");
  gemmini_config_vec_target_addr(Out_sp_addr);
  gemmini_vec_mul_uint(In_sp_addr, 5);

  printf("Move \"Out\" vec from Gemmini's scratchpad into main memory\n");
  gemmini_config_st(DIM * sizeof(elem_t));
  gemmini_mvout(Out, Out_sp_addr);

  printf("Fence till Gemmini completes all memory operations\n");
  gemmini_fence();

  printf("Result Display\n");

  printf("\"In\" Vec:\n");
  printVec(In);
  printf("Uint Value:\n");
  printf("5\n");
  printf("\"Out\" Vec:\n");
  printVec(Out);
  printf("\n");

  //VEC ADD UINT
  printf("----------------Perform vector add Uint--------------------\n");
  gemmini_config_vec_target_addr(Out_sp_addr);
  gemmini_vec_add_uint(In_sp_addr, 5);

  printf("Move \"Out\" vec from Gemmini's scratchpad into main memory\n");
  gemmini_config_st(DIM * sizeof(elem_t));
  gemmini_mvout(Out, Out_sp_addr);

  printf("Fence till Gemmini completes all memory operations\n");
  gemmini_fence();

  printf("Result Display:\n");
  printf("\"In\" Vec:\n");
  printVec(In);
  printf("Uint Value:\n");
  printf("5\n");
  printf("\"Out\" Vec:\n");
  printVec(Out);
  printf("\n");
  
  //VEC ADD VEC
  printf("---------------Perform vector add vector--------------------\n");
  gemmini_config_vec_target_addr(Out_sp_addr);
  gemmini_vec_add_vec(In_sp_addr, Identity_sp_addr);

  printf("Move \"Out\" vec from Gemmini's scratchpad into main memory\n");
  gemmini_config_st(DIM * sizeof(elem_t));
  gemmini_mvout(Out, Out_sp_addr);

  printf("Fence till Gemmini completes all memory operations\n");
  gemmini_fence();

  printf("Result Display:\n");
  printf("\"In\" Vec:\n");
  printVec(In);
  printf("\"Identity\" Vec:\n");
  printVec(Identity);
  printf("\"Out\" Vec:\n");
  printVec(Out);

    exit(0);
}

