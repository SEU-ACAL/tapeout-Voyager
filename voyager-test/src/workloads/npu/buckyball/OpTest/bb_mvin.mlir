// RUN: buddy-opt %s \
// RUN:     -lower-buckyball | \
// RUN: FileCheck %s

// 固定参数版本
func.func @main() -> i8 {
  %0 = arith.constant 0 : i8
  
  // 创建输入矩阵
  %input = memref.alloc() : memref<16x32xi8>
  
  // 获取暂存器地址 (scratchpad address)
  %sp_addr = arith.constant 100 : i64  // 暂存器地址
  
  // 使用BuckyBall的mvin操作将数据从内存移至暂存器
  // CHECK: mvin
  "buckyball.mvin"(%input, %sp_addr) : (memref<16x32xi8>, i64) -> ()
  
  // 释放内存
  memref.dealloc %input : memref<16x32xi8>
  
  return %0 : i8
}

// 动态参数版本
func.func @dynamic_test(%rows: index, %cols: index, %addr: i64) -> i8 {
  %0 = arith.constant 0 : i8
  
  // 创建动态尺寸的输入矩阵
  %input = memref.alloc(%rows, %cols) : memref<?x?xi8>
  
  // 使用动态参数的mvin操作
  // CHECK: mvin
  "buckyball.mvin"(%input, %addr) : (memref<?x?xi8>, i64) -> ()
  
  // 释放内存 
  memref.dealloc %input : memref<?x?xi8>
  
  return %0 : i8
} 