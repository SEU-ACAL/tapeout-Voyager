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
#endif

#ifndef BAREMETAL
#define MAT_DIM_I 512
#define MAT_DIM_K 512
#define MAT_DIM_J 512
#else
#define MAT_DIM_I 64
#define MAT_DIM_K 64
#define MAT_DIM_J 64
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

void full_matscale(full_t full[MAT_DIM_I][MAT_DIM_J], elem_t out[MAT_DIM_I][MAT_DIM_J], acc_scale_t scale) {
  for (size_t r = 0; r < MAT_DIM_I; r++)                             
    for (size_t c = 0; c < MAT_DIM_J; c++) {
      // Scale element
      full_t scaled = ACC_SCALE(full[r][c], scale);

      // Saturate and cast element
#ifndef ELEM_T_IS_FLOAT
      full_t elem = scaled > elem_t_max ? elem_t_max : (scaled < elem_t_min ? elem_t_min : scaled);
      out[r][c] = elem;
#else
      out[r][c] = scaled; // TODO should we also saturate when using floats?
#endif
    }
} 

#define TOTAL_COUNTERS 45

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

int main() {
#ifndef BAREMETAL
    if (mlockall(MCL_CURRENT | MCL_FUTURE) != 0) {
      perror("mlockall failed");
      exit(1);
    }
#endif

    printf("MAT_DIM_I: %d\n", MAT_DIM_I);
    printf("MAT_DIM_J: %d\n", MAT_DIM_J);
    printf("MAT_DIM_K: %d\n", MAT_DIM_K);

    gemmini_flush(0);

    static elem_t full_A[MAT_DIM_I][MAT_DIM_K] row_align(1);
    static elem_t full_B[MAT_DIM_K][MAT_DIM_J] row_align(1);
    static elem_t full_C[MAT_DIM_I][MAT_DIM_J] row_align(1);
    static ACC_T full_D[MAT_DIM_I][MAT_DIM_J] row_align_acc(1);

    static full_t gold_full[MAT_DIM_I][MAT_DIM_J];
    static elem_t gold[MAT_DIM_I][MAT_DIM_J];

// #if CHECK_RESULT == 1
// #ifdef FAST
#define RAND 1
// #else
// #define RAND rand()
// #endif
    // printf("Init A\n");
    for (size_t i = 0; i < MAT_DIM_I; ++i) {
      for (size_t j = 0; j < MAT_DIM_K; ++j) {
        full_A[i][j] = RAND % 2;
      }
    }

    // printf("Init B\n");
    for (size_t i = 0; i < MAT_DIM_K; ++i) {
      for (size_t j = 0; j < MAT_DIM_J; ++j) {
        full_B[i][j] = RAND % 2;
      }
    }

    // printf("Init D\n");
    for (size_t i = 0; i < MAT_DIM_I; ++i) {
      for (size_t j = 0; j < MAT_DIM_J; ++j) {
        full_D[i][j] = NO_BIAS ? 0 : RAND % 2;
      }
    }

//     printf("Starting slow CPU matmul\n");
//     unsigned long cpu_start = read_cycles();
// #ifdef FAST
//     for (size_t i = 0; i < MAT_DIM_I; ++i) {
//       for (size_t j = 0; j < MAT_DIM_J; ++j) {
//         gold_full[i][j] = MAT_DIM_K + (NO_BIAS ? 0 : (RAND % 2));
//       }
//     }

// #else
//     full_matmul(full_A, full_B, full_D, gold_full);
// #endif
//     unsigned long cpu_end = read_cycles();
//     printf("Cycles taken: %u\n", cpu_end-cpu_start);
//     full_matscale(gold_full, gold, ACC_SCALE_IDENTITY);
// #endif
    initialize_and_print_all_counters();

    printf("Starting gemmini matmul\n");
    unsigned long start = read_cycles();

    tiled_matmul_auto(MAT_DIM_I, MAT_DIM_J, MAT_DIM_K,
            (elem_t*)full_A, (elem_t*)full_B, NO_BIAS ? NULL : &full_D[0][0], (elem_t*)full_C,
            MAT_DIM_K, MAT_DIM_J, MAT_DIM_J, MAT_DIM_J,
            MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY,
            NO_ACTIVATION, ACC_SCALE_IDENTITY, 0, false,
            false, false,
            false, !FULL_BIAS_WIDTH,
            0,
            WS);

    unsigned long end = read_cycles();
    printf("Cycles taken: %u\n", end-start);

// #if CHECK_RESULT == 1
//     if (!full_is_equal(full_C, gold)) {
//       printf("C:\n");
//       full_printMatrix(full_C);
//       printf("Gold:\n");
//       full_printMatrix(gold);
//       printf("\n");

//       exit(1);
//     }
// #endif

    printf("Printing all counter values:\n");
    for (int i = 0; i < TOTAL_COUNTERS; i++) {
        int counter_val = counter_read(i);
        printf("%s (ID=%d) = %d\n", counter_names[i], counter_ids[i], counter_val);
    }

  exit(0);
}

