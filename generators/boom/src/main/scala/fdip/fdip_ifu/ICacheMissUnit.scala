// //******************************************************************************
// // Copyright (c) 2017 - 2019, The Regents of the University of California (Regents).
// // All Rights Reserved. See LICENSE and LICENSE.SiFive for license details.
// //------------------------------------------------------------------------------

// //------------------------------------------------------------------------------
// //------------------------------------------------------------------------------
// // ICache
// //------------------------------------------------------------------------------
// //------------------------------------------------------------------------------

package boom.fdip.ifu

import chisel3._
import chisel3.util._
import chisel3.util.random._

import org.chipsalliance.cde.config.{Parameters}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.tile._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.util._
import freechips.rocketchip.util.property._
import freechips.rocketchip.rocket.{HasL1ICacheParameters, ICacheParams, ICacheErrors, ICacheReq}
import boom.fdip.ifu._



import boom.fdip.common._
import boom.fdip.util._
import freechips.rocketchip.regmapper.RRTest0Map.re
class ICacheMissReq(implicit p: Parameters) extends BoomBundle with HasBoomFrontendParameters{
    val blkPaddr: UInt = UInt((vaddrBitsExtended - blockOffBits).W)
    val way:  UInt = UInt(log2Ceil(nWays).W)
    val vSetIdx:  UInt = UInt((log2Up(nSets)).W)
}

class ICacheMissResp(implicit p: Parameters) extends BoomBundle with HasBoomFrontendParameters{
  val blkPaddr: UInt = UInt((vaddrBitsExtended - blockOffBits).W)

  val vSetIdx:  UInt = UInt((log2Up(nSets)).W)
  val way:  UInt = UInt(log2Ceil(nWays).W)
  val data:     UInt = UInt((cacheBlockBytes*8).W)
//   val corrupt:  Bool = Bool()
}
class MSHRMissResp(implicit p: Parameters) extends BoomBundle with HasBoomFrontendParameters{
  val blkPaddr: UInt = UInt((vaddrBitsExtended - blockOffBits).W)

  val vSetIdx:  UInt = UInt((log2Up(nSets)).W)
  val way:  UInt = UInt(log2Ceil(nWays).W)

}
class ICacheMetaWriteBundle(implicit p: Parameters) extends BoomBundle with HasBoomFrontendParameters{
    val virIdx      = UInt((log2Up(nSets)).W)
    val phyTag      = UInt((vaddrBitsExtended - blockOffBits).W)
    val way     = UInt(log2Ceil(nWays).W)
}
class ICacheDataWriteBundle(implicit p: Parameters) extends BoomBundle  with HasBoomFrontendParameters{
    val virIdx      = UInt(idxBits.W)
    // // val phyTag      = UInt((vaddrBitsExtended - blockOffBits - idxBits).W) 
    val way     = UInt(log2Ceil(nWays).W)
    val data        = UInt((cacheBlockBytes*8).W)
}
class ICacheMissUnitIO(edge: TLEdgeOut)(implicit p: Parameters) extends BoomBundle with HasBoomFrontendParameters{

  // control
  val fencei: Bool = Input(Bool())
  val flush:  Bool = Input(Bool())
//   val invalidate: Bool = Input(Bool())

  // fetch
  val fetch_req:  DecoupledIO[ICacheMissReq] = Flipped(DecoupledIO(new ICacheMissReq()))
  val fetch_resp: Valid[ICacheMissResp]      = ValidIO(new ICacheMissResp())
  // prefetch
  val prefetch_req: DecoupledIO[ICacheMissReq] = Flipped(DecoupledIO(new ICacheMissReq()))
//   // SRAM Write Req
//   val meta_write: DecoupledIO[ICacheMetaWriteBundle] = DecoupledIO(new ICacheMetaWriteBundle())
//   val data_write: DecoupledIO[ICacheDataWriteBundle] = DecoupledIO(new ICacheDataWriteBundle())
  // get victim from replacer
//   val victim: ReplacerVictim = new ReplacerVictim
  // Tilelink
  val acquire                               = DecoupledIO(new TLBundleA(edge.bundle))
  val grant                                 = Flipped(DecoupledIO(new TLBundleD(edge.bundle)))
//   val mem_acquire: DecoupledIO[TLBundleA] = DecoupledIO(new TLBundleA(edge.bundle))
//   val mem_grant:   DecoupledIO[TLBundleD] = Flipped(DecoupledIO(new TLBundleD(edge.bundle)))
}
class LookUpMSHR(implicit p: Parameters) extends BoomBundle with HasBoomFrontendParameters{
  val info: Valid[ICacheMissReq] = ValidIO(new ICacheMissReq())
  val hit:  Bool                 = Input(Bool())
}
class ICacheMSHRIO(edge: TLEdgeOut)(implicit p: Parameters) extends BoomBundle with HasBoomFrontendParameters{

  // control
  val fencei: Bool      = Input(Bool())
  val flush:  Bool      = Input(Bool())
  val invalidate: Bool  = Input(Bool())

