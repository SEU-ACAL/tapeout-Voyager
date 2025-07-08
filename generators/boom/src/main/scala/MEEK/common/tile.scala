//******************************************************************************
// Copyright (c) 2017 - 2018, The Regents of the University of California (Regents).
// All Rights Reserved. See LICENSE and LICENSE.SiFive for license details.
//------------------------------------------------------------------------------

package boom.meek.common

import chisel3._
import chisel3.util._

import scala.collection.mutable.{ListBuffer}

import org.chipsalliance.cde.config._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.prci._
import freechips.rocketchip.rocket._
import freechips.rocketchip.subsystem.{RocketCrossingParams}
import freechips.rocketchip.tilelink._
import freechips.rocketchip.interrupts._
import freechips.rocketchip.util._
import freechips.rocketchip.tile._
import freechips.rocketchip.meek._
//===== GuardianCouncil Function: Start ====//
import freechips.rocketchip.guardiancouncil._
//===== GuardianCouncil Function: End   ====//
import boom.meek.exu._
import boom.meek.ifu._
import boom.meek.lsu._
import boom.meek.trans._
import boom.meek.util.{BoomCoreStringPrefix}
import freechips.rocketchip.prci.ClockSinkParameters


case class BoomTileAttachParams(
  tileParams: BoomTileParams,
  crossingParams: RocketCrossingParams
) extends CanAttachTile {
  type TileType = BoomTile
  val lookup = PriorityMuxHartIdFromSeq(Seq(tileParams))
}


/**
 * BOOM tile parameter class used in configurations
 *
 */
case class BoomTileParams(
  core: BoomCoreParams = BoomCoreParams(),
  icache: Option[ICacheParams] = Some(ICacheParams()),
  dcache: Option[DCacheParams] = Some(DCacheParams()),
  btb: Option[BTBParams] = Some(BTBParams()),
  name: Option[String] = Some("boom_tile"),
  tileId: Int = 0
) extends InstantiableTileParams[BoomTile]
{
  require(icache.isDefined)
  require(dcache.isDefined)
  def instantiate(crossing: HierarchicalElementCrossingParamsLike, lookup: LookupByHartIdImpl)(implicit p: Parameters): BoomTile = {
    new BoomTile(this, crossing, lookup)
  }
  val beuAddr: Option[BigInt] = None
  val blockerCtrlAddr: Option[BigInt] = None
  val boundaryBuffers: Boolean = false // if synthesized with hierarchical PnR, cut feed-throughs?
  val clockSinkParams: ClockSinkParameters = ClockSinkParameters()
  val baseName = name.getOrElse("boom_tile")
  val uniqueName = s"${baseName}_$tileId"
}

/**
 * BOOM tile
 *
 */
