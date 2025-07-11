#include "buckyball.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Test matrices
static elem_t input_matrix_a[DIM * DIM] __attribute__((aligned(64)));
static elem_t input_matrix_b[DIM * DIM] __attribute__((aligned(64)));
static elem_t output_matrix[DIM * DIM] __attribute__((aligned(64)));
static elem_t expected_matrix[DIM * DIM] __attribute__((aligned(64)));

#define BANK 4096
#define OP1_ADDR 0
#define OP2_ADDR (BANK + DIM)
#define WR_ADDR (DIM + 2 * BANK)

// Utility functions
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

void clear_matrix(elem_t* matrix, int rows, int cols) {
    memset(matrix, 0, rows * cols * sizeof(elem_t));
}

void init_ones_matrix(elem_t* matrix, int rows, int cols) {
    for (int i = 0; i < rows * cols; i++) {
        matrix[i] = 1;
    }
}

void init_identity_matrix(elem_t* matrix, int size) {
    clear_matrix(matrix, size, size);
    for (int i = 0; i < size; i++) {
        matrix[i * size + i] = 1;
    }
}

void init_row_vector(elem_t* matrix, int cols, elem_t value) {
    clear_matrix(matrix, DIM, DIM);
    for (int j = 0; j < cols; j++) {
        matrix[j] = value;
    }
}

void init_col_vector(elem_t* matrix, int rows, elem_t value) {
    clear_matrix(matrix, DIM, DIM);
    for (int i = 0; i < rows; i++) {
        matrix[i * DIM] = value;
    }
}

void init_random_matrix(elem_t* matrix, int rows, int cols, int seed) {
    srand(seed);
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            matrix[i * cols + j] = (rand() % 5); // 0-4的随机数
        }
    }
}

// 转置矩阵
void transpose_matrix(elem_t* src, elem_t* dst, int rows, int cols) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            dst[j * rows + i] = src[i * cols + j];
        }
    }
}

// CPU矩阵乘法（用于生成期望结果）
void cpu_matmul(elem_t* a, elem_t* b, elem_t* c, int rows, int cols, int inner) {
    clear_matrix(c, rows, cols);
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            for (int k = 0; k < inner; k++) {
                c[i * cols + j] += a[i * inner + k] * b[k * cols + j];
            }
        }
    }
}

int compare_matrices(elem_t* a, elem_t* b, int rows, int cols) {
    for (int i = 0; i < rows * cols; i++) {
        if (a[i] != b[i]) {
            printf("Mismatch at index %d: expected %d, got %d\n", i, b[i], a[i]);
            return 0;
        }
    }
    return 1;
}

// 执行硬件矩阵乘法
void hw_matmul(const char* test_name, elem_t* a, elem_t* b, elem_t* c, int size) {
    // 转置左矩阵
    static elem_t a_transposed[DIM * DIM] __attribute__((aligned(64)));
    transpose_matrix(a, a_transposed, size, size);
    
    // Move matrices to scratchpad
    bb_mvin((uintptr_t)a_transposed, OP1_ADDR, size);
    bb_mvin((uintptr_t)b, OP2_ADDR, size);

    printf("Perform test: %s\n ", test_name);
    // Perform matrix multiplication
    bb_mul_warp16(OP1_ADDR, OP2_ADDR, WR_ADDR, size);
    printf("Finish test: %s\n", test_name);

    // Move result back
    bb_mvout((uintptr_t)c, WR_ADDR, size);
}

int run_test(const char* test_name, elem_t* a, elem_t* b, int size) {
    // Clear output matrix
    clear_matrix(output_matrix, DIM, DIM);
    
    // Generate expected result using CPU
    cpu_matmul(a, b, expected_matrix, size, size, size);
    
    // Run hardware implementation
    hw_matmul(test_name, a, b, output_matrix, size);

    // Compare results
    if (compare_matrices(output_matrix, expected_matrix, size, size)) {
        printf("Test %s PASSED\n", test_name);
        return 1;
    } else {
        printf("Test %s FAILED\n", test_name);
        return 0;
    }
}


// 定义测试函数类型
typedef int (*TestFunction)();

int test_ones() {
    init_ones_matrix(input_matrix_a, DIM, DIM);
    init_ones_matrix(input_matrix_b, DIM, DIM);
    return run_test("All-ones matrices", input_matrix_a, input_matrix_b, DIM);
}

int test_identity_random() {
    init_identity_matrix(input_matrix_a, DIM);
    init_random_matrix(input_matrix_b, DIM, DIM, 123);
    return run_test("Identity × Random", input_matrix_a, input_matrix_b, DIM);
}

int test_row_col_vector() {
    init_row_vector(input_matrix_a, DIM, 2);
    init_col_vector(input_matrix_b, DIM, 3);
    return run_test("Row vector × Column vector", input_matrix_a, input_matrix_b, DIM);
}

int test_col_row_vector() {
    init_col_vector(input_matrix_a, DIM, 4);
    init_row_vector(input_matrix_b, DIM, 5);
    return run_test("Column vector × Row vector", input_matrix_a, input_matrix_b, DIM);
}

int test_random1() {
    init_random_matrix(input_matrix_a, DIM, DIM, 456);
    init_random_matrix(input_matrix_b, DIM, DIM, 789);
    return run_test("Random matrices 1", input_matrix_a, input_matrix_b, DIM);
}

int test_random2() {
    init_random_matrix(input_matrix_a, DIM, DIM, 111);
    init_random_matrix(input_matrix_b, DIM, DIM, 222);
    return run_test("Random matrices 2", input_matrix_a, input_matrix_b, DIM);
}

int test_random3() {
    init_random_matrix(input_matrix_a, DIM, DIM, 333);
    init_random_matrix(input_matrix_b, DIM, DIM, 444);
    return run_test("Random matrices 3", input_matrix_a, input_matrix_b, DIM);
}

int test_zero_random() {
    clear_matrix(input_matrix_a, DIM, DIM);
    init_random_matrix(input_matrix_b, DIM, DIM, 555);
    return run_test("Zero × Random", input_matrix_a, input_matrix_b, DIM);
}

int main() {
    int tests_passed = 0;
    int total_tests = 0;
    
    // 这里定义要运行的测试序号（1-8）
    // 修改这个数组来选择要运行的测试用例
    const int test_selection[] = {1}; 
    const int num_selected = sizeof(test_selection)/sizeof(test_selection[0]);
    
    // 创建测试函数数组
    TestFunction tests[] = {
        test_ones,                // 测试1
        test_identity_random,     // 测试2
        test_row_col_vector,      // 测试3
        test_col_row_vector,      // 测试4
        test_random1,             // 测试5
        test_random2,             // 测试6
        test_random3,             // 测试7
        test_zero_random          // 测试8
    };
    
    printf("Running %d selected tests from [%d] available tests\n", 
           num_selected, (int)(sizeof(tests)/sizeof(tests[0])));
    
    // 按选择顺序运行测试
    for (int i = 0; i < num_selected; i++) {
        int test_index = test_selection[i] - 1;
        if (test_index >= 0 && test_index < (int)(sizeof(tests)/sizeof(tests[0]))) {
            total_tests++;
            if (tests[test_index]()) {
                tests_passed++;
            }
        } else {
            printf("Invalid test index %d skipped\n", test_index + 1);
        }
    }
    
    return 0;
}