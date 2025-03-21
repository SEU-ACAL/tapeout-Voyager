package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._

class VecTC_input extends Bundle {
  val thread_rst = Input(Vec(16, UInt(8.W)))
  val thread_id  = Input(UInt(3.W))
  val config     = Input(UInt(12.W))  // 添加config字段以匹配VecALUThread输出
}

class VecTC_output extends Bundle {
  val wb_en   = Bool()
  val wb_data = Vec(16, UInt(8.W))
  val wb_addr = UInt(14.W)
  val is_acc  = Bool()
}

class VecTC extends Module {
  val io = IO(new Bundle {
      val in  = Vec(8, Flipped(Decoupled(new VecTC_input())))
      val out = Decoupled(new VecTC_output())
  })

  val Vectors1_data = Seq.tabulate(8) {i => RegInit(VecInit(Seq.fill(16)(0.U(8.W))))} // 分散Vec数据，16元素
  val Vectors1_valid = Seq.tabulate(8) {i => RegInit(false.B)} // 分散Vec有效位
  val Vectors2_data = Seq.tabulate(8) {i => RegInit(VecInit(Seq.fill(16)(0.U(8.W))))} // 级联Vec数据，保持8元素
  val Vectors2_valid = Seq.tabulate(8) {i => RegInit(false.B)} // 级联Vec有效位
  
// -----------------------------------------------------------------------------
// 缓冲寄存器
// -----------------------------------------------------------------------------
  
  (0 until 8).foreach { i =>
    when(io.in(i).valid) {
      Vectors1_data(i) := io.in(i).bits.thread_rst
      Vectors1_valid(i) := true.B
    }
      io.in(i).ready := true.B
  }

// -----------------------------------------------------------------------------
// Reduce
// -----------------------------------------------------------------------------
  // 第一个寄存器从Vector1获取输入
  for (i <- 0 until 7) { 
    Vectors1_valid(i) := io.in(i).valid
    Vectors2_valid(i) := Vectors1_valid(i)
  }

  when (Vectors1_valid(0)) { Vectors2_data(0) := Vectors1_data(0)}

  // 级联Vec - 每个cycle将本寄存器的值加给下一个寄存器
  for (i <- 0 until 7) { 
    when (Vectors1_valid(i)) {
      when (i.U === 0.U) {
          Vectors2_data(i) := Vectors1_data(i)
      }.otherwise {
        for (j <- 0 until 16) {
            Vectors2_data(i+1)(j) := Vectors2_data(i)(j) + Vectors2_data(i+1)(j) + Vectors1_data(i)(j)
        }
      }
    }
  }

// -----------------------------------------------------------------------------
// 弹出结果
// -----------------------------------------------------------------------------
  when (Vectors2_valid(7)) {
    io.out.valid := true.B
    io.out.bits.wb_en   := true.B
    io.out.bits.wb_data := Vectors2_data(7)
    io.out.bits.wb_addr := 0.U
    io.out.bits.is_acc  := false.B
  }.otherwise {
    io.out.valid := false.B
    io.out.bits.wb_en   := false.B
    io.out.bits.wb_data := VecInit(Seq.fill(16)(0.U(8.W)))
    io.out.bits.wb_addr := 0.U
    io.out.bits.is_acc  := false.B
  }
}
