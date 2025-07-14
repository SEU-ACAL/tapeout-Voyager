#include "buckyball.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Test matrices
static elem_t input_matrixu8[DIM * DIM] __attribute__((aligned(64)));
static result_t input_matrixu32[DIM * DIM] __attribute__((aligned(64)));
static result_t output_matrixu32[DIM  * DIM] __attribute__((aligned(64)));
static elem_t output_matrixu8[DIM  * DIM] __attribute__((aligned(64)));

#define BANK 4096

void init_matrixu8(elem_t* matrix, int rows, int cols, int seed) {
    for (int i = 0; i < rows * cols; i++) {
        matrix[i] = i % 128;  
    }
}
void init_matrixu32(result_t* matrix, int rows, int cols, int seed) {
    for (int i = 0; i < rows * cols; i++) {
        matrix[i] = i % 256;  
    }
}
int compare_matricesu8(elem_t* a, elem_t* b, int rows, int cols) {
   for (int i = 0; i < rows * cols; i++) {
        if (a[i] != b[i]) {
            printf("Mismatch at index %d: expected %d, got %d\n", i, b[i], a[i]);
            //print_matrix("Expected", b, 1, cols);
            //print_matrix("Actual", a, 1, cols);
            return 0;
        }
    }
    return 1;
}
int compare_matrices(result_t* a, result_t* b, int rows, int cols) {
    for (int i = 0; i < rows * cols; i++) {
        if (a[i] != b[i]) {
            printf("Mismatch at index %d: expected %d, got %d\n", i, b[i], a[i]);
            //print_matrix("Expected", b, 1, cols);
            //print_matrix("Actual", a, 1, cols);
            return 0;
        }
    }
    return 1;
}
#define OP1_ADDR 0
#define OP2_ADDR (BANK + DIM)
#define WR_ADDR (DIM + 2 * BANK)
int main() {
#ifdef MULTICORE 
    multicore(MULTICORE);  // Only allow specified hart to continue
#endif
    
    // Initialize input matrix
    init_matrixu32(input_matrixu32, DIM, DIM, 42);
    init_matrixu8(input_matrixu8, DIM, DIM, 42);
    
    // Clear output matrix
    memset(output_matrixu32, 0, sizeof(output_matrixu32));
    
    //print_matrix("Input", input_matrix, DIM, DIM);
    
    // Move input to scratchpad
    bb_mvin((uintptr_t)input_matrixu32, WR_ADDR, DIM * 4);
    bb_mvin((uintptr_t)input_matrixu8, OP1_ADDR, DIM );

    // Move back from scratchpad to output
    bb_mvout((uintptr_t)output_matrixu32, WR_ADDR, DIM * 4);
    printf("Finished ACC Test\n");
    if(compare_matrices(output_matrixu32, input_matrixu32, DIM, DIM)) {
        printf("ACC Test passed: Output matches expected result.\n");
    } else {
        printf("ACC Test failed: Output does not match expected result.\n");
    }

    memset(output_matrixu8, 0, sizeof(output_matrixu8));
    bb_mvout((uintptr_t)output_matrixu8, OP1_ADDR, DIM);
    printf("Finished SRAM Test\n");
    if(compare_matricesu8(output_matrixu8, input_matrixu8, DIM, DIM )) {
        printf("SRAM Test passed: Output matches expected result.\n");
    } else {
        printf("SRAM Test failed: Output does not match expected result.\n");
    }

#ifdef MULTICORE 
   exit(0);
#endif
}
