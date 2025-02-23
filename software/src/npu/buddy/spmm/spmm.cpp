#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include "include/v_isa.h"
#include "include/matrix_para.h"

extern "C" { void *__dso_handle = NULL; } // 不使用riscv64-unknown-elf-g++进行编译情况请注释这里

/* 使用riscv64-unknown-elf-g++进行编译请注释这里
// void write_result_text(const char* filename, int8_t* data, int M, int N) {
//     FILE* fp = fopen(filename, "w");
//     if (!fp) {
//         perror("Failed to open text file");
//         return;
//     }
//     for (int i = 0; i < M; ++i) {
//         for (int j = 0; j < N; ++j) {
//             fprintf(fp, "%d ", data[i * N + j]);
//         }
//         fprintf(fp, "\n");
//     }
//     fclose(fp);
// }*/

// 向量寄存器组
Vector v[32] = {
    #define VECTOR_INIT_2(x)  Vector(Vector::BitWidth::W8), Vector(Vector::BitWidth::W8),
    #define VECTOR_INIT_4(x)  VECTOR_INIT_2(x) VECTOR_INIT_2(x)
    #define VECTOR_INIT_8(x)  VECTOR_INIT_4(x) VECTOR_INIT_4(x)
    #define VECTOR_INIT_16(x) VECTOR_INIT_8(x) VECTOR_INIT_8(x)
    #define VECTOR_INIT_32(x) VECTOR_INIT_16(x) VECTOR_INIT_16(x)
    VECTOR_INIT_32()
    #undef VECTOR_INIT_1
    #undef VECTOR_INIT_2
    #undef VECTOR_INIT_4
    #undef VECTOR_INIT_8
    #undef VECTOR_INIT_16
    #undef VECTOR_INIT_32
};


// A 128 M* 128K
// B 128 K* 128

void spmm(CSRMatrix* sparse, int8_t* dense, int M, int N, int K, int8_t* result) {
    for (int i = 0; i < M; i++) {
        for (int j = sparse->row_ptr[i]; j < sparse->row_ptr[i+1]; j++) {
            int col = sparse->col_idx[j];
            int32_t val = sparse->values[j];
            for (int k = 0; k < N; k++) {
                result[i * N + k] += val * dense[col * N + k];
            }
        }
    }
}

void spmm_ws(CSRMatrix* A, int8_t* B, int M, int N, int K, int32_t* C) {
    for (int i = 0; i < M; i++) { // A 行
        for (int j = A->row_ptr[i]; j < A->row_ptr[i+1]; j++) { // A 列 
            for (int k = 0; k < N; k++) { // B 列
                C[i * N + k] += (int32_t)A->values[j] * B[A->col_idx[j] * N + k];
            }
        }
    }
}

void spmm_os(CSRMatrix* A, int8_t* B, int M, int N, int K, int32_t* C) {
    for (int i = 0; i < M; i++) { // A 行
        for (int k = 0; k < N; k++) { // B 列
            for (int j = A->row_ptr[i]; j < A->row_ptr[i+1]; j++) { // A 列
                C[i * N + k] += (int32_t)A->values[j] * B[A->col_idx[j] * N + k];
            }
        }
    }
}

// int line_nnz[16] = {0};

// void spmm_vector(CSRMatrix* A, int8_t* B, int M, int N, int K, int8_t* C) {
//     // int aval_baddr = &A->values;
//     // int idx_baddr = &A->col_idx;
//     // int ptr_baddr = &A->row_ptr;
//     int b_val_baddr = &B;
//     int c_val_baddr = &C;
//     for (int i = 0; i < M; i+=16) { // A 行
//         // v[0].load(&val_baddr + i * 16);
//         // v[1].load(&val_baddr + i * 16 + 1);
//         // v[1].add(-v[0]);
//         // for (int sp = i+0; sp < i+16; sp++) { 
//         //     line_nnz[sp] = A->row_ptr[i+1] - A->row_ptr[i]; 
//         // }
//         // if (__prefetcher_status() == 1) {
//         //     __prefetcher_track(xx);

//         // } 
//         for (int j = 0; j < N; j +=16) { // B 的行每次被取16个数
//             for (int sp = i; sp < i+16; sp++) { 
//                 for (int tp = A->row_ptr[i]; tp < A->row_ptr[i+1]; tp++) {
//                     int32_t a_val = A->values[tp];                    
//                     // %vx = vector.load(vx, r1=())   // load B
//                     v[sp].load(b_val_baddr + A->col_idx[tp] * N + j); 
//                     // %vx = vector.mul(vx, r1=())   // B vmula A
//                     v[sp].mul(a_val); 
//                     // %vx = vector.add(vx, vx+16)   // B vmulv B
//                     v[sp+16].add(v[sp]); 
//                 }
//                 v[sp+16].store(c_val_baddr + i * N + j); // C的第i行，第 j~j+16个
//             }
//         }
//         // v16~v32 + v0~v15 -> v0~v15
//         // for(int i = 0; i < 15; i++) { v[i].add(v[i+16]); }
//     }
// }

void spmm_vector(CSRMatrix* A, int8_t* B, int M, int N, int K, int8_t* C) {
    int8_t* b_val_baddr = B;
    int8_t* c_val_baddr = C;
    for (int i = 0; i < M; i+=16) { // A 行
        for (int j = 0; j < N; j +=16) { // B 的行每次被取16个数
            for (int sp = 0; sp < 16; sp++) { 
                for (int tp = A->row_ptr[i+sp]; tp < A->row_ptr[i+sp+1]; tp++) {
                    int8_t a_val = A->values[tp];                    
                    v[sp].load(b_val_baddr + A->col_idx[tp] * N + j); 
                    // printf("i=%d, j=%d, sp=%d, tp=%d", i,j,sp,tp);
                    // v[sp].print();
                    v[sp].mul(a_val); 
                    // v[sp].print();
                    // v[sp+16].print();
                    v[sp+16].add(v[sp]); 
                }
                v[sp+16].store(c_val_baddr + (i + sp) * N + j); // C的第sp行，第 j~j+16个
                v[sp+16].rst(); 
            }
        }
    }
}

int main() {
    int M = 128;
    int N = 128;
    int K = 128;

    int8_t* result = (int8_t *)calloc(M * N, sizeof(int8_t));

    // spmm(&A_csr, val_d, 128, 128, 128, result);
    spmm_vector(&A_csr, val_d, 128, 128, 128, result);

    // write_result_text("rst.txt", result, M, N); // 使用riscv64-unknown-elf-g++进行编译请注释这里
    free(result);

    return 0;
}
