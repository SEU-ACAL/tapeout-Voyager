#include "buckyball.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Test matrices
static elem_t input_matrix[DIM * DIM] __attribute__((aligned(64)));
static elem_t output_matrix[DIM * DIM] __attribute__((aligned(64)));

// Utility function implementations
void print_matrix(const char* name, elem_t* matrix, int rows, int cols) {
    printf("Matrix %s:\n", name);
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%4d ", matrix[i * cols + j]);
        }
        printf("\n");
    }
    printf("\n");
}

void init_matrix(elem_t* matrix, int rows, int cols, int seed) {
    srand(seed);
    for (int i = 0; i < rows * cols; i++) {
        matrix[i] = (elem_t)(rand() % 20 - 10);  // Random values from -10 to 9
    }
}

int compare_matrices(elem_t* a, elem_t* b, int rows, int cols) {
    for (int i = 0; i < rows * cols; i++) {
        if (a[i] != b[i]) {
            return 0;  // Matrices are different
        }
    }
    return 1;  // Matrices are the same
}

int main() {
    printf("Buckyball Test: mvin -> mvout\n");
    printf("==============================\n\n");
    
    // Initialize input matrix
    init_matrix(input_matrix, DIM, DIM, 42);
    
    // Clear output matrix
    memset(output_matrix, 0, sizeof(output_matrix));
    
    printf("Input matrix:\n");
    print_matrix("Input", input_matrix, DIM, DIM);
    
    // Move input to scratchpad
    bb_mvin((uintptr_t)input_matrix, 0, DIM);
    
    // Move back from scratchpad to output
    bb_mvout((uintptr_t)output_matrix, 0, DIM);
    
    printf("Output matrix after mvin->mvout:\n");
    print_matrix("Output", output_matrix, DIM, DIM);
    
    // Verify correctness
    if (compare_matrices(input_matrix, output_matrix, DIM, DIM)) {
        printf("✓ Test PASSED: Matrices match!\n");
        return 0;
    } else {
        printf("✗ Test FAILED: Matrices differ!\n");
        return 1;
    }
}
