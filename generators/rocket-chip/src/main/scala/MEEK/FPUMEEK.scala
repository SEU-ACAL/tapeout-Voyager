// See LICENSE.Berkeley for license details.
// See LICENSE.SiFive for license details.

package freechips.rocketchip.meek

import chisel3._
import chisel3.util._
import chisel3.{DontCare, WireInit, withClock, withReset}
import chisel3.experimental.SourceInfo
import chisel3.experimental.dataview._
import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.rocket._
import freechips.rocketchip.rocket.Instructions._
import freechips.rocketchip.util._
import freechips.rocketchip.util.property
import freechips.rocketchip.tile._


class FPUCoreIOMEEK(implicit p: Parameters) extends CoreBundle()(p) {
  val hartid = Input(UInt(hartIdLen.W))
  val time = Input(UInt(xLen.W))

  val inst = Input(Bits(32.W))
  val fromint_data = Input(Bits(xLen.W))

  val fcsr_rm = Input(Bits(FPConstants.RM_SZ.W))
  val fcsr_flags = Valid(Bits(FPConstants.FLAGS_SZ.W))

  val v_sew = Input(UInt(3.W))

  val store_data = Output(Bits(fLen.W))
  val toint_data = Output(Bits(xLen.W))

  val ll_resp_val = Input(Bool())
  val ll_resp_type = Input(Bits(3.W))
  val ll_resp_tag = Input(UInt(5.W))
  val ll_resp_data = Input(Bits(fLen.W))

  val valid = Input(Bool())
  val fcsr_rdy = Output(Bool())
  val nack_mem = Output(Bool())
  val illegal_rm = Output(Bool())
  val killx = Input(Bool())
  val killm = Input(Bool())
  val dec = Output(new FPUCtrlSigs())
  val sboard_set = Output(Bool())
  val sboard_clr = Output(Bool())
  val sboard_clra = Output(UInt(5.W))

  // val keep_clock_enabled = Input(Bool())
//===== GuardianCouncil Function: Start ====//
  // val keep_clock_enabled = Input(Bool())
  /* R Features */
  val r_farf_bits = Input(UInt(64.W))
  val r_farf_idx = Input(UInt(8.W))
  val r_farf_valid = Input(UInt(1.W))
  val farfs = Output(Vec(32, UInt(64.W)))
  val retire = Input(UInt(1.W))
  val keep_clock_enabled        = Input(Bool())
  val core_trace                = Input(Bool())
  val checker_mode              = Input(Bool())
  val if_overtaking             = Input(Bool())
  val if_overtaking_next_cycle  = Input(Bool())
  val fpu_inflight              = Output(Bool())
//===== GuardianCouncil Function: END ====//
}

class FPUIOMEEK(implicit p: Parameters) extends FPUCoreIOMEEK ()(p) {
  val cp_req = Flipped(Decoupled(new FPInput())) //cp doesn't pay attn to kill sigs
  val cp_resp = Decoupled(new FPResult())
}




class FPUMEEK(cfg: FPUParams)(implicit p: Parameters) extends FPUModule()(p) {
  val io = IO(new FPUIOMEEK)

  val (useClockGating, useDebugROB) = coreParams match {
    case r: RocketCoreParams =>
      val sz = if (r.debugROB.isDefined) r.debugROB.get.size else 1
      (r.clockGate, sz < 1)
    case _ => (false, false)
  }
  val clock_en_reg = Reg(Bool())
  val clock_en = clock_en_reg || io.cp_req.valid
  val gated_clock =
    if (!useClockGating) clock
    else ClockGate(clock, clock_en, "fpu_clock_gate")

  val fp_decoder = Module(new FPUDecoder)
  fp_decoder.io.inst := io.inst
  val id_ctrl = WireInit(fp_decoder.io.sigs)
  coreParams match { case r: RocketCoreParams => r.vector.map(v => {
    val v_decode = v.decoder(p) // Only need to get ren1
    v_decode.io.inst := io.inst
    v_decode.io.vconfig := DontCare // core deals with this
    when (v_decode.io.legal && v_decode.io.read_frs1) {
      id_ctrl.ren1 := true.B
      id_ctrl.swap12 := false.B
      id_ctrl.toint := true.B
      id_ctrl.typeTagIn := I
      id_ctrl.typeTagOut := Mux(io.v_sew === 3.U, D, S)
    }
    when (v_decode.io.write_frd) { id_ctrl.wen := true.B }
  })}

