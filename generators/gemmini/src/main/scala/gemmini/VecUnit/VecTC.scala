package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._

class VecTC_input extends Bundle {
  val thread_rst = Input(Vec(16, UInt(8.W)))
  val thread_id  = Input(UInt(3.W))
  val config     = Input(UInt(13.W)) 
  val rob_id     = Input(UInt(5.W))
}

class VecTC_output extends Bundle {
  val wb_en   = Bool()
  val wb_data = Vec(16, UInt(8.W))
  val wb_addr = UInt(14.W)
  val is_acc  = Bool()
  val rob_id  = Input(UInt(5.W))
}

class VecTC extends Module {
  val io = IO(new Bundle {
      val in  = Vec(8, Flipped(Decoupled(new VecTC_input())))
      val out = Decoupled(new VecTC_output())
  })

  val Vectors1_data = Seq.tabulate(8){i => RegInit(VecInit(Seq.fill(16)(0.U(8.W))))} // 缓冲Vec
  val Vectors1_valid = Seq.tabulate(8){i => RegInit(false.B)} 
  val Vectors2_data = Seq.tabulate(8){i => RegInit(VecInit(Seq.fill(16)(0.U(8.W))))} // 级联Vec
  val Vectors3_data = Seq.tabulate(8){i => RegInit(VecInit(Seq.fill(16)(0.U(8.W))))} // 级联Vec
  val Vectors2_valid = Seq.tabulate(8){i => RegInit(false.B)} 
  
  val rob_id = Seq.tabulate(8){i => RegInit(0.U(5.W))}
  val rob_id_reg = dontTouch(VecInit(Seq.fill(8)(RegInit(0.U(5.W)))))
  for (i <- 0 until 8) { rob_id_reg(i) := rob_id(i) }
  
  // val Vectors1_0_reg = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  // val Vectors1_0_valid = dontTouch(RegInit(false.B))
  // Vectors1_0_reg := Vectors1_data(0)
  // Vectors1_0_valid := Vectors1_valid(0)
// -----------------------------------------------------------------------------
// 缓冲寄存器
// -----------------------------------------------------------------------------
  
  (0 until 8).foreach { i =>
    when (io.in(i).valid) {
      Vectors1_data(i) := io.in(i).bits.thread_rst
      Vectors1_valid(i) := true.B
      
      // 更新rob_id(0)
      rob_id(0) := io.in(i).bits.rob_id
      
      // 依次更新其他rob_id
      for (j <- 1 until 8) {
        rob_id(j) := rob_id(j-1)
      }
    }
      io.in(i).ready := true.B
  }

// -----------------------------------------------------------------------------
// Reduce
// -----------------------------------------------------------------------------
  // 第一个寄存器从Vector1获取输入
  for (i <- 0 until 8) { 
    Vectors1_valid(i) := io.in(i).valid
    Vectors2_valid(i) := Vectors1_valid(i)
  }

  val Vectors2_0_reg = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  val Vectors2_1_reg = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  val Vectors2_2_reg = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  val Vectors2_3_reg = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  val Vectors2_4_reg = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  val Vectors2_5_reg = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  val Vectors2_6_reg = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  val Vectors2_7_reg = dontTouch(RegInit(VecInit(Seq.fill(16)(0.U(8.W)))))
  Vectors2_0_reg := Vectors2_data(0)
  Vectors2_1_reg := Vectors2_data(1)
  Vectors2_2_reg := Vectors2_data(2)
  Vectors2_3_reg := Vectors2_data(3)
  Vectors2_4_reg := Vectors2_data(4)
  Vectors2_5_reg := Vectors2_data(5)
  Vectors2_6_reg := Vectors2_data(6)
  Vectors2_7_reg := Vectors2_data(7)
  
  when (Vectors1_valid(0)) { Vectors2_data(0) := Vectors1_data(0)}

  // TODO: 这边要做成ping-pong
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

  // for (i <- 0 until 7) {
  //   when (Vectors1_valid(i)) {
  //     when (i.U === 0.U) {
  //       rob_id(0) := io.in(i).bits.rob_id
  //     }.otherwise {
  //       rob_id(i+1) := rob_id(i)
  //     }
  //   }
  // }

// -----------------------------------------------------------------------------
// 弹出结果
// -----------------------------------------------------------------------------
  when (Vectors2_valid(7)) {
    io.out.valid        := true.B
    io.out.bits.wb_en   := true.B
    io.out.bits.wb_data := Vectors2_data(7)
    io.out.bits.wb_addr := 0.U
    io.out.bits.is_acc  := false.B
    io.out.bits.rob_id  := rob_id(7)
  }.otherwise {
    io.out.valid        := false.B
    io.out.bits.wb_en   := false.B
    io.out.bits.wb_data := VecInit(Seq.fill(16)(0.U(8.W)))
    io.out.bits.wb_addr := 0.U
    io.out.bits.is_acc  := false.B
    io.out.bits.rob_id  := 0.U
  }
}
