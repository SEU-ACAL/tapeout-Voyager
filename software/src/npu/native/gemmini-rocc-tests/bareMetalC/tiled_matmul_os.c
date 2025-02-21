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

#define CHECK_RESULT 1

#define NO_BIAS 1
#define FULL_BIAS_WIDTH 1

#if FULL_BIAS_WIDTH
typedef acc_t ACC_T;
#else
typedef elem_t ACC_T;
#error variable-bitwidth bias not currently supported
#endif

#ifndef BAREMETAL
#define MAT_DIM_I 512
#define MAT_DIM_K 512
#define MAT_DIM_J 512
#else
#define MAT_DIM_I 2048//
#define MAT_DIM_K 2048 // K是共用的
#define MAT_DIM_J 128//
#endif


void print_tile(elem_t* in, int tile_dim) {
  for (size_t r = 0; r < tile_dim; r++) {
    printf("row starts at: %p\n", in +r*MAT_DIM_J);
    for (size_t c = 0; c < tile_dim; c++) {
      printf("%d ", *(in +r*MAT_DIM_J + c));
    }
    printf("\n");
  }
}
void full_matmul(elem_t A[MAT_DIM_I][MAT_DIM_K], elem_t B[MAT_DIM_K][MAT_DIM_J], ACC_T D[MAT_DIM_I][MAT_DIM_J], full_t C_full[MAT_DIM_I][MAT_DIM_J]) {
  for (size_t r = 0; r < MAT_DIM_I; r++)
    for (size_t c = 0; c < MAT_DIM_J; c++) {
      C_full[r][c] = D[r][c];
      for (size_t k = 0; k < MAT_DIM_K; k++)
        C_full[r][c] += A[r][k]*B[k][c];
    }
}

void full_printMatrix(elem_t m[MAT_DIM_I][MAT_DIM_J]) {
  for (size_t i = 0; i < MAT_DIM_I; ++i) {
    for (size_t j = 0; j < MAT_DIM_J; ++j)
      printf("%d ", m[i][j]);
    printf("\n");
  }
}

int full_is_equal(elem_t x[MAT_DIM_I][MAT_DIM_J], elem_t y[MAT_DIM_I][MAT_DIM_J]) {
  for (size_t i = 0; i < MAT_DIM_I; ++i)
    for (size_t j = 0; j < MAT_DIM_J; ++j)
      if (x[i][j] != y[i][j])
        return 0;
  return 1;
}


#define TOTAL_COUNTERS 45

