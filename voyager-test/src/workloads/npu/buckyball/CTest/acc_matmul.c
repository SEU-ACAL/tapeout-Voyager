#include "buckyball.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Test matrices
static elem_t input_matrix[DIM * DIM * 4 ] __attribute__((aligned(64)));
static result_t output_matrix[DIM  * DIM ] __attribute__((aligned(64)));


#define BANK 4096
// Utility function implementations


void init_matrix(elem_t* matrix, int rows, int cols, int seed) {
    for (int i = 0; i < rows * cols; i++) {
        matrix[i] = 1;  
    }
}

void print_matrix(const char* name, result_t* matrix, int rows, int cols) {
	printf("Matrix %s:\n", name);
	for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
					printf("%4d ", matrix[i * cols + j]);
			}
			printf("\n");
	}
	printf("\n");
}


#define OP1_ADDR 0
#define OP2_ADDR (BANK + DIM)
#define WR_ADDR (DIM + 2 * BANK)
int main() {
#ifdef MULTICORE 
    multicore(MULTICORE);  // Only allow specified hart to continue
#endif
    
    // Initialize input matrix
    init_matrix(input_matrix, DIM, DIM * 4, 42);
    
    // Clear output matrix
    memset(output_matrix, 0, sizeof(output_matrix));
    
    //print_matrix("Input", input_matrix, DIM, DIM);
    
    // Move input to scratchpad
    bb_mvin((uintptr_t)output_matrix, WR_ADDR, DIM * 4);
    bb_mvin((uintptr_t)input_matrix, OP1_ADDR, DIM * 4);
    bb_mvin((uintptr_t)input_matrix, OP2_ADDR, DIM * 4);

    
    printf("perform Matmul\n");
    bb_mul_warp16(OP1_ADDR, OP2_ADDR, WR_ADDR, DIM * 4);
    printf("Matmul Done\n");
    

    // Move back from scratchpad to output
    bb_mvout((uintptr_t)output_matrix, WR_ADDR, DIM * 4);
    printf("Finished\n");
   
    // print_matrix("Output", output_matrix, DIM, DIM);

#ifdef MULTICORE 
    exit(0);
#endif
}

