// See LICENSE.Berkeley for license details.
// See LICENSE.SiFive for license details.

package freechips.rocketchip.meek

import chisel3._
import chisel3.util._
import chisel3.experimental.IntParam

import org.chipsalliance.cde.config._
import org.chipsalliance.diplomacy.lazymodule._

import freechips.rocketchip.rocket.{
  MStatus, HellaCacheIO, TLBPTWIO, CanHavePTW, CanHavePTWModule,
  SimpleHellaCacheIF, M_XRD, PTE, PRV, M_SZ
}
import freechips.rocketchip.tile._
import freechips.rocketchip.tilelink.{
  TLNode, TLIdentityNode, TLClientNode, TLMasterParameters, TLMasterPortParameters
}
import freechips.rocketchip.util.InOrderArbiter
//===== GuardianCouncil Function: Start ====//
import freechips.rocketchip.guardiancouncil._
//===== GuardianCouncil Function: End   ====//
case object BuildRoCCMEEK extends Field[Seq[Parameters => LazyRoCCMEEK]](Nil)


class RoCCCoreIOMEEK(val nRoCCCSRs: Int = 0)(implicit p: Parameters) extends CoreBundle()(p) {
  val cmd = Flipped(Decoupled(new RoCCCommand))
  val resp = Decoupled(new RoCCResponse)
  val mem = new HellaCacheIO
  val busy = Output(Bool())
  val interrupt = Output(Bool())
  val exception = Input(Bool())
  val csrs = Flipped(Vec(nRoCCCSRs, new CustomCSRIO))
 //===== GuardianCouncil Function: Start ====//
  val csr_counter_in = Input(Vec(84, UInt(32.W)))
  val ghe_packet_in = Input(UInt(GH_GlobalParams.GH_WIDITH_PACKETS.W))
  val ghe_status_in = Input(UInt(32.W))
  val bigcore_comp  = Input(UInt(3.W))
  val ghe_event_out = Output(UInt(5.W))
  val ght_mask_out = Output(UInt(1.W))
  val ght_status_out = Output(UInt(32.W))
  val ght_cfg_out = Output(UInt(32.W))
  val ght_cfg_valid = Output(UInt(1.W))
  val debug_bp_reset = Output(UInt(1.W))

  val agg_packet_out = Output(UInt(GH_GlobalParams.GH_WIDITH_PACKETS.W))
  val report_fi_detection_out = Output(UInt(57.W))
  val fi_sel_out = Output(UInt(8.W))
  val agg_buffer_full = Input(UInt(1.W))
  val agg_core_status = Output(UInt(2.W))
  val ght_sch_na = Output(UInt(1.W))
  val ght_sch_refresh = Input(UInt(1.W))
  val ght_sch_dorefresh = Output(UInt(32.W))
  val ght_buffer_status = Input(UInt(2.W))

  val ght_satp_ppn  = Input(UInt(44.W))
  val ght_sys_mode  = Input(UInt(2.W))
  val if_correct_process = Output(UInt(1.W))
  
  val debug_mcounter = Input(UInt(64.W))
  val debug_icounter = Input(UInt(64.W))
  val debug_gcounter = Input(UInt(64.W))

  val debug_bp_checker = Input(UInt(64.W))
  val debug_bp_cdc = Input(UInt(64.W))
  val debug_bp_filter = Input(UInt(64.W))
  // val fi_latency = Input(UInt(64.W))

  /* R Features */
  val t_value_out = Output(UInt(15.W))
  val icctrl_out = Output(UInt(4.W))
  val arf_copy_out = Output(UInt(1.W))
  val rsu_status_in = Input(UInt(2.W))
  val s_or_r_out = Output(UInt(2.W))
  val elu_data_in = Input(UInt(GH_GlobalParams.GH_WIDITH_PERF.W))
  val elu_deq_out = Output(UInt(1.W))
  val elu_sel_out = Output(UInt(1.W))
  val record_pc_out = Output(UInt(1.W))
  val elu_status_in = Input(UInt(2.W))
  val gtimer_reset_out = Output(UInt(1.W))
  val core_trace_out = Output(UInt(2.W))
  val record_and_store_out = Output(UInt(2.W))
  val debug_perf_ctrl = Output(UInt(5.W))
  //===== GuardianCouncil Function: End   ====//
}