  val ex_reg_valid = RegNext(io.valid, false.B)
  val ex_reg_inst = RegEnable(io.inst, io.valid)
  val ex_reg_ctrl = RegEnable(id_ctrl, io.valid)
  val ex_ra = List.fill(3)(Reg(UInt()))

  // load/vector response
  val load_wb = RegNext(io.ll_resp_val)
  val load_wb_typeTag = RegEnable(io.ll_resp_type(1,0) - typeTagWbOffset, io.ll_resp_val)
  val load_wb_data = RegEnable(io.ll_resp_data, io.ll_resp_val)
  val load_wb_tag = RegEnable(io.ll_resp_tag, io.ll_resp_val)

  class FPUImpl { // entering gated-clock domain

  val req_valid = ex_reg_valid || io.cp_req.valid
  val ex_cp_valid = io.cp_req.fire
  val mem_cp_valid = RegNext(ex_cp_valid, false.B)
  val wb_cp_valid = RegNext(mem_cp_valid, false.B)
  val mem_reg_valid = RegInit(false.B)
  val killm = (io.killm || io.nack_mem) && !mem_cp_valid
  // Kill X-stage instruction if M-stage is killed.  This prevents it from
  // speculatively being sent to the div-sqrt unit, which can cause priority
  // inversion for two back-to-back divides, the first of which is killed.
  val killx = io.killx || mem_reg_valid && killm
  mem_reg_valid := ex_reg_valid && !killx || ex_cp_valid
  val mem_reg_inst = RegEnable(ex_reg_inst, ex_reg_valid)
  val wb_reg_valid = RegNext(mem_reg_valid && (!killm || mem_cp_valid), false.B)

  val cp_ctrl = Wire(new FPUCtrlSigs)
  cp_ctrl :<>= io.cp_req.bits.viewAsSupertype(new FPUCtrlSigs)
  io.cp_resp.valid := false.B
  io.cp_resp.bits.data := 0.U
  io.cp_resp.bits.exc := DontCare

  val ex_ctrl = Mux(ex_cp_valid, cp_ctrl, ex_reg_ctrl)
  val mem_ctrl = RegEnable(ex_ctrl, req_valid)
  val wb_ctrl = RegEnable(mem_ctrl, mem_reg_valid)

  // CoreMonitorBundle to monitor fp register file writes
  val frfWriteBundle = Seq.fill(2)(WireInit(new CoreMonitorBundle(xLen, fLen), DontCare))
  frfWriteBundle.foreach { i =>
    i.clock := clock
    i.reset := reset
    i.hartid := io.hartid
    i.timer := io.time(31,0)
    i.valid := false.B
    i.wrenx := false.B
    i.wrenf := false.B
    i.excpt := false.B
  }

  // regfile
  val regfile = Mem(32, Bits((fLen+1).W))
  // when (load_wb) {
  //   val wdata = recode(load_wb_data, load_wb_typeTag)
  //   regfile(load_wb_tag) := wdata
  //   assert(consistent(wdata))
  //   if (enableCommitLog)
  //     printf("f%d p%d 0x%x\n", load_wb_tag, load_wb_tag + 32.U, ieee(wdata))
  //   if (useDebugROB)
  //     DebugROB.pushWb(clock, reset, io.hartid, load_wb, load_wb_tag + 32.U, ieee(wdata))
  //   frfWriteBundle(0).wrdst := load_wb_tag
  //   frfWriteBundle(0).wrenf := true.B
  //   frfWriteBundle(0).wrdata := ieee(wdata)
  // }
//===== GuardianCouncil Function: Start ====//
  for (i <-0 until 32) { 
    io.farfs(i) := ieee(regfile(i))
  }
  val retire_1cycle = Reg(Bool())
  val retire_2cycle = Reg(Bool())
  val wen_1cycle = RegInit(0.U(3.W))
  val wen_2cycle = RegInit(0.U(3.W))

  // There is one cycle delay for the F-REG's loading
  val r_cannot_load_wb = Wire(Bool())
  r_cannot_load_wb := Mux(!io.checker_mode, false.B, Mux(retire_1cycle, false.B, true.B))

