package boom.fdip.ifu

import chisel3._
import chisel3.util._

import org.chipsalliance.cde.config.{Field, Parameters}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.tilelink._

import boom.fdip.common._
import boom.fdip.util._

import boom.fdip.ifu._
import java.lang



// A branch prediction for a single instruction
class BranchPrediction(implicit p: Parameters) extends BoomBundle()(p)
{
  // If this is a branch, do we take it?
  val taken           = Bool()

  // Is this a branch?
  val is_br           = Bool()
  // Is this a JAL?
  // val is_jal          = Bool()
  val is_call         = Bool()
  val is_ret          = Bool()
  val is_jalr         = Bool()//去除ret
  val is_jal          = Bool()//去除call

  val is_rvi_call     = Bool() // is the last instruction in a compressed call sequence
  // What is the target of his branch/jump? Do we know the target?
  val predicted_pc    = Valid(UInt(vaddrBitsExtended.W))


}


class BranchPredictionLiteBundle(implicit p: Parameters) extends BoomBundle()(p)
  with HasBoomFrontendParameters
{
  val pc      = UInt(vaddrBitsExtended.W)
  val valid   = Bool()
  val hasRedirect = Bool()
  val ftq_idx = UInt((log2Ceil(ftqSz)+1).W)
  val ghist   = new GlobalHistory
  val preds   = Vec(fetchWidth, new BranchPrediction)
  val meta    = Output(UInt(bpdMaxMetaLength.W))
  val lhist   = Output(UInt(localHistoryLength.W))
  
  def predTakenVec = {
    val taken_vec = WireInit(VecInit((0 until fetchWidth) map { i =>
      valid && fetchMask(pc)(i) && preds(i).predicted_pc.valid && useBPD.B && 
      (preds(i).is_jal || preds(i).is_jalr || preds(i).is_call || preds(i).is_ret ||
      (preds(i).is_br && preds(i).taken))
    }))
    taken_vec
  }
  def predTarget = {
    val taken_idx          = PriorityEncoder(predTakenVec)
    //没有taken，但地址不是nextfetch为错误行为
    val do_taken           = predTakenVec.reduce(_||_) && useBPD.B 
    val targs              = VecInit(preds.map(_.predicted_pc.bits))
    val predicted_target   = Mux(predTakenVec(taken_idx)&&useBPD.B ,
                                  targs(taken_idx),
                                  nextFetch(pc))
    predicted_target
  }
  // only used for s1 s2 stage
  def predGhist =  {
    val taken_idx          = PriorityEncoder(predTakenVec)
    val is_br_vec          = WireInit(VecInit(preds.map(p => p.is_br && p.predicted_pc.valid)))
    val predicted_ghist = ghist.update(
      is_br_vec.asUInt & fetchMask(pc),
      preds(taken_idx).taken && predTakenVec.reduce(_||_),
      preds(taken_idx).is_br,
      taken_idx,
      predTakenVec.reduce(_||_),
      pc,
      false.B,//!preds(taken_idx).is_jal,
      false.B // no need to consider jalr
    )
    predicted_ghist
  }
  def cfi_offset = {
    val offset  = Wire(Valid(UInt(log2Ceil(fetchWidth).W)))
    offset.valid := predTakenVec.reduce(_||_)
    offset.bits  := PriorityEncoder(predTakenVec)
    offset
  }
} 
class BranchPredictionRespBundle(implicit p: Parameters) extends BoomBundle()(p)
  with HasBoomFrontendParameters
{
  val f1 = (new BranchPredictionLiteBundle)
  val f2 = (new BranchPredictionLiteBundle)
  val f3 = (new BranchPredictionLiteBundle)
  // val f3_predicted_ghist = Output(new GlobalHistory)
  val f3_pred_target     = Output(UInt(vaddrBitsExtended.W))
  val f3_ras_top         = Output(UInt(vaddrBitsExtended.W))
  def selectedResp = {
    val res =
      PriorityMux(Seq(
        (f3.valid && f3.hasRedirect) -> f3,
        (f2.valid && f2.hasRedirect) -> f2,
        f1.valid                     -> f1
      ))
    res
  }
  def selectedRespIdxForFtq =
    PriorityMux(Seq(
      (f3.valid && f3.hasRedirect) -> BP_S3,
      (f2.valid && f2.hasRedirect) -> BP_S2,
      f1.valid                     -> BP_S1
    ))
  def selectedFtqentry = {
    val res = Wire(new FTQPCBundle)
    val redirects = (0 until fetchWidth) map { i =>
      selectedResp.valid && fetchMask(selectedResp.pc)(i) && selectedResp.preds(i).predicted_pc.valid &&
      (selectedResp.preds(i).is_jal || selectedResp.preds(i).is_jalr || selectedResp.preds(i).is_call ||selectedResp.preds(i).is_ret|| 
        (selectedResp.preds(i).is_br && selectedResp.preds(i).taken))
    }
    val redirect_idx = PriorityEncoder(redirects)
    val do_redirect = redirects.reduce(_||_) && useBPD.B
    val targs = VecInit(selectedResp.preds.map(_.predicted_pc.bits))
    val predicted_target = Mux(do_redirect,
                                  targs(redirect_idx),
                                  nextFetch(selectedResp.pc))
    val br_mask         = WireInit(VecInit(selectedResp.preds.map(i=>i.is_br||i.is_jal||i.is_jalr||i.is_call||i.is_ret)))
    val br_taken        = WireInit(VecInit(selectedResp.preds.map(i=>i.taken)))
    res.is_exit_branch := br_mask.reduce(_||_)
    res.is_exit_taken  := selectedResp.predTakenVec.reduce(_||_)
    res.exit_pc_offset := PriorityEncoder(selectedResp.predTakenVec)
    res.target         := Mux(f3.valid && f3.hasRedirect,f3_pred_target,predicted_target)
    res.start_pc       := selectedResp.pc
    res.mask           := fetchMask(res.start_pc)&MaskLower(UIntToOH(res.exit_pc_offset))
    res
  }
  def lastStage = f3
}

