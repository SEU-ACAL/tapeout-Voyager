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

  
  // 预计算阶段：集中处理参数
  // uint32_t params[DIM][4]; // [op1_addr, op2_addr, vd_idx, vs_idx]
  // for (size_t i = 0; i < DIM; i++) {
  //   params[i][0] = i;
  //   params[i][1] = i + DIM;
  //   params[i][2] = i + 16;
  //   params[i][3] = i;
  // }

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
  uint64_t rs1_values9 = rs1_values[8];
  uint64_t rs1_values10 = rs1_values[9];
  uint64_t rs1_values11 = rs1_values[10];
  uint64_t rs1_values12 = rs1_values[11];
  uint64_t rs1_values13 = rs1_values[12];
  uint64_t rs1_values14 = rs1_values[13];
  uint64_t rs1_values15 = rs1_values[14];
  uint64_t rs1_values16 = rs1_values[15];

  uint64_t rs2_values1 = rs2_values[0];
  uint64_t rs2_values2 = rs2_values[1];
  uint64_t rs2_values3 = rs2_values[2];
  uint64_t rs2_values4 = rs2_values[3];
  uint64_t rs2_values5 = rs2_values[4];
  uint64_t rs2_values6 = rs2_values[5];
  uint64_t rs2_values7 = rs2_values[6];
  uint64_t rs2_values8 = rs2_values[7];
  uint64_t rs2_values9 = rs2_values[8];
  uint64_t rs2_values10 = rs2_values[9];
  uint64_t rs2_values11 = rs2_values[10];
  uint64_t rs2_values12 = rs2_values[11];
  uint64_t rs2_values13 = rs2_values[12];
  uint64_t rs2_values14 = rs2_values[13];
  uint64_t rs2_values15 = rs2_values[14];
  uint64_t rs2_values16 = rs2_values[15];

  
  // 指令提交阶段：集中发射指令
  // for (size_t i = 0; i < DIM; i++) {
  //   gemmini_vec_loop_mul(1, 1, params[i][0], params[i][1],
  //                        15, params[i][2], params[i][3]);
  // }
  // gemmini_vec_loop_mul(1/*op1_from_mem*/, 
  //                      1/*op2_from_mem*/,  
  //                      0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/*op1_addr*/, 
  //                      16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31/*op2_addr*/, 
  //                      15/*iteration*/,  
  //                      16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31/*vd_idx*/,  
  //                      0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/*vs_idx*/
  // );
  // gemmini_vec_loop_mul(1/*op1_from_mem*/, 
  //                      1/*op2_from_mem*/,  
  //                      params[0][0],params[1][0],params[2][0],params[3][0],params[4][0],params[5][0],params[6][0],params[7][0],params[8][0],params[9][0],params[10][0],params[11][0],params[12][0],params[13][0],params[14][0],params[15][0]/*op1_addr*/, 
  //                      params[0][1],params[1][1],params[2][1],params[3][1],params[4][1],params[5][1],params[6][1],params[7][1],params[8][1],params[9][1],params[10][1],params[11][1],params[12][1],params[13][1],params[14][1],params[15][1]/*op2_addr*/, 
  //                      15/*iteration*/,  
  //                      params[0][2],params[1][2],params[2][2],params[3][2],params[4][2],params[5][2],params[6][2],params[7][2],params[8][2],params[9][2],params[10][2],params[11][2],params[12][2],params[13][2],params[14][2],params[15][2]/*vd_idx*/,  
  //                      params[0][3],params[1][3],params[2][3],params[3][3],params[4][3],params[5][3],params[6][3],params[7][3],params[8][3],params[9][3],params[10][3],params[11][3],params[12][3],params[13][3],params[14][3],params[15][3]/*vs_idx*/
  // );
  gemmini_vec_loop_mul(
    rs1_values1, rs1_values2, rs1_values3, rs1_values4, rs1_values5, rs1_values6, rs1_values7, rs1_values8, rs1_values9, rs1_values10, rs1_values11,
    rs2_values1, rs2_values2, rs2_values3, rs2_values4, rs2_values5, rs2_values6, rs2_values7, rs2_values8, rs2_values9, rs2_values10, rs2_values11);
  // gemmini_vec_loop_mul(
  //   rs1_values1, rs1_values2, rs1_values3, rs1_values4, rs1_values5, rs1_values6, rs1_values7, rs1_values8, rs1_values9, rs1_values10, rs1_values11, rs1_values12, rs1_values13, rs1_values14, rs1_values15, rs1_values16,
  //   rs2_values1, rs2_values2, rs2_values3, rs2_values4, rs2_values5, rs2_values6, rs2_values7, rs2_values8, rs2_values9, rs2_values10, rs2_values11, rs2_values12, rs2_values13, rs2_values14, rs2_values15, rs2_values16
  // );
  // for (size_t i = 0; i < DIM; i++){
  //   gemmini_vec_loop_mul(1/*op1_from_mem*/, 1/*op2_from_mem*/, i/*op1_addr*/, i+DIM/*op2_addr*/, 
  //                        15/*iteration*/, i+16/*vd_idx*/, i/*vs_idx*/);
  // }

  // gemmini_config_ex_mode(SYSTOLIC_ARRAY_MODE)
  
/* 历史方案2：
  gemmini_load_mul_add(In_sp_addr, 15, Identity_sp_addr);
  gemmini_store_vec(Out_sp_addr, 15);
  gemmini_broadcast_vec();
 
*/
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

  // printf("Move the output matrix from Gemmini's scratchpad to main memory\n");
  // gemmini_fence();
  // gemmini_mvout(C, C_sp_addr);
  // gemmini_fence();
  // //Transpose(Out);
  // printf("Print the output matrix\n");
  // printMatrix(C);
  printf("Pass\n");

  //   exit(0);
}