class RoCCIOMEEK(val nPTWPorts: Int, nRoCCCSRs: Int)(implicit p: Parameters) extends RoCCCoreIOMEEK(nRoCCCSRs)(p) {
  val ptw = Vec(nPTWPorts, new TLBPTWIO)
  val fpu_req = Decoupled(new FPInput)
  val fpu_resp = Flipped(Decoupled(new FPResult))
}

/** Base classes for Diplomatic TL2 RoCC units **/
abstract class LazyRoCCMEEK(
  val opcodes: OpcodeSet,
  val nPTWPorts: Int = 0,
  val usesFPU: Boolean = false,
  val roccCSRs: Seq[CustomCSR] = Nil
)(implicit p: Parameters) extends LazyModule {
  val module: LazyRoCCMEEKModuleImp
  require(roccCSRs.map(_.id).toSet.size == roccCSRs.size)
  val atlNode: TLNode = TLIdentityNode()
  val tlNode: TLNode = TLIdentityNode()
  val stlNode: TLNode = TLIdentityNode()
}

class LazyRoCCMEEKModuleImp(outer: LazyRoCCMEEK) extends LazyModuleImp(outer) {
  val io = IO(new RoCCIOMEEK(outer.nPTWPorts, outer.roccCSRs.size))
  io := DontCare
}

/** Mixins for including RoCC **/
class OpcodeSetMEEK(val opcodes: Seq[UInt]) {
  def |(set: OpcodeSet) =
    new OpcodeSet(this.opcodes ++ set.opcodes)

  def matches(oc: UInt) = opcodes.map(_ === oc).reduce(_ || _)
}


trait HasLazyRoCCMEEK extends CanHavePTW { this: BaseTile =>
  val roccs = p(BuildRoCCMEEK).map(_(p))
  val roccCSRs = roccs.map(_.roccCSRs) // the set of custom CSRs requested by all roccs
  require(roccCSRs.flatten.map(_.id).toSet.size == roccCSRs.flatten.size,
    "LazyRoCC instantiations require overlapping CSRs")
  roccs.map(_.atlNode).foreach { atl => tlMasterXbar.node :=* atl }
  roccs.map(_.tlNode).foreach { tl => tlOtherMastersNode :=* tl }
  roccs.map(_.stlNode).foreach { stl => stl :*= tlSlaveXbar.node }

  nPTWPorts += roccs.map(_.nPTWPorts).sum
  nDCachePorts += roccs.size
}

