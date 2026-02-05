package boom.fdip.ifu

//******************************************************************************
// Copyright (c) 2017 - 2019, The Regents of the University of California (Regents).
// All Rights Reserved. See LICENSE and LICENSE.SiFive for license details.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Frontend
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------


import chisel3._
import chisel3.util._

import org.chipsalliance.cde.config._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.rocket._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.tile._
import freechips.rocketchip.util._
import freechips.rocketchip.util.property._

import boom.fdip.common._
import boom.fdip.exu.{CommitExceptionSignals, BranchDecode, BrUpdateInfo, BranchDecodeSignals}
import boom.fdip.util._





class IFUtoIbuf(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  val req = Decoupled(new FetchBundle)
}
// class IFUtoICache(implicit p: Parameters) extends BoomBundle
//   with HasBoomFrontendParameters
// {
//     val req = Decoupled(new ICacheReq)
//     val s1_paddr = Output(UInt(paddrBits.W)) // delayed one cycle w.r.t. req

//     val s1_kill = Output(Bool()) // delayed one cycle w.r.t. req
//     val s2_kill = Output(Bool()) // delayed two cycles; prevents I$ miss emission


//     val invalidate  = Output(Bool())
// }

class TLBtoIFU(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  val xcpt_pf_if    = Input(Bool()) // I-TLB miss (instruction fetch fault).
  val xcpt_ae_if    = Input(Bool()) // Access exception.
}

class ICachetoIfuResp(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
    val data_valid    = Input(Bool())
    val ready     = Input(Bool())
    val data    = Input(UInt((fetchBytes*8).W))
    val replay  = Input(Bool())
    val ae      = Input(Bool())

}
/**
 * Bundle passed into the FetchBuffer and used to combine multiple
 * relevant signals together.
 */

class PredecodeBundle(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  val br_infos          = new FTQBundle
  // val is_rvc_vec        = Vec(fetchWidth, Bool())
  // val is_npc_plus4_vec  = Vec(fetchWidth, Bool())
  val ftq_idx           = UInt((log2Ceil(ftqSz)+1).W)
}
class IFUtoFTQ(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  val redirect_from_fetch = Output(Bool()) // True if redirect comes from fetch (not backend)
  val redirect_target     = Output(UInt(vaddrBitsExtended.W))
  val redirect_mask       = Output(UInt(fetchWidth.W)) // mask of instructions that were fetched
  val redirect_ftq_idx    = Output(UInt((log2Ceil(ftqSz)+1).W))
  val redirect_cfi_idx    = Output(UInt(log2Ceil(fetchWidth).W))
  val redirect_btb        = Output(Bool()) // True if BTB predicted this branch
  val predecode_infos     = Valid(new PredecodeBundle)
}
class IFUtoICache(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  val f3_ready    = Output(Bool())
}
/**
 * Main Frontend module that connects the icache, TLB, fetch controller,
 * and branch prediction pipeline together.
 *
 * @param outer top level Frontend class
 */
/* 
对于ifu来说s2阶段前的流水线高度和icache耦合
 */
