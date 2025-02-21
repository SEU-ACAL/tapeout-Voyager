// See LICENSE for license details.

#include <stdint.h>
#include <stddef.h>
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#ifndef BAREMETAL
#include <sys/mman.h>
#endif
#include <time.h>
#include "include/gemmini_testutils.h"

#ifdef FAST
#define AINIT RELU
#define SINIT 12
#define N 1
#else
#define AINIT NO_ACTIVATION
#define SINIT 0
#define N 2
#endif

// CSR data structure
typedef struct {
    int* values;
    int* col_indices;
    int* row_ptr;
    int rows;
    int cols;
} csr_matrix_t;

// Function to multiply CSR matrix with dense matrix B
void csr_matmul_dense(const csr_matrix_t* A, elem_t B[N][DIM][DIM], elem_t C[N][DIM][DIM]) {
    for (int i = 0; i < A->rows; i++) {
        for (int j = A->row_ptr[i]; j < A->row_ptr[i + 1]; j++) {
            int col = A->col_indices[j];
            int val = A->values[j];
            for (int k = 0; k < DIM; k++) {
                C[i][0][k] += val * B[col][0][k];
            }
        }
    }
}

void operands(int c, int * a, int * b, int * d) {
  *d = c % N;
  *b = (c / N) % N;
  *a = c / (N*N);
}


int one_side_sparse_os();


#if (3*N + N*N*N)*DIM > (BANK_NUM * BANK_ROWS)
#error scratchpad not big enough
#endif

int main() {
#ifndef BAREMETAL
    if (mlockall(MCL_CURRENT | MCL_FUTURE) != 0) {
      perror("mlockall failed");
      exit(1);
    }
#endif

  gemmini_flush(0);
  gemmini_config_ld(DIM * sizeof(elem_t));
  gemmini_config_st(DIM * sizeof(elem_t));

  static elem_t ZERO[DIM][DIM];

  for (int activation = AINIT; activation <= RELU; ++activation) {
    for (int shift = SINIT; shift <= 12; shift += 4) {
      // printf("activation: %d, shift: %d\n", activation, shift);

      static elem_t A[N][DIM][DIM] row_align(1);
      static elem_t B[N][DIM][DIM] row_align(1);
      static elem_t D[N][DIM][DIM] row_align(1);

      // We will try out every combination of A, B, D possible
      static elem_t C[N*N*N][DIM][DIM] row_align(1);
      static full_t gold_full[N*N*N][DIM][DIM];
      static elem_t gold[N*N*N][DIM][DIM];

      // ...taking into account the preloads or accumulates
      static int preload[N*N*N] = {1};
      for (int i = 1; i < N*N*N; ++i)
        preload[i] = rand() % 2;

      // ...and for the actual preloads, do we just preload zeros?
      static int preload_zeros[N*N*N];
      for (int i = 0; i < N*N*N; ++i)
        preload_zeros[i] = rand() % 2;

      // ...and finally, which results won't produce any output
      static int no_output[N*N*N];
      for (int i = 0; i < N*N*N-1; ++i)
        no_output[i] = !preload[i+1];
      no_output[N*N*N-1] = 0;

      printf("Preloads: ");
      for (int i = 0; i < N*N*N; ++i)
        printf("%d, ", preload[i]);
      printf("\n");
      printf("Zeros: ");
      for (int i = 0; i < N*N*N; ++i)
        printf("%d, ", preload_zeros[i]);
      printf("\n");
      printf("No outputs: ");
      for (int i = 0; i < N*N*N; ++i)
        printf("%d, ", no_output[i]);
      printf("\n");
      

      for (size_t n = 0; n < N; ++n) {
        for (size_t i = 0; i < DIM; ++i) {
          for (size_t j = 0; j < DIM; ++j) {
            A[n][i][j] = (rand() % 64) - 32;
            B[n][i][j] = (rand() % 64) - 32;
            D[n][i][j] = (rand() % 64) - 32;
          }
        }
      }

      int A_addr = 0;
      int B_addr = N*DIM;
      int D_addr = 2*N*DIM;
      int C_addr = 3*N*DIM;

      // printf("Moving in\n");
      for (size_t n = 0; n < N; ++n)
        gemmini_mvin(A[n], A_addr + n*DIM);
      
      for (size_t n = 0; n < N; ++n)
        gemmini_mvin(B[n], B_addr + n*DIM);

      for (size_t n = 0; n < N; ++n) {
        gemmini_mvin(D[n], D_addr + n*DIM);
      }

      // printf("Setting mode\n");
      gemmini_config_ex(OUTPUT_STATIONARY, activation, shift);

      for (size_t c = 0; c < N*N*N; ++c) {
        // printf("\tc: %u\n", c);

        int a, b, d;
        operands(c, &a, &b, &d);
        
        uint64_t out_addr = C_addr + c*DIM;
        if (no_output[c])
          out_addr = GARBAGE_ADDR;

        if (!preload[c]) {
          gemmini_preload_zeros(out_addr);
          gemmini_compute_accumulated(A_addr + a*DIM, B_addr + b*DIM);
        } else if (preload_zeros[c]) {
          gemmini_preload_zeros(out_addr);
          gemmini_compute_preloaded(A_addr + a*DIM, B_addr + b*DIM);
        } else {
          gemmini_preload(D_addr + d*DIM, out_addr);
          gemmini_compute_preloaded(A_addr + a*DIM, B_addr + b*DIM);
        }
      }

      // printf("Moving out\n");
      for (size_t c = 0; c < N*N*N; ++c)
        if (!no_output[c]) {
          // printf("\tc: %u\n", c);
          gemmini_mvout(&C[c][0][0], C_addr + c*DIM);
        }

      gemmini_fence();

    }
  }

  exit(0);
}