// 定义初始化和打印所有计数器的函数

    // 计数器 ID 列表  
    int counter_ids[TOTAL_COUNTERS] = {
        MAIN_LD_CYCLES,
        MAIN_ST_CYCLES,
        MAIN_EX_CYCLES,
        MAIN_LD_ST_CYCLES,
        MAIN_LD_EX_CYCLES,
        MAIN_ST_EX_CYCLES,
        MAIN_LD_ST_EX_CYCLES,
        LOAD_DMA_WAIT_CYCLE,
        LOAD_ACTIVE_CYCLE,
        LOAD_SCRATCHPAD_WAIT_CYCLE,
        STORE_DMA_WAIT_CYCLE,
        STORE_ACTIVE_CYCLE,
        STORE_POOLING_CYCLE,
        STORE_SCRATCHPAD_WAIT_CYCLE,
        DMA_TLB_MISS_CYCLE,
        DMA_TLB_HIT_REQ,
        DMA_TLB_TOTAL_REQ,
        RDMA_ACTIVE_CYCLE,
        RDMA_TLB_WAIT_CYCLES,
        RDMA_TL_WAIT_CYCLES,
        WDMA_ACTIVE_CYCLE,
        WDMA_TLB_WAIT_CYCLES,
        WDMA_TL_WAIT_CYCLES,
        EXE_ACTIVE_CYCLE,
        EXE_FLUSH_CYCLE,
        EXE_CONTROL_Q_BLOCK_CYCLE,
        EXE_PRELOAD_HAZ_CYCLE,
        EXE_OVERLAP_HAZ_CYCLE,
        SCRATCHPAD_A_WAIT_CYCLE,
        SCRATCHPAD_B_WAIT_CYCLE,
        SCRATCHPAD_D_WAIT_CYCLE,
        ACC_A_WAIT_CYCLE,
        ACC_B_WAIT_CYCLE,
        ACC_D_WAIT_CYCLE,
        A_GARBAGE_CYCLES,
        B_GARBAGE_CYCLES,
        D_GARBAGE_CYCLES,
        IM2COL_MEM_CYCLES,
        IM2COL_ACTIVE_CYCLES,
        IM2COL_TRANSPOSER_WAIT_CYCLE,
        RESERVATION_STATION_FULL_CYCLES,
        RESERVATION_STATION_ACTIVE_CYCLES,
        LOOP_MATMUL_ACTIVE_CYCLES,
        TRANSPOSE_PRELOAD_UNROLLER_ACTIVE_CYCLES,
        RESERVATION_STATION_LD_COUNT,
        RESERVATION_STATION_ST_COUNT,
        RESERVATION_STATION_EX_COUNT,
        RDMA_BYTES_REC,
        WDMA_BYTES_SENT,
        RDMA_TOTAL_LATENCY,
        WDMA_TOTAL_LATENCY
    };

    // 计数器名称列表，和 counter_ids 数组一一对应
    const char *counter_names[TOTAL_COUNTERS] = {
        "MAIN_LD_CYCLES",
        "MAIN_ST_CYCLES",
        "MAIN_EX_CYCLES",
        "MAIN_LD_ST_CYCLES",
        "MAIN_LD_EX_CYCLES",
        "MAIN_ST_EX_CYCLES",
        "MAIN_LD_ST_EX_CYCLES",
        "LOAD_DMA_WAIT_CYCLE",
        "LOAD_ACTIVE_CYCLE",
        "LOAD_SCRATCHPAD_WAIT_CYCLE",
        "STORE_DMA_WAIT_CYCLE",
        "STORE_ACTIVE_CYCLE",
        "STORE_POOLING_CYCLE",
        "STORE_SCRATCHPAD_WAIT_CYCLE",
        "DMA_TLB_MISS_CYCLE",
        "DMA_TLB_HIT_REQ",
        "DMA_TLB_TOTAL_REQ",
        "RDMA_ACTIVE_CYCLE",
        "RDMA_TLB_WAIT_CYCLES",
        "RDMA_TL_WAIT_CYCLES",
        "WDMA_ACTIVE_CYCLE",
        "WDMA_TLB_WAIT_CYCLES",
        "WDMA_TL_WAIT_CYCLES",
        "EXE_ACTIVE_CYCLE",
        "EXE_FLUSH_CYCLE",
        "EXE_CONTROL_Q_BLOCK_CYCLE",
        "EXE_PRELOAD_HAZ_CYCLE",
        "EXE_OVERLAP_HAZ_CYCLE",
        "SCRATCHPAD_A_WAIT_CYCLE",
        "SCRATCHPAD_B_WAIT_CYCLE",
        "SCRATCHPAD_D_WAIT_CYCLE",
        "ACC_A_WAIT_CYCLE",
        "ACC_B_WAIT_CYCLE",
        "ACC_D_WAIT_CYCLE",
        "A_GARBAGE_CYCLES",
        "B_GARBAGE_CYCLES",
        "D_GARBAGE_CYCLES",
        "IM2COL_MEM_CYCLES",
        "IM2COL_ACTIVE_CYCLES",
        "IM2COL_TRANSPOSER_WAIT_CYCLE",
        "RESERVATION_STATION_FULL_CYCLES",
        "RESERVATION_STATION_ACTIVE_CYCLES",
        "LOOP_MATMUL_ACTIVE_CYCLES",
        "TRANSPOSE_PRELOAD_UNROLLER_ACTIVE_CYCLES",
        "RESERVATION_STATION_LD_COUNT",
        "RESERVATION_STATION_ST_COUNT",
        "RESERVATION_STATION_EX_COUNT",
        "RDMA_BYTES_REC",
        "WDMA_BYTES_SENT",
        "RDMA_TOTAL_LATENCY",
        "WDMA_TOTAL_LATENCY"
    };


void initialize_and_print_all_counters() {
    // 配置所有计数器，计数器的 ID 从 0 开始
    for (int i = 0; i < TOTAL_COUNTERS; i++) {
        counter_configure(i, counter_ids[i]);
    }
}




// ===========================================================
//sparse function
// CSR data structure
typedef struct {
    int* values;
    int* col_indices;
    int* row_ptr;
    int rows;
    int cols;
} csr_matrix_t;