class BoomTile private(
  val boomParams: BoomTileParams,
  crossing: ClockCrossingType,
  lookup: LookupByHartIdImpl,
  q: Parameters)
  extends BaseTile(boomParams, crossing, lookup, q)
  with SinksExternalInterrupts
  with SourcesExternalNotifications
{

  // Private constructor ensures altered LazyModule.p is used implicitly
  def this(params: BoomTileParams, crossing: HierarchicalElementCrossingParamsLike, lookup: LookupByHartIdImpl)(implicit p: Parameters) =
    this(params, crossing.crossingType, lookup, p)

  val intOutwardNode = None
  val masterNode = TLIdentityNode()
  val slaveNode = TLIdentityNode()

  val tile_master_blocker =
    tileParams.blockerCtrlAddr
      .map(BasicBusBlockerParams(_, xBytes, masterPortBeatBytes, deadlock = true))
      .map(bp => LazyModule(new BasicBusBlocker(bp)))

  tile_master_blocker.foreach(lm => connectTLSlave(lm.controlNode, xBytes))

  // TODO: this doesn't block other masters, e.g. RoCCs
  tlOtherMastersNode := tile_master_blocker.map { _.node := tlMasterXbar.node } getOrElse { tlMasterXbar.node }
  masterNode :=* tlOtherMastersNode

  val cpuDevice: SimpleDevice = new SimpleDevice("cpu", Seq("ucb-bar,boom0", "riscv")) {
    override def parent = Some(ResourceAnchors.cpus)
    override def describe(resources: ResourceBindings): Description = {
      val Description(name, mapping) = super.describe(resources)
      Description(name, mapping ++
                        cpuProperties ++
                        nextLevelCacheProperty ++
                        tileProperties)
    }
  }

  ResourceBinding {
    Resource(cpuDevice, "reg").bind(ResourceAddress(tileId))
  }

  override def makeMasterBoundaryBuffers(crossing: ClockCrossingType)(implicit p: Parameters) = crossing match {
    case _: RationalCrossing =>
      if (!boomParams.boundaryBuffers) TLBuffer(BufferParams.none)
      else TLBuffer(BufferParams.none, BufferParams.flow, BufferParams.none, BufferParams.flow, BufferParams(1))
    case _ => TLBuffer(BufferParams.none)
  }

  override def makeSlaveBoundaryBuffers(crossing: ClockCrossingType)(implicit p: Parameters) = crossing match {
    case _: RationalCrossing =>
      if (!boomParams.boundaryBuffers) TLBuffer(BufferParams.none)
      else TLBuffer(BufferParams.flow, BufferParams.none, BufferParams.none, BufferParams.none, BufferParams.none)
    case _ => TLBuffer(BufferParams.none)
  }

  override lazy val module = new BoomTileModuleImp(this)

  // DCache
  lazy val dcache: BoomNonBlockingDCache = LazyModule(new BoomNonBlockingDCache(tileId))
  val dCacheTap = TLIdentityNode()
  tlMasterXbar.node := dCacheTap := TLWidthWidget(tileParams.dcache.get.rowBits/8) := visibilityNode := dcache.node


  // Frontend/ICache
  val frontend = LazyModule(new BoomFrontend(tileParams.icache.get, tileId))
  frontend.resetVectorSinkNode := resetVectorNexusNode
  tlMasterXbar.node := TLWidthWidget(tileParams.icache.get.rowBits/8) := frontend.masterNode

  require(tileParams.dcache.get.rowBits == tileParams.icache.get.rowBits)

  // ROCC
  val roccs = p(BuildRoCCMEEK).map(_(p))
  roccs.map(_.atlNode).foreach { atl => tlMasterXbar.node :=* atl }
  roccs.map(_.tlNode).foreach { tl => tlOtherMastersNode :=* tl }
}

/**
 * BOOM tile implementation
 *
 * @param outer top level BOOM tile
 */
class BoomTileModuleImp(outer: BoomTile) extends BaseTileModuleImp(outer){

  Annotated.params(this, outer.boomParams)

  val core = Module(new BoomCoreKernel()(outer.p))
  val lsu  = Module(new LSU()(outer.p, outer.dcache.module.edge))

  //===== GuardianCouncil Function: Start ====//
  val ght_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val ghe_bridge = Module(new GH_Bridge(GH_BridgeParams(3)))
  val ght_cfg_bridge = Module(new GH_Bridge(GH_BridgeParams(32)))
  val ght_cfg_v_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val ght_buffer_status_bridge = Module(new GH_Bridge(GH_BridgeParams(2)))
  val if_correct_process_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val if_ght_filters_empty_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val debug_mcounter_bridge = Module(new GH_Bridge(GH_BridgeParams(64)))
  val debug_icounter_bridge = Module(new GH_Bridge(GH_BridgeParams(64)))
  val debug_bp_checker_bridge = Module(new GH_Bridge(GH_BridgeParams(64)))
  val debug_bp_cdc_bridge = Module(new GH_Bridge(GH_BridgeParams(64)))
  val debug_bp_filter_bridge = Module(new GH_Bridge(GH_BridgeParams(64)))
  val debug_bp_reset_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val debug_gtimer_reset_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val number_checkers_bridge = Module(new GH_Bridge(GH_BridgeParams(8)))
  
  /* R Features */
  val icctrl_bridge = Module(new GH_Bridge(GH_BridgeParams(4)))
  val t_value_bridge = Module(new GH_Bridge(GH_BridgeParams(15)))
  val s_or_r = Reg(UInt(1.W))
  val core_trace = Wire(UInt(2.W))
  val fi_sel = Wire(UInt(8.W))
  // val fi_latency = Wire(UInt(57.W))
  val debug_perf_sel = Wire(UInt(4.W))