class BoomIFU(implicit p: Parameters) extends BoomModule()(p)
  with HasBoomCoreParameters
  with HasBoomFrontendParameters
{
  val io = IO(new Bundle{
    val fromFtq     = Flipped((new FTQToIfuIO))
    val fromICache  = new ICachetoIfuResp
    val fromTLB     = new TLBtoIFU
    val toIbuf      = new IFUtoIbuf
    val toFtq       = new IFUtoFTQ
    val toICache    = new IFUtoICache
    
    
  })

/* -------------------------------------------------------------------------- */
/*                            F0(GET REQ FROM FTQ)                            */
/* -------------------------------------------------------------------------- */

  val f0_valid    = WireInit(io.fromFtq.req.valid)
  val f0_req      = WireInit(io.fromFtq.req.bits)

  val early_resteer,backend_resteer = WireInit(false.B)
  val f0_flush,f1_flush,f2_flush,f3_flush    = WireInit(false.B)
  val f1_ready, f2_ready, f3_ready = WireInit(false.B)
  val f0_fire, f1_fire, f2_fire, f3_fire = WireInit(false.B)
  val f0_flush_by_bpu,f1_flush_by_bpu = WireInit(false.B)
  f0_flush_by_bpu := f0_valid && (io.fromFtq.flushByBpu.flushByS2(f0_req.ftq_idx)|| io.fromFtq.flushByBpu.flushByS3(f0_req.ftq_idx))
  
  f0_fire  := f0_valid && !f0_flush && f1_ready && io.fromICache.ready
  f3_flush := backend_resteer 
  f2_flush := f3_flush || early_resteer
  f1_flush := f2_flush || f1_flush_by_bpu
  f0_flush := f1_flush || f0_flush_by_bpu
  io.fromFtq.req.ready := f1_ready && io.fromICache.ready//需要等icache可以接受数据
/* -------------------------------------------------------------------------- */
/*                                     F1                                     */
/* -------------------------------------------------------------------------- */
  val f1_valid        = RegInit(false.B)//RegEnable(f0_valid, false.B,f0_fire && (!f1_flush))
  val f1_req          = RegEnable(f0_req,f0_fire && (!f1_flush))
  val f1_tlb_pf_if    = io.fromTLB.xcpt_pf_if
  val f1_tlb_ae_if    = io.fromTLB.xcpt_ae_if
  f1_flush_by_bpu := f1_valid && (io.fromFtq.flushByBpu.flushByS2(f1_req.ftq_idx)|| io.fromFtq.flushByBpu.flushByS3(f1_req.ftq_idx))
  f1_ready            := (!f1_valid)||f1_fire
  f1_fire             := f1_valid && f2_ready && !f1_flush
/* -------------------------------------------------------------------------- */
/*                        F2(ICache Resp and predeocde)                       */
/* -------------------------------------------------------------------------- */
/* 
TODO:s2阶段如果阻塞（fb 满）并且icache hit，此时会出现问题，需要保持s2阶段的icache data，
 */
  val f2_valid            = RegInit(false.B)//RegEnable(f1_valid, false.B,f1_fire && !f1_flush)
  val f2_req              = RegEnable(f1_req,f1_fire && !f1_flush)
  val f2_tlb_pf_if        = RegEnable(f1_tlb_pf_if, false.B,f1_fire && !f1_flush)
  val f2_tlb_ae_if        = RegEnable(f1_tlb_ae_if, false.B,f1_fire && !f1_flush)
  val f2_icache_resp      = io.fromICache.data
  val f2_icache_resp_val  = io.fromICache.data_valid

  val predecoder          = Module(new PreDecode)
  val prechecker          = Module(new PreChecker)
  f2_ready                := (!f2_valid) || f2_fire 
  f2_fire                 := f2_valid && f3_ready && f2_icache_resp_val && !f2_flush //icache 数据返回此时才可以进入下一级

  
  predecoder.io.req.xcpt_ae_if:= f2_tlb_ae_if
  predecoder.io.req.xcpt_pf_if:= f2_tlb_pf_if
  predecoder.io.req.valid     := f2_fire  
  predecoder.io.req.pc        := f2_req.ftq_entry.start_pc
  predecoder.io.req.data      := f2_icache_resp
  predecoder.io.req.mask      := fetchMask(f2_req.ftq_entry.start_pc)//注意f3阶段才给出最终的mask//f2_req.ftq_entry.mask

  val f2_decode_mask     = predecoder.io.resp.mask
  val f2_is_rvc          = predecoder.io.resp.is_rvc
  val f2_exp_insts       = predecoder.io.resp.exp_inst
  val f2_br_infos        = predecoder.io.resp.br_infos
  val f2_npc_plus4_mask  = predecoder.io.resp.npc_plus4_mask
  val f2_edge_inst       = predecoder.io.resp.edge_inst
  val f2_inst            = predecoder.io.resp.inst
/* -------------------------------------------------------------------------- */
/*                    F3(early resteer &send inst to ibuf)                    */
/* -------------------------------------------------------------------------- */
  val f3_valid            = RegInit(false.B)//RegEnable(f2_valid, false.B,f2_fire && !f2_flush)
  val f3_req              = RegEnable(f2_req,f2_fire && !f2_flush)
  val f3_tlb_pf_if        = RegEnable(f2_tlb_pf_if, false.B,f2_fire && !f2_flush)
  val f3_tlb_ae_if        = RegEnable(f2_tlb_ae_if, false.B,f2_fire && !f2_flush)
  val f3_npc_plus4_mask   = RegEnable(f2_npc_plus4_mask,f2_fire && !f2_flush)
  val f3_edge_inst        = RegEnable(f2_edge_inst, false.B,f2_fire && !f2_flush)

  io.toICache.f3_ready    := f3_ready
  f3_ready                := (!f3_valid)||f3_fire
  f3_fire                 := io.toIbuf.req.fire 

  val f3_decode_mask     = RegEnable(f2_decode_mask,f2_fire && !f2_flush)
  val f3_is_rvc          = RegEnable(f2_is_rvc     ,f2_fire && !f2_flush)
  val f3_exp_insts       = RegEnable(f2_exp_insts  ,f2_fire && !f2_flush)
  val f3_br_infos        = RegEnable(f2_br_infos   ,f2_fire && !f2_flush)
  val f3_inst            = RegEnable(f2_inst       ,f2_fire && !f2_flush)
  
  val f3_targs           = Wire(Vec(fetchWidth, UInt(vaddrBitsExtended.W)))
  // val f3_btb_mispredicts = Wire(Vec(fetchWidth, Bool()))

  // val f3_redirects      = Wire(Vec(fetchWidth, Bool()))
  val f3_mask           = WireInit(fetchMask(f3_req.ftq_entry.start_pc))
  val f3_br_mask        = Wire(Vec(fetchWidth, Bool()))
  val f3_final_mask     = Wire(UInt(fetchWidth.W))//最终的inst 掩码
  val f3_cfi_types      = Wire(Vec(fetchWidth, UInt(CFI_SZ.W)))
  val f3_call_mask      = Wire(Vec(fetchWidth, Bool()))
  val f3_ret_mask       = Wire(Vec(fetchWidth, Bool()))
  val f3_jal_mask       = Wire(Vec(fetchWidth, Bool()))
  val f3_jalr_mask      = Wire(Vec(fetchWidth, Bool()))
  val f3_jal_redirect   = WireInit(false.B)
  val f3_ret_redirect   = WireInit(false.B)
  val f3_target_redirect= WireInit(false.B)
  val f3_notCfi_taken_redirect = WireInit(false.B)
  val f3_isNot_valid_redirect = WireInit(false.B)
  // val f3_
  // val f3_
  val f3_fetch_bundle   = Wire(new FetchBundle)
  val f3_ctrl_mask      = WireInit(f3_br_mask.asUInt | f3_jal_mask.asUInt | f3_jalr_mask.asUInt)
  val f3_has_ctrl       = WireInit(f3_br_mask.reduce(_||_) || f3_jal_mask.reduce(_||_) ||  f3_jalr_mask.reduce(_||_))
  
  def isCtrl(cfi_idx: UInt): Bool = {
    f3_ctrl_mask(cfi_idx).asBool
  }
  def isBR(cfi_idx: UInt): Bool = {
    f3_br_mask(cfi_idx)
  }
  def isJAL(cfi_idx: UInt): Bool = {
    f3_jal_mask(cfi_idx)
  }
  //目标地址判断+分支类型判断（由于目前BTB的·tag是full tag，不会出现分支混叠，故目前不需要考虑）+是否需要修复BTB + BTB 没存储的分支
  /* 
  对于分支的重定向
  1.预测不跳转，但有jal，或者预测跳转但跳转的指令位置在jal后，此时不用考虑是否有效
  2.ret同理
  3.br和jal位置正确，但地址不对，此时一定为有效指令
  4.预测有分支但实际上无分支,
  5.预测的指令位置不是一个有效指令，

  实际上jal指令可以全权交给前端处理，目前仅修复前五种情况
   */
  val f3_cfi_idx        = Wire(UInt(log2Ceil(fetchWidth).W))
  val f3_cfi_target     = Wire(UInt(vaddrBitsExtended.W))
  val f3_cfi_valid      = Wire(Bool())
  val f3_redirect_type  = Wire(UInt(3.W))
  // //valid assign
  when(f1_flush){
    f1_valid := false.B
  }.elsewhen(f0_fire ){
    f1_valid := true.B
  }.elsewhen(f1_fire){
    f1_valid := false.B
  }

  when(f2_flush){
    f2_valid := false.B
  }.elsewhen(f1_fire ){
    f2_valid := true.B
  }.elsewhen(f2_fire){
    f2_valid := false.B
  }
  
  when(f3_flush){//下个周期的数据一定无效
    f3_valid := false.B
  }.elsewhen(f2_fire ){
    f3_valid := true.B
  }.elsewhen(f3_fire){
    f3_valid := false.B
  }

  /* 
  BTB更新
  1.分支预测jal，ret没有被识别到
  2.分支地址出错
  目前仅修复1
  TODO：add more BTB correct cases
   */ 
  val f3_btb_repair     = f3_jal_redirect || f3_ret_redirect 
  for(i <- 0 until fetchWidth){
      f3_targs (i) := Mux(f3_br_infos(i).cfi_type === CFI_JALR,
        f3_req.ftq_entry.target,
        f3_br_infos(i).target)
      /* 
      重定向：
      1.没有被识别的jal指令
      2.没有被识别的ret指令
      3.target出错（实际目前不会出现，BTB 为full tag，不会错误）
       */

      f3_br_mask(i)   := f3_br_infos(i).cfi_type === CFI_BR && f3_decode_mask(i) //得到整个block的br_mask
      f3_cfi_types(i) := f3_br_infos(i).cfi_type 
      f3_call_mask(i) := f3_br_infos(i).is_call && f3_decode_mask(i)
      f3_ret_mask(i)  := f3_br_infos(i).is_ret  && f3_decode_mask(i)
      f3_jal_mask(i)  := f3_decode_mask(i) && f3_br_infos(i).cfi_type === CFI_JAL
      f3_jalr_mask(i) := f3_decode_mask(i) &&  f3_br_infos(i).cfi_type === CFI_JALR
  }
  dontTouch(f0_req)
  dontTouch(f0_valid)
  dontTouch(f1_ready)
  dontTouch(f2_ready)
  dontTouch(f3_ready)
  dontTouch(f0_fire)
  dontTouch(f1_fire)
  dontTouch(f2_fire)
  dontTouch(f3_fire)
  dontTouch(f3_valid)
  dontTouch(f2_valid)
  dontTouch(f1_valid)
  dontTouch(f3_final_mask)
  dontTouch(f3_jal_redirect)
  dontTouch(f3_ret_redirect)
  dontTouch(f3_target_redirect)
  dontTouch(f3_targs)
  dontTouch(f3_has_ctrl)
  dontTouch(f3_ctrl_mask)
  dontTouch(f3_cfi_idx)
  dontTouch(f3_cfi_target)
  dontTouch(f3_br_mask)
  dontTouch(f3_notCfi_taken_redirect)
  // dontTouch(f3_target_redirect_cond1)
  // dontTouch(f3_target_redirect_cond2)
  // dontTouch(f3_target_redirect_cond3)
  prechecker.io.req.valid         := f3_valid && (!backend_resteer)
  prechecker.io.req.clear         := false.B
  prechecker.io.req.pc            := f3_req.ftq_entry.start_pc
  prechecker.io.req.inst_mask     := f3_decode_mask.asUInt
  prechecker.io.req.br_mask       := f3_br_mask.asUInt
  prechecker.io.req.jal_mask      := f3_jal_mask.asUInt
  prechecker.io.req.ret_mask      := f3_ret_mask.asUInt
  prechecker.io.req.target        := f3_targs
  prechecker.io.req.pred_cfi_idx  := f3_req.ftq_offset.bits
  prechecker.io.req.pred_taken    := f3_req.ftq_offset.valid
  prechecker.io.req.jalr_mask     := f3_jalr_mask.asUInt
  prechecker.io.req.rvc_mask      := f3_is_rvc.asUInt
  prechecker.io.req.pred_target   := f3_req.ftq_entry.target


  predecoder.io.req.redirect_clear:= prechecker.io.resp.clear_half&&prechecker.io.resp.redirect  || backend_resteer
  predecoder.io.req.normal_clear  := prechecker.io.resp.clear_half&&(!prechecker.io.resp.redirect) 
  early_resteer := prechecker.io.resp.redirect
  f3_final_mask:= prechecker.io.resp.inst_mask
  f3_cfi_target := prechecker.io.resp.target
  f3_cfi_idx := prechecker.io.resp.cfi_idx.bits
  f3_cfi_valid := prechecker.io.resp.cfi_idx.valid
  f3_redirect_type := prechecker.io.resp.redirect_type


  backend_resteer                                         := io.fromFtq.redirect.valid
  // early_resteer                                           := f3_valid&&(f3_jal_redirect || f3_ret_redirect || f3_target_redirect||f3_notCfi_taken_redirect||f3_isNot_valid_redirect)
  // f3_final_mask                                           := Mux(io.toFtq.predecode_infos.bits.br_infos.cfi_idx.valid,f3_decode_mask.asUInt & (MaskLower(UIntToOH(f3_redirect_idx))) ,f3_decode_mask.asUInt)
  io.toFtq.redirect_from_fetch                            := f3_valid&&(early_resteer)
  io.toFtq.redirect_target                                := f3_cfi_target
  io.toFtq.redirect_mask                                  := f3_final_mask 
  io.toFtq.redirect_ftq_idx                               := f3_req.ftq_idx
  io.toFtq.redirect_cfi_idx                               := f3_cfi_idx

  io.toFtq.redirect_btb                                   := f3_valid&&f3_btb_repair
  io.toFtq.predecode_infos := DontCare
  io.toFtq.predecode_infos.valid                          := f3_valid && !f3_flush
  io.toFtq.predecode_infos.bits.br_infos.cfi_idx.valid    := f3_valid && f3_cfi_valid
  io.toFtq.predecode_infos.bits.br_infos.cfi_idx.bits     := f3_cfi_idx
  io.toFtq.predecode_infos.bits.br_infos.cfi_taken        := f3_redirect_type === jal_fault ||  f3_redirect_type === target_fault
  io.toFtq.predecode_infos.bits.br_infos.cfi_mispredicted :=  false.B
  io.toFtq.predecode_infos.bits.br_infos.cfi_type         := f3_cfi_types(f3_cfi_idx)  
  io.toFtq.predecode_infos.bits.br_infos.cfi_is_call      := f3_call_mask(f3_cfi_idx)       
  io.toFtq.predecode_infos.bits.br_infos.cfi_is_ret       := f3_ret_mask (f3_cfi_idx)        
  io.toFtq.predecode_infos.bits.br_infos.cfi_npc_plus4    := f3_npc_plus4_mask(f3_cfi_idx)   
  io.toFtq.predecode_infos.bits.br_infos.br_mask          := f3_br_mask.asUInt & f3_final_mask.asUInt   
  io.toFtq.predecode_infos.bits.ftq_idx                   := f3_req.ftq_idx
  

  f3_fetch_bundle.pc              := f3_req.ftq_entry.start_pc     
  f3_fetch_bundle.next_pc         := f3_req.ftq_entry.target                                
  f3_fetch_bundle.edge_inst       := f3_edge_inst                              
  f3_fetch_bundle.insts           := f3_inst                            
  f3_fetch_bundle.exp_insts       := f3_exp_insts                                     
  f3_fetch_bundle.sfbs            := DontCare // now we dont care about SFB                                      
  f3_fetch_bundle.sfb_masks       := DontCare // now we dont care about SFB                                    
  f3_fetch_bundle.sfb_dests       := DontCare // now we dont care about SFB                                  
  f3_fetch_bundle.shadowable_mask := DontCare // now we dont care about SFB                                                     
  f3_fetch_bundle.shadowed_mask   := DontCare // now we dont care about SFB     
  f3_fetch_bundle.cfi_idx.valid   := f3_valid && f3_cfi_valid
  f3_fetch_bundle.cfi_idx.bits    := f3_cfi_idx                       
  f3_fetch_bundle.cfi_type        := f3_cfi_types(f3_cfi_idx)                         
  f3_fetch_bundle.cfi_is_call     := f3_call_mask(f3_cfi_idx)     
  f3_fetch_bundle.cfi_is_ret      := f3_ret_mask (f3_cfi_idx)                                                  
  f3_fetch_bundle.cfi_npc_plus4   := f3_npc_plus4_mask(f3_cfi_idx)                          
  // f3_fetch_bundle.ras_top         := //Now we dont need it                            
  f3_fetch_bundle.ftq_idx         := f3_req.ftq_idx                         
  f3_fetch_bundle.mask            := f3_final_mask.asUInt                    
  f3_fetch_bundle.br_mask         := f3_br_mask.asUInt                           
  // f3_fetch_bundle.ghist           := //Now we dont need it                             
  // f3_fetch_bundle.lhist           := DontCare                         
  f3_fetch_bundle.xcpt_pf_if      := f3_tlb_pf_if                              
  f3_fetch_bundle.xcpt_ae_if      := f3_tlb_ae_if                        
  f3_fetch_bundle.bp_debug_if_oh  := DontCare// now we dont care about Breakpoint                                     
  f3_fetch_bundle.bp_xcpt_if_oh   := DontCare// now we dont care about Breakpoint                      
  f3_fetch_bundle.end_half        := DontCare // now we dont care about SFB                       
             
  io.toIbuf.req.valid             := f3_valid && !f3_flush 
  io.toIbuf.req.bits              := f3_fetch_bundle
}
