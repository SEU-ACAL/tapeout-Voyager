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

 
  gemmini_flush(0);


  elem_t In[DIM][DIM] = {0};
  elem_t Out[DIM][DIM] = {0};

  elem_t Identity[DIM][DIM] = {0};
  for (size_t i = 0; i < DIM; i++)
    for (size_t j = 0; j < DIM; j++){
      In[i][j] = ( i == 0);
      Identity[i][j] = (j == 0);
    }

  size_t In_sp_addr = 0;
  size_t Out_sp_addr = DIM;
  size_t Identity_sp_addr = 2*DIM;

  Transpose(In);

  gemmini_config_ld(DIM * sizeof(elem_t));
  gemmini_config_st(DIM * sizeof(elem_t));

  printf("Move \"In\" and \"Identity\" matrix from main memory into Gemmini's scratchpad\n");
  gemmini_mvin(In, In_sp_addr);
  gemmini_mvin(Identity, Identity_sp_addr);

  printf("Perform matrix multiplication\n");
  gemmini_config_ex_mode(VECUNIT_MODE)
  gemmini_load_mul_add(In_sp_addr, 15, Identity_sp_addr);
  gemmini_store_vec(Out_sp_addr, 15);
  gemmini_broadcast_vec();
  
  printf("Move \"In\" and \"Identity\" matrix from main memory into Gemmini's scratchpad\n");
  gemmini_mvin(In, In_sp_addr);
  gemmini_mvin(Identity, Identity_sp_addr);

  printf("Perform matrix multiplication\n");
  gemmini_config_ex_mode(VECUNIT_MODE)
  gemmini_load_mul_add(In_sp_addr, 15, Identity_sp_addr);
  gemmini_store_vec(Out_sp_addr, 15);
  gemmini_broadcast_vec();
 
/* 废案：没有考虑到访存延迟，导致gemmini_load_mul_add指令无法流水地执行
  for (size_t i = 0; i < DIM; i++){
      gemmini_load_mul_add(Identity_sp_addr , In[i][0]);
      gemmini_load_mul_add(Identity_sp_addr + 1, In[i][1]);
      gemmini_load_mul_add(Identity_sp_addr + 2, In[i][2]);
      gemmini_load_mul_add(Identity_sp_addr + 3, In[i][3]);
      gemmini_load_mul_add(Identity_sp_addr + 4, In[i][4]);
      gemmini_load_mul_add(Identity_sp_addr + 5, In[i][5]);
      gemmini_load_mul_add(Identity_sp_addr + 6, In[i][6]);
      gemmini_load_mul_add(Identity_sp_addr + 7, In[i][7]);
      gemmini_load_mul_add(Identity_sp_addr + 8, In[i][8]);
      gemmini_load_mul_add(Identity_sp_addr + 9, In[i][9]);
      gemmini_load_mul_add(Identity_sp_addr + 10, In[i][10]);
      gemmini_load_mul_add(Identity_sp_addr + 11, In[i][11]);
      gemmini_load_mul_add(Identity_sp_addr + 12, In[i][12]);
      gemmini_load_mul_add(Identity_sp_addr + 13, In[i][13]);
      gemmini_load_mul_add(Identity_sp_addr + 14, In[i][14]);
      gemmini_load_mul_add(Identity_sp_addr + 15, In[i][15]);
    gemmini_store_vec(Out_sp_addr + i);
    gemmini_broadcast_vec();
  }
    */
  printf("Move the output matrix from Gemmini's scratchpad to main memory\n");
  gemmini_fence();
  gemmini_mvout(Out, Out_sp_addr);
  gemmini_fence();
  //Transpose(Out);
  printf("Print the output matrix\n");
  printMatrix(Out);

    exit(0);
}

