//******************************************************************************
// Copyright (c) 2015 - 2019, The Regents of the University of California (Regents).
// All Rights Reserved. See LICENSE and LICENSE.SiFive for license details.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Fetch Target Queue (FTQ)
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//
// Each entry in the FTQ holds the fetch address and branch prediction snapshot state.
//
// TODO:
// * reduce port counts.

package boom.fdip.ifu

import chisel3._
import chisel3.util._

import org.chipsalliance.cde.config.{Parameters}
import freechips.rocketchip.util.{Str}
import boom.fdip.ifu._
import boom.fdip.common._
import boom.fdip.util._
import boom.fdip.exu._
import boom.fdip.util._
import freechips.rocketchip.tilelink.TLMessages.isA
import os.write.over

/**
 * FTQ Parameters used in configurations
 *
 * @param nEntries # of entries in the FTQ
 */
case class FtqParameters(
  nEntries: Int = 16
)

/**
 * Bundle to add to the FTQ RAM and to be used as the pass in IO
 */

class FTQBundle(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  // // TODO compress out high-order bits
  // val fetch_pc  = UInt(vaddrBitsExtended.W)
  // IDX of instruction that was predicted taken, if any
  val cfi_idx   = Valid(UInt(log2Ceil(fetchWidth).W))
  // Was the CFI in this bundle found to be taken? or not
  val cfi_taken = Bool()
  // Was this CFI mispredicted by the branch prediction pipeline?
  val cfi_mispredicted = Bool()
  // What type of CFI was taken out of this bundle
  val cfi_type = UInt(CFI_SZ.W)
  // mask of branches which were visible in this fetch bundle
  val br_mask   = UInt(fetchWidth.W)
  // This CFI is likely a CALL
  val cfi_is_call   = Bool()
  // This CFI is likely a RET
  val cfi_is_ret    = Bool()
  // Is the NPC after the CFI +4 or +2
  val cfi_npc_plus4 = Bool()
  // What was the top of the RAS that this bundle saw?
  val ras_top = UInt(vaddrBitsExtended.W)
  val ras_idx = UInt(log2Ceil(nRasEntries).W)

  // // Which bank did this start from?
  // val start_bank = UInt(1.W)

  // // Metadata for the branch predictor
  // val bpd_meta = Vec(nBanks, UInt(bpdMaxMetaLength.W))
}