  when (load_wb && !r_cannot_load_wb) {
    val wdata = recode(load_wb_data, load_wb_typeTag)
    regfile(load_wb_tag) := wdata
    assert(consistent(wdata))
    /*
    if (GH_GlobalParams.GH_DEBUG == 1) {
    when (io.core_trace.asBool) {
      printf(midas.targetutils.SynthesizePrintf("FLT-LD: f%d p%d 0x%x\n", load_wb_tag, load_wb_tag + 32, load_wb_data))
    }
    }*/
    frfWriteBundle(0).wrdst := load_wb_tag
    frfWriteBundle(0).wrenf := true.B
    frfWriteBundle(0).wrdata := ieee(wdata)
  } .elsewhen (io.r_farf_valid === 1.U) {
    val r_farf_wbtype = WireInit(0.U(2.W))
    // FFFFr_farf_wbtype := 1.U
    r_farf_wbtype := Mux((io.r_farf_bits(63, 32) === "hFFFFFFFF".U), 0.U, 1.U)
    val r_farf_wb = recode(io.r_farf_bits, r_farf_wbtype)
    regfile(io.r_farf_idx) := r_farf_wb
  }
//===== GuardianCouncil Function: End ====//
  val ex_rs = ex_ra.map(a => regfile(a))
  when (io.valid) {
    when (id_ctrl.ren1) {
      when (!id_ctrl.swap12) { ex_ra(0) := io.inst(19,15) }
      when (id_ctrl.swap12) { ex_ra(1) := io.inst(19,15) }
    }
    when (id_ctrl.ren2) {
      when (id_ctrl.swap12) { ex_ra(0) := io.inst(24,20) }
      when (id_ctrl.swap23) { ex_ra(2) := io.inst(24,20) }
      when (!id_ctrl.swap12 && !id_ctrl.swap23) { ex_ra(1) := io.inst(24,20) }
    }
    when (id_ctrl.ren3) { ex_ra(2) := io.inst(31,27) }
  }
  val ex_rm = Mux(ex_reg_inst(14,12) === 7.U, io.fcsr_rm, ex_reg_inst(14,12))

  def fuInput(minT: Option[FType]): FPInput = {
    val req = Wire(new FPInput)
    val tag = ex_ctrl.typeTagIn
    req.viewAsSupertype(new Bundle with HasFPUCtrlSigs) :#= ex_ctrl.viewAsSupertype(new Bundle with HasFPUCtrlSigs)
    req.rm := ex_rm
    req.in1 := unbox(ex_rs(0), tag, minT)
    req.in2 := unbox(ex_rs(1), tag, minT)
    req.in3 := unbox(ex_rs(2), tag, minT)
    req.typ := ex_reg_inst(21,20)
    req.fmt := ex_reg_inst(26,25)
    req.fmaCmd := ex_reg_inst(3,2) | (!ex_ctrl.ren3 && ex_reg_inst(27))
    when (ex_cp_valid) {
      req := io.cp_req.bits
      when (io.cp_req.bits.swap12) {
        req.in1 := io.cp_req.bits.in2
        req.in2 := io.cp_req.bits.in1
      }
      when (io.cp_req.bits.swap23) {
        req.in2 := io.cp_req.bits.in3
        req.in3 := io.cp_req.bits.in2
      }
    }
    req
  }

  val sfma = Module(new FPUFMAPipe(cfg.sfmaLatency, FType.S))
  sfma.io.in.valid := req_valid && ex_ctrl.fma && ex_ctrl.typeTagOut === S
  sfma.io.in.bits := fuInput(Some(sfma.t))

  val fpiu = Module(new FPToInt)
  fpiu.io.in.valid := req_valid && (ex_ctrl.toint || ex_ctrl.div || ex_ctrl.sqrt || (ex_ctrl.fastpipe && ex_ctrl.wflags))
  fpiu.io.in.bits := fuInput(None)
  io.store_data := fpiu.io.out.bits.store
  io.toint_data := fpiu.io.out.bits.toint
  when(fpiu.io.out.valid && mem_cp_valid && mem_ctrl.toint){
    io.cp_resp.bits.data := fpiu.io.out.bits.toint
    io.cp_resp.valid := true.B
  }

  val ifpu = Module(new IntToFP(cfg.ifpuLatency))
  ifpu.io.in.valid := req_valid && ex_ctrl.fromint
  ifpu.io.in.bits := fpiu.io.in.bits
  ifpu.io.in.bits.in1 := Mux(ex_cp_valid, io.cp_req.bits.in1, io.fromint_data)