// CSC data structure 
typedef struct {
    int* values;
    int* row_indices;
    int* col_ptr;
    int rows;
    int cols;
} csc_matrix_t;

/*
// Function to multiply CSR matrix with dense matrix B
void csr_matmul_dense(const csr_matrix_t* A, const int B[ROW_DIM][COL_DIM], int* C) {
    for (int i = 0; i < A->rows; i++) {
        for (int j = A->row_ptr[i]; j < A->row_ptr[i + 1]; j++) {
            int col_A = A->col_indices[j];
            int val_A = A->values[j];

            // if (val_A != 0) {
                for (int k = 0; k < COL_DIM; k++) {
                    int val_B = B[col_A][k];
                    C[i * COL_DIM + k] += val_A * val_B;
                }
              // } else { continue; }
        }
    }
}


// Function to multiply CSR matrix with CSC matrix
// interaction
void csr_matmul_csc(const csr_matrix_t* A, const csc_matrix_t* B, int* C) {
    // Perform multiplication
    for (int i = 0; i < A->rows; i++) {
        for (int j = A->row_ptr[i]; j < A->row_ptr[i + 1]; j++) {
            int col_A = A->col_indices[j];
            int val_A = A->values[j];

            for (int k = B->col_ptr[col_A]; k < B->col_ptr[col_A + 1]; k++) {
                int row_B = B->row_indices[k];
                int val_B = B->values[k];

                // C[i, row_B] += A[i, col_A] * B[col_A, row_B]
                // if ((val_A != 0) && (val_B != 0)) {
                  C[i * B->cols + row_B] += val_A * val_B;                  
                // } else { continue; }
            }
        }
    }
} */


// ==========================================================
int main() {
#ifndef BAREMETAL
    if (mlockall(MCL_CURRENT | MCL_FUTURE) != 0) {
      perror("mlockall failed");
      exit(1);
    }
#endif

    gemmini_flush(0);

    static elem_t full_A[MAT_DIM_I][MAT_DIM_K] row_align(1);
    static elem_t full_B[MAT_DIM_K][MAT_DIM_J] row_align(1);
    static elem_t full_C[MAT_DIM_I][MAT_DIM_J] row_align(1);
    static ACC_T full_D[MAT_DIM_I][MAT_DIM_J] row_align_acc(1);


// #define RAND rand()
#define RAND 1

    for (size_t i = 0; i < MAT_DIM_I; ++i) {
      for (size_t j = 0; j < MAT_DIM_K; ++j) {
        full_A[i][j] = RAND; //% 2;
      }
    }

    // printf("Init B\n");
    for (size_t i = 0; i < MAT_DIM_K; ++i) {
      for (size_t j = 0; j < MAT_DIM_J; ++j) {
        full_B[i][j] = RAND;// % 2;
      }
    }

    // printf("Init D\n");
    for (size_t i = 0; i < MAT_DIM_I; ++i) {
      for (size_t j = 0; j < MAT_DIM_J; ++j) {
        full_D[i][j] = NO_BIAS ? 0 : RAND; //% 2;
      }
    }




    // print_tile(&full_A[0][0], 64);
    
    // counter_configure(0, LOAD_ACTIVE_CYCLE);
    initialize_and_print_all_counters();

    printf("Starting gemmini matmul\n");
    unsigned long start = read_cycles();

    tiled_matmul_auto(MAT_DIM_I, MAT_DIM_J, MAT_DIM_K,
            (elem_t*)full_A, (elem_t*)full_B, NO_BIAS ? NULL : &full_D[0][0], (elem_t*)full_C,
            MAT_DIM_K, MAT_DIM_J, MAT_DIM_J, MAT_DIM_J,
            MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY,
            NO_ACTIVATION, ACC_SCALE_IDENTITY, 0, false,
            false, false,
            false, false,
            0,
            OS);

    unsigned long end = read_cycles();
    printf("Cycles taken: %u\n", end-start);

    
    // int counter_val = counter_read(0);
    
    
    printf("Printing all counter values:\n");
    for (int i = 0; i < TOTAL_COUNTERS; i++) {
        int counter_val = counter_read(i);
        printf("%s (ID=%d) = %d\n", counter_names[i], counter_ids[i], counter_val);
    }


  exit(0);
}

