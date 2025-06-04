// RUN: buddy-opt %s \
// RUN:     -lower-buckyball | \
// RUN: FileCheck %s

// 固定参数版本
func.func @main() -> i8 {
  %0 = arith.constant 0 : i8
  
  // 创建输出矩阵
  %output = memref.alloc() : memref<16x32xi8>
  
  // 获取暂存器地址 (scratchpad address)
  %sp_addr = arith.constant 100 : i64  // 暂存器地址
  
  // 使用BuckyBall的mvout操作将数据从暂存器移至内存
  // CHECK: mvout
  "buckyball.mvout"(%output, %sp_addr) : (memref<16x32xi8>, i64) -> ()
  
  // 释放内存
  memref.dealloc %output : memref<16x32xi8>
  
  return %0 : i8
}

// 动态参数版本
func.func @dynamic_test(%rows: index, %cols: index, %addr: i64) -> i8 {
  %0 = arith.constant 0 : i8
  
  // 创建动态尺寸的输出矩阵
  %output = memref.alloc(%rows, %cols) : memref<?x?xi8>
  
  // 使用动态参数的mvout操作
  // CHECK: mvout
  "buckyball.mvout"(%output, %addr) : (memref<?x?xi8>, i64) -> ()
  
  // 释放内存
  memref.dealloc %output : memref<?x?xi8>
  
  return %0 : i8
} 

// 在实际计算场景中的使用示例
func.func @matmul_test(%m: index, %n: index, %k: index) -> i8 {
  %0 = arith.constant 0 : i8
  
  // 创建矩阵
  %a = memref.alloc(%m, %k) : memref<?x?xi8>
  %b = memref.alloc(%k, %n) : memref<?x?xi8>
  %c = memref.alloc(%m, %n) : memref<?x?xi8>
  
  // 暂存器地址
  %a_addr = arith.constant 0 : i64
  %b_addr = arith.constant 1000 : i64
  %c_addr = arith.constant 2000 : i64
  
  // 将A、B矩阵加载到暂存器
  "buckyball.mvin"(%a, %a_addr) : (memref<?x?xi8>, i64) -> ()
  "buckyball.mvin"(%b, %b_addr) : (memref<?x?xi8>, i64) -> ()
  
  // 执行矩阵乘法（此处省略具体实现）
  
  // 将结果从暂存器写回内存
  // CHECK: mvout
  "buckyball.mvout"(%c, %c_addr) : (memref<?x?xi8>, i64) -> ()
  
  // 释放内存
  memref.dealloc %a : memref<?x?xi8>
  memref.dealloc %b : memref<?x?xi8>
  memref.dealloc %c : memref<?x?xi8>
  
  return %0 : i8
} 