  val fpmu = Module(new FPToFP(cfg.fpmuLatency))
  fpmu.io.in.valid := req_valid && ex_ctrl.fastpipe
  fpmu.io.in.bits := fpiu.io.in.bits
  fpmu.io.lt := fpiu.io.out.bits.lt

  val divSqrt_wen = WireDefault(false.B)
  val divSqrt_inFlight = WireDefault(false.B)
  val divSqrt_waddr = Reg(UInt(5.W))
  val divSqrt_cp = Reg(Bool())
  val divSqrt_typeTag = Wire(UInt(log2Up(floatTypes.size).W))
  val divSqrt_wdata = Wire(UInt((fLen+1).W))
  val divSqrt_flags = Wire(UInt(FPConstants.FLAGS_SZ.W))
  divSqrt_typeTag := DontCare
  divSqrt_wdata := DontCare
  divSqrt_flags := DontCare
  // writeback arbitration
  case class Pipe(p: Module, lat: Int, cond: (FPUCtrlSigs) => Bool, res: FPResult)
  val pipes = List(
    Pipe(fpmu, fpmu.latency, (c: FPUCtrlSigs) => c.fastpipe, fpmu.io.out.bits),
    Pipe(ifpu, ifpu.latency, (c: FPUCtrlSigs) => c.fromint, ifpu.io.out.bits),
    Pipe(sfma, sfma.latency, (c: FPUCtrlSigs) => c.fma && c.typeTagOut === S, sfma.io.out.bits)) ++
    (fLen > 32).option({
          val dfma = Module(new FPUFMAPipe(cfg.dfmaLatency, FType.D))
          dfma.io.in.valid := req_valid && ex_ctrl.fma && ex_ctrl.typeTagOut === D
          dfma.io.in.bits := fuInput(Some(dfma.t))
          Pipe(dfma, dfma.latency, (c: FPUCtrlSigs) => c.fma && c.typeTagOut === D, dfma.io.out.bits)
        }) ++
    (minFLen == 16).option({
          val hfma = Module(new FPUFMAPipe(cfg.sfmaLatency, FType.H))
          hfma.io.in.valid := req_valid && ex_ctrl.fma && ex_ctrl.typeTagOut === H
          hfma.io.in.bits := fuInput(Some(hfma.t))
          Pipe(hfma, hfma.latency, (c: FPUCtrlSigs) => c.fma && c.typeTagOut === H, hfma.io.out.bits)
        })
  def latencyMask(c: FPUCtrlSigs, offset: Int) = {
    require(pipes.forall(_.lat >= offset))
    pipes.map(p => Mux(p.cond(c), (1 << p.lat-offset).U, 0.U)).reduce(_|_)
  }
  def pipeid(c: FPUCtrlSigs) = pipes.zipWithIndex.map(p => Mux(p._1.cond(c), p._2.U, 0.U)).reduce(_|_)
  val maxLatency = pipes.map(_.lat).max
  val memLatencyMask = latencyMask(mem_ctrl, 2)

  class WBInfo extends Bundle {
    val rd = UInt(5.W)
    val typeTag = UInt(log2Up(floatTypes.size).W)
    val cp = Bool()
    val pipeid = UInt(log2Ceil(pipes.size).W)
  }

  val wen = RegInit(0.U((maxLatency-1).W))
  val wbInfo = Reg(Vec(maxLatency-1, new WBInfo))
  val mem_wen = mem_reg_valid && (mem_ctrl.fma || mem_ctrl.fastpipe || mem_ctrl.fromint)
  val write_port_busy = RegEnable(mem_wen && (memLatencyMask & latencyMask(ex_ctrl, 1)).orR || (wen & latencyMask(ex_ctrl, 0)).orR, req_valid)
  ccover(mem_reg_valid && write_port_busy, "WB_STRUCTURAL", "structural hazard on writeback")

