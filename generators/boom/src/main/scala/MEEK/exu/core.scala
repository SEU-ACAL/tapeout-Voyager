//******************************************************************************
// Copyright (c) 2015 - 2019, The Regents of the University of California (Regents).
// All Rights Reserved. See LICENSE and LICENSE.SiFive for license details.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// RISC-V Processor Core
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//
// BOOM has the following (conceptual) stages:
//   if0 - Instruction Fetch 0 (next-pc select)
//   if1 - Instruction Fetch 1 (I$ access)
//   if2 - Instruction Fetch 2 (instruction return)
//   if3 - Instruction Fetch 3 (enqueue to fetch buffer)
//   if4 - Instruction Fetch 4 (redirect from bpd)
//   dec - Decode
//   ren - Rename1
//   dis - Rename2/Dispatch
//   iss - Issue
//   rrd - Register Read
//   exe - Execute
//   mem - Memory
//   sxt - Sign-extend
//   wb  - Writeback
//   com - Commit

package boom.meek.exu

import java.nio.file.{Paths}

import chisel3._
import chisel3.util._

import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.rocket.Instructions._
import freechips.rocketchip.tile.{TraceBundle}
import freechips.rocketchip.rocket.{Causes, PRV, TracedInstruction}
import freechips.rocketchip.util.{Str, UIntIsOneOf, CoreMonitorBundle}
import freechips.rocketchip.devices.tilelink.{PLICConsts, CLINTConsts}
import freechips.rocketchip.rocket._
import boom.meek.common._
import boom.meek.ifu.{GlobalHistory, HasBoomFrontendParameters}
import boom.meek.exu.FUConstants._
import boom.meek.util._
//===== GuardianCouncil Function: Start ====//
import freechips.rocketchip.r._
import freechips.rocketchip.guardiancouncil._
import java.awt.peer.PopupMenuPeer
import boom.meek.lsu.STQEntry
import freechips.rocketchip.meek._
//===== GuardianCouncil Function: End   ====//
/**
 * Top level core object that connects the Frontend to the rest of the pipeline.
 */
