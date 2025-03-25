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
  val rob_id_valid = Bool()
}

class VecTC extends Module {
  val io = IO(new Bundle {
      val in  = Vec(8, Flipped(Decoupled(new VecTC_input())))
      val out = Decoupled(new VecTC_output())
  })

  val Vectors1_data = Seq.tabulate(8){i => RegInit(VecInit(Seq.fill(16)(0.U(8.W))))} // 缓冲Vec
  val Vectors1_valid = Seq.tabulate(8){i => RegInit(false.B)}  // Vec有效(不是握手)
  // 若相邻寄存器没valid, 则这个寄存器不能ready,得等1个cycle

  val Vectors2_data = Seq.tabulate(8){i => RegInit(VecInit(Seq.fill(16)(0.U(8.W))))} // 级联Vec
  val Vectors2_valid = Seq.tabulate(8){i => RegInit(false.B)} 
  
  // val rob_id = Seq.tabulate(8){i => RegInit(0.U(5.W))}
  

  // val sIdle :: sProfill :: sFull :: Nil = Enum(3)
  // val state = RegInit(sIdle)
// -----------------------------------------------------------------------------
// 缓冲寄存器
// -----------------------------------------------------------------------------

  // profill 阶段 只支持0~7顺序
  val ptr = RegInit(0.U(5.W)) // 用来指引计算顺序
  val valid_mask = RegInit(0.U(8.W)) // 记录哪些输入已经valid过

  for (i <- 0 until 8) {
    io.in(i).ready := (i.U === ptr) || ((i.U < ptr) && valid_mask(i))
  }

  // 当当前ptr对应的输入有效时，记录并移动ptr
  when (io.in(ptr).valid && io.in(ptr).ready && (ptr < 8.U)) { 
      valid_mask := valid_mask | (1.U << ptr) // 设置有效标志
    ptr := ptr + 1.U 
  }
  
  for (i <- 0 until 8) {
    when(io.in(i).valid && io.in(i).ready) {
      Vectors1_valid(i) := valid_mask(i)
      Vectors1_data(i) := io.in(i).bits.thread_rst
    }
  }

  val rob_queue = Module(new Queue(UInt(5.W), 8))
  rob_queue.io.enq.valid := io.in(ptr).valid && io.in(ptr).ready && (ptr < 8.U)
  rob_queue.io.enq.bits  := io.in(ptr).bits.rob_id
  rob_queue.io.deq.ready := true.B//Vectors2_valid(7) && io.out.ready
  
  // io.out.bits.rob_id := rob_queue.io.deq.bits
  // TODO: 现在只是一次性玩具,后面改为真实提交的状态机

// -----------------------------------------------------------------------------
// Reduce
// -----------------------------------------------------------------------------
  for (i <- 0 until 8) { Vectors2_valid(i) := Vectors1_valid(i)}

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

// -----------------------------------------------------------------------------
// 弹出结果
// -----------------------------------------------------------------------------
  io.out.bits.rob_id_valid        := rob_queue.io.deq.valid
  io.out.bits.rob_id  := rob_queue.io.deq.bits

  when (Vectors2_valid(7)) {
    io.out.valid        := true.B
    io.out.bits.wb_en   := true.B
    io.out.bits.wb_data := Vectors2_data(7)
    io.out.bits.wb_addr := 0.U
    io.out.bits.is_acc  := false.B
  }.otherwise {
    io.out.valid        := false.B
    io.out.bits.wb_en   := false.B
    io.out.bits.wb_data := VecInit(Seq.fill(16)(0.U(8.W)))
    io.out.bits.wb_addr := 0.U
    io.out.bits.is_acc  := false.B
  }
}