  for (i <- 0 until maxLatency-2) {
    when (wen(i+1)) { wbInfo(i) := wbInfo(i+1) }
  }
  wen := wen >> 1
  when (mem_wen) {
    when (!killm) {
      //===== GuardianCouncil Function: Start ====//
      wen := wen >> 1 | Mux((io.checker_mode === 1.U) && io.if_overtaking_next_cycle, 0.U, memLatencyMask)
      //===== GuardianCouncil Function: End ====//
    }
    for (i <- 0 until maxLatency-1) {
      when (!write_port_busy && memLatencyMask(i)) {
        wbInfo(i).cp := mem_cp_valid
        wbInfo(i).typeTag := mem_ctrl.typeTagOut
        wbInfo(i).pipeid := pipeid(mem_ctrl)
        wbInfo(i).rd := mem_reg_inst(11,7)
      }
    }
  }
  //===== GuardianCouncil Function: Start ====//
  retire_1cycle := io.retire
  retire_2cycle := retire_1cycle
  wen_1cycle := wen
  wen_2cycle := wen_1cycle
  
  val r_cannot_wb = Wire(Bool())
  r_cannot_wb        := Mux(!io.checker_mode, false.B,
                        Mux(((wen(0) === 1.U) && (wen_1cycle(1) === 0.U) && io.retire.asBool), false.B,
                        Mux(((wen(0) === 1.U) && (wen_1cycle(1) === 1.U) && (wen_2cycle(2) === 0.U) && retire_1cycle), false.B,
                        Mux(((wen(0) === 1.U) && (wen_1cycle(1) === 1.U) && (wen_2cycle(2) === 1.U) && retire_2cycle), false.B, true.B))))
//===== GuardianCouncil Function: End ====//
  val waddr = Mux(divSqrt_wen, divSqrt_waddr, wbInfo(0).rd)
  val wb_cp = Mux(divSqrt_wen, divSqrt_cp, wbInfo(0).cp)
  val wtypeTag = Mux(divSqrt_wen, divSqrt_typeTag, wbInfo(0).typeTag)
  val wdata = box(Mux(divSqrt_wen, divSqrt_wdata, (pipes.map(_.res.data): Seq[UInt])(wbInfo(0).pipeid)), wtypeTag)
  val wexc = (pipes.map(_.res.exc): Seq[UInt])(wbInfo(0).pipeid)
  when ((!wbInfo(0).cp && wen(0)) || divSqrt_wen) {
    assert(consistent(wdata))
    regfile(waddr) := wdata
    if (enableCommitLog) {
      printf("f%d p%d 0x%x\n", waddr, waddr + 32.U, ieee(wdata))
    }
    frfWriteBundle(1).wrdst := waddr
    frfWriteBundle(1).wrenf := true.B
    frfWriteBundle(1).wrdata := ieee(wdata)
  }
  if (useDebugROB) {
    DebugROB.pushWb(clock, reset, io.hartid, (!wbInfo(0).cp && wen(0)) || divSqrt_wen, waddr + 32.U, ieee(wdata))
  }

  when (wb_cp && (wen(0) || divSqrt_wen)) {
    io.cp_resp.bits.data := wdata
    io.cp_resp.valid := true.B
  }

  assert(!io.cp_req.valid || pipes.forall(_.lat == pipes.head.lat).B,
    s"FPU only supports coprocessor if FMA pipes have uniform latency ${pipes.map(_.lat)}")
  // Avoid structural hazards and nacking of external requests
  // toint responds in the MEM stage, so an incoming toint can induce a structural hazard against inflight FMAs
  io.cp_req.ready := !ex_reg_valid && !(cp_ctrl.toint && wen =/= 0.U) && !divSqrt_inFlight

  val wb_toint_valid = wb_reg_valid && wb_ctrl.toint
  val wb_toint_exc = RegEnable(fpiu.io.out.bits.exc, mem_ctrl.toint)
  io.fcsr_flags.valid := wb_toint_valid || divSqrt_wen || wen(0)
  io.fcsr_flags.bits :=
    Mux(wb_toint_valid, wb_toint_exc, 0.U) |
    Mux(divSqrt_wen, divSqrt_flags, 0.U) |
    Mux(wen(0), wexc, 0.U)

