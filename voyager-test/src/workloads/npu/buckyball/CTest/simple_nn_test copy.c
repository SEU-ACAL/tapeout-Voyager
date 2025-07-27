#include "buckyball.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// 定义神经网络参数
#define INPUT_SIZE DIM
#define HIDDEN_SIZE DIM
#define OUTPUT_SIZE DIM

// 测试矩阵和数据缓冲区
static elem_t input_data[DIM * DIM] __attribute__((aligned(64)));
static elem_t weights1[HIDDEN_SIZE * INPUT_SIZE] __attribute__((aligned(64)));
static elem_t weights2[OUTPUT_SIZE * HIDDEN_SIZE] __attribute__((aligned(64)));
static result_t hidden_output[DIM * DIM] __attribute__((aligned(64)));
static result_t final_output[DIM * DIM] __attribute__((aligned(64)));
static result_t expected_output[DIM * DIM] __attribute__((aligned(64)));

#define BANK 512
#define OP1_ADDR 0
#define OP2_ADDR (BANK + DIM)
#define WR_ADDR (DIM + 2 * BANK)

// 执行硬件矩阵乘法
void hw_matmul(elem_t* a, elem_t* b, result_t* c, int size) {
    // 转置左矩阵
    static elem_t a_transposed[DIM * DIM] __attribute__((aligned(64)));
    transpose_matrix(a, a_transposed, size, size);
    
    // 移动矩阵到暂存器
    bb_mvin((uintptr_t)a_transposed, OP1_ADDR, size);
    bb_mvin((uintptr_t)b, OP2_ADDR, size);
    bb_mvin((uintptr_t)c, WR_ADDR, size << 2);

    bb_fence();
    // 执行矩阵乘法
    bb_mul_warp16(OP1_ADDR, OP2_ADDR, WR_ADDR, size);
    bb_fence();

    // 移回结果
    bb_mvout((uintptr_t)c, WR_ADDR, size << 2);
}

// ReLU激活函数（在CPU上执行）
void relu(result_t* matrix, int rows, int cols) {
    for (int i = 0; i < rows * cols; i++) {
        if (matrix[i] < 0) {
            matrix[i] = 0;
        }
    }
}

// CPU上的神经网络前向传播
void cpu_nn_forward(elem_t* input, elem_t* w1, elem_t* w2, 
                   result_t* hidden, result_t* output, int size) {
    // 输入层 -> 隐藏层
    cpu_matmul(input, w1, hidden, size, size, size);
    relu(hidden, size, size);  // 应用ReLU激活
    
    // 隐藏层 -> 输出层
    // 注意：需要将隐藏层输出（int32）量化为8位输入
    static elem_t hidden_quantized[DIM * DIM];
    for (int i = 0; i < size*size; i++) {
        hidden_quantized[i] = (elem_t)(hidden[i] >> 8);  // 量化到8位
    }
    
    cpu_matmul(hidden_quantized, w2, output, size, size, size);
}

// 执行神经网络测试
int test_neural_network() {
    printf("=== Neural Network Test Starting ===\n");
    
    // 初始化数据
    printf("Step 1: Initializing input data...\n");
    init_u8_random_matrix(input_data, DIM, DIM, 123);
    
    // 初始化权重 (神经网络参数)
    // 使用Xavier初始化以获得更好的训练效果
    printf("Step 2: Initializing weights with Xavier initialization...\n");
    float scale1 = sqrtf(2.0f / (INPUT_SIZE + HIDDEN_SIZE));
    float scale2 = sqrtf(2.0f / (HIDDEN_SIZE + OUTPUT_SIZE));
    
    for (int i = 0; i < HIDDEN_SIZE * INPUT_SIZE; i++) {
        float r = ((float)rand() / RAND_MAX) * 2.0f - 1.0f;
        weights1[i] = (elem_t)(r * scale1 * 127);
    }
    
    for (int i = 0; i < OUTPUT_SIZE * HIDDEN_SIZE; i++) {
        float r = ((float)rand() / RAND_MAX) * 2.0f - 1.0f;
        weights2[i] = (elem_t)(r * scale2 * 127);
    }
    
    // 清空输出缓冲区
    printf("Step 3: Clearing output buffers...\n");
    clear_u32_matrix(hidden_output, DIM, DIM);
    clear_u32_matrix(final_output, DIM, DIM);
    clear_u32_matrix(expected_output, DIM, DIM);
    
    // 在CPU上生成预期结果
    printf("Step 4: Computing expected results on CPU...\n");
    cpu_nn_forward(input_data, weights1, weights2, 
                  hidden_output, expected_output, DIM);
    
    // 重新清空hidden_output用于硬件计算
    clear_u32_matrix(hidden_output, DIM, DIM);
    
    // 硬件加速的前向传播 ------------------------------
    printf("=== Hardware Forward Pass ===\n");
    
    // 第一步: 输入层 -> 隐藏层 (H = relu(X * W1))
    printf("Step 5: Hardware Layer 1 (Input -> Hidden)...\n");
    hw_matmul(input_data, weights1, hidden_output, DIM);
    printf("Step 6: Applying ReLU activation...\n");
    relu(hidden_output, DIM, DIM);  // 在CPU上应用ReLU
    
    // 量化隐藏层输出作为下一层的输入
    printf("Step 7: Quantizing hidden output (32bit -> 8bit)...\n");
    static elem_t hidden_quantized[DIM * DIM];
    for (int i = 0; i < DIM*DIM; i++) {
        hidden_quantized[i] = (elem_t)(hidden_output[i] >> 8);  // 量化到8位
    }
    
    // 第二步: 隐藏层 -> 输出层 (Y = H * W2)
    printf("Step 8: Hardware Layer 2 (Hidden -> Output)...\n");
    hw_matmul(hidden_quantized, weights2, final_output, DIM);
    
    // --------------------------------------------------
    
    // 比较结果 (允许3%的误差容限，因为量化和舍入误差)
    printf("Step 9: Comparing results (tolerance=3%%)...\n");
    if (compare_u32_matrices_with_tolerance(final_output, expected_output, 
                                          DIM, DIM, 0.03)) {
        printf("✓ Neural Network Test PASSED\n");
        return 1;
    } else {
        printf("✗ Neural Network Test FAILED\n");
        return 0;
    }
}

int main() {
#ifdef MULTICORE 
    multicore(MULTICORE);
#endif
    int passed = test_neural_network();
    if (passed) {
        printf("Neural Network Test PASSED\n");
    } else {
        printf("Neural Network Test FAILED\n");
    }
    exit(0);
#ifdef MULTICORE 
    exit(0);
#endif
} 