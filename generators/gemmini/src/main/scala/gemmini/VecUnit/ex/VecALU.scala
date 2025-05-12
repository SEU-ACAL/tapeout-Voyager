package gemmini.VecUnit.ex

import chisel3._
import chisel3.util._
import chisel3.stage._
import gemmini.VecUnit.VecConfig

class thread_input extends Bundle {
  val op1       = Vec(16, UInt(8.W))
  val op2       = Vec(16, UInt(8.W))
  val config    = UInt(16.W)
  val iteration = UInt(4.W) // 从0开始，循环1~16次
  val thread_id = UInt(4.W)
  val rob_id    = UInt(5.W)
  val funct     = UInt(8.W)
  val waddr     = UInt(14.W)
}

class thread_output extends Bundle {
  val vector_rst = Vec(16, UInt(8.W))
  val scalar_rst = UInt(8.W)
  val thread_id  = UInt(4.W)
  val config     = UInt(16.W)
  val rob_id     = UInt(5.W)
}

class VecALUThread  extends Module {
	val io = IO(new Bundle {
		val in  = Flipped(Decoupled(new thread_input()))
		val out = Decoupled(new thread_output())
  })

  val Vector1   = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val Vector2   = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
  val config    = RegInit(0.U(16.W))
  val iteration = RegInit(0.U(4.W))
  val thread_id = RegInit(0.U(4.W))
  val rob_id    = RegInit(0.U(5.W))

  val Array(wr_op1, wr_op2, op1_is_scalar, op2_is_scalar,
						is_mul, is_add,	is_max, is_div, is_lut,
						is_int32, is_int16,
						tc_en, reduce, op_en, rd_acc, wr_acc) = 
  (0 until 16).map(i => Mux(io.in.valid, io.in.bits.config(i), config(i))).toArray

  val thread_busy = RegInit(false.B)
  val thread_iteration = RegInit(0.U(4.W))
  io.in.ready := !thread_busy

// -----------------------------------------------------------------------------
// Load Operands
// -----------------------------------------------------------------------------
	when (iteration === thread_iteration) {
		iteration := 0.U
		thread_busy := false.B
	}	
	when (io.in.valid) {
		Vector1 	:= Mux(wr_op1, io.in.bits.op1, Vector1)
		Vector2 	:= Mux(wr_op2, io.in.bits.op2, Vector2)
		config		:= io.in.bits.config
		iteration := 0.U
		thread_id := io.in.bits.thread_id
		rob_id		:= io.in.bits.rob_id
		thread_busy := true.B
		thread_iteration := io.in.bits.iteration
	}

	// shit


// -----------------------------------------------------------------------------
// Execute Micro Operation
// -----------------------------------------------------------------------------
	val vector_rst = WireInit(VecInit(Seq.fill(16)(0.U(8.W))))
	val scalar_rst = WireInit(0.U(8.W))

  when (thread_busy) {
			// 将Vector1的一个元素乘以Vector2中的所有元素，结果存入vector_rst
		when (is_mul) {
			vector_rst := VecInit(Vector2.map(_ * Vector1(iteration)))
		}
		when (is_max) {
			when (iteration === 2.U) {
				scalar_rst:= Vector2.reduce((acc, elem) => Mux(acc > elem, acc, elem))
			}.elsewhen (iteration === 1.U) {
				scalar_rst:= Vector1.reduce((acc, elem) => Mux(acc > elem, acc, elem))
			}
		}
		when (is_div) {
			vector_rst := VecInit(Vector2.map(_ / Vector1(0)))
		}
		iteration := iteration + 1.U
		io.out.valid := true.B
	}.otherwise {
		io.out.valid := false.B
	}
	io.out.bits.thread_id  := Mux(io.out.valid, thread_id, 0.U(3.W))
	io.out.bits.config 		 := Mux(io.out.valid, config, 0.U(16.W))
	io.out.bits.vector_rst := Mux(io.out.valid, vector_rst, VecInit(Seq.fill(16)(0.U(8.W))))
	io.out.bits.scalar_rst := Mux(io.out.valid, scalar_rst, 0.U(8.W))
	io.out.bits.rob_id 		 := Mux(io.out.valid, rob_id, 0.U(5.W))
}