// A branch update for a fetch-width worth of instructions
class BranchPredictionUpdate(implicit p: Parameters) extends BoomBundle()(p)
  with HasBoomFrontendParameters
{
  // Indicates that this update is due to a speculated misprediction
  // Local predictors typically update themselves with speculative info
  // Global predictors only care about non-speculative updates
  val is_mispredict_update = Bool()
  val is_repair_update = Bool()
  val btb_mispredicts = UInt(fetchWidth.W)
  def is_btb_mispredict_update = btb_mispredicts =/= 0.U
  def is_commit_update = !(is_mispredict_update || is_repair_update || is_btb_mispredict_update)

  val pc            = UInt(vaddrBitsExtended.W)
  // Mask of instructions which are branches.
  // If these are not cfi_idx, then they were predicted not taken
  val br_mask       = UInt(fetchWidth.W)
  // Which CFI was taken/mispredicted (if any)
  val cfi_idx       = Valid(UInt(log2Ceil(fetchWidth).W))
  // Was the cfi taken?
  val cfi_taken     = Bool()
  // Was the cfi mispredicted from the original prediction?
  val cfi_mispredicted = Bool()
  // Was the cfi a br?
  val cfi_is_br     = Bool()
  // Was the cfi a jal/jalr?
  val cfi_is_jal  = Bool()
  // Was the cfi a jalr
  val cfi_is_jalr = Bool()
  val cfi_is_ret  = Bool()
  val cfi_is_call = Bool()

  val ghist = new GlobalHistory
  val lhist = UInt(localHistoryLength.W)


  // What did this CFI jump to?
  val target        = UInt(vaddrBitsExtended.W)

  val meta          = UInt(bpdMaxMetaLength.W)
}

