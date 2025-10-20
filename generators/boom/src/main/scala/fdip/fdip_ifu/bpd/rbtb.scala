// package boom.fdip.ifu

// import chisel3._
// import chisel3.util._

// import org.chipsalliance.cde.config.{Field, Parameters}
// import freechips.rocketchip.diplomacy._
// import freechips.rocketchip.tilelink._

// import boom.fdip.common._
// import boom.fdip.util._
// // import boom.fdip.util._
// import scala.math.min

// case class BoomRBTBParams(
//   nSets: Int = 128,
//   nWays: Int = 2
// )

// class RBTB(params: BoomRBTBParams = BoomRBTBParams())(implicit p: Parameters) extends AbstractBranchPredictor()(p)
// {
//     override val nSets         = params.nSets
//     override val nWays         = params.nWays
//     val tagSz         = vaddrBitsExtended - log2Ceil(nSets) - log2Ceil(fetchWidth) - 1

//     require(isPow2(nSets))
//     require(numBr == 2)

//     class RBTBHeadSlot extends Bundle {
//         val valid  = Bool()
//         val offset = UInt(log2Ceil(fetchWidth).W)
//         val target_off = UInt(12.W)
//     }
//     class RBTBTailSlot extends Bundle {
//         val valid  = Bool()
//         val offset = UInt(log2Ceil(fetchWidth).W)
//         val target_off = UInt(20.W)
//         // val is_br  = Bool()
//         val tail_type = UInt(3.W) // 0:call, 1:ret, 2: jal, 3: jalr, 4: branch
//         def is_call = tail_type === 0.U
//         def is_ret  = tail_type === 1.U
//         def is_jal  = tail_type === 2.U
//         def is_jalr = tail_type === 3.U
//         def is_br  = tail_type === 4.U
//     }
//     class RBTBEntry extends Bundle {
//         val valid = Bool()
//         val head = new RBTBHeadSlot
//         val tail = new RBTBTailSlot
//     }



//     class BTBMeta extends Bundle {
//         val tag   = UInt(tagSz.W)
//     }

//     class BTBPredictMeta extends Bundle {
//         val write_way = UInt(log2Ceil(nWays).W)
//     }

//     val s1_meta = Wire(new BTBPredictMeta)
//     val f3_meta = RegNext(RegNext(s1_meta))

//     io.f3_meta := f3_meta.asUInt

//     override val metaSz = s1_meta.asUInt.getWidth

//     val doing_reset = RegInit(true.B)
//     val reset_idx   = RegInit(0.U(log2Ceil(nSets).W))
//     reset_idx := reset_idx + doing_reset
//     when (reset_idx === (nSets-1).U) { doing_reset := false.B }

//     val meta     = Seq.fill(nWays){Module(new SRAMHelper(nSets, new BTBMeta))}
//     val btb      = Seq.fill(nWays) {Module(new SRAMHelper(nSets, new RBTBEntry))}


//     val s1_req_rbtb  = WireInit(0.U.asTypeOf(Vec(nWays, new RBTBEntry)))
//     val s1_req_rmeta = WireInit(0.U.asTypeOf(Vec(nWays, new BTBMeta)))
//     val s1_req_tag   = WireInit(s1_idx >> log2Ceil(nSets))

//     val entrySz = s1_req_rbtb(0).asUInt.getWidth
//     val mems = (((0 until nWays) map ({w:Int => Seq(
//         (f"btb_meta_way$w", nSets, metaSz),
//         (f"btb_data_way$w", nSets, entrySz))})).flatten )
//     dontTouch(s1_req_rbtb)
//     dontTouch(s1_req_rmeta)
//     dontTouch(s1_req_tag)

