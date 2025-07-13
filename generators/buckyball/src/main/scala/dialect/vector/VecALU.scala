package dialect.vector

import chisel3._
import chisel3.util._
import chisel3.stage._
import buckyball.BuckyBallConfig

class north(implicit bbconfig: BuckyBallConfig)  extends Bundle {
  val config     = UInt(16.W) 
  val vector_rst = Vec(bbconfig.numVecPE, UInt(bbconfig.accType.getWidth.W))
}

class east(implicit bbconfig: BuckyBallConfig) extends Bundle {
  val funct     = UInt(8.W)
  val waddr     = UInt(14.W)
  val vector_rst = Vec(bbconfig.numVecPE, UInt(bbconfig.accType.getWidth.W))
}

class PE(implicit bbconfig: BuckyBallConfig) extends Module {
  val io = IO(new Bundle {
    val north = Flipped(Decoupled(new north()))
    val west = Flipped(Decoupled(new east()))
    val east = Decoupled(new east())
  })

  val vector_reg = RegInit(VecInit(Seq.fill(bbconfig.numVecPE)(0.U(bbconfig.accType.getWidth.W))))
  val funct_reg = RegInit(0.U(8.W))
  val waddr_reg = RegInit(0.U(14.W))

  when (io.west.fire) {
    vector_reg := io.west.bits.vector_rst
    funct_reg := io.west.bits.funct
    waddr_reg := io.west.bits.waddr
  }

  io.west.ready  := io.east.ready
  io.north.ready := io.east.ready

  io.east.valid      := io.north.valid
  io.east.bits.funct := funct_reg
  io.east.bits.waddr := waddr_reg

  for (i <- 0 until 16) {
    io.east.bits.vector_rst(i) := vector_reg(i) + io.north.bits.vector_rst(i)
  }
}
