//===- VecThread.scala - Level 1: Thread ---===//
package dialect.vector

import chisel3._
import chisel3.util._
import chisel3.stage._
import dialect.format._
import dialect.format.ArithmeticFactory

class SupportedFuncUnits(
  val mul: Boolean    = false,
  val pop: Boolean    = false, // 弹出第一个元素
  val max: Boolean    = false,
  val square: Boolean = false, 
  val add: Boolean    = false,    
  val sub: Boolean    = false,    
  val div: Boolean    = false,    
  val vmul: Boolean   = false
)
{
  def supportedFuncNum = {
    (if (mul) 1 else 0) +
    (if (pop) 1 else 0) +
    (if (max) 1 else 0) +
    (if (square) 1 else 0) +
    (if (add) 1 else 0) +
    (if (sub) 1 else 0) +
    (if (div) 1 else 0) +
    (if (vmul) 1 else 0)
  }
}

case class ThreadParams(lane: Int = 16,
                        attr: String = "base",
                        dataFormat: DataFormatParams = DataFormatParams("INT8"),
                        Ops: SupportedFuncUnits = new SupportedFuncUnits(
                          mul    = true, 
                          pop    = false, 
                          max    = false, 
                          square = false, 
                          add    = false, 
                          sub    = false, 
                          div    = false, 
                          vmul   = false)
) {
  // 在ThreadParams中创建算术实例，供所有操作模块使用
  implicit val arith: Arithmetic[Data] = ArithmeticFactory.createArithmetic(dataFormat.dataType.cloneType)
}

// there are all combination logic in threads' Operations
// we must make sure each operation finish in one cycle
class MulOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = t.dataFormat.dataType.cloneType
      val op2 = Vec(t.lane, t.dataFormat.dataType.cloneType)
    }))
    val out = Valid(new Bundle {
      val vRst = Vec(t.lane, t.dataFormat.dataType.cloneType)
    })
  })
  io.out.valid     := io.in.valid
  io.out.bits.vRst := io.in.bits.op2.map(op2 => t.arith.mul(io.in.bits.op1, op2))
}

class PopOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = Vec(t.lane, t.dataFormat.dataType.cloneType)
    }))
    val out = Valid(new Bundle {
      val sRst = t.dataFormat.dataType.cloneType
      val vRst = Vec(t.lane-1, t.dataFormat.dataType.cloneType) // 写回op1
    })
  })
  io.out.valid     := io.in.valid
  io.out.bits.sRst := io.in.bits.op1(0)
  io.out.bits.vRst := io.in.bits.op1.tail
}

class MaxOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = Vec(t.lane, t.dataFormat.dataType.cloneType)
    }))
    val out = Valid(new Bundle {
      val sRst = t.dataFormat.dataType.cloneType
      val vRst = Vec(t.lane-1, t.dataFormat.dataType.cloneType) // 写回op1
    })
  })
  io.out.valid     := io.in.valid
  // io.out.bits.sRst := io.in.bits.op2.reduce(_ max _)
  io.out.bits.sRst := Mux(t.arith.gt(io.in.bits.op1(0), io.in.bits.op1(1)), io.in.bits.op1(0), io.in.bits.op1(1))
  io.out.bits.vRst := Mux(t.arith.gt(io.in.bits.op1(0), io.in.bits.op1(1)), 
    VecInit(io.in.bits.op1(0) +: io.in.bits.op1.drop(2)), 
    VecInit(io.in.bits.op1(1) +: io.in.bits.op1.drop(2)))
}

class SquareOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = Vec(t.lane, t.dataFormat.dataType.cloneType)
    }))
    val out = Valid(new Bundle {
      val vRst = Vec(t.lane, t.dataFormat.dataType.cloneType)
    })
  })
  io.out.valid     := io.in.valid
  io.out.bits.vRst := io.in.bits.op1.map(x => t.arith.mul(x, x))
}

class AddOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = t.dataFormat.dataType.cloneType        // scalar
      val op2 = Vec(t.lane, t.dataFormat.dataType.cloneType) // vector
    }))
    val out = Valid(new Bundle {
      val vRst = Vec(t.lane, t.dataFormat.dataType.cloneType)
    })
  })
  io.out.valid     := io.in.valid
  io.out.bits.vRst := io.in.bits.op2.map(op2 => t.arith.add(io.in.bits.op1, op2))
}

class SubOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = t.dataFormat.dataType.cloneType        // scalar
      val op2 = Vec(t.lane, t.dataFormat.dataType.cloneType) // vector
    }))
    val out = Valid(new Bundle {
      val vRst = Vec(t.lane, t.dataFormat.dataType.cloneType)
    })
  })
  io.out.valid     := io.in.valid
  io.out.bits.vRst := io.in.bits.op2.map(op2 => t.arith.sub(io.in.bits.op1, op2))  
}

class DivOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = t.dataFormat.dataType.cloneType              // scalar
      val op2 = Vec(t.lane, t.dataFormat.dataType.cloneType) // vector
    }))
    val out = Valid(new Bundle {
      val vRst = Vec(t.lane, t.dataFormat.dataType.cloneType)
    })
  })
  io.out.valid     := io.in.valid
  io.out.bits.vRst := io.in.bits.op2.map(op2 => t.arith.div(io.in.bits.op1, op2))
}

class VecMulOp (implicit t: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Valid(new Bundle {
      val op1 = Vec(t.lane, t.dataFormat.dataType.cloneType)
      val op2 = Vec(t.lane, t.dataFormat.dataType.cloneType)
    }))
    val out = Valid(new Bundle {
      val vRst = Vec(t.lane, t.dataFormat.dataType.cloneType)
    })
  })
  io.out.valid     := io.in.valid
  io.out.bits.vRst := (io.in.bits.op1 zip io.in.bits.op2).map{ case (a, b) => t.arith.mul(a, b) }
}

class tOpLoad(implicit t: ThreadParams) extends Bundle {
  val op1       = Vec(t.lane, t.dataFormat.dataType.cloneType)
  val op2       = Vec(t.lane, t.dataFormat.dataType.cloneType)
  val scalar    = t.dataFormat.dataType.cloneType
  val opcode    = UInt(8.W)
  val iter      = UInt(4.W)    // 从0开始，循环1~16次
}

class tOut(implicit t: ThreadParams) extends Bundle {
  val sRst = t.dataFormat.dataType.cloneType
  val vRst = Vec(t.lane, t.dataFormat.dataType.cloneType)
}

abstract class BaseThread(
  val hasMul           : Boolean       = false,
  val hasMax           : Boolean       = false,
  val hasPop           : Boolean       = false,
  val hasSquare        : Boolean       = false,
  val hasAdd           : Boolean       = false,
  val hasSub           : Boolean       = false,
  val hasDiv           : Boolean       = false,
  val hasVecMul        : Boolean       = false
  )(implicit p: ThreadParams) extends Module {
  val io = IO(new Bundle {
    val in  = Flipped(Decoupled(new tOpLoad()))
    val out = Decoupled(new tOut())
    // val sout = if (hasPop || hasMax) Decoupled(new tScalarOut()) else null
  })

  io.in.ready   := false.B
  io.out.valid := false.B
  // io.sout.valid := false.B

  // require (hasMul, "[VecThread] You Must Have Mul in VecThread.")

  // require ((hasPop && hasShift) || (!hasPop),
  //   "[VecThread] if you choose hasPop, you must choose hasShift at the same time.")

  def supportedFuncUnits = {
    new SupportedFuncUnits(
      mul = hasMul,
      pop = hasPop,
      max = hasMax,
      square = hasSquare,
      add = hasAdd,
      sub = hasSub,
      div = hasDiv,
      vmul = hasVecMul)
  }
}