//     val s1_resp             = Wire(Vec(numBr,Valid(UInt(vaddrBitsExtended.W))))
//     val s1_is_jal           = Wire(Vec(numBr, Bool()))
//     val s1_is_br            = Wire(Vec(numBr, Bool()))
//     val s1_is_call          = Wire(Vec(numBr, Bool()))
//     val s1_is_ret           = Wire(Vec(numBr, Bool()))
//     val s1_is_jalr          = Wire(Vec(numBr, Bool()))
//     val btb_rw_conflict     = Wire(Vec(numBr, Bool()))
//     val s1_btb_rw_conflict  = RegNext(btb_rw_conflict)
// //TODO:need bypass for rbtb read
//     for (w <- 0 until nWays) {
//         meta(w).io.r.req.valid      := s0_valid && !doing_reset
//         meta(w).io.r.req.bits.raddr := s0_idx
//         s1_req_rmeta(w)             := meta(w).io.r.resp.rdata
//         btb(w).io.r.req.valid       := s0_valid && !doing_reset
//         btb(w).io.r.req.bits.raddr  := s0_idx
//         s1_req_rbtb(w)              := btb(w).io.r.resp.rdata
//         btb_rw_conflict(w)          := !btb(w).io.r.req.ready || !meta(w).io.r.req.ready
//     }
    
//     val s1_hit_ohs = VecInit((0 until nWays) map { w =>
//             s1_req_rmeta(w).tag === s1_req_tag(tagSz-1,0)
//         })

//     val s1_hits     = s1_hit_ohs.reduce(_||_)
//     val s1_hit_ways = PriorityEncoder(s1_hit_ohs)

//     for (w <- 0 until numBr) {
//         val entry_meta = s1_req_rmeta(s1_hit_ways)
//         val entry_btb  = s1_req_rbtb(s1_hit_ways)
//         s1_resp(w).valid := !doing_reset && s1_valid && s1_hits(w)
//         if(w==0){
//             s1_resp(w).bits  := (s1_pc.asSInt + entry_btb.head.target_off.asSInt).asUInt
//         }else{
//             s1_resp(w).bits  := (s1_pc.asSInt + entry_btb.tail.target_off.asSInt).asUInt
//         }
//         s1_is_br(w)  := !doing_reset && s1_resp(w).valid && (w.U===0.U||entry_btb.tail.is_br  && w.U===1.U)  
//         s1_is_jal(w) := !doing_reset && s1_resp(w).valid && entry_btb.tail.is_jal  && w.U===1.U  
//         s1_is_jalr(w):= !doing_reset && s1_resp(w).valid && entry_btb.tail.is_jalr && w.U===1.U 
//         s1_is_call(w):= !doing_reset && s1_resp(w).valid && entry_btb.tail.is_call && w.U===1.U 
//         s1_is_ret(w) := !doing_reset && s1_resp(w).valid && entry_btb.tail.is_ret  && w.U===1.U

//         io.resp.f2(w) := io.resp_in(0).f2(w)
//         io.resp.f3(w) := io.resp_in(0).f3(w)

//     }
//     when (RegNext(s1_hits.reduce(_||_))) {
//         io.resp.f2(w).predicted_pc := RegNext(s1_resp(w))
//         io.resp.f2(w).is_br        := RegNext(s1_is_br(w))
//         io.resp.f2(w).is_jal       := RegNext(s1_is_jal(w))
//         when (RegNext(s1_is_jal(w))) {
//             io.resp.f2(w).taken      := true.B
//         }
//     }
//     when (RegNext(RegNext(s1_hits(w)))) {
//     io.resp.f3(w).predicted_pc := RegNext(io.resp.f2(w).predicted_pc)
//     io.resp.f3(w).is_br        := RegNext(io.resp.f2(w).is_br)
//     io.resp.f3(w).is_jal       := RegNext(io.resp.f2(w).is_jal)
//     when (RegNext(RegNext(s1_is_jal(w)))) {
//         io.resp.f3(w).taken      := true.B
//     }
//     }
//     // val alloc_way = if (nWays > 1) {
//     //     val r_metas = Cat(VecInit(s1_req_rmeta.map { w => VecInit(w.map(_.tag)) }).asUInt, s1_req_tag(tagSz-1,0))
//     //     val l = log2Ceil(nWays)
//     //     val nChunks = (r_metas.getWidth + l - 1) / l
//     //     val chunks = (0 until nChunks) map { i =>
//     //     r_metas(min((i+1)*l, r_metas.getWidth)-1, i*l)
//     //     }
//     //     chunks.reduce(_^_)
//     // } else {
//     //     0.U
//     // }
//     // s1_meta.write_way := Mux(s1_hits.reduce(_||_),
//     //     PriorityEncoder(s1_hit_ohs.map(_.asUInt).reduce(_|_)),
//     //     alloc_way)

