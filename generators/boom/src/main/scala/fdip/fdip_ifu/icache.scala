//******************************************************************************
// Copyright (c) 2017 - 2019, The Regents of the University of California (Regents).
// All Rights Reserved. See LICENSE and LICENSE.SiFive for license details.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// ICache
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

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
import freechips.rocketchip.tilelink.TLMessages.d

/**
 * ICache module
 *
 * @param icacheParams parameters for the icache
 * @param hartId the id of the hardware thread in the cache
 * @param enableBlackBox use a blackbox icache
 */
class ICache(
  val icacheParams: ICacheParams,
  val staticIdForMetadataUseOnly: Int)(implicit p: Parameters)
  extends LazyModule
{
  lazy val module = new ICacheModule(this)
  val masterNode = TLClientNode(Seq(TLMasterPortParameters.v1(Seq(TLMasterParameters.v1(
    sourceId = IdRange(0, 12), // 12 个mshr 4fetch 8 prefetch//prefetch代表预取深度
    name = s"Core ${staticIdForMetadataUseOnly} ICache")))))
  val size = icacheParams.nSets * icacheParams.nWays * icacheParams.blockBytes
  private val wordBytes = icacheParams.fetchBytes
}

/**
 * IO Signals leaving the ICache
 *
 * @param outer top level ICache class
 */
class ICacheResp(val outer: ICache) extends Bundle
{
  val data    = UInt((outer.icacheParams.fetchBytes*8).W)
  val replay  = Bool()
  val ae      = Bool()
}

/**
 * IO Signals for interacting with the ICache
 *
 * @param outer top level ICache class
 */
class ICacheBundle(val outer: ICache) extends BoomBundle()(outer.p)
  with HasBoomFrontendParameters
{
  val req               = Flipped(Decoupled(new ICacheReq))
  val prefetch_req      = Flipped(DecoupledIO(new FTQToPrefetchIO))
  val s1_paddr          = Input(UInt(paddrBits.W)) // delayed one cycle w.r.t. req
  val s1_prefetch_paddr = Input(UInt(paddrBits.W)) // delayed one cycle w.r.t. req
  val s1_prefetch_kill  = Input(Bool()) // 此时发生tlb miss，预取失效
  val s1_kill           = Input(Bool()) // delayed one cycle w.r.t. req
  val s2_kill           = Input(Bool()) // delayed two cycles; prevents I$ miss emission

  val resp              = Valid(new ICacheResp(outer))
  val ifu_s3_ready      = Input(Bool())
  val flush             = Input(Bool())//后端重定向以及前端的重定向
  val invalidate        = Input(Bool())

  val perf = Output(new Bundle {
    val miss_acquire = Bool()
    val prefetch_acquire = Bool()
  })
}

/**
 * Get a tile-specific property without breaking deduplication
 */
object GetPropertyByHartId
{
  def apply[T <: Data](tiles: Seq[RocketTileParams], f: RocketTileParams => Option[T], hartId: UInt): T = {
    PriorityMux(tiles.collect { case t if f(t).isDefined => (t.tileId.U === hartId) -> f(t).get })
  }
}


 
/**
 * Main ICache module
 *
 * @param outer top level ICache class
 */

