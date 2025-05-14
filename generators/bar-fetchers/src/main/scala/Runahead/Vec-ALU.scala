package barf

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.{Field, Parameters}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.util._
import freechips.rocketchip.tile._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.rocket.ALU._


abstract class AbstractALU(implicit p: Parameters) extends CoreModule()(p) {}

class ALUSlice(implicit p: Parameters)extends AbstractALU() {
  val io = IO(new Bundle {
    val fn =  Input(UInt(SZ_ALU_FN.W))
    val in2 = Input(UInt(xLen.W))
    val in1 = Input(UInt(xLen.W))
    val out = Output(UInt(xLen.W))
    val adder_out = Output(UInt(xLen.W))
    val cmp_out = Output(Bool())
  })
  // ADD, SUB
  val in2_inv = Mux(isSub(io.fn), ~io.in2, io.in2)
  val in1_xor_in2 = io.in1 ^ in2_inv
  io.adder_out := io.in1 + in2_inv + isSub(io.fn)

  // SLT, SLTU
  val slt =
    Mux(io.in1(xLen-1) === io.in2(xLen-1), io.adder_out(xLen-1),
    Mux(cmpUnsigned(io.fn), io.in2(xLen-1), io.in1(xLen-1)))
  io.cmp_out := cmpInverted(io.fn) ^ Mux(cmpEq(io.fn), in1_xor_in2 === 0.U, slt)

  // SLL, SRL, SRA
  val (shamt, shin_r) =
    if (xLen == 32) (io.in2(4,0), io.in1)
    else {
      require(xLen == 64)
      val shin_hi_32 = Fill(32, isSub(io.fn) && io.in1(31))
      val shin_hi = io.in1(63,32)
      val shamt = Cat(io.in2(5), io.in2(4,0))
      (shamt, Cat(shin_hi, io.in1(31,0)))
    }
  val shin = Mux(io.fn === FN_SR  || io.fn === FN_SRA, shin_r, Reverse(shin_r))
  val shout_r = (Cat(isSub(io.fn) & shin(xLen-1), shin).asSInt >> shamt)(xLen-1,0)
  val shout_l = Reverse(shout_r)
  val shout = Mux(io.fn === FN_SR || io.fn === FN_SRA, shout_r, 0.U) |
              Mux(io.fn === FN_SL,                           shout_l, 0.U)

  // AND, OR, XOR
  val logic = Mux(io.fn === FN_XOR || io.fn === FN_OR, in1_xor_in2, 0.U) |
              Mux(io.fn === FN_OR || io.fn === FN_AND, io.in1 & io.in2, 0.U)
  val shift_logic = (isCmp(io.fn) && slt) | logic | shout
  val out = Mux(io.fn === FN_ADD || io.fn === FN_SUB, io.adder_out, shift_logic)

  io.out := out
}

class ALUCluster(params:VectorizerParams)(implicit p: Parameters)extends AbstractALU()(p){
    val io = IO(new Bundle {
        val fn =  Input(UInt(SZ_ALU_FN.W))
        val in1 = Input(UInt(params.VecBitWidth.W))
        val in2 = Input(UInt(params.VecBitWidth.W))
        val out = Output(UInt(params.VecBitWidth.W))
    })

    def unpack(data:UInt, i:Int):UInt = {
			val elemWidth = 64
			val startBit = i * elemWidth
			val endBit = (i + 1) * elemWidth - 1
			if (endBit < params.VecBitWidth) {
				data(endBit, startBit)
			} else {
				0.U(elemWidth.W)
  		}
    }

    val alus = (0 until params.nVecLanes) map { i =>
			val alu = Module(new ALUSlice())
			alu.io.fn := io.fn
			alu.io.in1 := unpack(io.in1, i)
			alu.io.in2 := unpack(io.in2, i)
			alu.io.out
  	}

		val pack = Wire(UInt(params.VecBitWidth.W))
		for (i <- 0 until params.nVecLanes) {
			val elemWidth = 64
			val startBit = i * elemWidth
			val endBit = (i + 1) * elemWidth - 1
			pack(endBit, startBit) := alus(i)
		}
		io.out := pack
}