class VecThread (implicit t: ThreadParams)
  extends BaseThread(
    hasMul           = t.Ops.mul,
    hasMax           = t.Ops.max,
    hasPop           = t.Ops.pop,
    hasSquare        = t.Ops.square,
    hasAdd           = t.Ops.add,
    hasSub           = t.Ops.sub,
    hasDiv           = t.Ops.div,
    hasVecMul        = t.Ops.vmul) 
{

//===----------------------------------------------------------------------===//
// 每个thread 配备如下寄存器和一个选择器
//===----------------------------------------------------------------------===//
  val busy      = RegInit(true.B)
  val op1       = RegInit(VecInit(Seq.fill(t.lane)(0.U(t.dataFormat.width.W))))
  val op2       = RegInit(VecInit(Seq.fill(t.lane)(0.U(t.dataFormat.width.W))))
  val scalar    = RegInit(0.U(t.dataFormat.width.W))
  val opcode    = RegInit(0.U(8.W))
  val iter      = RegInit(0.U(4.W))
  

  // val arbiter = Module(new Arbiter(UInt(8.W), supportedFuncUnits.supportedFuncNum))  



  io.in.ready := !busy
  when (io.in.fire) {
    op1       := io.in.bits.op1
    op2       := io.in.bits.op2
    scalar    := io.in.bits.scalar
    opcode    := io.in.bits.opcode
    iter      := io.in.bits.iter
    busy      := true.B
  }.otherwise {
    busy   := iter =/= 0.U
  }
//===----------------------------------------------------------------------===//
// Step 1 选择计算单元
// IDLE <-> BUSY 每个thread只有这两种状态，就先不写状态机了 
//===----------------------------------------------------------------------===//
  var mul: MulOp = null
  var pop: PopOp = null
  var max: MaxOp = null
  var square: SquareOp = null
  var add: AddOp = null
  var sub: SubOp = null
  var div: DivOp = null
  var vmul: VecMulOp = null
  
  if (hasMul) {
    mul = Module(new MulOp())
    // 默认值
    mul.io.in.valid := false.B
    mul.io.in.bits.op1 := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
    mul.io.in.bits.op2 := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
    
    when ((io.in.fire && (opcode === 1.U )) || opcode === 1.U || iter =/= 0.U) {
      mul.io.in.valid := true.B
      mul.io.in.bits.op1 := op1(iter)
      mul.io.in.bits.op2 := op2
      iter := iter - 1.U
    }
  }
  if (hasPop) {
    pop = Module(new PopOp())
    // 默认值
    pop.io.in.valid := false.B
    pop.io.in.bits.op1 := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
    
    when ((io.in.fire && (opcode === 2.U )) || opcode === 2.U || iter =/= 0.U) {
      pop.io.in.valid := true.B
      pop.io.in.bits.op1 := op1
      iter := iter - 1.U
    }
  }
  if (hasMax) {
    max = Module(new MaxOp())
    // 默认值
    max.io.in.valid := false.B
    max.io.in.bits.op1 := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
    
    when ((io.in.fire && (opcode === 3.U )) || opcode === 3.U || iter =/= 0.U) {
      max.io.in.valid := true.B
      max.io.in.bits.op1 := op1
      iter := iter - 1.U
    }
  }
  if (hasSquare) {
    square = Module(new SquareOp())
    // 默认值
    square.io.in.valid := false.B
    square.io.in.bits.op1 := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
    
    when ((io.in.fire && (opcode === 4.U )) || opcode === 4.U || iter =/= 0.U) {
      square.io.in.valid := true.B
      square.io.in.bits.op1 := op1
      iter := iter - 1.U
    }
  }
  if (hasAdd) {
    add = Module(new AddOp())
    // 默认值
    add.io.in.valid := false.B
    add.io.in.bits.op1 := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
    add.io.in.bits.op2 := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
    
    when ((io.in.fire && (opcode === 5.U )) || opcode === 5.U || iter =/= 0.U) {
      add.io.in.valid := true.B
      add.io.in.bits.op1 := scalar
      add.io.in.bits.op2 := op2
      iter := iter - 1.U
    }
  }
  if (hasSub) {
    sub = Module(new SubOp())
    // 默认值
    sub.io.in.valid := false.B
    sub.io.in.bits.op1 := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
    sub.io.in.bits.op2 := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
    
    when ((io.in.fire && (opcode === 6.U )) || opcode === 6.U || iter =/= 0.U) {
      sub.io.in.valid := true.B
      sub.io.in.bits.op1 := scalar
      sub.io.in.bits.op2 := op2
      iter := iter - 1.U
    }
  }
  if (hasDiv) {
    div = Module(new DivOp())
    // 默认值
    div.io.in.valid := false.B
    div.io.in.bits.op1 := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
    div.io.in.bits.op2 := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
    
    when ((io.in.fire && (opcode === 7.U )) || opcode === 7.U || iter =/= 0.U) {
      div.io.in.valid := true.B
      div.io.in.bits.op1 := scalar
      div.io.in.bits.op2 := op2
      iter := iter - 1.U
    }
  }
  if (hasVecMul) {
    vmul = Module(new VecMulOp())
    // 默认值
    vmul.io.in.valid := false.B
    vmul.io.in.bits.op1 := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
    vmul.io.in.bits.op2 := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
    
    when ((io.in.fire && (opcode === 8.U )) || opcode === 8.U || iter =/= 0.U) {
      vmul.io.in.valid := true.B
      vmul.io.in.bits.op1 := op1
      vmul.io.in.bits.op2 := op2
      iter := iter - 1.U
    }
  }
//===----------------------------------------------------------------------===//
// Step 2 输出/写回Op1Op2 (如需)
//===----------------------------------------------------------------------===//
  // 默认输出
  io.out.valid     := false.B
  io.out.bits.vRst := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
  io.out.bits.sRst := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
  

  
  if (hasMul) {
    when (opcode === 1.U) {
      io.out.valid     := mul.io.out.valid
      io.out.bits.vRst := mul.io.out.bits.vRst
      io.out.bits.sRst := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
    }
  }
  if (hasPop) {
    when (opcode === 2.U) {
      op1 := VecInit(pop.io.out.bits.vRst :+ 0.U.asTypeOf(t.dataFormat.dataType.cloneType))
      
      io.out.valid     := pop.io.out.valid
      io.out.bits.vRst := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
      io.out.bits.sRst := pop.io.out.bits.sRst
    }
  } 
  if (hasMax) {
    when (opcode === 3.U) {
      op1 := VecInit(max.io.out.bits.vRst :+ 0.U.asTypeOf(t.dataFormat.dataType.cloneType))
      
      io.out.valid     := max.io.out.valid
      io.out.bits.vRst := VecInit(Seq.fill(t.lane)(0.U.asTypeOf(t.dataFormat.dataType.cloneType)))
      io.out.bits.sRst := max.io.out.bits.sRst
    }
  }
  if (hasSquare) {
    when (opcode === 4.U) {
      io.out.valid     := square.io.out.valid
      io.out.bits.vRst := square.io.out.bits.vRst
      io.out.bits.sRst := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
    }
  }
  if (hasAdd) {
    when (opcode === 5.U) {
      io.out.valid     := add.io.out.valid
      io.out.bits.vRst := add.io.out.bits.vRst
      io.out.bits.sRst := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
    }
  }
  if (hasSub) {
    when (opcode === 6.U) {
      io.out.valid     := sub.io.out.valid
      io.out.bits.vRst := sub.io.out.bits.vRst
      io.out.bits.sRst := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
    }
  }
  if (hasDiv) {
    when (opcode === 7.U) {
      io.out.valid     := div.io.out.valid
      io.out.bits.vRst := div.io.out.bits.vRst
      io.out.bits.sRst := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
    }
  }
  if (hasVecMul) {
    when (opcode === 8.U) {
      io.out.valid     := vmul.io.out.valid
      io.out.bits.vRst := vmul.io.out.bits.vRst
      io.out.bits.sRst := 0.U.asTypeOf(t.dataFormat.dataType.cloneType)
    }
  }


}