//现在row bits已经没什么用
class ICacheModule(outer: ICache) extends LazyModuleImp(outer)
  with HasBoomFrontendParameters
{
  val numBanks = 8//默认64 bytes 8 banks
  
  val wordBits = outer.icacheParams.fetchBytes*8
  val bankBits = (outer.icacheParams.blockBytes/numBanks)*8
  val bankOffBits = log2Up(numBanks)
  val enableICacheDelay = tileParams.core.asInstanceOf[BoomCoreParams].enableICacheDelay
  val fetchBankNum = wordBits/bankBits//每次fetch多少个bank
  val io = IO(new ICacheBundle(outer))

  
  val (tl_out, edge_out) = outer.masterNode.out(0)
  override val refillCycles = outer.icacheParams.blockBytes*8 / tl_out.d.bits.data.getWidth
  val missunit = Module(new ICacheMissUnit(edge_out,refillCycles)(p))
  println(f"fecthBankNum:${numBanks}${refillCycles}")
  require(isPow2(nSets) && isPow2(nWays))
  require(usingVM)
  require(pgIdxBits >= untagBits)//TODO: 解除这个限制->refill addr的idx需要用vir 
  require(refillCycles>=1)
  require(wordBits >= bankBits)
  // How many bits do we intend to fetch at most every cycle?
  
  // Each of these cases require some special-case handling.
  // require (tl_out.d.bits.data.getWidth == wordBits || (2*tl_out.d.bits.data.getWidth == wordBits && nBanks == 2))
  // require (tl_out.d.bits.data.getWidth == wordBits)
  // require (tl_out.d.bits.data.getWidth == wordBits)
  // If TL refill is half the wordBits size and we have two banks, then the
  // refill writes to only one bank per cycle (instead of across two banks every
  // cycle).

  //每次fetch的bank起始一定是奇数
  def fetchData(start_bank:UInt,ICacheData:Vec[UInt]) = {
    val data = Wire(Vec(fetchBankNum,UInt(bankBits.W)))
    for(i <- 0 until fetchBankNum){
      data(i) := ICacheData((start_bank+i.U)%numBanks.U)
    }
    Cat(data.reverse)
  }
  def bankSel(start_bank:UInt) = {
    val sel = Wire(UInt(numBanks.W))
    val end_bank  = start_bank + fetchBankNum.U - 1.U
    sel := MaskUpper(UIntToOH(start_bank)) & MaskLower(UIntToOH(end_bank))
    sel

  }
  val prefetch_pipe    = Module(new PrefetchPipe())
  val refillsToOneBank = (2*tl_out.d.bits.data.getWidth == wordBits)
  val missRespVal      = WireInit(missunit.io.fetch_resp.valid)
  val missResp         = WireInit(missunit.io.fetch_resp.bits)

  val s1_ready,s2_ready       = WireInit(false.B)
  val s0_fire,s1_fire,s2_fire = WireInit(false.B) 
  val s0_valid      = io.req.fire
  val s0_vaddr      = WireInit(io.req.bits.addr)
  val s0_start_bank = fetchAlign(s0_vaddr)(blockOffBits-1,blockOffBits-bankOffBits)
  val s0_bank_sel   = bankSel(s0_start_bank)

  val s1_vaddr      = RegEnable(s0_vaddr,s0_fire)
  val s1_start_bank = RegEnable(s0_start_bank,s0_fire)
  val s1_valid      = RegInit(false.B)
  val s1_idx        = io.s1_paddr(untagBits-1,blockOffBits)
  val s1_tag        = io.s1_paddr(tagBits+untagBits-1,untagBits)
  val s1_prefetch_idx        = WireInit(io.s1_prefetch_paddr(untagBits-1,blockOffBits))
  val s1_prefetch_tag        = WireInit(io.s1_prefetch_paddr(tagBits+untagBits-1,untagBits))
  val s1_tag_hit    = Wire(Vec(nWays, Bool()))
  val s1_resp_hit   = missRespVal && (missResp.vSetIdx === s1_idx) && s1_valid && (missResp.blkPaddr>>idxBits)===s1_tag
  val s1_hit        = s1_tag_hit.reduce(_||_) || s1_resp_hit
  val s1_dout       = Wire(Vec(nWays, Vec(numBanks,UInt(bankBits.W)))) 
  val s1_hit_way     = OHToUInt(s1_tag_hit)
  val s1_way_mux     = Mux1H(s1_tag_hit, s1_dout)
  val s1_data        = fetchData(s1_start_bank,Mux(s1_resp_hit,s1_dout(0),s1_way_mux))//s1 hit的数据来自missunit或者data array

  val s2_vaddr      = RegEnable(s1_vaddr,s1_fire && !io.s1_kill)
  val s2_idx         = RegEnable(s1_idx,s1_fire && !io.s1_kill)
  val s2_tag         = RegEnable(s1_tag,s1_fire && !io.s1_kill)
  val s2_start_bank  = RegEnable(s1_start_bank,s1_fire && !io.s1_kill)
  val s2_valid       = RegInit(false.B)//RegEnable(s1_valid  ,false.B,s1_fire && !io.s1_kill)
  val s2_hit         = RegEnable(s1_hit,false.B,s1_fire && !io.s1_kill)
  val s2_data        = RegEnable(s1_data,s1_fire && !io.s1_kill)
  val s2_fetch_finish= WireInit(false.B)
  val s2_has_fetched = RegInit(false.B)
  //mshr info

  //s1,s2阶段正好命中missunit的resp
  
  val s2_resp_hit      = missRespVal && (missResp.vSetIdx === s2_idx) && s2_valid && (missResp.blkPaddr>>idxBits)===s2_tag



  val s2_respData = Wire(Vec(numBanks,UInt(bankBits.W)))
  for (i <- 0 until numBanks){
    s2_respData(i) := missResp.data((i+1)*bankBits-1,i*bankBits)
  }
  val s2_resp_data  = fetchData(s2_start_bank,s2_respData)
  val ifu_resp_data    = Mux(missRespVal&&s2_resp_hit,s2_resp_data,s2_data)
  // IFU s3 ready信号到来之前，保存ifu_resp_data，防止icache数据丢失
  val ifu_resp_data_reg  = RegInit(0.U((outer.icacheParams.fetchBytes*8).W))
  val ifu_resp_data_valid= RegInit(false.B)
  when(s2_valid&&(s2_hit||s2_resp_hit)&& !io.ifu_s3_ready && !io.flush){
    ifu_resp_data_reg := ifu_resp_data
  }
  when(io.flush){
    ifu_resp_data_valid := false.B
  }.elsewhen(s2_valid&&(s2_hit||s2_resp_hit)&& !io.ifu_s3_ready){
    ifu_resp_data_valid := true.B
  }.elsewhen(s2_fire){
    ifu_resp_data_valid := false.B
  }
  when(io.s1_kill||io.flush){
    s1_valid := false.B
  }.elsewhen(s0_fire){
    s1_valid := true.B
  }.elsewhen(s1_fire){
    s1_valid := false.B
  }

  when(io.s2_kill||io.flush){
    s2_valid := false.B
  }.elsewhen(s1_fire && !io.s1_kill){
    s2_valid := true.B
  }.elsewhen(s2_fire){
    s2_valid := false.B
  }
  s0_fire           := s0_valid && s1_ready 
  s1_fire           := s1_valid && s2_ready
  s1_ready          := s1_fire || !s1_valid
  s2_ready          := s2_fire || !s2_valid
  s2_fire           := s2_valid && (s2_hit ||s2_resp_hit) && io.ifu_s3_ready
  
  
  dontTouch(missResp)
  dontTouch(missRespVal)
  dontTouch(s1_idx)
  dontTouch(s0_bank_sel)
  dontTouch(s1_tag)
  dontTouch(s1_data)
  dontTouch(s0_vaddr)
  dontTouch(s1_vaddr)
  dontTouch(s2_vaddr)
  dontTouch(s2_fire)
  dontTouch(s0_fire)
  dontTouch(s1_fire)
  dontTouch(s1_ready)
  dontTouch(s1_prefetch_idx)
  dontTouch(s1_prefetch_tag)
  val invalidated   = RegInit(false.B)
  dontTouch(invalidated)
  // val refill_valid  = RegInit(false.B)
  // val refill_fire   = tl_out.a.fire
  val s2_miss = s2_valid && !s2_hit && !s2_resp_hit 


  io.req.ready := !missunit.io.fetch_resp.valid && s1_ready

  val (_, _, d_done, refill_cnt) = edge_out.count(tl_out.d)
  // val refill_done = refill_one_beat && d_done
  // tl_out.d.ready := true.B
  require (edge_out.manager.minLatency > 0)

  val repl_way = if (isDM) 0.U else LFSR(16, s2_miss)(log2Ceil(nWays)-1,0)
  //现在采用复制的方法去保证正常取指和prefetch同时可以访问
  val tag_array = Seq.fill(2){SyncReadMem(nSets, Vec(nWays, UInt(tagBits.W)))}
  val tag_rdata = tag_array(0).read(s0_vaddr(untagBits-1, blockOffBits), !missRespVal && s0_valid)//for normal fetch
  val prefetch_rdata = tag_array(1).read(io.prefetch_req.bits.fetch_pc(untagBits-1, blockOffBits), !missRespVal)//for prefetch
  val s1_prefetch_hit = Wire(Vec(nWays, Bool()))
  when (missRespVal) {
    for(i <- 0 until 2){
      tag_array(i).write(missResp.vSetIdx, VecInit(Seq.fill(nWays)(missResp.blkPaddr>>idxBits)), Seq.tabulate(nWays)(missResp.way === _.U))
    }
  }
  //TODO: update vb_entry
  val vb_array = RegInit(0.U((nSets*nWays).W))
  when (missRespVal) {
    vb_array := vb_array.bitSet(Cat(missResp.way, missResp.vSetIdx), missRespVal && !invalidated)
  }

  when (io.invalidate) {
    vb_array := 0.U
    invalidated := true.B
  }

  // val s2_dout   = Wire(Vec(nWays, Vec(numBanks,UInt(bankBits.W))))
  // val s1_bankid = Wire(Bool())

  for (i <- 0 until nWays) {

    val s1_vb = vb_array(Cat(i.U, s1_idx))
    val s1_prefetch_vb = vb_array(Cat(i.U, s1_prefetch_idx))
    val tag = tag_rdata(i)
    s1_tag_hit(i) := s1_vb && tag === s1_tag
    s1_prefetch_hit(i) := s1_prefetch_vb && prefetch_rdata(i) === s1_prefetch_tag
  }
  assert(PopCount(s1_tag_hit) <= 1.U)
  dontTouch(s1_prefetch_hit)
  val ramDepth = nSets

  val dataArrays =     (0 until nWays).map { way =>
    val banks = (0 until numBanks).map { bank =>
      val singleBank = Module(new ICacheSRAMHelper("ICache Data Array",way, bank, ramDepth, UInt((outer.icacheParams.blockBytes*8/numBanks).W)))
      singleBank
    }
    banks
  }
  
  for (i <- 0 until nWays) {
    val s0_ren = s0_valid
    val wen = (missRespVal && !invalidated) && missResp.way === i.U

    for (bank <- 0 until numBanks) {
      val dataArray = dataArrays(i)(bank)
      var mem_idx: UInt = null

      mem_idx =
        Mux(missRespVal, missResp.vSetIdx ,
        s0_vaddr(untagBits-1, blockOffBits))
      // val data = tl_out.d.bits.data
      dataArray.io.w.wen   := wen  
      dataArray.io.w.waddr := mem_idx
      dataArray.io.w.wdata := missResp.data(bankBits*(bank+1)-1,bankBits*bank)

      dataArray.io.r.req.valid      := s0_valid && s0_bank_sel(bank)
      dataArray.io.r.req.bits.raddr := mem_idx

      // if (enableICacheDelay)
      //   s2_dout(i)(bank) := RegNext(dataArray.io.r.resp.rdata)
      // else
      //   s2_dout(i)(bank) := dataArray.io.r.resp.rdata
      s1_dout(i)(bank) := Mux(s1_resp_hit,missResp.data(bankBits*(bank+1)-1,bankBits*bank),dataArray.io.r.resp.rdata)
    }
  }
  
  when(io.flush||io.invalidate){
    s2_has_fetched := false.B
  }.elsewhen(s2_fire){
    s2_has_fetched := false.B
  }
  .elsewhen(s2_miss && !io.s2_kill && s2_valid){
    s2_has_fetched := true.B
  }
  missunit.io.fetch_req.valid := s2_miss && !io.s2_kill && s2_valid && !s2_has_fetched && !io.flush && !io.invalidate
  missunit.io.fetch_req.bits.blkPaddr := Cat(s2_tag, s2_idx)
  missunit.io.fetch_req.bits.vSetIdx  := s2_idx
  missunit.io.fetch_req.bits.way      := repl_way
  missunit.io.fencei                  := io.invalidate
  missunit.io.prefetch_req            := DontCare
  missunit.io.flush                   := io.flush||io.invalidate//TODO: add prefetch and flush
  
  prefetch_pipe.io.s1_kill := io.s1_prefetch_kill
  prefetch_pipe.io.refilled := missRespVal
  prefetch_pipe.io.req <>io.prefetch_req
  prefetch_pipe.io.flush := io.flush||io.invalidate
  prefetch_pipe.io.s1_paddr := io.s1_prefetch_paddr
  missunit.io.prefetch_req <> prefetch_pipe.io.prefetch_req
  //预取的接口也需要bypass
  /* 
  cycle0：miss数据未返回，预取接口读tag
  cycle1：miss数据返回，预取接口的hit需要去监听miss，否则会重复写入
   */
  prefetch_pipe.io.s1_tag_hit := s1_prefetch_hit.reduce(_||_) || missRespVal&&(missResp.vSetIdx===s1_prefetch_idx)&&(missResp.blkPaddr>>idxBits)===s1_prefetch_tag

  // val refill_resp_dat = RegNext(fetchData())
  io.resp.bits.ae     := DontCare
  io.resp.bits.replay := DontCare
  io.resp.bits.data   := Mux(ifu_resp_data_valid, ifu_resp_data_reg, ifu_resp_data)
  io.resp.valid       := (s2_valid && (s2_hit || s2_resp_hit || ifu_resp_data_valid))&& !io.s2_kill && !io.flush

  tl_out.a <> missunit.io.acquire
  missunit.io.grant <> tl_out.d

  tl_out.b.ready := true.B
  tl_out.c.valid := false.B
  tl_out.e.valid := false.B

  io.perf.miss_acquire := tl_out.a.fire && tl_out.a.bits.source<4.U
  io.perf.prefetch_acquire := tl_out.a.fire && tl_out.a.bits.source>=4.U



  override def toString: String = BoomCoreStringPrefix(
    "==L1-ICache==",
    "Fetch bytes   : " + cacheParams.fetchBytes,
    "Block bytes   : " + (1 << blockOffBits),
    "Row bytes     : " + rowBytes,
    "Word bits     : " + wordBits,
    "Sets          : " + nSets,
    "Ways          : " + nWays,
    "Refill cycles : " + refillCycles,
    "RAMs          : (" +  wordBits/nBanks + " x " + nSets*refillCycles + ") using " + nBanks + " banks",
    "" + (if (nBanks == 2) "Dual-banked" else "Single-banked"),
    "I-TLB ways    : " + cacheParams.nTLBWays + "\n")
}