//     // val s1_update_cfi_idx = s1_update.bits.cfi_idx.bits
//     // val s1_update_meta    = s1_update.bits.meta.asTypeOf(new BTBPredictMeta)

//     // val max_offset_value = Cat(0.B, ~(0.U((offsetSz-1).W))).asSInt
//     // val min_offset_value = Cat(1.B,  (0.U((offsetSz-1).W))).asSInt
//     // val new_offset_value = (s1_update.bits.target.asSInt -
//     //     (s1_update.bits.pc + (s1_update.bits.cfi_idx.bits << 1)).asSInt)
//     // val offset_is_extended = (new_offset_value > max_offset_value ||
//     //                             new_offset_value < min_offset_value)


//     // val s1_update_wbtb_data  = Wire(new BTBEntry)
//     // s1_update_wbtb_data.extended := offset_is_extended
//     // s1_update_wbtb_data.offset   := new_offset_value
//     // val s1_update_wbtb_mask = (UIntToOH(s1_update_cfi_idx) &
//     //     Fill(bankWidth, s1_update.bits.cfi_idx.valid && s1_update.valid && s1_update.bits.cfi_taken && s1_update.bits.is_commit_update))

//     // val s1_update_wmeta_mask = ((s1_update_wbtb_mask | s1_update.bits.br_mask) &
//     //     (Fill(bankWidth, s1_update.valid && s1_update.bits.is_commit_update) |
//     //     (Fill(bankWidth, s1_update.valid) & s1_update.bits.btb_mispredicts)
//     //     )
//     // )
//     // val s1_update_wmeta_data = Wire(Vec(bankWidth, new BTBMeta))
//     // dontTouch(s1_update_wmeta_data)
//     // for (w <- 0 until bankWidth) {
//     //     s1_update_wmeta_data(w).tag     := Mux(s1_update.bits.btb_mispredicts(w), 0.U, s1_update_idx >> log2Ceil(nSets))
//     //     s1_update_wmeta_data(w).is_br   := s1_update.bits.br_mask(w)
//     // }

//     // for (w <- 0 until nWays) {
//     //     when (doing_reset || s1_update_meta.write_way === w.U || (w == 0 && nWays == 1).B) {
//     //     btb(w).write(
//     //         Mux(doing_reset,
//     //         reset_idx,
//     //         s1_update_idx),
//     //         Mux(doing_reset,
//     //         VecInit(Seq.fill(bankWidth) { 0.U(btbEntrySz.W) }),
//     //         VecInit(Seq.fill(bankWidth) { s1_update_wbtb_data.asUInt })),
//     //         Mux(doing_reset,
//     //         (~(0.U(bankWidth.W))),
//     //         s1_update_wbtb_mask).asBools
//     //     )
//     //     meta(w).write(
//     //         Mux(doing_reset,
//     //         reset_idx,
//     //         s1_update_idx),
//     //         Mux(doing_reset,
//     //         VecInit(Seq.fill(bankWidth) { 0.U(btbMetaSz.W) }),
//     //         VecInit(s1_update_wmeta_data.map(_.asUInt))),
//     //         Mux(doing_reset,
//     //         (~(0.U(bankWidth.W))),
//     //         s1_update_wmeta_mask).asBools
//     //     )


//     //     }
//     // }
//     // when (s1_update_wbtb_mask =/= 0.U && offset_is_extended) {
//     //     ebtb.write(s1_update_idx, s1_update.bits.target)
//     // }

// }