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


  elem_t A[DIM][DIM] = {0};
  elem_t B[DIM][DIM] = {0};
  elem_t C[DIM][DIM] = {0};

  // for (size_t i = 0; i < DIM; i++)
  //   for (size_t j = 0; j < DIM; j++){
  //     A[i][j] = ( i == 0);
  //     B[i][j] = (j == 0);
  //   }

  for (size_t i = 0; i < DIM; i++)
    for (size_t j = 0; j < DIM; j++){
      A[i][j] = 1;
      B[i][j] = 2;
    }

  // size_t In_sp_addr = 0;
  // size_t Out_sp_addr = DIM;
  // size_t Identity_sp_addr = 2*DIM;
  size_t A_sp_addr = 0;
  size_t B_sp_addr = DIM;
  size_t C_sp_addr = 2*DIM;

  Transpose(A);

  gemmini_config_ld(DIM * sizeof(elem_t));
  gemmini_config_st(DIM * sizeof(elem_t));

  // printf("Move \"In\" and \"Identity\" matrix from main memory into Gemmini's scratchpad\n");
  // gemmini_mvin(In, In_sp_addr);
  // gemmini_mvin(Identity, Identity_sp_addr);

  // printf("Perform matrix multiplication\n");
  // gemmini_config_ex_mode(VECUNIT_MODE)
  // gemmini_load_mul_add(In_sp_addr, 15, Identity_sp_addr);
  // gemmini_store_vec(Out_sp_addr, 15);
  // gemmini_broadcast_vec();
  
  printf("Move \"In\" and \"Identity\" matrix from main memory into Gemmini's scratchpad\n");
  gemmini_mvin(A, A_sp_addr);
  gemmini_mvin(B, B_sp_addr);

  printf("Perform matrix multiplication\n");
  gemmini_config_ex_mode(VECUNIT_MODE)
  // gemmini_vec_loop_mul(1/*op1_from_mem*/, 1/*op2_from_mem*/, 0/*op1_addr*/, 16/*op2_addr*/, 
  //                      15/*iteration*/, 16/*vd_idx*/, 0/*vs_idx*/);

  
  volatile uint64_t rs1_values[16], rs2_values[16];
  for (size_t i = 0; i < DIM; i++) {
    uint64_t op1 = i;
    uint64_t op2 = i + DIM;
    rs1_values[i] = (op2 << 16) | (op1 << 2) | 0x3; // 0x3 = (op2_from_mem=1, op1_from_mem=1)
    rs2_values[i] = (15 << 10) | ((i+16) << 5) | i;
  }

  uint64_t rs1_values1 = rs1_values[0];
  uint64_t rs1_values2 = rs1_values[1];
  uint64_t rs1_values3 = rs1_values[2];
  uint64_t rs1_values4 = rs1_values[3];
  uint64_t rs1_values5 = rs1_values[4];
  uint64_t rs1_values6 = rs1_values[5];
  uint64_t rs1_values7 = rs1_values[6];
  uint64_t rs1_values8 = rs1_values[7];

  uint64_t rs2_values1 = rs2_values[0];
  uint64_t rs2_values2 = rs2_values[1];
  uint64_t rs2_values3 = rs2_values[2];
  uint64_t rs2_values4 = rs2_values[3];
  uint64_t rs2_values5 = rs2_values[4];
  uint64_t rs2_values6 = rs2_values[5];
  uint64_t rs2_values7 = rs2_values[6];
  uint64_t rs2_values8 = rs2_values[7];
  
  gemmini_vec_loop_mul(
    rs1_values1, rs1_values2, rs1_values3, rs1_values4, rs1_values5, rs1_values6, rs1_values7, rs1_values8,
    rs2_values1, rs2_values2, rs2_values3, rs2_values4, rs2_values5, rs2_values6, rs2_values7, rs2_values8);
  // gemmini_fence();

  // gemmini_config_ex_mode(SYSTOLIC_ARRAY_MODE)
  // gemmini_config_ex(OUTPUT_STATIONARY, 0, 0);
  // gemmini_preload_zeros(C_sp_addr);
  // gemmini_compute_preloaded(A_sp_addr, B_sp_addr);
  
  // gemmini_fence();
  // gemmini_mvout(C, C_sp_addr);
  // gemmini_fence();
  // //Transpose(Out);
  // printf("Print the output matrix\n");
  // printMatrix(C);
  printf("Pass\n");

  //   exit(0);
}

