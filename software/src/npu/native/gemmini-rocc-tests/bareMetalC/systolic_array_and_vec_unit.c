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
void Transpose(elem_t matrix[DIM][DIM]){
    elem_t temp[DIM][DIM];
    for(size_t i = 0; i < DIM; i++){
      for(size_t j = 0; j < DIM; j++){
        temp[i][j] = matrix[j][i];
        }
      }
        for(size_t i = 0; i < DIM; i++){
          for(size_t j = 0; j < DIM; j++){
            matrix[i][j] = temp[i][j];
            }
        }
  }
int main() {
#ifndef BAREMETAL
    if (mlockall(MCL_CURRENT | MCL_FUTURE) != 0) {
      perror("mlockall failed");
      exit(1);
    }
#endif
  printf("-------------------SYSTOLIC ARRAY TEST : TEMPLATE-------------------------\n");
  printf("Flush Gemmini TLB of stale virtual addresses\n");
  gemmini_flush(0);

  printf("Initialize our input and output matrices in main memory\n");
  elem_t In[DIM][DIM];
  elem_t Out[DIM][DIM];

  elem_t Identity[DIM][DIM];
  for (size_t i = 0; i < DIM; i++)
    for (size_t j = 0; j < DIM; j++)
      Identity[i][j] = i == j;

  printf("Calculate the scratchpad addresses of all our matrices\n");
  printf("  Note: The scratchpad is \"row-addressed\", where each address contains one matrix row\n");
  size_t In_sp_addr = 0;
  size_t Out_sp_addr = DIM;
  size_t Identity_sp_addr = 2*DIM;

  printf("Move \"In\" matrix from main memory into Gemmini's scratchpad\n");
  gemmini_config_ld(DIM * sizeof(elem_t));
  gemmini_config_st(DIM * sizeof(elem_t));
  gemmini_mvin(In, In_sp_addr);

  printf("Move \"Identity\" matrix from main memory into Gemmini's scratchpad\n");
  gemmini_mvin(Identity, Identity_sp_addr);

  printf("Multiply \"In\" matrix with \"Identity\" matrix with a bias of 0\n");
  gemmini_config_ex_mode(SYSTOLIC_ARRAY);
  gemmini_config_ex(OUTPUT_STATIONARY, 0, 0);
  gemmini_preload_zeros(Out_sp_addr);
  gemmini_compute_preloaded(In_sp_addr, Identity_sp_addr);

  printf("Move \"Out\" matrix from Gemmini's scratchpad into main memory\n");
  gemmini_config_st(DIM * sizeof(elem_t));
  gemmini_mvout(Out, Out_sp_addr);

  printf("Fence till Gemmini completes all memory operations\n");
  gemmini_fence();

  printf("Check whether \"In\" and \"Out\" matrices are identical\n");
  if (!is_equal(In, Out)) {
    printf("Input and output matrices are different!\n");
    printf("\"In\" matrix:\n");
    printMatrix(In);
    printf("\"Out\" matrix:\n");
    printMatrix(Out);
    printf("\n");

    exit(1);
  }

  printf("Input and output matrices are identical, as expected\n");

  printf("-------------------VEC UNIT TEST : MATRIX MUTIPLICATION-------------------------\n");
  for (size_t i = 0; i < DIM; i++)
  for (size_t j = 0; j < DIM; j++){
    In[i][j] = ( j == 0);
    Identity[i][j] = (i == 0);
  }

  Transpose(In);
  gemmini_config_ld(DIM * sizeof(elem_t));
  gemmini_config_st(DIM * sizeof(elem_t));

  printf("Move \"In\" and \"Identity\" matrix from main memory into Gemmini's scratchpad\n");
  gemmini_mvin(In, In_sp_addr);
  gemmini_mvin(Identity, Identity_sp_addr);

  printf("Perform matrix multiplication\n");
  gemmini_config_ex_mode(VEC_UNIT)
  gemmini_load_mul_add(In_sp_addr, 15, Identity_sp_addr);
  gemmini_store_vec(Out_sp_addr, 15);
  gemmini_broadcast_vec();

  printf("Move the output matrix from Gemmini's scratchpad to main memory\n");
  gemmini_fence();
  gemmini_mvout(Out, Out_sp_addr);
  gemmini_fence();

  printf("Print the output matrix\n");
  printMatrix(Out);
  
  exit(0);
}

