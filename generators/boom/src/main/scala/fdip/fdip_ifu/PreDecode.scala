package boom.fdip.ifu


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
import boom.fdip.util._
import boom.fdip.exu.{CommitExceptionSignals, BranchDecode, BrUpdateInfo, BranchDecodeSignals}
class PreDecodeReq(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
    val valid = Bool()
    val redirect_clear = Bool()
    val normal_clear = Bool()
    val data  = UInt((fetchWidth*coreInstBits).W)
    val mask  = UInt(fetchWidth.W) // which instructions are valid
    val pc    = UInt(vaddrBitsExtended.W) // address of the first instruction in
    val xcpt_pf_if = Bool() 
    val xcpt_ae_if = Bool()
}
class PreCheckerReq(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{ 
  val pc    = UInt(vaddrBitsExtended.W) // address of the first instruction in
  val valid     = Bool()
  val clear     = Bool()
  val inst_mask = UInt(fetchWidth.W)
  val target    = Vec(fetchWidth,UInt(vaddrBitsExtended.W))
  val pred_taken = Bool()
  val pred_cfi_idx = UInt(log2Ceil(fetchWidth).W)
  val pred_target = UInt(vaddrBitsExtended.W)
  val br_mask   = UInt(fetchWidth.W)
  val jal_mask  = UInt(fetchWidth.W)
  val jalr_mask = UInt(fetchWidth.W)
  val ret_mask = UInt(fetchWidth.W)
  val rvc_mask  = UInt(fetchWidth.W)
}
class PreCheckerResp(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{ 
  val redirect      = Bool()
  val clear_half    = Bool()
  val target        = UInt(vaddrBitsExtended.W)
  val inst_mask     = UInt(fetchWidth.W)
  val redirect_type = UInt(3.W)
  val cfi_idx       = Valid(UInt(log2Ceil(fetchWidth).W))
  // val jal_redirect
}
class PreDecodeResp(implicit p: Parameters) extends BoomBundle
  with HasBoomFrontendParameters
{
  val is_rvc            = (Vec(fetchWidth, Bool()))
  val mask              = (Vec(fetchWidth, Bool()))
  val npc_plus4_mask    = (Vec(fetchWidth, Bool()))
  val edge_inst         = Bool() // does the fetch packet start with a half-instruction?
  val sfbs              = Vec(fetchWidth, Bool())
  val sfb_masks         = Vec(fetchWidth, UInt((2*fetchWidth).W))
  val sfb_dests         = Vec(fetchWidth, UInt((1+log2Ceil(fetchBytes)).W))
  val shadowable_mask   = Vec(fetchWidth, Bool())
  val shadowed_mask     = Vec(fetchWidth, Bool())
  val br_infos          = (Vec(fetchWidth, new BranchDecodeSignals))
  val inst              = (Vec(fetchWidth, UInt(32.W))) // expanded instructions
  val exp_inst          = (Vec(fetchWidth, UInt(32.W))) // expanded instructions
}

class PreDecode(implicit p: Parameters) extends BoomModule()(p)
  with HasBoomCoreParameters
  with HasBoomFrontendParameters
{
    val io = IO(new Bundle {
        val req  = Input(new PreDecodeReq())
        val resp = Output(new PreDecodeResp())
    })


    val rawInsts = VecInit((0 until fetchWidth).map(i =>
      io.req.data((i+1)*16-1, i*16)
    ))
    val processInsts = WireInit(VecInit(Seq.fill(fetchWidth)(0.U(32.W))))
    val align_pc = fetchAlign(io.req.pc)
    // Tracks trailing 16b of previous fetch packet
    val inst_prev_half    = Reg(UInt(16.W))
    // Tracks if last fetchpacket contained a half-inst
    val inst_prev_is_half = RegInit(false.B)
    val is_rvc_vec        = Wire(Vec(fetchWidth, Bool()))
    val inst_mask         = Wire(Vec(fetchWidth, Bool()))
    val br_info           = Wire(Vec(fetchWidth, new BranchDecodeSignals))
    val prev_half    = WireInit(inst_prev_half)
    // Tracks if last fetchpacket contained a half-inst
    val prev_is_half = WireInit(inst_prev_is_half)
    def isRVC(inst: UInt) = (inst(1,0) =/= 3.U)
    io.resp.sfbs := DontCare
    io.resp.sfb_masks := DontCare
    io.resp.sfb_dests := DontCare
    io.resp.shadowable_mask := DontCare
    io.resp.shadowed_mask := DontCare
    for(i <- 0 until fetchWidth) {
        val brsigs = Wire(new BranchDecodeSignals)
        if(i == 0) {

            val inst0 = Cat(rawInsts(0), inst_prev_half)
            val inst1 = Cat(rawInsts(1),rawInsts(0))
            val exp_inst0 = ExpandRVC(inst0)
            val exp_inst1 = ExpandRVC(inst1)
            val pc0 = (align_pc + (i << log2Ceil(coreInstBytes)).U - 2.U)
            val pc1 = (align_pc + (i << log2Ceil(coreInstBytes)).U)

            val bpd_decoder0 = Module(new BranchDecode)
            bpd_decoder0.io.inst := exp_inst0
            bpd_decoder0.io.pc   := pc0
            val bpd_decoder1 = Module(new BranchDecode)
            bpd_decoder1.io.inst := exp_inst1
            bpd_decoder1.io.pc   := pc1

            //检查是否有上周期的half指令
            processInsts(i)      := Mux(inst_prev_is_half&& !io.req.normal_clear, exp_inst0, exp_inst1)
            brsigs               := Mux(inst_prev_is_half&& !io.req.normal_clear, bpd_decoder0.io.out, bpd_decoder1.io.out)
            inst_mask(i)         := io.req.valid && io.req.mask(i).asBool 
            io.resp.inst(i)      := Mux(inst_prev_is_half&& !io.req.normal_clear, inst0, inst1)
        }else{
            val inst                = Wire(UInt(32.W))
            val exp_inst            = ExpandRVC(inst)
            val pc                  = align_pc + (i << log2Ceil(coreInstBytes)).U
            val bpd_decoder         = Module(new BranchDecode)
            bpd_decoder.io.inst     := exp_inst
            bpd_decoder.io.pc       := pc

            
            processInsts(i) := exp_inst
            brsigs          := bpd_decoder.io.out
            if(i == fetchWidth-1){
              inst          := Cat(0.U(16.W), rawInsts(i))
            }else{
              inst          := Cat(rawInsts(i+1), rawInsts(i))
            }
            // inst            := Mux(i.U===fetchWidth.U-1.U, , Cat(rawInsts(i+1), rawInsts(i)))
            inst_mask(i)    := io.req.valid && io.req.mask(i).asBool && Mux(i.U===1.U,inst_prev_is_half && !io.req.normal_clear || !(inst_mask(0)&&(!isRVC(io.resp.inst(0)))),
                Mux(i.U===fetchWidth.U-1.U,!((inst_mask(i-1) && (!isRVC(io.resp.inst(i-1)))) || !isRVC(io.resp.inst(i))),
                !(inst_mask(i-1)&&(!isRVC(io.resp.inst(i-1))))))     
            io.resp.inst(i)      := inst                                                           
        }
        io.resp.npc_plus4_mask(i) := (if (i == 0) {
          !is_rvc_vec(i) && !(inst_prev_is_half&& !io.req.normal_clear)
        } else {
          !is_rvc_vec(i)
        })
        val offset_from_aligned_pc = (
          (i << 1).U((log2Ceil(icBlockBytes)+1).W) +
          brsigs.sfb_offset.bits -
          Mux(inst_prev_is_half && !io.req.normal_clear && (i == 0).B, 2.U, 0.U)
        )
        val lower_mask = Wire(UInt((2*fetchWidth).W))
        val upper_mask = Wire(UInt((2*fetchWidth).W))
        lower_mask := UIntToOH(i.U)
        upper_mask := UIntToOH(offset_from_aligned_pc(log2Ceil(fetchBytes)+1,1)) 

        //TODO:need to check SFB 
        io.resp.sfbs(i) := (
          inst_mask(i) &&
          brsigs.sfb_offset.valid &&
          (offset_from_aligned_pc <= (2*fetchBytes).U)
        )
        io.resp.sfb_masks(i)       := ~MaskLower(lower_mask) & ~MaskUpper(upper_mask)
        io.resp.shadowable_mask(i) := (!(io.req.xcpt_pf_if || io.req.xcpt_ae_if ) &&
                                              inst_mask(i) &&
                                              (brsigs.shadowable || !inst_mask(i)))
        io.resp.sfb_dests(i)       := offset_from_aligned_pc
        is_rvc_vec(i) := isRVC(io.resp.inst(i))
        br_info(i)    := brsigs
    }
    /* 
    最后一条指令是否为half
    首先这条指令一定是RVI指令，
    之后：
    1.如果前一条指令是RVC，此时高位的mask为（0，1，？）
    2.如果前一条指令是RVI，此时高位mask为（0，0，1）
    
     */
    prev_is_half      := !isRVC(io.resp.inst(fetchWidth-1)) && !(inst_mask(fetchWidth-2) && (!isRVC(io.resp.inst(fetchWidth-2))))
    prev_half         := Mux(prev_is_half,rawInsts(fetchWidth-1), 0.U)
    when(io.req.redirect_clear) {
        inst_prev_half    := 0.U
        inst_prev_is_half := false.B
    }.elsewhen(io.req.valid) {
        inst_prev_half    := prev_half
        inst_prev_is_half := prev_is_half
    }.elsewhen(io.req.normal_clear) {
        inst_prev_half    := 0.U
        inst_prev_is_half := false.B
    }
    io.resp.exp_inst := processInsts
    io.resp.is_rvc    := is_rvc_vec
    io.resp.mask      := inst_mask
    io.resp.br_infos  := br_info
    io.resp.edge_inst := inst_prev_is_half && io.req.valid && (!io.req.redirect_clear)&&(!io.req.normal_clear)

}

class PreChecker(implicit p: Parameters) extends BoomModule()(p)
  with HasBoomCoreParameters
  with HasBoomFrontendParameters
{
    val io = IO(new Bundle {
        val req  = Input(new PreCheckerReq())
        val resp = Output(new PreCheckerResp())
    })
  val jal_redirect          = WireInit(false.B)
  val ret_redirect          = WireInit(false.B)
  val target_redirect       = WireInit(false.B)
  val notCfi_taken_redirect = WireInit(false.B)
  val isNot_valid_redirect  = WireInit(false.B)
  val retTarget             = WireInit(0.U(vaddrBitsExtended.W))
  val notCfi_target         = WireInit(0.U(vaddrBitsExtended.W))
  val notValid_target       = WireInit(0.U(vaddrBitsExtended.W))
  val seqTarget             = WireInit(0.U(vaddrBitsExtended.W))
  val redirectTarget        = WireInit(0.U(vaddrBitsExtended.W))
  val jal_mask              = io.req.jal_mask
  val jalr_mask             = io.req.jalr_mask
  val ret_mask              = io.req.ret_mask
  val br_mask               = io.req.br_mask
  
  val decode_mask = io.req.inst_mask

  val ctrl_mask   = jal_mask | br_mask | jalr_mask
  val target      = io.req.target
  val pred_target = io.req.pred_target

  jal_redirect       := io.req.pred_taken&&(PriorityEncoder(jal_mask)<io.req.pred_cfi_idx) && 
                          (PriorityEncoder(jal_mask)>=PriorityEncoder(decode_mask)) || 
                          (!io.req.pred_taken)&&(jal_mask=/=0.U)
  ret_redirect       := io.req.pred_taken&&(PriorityEncoder(ret_mask)<io.req.pred_cfi_idx) && 
                          (PriorityEncoder(ret_mask)>=PriorityEncoder(decode_mask)) || 
                          (!io.req.pred_taken)&&(ret_mask=/=0.U)

  target_redirect   := io.req.pred_taken&&
  ((io.req.pred_cfi_idx===PriorityEncoder(jal_mask))&&
  target(PriorityEncoder(jal_mask)) =/= pred_target ||
  io.req.pred_cfi_idx<PriorityEncoder(jal_mask)&&br_mask(io.req.pred_cfi_idx).asBool&&
  target(io.req.pred_cfi_idx) =/= pred_target
  )&& ctrl_mask=/=0.U
  notCfi_taken_redirect        := io.req.pred_taken && !ctrl_mask(io.req.pred_cfi_idx).asBool && decode_mask(io.req.pred_cfi_idx)
  isNot_valid_redirect         := io.req.pred_taken && (!decode_mask(io.req.pred_cfi_idx)) 

  // val f3_corret_predecode = WireInit(f3_valid&&(f3_target_redirect||f3_jal_redirect || f3_ret_redirect)|| backend_resteer)
  // // // val f3_target_redirect_cond4 = !f3_req.ftq_offset.valid && f3_has_ctrl && (f3_req.ftq_entry.target=/=f3_br_infos(PriorityEncoder(f3_br_mask)).target)
  // // f3_target_redirect    :=  f3_target_redirect_cond1 || f3_target_redirect_cond2 || f3_target_redirect_cond3 //|| f3_target_redirect_cond4
  // assert(!(!f3_req.ftq_offset.valid && f3_req.ftq_entry.target=/=nextFetch(f3_req.ftq_entry.start_pc)&&f3_valid), "No branch But target is not nextpc")
                            
  // predecoder.io.req.clear:= f3_corret_predecode                          
  // val f3_target_redirect_idx = Mux()
  val cfi_valid         = jal_redirect  || target_redirect || (io.req.pred_taken && !(notCfi_taken_redirect || isNot_valid_redirect))
  val jal_first         = PriorityEncoder(jal_mask) < PriorityEncoder(ret_mask)
  val cfi_idx           = MuxCase(io.req.pred_cfi_idx, Seq(
                              (jal_redirect ) -> PriorityEncoder(jal_mask),
                              (target_redirect) -> io.req.pred_cfi_idx,
                              (io.req.pred_taken && !(notCfi_taken_redirect || isNot_valid_redirect)) -> io.req.pred_cfi_idx
                            )) 
                      
  retTarget       := fetchAlign(io.req.pc) + PriorityEncoder(ret_mask)*coreInstBytes.U+Mux(io.req.rvc_mask(PriorityEncoder(ret_mask)),2.U,4.U)
  notCfi_target   := fetchAlign(io.req.pc) + (io.req.pred_cfi_idx)*coreInstBytes.U+Mux(io.req.rvc_mask(io.req.pred_cfi_idx),2.U,4.U)
  notValid_target := fetchAlign(io.req.pc) + (io.req.pred_cfi_idx)*coreInstBytes.U+2.U
  seqTarget       := Mux(ret_redirect, retTarget,
                      Mux(notCfi_taken_redirect, notCfi_target,
                          Mux(isNot_valid_redirect, notValid_target,
                              nextFetch(io.req.pc))))
  redirectTarget := Mux(jal_redirect || target_redirect,target(cfi_idx),Mux(notCfi_taken_redirect || isNot_valid_redirect || ret_redirect,seqTarget,io.req.pred_target) )
  val final_mask        = MuxCase(decode_mask,Seq(
                              (jal_redirect  || target_redirect)            -> (decode_mask & MaskLower(UIntToOH(cfi_idx))) ,
                              ret_redirect                                  -> (decode_mask & MaskLower(UIntToOH(PriorityEncoder(ret_mask)))),
                              (notCfi_taken_redirect || isNot_valid_redirect) -> (decode_mask & MaskLower(UIntToOH(io.req.pred_cfi_idx))),
                              (io.req.pred_taken && !(notCfi_taken_redirect || isNot_valid_redirect))  -> (decode_mask & MaskLower(UIntToOH(io.req.pred_cfi_idx)))
                              ))
    // Mux(cfi_valid,decode_mask & MaskLower(UIntToOH(redirect_idx)) ,
    //                           Mux(ret_redirect,decode_mask & (MaskLower(UIntToOH(PriorityEncoder(ret_mask)))),
    //                           Mux(notCfi_taken_redirect||isNot_valid_redirect,decode_mask & (MaskLower(UIntToOH(io.req.pred_cfi_idx))),
    //                               decode_mask)))
  io.resp.redirect      := io.req.valid&&(jal_redirect || target_redirect || ret_redirect || notCfi_taken_redirect || isNot_valid_redirect)
  io.resp.target        := redirectTarget 

  io.resp.cfi_idx.valid := io.req.valid&&cfi_valid
  io.resp.cfi_idx.bits  := cfi_idx
  io.resp.inst_mask     := final_mask
  io.resp.redirect_type := MuxCase(0.U,Seq(
                              jal_redirect            -> jal_fault,
                              (target_redirect)       -> target_fault,
                              (ret_redirect)          -> ret_fault,
                              (notCfi_taken_redirect) -> notcfi_fault,
                              (isNot_valid_redirect)  -> notvalid_fault
                            ))
  io.resp.clear_half    := io.req.valid&&(jal_redirect || 
                                          target_redirect || 
                                          ret_redirect || 
                                          notCfi_taken_redirect || 
                                          isNot_valid_redirect&&(io.req.pred_cfi_idx===(fetchWidth-1).U && !io.req.rvc_mask(fetchWidth-1))||
                                          io.req.pred_taken && !(notCfi_taken_redirect || isNot_valid_redirect))
                          
}