//===- VecThread.scala - Level 1: Thread ---===//
package dialect.vector

import chisel3._
import chisel3.util._
import chisel3.stage._

class SupportedFuncUnits(
  val mul: Boolean = false,
  val pop: Boolean = false, // 弹出第一个元素
  val max: Boolean = false)
{
  def supportedFuncNum = {
    (if (mul) 1 else 0) +
    (if (pop) 1 else 0) +
    (if (max) 1 else 0)
  }
}

case class ThreadParams(lane: Int = 16,
                        attr: String = "base",
                        Ops: SupportedFuncUnits = new SupportedFuncUnits(mul = true, pop = false, max = false)
)

// there are all combination logic in threads' Operations
// we must make sure each operation finish in one cycle
class MulOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = UInt(8.W)
      val op2 = Vec(t.lane, UInt(8.W))
    }))
    val out = Valid(new Bundle {
      val vRst = Vec(t.lane, UInt(8.W))
    })
  })
  io.out.valid     := io.in.valid
  io.out.bits.vRst := io.in.bits.op2.map(op2 => io.in.bits.op1 * op2)
}

class PopOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = Vec(t.lane, UInt(8.W))
    }))
    val out = Valid(new Bundle {
      val sRst = UInt(8.W)
      val vRst = Vec(t.lane-1, UInt(8.W)) // 写回op1
    })
  })
  io.out.valid     := io.in.valid
  io.out.bits.sRst := io.in.bits.op1(0)
  io.out.bits.vRst := io.in.bits.op1.tail
}

class MaxOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = Vec(t.lane, UInt(8.W))
    }))
    val out = Valid(new Bundle {
      val sRst = UInt(8.W)
      val vRst = Vec(t.lane-1, UInt(8.W)) // 写回op1
    })
  })
  io.out.valid     := io.in.valid
  // io.out.bits.sRst := io.in.bits.op2.reduce(_ max _)
  io.out.bits.sRst := Mux(io.in.bits.op1(0) > io.in.bits.op1(1), io.in.bits.op1(0), io.in.bits.op1(1))
  io.out.bits.vRst := Mux(io.in.bits.op1(0) > io.in.bits.op1(1), 
    VecInit(io.in.bits.op1(0) +: io.in.bits.op1.drop(2)), 
    VecInit(io.in.bits.op1(1) +: io.in.bits.op1.drop(2)))
}



class tOpLoad extends Bundle {
  val op1       = Vec(16, UInt(8.W))
  val op2       = Vec(16, UInt(8.W))
  val opcode    = UInt(8.W)
  val iter      = UInt(9.W) // 从0开始，循环1~16次
}

class tOut extends Bundle {
  val sRst = UInt(8.W)
  val vRst = Vec(16, UInt(8.W))
}

abstract class BaseThread(
  val hasMul           : Boolean       = false,
  val hasMax           : Boolean       = false,
  val hasPop           : Boolean       = false, 
  )(implicit p: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in  = Flipped(Decoupled(new tOpLoad()))
    val out = Decoupled(new tOut())
    // val sout = if (hasPop || hasMax) Decoupled(new tScalarOut()) else null
  })

  io.in.ready   := false.B
  io.out.valid := false.B
  // io.sout.valid := false.B

  require ((hasMul),
    "[VecThread] You Must Have Mul in VecThread.")

  // require ((hasPop && hasShift) || (!hasPop),
  //   "[VecThread] if you choose hasPop, you must choose hasShift at the same time.")

  def supportedFuncUnits = {
    new SupportedFuncUnits(
      mul = hasMul,
      pop = hasPop,
      max = hasMax)
  }
}


class VecThread (implicit t: ThreadParams)
  extends BaseThread(
    hasMul           = t.Ops.mul,
    hasMax           = t.Ops.max,
    hasPop           = t.Ops.pop) 
{

//===----------------------------------------------------------------------===//
// 每个thread 配备如下寄存器和一个选择器
//===----------------------------------------------------------------------===//
  val busy  = RegInit(false.B)
  val op1   = RegInit(VecInit(Seq.fill(t.lane)(0.U(8.W))))
  val op2   = RegInit(VecInit(Seq.fill(t.lane)(0.U(8.W))))
  val opcode = RegInit(0.U(8.W))
  val iter   = RegInit(0.U(9.W))
  // val arbiter = Module(new Arbiter(UInt(8.W), supportedFuncUnits.supportedFuncNum))  

  io.in.ready := !busy
  switch(busy){
    is(true.B) {
      when (iter === 1.U) {
        busy := false.B
      }.otherwise{
        iter := iter - 1.U
      }
    }
    is(false.B) {
      when (io.in.fire) {
        op1    := io.in.bits.op1
        op2    := io.in.bits.op2
        opcode := io.in.bits.opcode
        iter   := io.in.bits.iter
        busy   := true.B
      }
    }
  }
//===----------------------------------------------------------------------===//
// Step 1 选择计算单元
// IDLE <-> BUSY 每个thread只有这两种状态，就先不写状态机了 
//===----------------------------------------------------------------------===//
  var mul: MulOp = null
  var pop: PopOp = null
  var max: MaxOp = null
  
  if (hasMul) {
    mul = Module(new MulOp())
    when (busy) {
      mul.io.in.valid := true.B
      mul.io.in.bits.op1 := op1(iter)
      mul.io.in.bits.op2 := op2
    }.otherwise {
      mul.io.in.valid := false.B
      mul.io.in.bits.op1 := 0.U
      mul.io.in.bits.op2 := VecInit(Seq.fill(t.lane)(0.U(8.W)))
    }
  }
  if (hasPop) {
    pop = Module(new PopOp())
    when ((io.in.fire && (opcode === 2.U )) || opcode === 2.U || iter =/= 0.U) {
      pop.io.in.valid := true.B
      pop.io.in.bits.op1 := op1
      iter := iter - 1.U
    }.otherwise{
      pop.io.in.valid := false.B
      pop.io.in.bits.op1 := 0.U
    }
  }
  if (hasMax) {
    max = Module(new MaxOp())
    when ((io.in.fire && (opcode === 3.U )) || opcode === 3.U || iter =/= 0.U) {
      max.io.in.valid := true.B
      max.io.in.bits.op1 := op1(iter)
      iter := iter - 1.U
    }.otherwise {
      max.io.in.valid := false.B
      max.io.in.bits.op1 := 0.U
    }
  }
//===----------------------------------------------------------------------===//
// Step 2 输出/写回Op1Op2 (如需)
//===----------------------------------------------------------------------===//
  if (hasMul) {
    io.out.valid     := mul.io.out.valid
    io.out.bits.vRst := mul.io.out.bits.vRst
    io.out.bits.sRst := 0.U
  }
  if (hasPop) {
    op1 := pop.io.out.bits.vRst

    io.out.valid     := pop.io.out.valid
    io.out.bits.vRst := VecInit(Seq.fill(t.lane)(RegInit(0.U(8.W))))
    io.out.bits.sRst := pop.io.out.bits.sRst
  } 
  if (hasMax) {
    op1 := max.io.out.bits.vRst

    io.out.valid     := max.io.out.valid
    io.out.bits.vRst := VecInit(Seq.fill(t.lane)(RegInit(0.U(8.W))))
    io.out.bits.sRst := max.io.out.bits.sRst
  }
}

