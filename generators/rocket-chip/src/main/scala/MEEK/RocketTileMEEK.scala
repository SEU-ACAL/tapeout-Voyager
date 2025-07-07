// See LICENSE.SiFive for license details.
// See LICENSE.Berkeley for license details.

package freechips.rocketchip.meek

import chisel3._
import chisel3.util._
//===== GuardianCouncil Function: Start ====//
import freechips.rocketchip.guardiancouncil._
import chisel3.dontTouch
//===== GuardianCouncil Function: End   ====//
import org.chipsalliance.cde.config._
import org.chipsalliance.diplomacy.lazymodule._
import freechips.rocketchip.rocket._
import freechips.rocketchip.tile._
import freechips.rocketchip.devices.tilelink.{BasicBusBlockerParams, BasicBusBlocker}
import freechips.rocketchip.diplomacy.{
  AddressSet, DisableMonitors, BufferParams
}
import freechips.rocketchip.resources.{
  SimpleDevice, Description,
  ResourceAnchors, ResourceBindings, ResourceBinding, Resource, ResourceAddress,
}
import freechips.rocketchip.interrupts.IntIdentityNode
import freechips.rocketchip.tilelink.{TLIdentityNode, TLBuffer}
import freechips.rocketchip.rocket.{
  RocketCoreParams, ICacheParams, DCacheParams, BTBParams, HasHellaCache,
  HasICacheFrontend, ScratchpadSlavePort, HasICacheFrontendModule, Rocket
}
import freechips.rocketchip.subsystem.HierarchicalElementCrossingParamsLike
import freechips.rocketchip.prci.{ClockSinkParameters, RationalCrossing, ClockCrossingType}
import freechips.rocketchip.util.{Annotated, InOrderArbiter}

import freechips.rocketchip.util.BooleanToAugmentedBoolean

case class RocketTileBoundaryBufferParams(force: Boolean = false)

case class RocketTileMeekParams(
    core: RocketCoreParams = RocketCoreParams(),
    icache: Option[ICacheParams] = Some(ICacheParams()),
    dcache: Option[DCacheParams] = Some(DCacheParams()),
    btb: Option[BTBParams] = Some(BTBParams()),
    dataScratchpadBytes: Int = 0,
    tileId: Int = 0,
    beuAddr: Option[BigInt] = None,
    blockerCtrlAddr: Option[BigInt] = None,
    clockSinkParams: ClockSinkParameters = ClockSinkParameters(),
    boundaryBuffers: Option[RocketTileBoundaryBufferParams] = None
  ) extends InstantiableTileParams[RocketTileMeek] {
  require(icache.isDefined)
  require(dcache.isDefined)
  val baseName = "tile"
  val uniqueName = s"${baseName}_$tileId"
  def instantiate(crossing: HierarchicalElementCrossingParamsLike, lookup: LookupByHartIdImpl)(implicit p: Parameters): RocketTileMeek = {
    new RocketTileMeek(this, crossing, lookup)
  }
}

