// RUN: buddy-opt %s \
// RUN:     -lower-buckyball | \
// RUN: FileCheck %s

// 固定参数版本
func.func @main() -> i8 {
  %0 = arith.constant 0 : i8
  
  // 获取暂存器地址 (scratchpad addresses)
  %a_sp = arith.constant 100 : i64  // A矩阵暂存器地址
  %b_sp = arith.constant 200 : i64  // B矩阵暂存器地址
  %c_sp = arith.constant 300 : i64  // C矩阵暂存器地址
  %len = arith.constant 64 : i64    // 矩阵长度
  
  // 使用BuckyBall的bb_mul_warp16操作执行矩阵乘法(16 warp并行)
  // CHECK: bb_mul_warp16
  "buckyball.bb_mul_warp16"(%a_sp, %b_sp, %c_sp, %len) : (i64, i64, i64, i64) -> ()
  
  return %0 : i8
}

// 动态参数版本
func.func @dynamic_test(%addr1: i64, %addr2: i64, %addr3: i64, %length: i64) -> i8 {
  %0 = arith.constant 0 : i8
  
  // 使用动态参数的bb_mul_warp16操作
  // CHECK: bb_mul_warp16
  "buckyball.bb_mul_warp16"(%addr1, %addr2, %addr3, %length) : (i64, i64, i64, i64) -> ()
  
  return %0 : i8
}