class BoomCore()(implicit p: Parameters) extends BoomModule
  with HasBoomFrontendParameters // TODO: Don't add this trait
{
  val io = IO(new Bundle {
    val hartid = Input(UInt(hartIdLen.W))
    val interrupts = Input(new freechips.rocketchip.rocket.CoreInterrupts(false))
    val ifu = new boom.meek.ifu.BoomFrontendIO
    val ptw = Flipped(new freechips.rocketchip.rocket.DatapathPTWIO())
    val rocc = Flipped(new freechips.rocketchip.tile.RoCCCoreIO())
    val lsu = Flipped(new boom.meek.lsu.LSUCoreIO)
    val ptw_tlb = new freechips.rocketchip.rocket.TLBPTWIO()
    val trace = Output(new TraceBundle)
    val fcsr_rm = UInt(freechips.rocketchip.tile.FPConstants.RM_SZ.W)
//===== GuardianCouncil Function: Start ====//

    val commit_valids = Output(Vec(coreWidth, UInt(1.W)))
    val commit_uops   = Output(Vec(coreWidth, new MicroOp))
    val prf_rd = Output(Vec(coreWidth, UInt(xLen.W)))
    val alu_out = Output(Vec(coreWidth, UInt(xLen.W)))

    val csr_addr = Output(Vec(coreWidth, UInt(CSR_ADDR_SZ.W)))
    val big_hang = Input(Bool())//cdc not ready
    val ght_prv  = Output(UInt(2.W))

    val gh_stall = Input(Bool())
    val bigComp  = Input(UInt(3.W))

    val csr_counter = Output(Vec(84, UInt(32.W)))
    
    /* R Features */
    val num_of_checker = Input(UInt(8.W))
    val icctrl = Input(UInt(4.W))
    val t_value = Input(UInt(4.W))
    // val ght_filters_ready = Input(UInt(1.W))
    val r_arfs = Output (Vec(1, (UInt((xLen*2+8).W))))
    val r_arfs_pidx = Output(Vec(1, UInt(8.W)))
    val rsu_merging = Output(UInt(1.W))
    val ic_crnt_target = Output(UInt(5.W))
    val if_correct_process = Input(UInt(1.W))
    val ic_counter = Output(Vec(GH_GlobalParams.GH_NUM_CORES, (UInt(16.W))))
    val clear_ic_status_tomain = Input(UInt(GH_GlobalParams.GH_NUM_CORES.W))
    val icsl_na = Input(UInt(GH_GlobalParams.GH_NUM_CORES.W))
    val core_trace = Input(UInt(1.W))
    val debug_maincore_status = Output(UInt(4.W))
    val ic_trace = Input(UInt(1.W))
    val debug_perf_ctrl = Input(UInt(4.W))
    val debug_perf_val = Output(UInt(64.W))
    val shared_CP_CFG = Output(UInt(13.W))
    val arfs_ecp_dest = Output(UInt(8.W))

    // val if_big_complete_req = Input(UInt((GH_GlobalParams.GH_NUM_CORES-1).W))
    // val if_big_complete_ack                        = Output(Vec(GH_GlobalParams.GH_NUM_CORES-1, Bool()))

    val rsu_merging_valid = Output(Bool())
    // val icsl_na_ack                                = Output(Vec(GH_GlobalParams.GH_NUM_CORES, Bool()))
    // val big_checker_switch                         = Output(Vec(GH_GlobalParams.GH_NUM_CORES, Bool()))//大核事件导致切换
    //===== GuardianCouncil Function: End ====//
  })

  io.ptw_tlb := DontCare
  io.ptw := DontCare
  io.ifu := DontCare

  //**********************************
  // construct all of the modules

  // Only holds integer-registerfile execution units.
  val exe_units = new boom.meek.exu.ExecutionUnits(fpu=false)
  val jmp_unit_idx = exe_units.jmp_unit_idx
  val jmp_unit = exe_units(jmp_unit_idx)

  // Meanwhile, the FP pipeline holds the FP issue window, FP regfile, and FP arithmetic units.
  var fp_pipeline: FpPipeline = null
  if (usingFPU) fp_pipeline = Module(new FpPipeline)

  // ********************************************************
  // Clear fp_pipeline before use
  if (usingFPU) {
    fp_pipeline.io.ll_wports := DontCare
    fp_pipeline.io.wb_valids := DontCare
    fp_pipeline.io.wb_pdsts  := DontCare
  }

  val numIrfWritePorts        = exe_units.numIrfWritePorts + memWidth
  val numLlIrfWritePorts      = exe_units.numLlIrfWritePorts
  val numIrfReadPorts         = exe_units.numIrfReadPorts

  val numFastWakeupPorts      = exe_units.count(_.bypassable)
  val numAlwaysBypassable     = exe_units.count(_.alwaysBypassable)

  val numIntIssueWakeupPorts  = numIrfWritePorts + numFastWakeupPorts - numAlwaysBypassable // + memWidth for ll_wb
  val numIntRenameWakeupPorts = numIntIssueWakeupPorts
  val numFpWakeupPorts        = if (usingFPU) fp_pipeline.io.wakeups.length else 0

  val decode_units     = for (w <- 0 until decodeWidth) yield { val d = Module(new DecodeUnit); d }
  val dec_brmask_logic = Module(new BranchMaskGenerationLogic(coreWidth))
  val rename_stage     = Module(new RenameStage(coreWidth, numIntPhysRegs, numIntRenameWakeupPorts, false))
  val fp_rename_stage  = if (usingFPU) Module(new RenameStage(coreWidth, numFpPhysRegs, numFpWakeupPorts, true)) else null
  val pred_rename_stage = Module(new PredRenameStage(coreWidth, ftqSz, 1))
  val rename_stages    = if (usingFPU) Seq(rename_stage, fp_rename_stage, pred_rename_stage) else Seq(rename_stage, pred_rename_stage)

  val mem_iss_unit     = Module(new IssueUnitCollapsing(memIssueParam, numIntIssueWakeupPorts))
  mem_iss_unit.suggestName("mem_issue_unit")
  val int_iss_unit     = Module(new IssueUnitCollapsing(intIssueParam, numIntIssueWakeupPorts))
  int_iss_unit.suggestName("int_issue_unit")

  val issue_units      = Seq(mem_iss_unit, int_iss_unit)
  val dispatcher       = Module(new BasicDispatcher)

//===== GuardianCouncil Function: Start ====//
  val r_syscall                                    = Wire(Bool())
  val iregfile         = Module(new RegisterFileSynthesizable(
                             numIntPhysRegs,
                             numIrfReadPorts + coreWidth, // additional ports for GH_Subsystem
                             numIrfWritePorts,
                             xLen,
                             Seq.fill(memWidth) {true} ++ exe_units.bypassable_write_port_mask)) // bypassable ll_wb
  //===== GuardianCouncil Function: End  ====//
  val pregfile         = Module(new RegisterFileSynthesizable(
                            ftqSz,
                            exe_units.numIrfReaders,
                            1,
                            1,
                            Seq(true))) // The jmp unit is always bypassable
  pregfile.io := DontCare // Only use the IO if enableSFBOpt

  // wb arbiter for the 0th ll writeback
  // TODO: should this be a multi-arb?
  val ll_wbarb         = Module(new Arbiter(new ExeUnitResp(xLen), 1 +
                                                                   (if (usingFPU) 1 else 0) +
                                                                   (if (usingRoCC) 1 else 0)))
  val iregister_read   = Module(new RegisterRead(
                           issue_units.map(_.issueWidth).sum,
                           exe_units.withFilter(_.readsIrf).map(_.supportedFuncUnits).toSeq,
                           numIrfReadPorts,
                           exe_units.withFilter(_.readsIrf).map(x => 2).toSeq,
                           exe_units.numTotalBypassPorts,
                           jmp_unit.numBypassStages,
                           xLen))
  val rob              = Module(new Rob(
                           numIrfWritePorts + numFpWakeupPorts, // +memWidth for ll writebacks
                           numFpWakeupPorts))
  // Used to wakeup registers in rename and issue. ROB needs to listen to something else.
  val int_iss_wakeups  = Wire(Vec(numIntIssueWakeupPorts, Valid(new ExeUnitResp(xLen))))
  val int_ren_wakeups  = Wire(Vec(numIntRenameWakeupPorts, Valid(new ExeUnitResp(xLen))))
  val pred_wakeup  = Wire(Valid(new ExeUnitResp(1)))

  require (exe_units.length == issue_units.map(_.issueWidth).sum)

  //***********************************
  // Pipeline State Registers and Wires

  // Decode/Rename1 Stage
  val dec_valids = Wire(Vec(coreWidth, Bool()))  // are the decoded instruction valid? It may be held up though.
  val dec_uops   = Wire(Vec(coreWidth, new MicroOp()))
  val dec_fire   = Wire(Vec(coreWidth, Bool()))  // can the instruction fire beyond decode?
                                                    // (can still be stopped in ren or dis)
  val dec_ready  = Wire(Bool())
  val dec_xcpts  = Wire(Vec(coreWidth, Bool()))
  val ren_stalls = Wire(Vec(coreWidth, Bool()))

  // Rename2/Dispatch stage
  val dis_valids = Wire(Vec(coreWidth, Bool()))
  val dis_uops   = Wire(Vec(coreWidth, new MicroOp))
  val dis_fire   = Wire(Vec(coreWidth, Bool()))
  val dis_ready  = Wire(Bool())

  // Issue Stage/Register Read
  val iss_valids = Wire(Vec(exe_units.numIrfReaders, Bool()))
  val iss_uops   = Wire(Vec(exe_units.numIrfReaders, new MicroOp()))
  val bypasses   = Wire(Vec(exe_units.numTotalBypassPorts, Valid(new ExeUnitResp(xLen))))
  val pred_bypasses = Wire(Vec(jmp_unit.numBypassStages, Valid(new ExeUnitResp(1))))
  require(jmp_unit.bypassable)

  // --------------------------------------
  // Dealing with branch resolutions

  // The individual branch resolutions from each ALU
  val brinfos = Reg(Vec(coreWidth, new BrResolutionInfo()))

  // "Merged" branch update info from all ALUs
  // brmask contains masks for rapidly clearing mispredicted instructions
  // brindices contains indices to reset pointers for allocated structures
  //           brindices is delayed a cycle
  val brupdate  = Wire(new BrUpdateInfo)
  val b1    = Wire(new BrUpdateMasks)
  val b2    = Reg(new BrResolutionInfo)

  brupdate.b1 := b1
  brupdate.b2 := b2

  for ((b, a) <- brinfos zip exe_units.alu_units) {
    b := a.io.brinfo
    b.valid := a.io.brinfo.valid && !rob.io.flush.valid
  }
  b1.resolve_mask := brinfos.map(x => x.valid << x.uop.br_tag).reduce(_|_)
  b1.mispredict_mask := brinfos.map(x => (x.valid && x.mispredict) << x.uop.br_tag).reduce(_|_)

  // Find the oldest mispredict and use it to update indices
  var mispredict_val = false.B
  var oldest_mispredict = brinfos(0)
  for (b <- brinfos) {
    val use_this_mispredict = !mispredict_val ||
    b.valid && b.mispredict && IsOlder(b.uop.rob_idx, oldest_mispredict.uop.rob_idx, rob.io.rob_head_idx)

    mispredict_val = mispredict_val || (b.valid && b.mispredict)
    oldest_mispredict = Mux(use_this_mispredict, b, oldest_mispredict)
  }

  b2.mispredict  := mispredict_val
  b2.cfi_type    := oldest_mispredict.cfi_type
  b2.taken       := oldest_mispredict.taken
  b2.pc_sel      := oldest_mispredict.pc_sel
  b2.uop         := UpdateBrMask(brupdate, oldest_mispredict.uop)
  b2.jalr_target := RegNext(jmp_unit.io.brinfo.jalr_target)
  b2.target_offset := oldest_mispredict.target_offset

  val oldest_mispredict_ftq_idx = oldest_mispredict.uop.ftq_idx


  assert (!((brupdate.b1.mispredict_mask =/= 0.U || brupdate.b2.mispredict)
    && rob.io.commit.rollback), "Can't have a mispredict during rollback.")

  io.ifu.brupdate := brupdate

  for (eu <- exe_units) {
    eu.io.brupdate := brupdate
  }

  if (usingFPU) {
    fp_pipeline.io.brupdate := brupdate
  }

  // Load/Store Unit & ExeUnits
  val mem_units = exe_units.memory_units
  val mem_resps = mem_units.map(_.io.ll_iresp)
  for (i <- 0 until memWidth) {
    mem_units(i).io.lsu_io <> io.lsu.exe(i)
  }

  //-------------------------------------------------------------
  // Uarch Hardware Performance Events (HPEs)
  val load_commit  = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && rob.io.commit.uops(i).mem_cmd===M_XRD && rob.io.commit.uops(i).iq_type===IQT_MEM)
  val store_commit = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && rob.io.commit.uops(i).mem_cmd===M_XWR && rob.io.commit.uops(i).iq_type===IQT_MEM)
  val fp_commit    = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && rob.io.commit.uops(i).fp_val)
  val int_commit   = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && rob.io.commit.uops(i).iq_type===IQT_INT)
  val div_commit   = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && rob.io.commit.uops(i).fu_code=== FU_DIV)
  val mul_commit   = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && rob.io.commit.uops(i).fu_code=== FU_MUL)
  val csr_counter             = RegInit(VecInit(Seq.fill(84)(0.U(32.W))))
  val csr_counter_valid       = WireInit(VecInit(Seq.fill(84)(false.B)))
  val csr_counter_num         = WireInit(VecInit(Seq.fill(84)(0.U(log2Ceil(coreWidth).W))))
  val no_core_aval            = WireInit(false.B)
  val debug_ic_stall          = WireInit(false.B)
  //csr commit signals
  //--------machine level csr---------//
  val csr_commit              = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && rob.io.commit.uops(i).ctrl.csr_cmd.isOneOf(CSR.R, CSR.W, CSR.S, CSR.C))
  val csrw_commit             = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd))
  
  val csrw_commit_mstatus     = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mstatus.U)
  val csrw_commit_misa        = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.misa.U)
  val csrw_commit_medeleg     = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.medeleg.U)
  val csrw_commit_mideleg     = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mideleg.U)
  val csrw_commit_mie         = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mie.U)
  val csrw_commit_mtvec       = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mtvec.U)
  
  val csrw_commit_mcounteren  = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mcounteren.U)
  val csrw_commit_mscratch    = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mscratch.U)
  val csrw_commit_mepc        = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mepc.U)
  val csrw_commit_mcause      = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mcause.U)
  val csrw_commit_mtval       = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mtval.U)
  val csrw_commit_mip         = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mip.U)
  val csrw_commit_mtval2      = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mtval2.U)
  
  val csrw_commit_menvcfg     = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.menvcfg.U)
  val csrw_commit_mseccfg     = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mseccfg.U)
  
  val csrw_commit_pmpcfg0     = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.pmpcfg0.U)
  val csrw_commit_pmpaddr0    = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.pmpaddr0.U)
  val csrw_commit_pmpaddr     = (0 until 8).map(k => ((0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === (CSRs.pmpaddr0 + k).U)))
  
  val csrw_commit_mcountinh   = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mcountinhibit.U)
  val csrw_commit_event       = (0 until nPerfCounters).map(k => ((0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === (CSRs.mhpmevent3 + k).U)))
  
  val csrw_commit_mncause     = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CustomCSRs.mncause.U)
  val csrw_commit_mnepc       = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CustomCSRs.mnepc.U)
  val csrw_commit_mnscratch   = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CustomCSRs.mnscratch.U)
  val csrw_commit_mnstatus    = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CustomCSRs.mnstatus.U)
  
  val csrw_commit_dcsr        = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.dcsr.U)
  val csrw_commit_dpc         = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.dpc.U)
  val csrw_commit_dscratch0   = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.dscratch0.U)
  val csrw_commit_dscratch1   = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.dscratch1.U)

  val csrw_commit_tselect     = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.tselect.U)
  val csrw_commit_tdata1      = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.tdata1.U)
  val csrw_commit_tdata2      = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.tdata2.U)
  val csrw_commit_tdata3      = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.tdata3.U)
  val csrw_commit_mcontext    = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.mcontext.U)

  /*-----------user level csr---------------*/
  val csrw_commit_fflags      = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.fflags.U)
  val csrw_commit_fcsr        = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.fcsr.U)
  val csrw_commit_frm         = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.frm.U)



  /*-----------supervisor level csr-----------*/
  val csrw_commit_sstatus     = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.sstatus.U)
  val csrw_commit_sie         = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.sie.U)
  val csrw_commit_stvec       = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.stvec.U)
  val csrw_commit_scounteren  = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.scounteren.U)
  
  val csrw_commit_senvcfg     = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.senvcfg.U)

  val csrw_commit_sscratch    = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.sscratch.U)
  val csrw_commit_sepc        = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.sepc.U)
  val csrw_commit_scause      = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.scause.U)
  val csrw_commit_stval       = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.stval.U)
  val csrw_commit_sip         = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.sip.U)

  val csrw_commit_satp        = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.satp.U)

  val csrw_commit_scontext    = (0 until coreWidth).map(i => rob.io.commit.arch_valids(i) && CSR.isWriteCSR(rob.io.commit.uops(i).ctrl.csr_cmd) && rob.io.commit.uops(i).csr_addr === CSRs.scontext.U)
  //end

  //counter valid
  //--------machine level csr---------//
  csr_counter_valid(0)        := csr_commit.reduce(_ || _)
  csr_counter_valid(1)        := csrw_commit.reduce(_ || _)

  csr_counter_valid(2)        := csrw_commit_mstatus.reduce(_ || _)
  csr_counter_valid(3)        := csrw_commit_misa.reduce(_ || _)
  csr_counter_valid(4)        := csrw_commit_medeleg.reduce(_ || _)
  csr_counter_valid(5)        := csrw_commit_mideleg.reduce(_ || _)
  csr_counter_valid(6)        := csrw_commit_mie.reduce(_ || _)
  csr_counter_valid(7)        := csrw_commit_mtvec.reduce(_ || _)
  csr_counter_valid(8)        := csrw_commit_mcounteren.reduce(_ || _)

  csr_counter_valid(9)        := csrw_commit_mscratch.reduce(_ || _)
  csr_counter_valid(10)       := csrw_commit_mepc.reduce(_ || _)
  csr_counter_valid(11)       := csrw_commit_mcause.reduce(_ || _)
  csr_counter_valid(12)       := csrw_commit_mtval.reduce(_ || _)
  csr_counter_valid(13)       := csrw_commit_mip.reduce(_ || _)
  csr_counter_valid(14)       := csrw_commit_mtval2.reduce(_ || _)

  csr_counter_valid(15)       := csrw_commit_menvcfg.reduce(_ || _)
  csr_counter_valid(16)       := csrw_commit_mseccfg.reduce(_ || _)

  csr_counter_valid(17)       := csrw_commit_pmpcfg0.reduce(_ || _)
  for(i <- 0 until 8){
    csr_counter_valid(18 + i) := csrw_commit_pmpaddr(i).reduce(_ || _)
  }

  csr_counter_valid(26)       := csrw_commit_mcountinh.reduce(_ || _)
  for(i <- 0 until nPerfCounters){
    csr_counter_valid(27 + i) := csrw_commit_event(i).reduce(_ || _)
  }

  csr_counter_valid(56)       := csrw_commit_mncause.reduce(_ || _)
  csr_counter_valid(57)       := csrw_commit_mnepc.reduce(_ || _)
  csr_counter_valid(58)       := csrw_commit_mnscratch.reduce(_ || _)
  csr_counter_valid(59)       := csrw_commit_mnstatus.reduce(_ || _)

  csr_counter_valid(60)       := csrw_commit_dcsr.reduce(_ || _)
  csr_counter_valid(61)       := csrw_commit_dpc.reduce(_ || _)
  csr_counter_valid(62)       := csrw_commit_dscratch0.reduce(_ || _)
  csr_counter_valid(63)       := csrw_commit_dscratch1.reduce(_ || _)

  csr_counter_valid(64)       := csrw_commit_tselect.reduce(_ || _)
  csr_counter_valid(65)       := csrw_commit_tdata1.reduce(_ || _)
  csr_counter_valid(66)       := csrw_commit_tdata2.reduce(_ || _)
  csr_counter_valid(67)       := csrw_commit_tdata3.reduce(_ || _)
  csr_counter_valid(68)       := csrw_commit_mcontext.reduce(_ || _)

  /*-----------user level csr---------------*/
  csr_counter_valid(69)       := csrw_commit_fflags.reduce(_ || _)
  csr_counter_valid(70)       := csrw_commit_fcsr.reduce(_ || _)
  csr_counter_valid(71)       := csrw_commit_frm.reduce(_ || _)

  /*-----------supervisor level csr-----------*/
  csr_counter_valid(72)       := csrw_commit_sstatus.reduce(_ || _)
  csr_counter_valid(73)       := csrw_commit_sie.reduce(_ || _)
  csr_counter_valid(74)       := csrw_commit_stvec.reduce(_ || _)
  csr_counter_valid(75)       := csrw_commit_scounteren.reduce(_ || _)

  csr_counter_valid(76)       := csrw_commit_senvcfg.reduce(_ || _)

  csr_counter_valid(77)       := csrw_commit_sscratch.reduce(_ || _)
  csr_counter_valid(78)       := csrw_commit_sepc.reduce(_ || _)
  csr_counter_valid(79)       := csrw_commit_scause.reduce(_ || _)
  csr_counter_valid(80)       := csrw_commit_stval.reduce(_ || _)
  csr_counter_valid(81)       := csrw_commit_sip.reduce(_ || _)

  csr_counter_valid(82)       := csrw_commit_satp.reduce(_ || _)
  csr_counter_valid(83)       := csrw_commit_scontext.reduce(_ || _)
  //end
  //counter num one cycle
  /*-----------machine level csr-----------*/
  csr_counter_num(0)          := PopCount(csr_commit)
  csr_counter_num(1)          := PopCount(csrw_commit)

  csr_counter_num(2)          := PopCount(csrw_commit_mstatus)
  csr_counter_num(3)          := PopCount(csrw_commit_misa)
  csr_counter_num(4)          := PopCount(csrw_commit_medeleg)
  csr_counter_num(5)          := PopCount(csrw_commit_mideleg)
  csr_counter_num(6)          := PopCount(csrw_commit_mie)
  csr_counter_num(7)          := PopCount(csrw_commit_mtvec)
  csr_counter_num(8)          := PopCount(csrw_commit_mcounteren)

  csr_counter_num(9)          := PopCount(csrw_commit_mscratch)
  csr_counter_num(10)         := PopCount(csrw_commit_mepc)
  csr_counter_num(11)         := PopCount(csrw_commit_mcause)
  csr_counter_num(12)         := PopCount(csrw_commit_mtval)
  csr_counter_num(13)         := PopCount(csrw_commit_mip)
  csr_counter_num(14)         := PopCount(csrw_commit_mtval2)

  csr_counter_num(15)         := PopCount(csrw_commit_menvcfg)
  csr_counter_num(16)         := PopCount(csrw_commit_mseccfg)

  csr_counter_num(17)         := PopCount(csrw_commit_pmpcfg0)
  for(i <- 0 until 8){
    csr_counter_num(18 + i)   := PopCount(csrw_commit_pmpaddr(i))
  }

  csr_counter_num(26)         := PopCount(csrw_commit_mcountinh)
  for(i <- 0 until nPerfCounters){
    csr_counter_num(27 + i)   := PopCount(csrw_commit_event(i))
  }

  csr_counter_num(56)         := PopCount(csrw_commit_mncause)
  csr_counter_num(57)         := PopCount(csrw_commit_mnepc)
  csr_counter_num(58)         := PopCount(csrw_commit_mnscratch)
  csr_counter_num(59)         := PopCount(csrw_commit_mnstatus)

  csr_counter_num(60)         := PopCount(csrw_commit_dcsr)
  csr_counter_num(61)         := PopCount(csrw_commit_dpc)
  csr_counter_num(62)         := PopCount(csrw_commit_dscratch0)
  csr_counter_num(63)         := PopCount(csrw_commit_dscratch1)

  csr_counter_num(64)         := PopCount(csrw_commit_tselect)
  csr_counter_num(65)         := PopCount(csrw_commit_tdata1)
  csr_counter_num(66)         := PopCount(csrw_commit_tdata2)
  csr_counter_num(67)         := PopCount(csrw_commit_tdata3)
  csr_counter_num(68)         := PopCount(csrw_commit_mcontext)

  // User-level CSRs
  csr_counter_num(69)         := PopCount(csrw_commit_fflags)
  csr_counter_num(70)         := PopCount(csrw_commit_fcsr)
  csr_counter_num(71)         := PopCount(csrw_commit_frm)

  // Supervisor-level CSRs
  csr_counter_num(72)         := PopCount(csrw_commit_sstatus)
  csr_counter_num(73)         := PopCount(csrw_commit_sie)
  csr_counter_num(74)         := PopCount(csrw_commit_stvec)
  csr_counter_num(75)         := PopCount(csrw_commit_scounteren)

  csr_counter_num(76)         := PopCount(csrw_commit_senvcfg)

  csr_counter_num(77)         := PopCount(csrw_commit_sscratch)
  csr_counter_num(78)         := PopCount(csrw_commit_sepc)
  csr_counter_num(79)         := PopCount(csrw_commit_scause)
  csr_counter_num(80)         := PopCount(csrw_commit_stval)
  csr_counter_num(81)         := PopCount(csrw_commit_sip)

  csr_counter_num(82)         := PopCount(csrw_commit_satp)
  csr_counter_num(83)         := PopCount(csrw_commit_scontext)


  //end

  for(i <- 0 until 84){
    csr_counter(i) := Mux(csr_counter_valid(i), csr_counter(i) + csr_counter_num(i), csr_counter(i))
  }
  io.csr_counter <> csr_counter

  dontTouch(csr_counter)
  dontTouch(csr_counter_num)
  dontTouch(csr_counter_valid)
  val csr_commit_valid = csr_commit.reduce(_ || _)
  val csr_commit_num   = PopCount(csr_commit)
  dontTouch(csr_commit_num)
  dontTouch(csr_commit_valid)
  val issue_valids = VecInit(
  issue_units.flatMap(_.io.iss_valids) ++ fp_pipeline.io.wb_valids)  
  val br_commit    = (0 until coreWidth).map(i=>rob.io.commit.arch_valids(i)&&(rob.io.commit.uops(i).is_br))
  val jal_commit   = (0 until coreWidth).map(i=>rob.io.commit.arch_valids(i)&&(rob.io.commit.uops(i).is_jal))
  val jalr_commit  = (0 until coreWidth).map(i=>rob.io.commit.arch_valids(i)&&(rob.io.commit.uops(i).is_jalr))

  val total_mispred   = (0 until coreWidth).map(i=>rob.io.commit.arch_valids(i)&&(rob.io.commit.uops(i).is_br||rob.io.commit.uops(i).is_jal||rob.io.commit.uops(i).is_jalr)&&(rob.io.commit.uops(i).debug_fsrc===BSRC_C))
  val br_mispred      = (0 until coreWidth).map(i=>rob.io.commit.arch_valids(i)&&(rob.io.commit.uops(i).is_br)&&(rob.io.commit.uops(i).debug_fsrc===BSRC_C))




  val perfEvents = new freechips.rocketchip.meek.EventSets(Seq(
    new freechips.rocketchip.meek.EventSet((mask, hits) => (mask & hits).orR, Seq(
      ("exception"    ,       () => (rob.io.com_xcpt.valid,false.B,0.U)),
      ("Slots Retired",       () => (rob.io.commit.arch_valids.reduce(_|_),true.B,PopCount(rob.io.commit.arch_valids))),
      ("Slots Issued" ,       () => (issue_valids.reduce(_|_)  ,true.B,PopCount(issue_valids))),
      ("Fetch Bubbles",       () => ((!io.ifu.fetchpacket.valid)&&dec_ready,true.B,coreWidth.U)),
      ("Load  commit" ,       () => (load_commit.reduce(_|_)   ,true.B,PopCount(load_commit))),
      ("Store commit" ,       () => (store_commit.reduce(_|_)  ,true.B,PopCount(store_commit))),
      ("fp    commit" ,       () => (fp_commit.reduce(_|_)     ,true.B,PopCount(fp_commit))),
      ("br    commit" ,       () => (br_commit.reduce(_|_)     ,true.B,PopCount(br_commit))),
      ("jal   commit" ,       () => (jal_commit.reduce(_|_)    ,true.B,PopCount(jal_commit))),
      ("jalr  commit" ,       () => (jalr_commit.reduce(_|_)   ,true.B,PopCount(jalr_commit))),
      ("int   commit" ,       () => (int_commit.reduce(_|_)    ,true.B,PopCount(int_commit))),
      ("div   commit" ,       () => (div_commit.reduce(_|_)    ,true.B,PopCount(div_commit))),
      ("mul   commit" ,       () => (mul_commit.reduce(_|_)   ,true.B,PopCount(mul_commit))),
      ("cdc   bp    " ,       () => (io.gh_stall               ,false.B,1.U)),
      ("no    core    " ,       () => (no_core_aval               ,false.B,1.U)),
      ("ic   stall    " ,       () => (debug_ic_stall               ,false.B,1.U)),
      ("nop",       () => (false.B,false.B,0.U)))),

    new freechips.rocketchip.meek.EventSet((mask, hits) => (mask & hits).orR, Seq(
      ("total mispred" ,         () => (total_mispred.reduce(_|_)    ,true.B,PopCount(total_mispred))),
      ("br    mispred" ,         () => (br_mispred.reduce(_|_)       ,true.B,PopCount(br_mispred))),
      ("flush",                  () => (rob.io.flush.valid,false.B,0.U))
    )),

    new freechips.rocketchip.meek.EventSet((mask, hits) => (mask & hits).orR, Seq(
      ("I$ miss",     () => (io.ifu.perf.acquire,false.B,0.U)),
      ("D$ miss",     () => (io.lsu.perf.acquire,false.B,0.U)),
      ("D$ release",  () => (io.lsu.perf.release,false.B,0.U)),
      ("ITLB miss",   () => (io.ifu.perf.tlbMiss,false.B,0.U)),
      ("DTLB miss",   () => (io.lsu.perf.tlbMiss,false.B,0.U)),
      ("L2 TLB miss", () => (io.ptw.perf.l2miss,false.B,0.U))))))
  val csr = Module(new freechips.rocketchip.meek.CSRFileMEEK(perfEvents, boomParams.customCSRs.decls))
  csr.io.inst foreach { c => c := DontCare }
  csr.io.rocc_interrupt := io.rocc.interrupt
  csr.io.mhtinst_read_pseudo := false.B

  val custom_csrs = Wire(new BoomCustomCSRs)
  custom_csrs.csrs.foreach { c => c.stall := false.B; c.set := false.B; c.sdata := DontCare }

  (custom_csrs.csrs zip csr.io.customCSRs).map { case (lhs, rhs) => lhs <> rhs }

  //val icache_blocked = !(io.ifu.fetchpacket.valid || RegNext(io.ifu.fetchpacket.valid))
  val icache_blocked = false.B
  csr.io.counters foreach { c => c.inc := RegNext(perfEvents.evaluate(c.eventSel)) }

  //****************************************
  // Time Stamp Counter & Retired Instruction Counter
  // (only used for printf and vcd dumps - the actual counters are in the CSRFile)
  val debug_tsc_reg = RegInit(0.U(xLen.W))
  val debug_irt_reg = RegInit(0.U(xLen.W))
  val debug_brs     = Reg(Vec(4, UInt(xLen.W)))
  val debug_jals    = Reg(Vec(4, UInt(xLen.W)))
  val debug_jalrs   = Reg(Vec(4, UInt(xLen.W)))

  for (j <- 0 until 4) {
    debug_brs(j) := debug_brs(j) + PopCount(VecInit((0 until coreWidth) map {i =>
      rob.io.commit.arch_valids(i) &&
      (rob.io.commit.uops(i).debug_fsrc === j.U) &&
      rob.io.commit.uops(i).is_br
    }))
    debug_jals(j) := debug_jals(j) + PopCount(VecInit((0 until coreWidth) map {i =>
      rob.io.commit.arch_valids(i) &&
      (rob.io.commit.uops(i).debug_fsrc === j.U) &&
      rob.io.commit.uops(i).is_jal
    }))
    debug_jalrs(j) := debug_jalrs(j) + PopCount(VecInit((0 until coreWidth) map {i =>
      rob.io.commit.arch_valids(i) &&
      (rob.io.commit.uops(i).debug_fsrc === j.U) &&
      rob.io.commit.uops(i).is_jalr
    }))
  }

  dontTouch(debug_brs)
  dontTouch(debug_jals)
  dontTouch(debug_jalrs)

  debug_tsc_reg := debug_tsc_reg + 1.U
  debug_irt_reg := debug_irt_reg + PopCount(rob.io.commit.arch_valids.asUInt)
  dontTouch(debug_tsc_reg)
  dontTouch(debug_irt_reg)

  //****************************************
  // Print-out information about the machine

  val issStr =
    if (enableAgePriorityIssue) " (Age-based Priority)"
    else " (Unordered Priority)"

  // val btbStr =
  //   if (enableBTB) ("" + boomParams.btb.nSets * boomParams.btb.nWays + " entries (" + boomParams.btb.nSets + " x " + boomParams.btb.nWays + " ways)")
  //   else 0
  val btbStr = ""

  val fpPipelineStr =
    if (usingFPU) fp_pipeline.toString
    else ""

  override def toString: String =
    (BoomCoreStringPrefix("====Overall Core Params====") + "\n"
    + exe_units.toString + "\n"
    + fpPipelineStr + "\n"
    + rob.toString + "\n"
    + BoomCoreStringPrefix(
        "===Other Core Params===",
        "Fetch Width           : " + fetchWidth,
        "Decode Width          : " + coreWidth,
        "Issue Width           : " + issueParams.map(_.issueWidth).sum,
        "ROB Size              : " + numRobEntries,
        "Issue Window Size     : " + issueParams.map(_.numEntries) + issStr,
        "Load/Store Unit Size  : " + numLdqEntries + "/" + numStqEntries,
        "Num Int Phys Registers: " + numIntPhysRegs,
        "Num FP  Phys Registers: " + numFpPhysRegs,
        "Max Branch Count      : " + maxBrCount)
    + iregfile.toString + "\n"
    + BoomCoreStringPrefix(
        "Num Slow Wakeup Ports : " + numIrfWritePorts,
        "Num Fast Wakeup Ports : " + exe_units.count(_.bypassable),
        "Num Bypass Ports      : " + exe_units.numTotalBypassPorts) + "\n"
    + BoomCoreStringPrefix(
        "DCache Ways           : " + dcacheParams.nWays,
        "DCache Sets           : " + dcacheParams.nSets,
        "DCache nMSHRs         : " + dcacheParams.nMSHRs,
        "ICache Ways           : " + icacheParams.nWays,
        "ICache Sets           : " + icacheParams.nSets,
        "D-TLB Ways            : " + dcacheParams.nTLBWays,
        "I-TLB Ways            : " + icacheParams.nTLBWays,
        "Paddr Bits            : " + paddrBits,
        "Vaddr Bits            : " + vaddrBits) + "\n"
    + BoomCoreStringPrefix(
        "Using FPU Unit?       : " + usingFPU.toString,
        "Using FDivSqrt?       : " + usingFDivSqrt.toString,
        "Using VM?             : " + usingVM.toString) + "\n")

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Fetch Stage/Frontend ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------
  io.ifu.redirect_val         := false.B
  io.ifu.redirect_flush       := false.B

  // Breakpoint info
  io.ifu.status  := csr.io.status
  io.ifu.bp      := csr.io.bp
  io.ifu.mcontext := csr.io.mcontext
  io.ifu.scontext := csr.io.scontext

  io.ifu.flush_icache := (0 until coreWidth).map { i =>
    (rob.io.commit.arch_valids(i) && rob.io.commit.uops(i).is_fencei) ||
    (RegNext(dec_valids(i) && dec_uops(i).is_jalr && csr.io.status.debug))
  }.reduce(_||_)

  // TODO FIX THIS HACK
  // The below code works because of two quirks with the flush mechanism
  //  1 ) All flush_on_commit instructions are also is_unique,
  //      In the future, this constraint will be relaxed.
  //  2 ) We send out flush signals one cycle after the commit signal. We need to
  //      mux between one/two cycle delay for the following cases:
  //       ERETs are reported to the CSR two cycles before we send the flush
  //       Exceptions are reported to the CSR on the cycle we send the flush
  // This discrepency should be resolved elsewhere.
  when (RegNext(rob.io.flush.valid)) {
    io.ifu.redirect_val   := true.B
    io.ifu.redirect_flush := true.B
    val flush_typ = RegNext(rob.io.flush.bits.flush_typ)
    // Clear the global history when we flush the ROB (exceptions, AMOs, unique instructions, etc.)
    val new_ghist = WireInit((0.U).asTypeOf(new GlobalHistory))
    new_ghist.current_saw_branch_not_taken := true.B
    new_ghist.ras_idx := io.ifu.get_pc(0).entry.ras_idx
    io.ifu.redirect_ghist := new_ghist
    when (FlushTypes.useCsrEvec(flush_typ)) {
      io.ifu.redirect_pc  := Mux(flush_typ === FlushTypes.eret,
                                 RegNext(RegNext(csr.io.evec)),
                                 csr.io.evec)
    } .otherwise {
      val flush_pc = (AlignPCToBoundary(io.ifu.get_pc(0).pc, icBlockBytes)
                      + RegNext(rob.io.flush.bits.pc_lob)
                      - Mux(RegNext(rob.io.flush.bits.edge_inst), 2.U, 0.U))
      val flush_pc_next = flush_pc + Mux(RegNext(rob.io.flush.bits.is_rvc), 2.U, 4.U)
      io.ifu.redirect_pc := Mux(FlushTypes.useSamePC(flush_typ),
                                flush_pc, flush_pc_next)

    }
    io.ifu.redirect_ftq_idx := RegNext(rob.io.flush.bits.ftq_idx)
  } .elsewhen (brupdate.b2.mispredict && !RegNext(rob.io.flush.valid)) {
    val block_pc = AlignPCToBoundary(io.ifu.get_pc(1).pc, icBlockBytes)
    val uop_maybe_pc = block_pc | brupdate.b2.uop.pc_lob
    val npc = uop_maybe_pc + Mux(brupdate.b2.uop.is_rvc || brupdate.b2.uop.edge_inst, 2.U, 4.U)
    val jal_br_target = Wire(UInt(vaddrBitsExtended.W))
    jal_br_target := (uop_maybe_pc.asSInt + brupdate.b2.target_offset +
      (Fill(vaddrBitsExtended-1, brupdate.b2.uop.edge_inst) << 1).asSInt).asUInt
    val bj_addr = Mux(brupdate.b2.cfi_type === CFI_JALR, brupdate.b2.jalr_target, jal_br_target)
    val mispredict_target = Mux(brupdate.b2.pc_sel === PC_PLUS4, npc, bj_addr)
    io.ifu.redirect_val     := true.B
    io.ifu.redirect_pc      := mispredict_target
    io.ifu.redirect_flush   := true.B
    io.ifu.redirect_ftq_idx := brupdate.b2.uop.ftq_idx
    val use_same_ghist = (brupdate.b2.cfi_type === CFI_BR &&
                          !brupdate.b2.taken &&
                          bankAlign(block_pc) === bankAlign(npc))
    val ftq_entry = io.ifu.get_pc(1).entry
    val cfi_idx = (brupdate.b2.uop.pc_lob ^
      Mux(ftq_entry.start_bank === 1.U, 1.U << log2Ceil(bankBytes), 0.U))(log2Ceil(fetchWidth), 1)
    val ftq_ghist = io.ifu.get_pc(1).ghist
    val next_ghist = ftq_ghist.update(
      ftq_entry.br_mask.asUInt,
      brupdate.b2.taken,
      brupdate.b2.cfi_type === CFI_BR,
      cfi_idx,
      true.B,
      io.ifu.get_pc(1).pc,
      ftq_entry.cfi_is_call && ftq_entry.cfi_idx.bits === cfi_idx,
      ftq_entry.cfi_is_ret  && ftq_entry.cfi_idx.bits === cfi_idx)


    io.ifu.redirect_ghist   := Mux(
      use_same_ghist,
      ftq_ghist,
      next_ghist)
    io.ifu.redirect_ghist.current_saw_branch_not_taken := use_same_ghist
  } .elsewhen (rob.io.flush_frontend || brupdate.b1.mispredict_mask =/= 0.U) {
    io.ifu.redirect_flush   := true.B
  }

  // Tell the FTQ it can deallocate entries by passing youngest ftq_idx.
  val youngest_com_idx = (coreWidth-1).U - PriorityEncoder(rob.io.commit.valids.reverse)
  io.ifu.commit.valid := rob.io.commit.valids.reduce(_|_) || rob.io.com_xcpt.valid
  io.ifu.commit.bits  := Mux(rob.io.com_xcpt.valid,
                             rob.io.com_xcpt.bits.ftq_idx,
                             rob.io.commit.uops(youngest_com_idx).ftq_idx)

  assert(!(rob.io.commit.valids.reduce(_|_) && rob.io.com_xcpt.valid),
    "ROB can't commit and except in same cycle!")

  for (i <- 0 until memWidth) {
    when (RegNext(io.lsu.exe(i).req.bits.sfence.valid)) {
      io.ifu.sfence := RegNext(io.lsu.exe(i).req.bits.sfence)
    }
  }

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Branch Prediction ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Decode Stage ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  // track mask of finished instructions in the bundle
  // use this to mask out insts coming from FetchBuffer that have been finished
  // for example, back pressure may cause us to only issue some instructions from FetchBuffer
  // but on the next cycle, we only want to retry a subset
  val dec_finished_mask = RegInit(0.U(coreWidth.W))

  //-------------------------------------------------------------
  // Pull out instructions and send to the Decoders

  io.ifu.fetchpacket.ready := dec_ready
  val dec_fbundle = io.ifu.fetchpacket.bits

  //-------------------------------------------------------------
  // Decoders

  for (w <- 0 until coreWidth) {
    dec_valids(w)                      := io.ifu.fetchpacket.valid && dec_fbundle.uops(w).valid &&
                                          !dec_finished_mask(w)
    decode_units(w).io.enq.uop         := dec_fbundle.uops(w).bits
    decode_units(w).io.status          := csr.io.status
    decode_units(w).io.csr_decode      <> csr.io.decode(w)
    decode_units(w).io.interrupt       := csr.io.interrupt
    decode_units(w).io.interrupt_cause := csr.io.interrupt_cause

    dec_uops(w) := decode_units(w).io.deq.uop
  }

  //-------------------------------------------------------------
  // FTQ GetPC Port Arbitration

  val jmp_pc_req  = Wire(Decoupled(UInt(log2Ceil(ftqSz).W)))
  val xcpt_pc_req = Wire(Decoupled(UInt(log2Ceil(ftqSz).W)))
  val flush_pc_req = Wire(Decoupled(UInt(log2Ceil(ftqSz).W)))

  val ftq_arb = Module(new Arbiter(UInt(log2Ceil(ftqSz).W), 3))

  // Order by the oldest. Flushes come from the oldest instructions in pipe
  // Decoding exceptions come from youngest
  ftq_arb.io.in(0) <> flush_pc_req
  ftq_arb.io.in(1) <> jmp_pc_req
  ftq_arb.io.in(2) <> xcpt_pc_req

  // Hookup FTQ
  io.ifu.get_pc(0).ftq_idx := ftq_arb.io.out.bits
  ftq_arb.io.out.ready  := true.B

  // Branch Unit Requests (for JALs) (Should delay issue of JALs if this not ready)
  jmp_pc_req.valid := RegNext(iss_valids(jmp_unit_idx) && iss_uops(jmp_unit_idx).fu_code === FU_JMP)
  jmp_pc_req.bits  := RegNext(iss_uops(jmp_unit_idx).ftq_idx)

  jmp_unit.io.get_ftq_pc := DontCare
  jmp_unit.io.get_ftq_pc.pc               := io.ifu.get_pc(0).pc
  jmp_unit.io.get_ftq_pc.entry            := io.ifu.get_pc(0).entry
  jmp_unit.io.get_ftq_pc.next_val         := io.ifu.get_pc(0).next_val
  jmp_unit.io.get_ftq_pc.next_pc          := io.ifu.get_pc(0).next_pc


  // Frontend Exception Requests
  val xcpt_idx = PriorityEncoder(dec_xcpts)
  xcpt_pc_req.valid    := dec_xcpts.reduce(_||_)
  xcpt_pc_req.bits     := dec_uops(xcpt_idx).ftq_idx
  //rob.io.xcpt_fetch_pc := RegEnable(io.ifu.get_pc.fetch_pc, dis_ready)
  rob.io.xcpt_fetch_pc := io.ifu.get_pc(0).pc

  flush_pc_req.valid   := rob.io.flush.valid
  flush_pc_req.bits    := rob.io.flush.bits.ftq_idx

  // Mispredict requests (to get the correct target)
  io.ifu.get_pc(1).ftq_idx := oldest_mispredict_ftq_idx


  //-------------------------------------------------------------
  // Decode/Rename1 pipeline logic

  dec_xcpts := dec_uops zip dec_valids map {case (u,v) => u.exception && v}
  val dec_xcpt_stall = dec_xcpts.reduce(_||_) && !xcpt_pc_req.ready
  // stall fetch/dcode because we ran out of branch tags
  val branch_mask_full = Wire(Vec(coreWidth, Bool()))

  val dec_hazards = (0 until coreWidth).map(w =>
                      dec_valids(w) &&
                      (  !dis_ready
                      || rob.io.commit.rollback
                      || dec_xcpt_stall
                      || branch_mask_full(w)
                      || brupdate.b1.mispredict_mask =/= 0.U
                      || brupdate.b2.mispredict
                      || io.ifu.redirect_flush))

  val dec_stalls = dec_hazards.scanLeft(false.B) ((s,h) => s || h).takeRight(coreWidth)
  dec_fire := (0 until coreWidth).map(w => dec_valids(w) && !dec_stalls(w))

  // all decoders are empty and ready for new instructions
  dec_ready := dec_fire.last

  when (dec_ready || io.ifu.redirect_flush) {
    dec_finished_mask := 0.U
  } .otherwise {
    dec_finished_mask := dec_fire.asUInt | dec_finished_mask
  }

  //-------------------------------------------------------------
  // Branch Mask Logic

  dec_brmask_logic.io.brupdate := brupdate
  dec_brmask_logic.io.flush_pipeline := RegNext(rob.io.flush.valid)

  for (w <- 0 until coreWidth) {
    dec_brmask_logic.io.is_branch(w) := !dec_finished_mask(w) && dec_uops(w).allocate_brtag
    dec_brmask_logic.io.will_fire(w) :=  dec_fire(w) &&
                                         dec_uops(w).allocate_brtag // ren, dis can back pressure us
    dec_uops(w).br_tag  := dec_brmask_logic.io.br_tag(w)
    dec_uops(w).br_mask := dec_brmask_logic.io.br_mask(w)
  }

  branch_mask_full := dec_brmask_logic.io.is_full

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Register Rename Stage ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  // Inputs
  for (rename <- rename_stages) {
    rename.io.kill := io.ifu.redirect_flush
    rename.io.brupdate := brupdate

    rename.io.debug_rob_empty := rob.io.empty

    rename.io.dec_fire := dec_fire
    rename.io.dec_uops := dec_uops

    rename.io.dis_fire := dis_fire
    rename.io.dis_ready := dis_ready

    rename.io.com_valids := rob.io.commit.valids
    rename.io.com_uops := rob.io.commit.uops
    rename.io.rbk_valids := rob.io.commit.rbk_valids
    rename.io.rollback := rob.io.commit.rollback
  }


  // Outputs
  dis_uops := rename_stage.io.ren2_uops
  dis_valids := rename_stage.io.ren2_mask
  ren_stalls := rename_stage.io.ren_stalls


  /**
   * TODO This is a bit nasty, but it's currently necessary to
   * split the INT/FP rename pipelines into separate instantiations.
   * Won't have to do this anymore with a properly decoupled FP pipeline.
   */
  for (w <- 0 until coreWidth) {
    val i_uop   = rename_stage.io.ren2_uops(w)
    val f_uop   = if (usingFPU) fp_rename_stage.io.ren2_uops(w) else NullMicroOp
    val p_uop   = if (enableSFBOpt) pred_rename_stage.io.ren2_uops(w) else NullMicroOp
    val f_stall = if (usingFPU) fp_rename_stage.io.ren_stalls(w) else false.B
    val p_stall = if (enableSFBOpt) pred_rename_stage.io.ren_stalls(w) else false.B

    // lrs1 can "pass through" to prs1. Used solely to index the csr file.
    dis_uops(w).prs1 := Mux(dis_uops(w).lrs1_rtype === RT_FLT, f_uop.prs1,
                        Mux(dis_uops(w).lrs1_rtype === RT_FIX, i_uop.prs1, dis_uops(w).lrs1))
    dis_uops(w).prs2 := Mux(dis_uops(w).lrs2_rtype === RT_FLT, f_uop.prs2, i_uop.prs2)
    dis_uops(w).prs3 := f_uop.prs3
    dis_uops(w).ppred := p_uop.ppred
    dis_uops(w).pdst := Mux(dis_uops(w).dst_rtype  === RT_FLT, f_uop.pdst,
                        Mux(dis_uops(w).dst_rtype  === RT_FIX, i_uop.pdst,
                                                               p_uop.pdst))
    dis_uops(w).stale_pdst := Mux(dis_uops(w).dst_rtype === RT_FLT, f_uop.stale_pdst, i_uop.stale_pdst)

    dis_uops(w).prs1_busy := i_uop.prs1_busy && (dis_uops(w).lrs1_rtype === RT_FIX) ||
                             f_uop.prs1_busy && (dis_uops(w).lrs1_rtype === RT_FLT)
    dis_uops(w).prs2_busy := i_uop.prs2_busy && (dis_uops(w).lrs2_rtype === RT_FIX) ||
                             f_uop.prs2_busy && (dis_uops(w).lrs2_rtype === RT_FLT)
    dis_uops(w).prs3_busy := f_uop.prs3_busy && dis_uops(w).frs3_en
    dis_uops(w).ppred_busy := p_uop.ppred_busy && dis_uops(w).is_sfb_shadow

    ren_stalls(w) := rename_stage.io.ren_stalls(w) || f_stall || p_stall
  }

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Dispatch Stage ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  //-------------------------------------------------------------
  // Rename2/Dispatch pipeline logic

  val dis_prior_slot_valid = dis_valids.scanLeft(false.B) ((s,v) => s || v)
  val dis_prior_slot_unique = (dis_uops zip dis_valids).scanLeft(false.B) {case (s,(u,v)) => s || v && u.is_unique}
  val wait_for_empty_pipeline = (0 until coreWidth).map(w => (dis_uops(w).is_unique || custom_csrs.disableOOO) &&
                                  (!rob.io.empty || !io.lsu.fencei_rdy || dis_prior_slot_valid(w)))
  val rocc_shim_busy = if (usingRoCC) !exe_units.rocc_unit.io.rocc.rxq_empty else false.B
  val wait_for_rocc = (0 until coreWidth).map(w =>
                        (dis_uops(w).is_fence || dis_uops(w).is_fencei) && (io.rocc.busy || rocc_shim_busy))
  val rxq_full = if (usingRoCC) exe_units.rocc_unit.io.rocc.rxq_full else false.B
  val block_rocc = (dis_uops zip dis_valids).map{case (u,v) => v && u.uopc === uopROCC}.scanLeft(rxq_full)(_||_)
  val dis_rocc_alloc_stall = (dis_uops.map(_.uopc === uopROCC) zip block_rocc) map {case (p,r) =>
                               if (usingRoCC) p && r else false.B}

  val dis_hazards = (0 until coreWidth).map(w =>
                      dis_valids(w) &&
                      (  !rob.io.ready
                      || ren_stalls(w)
                      || io.lsu.ldq_full(w) && dis_uops(w).uses_ldq
                      || io.lsu.stq_full(w) && dis_uops(w).uses_stq
                      || !dispatcher.io.ren_uops(w).ready
                      || wait_for_empty_pipeline(w)
                      || wait_for_rocc(w)
                      || dis_prior_slot_unique(w)
                      || dis_rocc_alloc_stall(w)
                      || brupdate.b1.mispredict_mask =/= 0.U
                      || brupdate.b2.mispredict
                      || io.ifu.redirect_flush))


  io.lsu.fence_dmem := (dis_valids zip wait_for_empty_pipeline).map {case (v,w) => v && w} .reduce(_||_)

  val dis_stalls = dis_hazards.scanLeft(false.B) ((s,h) => s || h).takeRight(coreWidth)
  dis_fire := dis_valids zip dis_stalls map {case (v,s) => v && !s}
  dis_ready := !dis_stalls.last

  //-------------------------------------------------------------
  // LDQ/STQ Allocation Logic

  for (w <- 0 until coreWidth) {
    // Dispatching instructions request load/store queue entries when they can proceed.
    dis_uops(w).ldq_idx := io.lsu.dis_ldq_idx(w)
    dis_uops(w).stq_idx := io.lsu.dis_stq_idx(w)
  }

  //-------------------------------------------------------------
  // Rob Allocation Logic
