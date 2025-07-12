package buckyball.mem

import chisel3._
import chisel3.util._

import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.diplomacy.{IdRange, LazyModule, LazyModuleImp}
import freechips.rocketchip.tile.{CoreBundle, HasCoreParameters}
import freechips.rocketchip.tilelink._
import freechips.rocketchip.rocket.MStatus
import freechips.rocketchip.rocket.constants.MemoryOpConstants

import buckyball.util.Util._
import buckyball.frontend.FrontendTLBIO
import buckyball.mem.LocalAddr

import midas.targetutils.PerfCounter
import midas.targetutils.SynthesizePrintf

class SimpleReadRequest()(implicit p: Parameters) extends CoreBundle {
  val vaddr = UInt(coreMaxAddrBits.W)
  val len = UInt(16.W) // 读取长度（字节）
  val status = new MStatus
}

class SimpleReadResponse(dataWidth: Int) extends Bundle {
  val data = UInt(dataWidth.W)
  val last = Bool()
  val addrcounter = UInt(10.W)
}

class SimpleWriteRequest(dataWidth: Int)(implicit p: Parameters) extends CoreBundle {
  val vaddr = UInt(coreMaxAddrBits.W)
  val data = UInt(dataWidth.W)
  val len = UInt(16.W) // 写入长度（字节）
  val mask = UInt((dataWidth / 8).W) // 字节mask
  val status = new MStatus
}

class SimpleWriteResponse extends Bundle {
  val done = Bool()
}

class SimpleStreamReader(nXacts: Int, beatBits: Int, maxBytes: Int, dataWidth: Int)
                        (implicit p: Parameters) extends LazyModule {
  val node = TLClientNode(Seq(TLMasterPortParameters.v1(Seq(TLClientParameters(
    name = "buckyball-stream-reader", sourceId = IdRange(0, nXacts))))))

  lazy val module = new Impl
  class Impl extends LazyModuleImp(this) with HasCoreParameters with MemoryOpConstants {
    val (tl, edge) = node.out(0)
    val beatBytes = beatBits / 8

    val io = IO(new Bundle {
      val req = Flipped(Decoupled(new SimpleReadRequest()))
      val resp = Decoupled(new SimpleReadResponse(dataWidth))
      val tlb = new FrontendTLBIO
      val busy = Output(Bool())
      val flush = Input(Bool())
    })

    val s_idle :: s_req_block :: Nil = Enum(2)
    val state = RegInit(s_idle)

    val req = Reg(new SimpleReadRequest())
    val bytesRequested = Reg(UInt(16.W))
    val bytesReceived = Reg(UInt(16.W))
    val bytesLeft = req.len - bytesRequested

    // 简化读取大小计算
    val read_size = minOf(beatBytes.U, bytesLeft)
    val read_vaddr = req.vaddr + bytesRequested

    // Transaction ID 管理
    val xactBusy = RegInit(0.U(nXacts.W))
    val xactOnehot = PriorityEncoderOH(~xactBusy)
    val xactId = OHToUInt(xactOnehot)

    val xactBusy_fire = WireInit(false.B)
    val xactBusy_add = Mux(xactBusy_fire, (1.U << xactId).asUInt, 0.U)
    val xactBusy_remove = ~Mux(tl.d.fire, (1.U << tl.d.bits.source).asUInt, 0.U)
    xactBusy := (xactBusy | xactBusy_add) & xactBusy_remove.asUInt

    // TileLink 请求构造
    val get = edge.Get(
      fromSource = xactId,
      toAddress = 0.U,
      lgSize = log2Ceil(beatBytes).U
    )._2

    // TLB 处理管道
    class TLBundleAWithInfo extends Bundle {
      val tl_a = tl.a.bits.cloneType
      val vaddr = Output(UInt(vaddrBits.W))
      val status = Output(new MStatus)
    }

    val untranslated_a = Wire(Decoupled(new TLBundleAWithInfo))
    xactBusy_fire := untranslated_a.fire && state === s_req_block
    untranslated_a.valid := state === s_req_block && !xactBusy.andR
    untranslated_a.bits.tl_a := get
    untranslated_a.bits.vaddr := read_vaddr
    untranslated_a.bits.status := req.status

    // 简化TLB处理
    val tlb_q = Module(new Queue(new TLBundleAWithInfo, 1, pipe=true))
    tlb_q.io.enq <> untranslated_a

    io.tlb.req.valid := tlb_q.io.deq.fire
    io.tlb.req.bits := DontCare
    io.tlb.req.bits.tlb_req.vaddr := tlb_q.io.deq.bits.vaddr
    io.tlb.req.bits.tlb_req.passthrough := false.B
    io.tlb.req.bits.tlb_req.size := 0.U
    io.tlb.req.bits.tlb_req.cmd := M_XRD
    io.tlb.req.bits.status := tlb_q.io.deq.bits.status

    val translate_q = Module(new Queue(new TLBundleAWithInfo, 1, pipe=true))
    translate_q.io.enq <> tlb_q.io.deq
    translate_q.io.deq.ready := tl.a.ready || io.tlb.resp.miss

    // TileLink 连接
    tl.a.valid := translate_q.io.deq.valid && !io.tlb.resp.miss
    tl.a.bits := translate_q.io.deq.bits.tl_a
    tl.a.bits.address := io.tlb.resp.paddr

    // 简化迭代计数器管理
    val iter_counter = RegInit(0.U(10.W))
    val iter_table = RegInit(VecInit(Seq.fill(16)(0.U(10.W))))
    
    when (tl.a.fire) {
      iter_counter := iter_counter + 1.U
      iter_table(tl.a.bits.source) := iter_counter
    }

    // 响应处理
    io.resp.valid := tl.d.valid
    io.resp.bits.data := tl.d.bits.data
    io.resp.bits.addrcounter := iter_table(tl.d.bits.source)
    io.resp.bits.last := edge.last(tl.d) && (bytesReceived + beatBytes.U >= req.len)
    tl.d.ready := io.resp.ready
    
    when (tl.d.fire) {
      bytesReceived := bytesReceived + beatBytes.U
    }

    // 状态机
    io.req.ready := state === s_idle
    io.busy := xactBusy.orR || (state =/= s_idle)

    when (io.req.fire) {
      req := io.req.bits
      bytesRequested := 0.U
      bytesReceived := 0.U
      iter_counter := 0.U
      state := s_req_block
    }

    when (untranslated_a.fire) {
      bytesRequested := bytesRequested + read_size
      when (bytesRequested + read_size >= req.len) {
        state := s_idle
      }.otherwise {
        state := s_req_block
      }
    }
  }
}