  val debug_gtimer_reset = Reg(UInt(1.W))
  val debug_gtimer = Reg(UInt(62.W))
  val debug_gtimer_tiny = Reg(UInt(4.W))
  debug_gtimer_reset := debug_gtimer_reset_bridge.io.out
  debug_gtimer_reset := debug_gtimer_reset_bridge.io.out

  debug_gtimer_tiny := Mux(debug_gtimer_reset.asBool, 0.U, Mux((s_or_r === 1.U), Mux(debug_gtimer_tiny === 3.U, 0.U, debug_gtimer_tiny + 1.U), 0.U))
  debug_gtimer := Mux(debug_gtimer_reset.asBool, 0.U, Mux((s_or_r === 1.U), Mux(debug_gtimer_tiny === 3.U, debug_gtimer + 1.U, debug_gtimer), 0.U))
  val gc_core_width                               = outer.boomParams.core.decodeWidth
  outer.clock_SRNode.foreach{node=>
    node.bundle := clock
  } 
  outer.reset_SRNode.foreach{node=>
    node.bundle := reset
  } 
  if (outer.tileParams.tileId == 0) {
    println("#### Jessica #### Generating GH BUF for the big core, HartID: ", outer.boomParams.tileId, "...!!!")
   

    val gh_buf = Module(new GH_BUF(GH_BUF_Params((outer.tileParams.core.xLen),GH_GlobalParams.GH_WIDITH_PACKETS,gc_core_width, true)))
    // val fiu = Module(new R_FIU(R_FIUParams(64, GH_GlobalParams.GH_NUM_CORES-1)))
    // fiu.io.gtimer                                := debug_gtimer

    // for (i <- 0 until GH_GlobalParams.GH_NUM_CORES-1){
    //   fiu.io.fi_d(i)                             := outer.report_fi_detection_in_SKNode.bundle(i*57+56, i*57)
    // }
    // fiu.io.sel                                   := fi_sel
    // fi_latency                                   := fiu.io.fi_rslt


    outer.ght_packet_out_SRNode.foreach{node=>
    node.bundle := gh_buf.io.packet_out
    }          
    outer.ght_packet_dest_SRNode.foreach{node=>
    node.bundle :=Mux(gh_buf.io.gh_packet_dest=/=0.U,(gh_buf.io.gh_packet_dest),0.U)//送入ghm
    }                  
    core.io.gh_stall                             := gh_buf.io.core_hang_up
    if_ght_filters_empty_bridge.io.in            := gh_buf.io.ght_filters_empty
    outer.ghe_event_out_SRNode.foreach{node=>
      node.bundle := ghe_bridge.io.out
    }          
    core.io.clear_ic_status_tomain               := outer.clear_ic_status_tomainSKNode.map(_.bundle).getOrElse(0.U)
    core.io.icsl_na                              := outer.icsl_naSKNode.map(_.bundle).getOrElse(0.U)

    


    // outer.ghm_agg_core_id_out_SRNode.bundle      := 0.U
    core.io.bigComp := 0.U
    // Revisit: make below generic, as it is a verilog style
    val ldq_header                                = Wire(Vec(gc_core_width, UInt((2*outer.tileParams.core.xLen).W)))
    val stq_header                                = Wire(Vec(gc_core_width, UInt((2*outer.tileParams.core.xLen).W)))

    val use_ldq                                   = RegNext(VecInit.fill(gc_core_width)(false.B))
    val use_stq                                   = RegNext(VecInit.fill(gc_core_width)(false.B))
    
    for(i <- 0 until gc_core_width ){
      use_ldq(i) := core.io.commit_uops(i).uses_ldq&core.io.commit_valids(i)
      use_stq(i) := core.io.commit_uops(i).uses_stq&core.io.commit_valids(i)
    }
    //这里问题就是写一个输入不定n个输出的结构,每个端口都是一个n位的选择器,类似的写法还会在超标量的ibuf,issue出现,
    val ldq_forward_idxs   = VecInit.tabulate(gc_core_width)(i => PopCount(use_ldq.take(i)))
    // val ldq_forward_offset = VecInit(enq_idxs.map(_+enq_ptr(iqSz-1,0)))

    (0 until gc_core_width).map{idx=>
      val ldq_fwd_OH    = (0 until gc_core_width).map(i => (ldq_forward_idxs(idx) === i.U)&(use_ldq(idx)))
      val ldq_head_data = Mux1H(ldq_fwd_OH, lsu.io.ldq_head) 
      assert(PopCount(ldq_fwd_OH) <= 1.U, "Multiple forwarders for the same ldq entry")
      ldq_header(idx) := Mux(ldq_fwd_OH.reduce(_|_), ldq_head_data, 0.U)
    }

    
    val stq_forward_idxs   = VecInit.tabulate(gc_core_width)(i => PopCount(use_stq.take(i)))
    // val ldq_forward_offset = VecInit(enq_idxs.map(_+enq_ptr(iqSz-1,0)))

    (0 until gc_core_width).map{idx=>
      val stq_fwd_OH    = (0 until gc_core_width).map(i => (stq_forward_idxs(idx) === i.U)&(use_stq(idx)))
      val stq_head_data = Mux1H(stq_fwd_OH, lsu.io.stq_head) 
      assert(PopCount(stq_fwd_OH) <= 1.U, "Multiple forwarders for the same stq entry")
      stq_header(idx) := Mux(stq_fwd_OH.reduce(_|_), stq_head_data, 0.U)
    }



    val zeros_72bits                              = WireInit(0.U(72.W))
    val zeros_8bits                               = WireInit(0.U(8.W))
    lsu.io.core_trace                            := core_trace(0)


    for (w <- 0 until gc_core_width) {
      gh_buf.io.commit_uops(w)                   := RegNext(core.io.commit_uops(w))
      gh_buf.io.commit_valids(w)                 := RegNext(core.io.commit_valids(w))
      gh_buf.io.alu_in(w)                        := MuxCase(0.U, 
                                                      Array((gh_buf.io.commit_uops(w).uses_ldq === true.B) -> Cat(zeros_8bits, ldq_header(w)),
                                                            (gh_buf.io.commit_uops(w).uses_stq === true.B) -> Cat(zeros_8bits, stq_header(w))
                                                          )
                                                            )
      // gh_buf.io.gh_csr_addr_in(w)                := core.io.csr_addr(w)
      gh_buf.io.gh_prfs_rd(w)                    := RegNext(core.io.prf_rd(w))
    }
    gh_buf.io.gh_can_fwd                           := (ght_bridge.io.out | (!if_correct_process_bridge.io.out))
    gh_buf.io.cdc_not_ready                      := outer.bigcore_hang_in_SKNode.map(_.bundle).getOrElse(false.B)
    gh_buf.io.ic_crnt_target                     := RegNext(core.io.ic_crnt_target)
    
                        
    core.io.big_hang                             := false.B

    ght_buffer_status_bridge.io.in               := gh_buf.io.ght_buffer_status
    debug_mcounter_bridge.io.in                  := 0.U
    debug_icounter_bridge.io.in                  := 0.U
    debug_bp_checker_bridge.io.in                := 0.U
    debug_bp_cdc_bridge.io.in                    := 0.U
    debug_bp_filter_bridge.io.in                 := 0.U

    /* R Features */
    core.io.icctrl                               := icctrl_bridge.io.out
    core.io.t_value                              := t_value_bridge.io.out

    core.io.if_correct_process                   := if_correct_process_bridge.io.out

    outer.core_r_arfs_SRNode.foreach{node=>
      node.bundle := Cat(core.io.arfs_ecp_dest,core.io.r_arfs_pidx(0), core.io.r_arfs(0))
    }
    val ic_counter_superset                       = WireInit(0.U((16*GH_GlobalParams.GH_NUM_CORES).W))
    ic_counter_superset                          := core.io.ic_counter.reverse.reduce(Cat(_,_))
    outer.ic_counter_SRNode.foreach{node=>
      node.bundle := ic_counter_superset
    }
    core.io.num_of_checker                       := number_checkers_bridge.io.out
    core.io.debug_perf_ctrl                      := debug_perf_sel
    outer.debug_maincore_status_SRNode.foreach{node=>
      node.bundle := core.io.debug_maincore_status
    } 
  } else { 
    // Not be used, added to pass the compile
    core.io.gh_stall                             := 0.U
    core.io.icctrl                               := 0.U
    core.io.t_value                              := 0.U
  }
//===== GuardianCouncil Function: End   ====//
  val ptwPorts         = ListBuffer(lsu.io.ptw, outer.frontend.module.io.ptw, core.io.ptw_tlb)