//===== GuardianCouncil Function: Start   ====//
  val rsu_stall = WireInit(0.U(1.W))
  val ic_stall = WireInit(0.U(1.W))
  val r_exception_record = RegInit(0.U(1.W))
  rob.io.gh_stall  := (io.gh_stall|rsu_stall|ic_stall|io.big_hang) & (~r_exception_record) & (io.if_correct_process) & (~csr.io.r_exception) & (~csr.io.trace(0).exception.asUInt)
  rob.io.debug_st  := io.lsu.stq_debug
  //  rob.io.gh_stall  := (io.gh_stall|rsu_stall|ic_stall) & (~r_exception_record) & (io.if_correct_process) & (~csr.io.r_exception) & (~csr.io.trace(0).exception.asUInt)
  //===== GuardianCouncil Function: End   ====//
  rob.io.enq_valids := dis_fire
  rob.io.enq_uops   := dis_uops
  rob.io.enq_partial_stall := dis_stalls.last // TODO come up with better ROB compacting scheme.
  rob.io.debug_tsc := debug_tsc_reg
  rob.io.csr_stall := csr.io.csr_stall
  
  // Minor hack: ecall and breaks need to increment the FTQ deq ptr earlier than commit, since
  // they write their PC into the CSR the cycle before they commit.
  // Since these are also unique, increment the FTQ ptr when they are dispatched
  when (RegNext(dis_fire.reduce(_||_) && dis_uops(PriorityEncoder(dis_fire)).is_sys_pc2epc)) {
    io.ifu.commit.valid := true.B
    io.ifu.commit.bits  := RegNext(dis_uops(PriorityEncoder(dis_valids)).ftq_idx)
  }

  for (w <- 0 until coreWidth) {
    // note: this assumes uops haven't been shifted - there's a 1:1 match between PC's LSBs and "w" here
    // (thus the LSB of the rob_idx gives part of the PC)
    if (coreWidth == 1) {
      dis_uops(w).rob_idx := rob.io.rob_tail_idx
    } else {
      dis_uops(w).rob_idx := Cat(rob.io.rob_tail_idx >> log2Ceil(coreWidth).U,
                               w.U(log2Ceil(coreWidth).W))
    }
  }

  //-------------------------------------------------------------
  // RoCC allocation logic
  if (usingRoCC) {
    for (w <- 0 until coreWidth) {
      // We guarantee only decoding 1 RoCC instruction per cycle
      dis_uops(w).rxq_idx := exe_units.rocc_unit.io.rocc.rxq_idx(w)
    }
  }

  //-------------------------------------------------------------
  // Dispatch to issue queues

  // Get uops from rename2
  for (w <- 0 until coreWidth) {
    dispatcher.io.ren_uops(w).valid := dis_fire(w)
    dispatcher.io.ren_uops(w).bits  := dis_uops(w)
  }

  var iu_idx = 0
  // Send dispatched uops to correct issue queues
  // Backpressure through dispatcher if necessary
  for (i <- 0 until issueParams.size) {
    if (issueParams(i).iqType == IQT_FP.litValue) {
       fp_pipeline.io.dis_uops <> dispatcher.io.dis_uops(i)
    } else {
       issue_units(iu_idx).io.dis_uops <> dispatcher.io.dis_uops(i)
       iu_idx += 1
    }
  }

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Issue Stage ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  require (issue_units.map(_.issueWidth).sum == exe_units.length)

  var iss_wu_idx = 1
  var ren_wu_idx = 1
  // The 0th wakeup port goes to the ll_wbarb
  int_iss_wakeups(0).valid := ll_wbarb.io.out.fire && ll_wbarb.io.out.bits.uop.dst_rtype === RT_FIX
  int_iss_wakeups(0).bits  := ll_wbarb.io.out.bits

  int_ren_wakeups(0).valid := ll_wbarb.io.out.fire && ll_wbarb.io.out.bits.uop.dst_rtype === RT_FIX
  int_ren_wakeups(0).bits  := ll_wbarb.io.out.bits

  for (i <- 1 until memWidth) {
    int_iss_wakeups(i).valid := mem_resps(i).valid && mem_resps(i).bits.uop.dst_rtype === RT_FIX
    int_iss_wakeups(i).bits  := mem_resps(i).bits

    int_ren_wakeups(i).valid := mem_resps(i).valid && mem_resps(i).bits.uop.dst_rtype === RT_FIX
    int_ren_wakeups(i).bits  := mem_resps(i).bits
    iss_wu_idx += 1
    ren_wu_idx += 1
  }

  // loop through each issue-port (exe_units are statically connected to an issue-port)
  for (i <- 0 until exe_units.length) {
    if (exe_units(i).writesIrf) {
      val fast_wakeup = Wire(Valid(new ExeUnitResp(xLen)))
      val slow_wakeup = Wire(Valid(new ExeUnitResp(xLen)))
      fast_wakeup := DontCare
      slow_wakeup := DontCare

      val resp = exe_units(i).io.iresp
      assert(!(resp.valid && resp.bits.uop.rf_wen && resp.bits.uop.dst_rtype =/= RT_FIX))

      // Fast Wakeup (uses just-issued uops that have known latencies)
      fast_wakeup.bits.uop := iss_uops(i)
      fast_wakeup.valid    := iss_valids(i) &&
                              iss_uops(i).bypassable &&
                              iss_uops(i).dst_rtype === RT_FIX &&
                              iss_uops(i).ldst_val &&
                              !(io.lsu.ld_miss && (iss_uops(i).iw_p1_poisoned || iss_uops(i).iw_p2_poisoned))

      // Slow Wakeup (uses write-port to register file)
      slow_wakeup.bits.uop := resp.bits.uop
      slow_wakeup.valid    := resp.valid &&
                                resp.bits.uop.rf_wen &&
                                !resp.bits.uop.bypassable &&
                                resp.bits.uop.dst_rtype === RT_FIX

      if (exe_units(i).bypassable) {
        int_iss_wakeups(iss_wu_idx) := fast_wakeup
        iss_wu_idx += 1
      }
      if (!exe_units(i).alwaysBypassable) {
        int_iss_wakeups(iss_wu_idx) := slow_wakeup
        iss_wu_idx += 1
      }

      if (exe_units(i).bypassable) {
        int_ren_wakeups(ren_wu_idx) := fast_wakeup
        ren_wu_idx += 1
      }
      if (!exe_units(i).alwaysBypassable) {
        int_ren_wakeups(ren_wu_idx) := slow_wakeup
        ren_wu_idx += 1
      }
    }
  }
  require (iss_wu_idx == numIntIssueWakeupPorts)
  require (ren_wu_idx == numIntRenameWakeupPorts)
  require (iss_wu_idx == ren_wu_idx)

  // jmp unit performs fast wakeup of the predicate bits
  require (jmp_unit.bypassable)
  pred_wakeup.valid := (iss_valids(jmp_unit_idx) &&
                        iss_uops(jmp_unit_idx).is_sfb_br &&
                        !(io.lsu.ld_miss && (iss_uops(jmp_unit_idx).iw_p1_poisoned || iss_uops(jmp_unit_idx).iw_p2_poisoned))
  )
  pred_wakeup.bits.uop := iss_uops(jmp_unit_idx)
  pred_wakeup.bits.fflags := DontCare
  pred_wakeup.bits.data := DontCare
  pred_wakeup.bits.rs1_data := DontCare
  pred_wakeup.bits.rs2_data := DontCare
  pred_wakeup.bits.predicated := DontCare

  // Perform load-hit speculative wakeup through a special port (performs a poison wake-up).
  issue_units map { iu =>
     iu.io.spec_ld_wakeup := io.lsu.spec_ld_wakeup
  }


  // Connect the predicate wakeup port
  issue_units map { iu =>
    iu.io.pred_wakeup_port.valid := false.B
    iu.io.pred_wakeup_port.bits := DontCare
  }
  if (enableSFBOpt) {
    int_iss_unit.io.pred_wakeup_port.valid := pred_wakeup.valid
    int_iss_unit.io.pred_wakeup_port.bits := pred_wakeup.bits.uop.pdst
  }


  // ----------------------------------------------------------------
  // Connect the wakeup ports to the busy tables in the rename stages

  for ((renport, intport) <- rename_stage.io.wakeups zip int_ren_wakeups) {
    renport <> intport
  }
  if (usingFPU) {
    for ((renport, fpport) <- fp_rename_stage.io.wakeups zip fp_pipeline.io.wakeups) {
       renport <> fpport
    }
  }
  if (enableSFBOpt) {
    pred_rename_stage.io.wakeups(0) := pred_wakeup
  } else {
    pred_rename_stage.io.wakeups := DontCare
  }

  // If we issue loads back-to-back endlessly (probably because we are executing some tight loop)
  // the store buffer will never drain, breaking the memory-model forward-progress guarantee
  // If we see a large number of loads saturate the LSU, pause for a cycle to let a store drain
  val loads_saturating = (mem_iss_unit.io.iss_valids(0) && mem_iss_unit.io.iss_uops(0).uses_ldq)
  val saturating_loads_counter = RegInit(0.U(5.W))
  when (loads_saturating) { saturating_loads_counter := saturating_loads_counter + 1.U }
  .otherwise { saturating_loads_counter := 0.U }
  val pause_mem = RegNext(loads_saturating) && saturating_loads_counter === ~(0.U(5.W))

  var iss_idx = 0
  var int_iss_cnt = 0
  var mem_iss_cnt = 0
  for (w <- 0 until exe_units.length) {
    var fu_types = exe_units(w).io.fu_types
    val exe_unit = exe_units(w)
    if (exe_unit.readsIrf) {
      if (exe_unit.supportedFuncUnits.muld) {
        // Supress just-issued divides from issuing back-to-back, since it's an iterative divider.
        // But it takes a cycle to get to the Exe stage, so it can't tell us it is busy yet.
        val idiv_issued = iss_valids(iss_idx) && iss_uops(iss_idx).fu_code_is(FU_DIV)
        fu_types = fu_types & RegNext(~Mux(idiv_issued, FU_DIV, 0.U))
      }

      if (exe_unit.hasMem) {
        iss_valids(iss_idx) := mem_iss_unit.io.iss_valids(mem_iss_cnt)
        iss_uops(iss_idx)   := mem_iss_unit.io.iss_uops(mem_iss_cnt)
        mem_iss_unit.io.fu_types(mem_iss_cnt) := Mux(pause_mem, 0.U, fu_types)
        mem_iss_cnt += 1
      } else {
        iss_valids(iss_idx) := int_iss_unit.io.iss_valids(int_iss_cnt)
        iss_uops(iss_idx)   := int_iss_unit.io.iss_uops(int_iss_cnt)
        int_iss_unit.io.fu_types(int_iss_cnt) := fu_types
        int_iss_cnt += 1
      }
      iss_idx += 1
    }
  }
  require(iss_idx == exe_units.numIrfReaders)

  issue_units.map(_.io.tsc_reg := debug_tsc_reg)
  issue_units.map(_.io.brupdate := brupdate)
  issue_units.map(_.io.flush_pipeline := RegNext(rob.io.flush.valid))

  // Load-hit Misspeculations
  require (mem_iss_unit.issueWidth <= 2)
  issue_units.map(_.io.ld_miss := io.lsu.ld_miss)

  mem_units.map(u => u.io.com_exception := RegNext(rob.io.flush.valid))

  // Wakeup (Issue & Writeback)
  for {
    iu <- issue_units
    (issport, wakeup) <- iu.io.wakeup_ports zip int_iss_wakeups
  }{
    issport.valid := wakeup.valid
    issport.bits.pdst := wakeup.bits.uop.pdst
    issport.bits.poisoned := wakeup.bits.uop.iw_p1_poisoned || wakeup.bits.uop.iw_p2_poisoned

    require (iu.io.wakeup_ports.length == int_iss_wakeups.length)
  }

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Register Read Stage ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  // Register Read <- Issue (rrd <- iss)
//===== GuardianCouncil Function: Start ====//
  // Register Read <- Issue (rrd <- iss)
  for (i <- 0 until numIrfReadPorts) {
    iregister_read.io.rf_read_ports(i) <> iregfile.io.read_ports(i)
  }

  /* 
  TODO:need add reg to cut the critical path
   */
  // val rob_io_commit_uops_pdst_reg                   = Reg(Vec(coreWidth, UInt(maxPregSz.W)))
  
  for (w <- 0 until coreWidth) {
    // rob_io_commit_uops_pdst_reg(w)                 := rob.io.commit.uops(w).pdst
    iregfile.io.read_ports(numIrfReadPorts+w).addr := rob.io.commit.uops(w).pdst//rob_io_commit_uops_pdst_reg(w)
  }
  //===== GuardianCouncil Function: End ====//
  iregister_read.io.prf_read_ports := DontCare
  if (enableSFBOpt) {
    iregister_read.io.prf_read_ports <> pregfile.io.read_ports
  }

  for (w <- 0 until exe_units.numIrfReaders) {
    iregister_read.io.iss_valids(w) :=
      iss_valids(w) && !(io.lsu.ld_miss && (iss_uops(w).iw_p1_poisoned || iss_uops(w).iw_p2_poisoned))
  }
  iregister_read.io.iss_uops := iss_uops
  iregister_read.io.iss_uops map { u => u.iw_p1_poisoned := false.B; u.iw_p2_poisoned := false.B }

  iregister_read.io.brupdate := brupdate
  iregister_read.io.kill   := RegNext(rob.io.flush.valid)

  iregister_read.io.bypass := bypasses
  iregister_read.io.pred_bypass := pred_bypasses

  //-------------------------------------------------------------
  // Privileged Co-processor 0 Register File
  // Note: Normally this would be bad in that I'm writing state before
  // committing, so to get this to work I stall the entire pipeline for
  // CSR instructions so I never speculate these instructions.

  val csr_exe_unit = exe_units.csr_unit

  // for critical path reasons, we aren't zero'ing this out if resp is not valid
  val csr_rw_cmd = csr_exe_unit.io.iresp.bits.uop.ctrl.csr_cmd
  val wb_wdata = csr_exe_unit.io.iresp.bits.data

  csr.io.rw.addr        := csr_exe_unit.io.iresp.bits.uop.csr_addr
  csr.io.rw.cmd         := freechips.rocketchip.rocket.CSR.maskCmd(csr_exe_unit.io.iresp.valid, csr_rw_cmd)
  csr.io.rw.wdata       := wb_wdata

  rob.io.csr_replay.valid := csr_exe_unit.io.iresp.valid && csr.io.rw_stall
  rob.io.csr_replay.bits.uop := csr_exe_unit.io.iresp.bits.uop
  rob.io.csr_replay.bits.cause := MINI_EXCEPTION_CSR_REPLAY
  rob.io.csr_replay.bits.badvaddr := DontCare

  // Extra I/O
  // Delay retire/exception 1 cycle
  csr.io.retire    := RegNext(PopCount(rob.io.commit.arch_valids.asUInt))
  csr.io.exception := RegNext(rob.io.com_xcpt.valid)
  // csr.io.pc used for setting EPC during exception or CSR.io.trace.

  csr.io.pc        := (boom.meek.util.AlignPCToBoundary(io.ifu.get_pc(0).com_pc, icBlockBytes)
                     + RegNext(rob.io.com_xcpt.bits.pc_lob)
                     - Mux(RegNext(rob.io.com_xcpt.bits.edge_inst), 2.U, 0.U))
  // Cause not valid for for CALL or BREAKPOINTs (CSRFile will override it).
  csr.io.cause     := RegNext(rob.io.com_xcpt.bits.cause)
  csr.io.ungated_clock := clock

  val tval_valid = csr.io.exception &&
    csr.io.cause.isOneOf(
      //Causes.illegal_instruction.U, we currently only write 0x0 for illegal instructions
      Causes.breakpoint.U,
      Causes.misaligned_load.U,
      Causes.misaligned_store.U,
      Causes.load_access.U,
      Causes.store_access.U,
      Causes.fetch_access.U,
      Causes.load_page_fault.U,
      Causes.store_page_fault.U,
      Causes.fetch_page_fault.U)

  csr.io.tval := Mux(tval_valid,
    RegNext(encodeVirtualAddress(rob.io.com_xcpt.bits.badvaddr, rob.io.com_xcpt.bits.badvaddr)), 0.U)

  // TODO move this function to some central location (since this is used elsewhere).
  def encodeVirtualAddress(a0: UInt, ea: UInt) =
    if (vaddrBitsExtended == vaddrBits) {
      ea
    } else {
      // Efficient means to compress 64-bit VA into vaddrBits+1 bits.
      // (VA is bad if VA(vaddrBits) != VA(vaddrBits-1)).
      val a = a0.asSInt >> vaddrBits
      val msb = Mux(a === 0.S || a === -1.S, ea(vaddrBits), !ea(vaddrBits-1))
      Cat(msb, ea(vaddrBits-1,0))
    }

  // reading requires serializing the entire pipeline
  csr.io.fcsr_flags.valid := rob.io.commit.fflags.valid
  csr.io.fcsr_flags.bits  := rob.io.commit.fflags.bits
  csr.io.set_fs_dirty.get := rob.io.commit.fflags.valid

  exe_units.withFilter(_.hasFcsr).map(_.io.fcsr_rm := csr.io.fcsr_rm)
  io.fcsr_rm := csr.io.fcsr_rm

  if (usingFPU) {
    fp_pipeline.io.fcsr_rm := csr.io.fcsr_rm
  }

  csr.io.hartid := io.hartid
  csr.io.interrupts := io.interrupts

  // we do not support the H-extension
  csr.io.htval := DontCare
  csr.io.gva := DontCare

