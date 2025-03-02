#include <stdio.h>
#include <stdlib.h>

// 裸机环境可能需要特定的输出函数
// 如果有特定的硬件输出接口，可以在这里定义
#ifdef BAREMETAL
#define PUTCHAR(c) /* 这里可以添加裸机环境下的字符输出函数 */
#define PRINT_STR(s) do { \
    const char *p = (s); \
    while(*p) { \
        PUTCHAR(*p++); \
    } \
} while(0)
#else
#define PUTCHAR(c) putchar(c)
#define PRINT_STR(s) printf("%s", s)
#endif

typedef struct {
    int rows;       // 矩阵行数
    int cols;       // 矩阵列数
    int nnz;        // 非零元素个数
    double* values; // 非零元素值
    int* col_idx;   // 列索引
    int* row_ptr;   // 行指针
} CSRMatrix;

void spmm(const CSRMatrix* sparse, const double* dense, int dense_cols, double* result) {
    #ifndef BAREMETAL
    printf("开始执行SpMM计算...\n");
    fflush(stdout);
    #endif
    
    for (int i = 0; i < sparse->rows; i++) {
        for (int j = sparse->row_ptr[i]; j < sparse->row_ptr[i+1]; j++) {
            int col = sparse->col_idx[j];
            double val = sparse->values[j];
            for (int k = 0; k < dense_cols; k++) {
                result[i * dense_cols + k] += val * dense[col * dense_cols + k];
            }
        }
    }
    
    #ifndef BAREMETAL
    printf("SpMM计算完成!\n");
    fflush(stdout);
    #endif
}

// 定义静态数组，避免在裸机环境中使用动态内存
static double final_result[9];  // 最大可能大小

int main() {
    #ifndef BAREMETAL
    printf("程序开始执行...\n");
    fflush(stdout);
    #endif
    
    CSRMatrix A;
    A.rows = 3;
    A.cols = 3;
    A.nnz = 5;
    
    // [[1, 0, 2]
    //  [0, 0, 3]
    //  [4, 5, 0]]
    static int row_ptr[] = {0, 2, 3, 5};
    static int col_idx[] = {0, 2, 2, 0, 1};
    static double values[] = {1.0, 2.0, 3.0, 4.0, 5.0};
    
    A.row_ptr = row_ptr;
    A.col_idx = col_idx;
    A.values = values;

    int dense_cols = 2;
    double B[] = {
        1.0, 2.0,
        3.0, 4.0,
        5.0, 6.0
    };

    #ifndef BAREMETAL
    printf("准备开始计算...\n");
    fflush(stdout);
    #endif

    // 使用预分配的静态数组，而不是动态内存
    double* result = final_result;
    // 手动初始化为零
    for (int i = 0; i < A.rows * dense_cols; i++) {
        result[i] = 0.0;
    }

    spmm(&A, B, dense_cols, result);

    #ifndef BAREMETAL
    printf("Result matrix:\n");
    fflush(stdout);
    for (int i = 0; i < A.rows; i++) {
        for (int j = 0; j < dense_cols; j++) {
            printf("%.2f ", result[i * dense_cols + j]);
            fflush(stdout);
        }
        printf("\n");
        fflush(stdout);
    }
    #endif

    // 特殊的结果标记，可以在裸机下检测
    // 这将把第一个结果值复制到结果数组的最后一个位置
    // 可以通过硬件调试或内存检查来验证计算是否正确
    result[A.rows * dense_cols - 1] = result[0];

    // FileCheck：
    // [ (1*1 + 2*5), (1*2 + 2*6) ] = [11, 14]
    // [ (3*5),        (3*6)      ] = [15, 18]
    // [ (4*1 +5*3),  (4*2 +5*4)  ] = [19, 28]

    #ifndef BAREMETAL
    printf("程序执行完毕!\n");
    fflush(stdout);
    #endif
    
    return 0;
}
