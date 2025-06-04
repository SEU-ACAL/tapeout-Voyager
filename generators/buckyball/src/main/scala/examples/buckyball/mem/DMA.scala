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

// 简化的读取请求
class SimpleReadRequest()(implicit p: Parameters) extends CoreBundle {
  val vaddr = UInt(coreMaxAddrBits.W)
  val len = UInt(16.W) // 读取长度（字节）
  val status = new MStatus
}

// 简化的读取响应
class SimpleReadResponse(dataWidth: Int) extends Bundle {
  val data = UInt(dataWidth.W)
  val last = Bool()
}

// 简化的写入请求
class SimpleWriteRequest(dataWidth: Int)(implicit p: Parameters) extends CoreBundle {
  val vaddr = UInt(coreMaxAddrBits.W)
  val data = UInt(dataWidth.W)
  val len = UInt(16.W) // 写入长度（字节）
  val status = new MStatus
}

// 简化的写入响应
class SimpleWriteResponse extends Bundle {
  val done = Bool()
}

// 简化的读取器
class SimpleStreamReader(nXacts: Int, beatBits: Int, maxBytes: Int, dataWidth: Int)
                        (implicit p: Parameters) extends LazyModule {
  val node = TLClientNode(Seq(TLMasterPortParameters.v1(Seq(TLClientParameters(
    name = "simple-stream-reader", sourceId = IdRange(0, nXacts))))))

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

    val s_idle :: s_reading :: Nil = Enum(2)
    val state = RegInit(s_idle)

    val req = Reg(new SimpleReadRequest())
    val bytesRequested = Reg(UInt(16.W))
    val bytesLeft = req.len - bytesRequested

    // 简化的读取逻辑
    val read_size = minOf(beatBytes.U, bytesLeft)
    val read_vaddr = req.vaddr + bytesRequested

    // TileLink 读取请求
    val get = edge.Get(
      fromSource = 0.U, // 简化：只用一个source ID
      toAddress = 0.U,
      lgSize = log2Ceil(beatBytes).U
    )._2

    // TLB处理
    io.tlb.req.valid := state === s_reading && tl.a.ready
    io.tlb.req.bits := DontCare
    io.tlb.req.bits.tlb_req.vaddr := read_vaddr
    io.tlb.req.bits.tlb_req.passthrough := false.B
    io.tlb.req.bits.tlb_req.size := 0.U
    io.tlb.req.bits.tlb_req.cmd := M_XRD
    io.tlb.req.bits.status := req.status

    // TileLink连接
    tl.a.valid := state === s_reading && !io.tlb.resp.miss
    tl.a.bits := get
    tl.a.bits.address := io.tlb.resp.paddr

    // 响应处理
    io.resp.valid := tl.d.valid
    io.resp.bits.data := tl.d.bits.data
    io.resp.bits.last := bytesRequested + read_size >= req.len
    tl.d.ready := io.resp.ready

    // 状态机
    io.req.ready := state === s_idle
    io.busy := state =/= s_idle

    when (io.req.fire) {
      req := io.req.bits
      bytesRequested := 0.U
      state := s_reading
    }

    when (tl.a.fire) {
      bytesRequested := bytesRequested + read_size
      when (bytesRequested + read_size >= req.len) {
        state := s_idle
      }
    }
  }
}

// 简化的写入器
class SimpleStreamWriter(nXacts: Int, beatBits: Int, maxBytes: Int, dataWidth: Int)
                        (implicit p: Parameters) extends LazyModule {
  val node = TLClientNode(Seq(TLMasterPortParameters.v1(Seq(TLClientParameters(
    name = "simple-stream-writer", sourceId = IdRange(0, nXacts))))))

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
    val bytesSent = Reg(UInt(16.W))
    val bytesLeft = req.len - bytesSent

    // 简化的写入逻辑
    val write_size = minOf(beatBytes.U, bytesLeft)
    val write_vaddr = req.vaddr + bytesSent

    // TileLink 写入请求
    val put = edge.Put(
      fromSource = 0.U, // 简化：只用一个source ID
      toAddress = 0.U,
      lgSize = log2Ceil(beatBytes).U,
      data = req.data >> (bytesSent * 8.U)
    )._2

    // TLB处理
    io.tlb.req.valid := state === s_writing && tl.a.ready
    io.tlb.req.bits := DontCare
    io.tlb.req.bits.tlb_req.vaddr := write_vaddr
    io.tlb.req.bits.tlb_req.passthrough := false.B
    io.tlb.req.bits.tlb_req.size := 0.U
    io.tlb.req.bits.tlb_req.cmd := M_XWR
    io.tlb.req.bits.status := req.status

    // TileLink连接
    tl.a.valid := state === s_writing && !io.tlb.resp.miss
    tl.a.bits := put
    tl.a.bits.address := io.tlb.resp.paddr

    tl.d.ready := true.B

    // 响应处理
    io.resp.valid := tl.d.valid && state === s_writing
    io.resp.bits.done := bytesSent + write_size >= req.len

    // 状态机
    io.req.ready := state === s_idle
    io.busy := state =/= s_idle

    when (io.req.fire) {
      req := io.req.bits
      bytesSent := 0.U
      state := s_writing
    }

    when (tl.a.fire) {
      bytesSent := bytesSent + write_size
      when (bytesSent + write_size >= req.len) {
        state := s_idle
      }
    }
  }
}
