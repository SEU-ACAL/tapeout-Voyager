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
  
  val mask_len = (w / (aligned_to * 8)) max 1
  val mask_elem = UInt((w min (aligned_to * 8)).W)

  val io = IO(new Bundle {
    val read = Flipped(new SramReadIO(n, w))
    val write = Flipped(new SramWriteIO(n, w, mask_len))
  })

  val mem = SyncReadMem(n, Vec(mask_len, mask_elem))

  // 写入逻辑
  when (io.write.en) {
    if (aligned_to >= w)
      mem.write(io.write.addr, io.write.data.asTypeOf(Vec(mask_len, mask_elem)), 
        VecInit((~(0.U(mask_len.W))).asBools))
    else
      mem.write(io.write.addr, io.write.data.asTypeOf(Vec(mask_len, mask_elem)), io.write.mask)
  }

  // 读取逻辑
  val raddr = io.read.req.bits.addr
  val ren = io.read.req.fire
  val rdata = mem.read(raddr, ren).asUInt
  val fromDMA = io.read.req.bits.fromDMA

  // 缓冲读取结果的队列
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
  val acc = Output(Bool())
}

class AccBank(n: Int, w: Int, aligned_to: Int, single_ported: Boolean) extends Module {
  require(w % aligned_to == 0 || w < aligned_to)
  
  val mask_len = (w / (aligned_to * 8)) max 1
  val mask_elem = UInt((w min (aligned_to * 8)).W)

  val io = IO(new Bundle {
    val read = Flipped(new SramReadIO(n, w))
    val write = Flipped(new AccWriteIO(n, w, mask_len))
  })

  val mem = SyncReadMem(n, Vec(mask_len, mask_elem))

  // 简化的累加器流水线
  val s1_valid = RegNext(io.write.en)
  val s1_addr = RegEnable(io.write.addr, io.write.en)
  val s1_data = RegEnable(io.write.data, io.write.en)
  val s1_acc = RegEnable(io.write.acc, io.write.en)
  val s1_mask = RegEnable(io.write.mask, io.write.en)

  // 读取逻辑：优先处理写入的读取
  val raddr = Mux(s1_valid, s1_addr, io.read.req.bits.addr)
  val ren = io.read.req.fire || s1_valid
  val fromDMA = io.read.req.bits.fromDMA
  val rdata = mem.read(raddr, ren).asUInt

  // 第二级：累加计算
  val s2_valid = RegNext(s1_valid)
  val s2_addr = RegEnable(s1_addr, s1_valid)
  val s2_data = RegEnable(Mux(s1_acc, s1_data + rdata, s1_data), s1_valid)
  val s2_mask = RegEnable(s1_mask, s1_valid)

  // 第三级：写入
  val s3_valid = RegNext(s2_valid)
  val s3_addr = RegEnable(s2_addr, s2_valid)
  val s3_data = RegEnable(s2_data, s2_valid)
  val s3_mask = RegEnable(s2_mask, s2_valid)

  // 写入逻辑
  when (s3_valid) {
    if (aligned_to >= w)
      mem.write(s3_addr, s3_data.asTypeOf(Vec(mask_len, mask_elem)), 
        VecInit((~(0.U(mask_len.W))).asBools))
    else
      mem.write(s3_addr, s3_data.asTypeOf(Vec(mask_len, mask_elem)), s3_mask)
  }

  // 读取响应
  assert(!(s1_valid && io.read.req.fire), "AccBank: Read and write requests cannot be issued simultaneously")
  
  io.read.resp.valid := RegNext(ren)
  io.read.resp.bits.data := rdata
  io.read.resp.bits.fromDMA := RegNext(fromDMA)
  io.read.req.ready := true.B
}
