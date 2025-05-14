package barf

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.{Field, Parameters}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.util._
import freechips.rocketchip.tile._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.subsystem.{CacheBlockBytes}
import freechips.rocketchip.rocket.{ExpandedInstruction}


object StrideStates {
  val width = 2
  def Init    = 0.U(width.W)
  def Steady  = 1.U(width.W)
  def Trans   = 2.U(width.W)
  def NoPred  = 3.U(width.W)
}

class StrideMetadata extends Bundle {
  val state = UInt(StrideStates.width.W)
    /** Metadata equality */
  def ===(rhs: UInt): Bool = state === rhs
  def ===(rhs: StrideMetadata): Bool = state === rhs.state
  def =/=(rhs: StrideMetadata): Bool = !this.===(rhs)

  def isValid(dummy: Int = 0): Bool = state > StrideStates.Init

  private def StateTrans(corr: Bool): (Bool, UInt) = {
    import StrideStates._
    MuxTLookup(Cat(corr, state), (false.B, 0.U(width.W)),
      Seq(
        Cat(true.B , Init)    -> (true.B,  Steady),
        Cat(false.B, Init)    -> (false.B, Trans),
        Cat(true.B , Steady)  -> (true.B,  Steady),
        Cat(false.B, Steady)  -> (false.B, Init),
        Cat(true.B , Trans)   -> (true.B,  Steady),
        Cat(false.B, Trans)   -> (false.B, NoPred),
        Cat(true.B , NoPred)  -> (false.B, Trans),
        Cat(false.B, NoPred)  -> (false.B, NoPred)
      )
    )
  }

  def onPref(corr: Bool): (Bool, StrideMetadata) = {
    val r = StateTrans(corr)
    (r._1, StrideMetadata(r._2))
  }

}

object StrideMetadata {
  def apply(perm: UInt) = {
    val meta = Wire(new StrideMetadata)
    meta.state := perm
    meta
  }
  def onReset = StrideMetadata(StrideStates.Init)
}

class RPTMeta(nSets: Int)(implicit override val p: Parameters) extends CoreBundle()(p) {
  val state = new StrideMetadata
  val tag   = UInt((vaddrBitsExtended - log2Ceil(nSets)).W)
  val prev_addr = UInt(coreMaxAddrBits.W)
}

class RPTStirde(nStrideBit: Int) extends Bundle {
  val stride = UInt(nStrideBit.W)
} 

class RPTBundle(nSets: Int, nStrideBit: Int)(implicit override val p: Parameters) extends CoreBundle()(p) {
  val pc = Input((UInt(vaddrBitsExtended.W)))
  val addr = Input(Valid(UInt(coreMaxAddrBits.W)))
  val read = Input(Bool())
  val s1_kill = Input(Bool())
  val stride = Output(Valid(UInt(nStrideBit.W)))
}

class RefPredicTable(nSets: Int, nStrideBit: Int)(implicit override val p: Parameters) extends CoreModule()(p) {
  val io = IO(new RPTBundle(nSets, nStrideBit))
  
  val meta = SyncReadMem(nSets, new RPTMeta(nSets))
  val delta = SyncReadMem(nSets, new RPTStirde(nStrideBit))
  
  val idSz = log2Ceil(nSets)

  // --------------------------------------------------------
  // **** Stage 0 ****
  //      Send request to PRT
  // --------------------------------------------------------
  val s0_valid = io.addr.valid & io.read
  val s0_idx = io.pc(idSz-1,0)
  val s0_addr = io.addr.bits
  val s0_tag = io.pc >> idSz

  // --------------------------------------------------------
  // **** Stage 1 ****
  //      RPT response
  // --------------------------------------------------------
  val s1_valid = RegNext(s0_valid) & !io.s1_kill
  val s1_addr  = RegEnable(s0_addr, s0_valid)
  val s1_tag   = RegEnable(s0_tag, s0_valid)
  val s1_idx   = RegEnable(s0_idx, s0_valid)

  val s1_req_rprt = delta.read(s0_idx, s0_valid).asTypeOf(new RPTStirde(nStrideBit))
  val s1_req_rmeta = meta.read(s0_idx, s0_valid).asTypeOf(new RPTMeta(nSets))

  val s1_stride = s1_req_rprt.stride
  val s1_hit = s1_req_rmeta.tag === s0_tag
  val s1_hit_valid = s1_hit & s1_valid
  val s1_prev_addr = s1_req_rmeta.prev_addr
  val s1_hit_state = Mux(s1_hit, s1_req_rmeta.state.asUInt, 0.U).asTypeOf(chiselTypeOf(StrideMetadata.onReset))
  
  val s1_new_stride = s1_addr - s1_prev_addr
  val s1_stride_corr = s1_new_stride === s1_stride
  val (s1_stride_valid, s1_new_state) = s1_hit_state.onPref(s1_stride_corr & s1_hit_valid)
  val s1_update = s1_hit_state =/= s1_new_state || s1_prev_addr =/= s1_addr

  dontTouch(s1_prev_addr)

  io.stride.valid := s1_stride_valid
  io.stride.bits := s1_stride
  
  // --------------------------------------------------------
  // **** Stage 2 ****
  //      Update or Allocate PRT 
  // --------------------------------------------------------
  val s2_update_meta = Wire(new RPTMeta(nSets))
  s2_update_meta.prev_addr := s1_addr
  s2_update_meta.state := Mux(s1_hit, s1_new_state.asUInt, 0.U).asTypeOf(chiselTypeOf(StrideMetadata.onReset))
  s2_update_meta.tag := s1_tag
  
  val s2_update_stride = Mux(s1_hit, s1_new_stride, 0.U).asTypeOf(new RPTStirde(nStrideBit))

  when(s1_valid && (s1_hit && s1_update || !s1_hit)) {
    meta.write(s1_idx, s2_update_meta)
  }

  when(s1_valid && (s1_hit && !s1_stride_corr || !s1_hit) ) {
    delta.write(s1_idx, s2_update_stride)
  }
}