trait HasLazyRoCCMEEKModule extends CanHavePTWModule
    with HasCoreParameters { this: RocketTileMeekModuleImp =>

  val (respArb, cmdRouter) = if(outer.roccs.nonEmpty) {
    val respArb = Module(new RRArbiter(new RoCCResponse()(outer.p), outer.roccs.size))
    val cmdRouter = Module(new RoccMEEKCommandRouter(outer.roccs.map(_.opcodes))(outer.p))
    outer.roccs.zipWithIndex.foreach { case (rocc, i) =>
      rocc.module.io.ptw ++=: ptwPorts
      rocc.module.io.cmd <> cmdRouter.io.out(i)
      val dcIF = Module(new SimpleHellaCacheIF()(outer.p))
      dcIF.io.requestor <> rocc.module.io.mem
      dcachePorts += dcIF.io.cache
      respArb.io.in(i) <> Queue(rocc.module.io.resp)
 //===== GuardianCouncil Function: Start ====//
      for(i <- 0 until 84){
        rocc.module.io.csr_counter_in(i) := 0.U
      }
      rocc.module.io.debug_mcounter := 0.U
      rocc.module.io.debug_icounter := 0.U
      rocc.module.io.debug_gcounter := 0.U
      rocc.module.io.debug_bp_checker := 0.U
      rocc.module.io.debug_bp_cdc := 0.U
      rocc.module.io.debug_bp_filter := 0.U
      // rocc.module.io.fi_sel_in := 0.U
      rocc.module.io.ghe_packet_in := cmdRouter.io.ghe_packet_in
      rocc.module.io.ghe_status_in := cmdRouter.io.ghe_status_in
      rocc.module.io.bigcore_comp  := cmdRouter.io.bigcore_comp_out
      cmdRouter.io.ght_mask_in := rocc.module.io.ght_mask_out
      cmdRouter.io.ght_status_in := rocc.module.io.ght_status_out
      cmdRouter.io.ghe_event_in := rocc.module.io.ghe_event_out
      cmdRouter.io.ght_cfg_in := rocc.module.io.ght_cfg_out
      cmdRouter.io.ght_cfg_valid_in := rocc.module.io.ght_cfg_valid
      cmdRouter.io.debug_bp_reset_in := rocc.module.io.debug_bp_reset

      cmdRouter.io.agg_packet_in := rocc.module.io.agg_packet_out
      cmdRouter.io.report_fi_detection_in := rocc.module.io.report_fi_detection_out
      rocc.module.io.agg_buffer_full := cmdRouter.io.agg_buffer_full
      cmdRouter.io.agg_core_status_in := rocc.module.io.agg_core_status
      cmdRouter.io.ght_sch_na_in := rocc.module.io.ght_sch_na
      rocc.module.io.ght_sch_refresh := cmdRouter.io.ght_sch_refresh
      rocc.module.io.ght_buffer_status := cmdRouter.io.ght_buffer_status
      cmdRouter.io.ght_sch_dorefresh_in := rocc.module.io.ght_sch_dorefresh
      cmdRouter.io.if_correct_process_in := rocc.module.io.if_correct_process

      /* R Features */
      cmdRouter.io.icctrl_in := rocc.module.io.icctrl_out
      cmdRouter.io.t_value_in := rocc.module.io.t_value_out
      cmdRouter.io.s_or_r_in := rocc.module.io.s_or_r_out
      cmdRouter.io.arf_copy_in := rocc.module.io.arf_copy_out
      cmdRouter.io.core_trace_in := rocc.module.io.core_trace_out
      cmdRouter.io.debug_perf_ctrl_in := rocc.module.io.debug_perf_ctrl
      cmdRouter.io.record_and_store_in := rocc.module.io.record_and_store_out
      cmdRouter.io.record_pc_in := rocc.module.io.record_pc_out
      cmdRouter.io.gtimer_reset_in := rocc.module.io.gtimer_reset_out
      rocc.module.io.rsu_status_in := cmdRouter.io.rsu_status_out
      rocc.module.io.ght_satp_ppn := cmdRouter.io.ght_satp_ppn
      rocc.module.io.ght_sys_mode := cmdRouter.io.ght_sys_mode
      rocc.module.io.elu_data_in := cmdRouter.io.elu_data_in
      cmdRouter.io.elu_deq_in := rocc.module.io.elu_deq_out
      cmdRouter.io.elu_sel_in := rocc.module.io.elu_sel_out
      rocc.module.io.elu_status_in := cmdRouter.io.elu_status_in
      //===== GuardianCouncil Function: End   ====//
    }
    (Some(respArb), Some(cmdRouter))
  } else {
    (None, None)
  }
  val roccCSRIOs = outer.roccs.map(_.module.io.csrs)
}



