#include <stdio.h>
#include <stdlib.h>
#include "include/v_isa.h"

// typedef struct {
//     int rows;       // 矩阵行数
//     int cols;       // 矩阵列数
//     int nnz;        // 非零元素个数
//     double* values; // 非零元素值
//     int* col_idx;   // 列索引
//     int* row_ptr;   // 行指针
// } CSRMatrix;

// void spmm(const CSRMatrix* sparse, const double* dense, int dense_cols, double* result) {
//     for (int i = 0; i < sparse->rows; i++) {
//         for (int j = sparse->row_ptr[i]; j < sparse->row_ptr[i+1]; j++) {
//             int col = sparse->col_idx[j];
//             double val = sparse->values[j];
//             for (int k = 0; k < dense_cols; k++) {
//                 result[i * dense_cols + k] += val * dense[col * dense_cols + k];
//             }
//         }
//     }
// }


#include <iostream>

int main() {
    // 创建不同位宽的向量
    Vector vec8(Vector::BitWidth::W8);
    Vector vec32(Vector::BitWidth::W32);
    // 操作8位向量
    vec8.add(5);
    vec8.multiply(2);
    std::cout << "8-bit Vector: ";
    vec8.print();  // 输出：[10 10 10 ... ] (16个10)
    
    // 操作32位向量
    vec32.add(10);
    vec32.add(vec32); // 自加操作
    std::cout << "32-bit Vector: ";
    vec32.print();  // 输出：[20 20 20 20 ]
    // 获取求和结果
    std::cout << "Sum8: " << vec8.sum() << "\n";   // 160
    std::cout << "Sum32: " << vec32.sum() << "\n"; // 80

    return 0;
}
