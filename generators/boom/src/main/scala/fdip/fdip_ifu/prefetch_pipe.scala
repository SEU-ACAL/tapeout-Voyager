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

/* 
s0：接收ftq的请求，发起tlb请求
s1：接收tlb的响应，产生物理地址，对比tag

 */
class PrefetchPipeResp(implicit p: Parameters) extends BoomBundle
{
  val req         = DecoupledIO(new FtqRequestBundle)
  val flushByBpu  = new BPUFlushInfo
  val redirect    = Valid(UInt((log2Ceil(ftqSz)+1).W))
  //TODO:ADD signals

}
/* 
prefetch 只会因为mshr不足而阻塞
*/
class PrefetchPipe(implicit p: Parameters) extends BoomModule()(p)
  with HasBoomCoreParameters
  with HasBoomFrontendParameters
{
    val io = IO(new Bundle {
        val req         = Flipped(DecoupledIO(new FTQToPrefetchIO))
        val refilled    = Input(Bool())
        val s1_paddr    = Input(UInt(paddrBits.W)) // delayed one cycle w.r.t. req
        val s1_tag_hit  = Input(Bool())
        val s1_kill     = Input(Bool()) // delayed one cycle w.r.t. req 
        val flush       = Input(Bool())//后端重定向以及前端的重定向
        val prefetch_req=DecoupledIO(new ICacheMissReq())
    })


  val s1_ready,s2_ready       = WireInit(false.B)
  val s0_fire,s1_fire,s2_fire = WireInit(false.B) 
  val s0_valid      = io.req.fire
  val s0_vaddr      = WireInit(io.req.bits.fetch_pc)


  val s1_vaddr      = RegEnable(s0_vaddr,s0_fire)
  val s1_valid      = RegInit(false.B)
  val s1_idx        = io.s1_paddr(untagBits-1,blockOffBits)
  val s1_tag        = io.s1_paddr(tagBits+untagBits-1,untagBits)
  val s1_hit        = io.s1_tag_hit //如果hit不发出请求

  val s2_vaddr      = RegEnable(s1_vaddr,s1_fire && !io.flush)
  val s2_idx         = RegEnable(s1_idx,s1_fire && !io.flush)
  val s2_tag         = RegEnable(s1_tag,s1_fire && !io.flush)
  val s2_valid       = RegInit(false.B)//RegEnable(s1_valid  ,false.B,s1_fire && !io.s1_kill)
  val s2_hit         = RegEnable(s1_hit,false.B,s1_fire && !io.flush)




  when(io.flush){
    s1_valid := false.B
  }.elsewhen(s0_fire){
    s1_valid := true.B
  }.elsewhen(s1_fire){
    s1_valid := false.B
  }

  when(io.flush){
    s2_valid := false.B
  }.elsewhen(s1_fire ){
    s2_valid := true.B
  }.elsewhen(s2_fire){
    s2_valid := false.B
  }
  s0_fire           := s0_valid && s1_ready 
  s1_fire           := s1_valid && s2_ready
  s1_ready          := s1_fire || !s1_valid
  s2_ready          := s2_fire || !s2_valid
  s2_fire           := s2_valid && (s2_hit || io.prefetch_req.ready)
  
  

  dontTouch(s1_idx)
  dontTouch(s1_tag)
  dontTouch(s0_vaddr)
  dontTouch(s1_vaddr)
  dontTouch(s2_vaddr)
  dontTouch(s2_fire)
  dontTouch(s0_fire)
  dontTouch(s1_fire)
  dontTouch(s1_ready)

  val s2_miss = s2_valid && !s2_hit 
  io.req.ready :=  s1_ready && !io.refilled
  val repl_way = if (isDM) 0.U else LFSR(16, s2_miss)(log2Ceil(nWays)-1,0)
  
  io.prefetch_req.valid         := s2_miss && !io.flush && s2_valid 
  io.prefetch_req.bits.blkPaddr := Cat(s2_tag, s2_idx)
  io.prefetch_req.bits.vSetIdx  := s2_idx
  io.prefetch_req.bits.way      := repl_way
}