// A branch update to a single bank
class BranchPredictionBankUpdate(implicit p: Parameters) extends BoomBundle()(p)
  with HasBoomFrontendParameters
{
  val is_mispredict_update     = Bool()
  val is_repair_update         = Bool()

  val btb_mispredicts  = UInt(fetchWidth.W)
  def is_btb_mispredict_update = btb_mispredicts =/= 0.U

  def is_commit_update = !(is_mispredict_update || is_repair_update || is_btb_mispredict_update)

  val pc               = UInt(vaddrBitsExtended.W)

  val br_mask          = UInt(fetchWidth.W)
  val cfi_idx          = Valid(UInt(log2Ceil(fetchWidth).W))
  val cfi_taken        = Bool()
  val cfi_mispredicted = Bool()

  val cfi_is_br        = Bool()
  val cfi_is_jal       = Bool()
  val cfi_is_jalr      = Bool()
  val cfi_is_call      = Bool()
  val cfi_is_ret       = Bool()

  val ghist            = UInt(globalHistoryLength.W)
  val lhist            = UInt(localHistoryLength.W)

  val target           = UInt(vaddrBitsExtended.W)

  val meta             = UInt(bpdMaxMetaLength.W)
}

class BranchPredictionRequest(implicit p: Parameters) extends BoomBundle()(p)
{
  val pc    = UInt(vaddrBitsExtended.W)
  // val ghist = new GlobalHistory
}


class BranchPredictionBankResponse(implicit p: Parameters) extends BoomBundle()(p)
  with HasBoomFrontendParameters
{
  val f1 = Vec(fetchWidth, new BranchPrediction)
  val f2 = Vec(fetchWidth, new BranchPrediction)
  val f3 = Vec(fetchWidth, new BranchPrediction)
}

abstract class AbstractBranchPredictor(implicit p: Parameters) extends BoomModule()(p)
  with HasBoomFrontendParameters
{
  val metaSz   = 0
  val nbpdBanks = 8 //默认8 bank
  def nInputs  = 1
  // require(nbpdBanks<=fetchWidth)
  val mems: Seq[Tuple3[String, Int, Int]]

  val io = IO(new Bundle {
    val f0_valid = Input(Bool())
    val f0_pc    = Input(UInt(vaddrBitsExtended.W))
    val f0_mask  = Input(UInt(bankWidth.W))
    // Local history not available until end of f1
    val f1_ghist = Input(UInt(globalHistoryLength.W))
    val f1_lhist = Input(UInt(localHistoryLength.W))

    val resp_in = Input(Vec(nInputs, new BranchPredictionBankResponse))
    val resp = Output(new BranchPredictionBankResponse)

    // Store the meta as a UInt, use width inference to figure out the shape
    val f3_meta = Output(UInt(bpdMaxMetaLength.W))

    val f3_fire = Input(Bool())

    val update = Input(Valid(new BranchPredictionBankUpdate))
  })
  io.resp := io.resp_in(0)

  io.f3_meta := 0.U

  val s0_idx       = fetchIdx(io.f0_pc)
  val s1_idx       = RegNext(s0_idx)
  val s2_idx       = RegNext(s1_idx)
  val s3_idx       = RegNext(s2_idx)

  val s0_valid      = io.f0_valid
  val s1_valid      = RegNext(s0_valid)
  val s2_valid      = RegNext(s1_valid)
  val s3_valid      = RegNext(s2_valid)

  val s0_mask       = io.f0_mask
  val s1_mask       = RegNext(s0_mask)
  val s2_mask       = RegNext(s1_mask)
  val s3_mask       = RegNext(s2_mask)

  val s0_pc         = io.f0_pc
  val s1_pc         = RegNext(s0_pc)

  val s0_update     = io.update
  val s0_update_idx = fetchIdx(io.update.bits.pc)
  val s0_update_valid = io.update.valid

  val s1_update     = RegNext(s0_update)
  val s1_update_idx = RegNext(s0_update_idx)
  val s1_update_valid = RegNext(s0_update_valid)
}