  val hellaCachePorts  = ListBuffer[HellaCacheIO]()

  outer.reportWFI(None) // TODO: actually report this?

  outer.decodeCoreInterrupts(core.io.interrupts) // Decode the interrupt vector

  // Pass through various external constants and reports
  outer.traceSourceNode.bundle <> core.io.trace
  outer.bpwatchSourceNode.bundle <> DontCare // core.io.bpwatch
  core.io.hartid := outer.hartIdSinkNode.bundle

  // Connect the core pipeline to other intra-tile modules
  outer.frontend.module.io.cpu <> core.io.ifu
  core.io.lsu <> lsu.io.core



  core.io.core_trace := core_trace(0)
  core.io.ic_trace := core_trace(1)
  
  //fpuOpt foreach { fpu => core.io.fpu <> fpu.io } RocketFpu - not needed in boom
  core.io.rocc := DontCare

  // RoCC
  if (outer.roccs.size > 0) {
    val (respArb, cmdRouter) = {
      val respArb = Module(new RRArbiter(new RoCCResponse()(outer.p), outer.roccs.size))
      val cmdRouter = Module(new RoccCommandRouterBoom(outer.roccs.map(_.opcodes))(outer.p))
      outer.roccs.zipWithIndex.foreach { case (rocc, i) =>
        ptwPorts ++= rocc.module.io.ptw
        rocc.module.io.cmd <> cmdRouter.io.out(i)
        val dcIF = Module(new SimpleHellaCacheIF()(outer.p))
        dcIF.io.requestor <> rocc.module.io.mem
        hellaCachePorts += dcIF.io.cache
        respArb.io.in(i) <> Queue(rocc.module.io.resp)
        //===== GuardianCouncil Function: Start ====//
        rocc.module.io.elu_status_in               := 0.U
        rocc.module.io.csr_counter_in                := cmdRouter.io.csr_counter_out
        rocc.module.io.ghe_packet_in                 := cmdRouter.io.ghe_packet_in
        rocc.module.io.ghe_status_in                 := cmdRouter.io.ghe_status_in
        rocc.module.io.bigcore_comp                  := cmdRouter.io.bigcore_comp
        cmdRouter.io.ght_mask_in                     := rocc.module.io.ght_mask_out
        cmdRouter.io.ght_status_in                   := rocc.module.io.ght_status_out
        cmdRouter.io.ghe_event_in                    := rocc.module.io.ghe_event_out
        cmdRouter.io.ght_cfg_in                      := rocc.module.io.ght_cfg_out
        cmdRouter.io.ght_cfg_valid_in                := rocc.module.io.ght_cfg_valid
        cmdRouter.io.debug_bp_reset_in               := rocc.module.io.debug_bp_reset

        cmdRouter.io.agg_packet_in                   := rocc.module.io.agg_packet_out
        rocc.module.io.agg_buffer_full               := cmdRouter.io.agg_buffer_full
        cmdRouter.io.agg_core_status_in              := rocc.module.io.agg_core_status
        cmdRouter.io.ght_sch_na_in                   := rocc.module.io.ght_sch_na
        rocc.module.io.ght_sch_refresh               := cmdRouter.io.ght_sch_refresh
        cmdRouter.io.ght_sch_dorefresh_in            := rocc.module.io.ght_sch_dorefresh
        rocc.module.io.ght_buffer_status             := cmdRouter.io.ght_buffer_status

        rocc.module.io.ght_satp_ppn                  := cmdRouter.io.ght_satp_ppn
        rocc.module.io.ght_sys_mode                  := cmdRouter.io.ght_sys_mode
        cmdRouter.io.if_correct_process_in           := rocc.module.io.if_correct_process

        rocc.module.io.debug_mcounter                := cmdRouter.io.debug_mcounter
        rocc.module.io.debug_icounter                := cmdRouter.io.debug_icounter
        rocc.module.io.debug_gcounter                := cmdRouter.io.debug_gcounter
        
        rocc.module.io.debug_bp_checker              := cmdRouter.io.debug_bp_checker
        // rocc.module.io.fi_latency                    := cmdRouter.io.fi_latency
        rocc.module.io.debug_bp_cdc                  := cmdRouter.io.debug_bp_cdc
        rocc.module.io.debug_bp_filter               := cmdRouter.io.debug_bp_filter

        /* R Features */
        cmdRouter.io.icctrl_in                       := rocc.module.io.icctrl_out
        cmdRouter.io.t_value_in                      := rocc.module.io.t_value_out
        cmdRouter.io.s_or_r_in                       := rocc.module.io.s_or_r_out
        cmdRouter.io.arf_copy_in                     := rocc.module.io.arf_copy_out
        rocc.module.io.rsu_status_in                 := cmdRouter.io.rsu_status_in
        cmdRouter.io.gtimer_reset_in                 := rocc.module.io.gtimer_reset_out
        cmdRouter.io.fi_sel_in                       := rocc.module.io.fi_sel_out 
        cmdRouter.io.core_trace_in                   := rocc.module.io.core_trace_out
        rocc.module.io.elu_data_in                   := cmdRouter.io.elu_data_in
        cmdRouter.io.debug_perf_ctrl_in              := rocc.module.io.debug_perf_ctrl        
        //===== GuardianCouncil Function: End   ====//
      }
      // first keep fpu ios unconnected
      val fp_ios = outer.roccs.map(r => {
        val roccio = r.module.io
        roccio.fpu_req.ready := true.B
        roccio.fpu_resp.valid := false.B
        roccio.fpu_resp.bits := DontCare
      })
      // Create this FPU just for RoCC
      val nFPUPorts = outer.roccs.filter(_.usesFPU).size
      if (nFPUPorts > 0) {
        val fpuOpt = outer.tileParams.core.fpu.map(params => Module(new freechips.rocketchip.tile.FPU(params)(outer.p)))
        // TODO: Check this FPU works properly
        fpuOpt foreach { fpu =>
          // This FPU does not get CPU requests
          fpu.io := DontCare
          fpu.io.fcsr_rm := core.io.fcsr_rm
          fpu.io.ll_resp_val := false.B
          fpu.io.valid := false.B
          fpu.io.killx := false.B
          fpu.io.killm := false.B

          val fpArb = Module(new InOrderArbiter(new FPInput()(outer.p), new FPResult()(outer.p), nFPUPorts))
          val fp_rocc_ios = outer.roccs.filter(_.usesFPU).map(_.module.io)
          fpArb.io.in_req <> fp_rocc_ios.map(_.fpu_req)
          fp_rocc_ios.zip(fpArb.io.in_resp).foreach {
            case (rocc, arb) => rocc.fpu_resp <> arb
          }
          fpu.io.cp_req <> fpArb.io.out_req
          fpArb.io.out_resp <> fpu.io.cp_resp
        }
      }
      (respArb, cmdRouter)
    
    }

    cmdRouter.io.in <> core.io.rocc.cmd
    outer.roccs.foreach(_.module.io.exception := core.io.rocc.exception)
    core.io.rocc.resp <> respArb.io.out
    core.io.rocc.busy <> (cmdRouter.io.busy || outer.roccs.map(_.module.io.busy).reduce(_||_))
    core.io.rocc.interrupt := outer.roccs.map(_.module.io.interrupt).reduce(_||_)
    //===== GuardianCouncil Function: Start ====//
    cmdRouter.io.ghe_packet_in                   := outer.ghe_packet_in_SKNode.map(_.bundle).getOrElse(0.U) // Revisit: current agg packet and filtered packets are using the same channel
    cmdRouter.io.ghe_status_in                   := outer.ghe_status_in_SKNode.map(_.bundle).getOrElse(0.U)
    ghe_bridge.io.in                             := cmdRouter.io.ghe_event_out
    ght_bridge.io.in                             := cmdRouter.io.ght_mask_out
    debug_gtimer_reset_bridge.io.in              := cmdRouter.io.gtimer_reset_out
    ght_cfg_bridge.io.in                         := cmdRouter.io.ght_cfg_out
    ght_cfg_v_bridge.io.in                       := cmdRouter.io.ght_cfg_valid
    debug_bp_reset_bridge.io.in                  := cmdRouter.io.debug_bp_reset
    //for cdc 
    val cdc_cnt = RegInit(0.U(2.W))
    cdc_cnt := cdc_cnt+1.U

    
    outer.ght_status_out_SRNode.foreach{node=>
      node.bundle := Mux(cdc_cnt===3.U,Cat(if_ght_filters_empty_bridge.io.out, cmdRouter.io.ght_status_out(30,0)),0.U)
    }         
    number_checkers_bridge.io.in                 := cmdRouter.io.ght_status_out(30,23)

    // agg
    // outer.agg_packet_out_SRNode.bundle           := cmdRouter.io.agg_packet_out
    cmdRouter.io.agg_buffer_full                 := 0.U
    // outer.agg_core_status_SRNode.bundle          := cmdRouter.io.agg_core_status_out
    // outer.ght_sch_na_out_SRNode.bundle           := cmdRouter.io.ght_sch_na_out
    cmdRouter.io.ght_sch_refresh                 := 0.U
    // For big_core GHT
    cmdRouter.io.bigcore_comp                    := outer.bigcore_comp_in_SKNode.map(_.bundle).getOrElse(0.U)
    // outer.ght_sch_dorefresh_SRNode.bundle        := cmdRouter.io.ght_sch_dorefresh_out    
    cmdRouter.io.ght_buffer_status               := ght_buffer_status_bridge.io.out
    
    cmdRouter.io.ght_satp_ppn                    := core.io.ptw.ptbr.ppn
    cmdRouter.io.ght_sys_mode                    := core.io.ght_prv
    cmdRouter.io.csr_counter_in                  := core.io.csr_counter
    if_correct_process_bridge.io.in              := cmdRouter.io.if_correct_process_out

    cmdRouter.io.debug_mcounter                  := debug_mcounter_bridge.io.out
    cmdRouter.io.debug_icounter                  := debug_icounter_bridge.io.out
    cmdRouter.io.debug_bp_checker                := debug_bp_checker_bridge.io.out
    // cmdRouter.io.fi_latency                      := fi_latency
    cmdRouter.io.debug_bp_cdc                    := debug_bp_cdc_bridge.io.out
    cmdRouter.io.debug_bp_filter                 := debug_bp_filter_bridge.io.out
    cmdRouter.io.debug_gcounter                  := outer.debug_gcounter_SKNode.map(_.bundle).getOrElse(0.U)

    /* R Features */
    icctrl_bridge.io.in                          := cmdRouter.io.icctrl_out
    t_value_bridge.io.in                         := cmdRouter.io.t_value_out
    cmdRouter.io.rsu_status_in                   := 0.U
    s_or_r                                       := cmdRouter.io.s_or_r_out(1)
    fi_sel                                       := cmdRouter.io.fi_sel_out
    core_trace                                   := cmdRouter.io.core_trace_out
    cmdRouter.io.elu_data_in                     := core.io.debug_perf_val
    debug_perf_sel                               := cmdRouter.io.debug_perf_ctrl_out
    //===== GuardianCouncil Function: End   ====//
  }

  // PTW
  val ptw  = Module(new PTW(ptwPorts.length)(outer.dcache.node.edges.out(0), outer.p))
  core.io.ptw <> ptw.io.dpath
  ptw.io.requestor <> ptwPorts.toSeq
  ptw.io.mem +=: hellaCachePorts

   // LSU IO
  val hellaCacheArb = Module(new HellaCacheArbiter(hellaCachePorts.length)(outer.p))
  hellaCacheArb.io.requestor <> hellaCachePorts.toSeq
  lsu.io.hellacache <> hellaCacheArb.io.mem
  outer.dcache.module.io.lsu <> lsu.io.dmem

  // Generate a descriptive string
  val frontendStr = outer.frontend.module.toString
  val coreStr = core.toString
  val boomTileStr =
    (BoomCoreStringPrefix(s"======BOOM Tile ${outer.tileId} Params======") + "\n"
    + frontendStr
    + coreStr + "\n")

  override def toString: String = boomTileStr

  print(boomTileStr)
}
