package barf

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.{Field, Parameters}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.util._
import freechips.rocketchip.tile._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.rocket.ALU._
import freechips.rocketchip.rocket.constants._
import freechips.rocketchip.rocket.{isPrefetch}
import VecUtil._

// address generator unit
class AGUOperand(params:VectorizerParams)(implicit p: Parameters) extends CoreBundle {
    val base   = UInt()
    val offset = UInt()
}

class AGUResult(implicit p: Parameters) extends CoreBundle() {
    val addr = UInt()
}

class AGUIO(params:VectorizerParams)(implicit p: Parameters) extends CoreBundle {
    val in   = Valid(new AGUOperand(params))
    val mask = Vec(params.nVecLanes, Bool())
    val out  = Vec(params.nVecLanes, Flipped(Valid(new AGUResult)))
}

class AGU(params:VectorizerParams)(implicit p: Parameters) extends CoreModule()(p) {
    val io = IO(Flipped(new AGUIO(params)))

    val in = io.in.bits
    val offset = in.offset
    val addr = RegInit(VecInit(Seq.fill(params.nVecLanes)(0.U(vaddrBitsExtended.W))))

    addr.zipWithIndex.foreach { case (x, i) =>
        x := Mux(io.in.valid & io.mask(i), in.base + offset * i.U, addr(i))
    }

    io.out.zipWithIndex.foreach { case (x, i) =>
        x.valid := io.in.valid & io.mask(i)
        x.bits.addr := addr(i)
    }
}

class VecLoadReq(params:VectorizerParams)(implicit p: Parameters) extends CoreBundle {
    val agu      = Flipped(Valid(new AGUOperand(params)))
    val ncaddr   = Input(UInt(params.VecBitWidth.W)) // non-continuous address from VecRegfile
    val const    = Input(UInt(xLen.W))
    val mask     = Input(UInt(params.nVecLanes.W))
}
class VecLoadResp(params:VectorizerParams)(implicit p: Parameters) extends CoreBundle with MemoryOpConstants {
    //val addr = UInt(vaddrBitsExtended.W)
    val cmd  = UInt(M_SZ.W)
    val data = UInt(coreDataBits.W)
}

class VecLoadWriteBack(params:VectorizerParams)(implicit p: Parameters) extends CoreBundle {
    val result = UInt(params.VecBitWidth.W)
}

class VecLoadUnit(params:VectorizerParams)(implicit p: Parameters) extends CoreModule()(p) {
    val io = IO(new Bundle {
        val req  = Decoupled(new VecLoadReq(params))
        val resp = Flipped(Decoupled(new VecLoadResp(params)))
        val wb   = Valid(new VecLoadWriteBack(params))
        val pref = Decoupled(new Prefetch)
    })
    
    // only stride prefetch using AGU
    val agu = Module(new AGU(params))
    agu.io.in.valid := io.req.valid
    agu.io.in.bits.base := io.req.bits.agu.bits.base
    agu.io.in.bits.offset := io.req.bits.agu.bits.offset
    agu.io.mask := io.req.bits.mask

    val req = io.req.bits
    val req_valid = VecInit((0 until params.nVecLanes).map(i => io.req.valid && io.req.bits.mask(i)))
    val req_ncaddr = unpack(req.ncaddr, 64, params.nVecLanes, params.VecBitWidth)
    val req_ncaddr_ext = req_ncaddr.map(_ + req.const)
    val req_stride = agu.io.out.map(_.bits.addr)

    // convert vector address request to address request sequence
    val prf = new Queue(io.pref.bits.address, params.nVecLanes)
    val req_ncvalid_reg = RegNext(req_valid)
    val req_stvalid_reg = RegNext(VecInit(agu.io.out.map(_.valid)))

    for (i <- 0 until params.nVecLanes) {
        when(req_ncvalid_reg(i) || req_stvalid_reg(i)) {
            prf.io.enq.valid := true.B
            prf.io.enq.bits  := Mux(req_ncvalid_reg(i), req_ncaddr_ext(i), req_stride(i))
            when(req_ncvalid_reg(i)) {
                req_ncvalid_reg(i) := false.B
            }
            when(req_stvalid_reg(i)) {
                req_stvalid_reg(i) := false.B
            }
        }
    }

    val all_resp_ret = Wire(Bool())
    val (req_sending_cnt, req_overflow) = Counter(0 until params.nVecLanes, prf.io.deq.fire, all_resp_ret)
    prf.io.deq.ready := io.pref.ready
    
    // request to cache
    io.pref.valid  := prf.io.deq.valid
    io.pref.bits.address  := prf.io.deq.bits
    io.pref.bits.write    := false.B

    // response from cache
    val prf_resp_valid = io.resp.fire && isPrefetch(io.resp.bits.cmd)
    val resp = Reg(Vec(params.nVecLanes, UInt(xLen.W)))
    val (resp_burst_cnt, can_pack) = Counter(0 until params.nVecLanes, prf_resp_valid, all_resp_ret)
    all_resp_ret := resp_burst_cnt === req_sending_cnt

    val vec = RegInit(0.U(params.VecBitWidth.W))

    when(prf_resp_valid) {
        resp(resp_burst_cnt) := io.resp.bits.data
    }

    when(can_pack) {
        vec := pack(resp)
    }

    io.req.ready  := req_sending_cnt =/= params.nVecLanes.U
    io.resp.ready := resp_burst_cnt.orR
    
    io.wb.valid := can_pack
    io.wb.bits.result := vec
}