// TODO can we add this back in, but handle reset properly and save us
//      the mux above on csr.io.rw.cmd?
//   assert (!(csr_rw_cmd =/= rocket.CSR.N && !exe_units(0).io.resp(0).valid),
//   "CSRFile is being written to spuriously.")

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Execute Stage ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  iss_idx = 0
  var bypass_idx = 0
  for (w <- 0 until exe_units.length) {
    val exe_unit = exe_units(w)
    if (exe_unit.readsIrf) {
      exe_unit.io.req <> iregister_read.io.exe_reqs(iss_idx)

      if (exe_unit.bypassable) {
        for (i <- 0 until exe_unit.numBypassStages) {
          bypasses(bypass_idx) := exe_unit.io.bypass(i)
          bypass_idx += 1
        }
      }
      iss_idx += 1
    }
  }
  require (bypass_idx == exe_units.numTotalBypassPorts)
  for (i <- 0 until jmp_unit.numBypassStages) {
    pred_bypasses(i) := jmp_unit.io.bypass(i)
  }

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Load/Store Unit ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  // enqueue basic load/store info in Decode
  for (w <- 0 until coreWidth) {
    io.lsu.dis_uops(w).valid := dis_fire(w)
    io.lsu.dis_uops(w).bits  := dis_uops(w)
  }

  // tell LSU about committing loads and stores to clear entries
  io.lsu.commit                  := rob.io.commit

  // tell LSU that it should fire a load that waits for the rob to clear
  io.lsu.commit_load_at_rob_head := rob.io.com_load_is_at_rob_head

  //com_xcpt.valid comes too early, will fight against a branch that resolves same cycle as an exception
  io.lsu.exception := RegNext(rob.io.flush.valid)

  // Handle Branch Mispeculations
  io.lsu.brupdate := brupdate
  io.lsu.rob_head_idx := rob.io.rob_head_idx
  io.lsu.rob_pnr_idx  := rob.io.rob_pnr_idx

  io.lsu.tsc_reg := debug_tsc_reg


  if (usingFPU) {
    io.lsu.fp_stdata <> fp_pipeline.io.to_sdq
  }

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Writeback Stage ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------
  //===== GuardianCouncil Function: Start ====//
  var w_cnt = 1
  iregfile.io.write_ports(0) := WritePort(ll_wbarb.io.out, ipregSz, xLen, RT_FIX)
  ll_wbarb.io.in(0) <> mem_resps(0)
  assert (ll_wbarb.io.in(0).ready) // never backpressure the memory unit.
  for (i <- 1 until memWidth) {
    iregfile.io.write_ports(w_cnt) := WritePort(mem_resps(i), ipregSz, xLen, RT_FIX)
    w_cnt += 1
  }

  for (i <- 0 until exe_units.length) {
    if (exe_units(i).writesIrf) {
      val wbresp = exe_units(i).io.iresp
      val wbpdst = wbresp.bits.uop.pdst
      val wbdata = wbresp.bits.data

      def wbIsValid(rtype: UInt) =
        wbresp.valid && wbresp.bits.uop.rf_wen && wbresp.bits.uop.dst_rtype === rtype
      val wbReadsCSR = wbresp.bits.uop.ctrl.csr_cmd =/= freechips.rocketchip.rocket.CSR.N

      iregfile.io.write_ports(w_cnt).valid     := wbIsValid(RT_FIX)
      iregfile.io.write_ports(w_cnt).bits.addr := wbpdst
      wbresp.ready := true.B
      if (exe_units(i).hasCSR) {
        iregfile.io.write_ports(w_cnt).bits.data := Mux(wbReadsCSR, csr.io.rw.rdata, wbdata)
      } else {
        iregfile.io.write_ports(w_cnt).bits.data := wbdata
      }

      assert (!wbIsValid(RT_FLT), "[fppipeline] An FP writeback is being attempted to the Int Regfile.")

      assert (!(wbresp.valid &&
        !wbresp.bits.uop.rf_wen &&
        wbresp.bits.uop.dst_rtype === RT_FIX),
        "[fppipeline] An Int writeback is being attempted with rf_wen disabled.")

      assert (!(wbresp.valid &&
        wbresp.bits.uop.rf_wen &&
        wbresp.bits.uop.dst_rtype =/= RT_FIX),
        "[fppipeline] writeback being attempted to Int RF with dst != Int type exe_units("+i+").iresp")
      w_cnt += 1
    }
  }
  require(w_cnt == iregfile.io.write_ports.length)

  if (enableSFBOpt) {
    pregfile.io.write_ports(0).valid     := jmp_unit.io.iresp.valid && jmp_unit.io.iresp.bits.uop.is_sfb_br
    pregfile.io.write_ports(0).bits.addr := jmp_unit.io.iresp.bits.uop.pdst
    pregfile.io.write_ports(0).bits.data := jmp_unit.io.iresp.bits.data
  }

  if (usingFPU) {
    // Connect IFPU
    fp_pipeline.io.from_int  <> exe_units.ifpu_unit.io.ll_fresp
    // Connect FPIU
    ll_wbarb.io.in(1)        <> fp_pipeline.io.to_int
    // Connect FLDs
    fp_pipeline.io.ll_wports <> exe_units.memory_units.map(_.io.ll_fresp).toSeq
  }
  if (usingRoCC) {
    require(usingFPU)
    ll_wbarb.io.in(2)       <> exe_units.rocc_unit.io.ll_iresp
  }

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Commit Stage ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  // Writeback
  // ---------
  // First connect the ll_wport
  val ll_uop = ll_wbarb.io.out.bits.uop
  rob.io.wb_resps(0).valid  := ll_wbarb.io.out.valid && !(ll_uop.uses_stq && !ll_uop.is_amo)
  rob.io.wb_resps(0).bits   <> ll_wbarb.io.out.bits
  rob.io.debug_wb_valids(0) := ll_wbarb.io.out.valid && ll_uop.dst_rtype =/= RT_X
  rob.io.debug_wb_wdata(0)  := ll_wbarb.io.out.bits.data
  rob.io.debug_rs1_data(0)  := ll_wbarb.io.out.bits.rs1_data
  rob.io.debug_rs2_data(0)  := ll_wbarb.io.out.bits.rs2_data
  var cnt = 1
  for (i <- 1 until memWidth) {
    val mem_uop = mem_resps(i).bits.uop
    rob.io.wb_resps(cnt).valid := mem_resps(i).valid && !(mem_uop.uses_stq && !mem_uop.is_amo)
    rob.io.wb_resps(cnt).bits  := mem_resps(i).bits
    rob.io.debug_wb_valids(cnt) := mem_resps(i).valid && mem_uop.dst_rtype =/= RT_X
    rob.io.debug_wb_wdata(cnt)  := mem_resps(i).bits.data
    rob.io.debug_rs1_data(cnt)  := mem_resps(i).bits.rs1_data
    rob.io.debug_rs2_data(cnt)  := mem_resps(i).bits.rs2_data
    cnt += 1
  }
  var f_cnt = 0 // rob fflags port index
  for (eu <- exe_units) {
    if (eu.writesIrf)
    {
      val resp   = eu.io.iresp
      val wb_uop = resp.bits.uop
      val data   = resp.bits.data
      val rs1_data = resp.bits.rs1_data
      val rs2_data = resp.bits.rs2_data
      rob.io.wb_resps(cnt).valid := resp.valid && !(wb_uop.uses_stq && !wb_uop.is_amo)
      rob.io.wb_resps(cnt).bits  <> resp.bits
      rob.io.debug_rs1_data(cnt) := rs1_data
      rob.io.debug_rs2_data(cnt) := rs2_data
      rob.io.debug_wb_valids(cnt) := resp.valid && wb_uop.rf_wen && wb_uop.dst_rtype === RT_FIX
      if (eu.hasFFlags) {
        rob.io.fflags(f_cnt) <> resp.bits.fflags
        f_cnt += 1
      }
      if (eu.hasCSR) {
        rob.io.debug_wb_wdata(cnt) := Mux(wb_uop.ctrl.csr_cmd =/= freechips.rocketchip.rocket.CSR.N,
          csr.io.rw.rdata,
          data)
      } else {
        rob.io.debug_wb_wdata(cnt) := data
      }
      cnt += 1
    }
  }

  require(cnt == numIrfWritePorts)
  if (usingFPU) {
    for ((((wdata, wakeup), rs1), rs2) <- (fp_pipeline.io.debug_wb_wdata.zip(fp_pipeline.io.wakeups).zip(fp_pipeline.io.debug_rs1_data).zip(fp_pipeline.io.debug_rs2_data))) {
      rob.io.wb_resps(cnt) <> wakeup
      rob.io.fflags(f_cnt) <> wakeup.bits.fflags
      rob.io.debug_wb_valids(cnt) := wakeup.valid
      rob.io.debug_wb_wdata(cnt) := wdata
      rob.io.debug_rs1_data(cnt) := rs1
      rob.io.debug_rs2_data(cnt) := rs2
      cnt += 1
      f_cnt += 1

      assert (!(wakeup.valid && wakeup.bits.uop.dst_rtype =/= RT_FLT),
        "[core] FP wakeup does not write back to a FP register.")

      assert (!(wakeup.valid && !wakeup.bits.uop.fp_val),
        "[core] FP wakeup does not involve an FP instruction.")
    }
  }

  require (cnt == rob.numWakeupPorts)
  require (f_cnt == rob.numFpuPorts)

  // branch resolution
  rob.io.brupdate <> brupdate

  exe_units.map(u => u.io.status := csr.io.status)
  if (usingFPU)
    fp_pipeline.io.status := csr.io.status

  // Connect breakpoint info to memaddrcalcunit
  for (i <- 0 until memWidth) {
    mem_units(i).io.status   := csr.io.status
    mem_units(i).io.bp       := csr.io.bp
    mem_units(i).io.mcontext := csr.io.mcontext
    mem_units(i).io.scontext := csr.io.scontext
  }
  //===== GuardianCouncil Function: END ====//
  // LSU <> ROB
  rob.io.lsu_clr_bsy    := io.lsu.clr_bsy
  rob.io.lsu_clr_unsafe := io.lsu.clr_unsafe
  rob.io.lxcpt          <> io.lsu.lxcpt
  //===== GuardianCouncil Function: Start ====//
  val gh_effective_jalr_target_reg                = RegInit(0.U(xLen.W))
  gh_effective_jalr_target_reg                   := jmp_unit.io.brinfo.jalr_target
  rob.io.gh_effective_rob_idx                    := jmp_unit.io.iresp.bits.uop.rob_idx
  rob.io.gh_effective_valid                      := jmp_unit.io.iresp.valid
  rob.io.gh_effective_jalr_target                := gh_effective_jalr_target_reg
  //===== GuardianCouncil Function: End   ====//
  assert (!(csr.io.singleStep), "[core] single-step is unsupported.")


  //-------------------------------------------------------------
  // **** Flush Pipeline ****
  //-------------------------------------------------------------
  // flush on exceptions, miniexeptions, and after some special instructions

  if (usingFPU) {
    fp_pipeline.io.flush_pipeline := RegNext(rob.io.flush.valid)
  }

  for (w <- 0 until exe_units.length) {
    exe_units(w).io.req.bits.kill := RegNext(rob.io.flush.valid)
  }

  assert (!(rob.io.com_xcpt.valid && !rob.io.flush.valid),
    "[core] exception occurred, but pipeline flush signal not set!")

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Outputs to the External World ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  // detect pipeline freezes and throw error
  val idle_cycles = freechips.rocketchip.util.WideCounter(32)
  when (rob.io.commit.valids.asUInt.orR ||
        csr.io.csr_stall ||
        io.rocc.busy ||
        reset.asBool) {
    idle_cycles := 0.U
  }
  assert (!(idle_cycles.value(15)), "Pipeline has hung.")

  if (usingFPU) {
    fp_pipeline.io.debug_tsc_reg := debug_tsc_reg
  }

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // **** Handle Cycle-by-Cycle Printouts ****
  //-------------------------------------------------------------
  //-------------------------------------------------------------


  if (COMMIT_LOG_PRINTF) {
    var new_commit_cnt = 0.U

    for (w <- 0 until coreWidth) {
      val priv = RegNext(csr.io.status.prv) // erets change the privilege. Get the old one

      // To allow for diffs against spike :/
      def printf_inst(uop: MicroOp) = {
        when (uop.is_rvc) {
          printf("(0x%x)", uop.debug_inst(15,0))
        } .otherwise {
          printf("(0x%x)", uop.debug_inst)
        }
      }

      when (rob.io.commit.arch_valids(w)) {
        printf("%d 0x%x ",
          priv,
          Sext(rob.io.commit.uops(w).debug_pc(vaddrBits-1,0), xLen))
        printf_inst(rob.io.commit.uops(w))
        when (rob.io.commit.uops(w).dst_rtype === RT_FIX && rob.io.commit.uops(w).ldst =/= 0.U) {
          printf(" x%d 0x%x\n",
            rob.io.commit.uops(w).ldst,
            rob.io.commit.debug_wdata(w))
        } .elsewhen (rob.io.commit.uops(w).dst_rtype === RT_FLT) {
          printf(" f%d 0x%x\n",
            rob.io.commit.uops(w).ldst,
            rob.io.commit.debug_wdata(w))
        } .otherwise {
          printf("\n")
        }
      }
    }
  } else if (BRANCH_PRINTF) {
    val debug_ghist = RegInit(0.U(globalHistoryLength.W))
    when (rob.io.flush.valid && FlushTypes.useCsrEvec(rob.io.flush.bits.flush_typ)) {
      debug_ghist := 0.U
    }

    var new_ghist = debug_ghist

    for (w <- 0 until coreWidth) {
      when (rob.io.commit.arch_valids(w) &&
        (rob.io.commit.uops(w).is_br || rob.io.commit.uops(w).is_jal || rob.io.commit.uops(w).is_jalr)) {
        // for (i <- 0 until globalHistoryLength) {
        //   printf("%x", new_ghist(globalHistoryLength-i-1))
        // }
        // printf("\n")
        printf("%x %x %x %x %x %x\n",
          rob.io.commit.uops(w).debug_fsrc, rob.io.commit.uops(w).taken,
          rob.io.commit.uops(w).is_br, rob.io.commit.uops(w).is_jal,
          rob.io.commit.uops(w).is_jalr, Sext(rob.io.commit.uops(w).debug_pc(vaddrBits-1,0), xLen))

      }
      new_ghist = Mux(rob.io.commit.arch_valids(w) && rob.io.commit.uops(w).is_br,
        Mux(rob.io.commit.uops(w).taken, new_ghist << 1 | 1.U(1.W), new_ghist << 1),
        new_ghist)
    }
    debug_ghist := new_ghist
  }

  // TODO: Does anyone want this debugging functionality?
  val coreMonitorBundle = Wire(new CoreMonitorBundle(xLen, fLen))
  coreMonitorBundle := DontCare
  coreMonitorBundle.clock  := clock
  coreMonitorBundle.reset  := reset


  //-------------------------------------------------------------
  //-------------------------------------------------------------
  // Page Table Walker

  io.ptw.ptbr       := csr.io.ptbr
  io.ptw.status     := csr.io.status
  io.ptw.pmp        := csr.io.pmp
  io.ptw.sfence     := io.ifu.sfence

  //-------------------------------------------------------------
  //-------------------------------------------------------------

  io.rocc := DontCare
  io.rocc.exception := csr.io.exception && csr.io.status.xs.orR
  io.rocc.csrs <> csr.io.roccCSRs
  if (usingRoCC) {
    exe_units.rocc_unit.io.rocc.rocc         <> io.rocc
    exe_units.rocc_unit.io.rocc.dis_uops     := dis_uops
    exe_units.rocc_unit.io.rocc.rob_head_idx := rob.io.rob_head_idx
    exe_units.rocc_unit.io.rocc.rob_pnr_idx  := rob.io.rob_pnr_idx
    exe_units.rocc_unit.io.com_exception     := rob.io.flush.valid
    exe_units.rocc_unit.io.status            := csr.io.status

    for (w <- 0 until coreWidth) {
      exe_units.rocc_unit.io.rocc.dis_rocc_vals(w) := (
        dis_fire(w) &&
        dis_uops(w).uopc === uopROCC &&
        !dis_uops(w).exception
      )
    }
  }

  io.trace := DontCare
  io.trace.time := csr.io.time
  io.trace.insns map (t => t.valid := false.B)
  io.trace.custom.get.asInstanceOf[BoomTraceBundle].rob_empty := rob.io.empty

  if (trace) {
    for (w <- 0 until coreWidth) {
      // Delay the trace so we have a cycle to pull PCs out of the FTQ
      io.trace.insns(w).valid      := RegNext(rob.io.commit.arch_valids(w))

      // Recalculate the PC
      io.ifu.debug_ftq_idx(w) := rob.io.commit.uops(w).ftq_idx
      val iaddr = (AlignPCToBoundary(io.ifu.debug_fetch_pc(w), icBlockBytes)
                   + RegNext(rob.io.commit.uops(w).pc_lob)
                   - Mux(RegNext(rob.io.commit.uops(w).edge_inst), 2.U, 0.U))(vaddrBits-1,0)
      io.trace.insns(w).iaddr      := Sext(iaddr, xLen)

      def getInst(uop: MicroOp, inst: UInt): UInt = {
        Mux(uop.is_rvc, Cat(0.U(16.W), inst(15,0)), inst)
      }

      def getWdata(uop: MicroOp, wdata: UInt): UInt = {
        Mux((uop.dst_rtype === RT_FIX && uop.ldst =/= 0.U) || (uop.dst_rtype === RT_FLT), wdata, 0.U(xLen.W))
      }

      // use debug_insts instead of uop.debug_inst to use the rob's debug_inst_mem
      // note: rob.debug_insts comes 1 cycle later
      io.trace.insns(w).insn       := getInst(RegNext(rob.io.commit.uops(w)), rob.io.commit.debug_insts(w))
      io.trace.insns(w).wdata.map { _ := RegNext(getWdata(rob.io.commit.uops(w), rob.io.commit.debug_wdata(w))) }

      // Comment out this assert because it blows up FPGA synth-asserts
      // This tests correctedness of the debug_inst mem
      // when (RegNext(rob.io.commit.valids(w))) {
      //   assert(rob.io.commit.debug_insts(w) === RegNext(rob.io.commit.uops(w).debug_inst))
      // }
      // This tests correctedness of recovering pcs through ftq debug ports
      // when (RegNext(rob.io.commit.valids(w))) {
      //   assert(Sext(io.trace.insns(w).iaddr, xLen) ===
      //     RegNext(Sext(rob.io.commit.uops(w).debug_pc(vaddrBits-1,0), xLen)))
      // }

      // These csr signals do not exactly match up with the ROB commit signals.
      io.trace.insns(w).priv       := RegNext(Cat(RegNext(csr.io.status.debug), csr.io.status.prv))
      // Can determine if it is an interrupt or not based on the MSB of the cause
      io.trace.insns(w).exception  := RegNext(rob.io.com_xcpt.valid && !rob.io.com_xcpt.bits.cause(xLen - 1)) && (w == 0).B
      io.trace.insns(w).interrupt  := RegNext(rob.io.com_xcpt.valid && rob.io.com_xcpt.bits.cause(xLen - 1)) && (w == 0).B
      io.trace.insns(w).cause      := RegNext(rob.io.com_xcpt.bits.cause)
      io.trace.insns(w).tval       := RegNext(csr.io.tval)
    }
    dontTouch(io.trace)
  } else {
    io.ifu.debug_ftq_idx := DontCare
  }
