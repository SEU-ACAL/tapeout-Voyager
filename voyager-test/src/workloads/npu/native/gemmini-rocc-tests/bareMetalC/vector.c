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
      A[i][j] = 2;
      B[i][j] = (j == 0);
    }

  // size_t In_sp_addr = 0;
  // size_t Out_sp_addr = DIM;
  // size_t Identity_sp_addr = 2*DIM;
  size_t A_sp_addr = 0;
  size_t B_sp_addr = DIM + 4096;
  size_t C_sp_addr = 10*DIM;


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
  gemmini_mvin(A, A_sp_addr + DIM);
  gemmini_mvin(A, A_sp_addr + 2*DIM);
  gemmini_mvin(B, B_sp_addr);
  gemmini_mvin(B, B_sp_addr + DIM);
  gemmini_mvin(B, B_sp_addr + 2*DIM);

  printf("Perform matrix multiplication\n");
  gemmini_config_ex_mode(VECUNIT_MODE)
  // gemmini_vec_loop_mul(1/*op1_from_mem*/, 1/*op2_from_mem*/, 0/*op1_addr*/, 16/*op2_addr*/, 
  //                      15/*iteration*/, 16/*vd_idx*/, 0/*vs_idx*/);

  
  volatile uint64_t rs1_values[16], rs2_values[16];
  uint64_t waddr = DIM * 10;
  uint64_t opnum = 2; //进行 16 x opnum * opnum x 16 的矩阵乘法
  uint64_t mode = 1;
  for (size_t i = 0; i < DIM; i++) {
    uint64_t op1 = i;
    uint64_t op2 = i + DIM;
    rs1_values[i] = (mode << 59)|(opnum << 44)|(waddr << 30)|(op2 << 16) | (op1 << 2) | 0x3; // 0x3 = (op2_from_mem=1, op1_from_mem=1)
    rs2_values[i] = (15 << 10) | ((i+16) << 5) | i;
  }

  uint64_t rs1_values1 = rs1_values[0];

  uint64_t rs2_values1 = rs2_values[0];

  
  ROCC_INSTRUCTION_RS1_RS2(XCUSTOM_ACC,  (uint64_t)rs1_values1, (uint64_t)rs2_values1, k_INST_VEC_LOOP_MUL_16);
  printf("Pass\n");
  /*
  ROCC_INSTRUCTION_RS1_RS2(XCUSTOM_ACC,  (uint64_t)rs1_values1, (uint64_t)rs2_values1, k_INST_VEC_LOOP_MUL_4);
  printf("Pass\n");
  ROCC_INSTRUCTION_RS1_RS2(XCUSTOM_ACC,  (uint64_t)rs1_values1, (uint64_t)rs2_values1, k_INST_VEC_LOOP_MUL_16);
  printf("Pass\n");
  */
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

  //   exit(0);
}

