package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._

class thread_input extends Bundle {
  val op1       = Vec(16, UInt(8.W))
  val op2       = Vec(16, UInt(8.W))
  val config    = UInt(12.W)
  val iteration = UInt(4.W) // 从0开始，循环1~16次
  val thread_id = UInt(3.W)
}

class thread_output extends Bundle {
  val thread_rst = Vec(16, UInt(8.W))
  val thread_id  = UInt(3.W)
  val config     = UInt(12.W)
}

class VecALUThread (val OpChainDepth: Int = 5) extends Module {
		val io = IO(new Bundle {
		val in  = Flipped(Decoupled(new thread_input()))
		val out = Decoupled(new thread_output())
  })

  val Vector1 = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val Vector2 = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val config  = RegInit(0.U(12.W))
  val iteration = RegInit(0.U(4.W))
  val thread_id = RegInit(0.U(3.W))

  config    := Mux(io.in.valid, io.in.bits.config, config)
  iteration := Mux(io.in.valid, io.in.bits.iteration, iteration)
  thread_id := Mux(io.in.valid, io.in.bits.thread_id, thread_id)

  val Array(is_load_op1, is_load_op2, 
    is_mul, is_add,
    is_int32, is_int16,
    tc_en, reduce_en, op_en,
    is_softmax, is_gelu, is_layernorm) = 
  (0 until 12).map(i => io.in.bits.config(i)).toArray

// -----------------------------------------------------------------------------
// Generate Micro Operation Chain
// load = 0, compute = 1, ptr是队尾指针
// -----------------------------------------------------------------------------
  val opChain = RegInit(0.U(log2Ceil(OpChainDepth).W))
  val opPtr = RegInit(0.U(log2Ceil(OpChainDepth).W))

  val thread_busy = RegInit(false.B)
  io.in.ready := !thread_busy
  thread_busy := (opPtr =/= 0.U)

  // 入队
  when (io.in.valid && io.in.ready) {
		when (is_load_op1 || is_load_op2) {
			opPtr := opPtr + 1.U
		}
		when (is_mul) {
			// val ones = Mux(is_int32, VecInit(Seq.fill(4)(1.U(1.W))), 
			//            Mux(is_int16, VecInit(Seq.fill(8)(1.U(1.W))), 
			//                VecInit(Seq.fill(16)(1.U(1.W)))))
			// val mask = ones.asUInt()(io.in.bits.iteration)
			
			val ones_32bit = VecInit(Seq.fill(16)(0.U(1.W)))
			val ones_16bit = VecInit(Seq.fill(16)(0.U(1.W)))
			val ones_8bit = VecInit(Seq.fill(16)(0.U(1.W)))
			
			for (i <- 0 until 4) { ones_32bit(i) := 1.U }
			for (i <- 0 until 8) { ones_16bit(i) := 1.U }
			for (i <- 0 until 16) { ones_8bit(i) := 1.U }
			
			val selected_ones = Wire(Vec(16, UInt(1.W)))
			when (is_int32) {
				selected_ones := ones_32bit
			} .elsewhen (is_int16) {
				selected_ones := ones_16bit
			} .otherwise {
				selected_ones := ones_8bit
			}
  
			val mask = selected_ones.asUInt()(io.in.bits.iteration)
			opChain := opChain | (mask << opPtr)
			opPtr := opPtr << io.in.bits.iteration
  	}
  }

// -----------------------------------------------------------------------------
// Execute Micro Operation Chain
// -----------------------------------------------------------------------------
  // 出队
  // 默认初始化所有输出信号
  io.out.valid := false.B
  io.out.bits.thread_id := thread_id
  io.out.bits.config := config
  io.out.bits.thread_rst := VecInit(Seq.fill(16)(0.U(8.W)))

  when (opPtr =/= 0.U) {
		when (opChain(0) === 0.U) {
			when (is_load_op1) {
				Vector1 := io.in.bits.op1
			}
			when (is_load_op2) {
				Vector2 := io.in.bits.op2
			}
			opPtr := opPtr - 1.U
			opChain := opChain >> 1.U
		}.elsewhen (opChain(0) === 1.U && io.out.ready) {
			when (is_mul) {
					io.out.valid := true.B
					for (i <- 0 until 16) { // 修改为16，确保所有元素都被初始化
							// 将Vector1的一个元素乘以Vector2中的所有元素，结果存入thread_rst
							io.out.bits.thread_rst(i) := Vector1(opChain(0).asUInt) * Vector2(i)
					}
			}
			opPtr := opPtr - 1.U
			opChain := opChain >> 1.U
		}
  }
}