/* 
负责next pc和ghist维护

input :fetchwidth
process:bankwidth
output:fetchwidth
fetchwidth <= bankwidth
 */
class BranchPredictor(implicit p: Parameters) extends BoomModule()(p)
 with HasBoomFrontendParameters
{
  val io = IO(new Bundle {

    // Requests and responses
    // val f0_req = Input(Valid(new BranchPredictionRequest))
    val fromFtq       = Flipped(new FTQToBPUIO)
    val toFtq         = new BPUToFTQIO
    val reset_vector  = Input(UInt(vaddrBitsExtended.W))
    // val resp = Output(new Bundle {
    //   val f1 = new BranchPredictionBundle
    //   val f2 = new BranchPredictionBundle
    //   val f3 = new BranchPredictionBundle
    // })

    val f3_fire = Input(Bool())

    // Update
    // val update = Input(Valid(new BranchPredictionUpdate))
  })

  var total_memsize = 0
  val bpdStr = new StringBuilder
  bpdStr.append(BoomCoreStringPrefix("==Branch Predictor Memory Sizes==\n"))
  val predictor =  Module(if (useBPD) new ComposedBranchPredictorBank else new NullBranchPredictorBank)
  // (0 until nBanks) map ( b => {
  //   val m =
  //   for ((n, d, w) <- m.mems) {
  //     bpdStr.append(BoomCoreStringPrefix(f"bank$b $n: $d x $w = ${d * w / 8}"))
  //     total_memsize = total_memsize + d * w / 8
  //   }
  //   m
  // })
  // bpdStr.append(BoomCoreStringPrefix(f"Total bpd size: ${total_memsize / 1024} KB\n"))
  // override def toString: String = bpdStr.toString

  //TODO: BTB need to record call or ret so that we can use RAS and predict update
  val ras               = Module(new BoomRAS)
//如果ftq没有空间，那么s1阶段会一直保持这个pc，并且持续预测（或者使用fire发送预测请求？）
/* 
由于送入bpu的是s0阶段的请求，如果s1阶段没有fire，
 */
  val s0_pc             = WireInit(io.reset_vector)
  val s0_valid          = WireInit(false.B)
  val s0_ghist          = WireInit((0.U).asTypeOf(new GlobalHistory))
  val s0_fire, s1_fire, s2_fire, s3_fire = WireInit(false.B)
  //由于s1阶段可能由于ftq full导致预测信息无法写入，此时需要去replay pc和ghist
  val s1_replay          = WireInit(false.B)
  
  val s1_ready, s2_ready, s3_ready = WireInit(false.B)
  dontTouch(s0_valid)
  dontTouch(s0_ghist)
  val s1_pc             = RegEnable(s0_pc,s0_fire)
  val s1_clear          = WireInit(false.B)
  val s1_valid          = RegInit(false.B)
  val s1_ghist          = RegEnable(s0_ghist,s0_fire)
  // val s1_target         = Wire(UInt(vaddrBitsExtended.W))

  val s2_pc             = RegEnable(s1_pc,s1_fire)
  val s2_valid          = RegInit(false.B)//RegEnable(s1_valid,false.B,io.toFtq.resp.ready&&(!s1_clear))
  val s2_redirect       = WireInit(false.B)
  val s2_clear          = WireInit(false.B)
  val s2_ghist          = RegEnable(s1_ghist,s1_fire)
  // val s2_target         = Wire(UInt(vaddrBitsExtended.W))
  val s2_resp           = WireInit(io.toFtq.resp.bits.f2)

  val s3_pc             = RegEnable(s2_pc,s2_fire)
  val s3_valid          = RegInit(false.B)//RegEnable(s2_valid,false.B,s2_fire&&(!s2_clear))
  val s3_clear          = WireInit(false.B)
  val s3_redirect       = WireInit(false.B)
  val s3_ghist          = RegEnable(s2_ghist,s2_fire)
  val s3_resp           = WireInit(io.toFtq.resp.bits.f3)
  //实质上，只要s1阶段fire，那么s2，s3必然valid,

  //TODO:delete handshake signal
  s0_fire               := s0_valid && s1_ready
  s1_fire               := s1_valid && s2_ready && io.toFtq.resp.ready
  s2_fire               := s2_valid && s3_ready
  s3_fire               := s3_valid  
// s1阶段ready的条件：s1阶段fire，或者s1阶段无效，或者s1阶段clear（此时s1阶段数据无效）
  s1_ready              := s1_fire || !s1_valid || s1_clear
  s2_ready              := s2_fire || !s2_valid || s2_clear
  s3_ready              := s3_fire || !s3_valid || s3_clear
  
  //当clear信号来临，s1_valid 不需要被清除，因为此时s0_valid就是redirect信号，其他阶段无所谓
  //s2，s3阶段发生clear，需要清除自身的valid，假如s2发生重定向，实际上就是下一个到s2阶段的就是无效信号
  when(s0_fire){
    s1_valid := true.B
  }.elsewhen(s1_fire){
    s1_valid := false.B
  }

  when(s1_clear){
    s2_valid := false.B
  }.elsewhen(s1_fire ){
    s2_valid := true.B
  }.elsewhen(s2_fire){
    s2_valid := false.B
  }

//如果s2阶段发生clear，
  when(s2_clear){
    s3_valid := false.B
  }.elsewhen(s2_fire ){
    s3_valid := true.B
  }.elsewhen(s3_fire){
    s3_valid := false.B
  }
  s1_replay := s1_valid && !(s2_ready && io.toFtq.resp.ready)
  // val s3_target         = Wire(UInt(vaddrBitsExtended.W))
  val s3_align_pc       = fetchAlign(s3_pc)
  val s3_taken_vec = WireInit(VecInit((0 until fetchWidth) map { i =>
    s3_resp.valid && fetchMask(s3_pc)(i) && s3_resp.preds(i).predicted_pc.valid &&
    (s3_resp.preds(i).is_jal||s3_resp.preds(i).is_jalr ||s3_resp.preds(i).is_call||s3_resp.preds(i).is_ret ||
    (s3_resp.preds(i).is_br && s3_resp.preds(i).taken))
  }))
  val s3_taken_is_call = WireInit(VecInit((0 until fetchWidth) map { i =>
    s3_resp.valid && fetchMask(s3_pc)(i) && s3_resp.preds(i).predicted_pc.valid &&
    (s3_resp.preds(i).is_call)
  }))
  val s3_taken_is_rvi_call = WireInit(VecInit((0 until fetchWidth) map { i =>
    s3_resp.valid && fetchMask(s3_pc)(i) && s3_resp.preds(i).predicted_pc.valid &&
    (s3_resp.preds(i).is_call)&&s3_resp.preds(i).is_rvi_call
  }))
  val s3_taken_is_ret = WireInit(VecInit((0 until fetchWidth) map { i =>
    s3_resp.valid && fetchMask(s3_pc)(i) && s3_resp.preds(i).predicted_pc.valid &&
    (s3_resp.preds(i).is_ret)
  }))
  
  val s3_is_br     = WireInit(VecInit((0 until fetchWidth) map { i =>
    s3_resp.valid && fetchMask(s3_pc)(i) && s3_resp.preds(i).predicted_pc.valid &&
    (s3_resp.preds(i).is_br)
  }))
  // val s3_taken_idx = 
  val s3_predTarget = Mux(s3_taken_vec.reduce(_||_),
    Mux(s3_taken_is_ret(PriorityEncoder(s3_taken_vec)) && useBPD.B && useRAS.B,
      ras.io.read_addr,
      s3_resp.preds(PriorityEncoder(s3_taken_vec)).predicted_pc.bits
    ),
    nextFetch(s3_pc)
  )

  val s3_predGhist = s3_resp.ghist.update(
    s3_is_br.asUInt,
    s3_taken_vec.reduce(_||_),
    s3_resp.preds(PriorityEncoder(s3_taken_vec)).is_br,
    PriorityEncoder(s3_taken_vec),
    s3_taken_vec.reduce(_||_),
    s3_pc,
    s3_taken_is_call(PriorityEncoder(s3_taken_vec)),
    s3_taken_is_ret(PriorityEncoder(s3_taken_vec))
  )

  

  val s1_previous_pred_info    = RegNext(io.toFtq.resp.bits.f1)
  val s2_previous_pred_info    = RegNext(io.toFtq.resp.bits.f2)
  val s3_saw_s1_pred_info      = RegNext(s1_previous_pred_info)
  val f2_correct_f1_ghist     = WireInit(s1_previous_pred_info.predGhist =/=  io.toFtq.resp.bits.f2.predGhist&& enableGHistStallRepair.B && s2_valid)
  val f3_correct_f2_ghist     = WireInit(s2_previous_pred_info.predGhist =/=  io.toFtq.resp.bits.f3.predGhist&& enableGHistStallRepair.B && s3_valid)
  val f3_correct_f1_ghist     = WireInit(s3_saw_s1_pred_info.predGhist   =/=  io.toFtq.resp.bits.f3.predGhist&& enableGHistStallRepair.B && s3_valid)
  dontTouch(s1_replay)
  dontTouch(f2_correct_f1_ghist)
  dontTouch(f3_correct_f2_ghist)
  dontTouch(f3_correct_f1_ghist)
  s0_pc                 := MuxCase(io.reset_vector,
  Seq(
    (RegNext(reset.asBool) && !reset.asBool) -> io.reset_vector,
    io.fromFtq.redirect_val                  -> io.fromFtq.redirect_pc,
    (s3_redirect || f3_correct_f2_ghist)     -> s3_predTarget,
    (s2_redirect || f2_correct_f1_ghist)     -> io.toFtq.resp.bits.f2.predTarget,
    s1_replay                                -> s1_pc,
    s1_valid                                 -> io.toFtq.resp.bits.f1.predTarget
  )
  )
  s0_valid              := (RegNext(reset.asBool) && !reset.asBool) || io.fromFtq.redirect_val ||
                          s3_redirect || s2_redirect || s1_valid ||s1_replay ||f3_correct_f2_ghist || f2_correct_f1_ghist
  s0_ghist              := MuxCase((0.U).asTypeOf(new GlobalHistory),
  Seq(
    (RegNext(reset.asBool) && !reset.asBool) -> (0.U).asTypeOf(new GlobalHistory),
    io.fromFtq.redirect_val                  -> io.fromFtq.redirect_ghist,
    (s3_redirect||f3_correct_f2_ghist)       -> s3_predGhist,
    (s2_redirect||f2_correct_f1_ghist)       -> io.toFtq.resp.bits.f2.predGhist,
    s1_replay                                -> s1_ghist,                     
    s1_valid                                 -> io.toFtq.resp.bits.f1.predGhist
  )
  )
  //redirect and clear
  //其实这里还需要去做位置判断
  s2_redirect                 := io.toFtq.resp.bits.f2.valid&&(s1_previous_pred_info.valid)&&(s1_previous_pred_info.predTarget=/=io.toFtq.resp.bits.f2.predTarget)&&s2_valid
  s3_redirect                 := io.toFtq.resp.bits.f3.valid&&(s2_previous_pred_info.valid)&&(s2_previous_pred_info.predTarget=/=io.toFtq.resp.bits.f3.predTarget)&&s3_valid
  

 
  s1_clear                    := io.fromFtq.redirect_val || (s3_redirect||f3_correct_f2_ghist) || (s2_redirect||f2_correct_f1_ghist) 
  s2_clear                    := io.fromFtq.redirect_val || (s3_redirect||f3_correct_f2_ghist)
  s3_clear                    := io.fromFtq.redirect_val

  io.toFtq.resp.bits.f3_ras_top     := ras.io.read_addr
  io.toFtq.resp.bits.f1.hasRedirect := false.B
  io.toFtq.resp.bits.f2.hasRedirect := (s2_redirect||f2_correct_f1_ghist) && (! s2_clear)
  io.toFtq.resp.bits.f3.hasRedirect := (s3_redirect||f3_correct_f2_ghist) && (! s3_clear)
  io.toFtq.resp.bits.f3_pred_target := s3_predTarget

  //TODO:add update for RAS
  ras.io.read_idx                   := s3_resp.ghist.ras_idx

//predict update
  ras.io.write_valid := s3_valid && io.f3_fire && useRAS.B && s3_taken_is_call(PriorityEncoder(s3_taken_vec))
  ras.io.write_addr  := s3_align_pc + (PriorityEncoder(s3_taken_vec) << 1) + Mux(
    s3_taken_is_rvi_call(PriorityEncoder(s3_taken_vec)), 4.U, 2.U)
  ras.io.write_idx   := WrapInc(s3_resp.ghist.ras_idx, nRasEntries)
  // //这里最主要的意思就是去一个周期2 branch
/* ----------------------------------- Req ---------------------------------- */
  // def predMask(pc: UInt) = {
  //   val base = fetchAlign(pc)
  //   val idx = base.extract(log2Ceil(fetchWidth)+log2Ceil(coreInstBytes)-1, log2Ceil(coreInstBytes))//这里要求fetchwidth小于等于8
  //   val mask = WireInit(0.U(bankWidth.W))
  //   mask := ((1 << fetchWidth)-1).U << idx
  //   mask
  // }
  predictor.io.f0_valid   := s0_valid
  predictor.io.f0_pc      := fetchAlign(s0_pc)
  predictor.io.f0_mask    := fetchMask(s0_pc)
  predictor.io.f1_ghist   := RegNext(s0_ghist.histories)
  predictor.io.f1_lhist   := DontCare
  predictor.io.resp_in(0)           := (0.U).asTypeOf(new BranchPredictionBankResponse)



/* ---------------------------------- Resp ---------------------------------- */

  dontTouch(s1_previous_pred_info)
  io.toFtq.resp.bits.f1.preds    := predictor.io.resp.f1
  io.toFtq.resp.bits.f2.preds    := predictor.io.resp.f2
  io.toFtq.resp.bits.f3.preds    := predictor.io.resp.f3
  io.toFtq.resp.bits.f3.meta     := predictor.io.f3_meta
  predictor.io.f3_fire := false.B


  io.toFtq.resp.bits.f1.pc := RegNext(s0_pc)
  io.toFtq.resp.bits.f2.pc := RegNext(s1_pc)
  io.toFtq.resp.bits.f3.pc := RegNext(s2_pc)

  io.toFtq.resp.valid         := s1_fire && (!s1_clear) 
  io.toFtq.resp.bits.f1.valid := s1_fire && (!s1_clear) 
  io.toFtq.resp.bits.f1.ghist := s1_ghist

  io.toFtq.resp.bits.f1.ftq_idx:= DontCare
  

  io.toFtq.resp.bits.f2.valid   := s2_fire && (!s2_clear)
  io.toFtq.resp.bits.f2.ftq_idx := RegNext(io.fromFtq.ftq_idx)
  io.toFtq.resp.bits.f2.ghist   := s2_ghist

  io.toFtq.resp.bits.f3.valid := s3_fire && (!s3_clear)
  io.toFtq.resp.bits.f3.ftq_idx:= RegNext(RegNext(io.fromFtq.ftq_idx))
  io.toFtq.resp.bits.f3.ghist := s3_ghist


  // We don't care about meta from the f1 and f2 resps
  // Use the meta from the latest resp
  io.toFtq.resp.bits.f1.meta  := DontCare
  io.toFtq.resp.bits.f2.meta  := DontCare
  io.toFtq.resp.bits.f1.lhist := DontCare
  io.toFtq.resp.bits.f2.lhist := DontCare
  io.toFtq.resp.bits.f3.lhist := DontCare
/* --------------------------------- update --------------------------------- */
  predictor.io.update.bits.is_mispredict_update := io.fromFtq.bpdupdate.bits.is_mispredict_update
  predictor.io.update.bits.is_repair_update     := io.fromFtq.bpdupdate.bits.is_repair_update
  predictor.io.update.bits.meta             := io.fromFtq.bpdupdate.bits.meta
  predictor.io.update.bits.lhist            := io.fromFtq.bpdupdate.bits.lhist
  predictor.io.update.bits.cfi_idx.bits     := io.fromFtq.bpdupdate.bits.cfi_idx.bits
  predictor.io.update.bits.cfi_taken        := io.fromFtq.bpdupdate.bits.cfi_taken
  predictor.io.update.bits.cfi_mispredicted := io.fromFtq.bpdupdate.bits.cfi_mispredicted
  predictor.io.update.bits.cfi_is_br        := io.fromFtq.bpdupdate.bits.cfi_is_br
  predictor.io.update.bits.cfi_is_jal       := io.fromFtq.bpdupdate.bits.cfi_is_jal
  predictor.io.update.bits.cfi_is_jalr      := io.fromFtq.bpdupdate.bits.cfi_is_jalr
  predictor.io.update.bits.cfi_is_ret      := io.fromFtq.bpdupdate.bits.cfi_is_ret
  predictor.io.update.bits.cfi_is_call     := io.fromFtq.bpdupdate.bits.cfi_is_call
  predictor.io.update.bits.target           := io.fromFtq.bpdupdate.bits.target

  predictor.io.update.valid                 := io.fromFtq.bpdupdate.valid
  predictor.io.update.bits.pc               := fetchAlign(io.fromFtq.bpdupdate.bits.pc)
  predictor.io.update.bits.br_mask          := io.fromFtq.bpdupdate.bits.br_mask
  predictor.io.update.bits.btb_mispredicts  := io.fromFtq.bpdupdate.bits.btb_mispredicts
  predictor.io.update.bits.cfi_idx.valid    := io.fromFtq.bpdupdate.bits.cfi_idx.valid
  predictor.io.update.bits.ghist            := io.fromFtq.bpdupdate.bits.ghist.histories

  // when (io.fromFtq.bpdupdate.valid) {
  //   when (io.fromFtq.bpdupdate.bits.cfi_is_br && io.fromFtq.bpdupdate.bits.cfi_idx.valid) {
  //     assert(io.fromFtq.bpdupdate.bits.br_maskio.fromFtq.bpdupdate.bits.cfi_idx.bits)
  //   }
  // }

  val commit_ghist        = RegInit(0.U.asTypeOf(new GlobalHistory))
  dontTouch(commit_ghist)
  when (io.fromFtq.bpdupdate.valid && predictor.io.update.bits.is_commit_update) {
    commit_ghist := commit_ghist.update(
      predictor.io.update.bits.br_mask,
      predictor.io.update.bits.cfi_taken,
      predictor.io.update.bits.cfi_is_br,
      predictor.io.update.bits.cfi_idx.bits,
      predictor.io.update.bits.cfi_idx.valid,
      predictor.io.update.bits.pc,
      predictor.io.update.bits.cfi_is_call,
      predictor.io.update.bits.cfi_is_ret
    )
    assert(commit_ghist.histories === predictor.io.update.bits.ghist,
      "Branch Predictor Commit Update GHist does not match the expected value!")
  }
}

class NullBranchPredictorBank(implicit p: Parameters) extends AbstractBranchPredictor()(p) {
  val mems = Nil
  println("Using null branch predictor")
}