class RocketTileMeek private(
      val rocketParams: RocketTileMeekParams,
      crossing: ClockCrossingType,
      lookup: LookupByHartIdImpl,
      q: Parameters)
    extends BaseTile(rocketParams, crossing, lookup, q)
    with SinksExternalInterrupts
    with SourcesExternalNotifications
    with HasLazyRoCCMEEK  // implies CanHaveSharedFPU with CanHavePTW with HasHellaCache
    with HasHellaCache
    with HasICacheFrontend
{
  // Private constructor ensures altered LazyModule.p is used implicitly
  def this(params: RocketTileMeekParams, crossing: HierarchicalElementCrossingParamsLike, lookup: LookupByHartIdImpl)(implicit p: Parameters) =
    this(params, crossing.crossingType, lookup, p)

  val intOutwardNode = rocketParams.beuAddr map { _ => IntIdentityNode() }
  val slaveNode = TLIdentityNode()
  val masterNode = visibilityNode

  val dtim_adapter = tileParams.dcache.flatMap { d => d.scratch.map { s =>
    LazyModule(new ScratchpadSlavePort(AddressSet.misaligned(s, d.dataScratchpadBytes), lazyCoreParamsView.coreDataBytes, tileParams.core.useAtomics && !tileParams.core.useAtomicsOnlyForIO))
  }}
  dtim_adapter.foreach(lm => connectTLSlave(lm.node, lm.node.portParams.head.beatBytes))

  val bus_error_unit = rocketParams.beuAddr map { a =>
    val beu = LazyModule(new BusErrorUnit(new L1BusErrors, BusErrorUnitParams(a), xLen/8))
    intOutwardNode.get := beu.intNode
    connectTLSlave(beu.node, xBytes)
    beu
  }

  val tile_master_blocker =
    tileParams.blockerCtrlAddr
      .map(BasicBusBlockerParams(_, xBytes, masterPortBeatBytes, deadlock = true))
      .map(bp => LazyModule(new BasicBusBlocker(bp)))

  tile_master_blocker.foreach(lm => connectTLSlave(lm.controlNode, xBytes))

  // TODO: this doesn't block other masters, e.g. RoCCs
  tlOtherMastersNode := tile_master_blocker.map { _.node := tlMasterXbar.node } getOrElse { tlMasterXbar.node }
  masterNode :=* tlOtherMastersNode
  DisableMonitors { implicit p => tlSlaveXbar.node :*= slaveNode }

  nDCachePorts += 1 /*core */ + (dtim_adapter.isDefined).toInt + rocketParams.core.vector.map(_.useDCache.toInt).getOrElse(0)

  val dtimProperty = dtim_adapter.map(d => Map(
    "sifive,dtim" -> d.device.asProperty)).getOrElse(Nil)

  val itimProperty = frontend.icache.itimProperty.toSeq.flatMap(p => Map("sifive,itim" -> p))

  val beuProperty = bus_error_unit.map(d => Map(
          "sifive,buserror" -> d.device.asProperty)).getOrElse(Nil)

  val cpuDevice: SimpleDevice = new SimpleDevice("cpu", Seq("sifive,rocket0", "riscv")) {
    override def parent = Some(ResourceAnchors.cpus)
    override def describe(resources: ResourceBindings): Description = {
      val Description(name, mapping) = super.describe(resources)
      Description(name, mapping ++ cpuProperties ++ nextLevelCacheProperty
                  ++ tileProperties ++ dtimProperty ++ itimProperty ++ beuProperty)
    }
  }

  val vector_unit = rocketParams.core.vector.map(v => LazyModule(v.build(p)))
  vector_unit.foreach(vu => tlMasterXbar.node :=* vu.atlNode)
  vector_unit.foreach(vu => tlOtherMastersNode :=* vu.tlNode)


  ResourceBinding {
    Resource(cpuDevice, "reg").bind(ResourceAddress(tileId))
  }

  override lazy val module = new RocketTileMeekModuleImp(this)

  override def makeMasterBoundaryBuffers(crossing: ClockCrossingType)(implicit p: Parameters) = (rocketParams.boundaryBuffers, crossing) match {
    case (Some(RocketTileBoundaryBufferParams(true )), _)                   => TLBuffer()
    case (Some(RocketTileBoundaryBufferParams(false)), _: RationalCrossing) => TLBuffer(BufferParams.none, BufferParams.flow, BufferParams.none, BufferParams.flow, BufferParams(1))
    case _ => TLBuffer(BufferParams.none)
  }

  override def makeSlaveBoundaryBuffers(crossing: ClockCrossingType)(implicit p: Parameters) = (rocketParams.boundaryBuffers, crossing) match {
    case (Some(RocketTileBoundaryBufferParams(true )), _)                   => TLBuffer()
    case (Some(RocketTileBoundaryBufferParams(false)), _: RationalCrossing) => TLBuffer(BufferParams.flow, BufferParams.none, BufferParams.none, BufferParams.none, BufferParams.none)
    case _ => TLBuffer(BufferParams.none)
  }
}

class RocketTileMeekModuleImp(outer: RocketTileMeek) extends BaseTileModuleImp(outer)
    with HasFpuOpt
    with HasLazyRoCCMEEKModule
    with HasICacheFrontendModule {
  Annotated.params(this, outer.rocketParams)

  val core = Module(new RocketMEEK_kernel(outer)(outer.p))
  outer.vector_unit.foreach { v =>
    core.io.vector.get <> v.module.io.core
    v.module.io.tlb <> outer.dcache.module.io.tlb_port
  }

  //===== GuardianCouncil Function: Start ====//
  val ght_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val ghe_bridge = Module(new GH_Bridge(GH_BridgeParams(5)))
  val ght_cfg_bridge = Module(new GH_Bridge(GH_BridgeParams(32)))
  val ght_cfg_v_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val if_correct_process_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val record_pc_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val elu_deq_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))
  val elu_sel_bridge = Module(new GH_Bridge(GH_BridgeParams(1)))

  /* R Features */
  // A mini-decoder for packets
  val s_or_r = RegInit(0.U(1.W))

  val core_trace = WireInit(0.U(2.W))
  val debug_perf_ctrl = WireInit(0.U(5.W))
  val record_and_store = WireInit(0.U(2.W))
