package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._

class thread_input extends Bundle {
  val op1       = Vec(16, UInt(8.W))
  val op2       = Vec(16, UInt(8.W))
  val config    = UInt(13.W)
  val iteration = UInt(4.W) // 从0开始，循环1~16次
  val thread_id = UInt(3.W)
  val rob_id    = UInt(5.W)
}

class thread_output extends Bundle {
  val thread_rst = Vec(16, UInt(8.W))
  val thread_id  = UInt(3.W)
  val config     = UInt(13.W)
  val rob_id     = UInt(5.W)
}

class VecALUThread (val OpChainDepth: Int = 32) extends Module {
		val io = IO(new Bundle {
		val in  = Flipped(Decoupled(new thread_input()))
		val out = Decoupled(new thread_output())
  })

  val Vector1 = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val Vector2 = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val config  = RegInit(0.U(13.W))
  val iteration = RegInit(0.U(4.W))
  val thread_id = RegInit(0.U(3.W))
  val rob_id    = RegInit(0.U(5.W))

  config    := Mux(io.in.valid, io.in.bits.config, config)
  iteration := Mux(io.in.valid, io.in.bits.iteration, iteration)
  thread_id := Mux(io.in.valid, io.in.bits.thread_id, thread_id)
  rob_id    := Mux(io.in.valid, io.in.bits.rob_id, rob_id)
	
  val Array(wr_op1, wr_op2, op1_is_scalar, op2_is_scalar,
						is_mul, is_add,	is_int32, is_int16,
						tc_en, reduce, op_en, rd_acc, wr_acc) = 
  (0 until 13).map(i => Mux(io.in.valid, io.in.bits.config(i), config(i))).toArray
// -----------------------------------------------------------------------------
// Generate Micro Operation Chain
// load = 0, compute = 1, ptr是队尾指针
// -----------------------------------------------------------------------------
  val opChain = dontTouch(RegInit(0.U(OpChainDepth.W)))
  val opPtr 	= dontTouch(RegInit(0.U(log2Ceil(OpChainDepth).W)))

  val thread_busy = opPtr =/= 0.U
  io.in.ready := !thread_busy

	val wr_op1_reg = dontTouch(RegInit(false.B))
	val wr_op2_reg = dontTouch(RegInit(false.B))
	val is_mul_reg = dontTouch(RegInit(false.B))

	wr_op1_reg := wr_op1 
	wr_op2_reg := wr_op2
	is_mul_reg := is_mul

  // 入队
  when (io.in.valid && io.in.ready) {
		// when (wr_op1 || wr_op2) {
		// 	opPtr := opPtr + 1.U
		// 	opChain := opChain.bitSet(opPtr, false.B) 
		// }
		// when (is_mul) {
		// 	opPtr := opPtr + io.in.bits.iteration + 1.U
		// 	// 添加io.in.bits.iteration + 1.U位的1
		// 	for (i <- 0 until OpChainDepth) {
		// 		when (i.U >= opPtr && i.U < (opPtr + io.in.bits.iteration + 1.U)) {
		// 			opChain := opChain.bitSet(i.U, true.B)
		// 		}
		// 	}
		// }
			when (is_mul) {
				when (wr_op1 || wr_op2) {
					opChain := "b0000_0000_0000_0001_1111_1111_1111_1110".U
					opPtr 	:= opPtr + io.in.bits.iteration + 1.U + 1.U
				}.otherwise {
					opChain := "b0000_0000_0000_0000_1111_1111_1111_1111".U
					opPtr 	:= opPtr + io.in.bits.iteration + 1.U
				}
			}
		}
// -----------------------------------------------------------------------------
// Execute Micro Operation Chain
// -----------------------------------------------------------------------------
	val thread_rst = WireInit(VecInit(Seq.fill(16)(0.	U(8.W))))
	
	// 出队
  io.out.valid 					 := false.B
  io.out.bits.thread_id  := Mux(io.out.valid, thread_id, 0.U(3.W))
  io.out.bits.config 		 := Mux(io.out.valid, config, 0.U(13.W))
  io.out.bits.thread_rst := Mux(io.out.valid, thread_rst, VecInit(Seq.fill(16)(0.U(8.W))))
  io.out.bits.rob_id 		 := Mux(io.out.valid, rob_id, 0.U(5.W))

  when (thread_busy || io.in.valid) {
		// TODO:钻了空子
		Vector1 := Mux(io.in.valid && wr_op1, io.in.bits.op1, Vector1)
		Vector2 := Mux(io.in.valid && wr_op2, io.in.bits.op2, Vector2)

		when (opChain(0) === 0.U && !io.in.valid) {
			// Vector1 := Mux(wr_op1, io.in.bits.op1, Vector1)
			// Vector2 := Mux(wr_op2, io.in.bits.op2, Vector2)
			opPtr 	:= opPtr - 1.U
			opChain := opChain >> 1.U
		}.elsewhen (opChain(0) === 1.U && io.out.ready) {
			when (is_mul) {
					val vec1 = dontTouch(Wire(UInt(8.W)))
					vec1 := Vector1(opPtr)
				for (i <- 0 until 16) {
					// 将Vector1的一个元素乘以Vector2中的所有元素，结果存入thread_rst
					thread_rst(i):= vec1 * Vector2(i)
					// io.out.bits.thread_rst(i) := Vector1(opPtr) * Vector2(i)
				}
			}
			io.out.valid := true.B
			opPtr 	:= opPtr - 1.U
			opChain := opChain >> 1.U
		}
  }


}


