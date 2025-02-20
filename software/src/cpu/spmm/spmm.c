#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int rows;       // 矩阵行数
    int cols;       // 矩阵列数
    int nnz;        // 非零元素个数
    double* values; // 非零元素值
    int* col_idx;   // 列索引
    int* row_ptr;   // 行指针
} CSRMatrix;

void spmm(const CSRMatrix* sparse, const double* dense, int dense_cols, double* result) {
    for (int i = 0; i < sparse->rows; i++) {
        for (int j = sparse->row_ptr[i]; j < sparse->row_ptr[i+1]; j++) {
            int col = sparse->col_idx[j];
            double val = sparse->values[j];
            for (int k = 0; k < dense_cols; k++) {
                result[i * dense_cols + k] += val * dense[col * dense_cols + k];
            }
        }
    }
}

int main() {
    CSRMatrix A;
    A.rows = 3;
    A.cols = 3;
    A.nnz = 4;
    
    // [[1, 0, 2]
    //  [0, 0, 3]
    //  [4, 5, 0]]
    A.row_ptr = (int[]){0, 2, 3, 5};
    A.col_idx = (int[]){0, 2, 2, 0, 1};
    A.values = (double[]){1.0, 2.0, 3.0, 4.0, 5.0};

    int dense_cols = 2;
    double B[] = {
        1.0, 2.0,
        3.0, 4.0,
        5.0, 6.0
    };

    double* result = calloc(A.rows * dense_cols, sizeof(double));

    spmm(&A, B, dense_cols, result);

    printf("Result matrix:\n");
    for (int i = 0; i < A.rows; i++) {
        for (int j = 0; j < dense_cols; j++) {
            printf("%.2f ", result[i * dense_cols + j]);
        }
        printf("\n");
    }

    // FileCheck：
    // [ (1*1 + 2*5), (1*2 + 2*6) ] = [11, 14]
    // [ (3*5),        (3*6)      ] = [15, 18]
    // [ (4*1 +5*3),  (4*2 +5*4)  ] = [19, 28]

    free(result);
    return 0;
}