//make it generic
  
  //arfs 是固定的
  val arfs_in = outer.core_r_arfs_c_SKNode.map(_.bundle).getOrElse(0.U((2*GH_GlobalParams.GH_WIDITH_PERF+1).W))
  val arfs_index = arfs_in (143+1, 136+1)
  val ptype_rcu = Mux(s_or_r.asBool && ((arfs_index(2,0) === 7.U)), true.B, false.B)
  val arfs_if_CPS = Mux(ptype_rcu.asBool && (arfs_index (6, 3) === outer.rocketParams.tileId.U), 1.U, 0.U)
  val packet_rcu = Mux((ptype_rcu), arfs_in, 0.U)

  // val icsl_ack          = outer.icsl_ack_tocheckerSKNode.bundle
  // dontTouch(icsl_ack)//for debug
  // core.io.icsl_ack := icsl_ack
  core.io.cdc_empty    := outer.cdc_empty_tocheckerSKNode.map(_.bundle).getOrElse(0.U(1.W))
  // core.io.big_switch   := outer.big_switch_tocheckerSKNode.bundle
  val packet_in         = WireInit(0.U((2*GH_GlobalParams.GH_WIDITH_PACKETS+1).W))
  //极度旧的chisel写法
  val packet_vec        = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U((GH_GlobalParams.GH_WIDITH_PACKETS).W)))
  val packet_en         = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(false.B))
  val packet_index_vec  = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U(8.W)))
  val packet_vec_in     = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U((GH_GlobalParams.GH_WIDITH_PACKETS).W)))

  packet_in := outer.ghe_packet_in_SKNode.map(_.bundle).getOrElse(0.U((2*GH_GlobalParams.GH_WIDITH_PACKETS+1).W))
  // dontTouch(packet_in)
  // dontTouch(packet_en)
  // val ptype_fg = ((packet_index_vec(0)(2) === 0.U) && (packet_index_vec(0)(1,0) =/= 0.U) && (s_or_r === 0.U))
  // val ptype_lsl = (s_or_r.asBool && (packet_index_vec(0)(2,0) =/= 7.U) && (packet_index_vec(0)(2,0) =/= 0.U))




  for( i<- 0 until GH_GlobalParams.GH_TOTAL_PACKETS){
    packet_vec(i)       := packet_in(GH_GlobalParams.GH_WIDITH_PACKETS*(i+1)-1,i*GH_GlobalParams.GH_WIDITH_PACKETS)
    packet_index_vec(i) := packet_vec(i)(GH_GlobalParams.GH_WIDITH_PACKETS-1,GH_GlobalParams.GH_WIDITH_PACKETS-8)
    packet_en(i)        := s_or_r.asBool && (packet_index_vec(i)(2,0) =/= 7.U) && (packet_index_vec(i)(2,0) =/= 0.U)&&packet_index_vec(i)(6,3)===outer.rocketParams.tileId.U
    packet_vec_in(i)    := Mux(packet_en(i),packet_vec(i),0.U)
  }








  val arf_copy_bridge   = Module(new GH_Bridge(GH_BridgeParams(1)))
  outer.clock_SRNode.foreach{node=>
    node.bundle:=clock
  }  
  outer.reset_SRNode.foreach{node=>
    node.bundle:=reset
  }
 // Other cores:
  // For other cores: no GHT is required, and hence tied-off
  core.io.clk_enable_gh := 1.U // the core is never gated
  val zeros_4bits = WireInit(0.U(4.W))



  outer.ghe_event_out_SRNode.foreach{node=>
    node.bundle := Cat(0.U, (ghe_bridge.io.out | Cat(core.io.packet_cdc_ready, zeros_4bits) | Cat(zeros_4bits, core.io.lsl_near_full)))

  } 
  outer.ghe_revent_out_SRNode.foreach{node=>
    node.bundle:= core.io.lsl_highwatermark
  }
  core.io.arfs_if_CPS := arfs_if_CPS
  core.io.packet_arfs := packet_rcu
  core.io.packet_lsl := packet_vec_in
  core.io.arf_copy_in := arf_copy_bridge.io.out
  core.io.s_or_r := s_or_r
  core.io.if_correct_process := if_correct_process_bridge.io.out
  core.io.record_pc := record_pc_bridge.io.out
  core.io.elu_deq := elu_deq_bridge.io.out
  core.io.elu_sel := elu_sel_bridge.io.out
  core.io.ic_counter := outer.ic_counter_SKNode.map(_.bundle).getOrElse(0.U(20.W))
  outer.clear_ic_status_SRNode.foreach{node=>
    node.bundle := core.io.clear_ic_status
  }
  core.io.core_trace := core_trace(0)
  core.io.debug_perf_ctrl := debug_perf_ctrl
  core.io.record_and_store := record_and_store
  //===== GuardianCouncil Function: END ====//
  // reset vector is connected in the Frontend to s2_pc
  core.io.reset_vector := DontCare

  // Report unrecoverable error conditions; for now the only cause is cache ECC errors
  outer.reportHalt(List(outer.dcache.module.io.errors))

  // Report when the tile has ceased to retire instructions; for now the only cause is clock gating
  outer.reportCease(outer.rocketParams.core.clockGate.option(
    !outer.dcache.module.io.cpu.clock_enabled &&
    !outer.frontend.module.io.cpu.clock_enabled &&
    !ptw.io.dpath.clock_enabled &&
    core.io.cease))

  outer.reportWFI(Some(core.io.wfi))

  outer.decodeCoreInterrupts(core.io.interrupts) // Decode the interrupt vector

  outer.bus_error_unit.foreach { beu =>
    core.io.interrupts.buserror.get := beu.module.io.interrupt
    beu.module.io.errors.dcache := outer.dcache.module.io.errors
    beu.module.io.errors.icache := outer.frontend.module.io.errors
  }

  core.io.interrupts.nmi.foreach { nmi => nmi := outer.nmiSinkNode.get.bundle }

  // Pass through various external constants and reports that were bundle-bridged into the tile
  outer.traceSourceNode.bundle <> core.io.trace
  core.io.traceStall := outer.traceAuxSinkNode.bundle.stall
  outer.bpwatchSourceNode.bundle <> core.io.bpwatch
  core.io.hartid := outer.hartIdSinkNode.bundle
  require(core.io.hartid.getWidth >= outer.hartIdSinkNode.bundle.getWidth,
    s"core hartid wire (${core.io.hartid.getWidth}b) truncates external hartid wire (${outer.hartIdSinkNode.bundle.getWidth}b)")

  // Connect the core pipeline to other intra-tile modules
  outer.frontend.module.io.cpu <> core.io.imem
  dcachePorts += core.io.dmem // TODO outer.dcachePorts += () => module.core.io.dmem ??
  fpuOpt foreach { fpu =>
    core.io.fpu :<>= fpu.io.waiveAs[FPUCoreIOMEEK](_.cp_req, _.cp_resp)
  }
  if (fpuOpt.isEmpty) {
    core.io.fpu := DontCare
  }
  outer.vector_unit foreach { v => if (outer.rocketParams.core.vector.get.useDCache) {
    dcachePorts += v.module.io.dmem
  } else {
    v.module.io.dmem := DontCare
  } }
  core.io.ptw <> ptw.io.dpath

  // Connect the coprocessor interfaces
  if (outer.roccs.size > 0) {
    cmdRouter.get.io.in <> core.io.rocc.cmd
    outer.roccs.foreach{ lm =>
      lm.module.io.exception := core.io.rocc.exception
      lm.module.io.fpu_req.ready := DontCare
      lm.module.io.fpu_resp.valid := DontCare
      lm.module.io.fpu_resp.bits.data := DontCare
      lm.module.io.fpu_resp.bits.exc := DontCare
    }
    core.io.rocc.resp <> respArb.get.io.out
    core.io.rocc.busy <> (cmdRouter.get.io.busy || outer.roccs.map(_.module.io.busy).reduce(_ || _))
    core.io.rocc.interrupt := outer.roccs.map(_.module.io.interrupt).reduce(_ || _)
    (core.io.rocc.csrs zip roccCSRIOs.flatten).foreach { t => t._2 <> t._1 }
    //===== GuardianCouncil Function: Start ====//
    cmdRouter.get.io.ghe_packet_in := 0.U
    cmdRouter.get.io.ghe_status_in := outer.ghe_status_in_SKNode.map(_.bundle).getOrElse(0.U(32.W))
    ghe_bridge.io.in := cmdRouter.get.io.ghe_event_out
    ght_bridge.io.in := cmdRouter.get.io.ght_mask_out
    ght_cfg_bridge.io.in := cmdRouter.get.io.ght_cfg_out
    ght_cfg_v_bridge.io.in := cmdRouter.get.io.ght_cfg_valid
    outer.ght_status_out_SRNode.foreach{node=>
      node.bundle := cmdRouter.get.io.ght_status_out
    } 


    cmdRouter.get.io.agg_buffer_full := 0.U
    cmdRouter.get.io.ght_sch_refresh := 0.U
    cmdRouter.get.io.ght_buffer_status := 0.U
    // For big_core GHT
    cmdRouter.get.io.bigcore_comp := outer.bigcore_comp_in_SKNode.map(_.bundle).getOrElse(0.U(3.W))
    arf_copy_bridge.io.in := cmdRouter.get.io.arf_copy_out
    /* R Features */
    cmdRouter.get.io.rsu_status_in := core.io.rsu_status
    cmdRouter.get.io.elu_status_in := core.io.elu_status
    s_or_r := cmdRouter.get.io.s_or_r_out(0)
    core_trace := cmdRouter.get.io.core_trace_out
    debug_perf_ctrl := cmdRouter.get.io.debug_perf_ctrl_out
    record_and_store := cmdRouter.get.io.record_and_store_out
    cmdRouter.get.io.ght_satp_ppn := core.io.ptw.ptbr.ppn
    cmdRouter.get.io.ght_sys_mode := core.io.ght_prv
    if_correct_process_bridge.io.in := cmdRouter.get.io.if_correct_process_out
    record_pc_bridge.io.in := cmdRouter.get.io.record_pc_out
    cmdRouter.get.io.elu_data_in := core.io.elu_data
    elu_deq_bridge.io.in := cmdRouter.get.io.elu_deq_out
    elu_sel_bridge.io.in := cmdRouter.get.io.elu_sel_out
    //===== GuardianCouncil Function: End   ====//
  } else {
    // tie off
    core.io.rocc.cmd.ready := false.B
    core.io.rocc.resp.valid := false.B
    core.io.rocc.resp.bits := DontCare
    core.io.rocc.busy := DontCare
    core.io.rocc.interrupt := DontCare
  }
  // Dont care mem since not all RoCC need accessing memory
  core.io.rocc.mem := DontCare

  // Rocket has higher priority to DTIM than other TileLink clients
  outer.dtim_adapter.foreach { lm => dcachePorts += lm.module.io.dmem }

  // TODO eliminate this redundancy
  val h = dcachePorts.size
  val c = core.dcacheArbPorts
  println(s"dcachePorts: $h ")
  val o = outer.nDCachePorts
  require(h == c, s"port list size was $h, core expected $c")
  require(h == o, s"port list size was $h, outer counted $o")
  // TODO figure out how to move the below into their respective mix-ins
  dcacheArb.io.requestor <> dcachePorts.toSeq
  ptw.io.requestor <> ptwPorts.toSeq
}