class FTQPCBundle(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{

  // TODO: check mask 
  val start_pc       = UInt(vaddrBitsExtended.W)
  val mask           = UInt(fetchWidth.W)//得到end_pc
  val exit_pc_offset = UInt((fetchBytes/2).W)//以C扩展为基准
  val is_exit_branch = Bool()
  val is_exit_taken  = Bool()
  val target         = UInt(vaddrBitsExtended.W)//可以优化
}
class FtqToICacheRequestBundle(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  // // TODO compress out high-order bits
  val fetch_pc  = UInt(vaddrBitsExtended.W)
  val mask      = UInt(fetchWidth.W)
}
class FtqRequestBundle(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  // // TODO compress out high-order bits
  val ftq_entry  = (new FTQPCBundle)
  val ftq_offset = Valid(UInt((log2Ceil(fetchWidth)).W))
  val ftq_idx    = (UInt((log2Ceil(ftqSz)+1).W))
  // val target     = UInt(vaddrBitsExtended.W)
}
class IFURequestBundle(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  // // TODO compress out high-order bits
  val pfc_info   = (new FTQBundle)
  val ftq_idx    = (UInt((log2Ceil(ftqSz)+1).W))
  val cfi_idx    = Valid(UInt(log2Ceil(fetchWidth).W))
}
class SpecInfoBundle(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  // // TODO compress out high-order bits
  val ghist   = new GlobalHistory
  val ras_top = UInt(vaddrBitsExtended.W)
}
/**
 * IO to provide a port for a FunctionalUnit to get the PC of an instruction.
 * And for JALRs, the PC of the next instruction.
 */
class GetPCFromFtqIO(implicit p: Parameters) extends BoomBundle
{
  val ftq_idx   = Input(UInt((log2Ceil(ftqSz)+1).W))

  val entry     = Output(new FTQBundle)
  val ghist     = Output(new GlobalHistory)

  val pc        = Output(UInt(vaddrBitsExtended.W))
  val com_pc    = Output(UInt(vaddrBitsExtended.W))

  // the next_pc may not be valid (stalled or still being fetched)
  val next_val  = Output(Bool())
  val next_pc   = Output(UInt(vaddrBitsExtended.W))
}

class CTRLToFTQIO(implicit p: Parameters) extends BoomBundle
{
  val redirect_val    = Output(Bool())
  // val redirect_target
  val redirect_pc     = Output(UInt(vaddrBitsExtended.W))
  val redirect_ftq_idx= Output(UInt((log2Ceil(ftqSz)+1).W)) 

  val deq             = Valid(UInt((log2Ceil(ftqSz)+1).W))
  val brupdate        = Output(new BrUpdateInfo)
}

class FTQToCTRLIO(implicit p: Parameters) extends BoomBundle
{
  val get_ftq_pc = Vec(2, new GetPCFromFtqIO())
}

class FTQToICacheIO(implicit p: Parameters) extends BoomBundle
{
  val req = DecoupledIO(new FtqToICacheRequestBundle)
}

class FTQToBPUIO(implicit p: Parameters) extends BoomBundle
{
  val ftq_idx   = Output(UInt((log2Ceil(ftqSz)+1).W))

  // val ftq_full  = Output(Bool())
  val redirect_val    = Output(Bool())
  val redirect_pc     = Output(UInt(vaddrBitsExtended.W))
  val redirect_ftq_idx= Output(UInt((log2Ceil(ftqSz)+1).W)) 
  val redirect_ghist  = Output(new GlobalHistory)
  val redirect_btb_repair = Output(Bool())
  val bpdupdate = Output(Valid(new BranchPredictionUpdate))

  val ras_update = Output(Bool())
  val ras_update_idx = Output(UInt(log2Ceil(nRasEntries).W))
  val ras_update_pc  = Output(UInt(vaddrBitsExtended.W))
}

class FTQToPrefetchIO(implicit p: Parameters) extends BoomBundle
{
  val fetch_pc  = UInt(vaddrBitsExtended.W)
  val mask      = UInt(fetchWidth.W)
}

class BPUToFTQIO(implicit p: Parameters) extends BoomBundle
{
  val resp = DecoupledIO(new BranchPredictionRespBundle)
}
class BPUFlushInfo(implicit p: Parameters) extends BoomBundle
{
  val s2_redirect = Valid(UInt((log2Ceil(ftqSz)+1).W))
  val s3_redirect = Valid(UInt((log2Ceil(ftqSz)+1).W))
  def flushByS2(idx:UInt): Bool = {
    return s2_redirect.valid && (s2_redirect.bits === idx)
  }
  def flushByS3(idx:UInt): Bool = {
    return s3_redirect.valid && (s3_redirect.bits === idx)
  }
}
class FTQToIfuIO(implicit p: Parameters) extends BoomBundle
{
  val req         = DecoupledIO(new FtqRequestBundle)
  val flushByBpu  = new BPUFlushInfo
  val redirect    = Valid(UInt((log2Ceil(ftqSz)+1).W))
  //TODO:ADD signals

}
// class IfuToFTQIO(implicit p: Parameters) extends BoomBundle
// {
//   //TODO:ADD signals
//   val pd_info = DecoupledIO(new IFURequestBundle)
// }

/**
 * Queue to store the fetch PC and other relevant branch predictor signals that are inflight in the
 * processor.
 *
 * @param num_entries # of entries in the FTQ
 */
class FDIPFetchTargetQueue(implicit p: Parameters) extends BoomModule
  with HasBoomCoreParameters
  with HasBoomFrontendParameters
{
  // override val ftqSz: Int = boomParams.FDIPftq.nEntries
  assert(isPow2(ftqSz) && ftqSz >= 2)//now it onlty support pow2,
  val num_entries = ftqSz
  private val idx_sz = log2Ceil(num_entries)
  // println(f"Fetch Target Queue Size: $idx_sz")
  val io = IO(new BoomBundle {
    val fromBpu     = Flipped(new BPUToFTQIO)
    val fromBackend = Flipped(new CTRLToFTQIO)
    val fromIfu     = Flipped(new IFUtoFTQ)

    val toBackend   = new FTQToCTRLIO
    val toBPU       = new FTQToBPUIO
    val toICache    = new FTQToICacheIO
    val toPrefetch  = DecoupledIO(new FTQToPrefetchIO)
    val toIfu       = new FTQToIfuIO
    // Used to regenerate PC for trace port stuff in FireSim
    // Don't tape this out, this blows up the FTQ
    val ftq_redirect_conflict = Output(Bool())
    val ftq_meta_conflict     = Output(Bool())
    val ftq_full              = Output(Bool())
    val debug_ftq_idx  = Input(Vec(coreWidth, UInt((log2Ceil(ftqSz)+1).W)))
    val debug_fetch_pc = Output(Vec(coreWidth, UInt(vaddrBitsExtended.W)))
  })
  def GetPtr(idx: UInt,num:Int): UInt = {
    return (idx )(log2Ceil(num)-1,0)
  }
  def GetFlag(idx: UInt,num:Int): UInt = {
    return idx(log2Ceil(num))
  }
  def isAfter(idx1:UInt,idx2:UInt,num:Int): Bool = {//越小越好
    val flag1 = GetFlag(idx1,num)
    val flag2 = GetFlag(idx2,num)
    val ptr1  = GetPtr(idx1,num)
    val ptr2  = GetPtr(idx2,num)
    return Mux(flag1 === flag2, ptr1 < ptr2, ptr1 >ptr2)
  }
  def isBefore(idx1:UInt,idx2:UInt,num:Int): Bool = {//这个得出谁更老
    val flag1 = GetFlag(idx1,num)
    val flag2 = GetFlag(idx2,num)
    val ptr1  = GetPtr(idx1,num)
    val ptr2  = GetPtr(idx2,num)
    return Mux(flag1 === flag2, ptr1 > ptr2, ptr1 < ptr2)
  }
  def isFull(idx1:UInt,idx2:UInt,num:Int): Bool = {//越小越好
    val flag1 = GetFlag(idx1,num)
    val flag2 = GetFlag(idx2,num)
    val ptr1  = GetPtr(idx1,num)
    val ptr2  = GetPtr(idx2,num)
    return flag1 =/= flag2 && ptr1 === ptr2
  }
  def isEmpty(idx1:UInt,idx2:UInt,num:Int): Bool = {//越小越好
    val flag1 = GetFlag(idx1,num)
    val flag2 = GetFlag(idx2,num)
    val ptr1  = GetPtr(idx1,num)
    val ptr2  = GetPtr(idx2,num)
    return flag1 === flag2 && ptr1 === ptr2
  }
  def CirWrapInc(idx:UInt,num:Int): UInt = {//越小越好

    return Mux(GetPtr(idx,num) === (num-1).U, Cat(~GetFlag(idx,num),0.U(log2Ceil(num).W)), idx + 1.U)
  }


  val pc_mem        = Reg(Vec(num_entries, new FTQPCBundle))//后端读pc
  val meta          = Module(new SRAMHelper(num_entries, UInt(bpdMaxMetaLength.W)))//commit update
  val redirect_mem  = Module(new SRAMHelper(num_entries, new SpecInfoBundle()))//some info needed to redirect:IFU-redirect+backend-redirect+commit
  val pd_mem        = Reg(Vec(num_entries, new FTQBundle))//some info needed to redirect:IFU-redirect+backend-redirect+commit
  
  val cfi_offset    = Reg(Vec(num_entries, Valid(UInt((log2Ceil(fetchWidth)).W))))
  // val ghist         = Seq.fill(2) { SRAMHelper(num_entries, new GlobalHistory) }

  //目前对这些指针的管理仍然高度依赖于位置，位置越靠前，优先级越低，之后考虑直接使用mux来做选择
  val bpu_ptr    = RegInit(0.U((idx_sz+1).W))
  val ifu_ptr    = RegInit(0.U((idx_sz+1).W))
  val pf_ptr     = RegInit(0.U((idx_sz+1).W))
  val commit_ptr = RegInit(0.U((idx_sz+1).W))//后端提交指针
  val deq_ptr    = RegInit(0.U((idx_sz+1).W))//后端此次提交最年轻指令的ftq_idx
  val full       = isFull(commit_ptr,bpu_ptr,num_entries)


  /* -------------------------------------------------------------------------- */
  /*                                   From Bpu                                 */
  /* -------------------------------------------------------------------------- */
  io.fromBpu.resp.ready := (!full)
  when(io.toICache.req.fire){
    ifu_ptr := CirWrapInc(ifu_ptr,num_entries)
  }
  // bpu info process
  val f1_resp    = io.fromBpu.resp.bits.f1
  val f1_mask    = fetchMask(f1_resp.pc)
  

  //s2,s3阶段的重定向写入的优先级更高
  val bpu_s2_redirect = WireInit(io.fromBpu.resp.bits.f2.hasRedirect)
  val bpu_s3_redirect = WireInit(io.fromBpu.resp.bits.f3.hasRedirect)
  //PC ENQ
  val bpu_in_resp    = io.fromBpu.resp.bits.selectedResp
  val bpu_in_stage   = io.fromBpu.resp.bits.selectedRespIdxForFtq
  val bpu_in_resp_ptr= Mux(bpu_in_stage===BP_S1,bpu_ptr,bpu_in_resp.ftq_idx)
  val bpu_in_entry   = io.fromBpu.resp.bits.selectedFtqentry
  val bpu_in_wen     = (io.fromBpu.resp.fire || bpu_s2_redirect || bpu_s3_redirect ) && 
                      !(io.fromBackend.redirect_val||io.fromIfu.redirect_from_fetch)//后端重定向时不写入

  val bpu_last_stage_resp = WireInit(io.fromBpu.resp.bits.lastStage)
  val bpu_last_stage_ptr  = WireInit(io.fromBpu.resp.bits.lastStage.ftq_idx)
  val bpu_last_stage_meta = WireInit(io.fromBpu.resp.bits.lastStage.meta)
  val bpu_last_stage_ghist= WireInit(io.fromBpu.resp.bits.lastStage.ghist)
  val bpu_last_stage_wen  = WireInit(io.fromBpu.resp.bits.lastStage.valid && 
                            !(io.fromBackend.redirect_val||io.fromIfu.redirect_from_fetch))
  val bpu_last_stage_ras_top = io.fromBpu.resp.bits.f3_ras_top
  dontTouch(bpu_s2_redirect)
  dontTouch(bpu_s3_redirect)
  dontTouch(bpu_last_stage_wen)
  dontTouch(bpu_last_stage_ptr)
  dontTouch(bpu_last_stage_meta)
  dontTouch(bpu_last_stage_ghist)
  dontTouch(bpu_last_stage_resp)
  meta.io.w.wen     := bpu_last_stage_wen
  meta.io.w.waddr   := bpu_last_stage_ptr
  meta.io.w.wdata   := bpu_last_stage_meta

  //默认读优先，但如果重定向的话，写入的一定是无效信息，所以可以禁止写入
  /* 
  这里发生读写冲突，会导致更新BPU晚一个周期，对整体的性能影响有待评估
   */
  redirect_mem.io.w.wen           := bpu_last_stage_wen//bpu_in_wen&&bpu_in_stage===BP_S3&& !(io.fromBackend.redirect_val||io.fromIfu.redirect_from_fetch)
  redirect_mem.io.w.waddr         := bpu_last_stage_ptr
  redirect_mem.io.w.wdata.ghist   := bpu_last_stage_ghist
  redirect_mem.io.w.wdata.ras_top := bpu_last_stage_ras_top

  io.ftq_redirect_conflict := redirect_mem.io.w.wen && redirect_mem.io.r.req.valid         
  io.ftq_meta_conflict     := meta.io.w.wen && meta.io.r.req.valid
  io.ftq_full              := full


  when(bpu_in_wen){
    pc_mem(GetPtr(bpu_in_resp_ptr,num_entries)) := bpu_in_entry
    cfi_offset(GetPtr(bpu_in_resp_ptr,num_entries)) := (bpu_in_resp.cfi_offset)
  }
  //Bpu ptr update
  bpu_ptr := Mux(bpu_in_wen&&bpu_in_stage===BP_S1,CirWrapInc(bpu_in_resp_ptr,num_entries),bpu_ptr)
  pf_ptr  := Mux(io.toPrefetch.fire&& !isAfter(pf_ptr,ifu_ptr,num_entries),CirWrapInc(pf_ptr,num_entries),pf_ptr)
  /* --------------------------------- ptr fix -------------------------------- */
/* 
1.BPU发生重定向的BPU_PTR<=IFU_PTR,此时说明这个发生重定向的指令已经送入IFU，此时需要刷新这个block，但然后恢复指针
2.BPU_PTR>IFU_PTR,此时说明发生重定向的block并未送入IFU，此时不对IFU指针操作，也不用刷新IFU
 */
  when(bpu_s2_redirect){
    bpu_ptr := CirWrapInc(io.fromBpu.resp.bits.f2.ftq_idx,num_entries)
    when(!isBefore(io.fromBpu.resp.bits.f2.ftq_idx,ifu_ptr,num_entries)){
      ifu_ptr :=io.fromBpu.resp.bits.f2.ftq_idx
    }
    when(!isBefore(io.fromBpu.resp.bits.f2.ftq_idx,pf_ptr,num_entries)){
      pf_ptr  := io.fromBpu.resp.bits.f2.ftq_idx
    }
  }
  when(bpu_s3_redirect){
    bpu_ptr := CirWrapInc(io.fromBpu.resp.bits.f3.ftq_idx,num_entries)
    when(!isBefore(io.fromBpu.resp.bits.f3.ftq_idx,ifu_ptr,num_entries)){
      ifu_ptr :=io.fromBpu.resp.bits.f3.ftq_idx
    }
    when(!isBefore(io.fromBpu.resp.bits.f3.ftq_idx,pf_ptr,num_entries)){
      pf_ptr  := io.fromBpu.resp.bits.f3.ftq_idx
    }
  }

  //BPU other mem write
  /* 
  update :后端异常+分支预测失败+正常commit
  后端异常：直接刷新流水
  分支预测失败：此时不仅需要恢复预测失败的ghist,
  正常提交：此时会更新commit指针，但由于前端一个fetch block可能对应多个后端的block，所以commit_ptr指针更新策略
  此时弊端commit_ptr指针略过update信息，导致update失败
   */
/* -------------------------------------------------------------------------- */
/*                                  From IFU                                  */
/* -------------------------------------------------------------------------- */
//本阶段送入的br_mask一定是对的，无论分支是否错误
/* 
这里需要再议，在BTB从来没找到的分支认为没有信息，即使此时解码为br，仍然不会更新ghr
 */
  val new_entry = Wire(new FTQBundle)
  val prev_ghist = RegInit((0.U).asTypeOf(new GlobalHistory))
  val prev_entry = RegInit((0.U).asTypeOf(new FTQBundle))
  new_entry.cfi_idx           := io.fromIfu.predecode_infos.bits.br_infos.cfi_idx
  new_entry.cfi_taken         := io.fromIfu.predecode_infos.bits.br_infos.cfi_taken
  new_entry.cfi_mispredicted  := false.B
  new_entry.cfi_type          := io.fromIfu.predecode_infos.bits.br_infos.cfi_type
  new_entry.cfi_is_call       := io.fromIfu.predecode_infos.bits.br_infos.cfi_is_call
  new_entry.cfi_is_ret        := io.fromIfu.predecode_infos.bits.br_infos.cfi_is_ret
  new_entry.cfi_npc_plus4     := io.fromIfu.predecode_infos.bits.br_infos.cfi_npc_plus4
  new_entry.br_mask           := io.fromIfu.predecode_infos.bits.br_infos.br_mask 
  new_entry.ras_top           := DontCare
  new_entry.ras_idx           := DontCare
  //pfc入队只要没有full就行，这个full条件其实是pc_mem的，写入的地址来自ftq传往ifu的指针
  // io.fromIfu.predecode_infos.ready := (!full)
  when(io.fromIfu.predecode_infos.valid){
    pd_mem(GetPtr(io.fromIfu.predecode_infos.bits.ftq_idx,num_entries)) := new_entry
  }



  /* -------------------------------------------------------------------------- */
  /*                                 From Backend                               */
  /* -------------------------------------------------------------------------- */

  val bpd_update_mispredict = RegInit(false.B)
  val bpd_update_fetch      = RegInit(false.B)
  val bpd_update_commit     = RegInit(false.B)
  val do_update_commit      = WireInit(false.B)
  val bpd_update_idx        = Wire(UInt((log2Ceil(ftqSz)+1).W))
  val bpd_update_entry      = RegNext(pd_mem(bpd_update_idx))
  val bpd_entry             = WireInit(pd_mem(bpd_update_idx))
  val bpd_redirect_entry    = WireInit(pd_mem(bpd_update_idx))
  val bpd_update_pc         = RegNext(pc_mem(bpd_update_idx).start_pc)
  val bpd_update_ghist      = redirect_mem.io.r.resp.rdata.ghist //需要传入BPU修复后的
  val bpd_update_ras_top    = redirect_mem.io.r.resp.rdata.ras_top
  val bpd_update_meta       = meta.io.r.resp.rdata
  val ifu_redirect_ghist    = WireInit(bpd_update_ghist)
  val backend_redirect_ghist = WireInit(bpd_update_ghist)
  val bpd_update_target     = RegNext(pc_mem(GetPtr(CirWrapInc(bpd_update_idx,num_entries),num_entries)).start_pc)

  val ras_update_info       = RegNext(Mux(io.fromBackend.redirect_val&&io.fromBackend.brupdate.b2.mispredict,pd_mem(bpd_update_idx),new_entry))
  //只有commit阶段可能遇到读写同时发生，此时阻塞读，直到写入完成
  bpd_update_idx                     := Mux(io.fromBackend.redirect_val&&io.fromBackend.brupdate.b2.mispredict,
                            io.fromBackend.redirect_ftq_idx,Mux(io.fromIfu.redirect_from_fetch,
                            io.fromIfu.redirect_ftq_idx,commit_ptr))
  meta.io.r.req.valid                := (commit_ptr=/=deq_ptr)
  meta.io.r.req.bits.raddr           := commit_ptr

  //对于redirect_mem 读的优先级大于写，一般读是为了重定向，此时写入的一定无效
  /* 
  提交时需要去根据ghist来得到更新ctr的idx
  */
  redirect_mem.io.r.req.bits.raddr   := bpd_update_idx
  redirect_mem.io.r.req.valid        := io.fromBackend.redirect_val||io.fromIfu.redirect_from_fetch||(commit_ptr=/=deq_ptr)
  bpd_update_mispredict              := (io.fromBackend.redirect_val&&io.fromBackend.brupdate.b2.mispredict||io.fromIfu.redirect_from_fetch)
  //必须redirect和meta全部读出来，此时才可以更新
  do_update_commit                   := (!(io.fromBackend.redirect_val&&io.fromBackend.brupdate.b2.mispredict||io.fromIfu.redirect_from_fetch))&&
                                (commit_ptr=/=deq_ptr)&&redirect_mem.io.r.req.fire&&meta.io.r.req.fire//此时需要commit update
  bpd_update_commit                  := do_update_commit //第二个周期读出update信息，然后送入bpu


  deq_ptr                   := Mux(io.fromBackend.deq.valid,io.fromBackend.deq.bits,deq_ptr)
  commit_ptr                := Mux(do_update_commit,CirWrapInc(commit_ptr,num_entries),commit_ptr)

/* -------------------------------- fix entry ------------------------------- */
  // val br_update_entry
//更新指针
  when(io.fromBackend.redirect_val){
    //恢复bpu_ptr
    bpu_ptr             := CirWrapInc(io.fromBackend.redirect_ftq_idx,num_entries)
    ifu_ptr             := CirWrapInc(io.fromBackend.redirect_ftq_idx,num_entries)
    pf_ptr              := CirWrapInc(io.fromBackend.redirect_ftq_idx,num_entries)
    
    when(io.fromBackend.brupdate.b2.mispredict){
      val new_cfi_idx = (io.fromBackend.brupdate.b2.uop.pc_lob)/(coreInstBytes.U)//截断的指令属于下一个block
      bpd_redirect_entry.cfi_idx.valid    := true.B
      bpd_redirect_entry.cfi_idx.bits     := new_cfi_idx
      bpd_redirect_entry.cfi_mispredicted := true.B
      bpd_redirect_entry.cfi_taken        := io.fromBackend.brupdate.b2.taken
      bpd_redirect_entry.cfi_type         := io.fromBackend.brupdate.b2.cfi_type
      // bpd_redirect_entry.
      bpd_redirect_entry.cfi_is_call      := io.fromBackend.brupdate.b2.is_call 
      bpd_redirect_entry.cfi_is_ret       := io.fromBackend.brupdate.b2.is_ret  
    }.otherwise{
      /* 
      此时由于前端PFC，可能存储的为jal指令，但实际上，这个指令被前面的redirect打断，此时不能更新这个信息
       */
      bpd_redirect_entry.cfi_idx.valid    := false.B
      bpd_redirect_entry.cfi_mispredicted := false.B
    }
    // ras_update     := true.B
    // ras_update_pc  := redirect_entry.ras_top
    // ras_update_idx := redirect_entry.ras_idx
    pd_mem(bpd_update_idx) := bpd_redirect_entry
  }.elsewhen(io.fromIfu.redirect_from_fetch){//IFU redirect do not need to fix pd_mem
    bpu_ptr             := CirWrapInc(io.fromIfu.redirect_ftq_idx,num_entries)
    ifu_ptr             := CirWrapInc(io.fromIfu.redirect_ftq_idx,num_entries)
    pf_ptr              := CirWrapInc(io.fromIfu.redirect_ftq_idx,num_entries)
  }
  dontTouch(do_update_commit)
  dontTouch(bpd_update_commit)
  dontTouch(bpd_update_entry)
// println(f"width${ifu_ptr.getWidth}")
  /* -------------------------------------------------------------------------- */
  /*                                  To ICache                                 */
  /* -------------------------------------------------------------------------- */
  
  /* 
  送到ICache的请求需要保证ifu的指针不能跟上bpu指针
  */
  
  io.toICache.req.valid          := (!isEmpty(ifu_ptr,bpu_ptr,num_entries)) && !(io.fromBackend.redirect_val||io.fromIfu.redirect_from_fetch) && 
                                  (!(bpu_s2_redirect && !isBefore(io.fromBpu.resp.bits.f2.ftq_idx,ifu_ptr,num_entries)))&&
                                  (!(bpu_s3_redirect && !isBefore(io.fromBpu.resp.bits.f3.ftq_idx,ifu_ptr,num_entries)))
  io.toICache.req.bits.fetch_pc  := pc_mem(GetPtr(ifu_ptr,num_entries)).start_pc
  io.toICache.req.bits.mask      := pc_mem(GetPtr(ifu_ptr,num_entries)).mask
  //送出后ifu指针+1

  /* -------------------------------------------------------------------------- */
  /*                                   TO BPU                                   */
  /* -------------------------------------------------------------------------- */


  //we DONT USE loop predictor
  io.toBPU.ftq_idx := bpu_ptr
  io.toBPU.bpdupdate:=DontCare
  val cfi_idx = bpd_update_entry.cfi_idx.bits
  io.toBPU.bpdupdate.valid                     := bpd_update_commit && (bpd_update_entry.cfi_idx.valid || bpd_update_entry.br_mask =/= 0.U)
  io.toBPU.bpdupdate.bits.is_mispredict_update := !bpd_update_commit
  io.toBPU.bpdupdate.bits.is_repair_update     := false.B
  io.toBPU.bpdupdate.bits.pc                   := bpd_update_pc
  io.toBPU.bpdupdate.bits.btb_mispredicts      := 0.U
  io.toBPU.bpdupdate.bits.br_mask              := Mux(bpd_update_entry.cfi_idx.valid,
    MaskLower(UIntToOH(cfi_idx)) & bpd_update_entry.br_mask, bpd_update_entry.br_mask)
  io.toBPU.bpdupdate.bits.cfi_idx              := bpd_update_entry.cfi_idx
  io.toBPU.bpdupdate.bits.cfi_mispredicted     := bpd_update_entry.cfi_mispredicted
  io.toBPU.bpdupdate.bits.cfi_taken            := bpd_update_entry.cfi_taken
  io.toBPU.bpdupdate.bits.target               := bpd_update_target
  io.toBPU.bpdupdate.bits.cfi_is_br            := bpd_update_entry.br_mask(cfi_idx)
  io.toBPU.bpdupdate.bits.cfi_is_jal           := bpd_update_entry.cfi_type === CFI_JAL 
  io.toBPU.bpdupdate.bits.cfi_is_jalr          := bpd_update_entry.cfi_type === CFI_JALR
  io.toBPU.bpdupdate.bits.cfi_is_call          := bpd_update_entry.cfi_is_call
  io.toBPU.bpdupdate.bits.cfi_is_ret           := bpd_update_entry.cfi_is_ret
  io.toBPU.bpdupdate.bits.ghist                := bpd_update_ghist
  io.toBPU.bpdupdate.bits.lhist                := DontCare
  io.toBPU.bpdupdate.bits.meta                 := bpd_update_meta
  // when (bpd_update_commit) {


  //   // first_empty := false.B
  // }
  //redirect (
  val ifu_redirect_entry  = RegNext(new_entry)
  ifu_redirect_ghist := bpd_update_ghist.update(
    ifu_redirect_entry.br_mask.asUInt,
    ifu_redirect_entry.cfi_taken,
    ifu_redirect_entry.cfi_type === CFI_BR,
    ifu_redirect_entry.cfi_idx.bits,
    ifu_redirect_entry.cfi_idx.valid,
    ifu_redirect_entry.cfi_idx.bits + (bpd_update_pc),
    ifu_redirect_entry.cfi_is_call,
    ifu_redirect_entry.cfi_is_ret   )
  backend_redirect_ghist := bpd_update_ghist.update(
    bpd_update_entry.br_mask.asUInt,
    RegNext(io.fromBackend.brupdate.b2.taken),
    RegNext(io.fromBackend.brupdate.b2.cfi_type === CFI_BR),
    bpd_update_entry.cfi_idx.bits,
    RegNext(io.fromBackend.brupdate.b2.mispredict),
    bpd_update_pc,
    bpd_update_entry.cfi_is_call && bpd_update_entry.cfi_idx.bits === io.fromBackend.brupdate.b2.uop.pc_lob,//TODO:fix pc_lob
    bpd_update_entry.cfi_is_ret  && bpd_update_entry.cfi_idx.bits === io.fromBackend.brupdate.b2.uop.pc_lob
  )
  //TODO：添加predeocde的重定向 + RAS恢复
  io.toBPU.redirect_val                          := RegNext(io.fromBackend.redirect_val || io.fromIfu.redirect_from_fetch)      
  io.toBPU.redirect_ftq_idx                      := RegNext(Mux(io.fromBackend.redirect_val,io.fromBackend.redirect_ftq_idx,io.fromIfu.redirect_ftq_idx))  
  io.toBPU.redirect_pc                           := RegNext(Mux(io.fromBackend.redirect_val,io.fromBackend.redirect_pc,io.fromIfu.redirect_target))  
  io.toBPU.redirect_ghist                        := Mux(RegNext(io.fromBackend.redirect_val),backend_redirect_ghist,ifu_redirect_ghist)
  io.toBPU.redirect_btb_repair                   := RegNext(io.fromIfu.redirect_btb)//只有ifu的重定向才会early修复btb,其他的就是commit更新
  //RAS目前只修复由于call指令导致的错误（一般是未识别导致的）
  io.toBPU.ras_update                            := bpd_update_mispredict && (ras_update_info.cfi_is_call)
  io.toBPU.ras_update_idx                        := redirect_mem.io.r.resp.rdata.ghist.ras_idx
  io.toBPU.ras_update_pc                         := redirect_mem.io.r.resp.rdata.ras_top
/* -------------------------------------------------------------------------- */
/*                                 To Prefetch                                */
/* -------------------------------------------------------------------------- */
  io.toPrefetch.valid := (!isEmpty(pf_ptr,bpu_ptr,num_entries)) && !(io.fromBackend.redirect_val||io.fromIfu.redirect_from_fetch) 
  io.toPrefetch.bits.fetch_pc := pc_mem(GetPtr(pf_ptr,num_entries)).start_pc
  io.toPrefetch.bits.mask     := pc_mem(GetPtr(pf_ptr,num_entries)).mask
/* -------------------------------------------------------------------------- */
/*                                   To IFU                                   */
/* -------------------------------------------------------------------------- */
  io.toIfu.req.valid                      := (!isEmpty(ifu_ptr,bpu_ptr,num_entries)) && !(io.fromBackend.redirect_val||io.fromIfu.redirect_from_fetch)
  io.toIfu.req.bits.ftq_entry             := pc_mem(GetPtr(ifu_ptr,num_entries))
  io.toIfu.req.bits.ftq_idx               := ifu_ptr
  io.toIfu.flushByBpu.s2_redirect.valid   := io.fromBpu.resp.bits.f2.hasRedirect
  io.toIfu.flushByBpu.s2_redirect.bits    := io.fromBpu.resp.bits.f2.ftq_idx
  io.toIfu.flushByBpu.s3_redirect.valid   := io.fromBpu.resp.bits.f3.hasRedirect
  io.toIfu.flushByBpu.s3_redirect.bits    := io.fromBpu.resp.bits.f3.ftq_idx
  io.toIfu.redirect.valid                 := io.fromBackend.redirect_val
  io.toIfu.redirect.bits                  := io.fromBackend.redirect_ftq_idx



  io.toIfu.req.bits.ftq_offset.valid      := cfi_offset(GetPtr(ifu_ptr,num_entries)).valid
  io.toIfu.req.bits.ftq_offset.bits       := cfi_offset(GetPtr(ifu_ptr,num_entries)).bits
  /* -------------------------------------------------------------------------- */
  /*                                 TO Backend                                 */
  /* -------------------------------------------------------------------------- */
  for (i <- 0 until 2) {
    val idx = GetPtr(io.toBackend.get_ftq_pc(i).ftq_idx,num_entries)
    val next_idx = CirWrapInc(io.toBackend.get_ftq_pc(i).ftq_idx, num_entries)
    val next_is_enq = (next_idx === bpu_ptr) && io.fromBpu.resp.fire
    val next_pc = Mux(next_is_enq, bpu_in_entry.start_pc, pc_mem(GetPtr(next_idx,num_entries)).start_pc)

    io.toBackend.get_ftq_pc(i).pc        := RegNext(pc_mem(idx).start_pc)
    io.toBackend.get_ftq_pc(i).next_pc   := RegNext(next_pc)
    io.toBackend.get_ftq_pc(i).next_val  := RegNext((!isFull(next_idx,bpu_ptr,num_entries)) || next_is_enq)
    io.toBackend.get_ftq_pc(i).com_pc    := RegNext(pc_mem(Mux(io.fromBackend.deq.valid, GetPtr(io.fromBackend.deq.bits,num_entries), GetPtr(commit_ptr,num_entries))).start_pc)
    io.toBackend.get_ftq_pc(i).entry     := RegNext(pd_mem(idx))
    io.toBackend.get_ftq_pc(i).ghist     := RegNext(redirect_mem.io.r.resp.rdata.ghist)//TODO:fix it
  }

  io.debug_fetch_pc := DontCare

}
