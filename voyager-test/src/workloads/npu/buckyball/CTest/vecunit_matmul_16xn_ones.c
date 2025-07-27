#include "buckyball.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static elem_t input_matrix_a[DIM * 1024] __attribute__((aligned(64)));
static elem_t input_matrix_b[DIM* 1024] __attribute__((aligned(64)));
static result_t output_matrix[DIM * DIM] __attribute__((aligned(64)));
static result_t expected_matrix[DIM * DIM] __attribute__((aligned(64)));
static elem_t a_transposed[DIM * 1024] __attribute__((aligned(64)));
#define BANK 512
#define OP1_ADDR 0
#define OP2_ADDR (BANK + DIM)
#define WR_ADDR (DIM + 2 * BANK)

void hw_matmul(const char* test_name, elem_t* a, elem_t* b, result_t* c, int size) {
    transpose_matrix(a, a_transposed, DIM, size);
    bb_mvin((uintptr_t)a_transposed, OP1_ADDR, size);
    bb_mvin((uintptr_t)b, OP2_ADDR, size);
    bb_mvin((uintptr_t)c, WR_ADDR, DIM << 2);
    printf("2\n");
    bb_mul_warp16(OP1_ADDR, OP2_ADDR, WR_ADDR, size);
    printf("2\n");
    bb_mvout((uintptr_t)c, WR_ADDR, DIM << 2);
}

int run_test(const char* test_name, elem_t* a, elem_t* b, int size) {
    hw_matmul(test_name, a, b, output_matrix, size);
}

int test_ones_16x64() {
    init_ones_matrix(input_matrix_a, DIM, 64);
    init_ones_matrix(input_matrix_b, 64, DIM);
    return run_test("All-ones matrices", input_matrix_a, input_matrix_b, 64);
}

int main() {
#ifdef MULTICORE 
    multicore(MULTICORE);
#endif
    int passed = test_ones_16x64();

#ifdef MULTICORE 
    exit(0);
#endif
} 