class SimpleStreamWriter(nXacts: Int, beatBits: Int, maxBytes: Int, dataWidth: Int)
                        (implicit p: Parameters) extends LazyModule {
  val node = TLClientNode(Seq(TLMasterPortParameters.v1(Seq(TLClientParameters(
    name = "buckyball-stream-writer", sourceId = IdRange(0, nXacts))))))

  lazy val module = new Impl
  class Impl extends LazyModuleImp(this) with HasCoreParameters with MemoryOpConstants {
    val (tl, edge) = node.out(0)
    val beatBytes = beatBits / 8

    val io = IO(new Bundle {
      val req = Flipped(Decoupled(new SimpleWriteRequest(dataWidth)))
      val resp = Decoupled(new SimpleWriteResponse)
      val tlb = new FrontendTLBIO
      val busy = Output(Bool())
      val flush = Input(Bool())
    })

    val s_idle :: s_writing :: Nil = Enum(2)
    val state = RegInit(s_idle)

    val req = Reg(new SimpleWriteRequest(dataWidth))

    val xactBusy = RegInit(0.U(nXacts.W))
    val xactOnehot = PriorityEncoderOH(~xactBusy)
    val xactId = OHToUInt(xactOnehot)

    val xactBusy_fire = WireInit(false.B)
    val xactBusy_add = Mux(xactBusy_fire, (1.U << xactId).asUInt, 0.U)
    val xactBusy_remove = ~Mux(tl.d.fire, (1.U << tl.d.bits.source).asUInt, 0.U)
    xactBusy := (xactBusy | xactBusy_add) & xactBusy_remove.asUInt

    // 简化Put请求生成
    val lg_beat_bytes = log2Ceil(beatBytes)
    val use_put_full = req.mask === ~0.U(beatBytes.W)
    
    val putFull = edge.Put(
      fromSource = xactId,
      toAddress = 0.U,
      lgSize = lg_beat_bytes.U,
      data = req.data
    )._2
    
    val putPartial = edge.Put(
      fromSource = xactId,
      toAddress = 0.U,
      lgSize = lg_beat_bytes.U,
      data = req.data,
      mask = req.mask
    )._2
    
    val selected_put = Mux(use_put_full, putFull, putPartial)

    // TLB 处理管道
    class TLBundleAWithInfo extends Bundle {
      val tl_a = tl.a.bits.cloneType
      val vaddr = Output(UInt(vaddrBits.W))
      val status = Output(new MStatus)
    }

    val untranslated_a = Wire(Decoupled(new TLBundleAWithInfo))
    xactBusy_fire := untranslated_a.fire
    untranslated_a.valid := state === s_writing && !xactBusy.andR
    untranslated_a.bits.tl_a := selected_put
    untranslated_a.bits.vaddr := req.vaddr
    untranslated_a.bits.status := req.status

    val tlb_q = Module(new Queue(new TLBundleAWithInfo, 1, pipe=true))
    tlb_q.io.enq <> untranslated_a

    io.tlb.req.valid := tlb_q.io.deq.valid
    io.tlb.req.bits := DontCare
    io.tlb.req.bits.tlb_req.vaddr := tlb_q.io.deq.bits.vaddr
    io.tlb.req.bits.tlb_req.passthrough := false.B
    io.tlb.req.bits.tlb_req.size := 0.U
    io.tlb.req.bits.tlb_req.cmd := M_XWR
    io.tlb.req.bits.status := tlb_q.io.deq.bits.status

    val translate_q = Module(new Queue(new TLBundleAWithInfo, 1, pipe=true))
    translate_q.io.enq <> tlb_q.io.deq
    translate_q.io.deq.ready := tl.a.ready || io.tlb.resp.miss

    // TileLink 连接
    tl.a.valid := translate_q.io.deq.valid && !io.tlb.resp.miss
    tl.a.bits := translate_q.io.deq.bits.tl_a
    tl.a.bits.address := io.tlb.resp.paddr

    tl.d.ready := true.B

    // 响应处理
    io.resp.valid := tl.d.valid && edge.last(tl.d)
    io.resp.bits.done := true.B

    // 状态机
    io.req.ready := state === s_idle
    io.busy := xactBusy.orR || (state =/= s_idle)

    when (io.req.fire) {
      req := io.req.bits
      state := s_writing
    }

    when (untranslated_a.fire) {
      state := s_idle
    }
  }
}
