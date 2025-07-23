#include "buckyball.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Test matrices
static elem_t input_matrix_a[DIM * 1024] __attribute__((aligned(64)));
static elem_t input_matrix_b[DIM* 1024] __attribute__((aligned(64)));
static result_t output_matrix[DIM * DIM] __attribute__((aligned(64)));
static result_t expected_matrix[DIM * DIM] __attribute__((aligned(64)));
static elem_t a_transposed[DIM * 1024] __attribute__((aligned(64)));

#define BANK 512
#define OP1_ADDR 0
#define OP2_ADDR (BANK + DIM)
#define WR_ADDR (DIM + 2 * BANK)

int sram_mvin_mvout_pressure_test() {
    for(int i = 0; i < 16; i++){
        init_u8_random_matrix(input_matrix_a, DIM, DIM , i);
        bb_mvin((uintptr_t)input_matrix_a, OP1_ADDR + DIM * i, DIM);
    }
    for(int i = 0; i < 16; i++){
        clear_u8_matrix(input_matrix_b, DIM, DIM);
        bb_mvout((uintptr_t)input_matrix_b, OP1_ADDR + DIM * i, DIM);
        if(!compare_u8_matrices(input_matrix_a, input_matrix_b, DIM, DIM)) {
            printf("Test SRAM mvin/mvout pressure %d FAILED\n", i);
            return 0;
        } else {
            printf("Test SRAM mvin/mvout pressure %d PASSED\n", i);
        }
    }
    return 1;
}

int main() {
#ifdef MULTICORE 
    multicore(MULTICORE);
#endif
    int passed = sram_mvin_mvout_pressure_test();
    if (passed) {
        printf("SRAM mvin/mvout pressure test PASSED\n");
    } else {
        printf("SRAM mvin/mvout pressure test FAILED\n");
    }
#ifdef MULTICORE 
    exit(0);
#endif
} 