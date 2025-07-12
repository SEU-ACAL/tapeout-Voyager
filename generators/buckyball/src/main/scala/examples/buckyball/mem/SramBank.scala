package buckyball.mem

import chisel3._
import chisel3.util._

import buckyball.util.Util._

class SramReadReq(val n: Int) extends Bundle {
  val addr = UInt(log2Ceil(n).W)
  val fromDMA = Bool()
}

class SramReadResp(val w: Int) extends Bundle {
  val data = UInt(w.W)
  val fromDMA = Bool()
}

class SramReadIO(val n: Int, val w: Int) extends Bundle {
  val req = Decoupled(new SramReadReq(n))
  val resp = Flipped(Decoupled(new SramReadResp(w)))
}

class SramWriteIO(val n: Int, val w: Int, val mask_len: Int) extends Bundle {
  val en = Output(Bool())
  val addr = Output(UInt(log2Ceil(n).W))
  val mask = Output(Vec(mask_len, Bool()))
  val data = Output(UInt(w.W))
}

class SramBank(n: Int, w: Int, aligned_to: Int, single_ported: Boolean) extends Module {
  
  require(w % aligned_to == 0 || w < aligned_to)
  
  // single_ported参数表示此SRAM bank的期望使用模式
  // true: 单端口模式，支持同时读写，但读写地址可能不同
  // false: 多端口模式，支持多个并发读取（在外部仲裁）
  // 注意：Chisel的SyncReadMem本身支持同时读写
  
  val mask_len = (w / (aligned_to * 8)) max 1 // How many mask bits are there?
  val mask_elem = UInt((w min (aligned_to * 8)).W) // What datatype does each mask bit correspond to?

  val io = IO(new Bundle {
    val read = Flipped(new SramReadIO(n, w))
    val write = Flipped(new SramWriteIO(n, w, mask_len))
  })

  // Local memory
  val mem = SyncReadMem(n, Vec(mask_len, mask_elem))
  assert(!(io.write.en && io.read.req.fire), "SramBank: Read and write requests cannot be issued simultaneously")
  // Write logic
  when (io.write.en) {
    if (aligned_to >= w)
      mem.write(io.write.addr, io.write.data.asTypeOf(Vec(mask_len, mask_elem)), VecInit((~(0.U(mask_len.W))).asBools))
    else
      mem.write(io.write.addr, io.write.data.asTypeOf(Vec(mask_len, mask_elem)), io.write.mask)
  }

  // Read logic
  val raddr = io.read.req.bits.addr
  val ren = io.read.req.fire
  val rdata = mem.read(raddr, ren).asUInt
  val fromDMA = io.read.req.bits.fromDMA

  // Make a queue which buffers the result of an SRAM read if it can't immediately be consumed
  val q = Module(new Queue(new SramReadResp(w), 1, true, true))
  q.io.enq.valid := RegNext(ren)
  q.io.enq.bits.data := rdata
  q.io.enq.bits.fromDMA := RegNext(fromDMA)

  io.read.req.ready := true.B
  io.read.resp <> q.io.deq
}

class AccWriteIO(val n: Int, val w: Int, val mask_len: Int) extends Bundle {
  val en = Output(Bool())
  val addr = Output(UInt(log2Ceil(n).W))
  val mask = Output(Vec(mask_len, Bool()))
  val data = Output(UInt(w.W))
  val acc  = Output(Bool()) 
  //val fastwrite = Output(Bool()) // 是否使用快速写入模式
  //val endfastwrite = Output(Bool()) // 是否结束快速写入模式
}

class AccBank(n: Int, w: Int, aligned_to: Int, single_ported: Boolean) extends Module {
  
  require(w % aligned_to == 0 || w < aligned_to)
  
  // single_ported参数表示此SRAM bank的期望使用模式
  // true: 单端口模式，支持同时读写，但读写地址可能不同
  // false: 多端口模式，支持多个并发读取（在外部仲裁）
  // 注意：Chisel的SyncReadMem本身支持同时读写
  
  val mask_len = (w / (aligned_to * 8)) max 1 // How many mask bits are there?
  val mask_elem = UInt((w min (aligned_to * 8)).W) // What datatype does each mask bit correspond to?

  val io = IO(new Bundle {
    val read = Flipped(new SramReadIO(n, w))
    val write = Flipped(new AccWriteIO(n, w, mask_len))
  })



  //S1: Read request
  val s1_addr = RegEnable(io.write.addr, io.write.en)
  val s1_valid = RegNext(io.write.en)
  val s1_data = RegEnable(io.write.data, io.write.en)
  val s1_acc = RegEnable(io.write.acc, io.write.en)
  val s1_mask = RegEnable(io.write.mask, io.write.en)

  // Local memory
  val mem = SyncReadMem(n, Vec(mask_len, mask_elem))
  val raddr = Mux(io.write.en, s1_addr, io.read.req.bits.addr)
  val ren = io.read.req.fire || io.write.en
  val fromDMA = io.read.req.bits.fromDMA
  val rdata = mem.read(raddr, ren).asUInt

  //S2: Add
  val s2_addr = RegEnable(s1_addr, s1_valid)
  val s2_data = RegEnable(Mux(s1_acc, s1_data + rdata, s1_data), s1_valid)
  val s2_mask = RegEnable(s1_mask, s1_valid)
  val s2_valid = RegNext(s1_valid)
  
  //S3: Write request
  val s3_addr = RegEnable(s2_addr, s2_valid)
  val s3_data = RegEnable(s2_data, s2_valid)
  val s3_mask = RegEnable(s2_mask, s2_valid)
  val s3_valid = RegNext(s2_valid)

  assert(!((s1_addr === s2_addr) && s1_valid && s2_valid), "AccBank: Data cannot be written to the same address consecutively, please consider using fastwrite mode.")
  // Write logic
  when (s3_valid) {
    if (aligned_to >= w)
      mem.write(s3_addr, s3_data.asTypeOf(Vec(mask_len, mask_elem)), VecInit((~(0.U(mask_len.W))).asBools))
    else
      mem.write(s3_addr, s3_data.asTypeOf(Vec(mask_len, mask_elem)), s3_mask)
  }

  // Read logic
  assert(!(s1_valid && io.read.req.fire), "AccBank: Read and write requests cannot be issued simultaneously")
  
  // Make a queue which buffers the result of an SRAM read if it can't immediately be consumed
  
  io.read.resp.valid := RegNext(ren)
  io.read.resp.bits.data := rdata
  io.read.resp.bits.fromDMA := RegNext(fromDMA)

  io.read.req.ready := true.B

}