class RoccMEEKCommandRouter(opcodes: Seq[OpcodeSet])(implicit p: Parameters)
    extends CoreModule()(p) {
  val io = IO(new Bundle {
    val in = Flipped(Decoupled(new RoCCCommand))
    val out = Vec(opcodes.size, Decoupled(new RoCCCommand))
    val busy = Output(Bool())
 //===== GuardianCouncil Function: Start ====//
    val ghe_packet_in = Input(UInt(GH_GlobalParams.GH_WIDITH_PACKETS.W))
    val ghe_status_in = Input(UInt(32.W))
    val bigcore_comp  = Input(UInt(3.W))
    val bigcore_comp_out = Output(UInt(3.W))
    val ghe_event_in = Input(UInt(5.W))
    val ghe_event_out = Output(UInt(5.W))
    val ght_mask_out  = Output(UInt(1.W))
    val ght_mask_in = Input(UInt(1.W))
    val ght_status_out  = Output(UInt(32.W))
    val ght_status_in = Input(UInt(32.W))
    val ght_cfg_out = Output(UInt(32.W))
    val ght_cfg_in = Input(UInt(32.W))
    val ght_cfg_valid = Output(UInt(1.W))
    val ght_cfg_valid_in = Input(UInt(1.W))

    val debug_bp_reset = Output(UInt(1.W))
    val debug_bp_reset_in = Input(UInt(1.W))

    val agg_packet_out = Output(UInt(GH_GlobalParams.GH_WIDITH_PACKETS.W))
    val agg_packet_in  = Input(UInt(GH_GlobalParams.GH_WIDITH_PACKETS.W))
    val report_fi_detection_out = Output(UInt(57.W))
    val report_fi_detection_in  = Input(UInt(57.W))
    val agg_buffer_full = Input(UInt(1.W))
    val agg_core_status_out = Output(UInt(2.W))
    val agg_core_status_in = Input(UInt(2.W))

    val ght_sch_na_in = Input(UInt(1.W))
    val ght_sch_na_out = Output(UInt(1.W))
    val ght_sch_refresh = Input(UInt(1.W))
    val ght_buffer_status = Input(UInt(2.W))

    val ght_sch_dorefresh_in = Input(UInt(32.W))
    val ght_sch_dorefresh_out = Output(UInt(32.W))

    val if_correct_process_in = Input(UInt(1.W))
    val if_correct_process_out = Output(UInt(1.W))

    /* R Features */
    val icctrl_out = Output(UInt(4.W))
    val icctrl_in = Input(UInt(4.W))
    val t_value_out = Output(UInt(15.W))
    val t_value_in = Input(UInt(15.W))
    val arf_copy_out = Output(UInt(1.W))
    val arf_copy_in = Input(UInt(1.W))
    val core_trace_out = Output(UInt(2.W))
    val core_trace_in = Input(UInt(2.W))
    val debug_perf_ctrl_out = Output(UInt(5.W))
    val debug_perf_ctrl_in = Input(UInt(5.W))
    val record_and_store_out = Output(UInt(2.W))
    val record_and_store_in = Input(UInt(2.W))
    val record_pc_out = Output(UInt(1.W))
    val record_pc_in = Input(UInt(1.W))
    val gtimer_reset_out = Output(UInt(1.W))
    val gtimer_reset_in = Input(UInt(1.W))

    val rsu_status_in = Input(UInt(2.W))
    val rsu_status_out = Output(UInt(2.W))
    val s_or_r_out = Output(UInt(2.W))
    val s_or_r_in = Input(UInt(2.W))
    val ght_satp_ppn  = Input(UInt(44.W))
    val ght_sys_mode  = Input(UInt(2.W))
    val elu_data_in = Input(UInt(GH_GlobalParams.GH_WIDITH_PERF.W))
    val elu_deq_out = Output(UInt(1.W))
    val elu_deq_in = Input(UInt(1.W))
    val elu_sel_out = Output(UInt(1.W))
    val elu_sel_in = Input(UInt(1.W))
    val elu_status_in = Input(UInt(2.W))
    //===== GuardianCouncil Function: End   ====//
  })

  val cmd = (io.in)
  val cmdReadys = io.out.zip(opcodes).map { case (out, opcode) =>
    val me = opcode.matches(cmd.bits.inst.opcode)
    out.valid := cmd.valid && me
    out.bits := cmd.bits
    out.ready && me
  }
  cmd.ready := cmdReadys.reduce(_ || _)
  io.busy := cmd.valid
//===== GuardianCouncil Function: Start ====//
  io.ghe_event_out := io.ghe_event_in
  io.ght_mask_out := io.ght_mask_in
  io.ght_status_out := io.ght_status_in
  io.ght_cfg_out := io.ght_cfg_in
  io.ght_cfg_valid := io.ght_cfg_valid_in
  io.debug_bp_reset := io.debug_bp_reset_in
  io.bigcore_comp_out := io.bigcore_comp

  io.rsu_status_out := io.rsu_status_in

  io.agg_packet_out := io.agg_packet_in
  io.report_fi_detection_out := io.report_fi_detection_in
  io.agg_core_status_out := io.agg_core_status_in
  io.ght_sch_na_out := io.ght_sch_na_in
  io.ght_sch_dorefresh_out := io.ght_sch_dorefresh_in

  io.if_correct_process_out := io.if_correct_process_in

  /* R Features */
  io.icctrl_out := io.icctrl_in
  io.t_value_out := io.t_value_in
  io.arf_copy_out := io.arf_copy_in
  io.core_trace_out := io.core_trace_in
  io.debug_perf_ctrl_out := io.debug_perf_ctrl_in
  io.record_and_store_out := io.record_and_store_in
  io.record_pc_out := io.record_pc_in
  io.gtimer_reset_out := io.gtimer_reset_in
  io.s_or_r_out := io.s_or_r_in
  io.elu_deq_out := io.elu_deq_in
  io.elu_sel_out := io.elu_sel_in
  //===== GuardianCouncil Function: End   ====//


  assert(PopCount(cmdReadys) <= 1.U,
    "Custom opcode matched for more than one accelerator")
  // dontTouch(io.rsu_status_in)
  // dontTouch(io.rsu_status_out)
  dontTouch(io)
}
class RoccCommandRouterBoom(opcodes: Seq[OpcodeSet])(implicit p: Parameters)
    extends CoreModule()(p) {
  val io =IO (new Bundle {
    val in = Flipped(Decoupled(new RoCCCommand))
    val out = Vec(opcodes.size, Decoupled(new RoCCCommand))
    val busy = Output(Bool())
    //===== GuardianCouncil Function: Start ====//
    val csr_counter_in = Input(Vec(84, UInt(32.W)))
    val csr_counter_out = Output(Vec(84, UInt(32.W)))
    val ghe_packet_in = Input(UInt(GH_GlobalParams.GH_WIDITH_PACKETS.W))
    val ghe_status_in = Input(UInt(32.W))
    val bigcore_comp  = Input(UInt(3.W))
    val bigcore_comp_out = Output(UInt(3.W))
    val ghe_event_in = Input(UInt(5.W))
    val ghe_event_out = Output(UInt(5.W))
    val ght_mask_out  = Output(UInt(1.W))
    val ght_mask_in = Input(UInt(1.W))
    val ght_status_out  = Output(UInt(32.W))
    val ght_status_in = Input(UInt(32.W))
    val ght_cfg_out = Output(UInt(32.W))
    val ght_cfg_in = Input(UInt(32.W))
    val ght_cfg_valid = Output(UInt(1.W))
    val ght_cfg_valid_in = Input(UInt(1.W))

    val debug_bp_reset = Output(UInt(1.W))
    val debug_bp_reset_in = Input(UInt(1.W))
    

    val agg_packet_out = Output(UInt(GH_GlobalParams.GH_WIDITH_PACKETS.W))
    val agg_packet_in  = Input(UInt(GH_GlobalParams.GH_WIDITH_PACKETS.W))
    val agg_buffer_full = Input(UInt(1.W))
    val agg_core_status_out = Output(UInt(2.W))
    val agg_core_status_in = Input(UInt(2.W))

    val ght_sch_na_in = Input(UInt(1.W))
    val ght_sch_na_out = Output(UInt(1.W))
    val ght_sch_refresh = Input(UInt(1.W))
    val ght_buffer_status = Input(UInt(2.W))

    val ght_sch_dorefresh_in = Input(UInt(32.W))
    val ght_sch_dorefresh_out = Output(UInt(32.W))

    val ght_satp_ppn  = Input(UInt(44.W))
    val ght_sys_mode  = Input(UInt(2.W))

    val if_correct_process_in = Input(UInt(1.W))
    val if_correct_process_out = Output(UInt(1.W))

    val debug_mcounter  = Input(UInt(64.W))
    val debug_icounter  = Input(UInt(64.W))
    val debug_gcounter  = Input(UInt(64.W))

    val debug_bp_checker = Input(UInt(64.W))
    val debug_bp_cdc = Input(UInt(64.W))
    val debug_bp_filter = Input(UInt(64.W))

    /* R Features */
    val icctrl_out = Output(UInt(4.W))
    val icctrl_in = Input(UInt(4.W))
    val t_value_out = Output(UInt(15.W))
    val t_value_in = Input(UInt(15.W))
    val arf_copy_out = Output(UInt(1.W))
    val arf_copy_in = Input(UInt(1.W))
    val core_trace_out = Output(UInt(2.W))
    val core_trace_in = Input(UInt(2.W))
    val s_or_r_out = Output(UInt(2.W))
    val s_or_r_in = Input(UInt(2.W))
    val gtimer_reset_out = Output(UInt(1.W))
    val gtimer_reset_in = Input(UInt(1.W))
    val fi_sel_out = Output(UInt(8.W))
    val fi_sel_in  = Input(UInt(8.W))
    // val fi_latency = Input(UInt(64.W))
    val rsu_status_in = Input(UInt(2.W))
    val elu_data_in = Input(UInt(GH_GlobalParams.GH_WIDITH_PERF.W))

    val debug_perf_ctrl_out = Output(UInt(5.W))
    val debug_perf_ctrl_in = Input(UInt(5.W))
    //===== GuardianCouncil Function: End   ====//
  })

  // val cmd = Queue(io.in)
  // val cmdReadys = io.out.zip(opcodes).map { case (out, opcode) =>
  //   val me = opcode.matches(cmd.bits.inst.opcode)
  //   out.valid := cmd.valid && me
  //   out.bits := cmd.bits
  //   out.ready && me
  // }
  // cmd.ready := cmdReadys.reduce(_ || _)
  // io.busy := cmd.valid
  //修改了cmd的方式
  val cmd = (io.in)
  val cmdReadys = io.out.zip(opcodes).map { case (out, opcode) =>
    val me = opcode.matches(cmd.bits.inst.opcode)
    out.valid := cmd.valid && me
    out.bits := cmd.bits
    out.ready && me
  }
  cmd.ready := cmdReadys.reduce(_ || _)
  io.busy := cmd.valid
  //===== GuardianCouncil Function: Start ====//
  io.ghe_event_out := io.ghe_event_in
  io.ght_mask_out := io.ght_mask_in
  io.ght_status_out := io.ght_status_in
  io.ght_cfg_out := io.ght_cfg_in
  io.ght_cfg_valid := io.ght_cfg_valid_in
  io.debug_bp_reset := io.debug_bp_reset_in
  io.bigcore_comp_out := io.bigcore_comp
  io.csr_counter_out := io.csr_counter_in

  io.agg_packet_out := io.agg_packet_in
  io.agg_core_status_out := io.agg_core_status_in
  io.ght_sch_na_out := io.ght_sch_na_in
  io.ght_sch_dorefresh_out := io.ght_sch_dorefresh_in
  io.if_correct_process_out := io.if_correct_process_in

  /* R Features */
  io.icctrl_out := io.icctrl_in
  io.gtimer_reset_out := io.gtimer_reset_in
  io.fi_sel_out := io.fi_sel_in
  io.t_value_out := io.t_value_in
  io.s_or_r_out := io.s_or_r_in
  io.arf_copy_out := io.arf_copy_in
  io.core_trace_out := io.core_trace_in

  io.debug_perf_ctrl_out := io.debug_perf_ctrl_in
  //===== GuardianCouncil Function: End   ====//
  assert(PopCount(cmdReadys) <= 1.U,
    "Custom opcode matched for more than one accelerator")
}