trait HasFpuOpt { this: RocketTileMeekModuleImp =>
  val fpuOpt = outer.tileParams.core.fpu.map(params => Module(new FPUMEEK(params)(outer.p)))
  fpuOpt.foreach { fpu =>
    val nRoCCFPUPorts = outer.roccs.count(_.usesFPU)
    val nFPUPorts = nRoCCFPUPorts + outer.rocketParams.core.useVector.toInt
    if (nFPUPorts > 0) {
      val fpArb = Module(new InOrderArbiter(new FPInput()(outer.p), new FPResult()(outer.p), nFPUPorts))
      fpu.io.cp_req <> fpArb.io.out_req
      fpArb.io.out_resp <> fpu.io.cp_resp

      val fp_rocc_ios = outer.roccs.filter(_.usesFPU).map(_.module.io)
      for (i <- 0 until nRoCCFPUPorts) {
        fpArb.io.in_req(i) <> fp_rocc_ios(i).fpu_req
        fp_rocc_ios(i).fpu_resp <> fpArb.io.in_resp(i)
      }
      outer.vector_unit.foreach(vu => {
        fpArb.io.in_req(nRoCCFPUPorts) <> vu.module.io.fp_req
        vu.module.io.fp_resp <> fpArb.io.in_resp(nRoCCFPUPorts)
      })
    } else {
      fpu.io.cp_req.valid := false.B
      fpu.io.cp_req.bits := DontCare
      fpu.io.cp_resp.ready := false.B
    }
  }
}
