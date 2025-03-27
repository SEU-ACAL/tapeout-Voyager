package gemmini.VecUnit.ex

import chisel3._
import chisel3.util._
import chisel3.stage._

import gemmini.VecUnit.ExCmtReq

class north extends Bundle {
  val rob_id     = UInt(5.W) // 用不上
  val thread_id  = UInt(3.W) // 用不上
  val scalar_rst = UInt(8.W) // 用不上
  val config     = UInt(16.W) 
  val vector_rst = Vec(16, UInt(8.W))
}

class east extends Bundle {
  // val rob_id     = UInt(5.W)
  // val thread_id  = UInt(3.W)
  val config     = UInt(16.W)
  val vector_rst = Vec(16, UInt(8.W))
}

class PE extends Module {
  val io = IO(new Bundle {
    val north = Flipped(Decoupled(new north()))
    val west = Flipped(Decoupled(new east()))
    val east = Decoupled(new east())
  })

  val vector_reg = RegInit(VecInit(Seq.fill(16)(0.U(32.W))))
  val config_reg = RegInit(0.U(16.W))

  when (io.west.fire) {
    for (i <- 0 until 16) { vector_reg(i) := io.west.bits.vector_rst(i)}
    config_reg := io.west.bits.config
  }

  io.west.ready := io.east.ready
  io.north.ready := io.east.ready

  io.east.valid           := io.north.valid
  io.east.bits.config     := config_reg

  for (i <- 0 until 16) {
    io.east.bits.vector_rst(i) := vector_reg(i) + io.north.bits.vector_rst(i)
  }
}

class VecReduce extends Module {
  val io = IO(new Bundle {
      val in  = Vec(8, Flipped(Decoupled(new north())))
      val out = Decoupled(new ExCmtReq())
  })

  val VecQueue = Seq.fill(8)(Module(new PE()))
  val in_fire = io.in.map(_.fire)

// -----------------------------------------------------------------------------
// 连接PE
// -----------------------------------------------------------------------------
  VecQueue(0).io.west.valid           := io.in(0).valid
  VecQueue(0).io.west.bits.config     := io.in(0).bits.config
  VecQueue(0).io.west.bits.vector_rst := VecInit(Seq.fill(16)(0.U(8.W)))
  VecQueue(0).io.north <> io.in(0)
  for (i <- 1 until 8) {
    VecQueue(i).io.north <> io.in(i)
    VecQueue(i).io.west <> VecQueue(i - 1).io.east
  }
  VecQueue(7).io.east.ready := io.out.ready

// -----------------------------------------------------------------------------
// 输出
// -----------------------------------------------------------------------------
  io.out.valid := VecQueue(7).io.east.valid
  io.out.bits.wb_en   := true.B
  io.out.bits.wb_data := VecQueue(7).io.east.bits.vector_rst
  io.out.bits.wb_addr := 32.U(14.W) // TODO: 
  io.out.bits.is_acc  := VecQueue(7).io.east.bits.config(15)
  io.out.bits.rob_id  := 0.U(5.W) // TODO: 
}
