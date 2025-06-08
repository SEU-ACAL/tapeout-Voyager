// RUN: buddy-opt %s \
// RUN:     -lower-buckyball | \
// RUN: FileCheck %s

// Spec: 
// 目的：mvin和mvout指令的正确性
// 1. 打印输入矩阵 
// 2. 打印搬移前目标地址的矩阵  [CHECK] 打印结果应为全0矩阵
// 3. 使用mvin将数据从内存搬到暂存器
// 4. 使用mvout将数据从暂存器搬回输出内存
// 5. 打印搬移后目标地址的矩阵  [CHECK] 打印结果应该与输入矩阵相同

memref.global "private" @input_matrix : memref<3x16xi8> = dense<[[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
                                                                 [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31],
                                                                 [32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47]]>

func.func @main() -> i8 {
//   // === 检查当前hartid是否为5，否则退出 ===
//   %hartid = llvm.inline_asm "csrr $0, mhartid", "=r" : () -> i32
//   // buckyball.print_scalar %hartid : i32

//   %target_hart = arith.constant 5 : i32
//   %is_correct_hart = arith.cmpi eq, %hartid, %target_hart : i32
//   cf.cond_br %is_correct_hart, ^continue, ^exit

// ^exit:
//   // 如果不是hart 5，返回 0
//   %error = arith.constant -1 : i8
//   return %error : i8

// ^continue:
  buckyball.multicore
  // %hartid = llvm.inline_asm "csrr $0, mhartid", "=r" : () -> i32
  // buckyball.print_scalar %hartid : i32
  // === 主程序 ===
  %0 = arith.constant 0 : i8
  %spadAddr = arith.constant 10 : i64
  %arrayA = memref.get_global @input_matrix : memref<3x16xi8>
  %arrayB = memref.alloc() : memref<3x16xi8>
  buckyball.print %arrayA : memref<3x16xi8>
  buckyball.print %arrayB : memref<3x16xi8>
  // 使用mvin将数据从内存搬到暂存器
  // CHECK: mvin
  buckyball.bb_mvin %arrayA %spadAddr : memref<3x16xi8> i64
  // 使用mvout将数据从暂存器搬回输出内存
  // CHECK: mvout  
  buckyball.bb_mvout %arrayB %spadAddr : memref<3x16xi8> i64
  // 打印搬移后的输出矩阵
  buckyball.print %arrayB : memref<3x16xi8>
  // 释放分配的内存
  memref.dealloc %arrayB : memref<3x16xi8>
  
  // exit
  %exit_code = arith.constant 0 : i32
  func.call @exit(%exit_code) : (i32) -> ()
  llvm.unreachable
}

func.func private @exit(i32) -> ()