  // fetch
  val req:  DecoupledIO[ICacheMissReq] = Flipped(DecoupledIO(new ICacheMissReq()))//目前兼容lookup的功能
  val resp: Valid[MSHRMissResp]      = ValidIO(new MSHRMissResp())//返回写入data和tag的必要数据

  val lookUps:   Vec[LookUpMSHR]            = Flipped(Vec(2, new LookUpMSHR())) //1:fetch 2:pre-fetch
  val acquire                               = DecoupledIO(new TLBundleA(edge.bundle))
}
class ICacheMSHR(edge: TLEdgeOut,ID:Int)(implicit p: Parameters) extends BoomModule with HasBoomFrontendParameters{
    val io: ICacheMSHRIO = IO(new ICacheMSHRIO(edge: TLEdgeOut))
    val valid = RegInit(false.B)
    val flush = RegInit(false.B)
    val fencei = RegInit(false.B)
    val issued = RegInit(false.B)
    val blkPaddr = RegInit(UInt((vaddrBitsExtended - log2Up(cacheParams.blockBytes)).W),0.U)
    val vSetIdx  = RegInit(UInt((log2Up(nSets)).W),0.U)
    val way      = RegInit(UInt(log2Ceil(nWays).W),0.U)
    

    //Lookup
    val Hits = io.lookUps.map(lu => lu.info.valid && valid && (lu.info.bits.blkPaddr === blkPaddr) && (lu.info.bits.vSetIdx === vSetIdx)
                      && !io.flush && !io.fencei)
    io.lookUps.zip(Hits).foreach{ case (lu, hit) =>
        lu.hit := hit
    }


    io.req.ready := !valid && !io.flush && !io.fencei
    when(io.req.fire){
        valid := true.B
        fencei := false.B
        flush := false.B
        blkPaddr := io.req.bits.blkPaddr
        vSetIdx  := io.req.bits.vSetIdx
        way     := io.req.bits.way
        issued := false.B
    }

    when(io.acquire.fire){
        issued := true.B
    }
    when(io.flush||io.fencei){
        fencei := true.B
        flush := true.B
        // issued := false.B
        // valid  := false.B
        when(!issued){
            valid := false.B
        }
    }
    when(io.invalidate){//此时mshr释放，表示写入icache
        valid := false.B
        issued := false.B
    }
    io.resp.valid := valid && !flush && !fencei 
    io.resp.bits.blkPaddr := blkPaddr
    io.resp.bits.vSetIdx  := vSetIdx
    io.resp.bits.way  := way

    io.acquire.valid := valid && !issued && !io.flush && !io.fencei
    private val getBlock = edge.Get(
        fromSource = ID.U,
        toAddress = Cat(blkPaddr, 0.U(blockOffBits.W)),
        lgSize = log2Up(cacheParams.blockBytes).U
    )._2
    io.acquire.bits := getBlock
    dontTouch(io.acquire)
}
/* 
功能
1.将miss请求存入mshr
2.处理mshr请求，发送到l2
3.接收l2返回的数据，写回icache
4.查找mshr，返回fetch_resp
*/
class ICacheMissUnit(edge: TLEdgeOut,refillCycles:Int)(implicit p: Parameters) extends BoomModule with HasBoomFrontendParameters{
    val io: ICacheMissUnitIO = IO(new ICacheMissUnitIO(edge))
    private  val nMSHRs = 4
    private  val nPrefetchMSHRs = 8
    // override val refillCycles = outer.icacheParams.blockBytes*8 / outer.masterNode.out.head._1.d.bits.data.getWidth
    val mshrs = (0 until nMSHRs).map{i => 
      val mshr=Module(new ICacheMSHR(edge,i))
      mshr
    }
    val pre_mshrs = (0 until nPrefetchMSHRs).map{i => 
      val mshr=Module(new ICacheMSHR(edge,i+nMSHRs))
      mshr
    }
    val mshrReadyVec = WireInit(VecInit(mshrs.map(mshr => mshr.io.req.ready)))
    val mshrSel      = PriorityEncoder(mshrReadyVec)
    val mshrFull     = WireInit(!mshrReadyVec.reduce(_ || _))

    val prefetch_mshrReadyVec = WireInit(VecInit(pre_mshrs.map(mshr => mshr.io.req.ready)))
    val prefetch_mshrSel      = PriorityEncoder(prefetch_mshrReadyVec)
    val prefetch_mshrFull     = WireInit(!prefetch_mshrReadyVec.reduce(_ || _)) 

