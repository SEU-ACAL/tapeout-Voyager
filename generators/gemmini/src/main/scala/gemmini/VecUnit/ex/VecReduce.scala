package gemmini.VecUnit.ex

import chisel3._
import chisel3.util._
import chisel3.stage._

import gemmini.VecUnit.ExCmtReq
import gemmini.VecUnit.IssExReq

class north  extends Bundle {
  val rob_id     = UInt(5.W) // 用不上
  val thread_id  = UInt(4.W) // 用不上
  val scalar_rst = UInt(8.W) // 用不上
  val config     = UInt(16.W) 
  val vector_rst = Vec(16, UInt(8.W))
}

class east  extends Bundle {
  // val rob_id     = UInt(5.W)
  // val thread_id  = UInt(3.W)
  val funct     = UInt(8.W)
  val waddr     = UInt(14.W)
  val vector_rst = Vec(16, UInt(8.W))
}

class PE extends Module {
  val io = IO(new Bundle {
    val north = Flipped(Decoupled(new north()))
    val west = Flipped(Decoupled(new east()))
    val east = Decoupled(new east())
  })

  val vector_reg = RegInit(VecInit(Seq.fill(16)(0.U(32.W))))
  val funct_reg = RegInit(0.U(8.W))
  val waddr_reg = RegInit(0.U(14.W))

  when (io.west.fire) {
    vector_reg := io.west.bits.vector_rst
    funct_reg := io.west.bits.funct
    waddr_reg := io.west.bits.waddr
  }

  io.west.ready := io.east.ready
  io.north.ready := io.east.ready

  io.east.valid       := io.north.valid
  io.east.bits.funct := funct_reg
  io.east.bits.waddr := waddr_reg

  for (i <- 0 until 16) {
    io.east.bits.vector_rst(i) := vector_reg(i) + io.north.bits.vector_rst(i)
  }
}


class Vec4PE() extends Module{
  val io = IO(new Bundle {
    val in  = Flipped(Decoupled(new IssExReq()))
    val west =Flipped(Decoupled(new east()))
    val east = Decoupled(new east())
    val thread_id = Input(UInt(2.W))
    val out = Decoupled(new ExCmtReq())
  })

  val VecQueue = Seq.fill(4)(Module(new PE()))
  val alu_threads = Seq.fill(4)(Module(new VecALUThread()))
  for(i <- 0 until 4){
    alu_threads(i).io.in.valid          := false.B
    alu_threads(i).io.in.bits.op1       := VecInit(Seq.fill(16)(0.U(8.W)))
    alu_threads(i).io.in.bits.op2       := VecInit(Seq.fill(16)(0.U(8.W)))
    alu_threads(i).io.in.bits.config    := 0.U(16.W) 
    alu_threads(i).io.in.bits.iteration := 0.U(4.W)
    alu_threads(i).io.in.bits.thread_id := i.U
    alu_threads(i).io.in.bits.rob_id    := 0.U(5.W)
    alu_threads(i).io.in.bits.funct     := 0.U(8.W)
    alu_threads(i).io.in.bits.waddr     := 0.U(14.W)
  }

  when(io.in.valid){
    for (i <- 0 until 4){
      when (io.thread_id === i.U) {
        alu_threads(i).io.in <> io.in
      }
    }
  }
  VecQueue(0).io.west       <> io.west
  VecQueue(0).io.north      <> alu_threads(0).io.out
  io.in.ready := true.B
  for (i <- 1 until 4) {
    VecQueue(i).io.north <> alu_threads(i).io.out
    VecQueue(i).io.west <> VecQueue(i - 1).io.east
  }
  VecQueue(3).io.east.ready := io.out.ready
  io.out.valid := VecQueue(3).io.east.valid
  io.out.bits.wb_en   := VecQueue(3).io.east.valid
  io.out.bits.wb_data := VecQueue(3).io.east.bits.vector_rst
  io.out.bits.wb_addr := VecQueue(3).io.east.bits.waddr
  io.out.bits.is_acc  := false.B
  io.out.bits.rob_id  := 0.U(5.W) // TODO:
  io.out.bits.funct   := VecQueue(3).io.east.bits.funct

  io.east <> VecQueue(3).io.east

}

class Vec8PE extends Module{
  val io = IO(new Bundle {
    val in  = Flipped(Decoupled(new IssExReq()))
    val west =Flipped(Decoupled(new east()))
    val east = Decoupled(new east())
    val thread_id = Input(UInt(3.W))
    val out = Decoupled(new ExCmtReq())
  })

  val VecQueue = Seq.fill(8)(Module(new PE()))
  val alu_threads = Seq.fill(8)(Module(new VecALUThread()))
  for(i <- 0 until 8){
    alu_threads(i).io.in.valid          := false.B
    alu_threads(i).io.in.bits.op1       := VecInit(Seq.fill(16)(0.U(8.W)))
    alu_threads(i).io.in.bits.op2       := VecInit(Seq.fill(16)(0.U(8.W)))
    alu_threads(i).io.in.bits.config    := 0.U(16.W) 
    alu_threads(i).io.in.bits.iteration := 0.U(4.W)
    alu_threads(i).io.in.bits.thread_id := i.U
    alu_threads(i).io.in.bits.rob_id    := 0.U(5.W)
    alu_threads(i).io.in.bits.funct     := 0.U(8.W)
    alu_threads(i).io.in.bits.waddr     := 0.U(14.W)
  }
  when(io.in.valid){
    for (i <- 0 until 8){
      when (io.thread_id === i.U) {
        alu_threads(i).io.in <> io.in
      }
    }
  }
  VecQueue(0).io.west  <>  io.west
  VecQueue(0).io.north      <> alu_threads(0).io.out
  io.in.ready := true.B
  for (i <- 1 until 8) {
    VecQueue(i).io.north <> alu_threads(i).io.out
    VecQueue(i).io.west <> VecQueue(i - 1).io.east
  }
  VecQueue(7).io.east.ready := io.out.ready
  io.out.valid := VecQueue(7).io.east.valid

  io.out.bits.wb_en   := VecQueue(7).io.east.valid
  io.out.bits.wb_data := VecQueue(7).io.east.bits.vector_rst
  io.out.bits.wb_addr := VecQueue(7).io.east.bits.waddr
  io.out.bits.is_acc  := false.B
  io.out.bits.rob_id  := 0.U(5.W) 
  io.out.bits.funct   := VecQueue(7).io.east.bits.funct

  io.east <> VecQueue(7).io.east
}