//===== GuardianCouncil Function: Start ====//
  // val ght_prfs_forward_prf_reg                    = Reg(Vec(coreWidth, Bool()))
  // val ght_prfs_forward_prf_reg_test               = Reg(Vec(coreWidth, Bool()))
  val if_mret_or_sret                             = Reg(Vec(coreWidth, Bool()))

  // val csrshadow_seq                               = (CSRshadows.allshadows.map(_.asUInt)).toSeq ++ Seq(CSRs.fflags.U, CSRs.fcsr.U, CSRs.frm.U)
  val csrshadow_seq                               = Seq(CSRs.fflags.U, CSRs.fcsr.U, CSRs.frm.U)
  for (w <- 0 until coreWidth) {
    // ght_prfs_forward_prf_reg_test(w)             := (io.ght_prfs_forward_prf(w) && !RegNext(RegNext(rob.io.commit.uops(w).csr_addr)).isOneOf(csrshadow_seq))
    // ght_prfs_forward_prf_reg(w)                  := io.ght_prfs_forward_prf(w)
    // ght_prfs_forward_prf_reg(w)                  := io.ght_prfs_forward_prf(w) && !RegNext(RegNext(rob.io.commit.uops(w).csr_addr)).isOneOf(csrshadow_seq)

    // io.pc(w)                                     := rob.io.commit.uops(w).debug_pc(31,0)
    // io.inst(w)                                   := rob.io.commit.uops(w).debug_inst(31,0)
    // io.new_commit(w)                             := Mux(r_syscall, 0.U, rob.io.commit.arch_valids(w))
    io.commit_valids(w)                             := Mux(r_syscall,false.B,rob.io.commit.arch_valids(w))  
  // io.commit_uops                                  := rob.io.commit.uops
    io.prf_rd(w)                                    := iregfile.io.read_ports(numIrfReadPorts + w).data

    io.csr_addr(w)                               := rob.io.commit.uops(w).csr_addr
    
    // io.uses_ldq(w)                               := rob.io.commit.uops(w).uses_ldq
    // io.uses_stq(w)                               := rob.io.commit.uops(w).uses_stq
    // io.is_jal_or_jalr(w)                         := rob.io.commit.uops(w).is_jal|rob.io.commit.uops(w).is_jalr
    // io.ft_idx(w)                                 := rob.io.commit.uops(w).ftq_idx
    // io.is_rvc(w)                                 := rob.io.commit.uops(w).is_rvc
    io.alu_out(w)                                := rob.io.commit.gh_effective_alu_out(w);
    // if_mret_or_sret(w)                           := rob.io.commit.arch_valids(w) && ((rob.io.commit.uops(w).debug_inst(31,0) === 0x30200073.U) || (rob.io.commit.uops(w).debug_inst(31,0) === 0x10200073.U))
  }
  // dontTouch(ght_prfs_forward_prf_reg)
  // dontTouch(io.ght_prfs_forward_prf)
  // dontTouch(ght_prfs_forward_prf_reg_test)
  io.ght_prv                                     := RegNext(csr.io.status.prv)

  val zero_2bits                                  = WireInit(0.U(2.W))
  val arch_valids_extended                        = Wire(Vec(coreWidth, UInt(3.W)))
  for (i <- 0 until coreWidth) {
    arch_valids_extended(i)                      := Cat(zero_2bits, rob.io.commit.arch_valids.asUInt(i))
  }
  
  val ic_incr                                     = arch_valids_extended.reduce(_ + _)


  val numARFS                                     = 32
  val pcarf                                       = RegInit(0.U(40.W))
  val arfs                                        = Reg(Vec(numARFS, UInt(xLen.W)))
  val farfs                                       = Reg(Vec(numARFS, UInt(xLen.W)))
  // val csrrfs                                      = Reg(Vec(CSRshadows.allshadows.size, UInt(xLen.W)))

  for (w <- 0 until coreWidth) {
    //TODO : check only support linux
    when (rob.io.commit.arch_valids(w)) {
      when (rob.io.commit.uops(w).dst_rtype === RT_FIX && rob.io.commit.uops(w).ldst =/= 0.U && !r_syscall) {
        arfs(rob.io.commit.uops(w).ldst)          := rob.io.commit.debug_wdata(w)
      } .elsewhen (rob.io.commit.uops(w).dst_rtype === RT_FLT && !r_syscall) {
        farfs(rob.io.commit.uops(w).ldst)         := rob.io.commit.debug_wdata(w)
      }
    }
  }

  // when(CSR.isWriteCSR(csr_exe_unit.io.iresp.bits.uop.ctrl.csr_cmd) && !r_syscall && csr_exe_unit.io.iresp.valid){
  //   for(i <- 0 until CSRshadows.allshadows.size){
  //     when(csr_exe_unit.io.iresp.bits.uop.csr_addr === CSRshadows.allshadows(i).U){
  //       csrrfs(i) := wb_wdata
  //     }
  //   }
  // }

  // dontTouch(csrrfs)

  if (GH_GlobalParams.GH_DEBUG == 1) {
    val debug_instruction_counter = RegInit(0.U(64.W))
    val ic_trace_reg = RegInit(0.U(1.W))
    ic_trace_reg := io.ic_trace

    when ((io.ic_trace === 1.U) && (ic_trace_reg === 0.U)){
      debug_instruction_counter := 0.U
    }
    when ((ic_incr =/= 0.U) && (io.ic_trace.asBool) && io.if_correct_process.asBool) {
      debug_instruction_counter := debug_instruction_counter + ic_incr
    }

    // when ((io.ic_trace === 0.U) && (ic_trace_reg === 1.U)){
    //   printf(midas.targetutils.SynthesizePrintf("Debug_IC=[0x%x]\n", debug_instruction_counter))
    // } .otherwise {
    //   when (((debug_instruction_counter & 0x3FFF.U) === 0.U) && (io.ic_trace.asBool)){
    //     printf(midas.targetutils.SynthesizePrintf("Debug_IC=[0x%x]\n", debug_instruction_counter))
    //   }
    // }
    for (w <- 0 until coreWidth) {
      val priv = RegNext(csr.io.status.prv) // erets change the privilege. Get the old one

      // io.trace.insns(w).priv       := RegNext(Cat(RegNext(csr.io.status.debug), csr.io.status.prv))
      // // Can determine if it is an interrupt or not based on the MSB of the cause
      // io.trace.insns(w).exception  := RegNext(rob.io.com_xcpt.valid && !rob.io.com_xcpt.bits.cause(xLen - 1)) && (w == 0).B
      // io.trace.insns(w).interrupt  := RegNext(rob.io.com_xcpt.valid && rob.io.com_xcpt.bits.cause(xLen - 1)) && (w == 0).B
      // io.trace.insns(w).cause      := RegNext(rob.io.com_xcpt.bits.cause)
      // io.trace.insns(w).tval       := RegNext(csr.io.tval)
      when (rob.io.commit.arch_valids(w)&&io.ic_trace.asBool) {
        printf(midas.targetutils.SynthesizePrintf("Boom Priv %d syscall[%x] Exception[%x] Interrupt[%x] cause[%x] tval [%x] PC[0x%x] INST[0x%x] W[%x %x idx %x][arfs r%x ]\n",
          priv,r_syscall,rob.io.com_xcpt.valid && !rob.io.com_xcpt.bits.cause(xLen - 1) && (w == 0).B,(rob.io.com_xcpt.valid && rob.io.com_xcpt.bits.cause(xLen - 1)) && (w == 0).B,
          rob.io.com_xcpt.bits.cause,csr.io.tval,
          Sext(rob.io.commit.uops(w).debug_pc(vaddrBits-1,0), xLen),Mux(rob.io.commit.uops(w).is_rvc,rob.io.commit.uops(w).debug_inst(15,0),rob.io.commit.uops(w).debug_inst),
          rob.io.commit.uops(w).dst_rtype === RT_FIX&& rob.io.commit.uops(w).ldst =/= 0.U,rob.io.commit.uops(w).dst_rtype === RT_FLT,rob.io.commit.uops(w).ldst,rob.io.commit.debug_wdata(w)))
      }
    }
  }

  

  /* R Features */
  val rsu_master = Module(new R_RSU(R_RSUParams(xLen, numARFS, 1)))
  val ic_master = Module(new R_IC(R_ICParams(GH_GlobalParams.GH_NUM_CORES, 16)))
  val r_exception_record_2                         = RegInit(0.U(1.W))
  r_exception_record_2                            := Mux(csr.io.r_exception.asBool, 1.U, Mux(ic_incr =/= 0.U && r_exception_record_2.asBool, 0.U, r_exception_record_2))
  r_exception_record                              := Mux(csr.io.r_exception.asBool, 1.U, Mux(ic_incr =/= 0.U && r_exception_record.asBool && !r_exception_record_2.asBool, 0.U, r_exception_record))
  r_syscall                                       := Mux((ic_incr =/= 0.U) && (r_exception_record.asBool || csr.io.r_exception.asBool), true.B, false.B)
  
  ic_master.io.ic_run_isax                        := io.icctrl(0)
  ic_master.io.ic_exit_isax                       := io.icctrl(1)
  ic_master.io.ic_syscall                         := io.icctrl(2) | RegNext(r_syscall)
  ic_master.io.ic_syscall_back                    := (io.icctrl(3) | if_mret_or_sret.reduce(_||_)) && (csr.io.r_exception === 0.U)
  ic_master.io.if_ready_snap_shot                 := rob.io.can_commit_withoutGC.asUInt
  ic_master.io.rsu_busy                           := rsu_master.io.rsu_busy
  ic_master.io.ic_threshold                       := GH_GlobalParams.GH_TOTAL_INSTS.U
  ic_master.io.ic_incr                            := Mux(r_syscall, 0.U, ic_incr)
  ic_stall                                        := ic_master.io.if_pipeline_stall
  no_core_aval                                    := ic_master.io.debug_perf_nocore
  debug_ic_stall                                  := ic_master.io.if_pipeline_stall
  // io.big_checker_switch                           := ic_master.io.big_checker_switch
  // io.icsl_na_ack                                  := ic_master.io.icsl_na_ack
  val num_activated_cores                          = RegInit(0.U(8.W))
  num_activated_cores                             := io.num_of_checker
  ic_master.io.num_of_checker                     := io.num_of_checker
  ic_master.io.changing_num_of_checker            := Mux((num_activated_cores =/= io.num_of_checker), 1.U, 0.U)
  ic_master.io.core_trace                         := io.core_trace
  csr.io.core_trace                               := io.core_trace
  io.debug_maincore_status                        := ic_master.io.debug_maincore_status
  
  io.ic_crnt_target                               := ic_master.io.crnt_target
  for (i <-0 until GH_GlobalParams.GH_NUM_CORES){
    io.ic_counter(i)                              := ic_master.io.ic_counter(i)
    ic_master.io.clear_ic_status(i)               := io.clear_ic_status_tomain(i)
    ic_master.io.icsl_na(i)                       := io.icsl_na(i)
  }
  ic_master.io.if_correct_process                 := io.if_correct_process
  ic_master.io.ic_trace                           := io.ic_trace
  
  // ic_master.io.if_big_complete_req                := io.if_big_complete_req

  // revisit 
  val if_filtering                                 = ic_master.io.if_filtering // NOT USED YET!
  val snapshot_reg                                 = RegInit(0.U(1.W))
  snapshot_reg                                    := ic_master.io.if_dosnap
  
  for (i <- 0 until numARFS) {
    rsu_master.io.arfs_in(i)                      := arfs(i)
    rsu_master.io.farfs_in(i)                     := farfs(i)
  }
  rsu_master.io.pcarf_in                          := rob.io.r_next_pc
  rsu_master.io.fcsr_in                           := csr.io.fcsr_read
  rsu_master.io.snapshot                          := ic_master.io.if_dosnap
  csr.io.pfarf_valid                              := 0.U
  csr.io.fcsr_in                                  := 0.U
  csr.io.arfs_is_CPS                              := false.B
  csr.io.arfs_is_CSR                              := false.B
  csr.io.csr_shadows                              := 0.U
  csr.io.shadow_idx                               := 0.U
  csr.io.checker_mode                             := false.B
  rsu_master.io.shadowcsr_in                      := csr.io.shadow_read
  rsu_master.io.merge                             := snapshot_reg
  // rsu_master.io.ght_filters_ready                 := io.ght_filters_ready
  rsu_master.io.ic_crnt_target                    := ic_master.io.crnt_target
  rsu_master.io.ic_old_crnt_target                := ic_master.io.old_crnt_target
  rsu_master.io.core_trace                        := io.core_trace
  rsu_master.io.ic_trace                          := io.ic_trace 
  rsu_stall                                       := rsu_master.io.core_hang_up
  rsu_master.io.big_hang                          := io.big_hang
  io.arfs_ecp_dest                                := rsu_master.io.arfs_ecp_dest
  for (w <- 0 until 1){
    io.r_arfs(w)                                  := Cat(rsu_master.io.arfs_index(w), rsu_master.io.arfs_merge(w))
    io.r_arfs_pidx(w)                             := rsu_master.io.arfs_pidx(w)
  }
  io.rsu_merging                                  := rsu_master.io.rsu_merging
  io.rsu_merging_valid                            := rsu_master.io.rsu_merging_valid
  io.debug_perf_val                               := ic_master.io.debug_perf_val
  ic_master.io.debug_perf_sel                     := io.debug_perf_ctrl(3,1)
  ic_master.io.debug_perf_reset                   := io.debug_perf_ctrl(0)
  io.shared_CP_CFG                                := ic_master.io.shared_CP_CFG


  // io.commit_valids                                := rob.io.commit.arch_valids  
  io.commit_uops                                  := rob.io.commit.uops
  // io.if_big_complete_ack                           := ic_master.io.if_big_complete_ack
  //===== GuardianCouncil Function: End ====//
}