    private val acquireArb          = Module(new Arbiter((new TLBundleA(edge.bundle)), nMSHRs))
    private val prefetchAcquireArb  = Module(new Arbiter((new TLBundleA(edge.bundle)), nPrefetchMSHRs))
    private val totalAcquireArb  = Module(new Arbiter((new TLBundleA(edge.bundle)), 2))
    val all_mshrs = mshrs ++ pre_mshrs
    val fetchHitVec = WireInit(VecInit(all_mshrs.map(mshr => mshr.io.lookUps(0).hit)))
    val prefetchHitVec = WireInit(VecInit(all_mshrs.map(mshr => mshr.io.lookUps(1).hit)))
    assert(PopCount(fetchHitVec) <= 1.U, "ICacheMissUnit: multiple MSHR hits on fetch_req")
    io.fetch_req.ready := !mshrFull || fetchHitVec.reduce(_ || _) || prefetchHitVec.reduce(_ || _)

    
    val mshrResps = all_mshrs.map(mshr => mshr.io.resp)
    
    //Mshr 入队
    totalAcquireArb.io.in(0) <> acquireArb.io.out
    totalAcquireArb.io.in(1) <> prefetchAcquireArb.io.out
    totalAcquireArb.io.out <> io.acquire
    
    /* -------------------------------------------------------------------------- */
    /*                                 //Fetch 响应                                 */
    /* -------------------------------------------------------------------------- */
    
    // val respCnt      = RegInit(0.U(log2Ceil(refillCycles).W))
    val respDataReg  = RegInit(VecInit(Seq.fill(refillCycles)(0.U(io.grant.bits.data.getWidth.W))))
    val (_, _, d_done, refill_cnt) = edge.count(io.grant)//
    val respOneBeat = io.grant.fire&&edge.hasData(io.grant.bits)
    val respDone    = respOneBeat && d_done
    val respId      = WireInit(io.grant.bits.source)
    val mshrResp    = mshrResps(respId)
    when(respOneBeat){
        respDataReg(refill_cnt) := io.grant.bits.data
    }
    io.grant.ready := true.B
    //delay 1 cycle
    val respDoneReg = RegNext(respDone, false.B)

    val respIdReg   = RegNext(respId, 0.U)
    val mshrRespReg = RegNext(mshrResp.bits, 0.U.asTypeOf(new MSHRMissResp()))

    dontTouch(mshrFull)
    dontTouch(mshrReadyVec)
    (0 until nMSHRs).foreach{i =>
        mshrs(i).io.fencei := io.fencei
        mshrs(i).io.flush  := io.flush
        mshrs(i).io.lookUps := DontCare
        mshrs(i).io.lookUps(0).info.bits := io.fetch_req.bits
        mshrs(i).io.lookUps(0).info.valid := io.fetch_req.valid
        mshrs(i).io.lookUps(1).info.bits := io.prefetch_req.bits
        mshrs(i).io.lookUps(1).info.valid := io.prefetch_req.valid
        mshrs(i).io.invalidate := respIdReg === i.U && respDoneReg
        mshrs(i).io.req.valid  := (i.U === mshrSel) && io.fetch_req.valid && !mshrFull && (!fetchHitVec.reduce(_ || _)) && (!prefetchHitVec.reduce(_ || _))
        mshrs(i).io.req.bits   := io.fetch_req.bits
        acquireArb.io.in(i) <> mshrs(i).io.acquire
    }
    (0 until nPrefetchMSHRs).foreach{i =>
      pre_mshrs(i).io.fencei := io.fencei
      pre_mshrs(i).io.flush  := io.flush
      pre_mshrs(i).io.lookUps := DontCare
      pre_mshrs(i).io.lookUps(0).info.bits := io.fetch_req.bits
      pre_mshrs(i).io.lookUps(0).info.valid := io.fetch_req.valid
      pre_mshrs(i).io.lookUps(1).info.bits := io.prefetch_req.bits
      pre_mshrs(i).io.lookUps(1).info.valid := io.prefetch_req.valid
      pre_mshrs(i).io.invalidate := respIdReg === (i+nMSHRs).U && respDoneReg
      pre_mshrs(i).io.req.valid  := (i.U === prefetch_mshrSel) && !(io.fetch_req.valid&&io.prefetch_req.bits.blkPaddr===io.fetch_req.bits.blkPaddr&&io.fetch_req.bits.vSetIdx===io.prefetch_req.bits.vSetIdx)&&
                                         io.prefetch_req.valid && !prefetch_mshrFull && (!fetchHitVec.reduce(_ || _)) && (!prefetchHitVec.reduce(_ || _))
      pre_mshrs(i).io.req.bits   := io.prefetch_req.bits
      prefetchAcquireArb.io.in(i) <> pre_mshrs(i).io.acquire
    }


    io.fetch_resp.valid         := respDoneReg
    io.fetch_resp.bits.blkPaddr := mshrRespReg.blkPaddr
    io.fetch_resp.bits.vSetIdx  := mshrRespReg.vSetIdx
    io.fetch_resp.bits.way      := mshrRespReg.way
    io.fetch_resp.bits.data     := Cat(respDataReg.reverse)
    




    //TODO；add pre-fetch
    io.prefetch_req.ready := !prefetch_mshrFull || fetchHitVec.reduce(_ || _) || prefetchHitVec.reduce(_ || _)



}

