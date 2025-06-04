// RUN: buddy-opt %s \
// RUN:     -lower-buckyball | \
// RUN: FileCheck %s

memref.global "private" @input_matrix : memref<2x16xi8> = dense<[[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
                                                                 [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]]>

func.func @main() -> i8 {
  %0 = arith.constant 0 : i8
  %spadAddr = arith.constant 0 : i64
  // %arrayA = memref.alloc() : memref<2x8xi8>
  %arrayA = memref.get_global @input_matrix : memref<2x16xi8>
  // %c0 = arith.constant 0 : index
  // %c1 = arith.constant 1 : index
  // %v0 = arith.constant 42 : i8
  // %v1 = arith.constant 84 : i8
  // memref.store %v0, %arrayA[%c0, %c0] : memref<2x8xi8>
  // memref.store %v1, %arrayA[%c1, %c0] : memref<2x8xi8>
  %arrayB = memref.alloc() : memref<2x16xi8>
  buckyball.print %arrayA : memref<2x16xi8>
  buckyball.print %arrayB : memref<2x16xi8>
  // 使用mvin将数据从内存搬到暂存器
  // CHECK: mvin
  buckyball.mvin %arrayA %spadAddr : memref<2x16xi8> i64
  // 使用mvout将数据从暂存器搬回输出内存
  // CHECK: mvout  
  buckyball.mvout %arrayB %spadAddr : memref<2x16xi8> i64
  // 打印搬移后的输出矩阵
  buckyball.print %arrayB : memref<2x16xi8>
  // 释放分配的内存
  // memref.dealloc %arrayA : memref<2x16xi8>
  memref.dealloc %arrayB : memref<2x16xi8>
  return %0 : i8
}