  val divSqrt_write_port_busy = (mem_ctrl.div || mem_ctrl.sqrt) && wen.orR
  io.fcsr_rdy := !(ex_reg_valid && ex_ctrl.wflags || mem_reg_valid && mem_ctrl.wflags || wb_reg_valid && wb_ctrl.toint || wen.orR || divSqrt_inFlight)
  io.nack_mem := (write_port_busy || divSqrt_write_port_busy || divSqrt_inFlight) && !mem_cp_valid
  io.dec <> id_ctrl
  def useScoreboard(f: ((Pipe, Int)) => Bool) = pipes.zipWithIndex.filter(_._1.lat > 3).map(x => f(x)).fold(false.B)(_||_)
  io.sboard_set := wb_reg_valid && !wb_cp_valid && RegNext(useScoreboard(_._1.cond(mem_ctrl)) || mem_ctrl.div || mem_ctrl.sqrt || mem_ctrl.vec)
  io.sboard_clr := !wb_cp_valid && (divSqrt_wen || (wen(0) && useScoreboard(x => wbInfo(0).pipeid === x._2.U)))
  io.sboard_clra := waddr
  ccover(io.sboard_clr && load_wb, "DUAL_WRITEBACK", "load and FMA writeback on same cycle")
  // we don't currently support round-max-magnitude (rm=4)
  io.illegal_rm := io.inst(14,12).isOneOf(5.U, 6.U) || io.inst(14,12) === 7.U && io.fcsr_rm >= 5.U

  if (cfg.divSqrt) {
    val divSqrt_inValid = mem_reg_valid && (mem_ctrl.div || mem_ctrl.sqrt) && !divSqrt_inFlight
    // val divSqrt_killed = RegNext(divSqrt_inValid && killm, true.B)
    //===== GuardianCouncil Function: Start ====//
    val divSqrt_killed = RegNext(divSqrt_inValid && killm, true.B) || (RegNext(divSqrt_inValid) && (Mux(io.checker_mode.asBool, io.if_overtaking, false.B)))
    //===== GuardianCouncil Function: End ====//
    when (divSqrt_inValid) {
      divSqrt_waddr := mem_reg_inst(11,7)
      divSqrt_cp := mem_cp_valid
    }

    ccover(divSqrt_inFlight && divSqrt_killed, "DIV_KILLED", "divide killed after issued to divider")
    ccover(divSqrt_inFlight && mem_reg_valid && (mem_ctrl.div || mem_ctrl.sqrt), "DIV_BUSY", "divider structural hazard")
    ccover(mem_reg_valid && divSqrt_write_port_busy, "DIV_WB_STRUCTURAL", "structural hazard on division writeback")

    for (t <- floatTypes) {
      val tag = mem_ctrl.typeTagOut
      val divSqrt = withReset(divSqrt_killed) { Module(new hardfloat.DivSqrtRecFN_small(t.exp, t.sig, 0)) }
      divSqrt.io.inValid := divSqrt_inValid && tag === typeTag(t).U
      divSqrt.io.sqrtOp := mem_ctrl.sqrt
      divSqrt.io.a := maxType.unsafeConvert(fpiu.io.out.bits.in.in1, t)
      divSqrt.io.b := maxType.unsafeConvert(fpiu.io.out.bits.in.in2, t)
      divSqrt.io.roundingMode := fpiu.io.out.bits.in.rm
      divSqrt.io.detectTininess := hardfloat.consts.tininess_afterRounding

      when (!divSqrt.io.inReady) { divSqrt_inFlight := true.B } // only 1 in flight

      when (divSqrt.io.outValid_div || divSqrt.io.outValid_sqrt) {
        divSqrt_wen := !divSqrt_killed
        divSqrt_wdata := sanitizeNaN(divSqrt.io.out, t)
        divSqrt_flags := divSqrt.io.exceptionFlags
        divSqrt_typeTag := typeTag(t).U
      }
    }

    when (divSqrt_killed) { divSqrt_inFlight := false.B }
    //===== GuardianCouncil Function: Start ====//
    io.fpu_inflight := divSqrt_inFlight || divSqrt_inValid || divSqrt_wen || (wen =/= 0.U)
    //===== GuardianCouncil Function: END ====//
  } else {
    when (id_ctrl.div || id_ctrl.sqrt) { io.illegal_rm := true.B }
  }

  // gate the clock
  clock_en_reg := !useClockGating.B ||
    io.keep_clock_enabled || // chicken bit
    io.valid || // ID stage
    req_valid || // EX stage
    mem_reg_valid || mem_cp_valid || // MEM stage
    wb_reg_valid || wb_cp_valid || // WB stage
    wen.orR || divSqrt_inFlight || // post-WB stage
    io.ll_resp_val // load writeback

  } // leaving gated-clock domain
  val fpuImpl = withClock (gated_clock) { new FPUImpl }

  def ccover(cond: Bool, label: String, desc: String)(implicit sourceInfo: SourceInfo) =
    property.cover(cond, s"FPU_$label", "Core;;" + desc)
}
