// See LICENSE.SiFive for license details.

package freechips.rocketchip.subsystem

import chisel3._

import org.chipsalliance.cde.config._
import org.chipsalliance.diplomacy.bundlebridge._
import org.chipsalliance.diplomacy.lazymodule._

import freechips.rocketchip.devices.debug.TLDebugModule
import freechips.rocketchip.diplomacy.{DisableMonitors, FlipRendering}
import freechips.rocketchip.interrupts.{IntXbar, IntSinkNode, IntSinkPortSimple, IntSyncAsyncCrossingSink}
import freechips.rocketchip.tile.{MaxHartIdBits, BaseTile, InstantiableTileParams, TileParams, TilePRCIDomain, TraceBundle, PriorityMuxHartIdFromSeq}
import freechips.rocketchip.tilelink.TLWidthWidget
import freechips.rocketchip.prci.{ClockGroup, BundleBridgeBlockDuringReset, NoCrossing, SynchronousCrossing, CreditedCrossing, RationalCrossing, AsynchronousCrossing}
import freechips.rocketchip.rocket.TracedInstruction
import freechips.rocketchip.util.TraceCoreInterface

import scala.collection.immutable.SortedMap
//===== GuardianCouncil Function: Start ====//
import freechips.rocketchip.tile.EnableGuardianCouncilNodes
import freechips.rocketchip.guardiancouncil._
//===== GuardianCouncil Function: End   ====//
/** Entry point for Config-uring the presence of Tiles */
case class TilesLocated(loc: HierarchicalLocation) extends Field[Seq[CanAttachTile]](Nil)

/** List of HierarchicalLocations which might contain a Tile */
case object PossibleTileLocations extends Field[Seq[HierarchicalLocation]](Nil)

/** For determining static tile id */
case object NumTiles extends Field[Int](0)

/** Whether to add timing-closure registers along the path of the hart id
  * as it propagates through the subsystem and into the tile.
  *
  * These are typically only desirable when a dynamically programmable prefix is being combined
  * with the static hart id via [[freechips.rocketchip.subsystem.HasTiles.tileHartIdNexusNode]].
  */
case object InsertTimingClosureRegistersOnHartIds extends Field[Boolean](false)

/** Whether per-tile hart ids are going to be driven as inputs into a HasTiles block,
  * and if so, what their width should be.
  */
case object HasTilesExternalHartIdWidthKey extends Field[Option[Int]](None)

/** Whether per-tile reset vectors are going to be driven as inputs into a HasTiles block.
  *
  * Unlike the hart ids, the reset vector width is determined by the sinks within the tiles,
  * based on the size of the address map visible to the tiles.
  */
case object HasTilesExternalResetVectorKey extends Field[Boolean](true)

/** These are sources of "constants" that are driven into the tile.
  * 
  * While they are not expected to change dyanmically while the tile is executing code,
  * they may be either tied to a contant value or programmed during boot or reset.
  * They need to be instantiated before tiles are attached within the subsystem containing them.
  */
trait HasTileInputConstants { this: LazyModule with Attachable with InstantiatesHierarchicalElements =>
  /** tileHartIdNode is used to collect publishers and subscribers of hartids. */
  val tileHartIdNodes: SortedMap[Int, BundleBridgeEphemeralNode[UInt]] = (0 until nTotalTiles).map { i =>
    (i, BundleBridgeEphemeralNode[UInt]())
  }.to(SortedMap)

  /** tileHartIdNexusNode is a BundleBridgeNexus that collects dynamic hart prefixes.
    *
    *   Each "prefix" input is actually the same full width as the outer hart id; the expected usage
    *   is that each prefix source would set only some non-overlapping portion of the bits to non-zero values.
    *   This node orReduces them, and further combines the reduction with the static ids assigned to each tile,
    *   producing a unique, dynamic hart id for each tile.
    *
    *   If p(InsertTimingClosureRegistersOnHartIds) is set, the input and output values are registered.
    *
    *   The output values are [[dontTouch]]'d to prevent constant propagation from pulling the values into
    *   the tiles if they are constant, which would ruin deduplication of tiles that are otherwise homogeneous.
    */
  val tileHartIdNexusNode = LazyModule(new BundleBridgeNexus[UInt](
    inputFn = BundleBridgeNexus.orReduction[UInt](registered = p(InsertTimingClosureRegistersOnHartIds)) _,
    outputFn = (prefix: UInt, n: Int) =>  Seq.tabulate(n) { i =>
      val y = dontTouch(prefix | totalTileIdList(i).U(p(MaxHartIdBits).W)) // dontTouch to keep constant prop from breaking tile dedup
      if (p(InsertTimingClosureRegistersOnHartIds)) BundleBridgeNexus.safeRegNext(y) else y
    },
    default = Some(() => 0.U(p(MaxHartIdBits).W)),
    inputRequiresOutput = true, // guard against this being driven but then ignored in tileHartIdIONodes below
    shouldBeInlined = false // can't inline something whose output we are are dontTouching
  )).node
  // TODO: Replace the DebugModuleHartSelFuncs config key with logic to consume the dynamic hart IDs

  /** tileResetVectorNode is used to collect publishers and subscribers of tile reset vector addresses. */
  val tileResetVectorNodes: SortedMap[Int, BundleBridgeEphemeralNode[UInt]] = (0 until nTotalTiles).map { i =>
    (i, BundleBridgeEphemeralNode[UInt]())
  }.to(SortedMap)

  /** tileResetVectorNexusNode is a BundleBridgeNexus that accepts a single reset vector source, and broadcasts it to all tiles. */
  val tileResetVectorNexusNode = BundleBroadcast[UInt](
    inputRequiresOutput = true // guard against this being driven but ignored in tileResetVectorIONodes below
  )

  /** tileHartIdIONodes may generate subsystem IOs, one per tile, allowing the parent to assign unique hart ids.
    *
    *   Or, if such IOs are not configured to exist, tileHartIdNexusNode is used to supply an id to each tile.
    */
  val tileHartIdIONodes: Seq[BundleBridgeSource[UInt]] = p(HasTilesExternalHartIdWidthKey) match {
    case Some(w) => (0 until nTotalTiles).map { i =>
      val hartIdSource = BundleBridgeSource(() => UInt(w.W))
      tileHartIdNodes(i) := hartIdSource
      hartIdSource
    }
    case None => {
      (0 until nTotalTiles).map { i => tileHartIdNodes(i) :*= tileHartIdNexusNode }
      Nil
    }
  }

  /** tileResetVectorIONodes may generate subsystem IOs, one per tile, allowing the parent to assign unique reset vectors.
    *
    *   Or, if such IOs are not configured to exist, tileResetVectorNexusNode is used to supply a single reset vector to every tile.
    */
  val tileResetVectorIONodes: Seq[BundleBridgeSource[UInt]] = p(HasTilesExternalResetVectorKey) match {
    case true => (0 until nTotalTiles).map { i =>
      val resetVectorSource = BundleBridgeSource[UInt]()
      tileResetVectorNodes(i) := resetVectorSource
      resetVectorSource
    }
    case false => {
      (0 until nTotalTiles).map { i => tileResetVectorNodes(i) :*= tileResetVectorNexusNode }
      Nil
    }
  }
}
//===== GuardianCouncil Function: Start ====//
trait HasGHnodes {this: LazyModule  =>
  // val tile_ghm_agg_core_id_EPNode                = BundleBridgeEphemeralNode[UInt]()
  val tile_ght_packet_out_EPNode                 = BundleBridgeEphemeralNode[UInt]()
  val tile_core_r_arfs_EPNode                    = BundleBridgeEphemeralNode[UInt]()
  val tile_ic_counter_out_EPNode                 = BundleBridgeEphemeralNode[UInt]()
  // val tile_icsl_ack_EPNode                       = BundleBridgeEphemeralNode[UInt]()

  // val tile_big_checker_switch_EPNode             = BundleBridgeEphemeralNode[UInt]()
  val debug_maincore_status_out_EPNode           = BundleBridgeEphemeralNode[UInt]()

  // val big_complete_ack_EPNode           = BundleBridgeEphemeralNode[UInt]() 

  val tile_ght_packet_dest_EPNode                = BundleBridgeEphemeralNode[UInt]()
  val tile_ght_status_out_EPNode                 = BundleBridgeEphemeralNode[UInt]()

  var tile_clock_EPNodes                         = Seq[BundleBridgeEphemeralNode[Clock]]()
  var tile_reset_EPNodes                         = Seq[BundleBridgeEphemeralNode[Bool]]()

  // var tile_big_complete_EPNodes                  = Seq[BundleBridgeEphemeralNode[Bool]]()//from little
  // var tile_if_big_complete_EPNodes               = Seq[BundleBridgeEphemeralNode[Bool]]()//to little
  
  var tile_ghe_event_out_EPNodes                 = Seq[BundleBridgeEphemeralNode[UInt]]()
  var tile_ghe_revent_out_EPNodes                = Seq[BundleBridgeEphemeralNode[UInt]]()
  var tile_ghe_packet_in_EPNodes                 = Seq[BundleBridgeEphemeralNode[UInt]]()
  var core_r_arfs_c_EPNodes                      = Seq[BundleBridgeEphemeralNode[UInt]]()
  var tile_icsl_counter_in_EPNodes               = Seq[BundleBridgeEphemeralNode[UInt]]()
  var tile_clear_ic_status_out_EPNodes           = Seq[BundleBridgeEphemeralNode[UInt]]()
  var tile_ghe_status_in_EPNodes                 = Seq[BundleBridgeEphemeralNode[UInt]]()
  var clear_ic_status_tomainEPNodes              = Seq[BundleBridgeEphemeralNode[UInt]]()
  // var icsl_ack_tocheckerEPNodes                  = Seq[BundleBridgeEphemeralNode[Bool]]()

  // var big_switch_tocheckerEPNodes                  = Seq[BundleBridgeEphemeralNode[Bool]]()
  var cdc_empty_tocheckerEPNodes                 = Seq[BundleBridgeEphemeralNode[Bool]]()
  var icsl_naEPNodes                             = Seq[BundleBridgeEphemeralNode[UInt]]()

  val tile_bigcore_hang_EPNode                   = BundleBridgeEphemeralNode[UInt]()
  val tile_bigcore_comp_EPNode                   = BundleBridgeEphemeralNode[UInt]()
  val tile_debug_bp_EPNode                       = BundleBridgeEphemeralNode[UInt]()
  // val tile_if_big_complete_req_EPNode            = BundleBridgeEphemeralNode[UInt]()


  // var tile_agg_packet_out_EPNodes                = Seq[BundleBridgeEphemeralNode[UInt]]()
  // var tile_report_fi_detection_EPNodes           = Seq[BundleBridgeEphemeralNode[UInt]]()
  // var tile_report_fi_detection_in_EPNodes        = Seq[BundleBridgeEphemeralNode[UInt]]()
  // var tile_agg_buffer_full_in_EPNodes            = Seq[BundleBridgeEphemeralNode[UInt]]()
  // var tile_agg_core_status_out_EPNodes           = Seq[BundleBridgeEphemeralNode[UInt]]()

  // var tile_ght_sch_na_out_EPNodes                = Seq[BundleBridgeEphemeralNode[UInt]]()
  // var tile_ghe_sch_refresh_in_EPNodes            = Seq[BundleBridgeEphemeralNode[UInt]]()

  // val tile_sch_na_EPNode                         = BundleBridgeEphemeralNode[UInt]()
  // var tile_ght_sch_dorefresh_EPNodes             = Seq[BundleBridgeEphemeralNode[UInt]]()

  val tile_debug_gcounter_EPNode                 = BundleBridgeEphemeralNode[UInt]()
  
  // var tile_agg_packet_in_EPNodes                 = Seq[BundleBridgeEphemeralNode[UInt]]()
  // val tile_agg_empty_EPNode                      = BundleBridgeEphemeralNode[UInt]()
  // val tile_agg_free_EPNode                       = BundleBridgeEphemeralNode[UInt]()
}
//===== GuardianCouncil Function: End ======//
/** These are sinks of notifications that are driven out from the tile.
  *
  * They need to be instantiated before tiles are attached to the subsystem containing them.
  */
trait HasTileNotificationSinks { this: LazyModule =>
  val tileHaltXbarNode = IntXbar()
  val tileHaltSinkNode = IntSinkNode(IntSinkPortSimple())
  tileHaltSinkNode := tileHaltXbarNode

  val tileWFIXbarNode = IntXbar()
  val tileWFISinkNode = IntSinkNode(IntSinkPortSimple())
  tileWFISinkNode := tileWFIXbarNode

  val tileCeaseXbarNode = IntXbar()
  val tileCeaseSinkNode = IntSinkNode(IntSinkPortSimple())
  tileCeaseSinkNode := tileCeaseXbarNode
}

/** Standardized interface by which parameterized tiles can be attached to contexts containing interconnect resources.
  *
  *   Sub-classes of this trait can optionally override the individual connect functions in order to specialize
  *   their attachment behaviors, but most use cases should be be handled simply by changing the implementation
  *   of the injectNode functions in crossingParams.
  */
trait CanAttachTile {
  type TileType <: BaseTile
  type TileContextType <: DefaultHierarchicalElementContextType
  def tileParams: InstantiableTileParams[TileType]
  def crossingParams: HierarchicalElementCrossingParamsLike

  /** Narrow waist through which all tiles are intended to pass while being instantiated. */
  def instantiate(allTileParams: Seq[TileParams], instantiatedTiles: SortedMap[Int, TilePRCIDomain[_]])(implicit p: Parameters): TilePRCIDomain[TileType] = {
    val clockSinkParams = tileParams.clockSinkParams.copy(name = Some(tileParams.uniqueName))
    val tile_prci_domain = LazyModule(new TilePRCIDomain[TileType](clockSinkParams, crossingParams) { self =>
      val element = self.element_reset_domain { LazyModule(tileParams.instantiate(crossingParams, PriorityMuxHartIdFromSeq(allTileParams))) }
    })
    tile_prci_domain
  }

  /** A default set of connections that need to occur for most tile types */
  def connect(domain: TilePRCIDomain[TileType], context: TileContextType): Unit = {
    connectMasterPorts(domain, context)
    connectSlavePorts(domain, context)
    connectInterrupts(domain, context)
    connectPRC(domain, context)
    connectOutputNotifications(domain, context)
    connectInputConstants(domain, context)
    connectTrace(domain, context)
    //===== GuardianCouncil Function: Start ====//

    connectGHSingals(domain, context)
  
    //===== GuardianCouncil Function: End   ====//
  }

  /** Connect the port where the tile is the master to a TileLink interconnect. */
  def connectMasterPorts(domain: TilePRCIDomain[TileType], context: Attachable): Unit = {
    implicit val p = context.p
    val dataBus = context.locateTLBusWrapper(crossingParams.master.where)
    dataBus.coupleFrom(tileParams.baseName) { bus =>
      bus :=* crossingParams.master.injectNode(context) :=* domain.crossMasterPort(crossingParams.crossingType)
    }
  }

  /** Connect the port where the tile is the slave to a TileLink interconnect. */
  def connectSlavePorts(domain: TilePRCIDomain[TileType], context: Attachable): Unit = {
    implicit val p = context.p
    DisableMonitors { implicit p =>
      val controlBus = context.locateTLBusWrapper(crossingParams.slave.where)
      controlBus.coupleTo(tileParams.baseName) { bus =>
        domain.crossSlavePort(crossingParams.crossingType) :*= crossingParams.slave.injectNode(context) :*= TLWidthWidget(controlBus.beatBytes) :*= bus
      }
    }
  }

  /** Connect the various interrupts sent to and and raised by the tile. */
  def connectInterrupts(domain: TilePRCIDomain[TileType], context: TileContextType): Unit = {
    implicit val p = context.p
    // NOTE: The order of calls to := matters! They must match how interrupts
    //       are decoded from tile.intInwardNode inside the tile. For this reason,
    //       we stub out missing interrupts with constant sources here.

    // 1. Debug interrupt is definitely asynchronous in all cases.
    domain.element.intInwardNode := domain { IntSyncAsyncCrossingSink(3) } :=
      context.debugNodes(domain.element.tileId)

    // 2. The CLINT and PLIC output interrupts are synchronous to the CLINT/PLIC respectively,
    //    so might need to be synchronized depending on the Tile's crossing type.

    //    From CLINT: "msip" and "mtip"
    context.msipDomain {
      domain.crossIntIn(crossingParams.crossingType, domain.element.intInwardNode) :=
        context.msipNodes(domain.element.tileId)
    }

    //    From PLIC: "meip"
    context.meipDomain {
      domain.crossIntIn(crossingParams.crossingType, domain.element.intInwardNode) :=
        context.meipNodes(domain.element.tileId)
    }

    //    From PLIC: "seip" (only if supervisor mode is enabled)
    if (domain.element.tileParams.core.hasSupervisorMode) {
      context.seipDomain {
        domain.crossIntIn(crossingParams.crossingType, domain.element.intInwardNode) :=
          context.seipNodes(domain.element.tileId)
      }
    }

    // 3. Local Interrupts ("lip") are required to already be synchronous to the Tile's clock.
    // (they are connected to domain.element.intInwardNode in a seperate trait)

    // 4. Interrupts coming out of the tile are sent to the PLIC,
    //    so might need to be synchronized depending on the Tile's crossing type.
    context.tileToPlicNodes.get(domain.element.tileId).foreach { node =>
      FlipRendering { implicit p => domain.element.intOutwardNode.foreach { out =>
        context.toPlicDomain { node := domain.crossIntOut(crossingParams.crossingType, out) }
      }}
    }

    // 5. Connect NMI inputs to the tile. These inputs are synchronous to the respective core_clock.
    domain.element.nmiNode.foreach(_ := context.nmiNodes(domain.element.tileId))
  }

  /** Notifications of tile status are connected to be broadcast without needing to be clock-crossed. */
  def connectOutputNotifications(domain: TilePRCIDomain[TileType], context: TileContextType): Unit = {
    implicit val p = context.p
    domain {
      context.tileHaltXbarNode  :=* domain.crossIntOut(NoCrossing, domain.element.haltNode)
      context.tileWFIXbarNode   :=* domain.crossIntOut(NoCrossing, domain.element.wfiNode)
      context.tileCeaseXbarNode :=* domain.crossIntOut(NoCrossing, domain.element.ceaseNode)
    }
    // TODO should context be forced to have a trace sink connected here?
    //      for now this just ensures domain.trace[Core]Node has been crossed without connecting it externally
  }

  /** Connect inputs to the tile that are assumed to be constant during normal operation, and so are not clock-crossed. */
  def connectInputConstants(domain: TilePRCIDomain[TileType], context: TileContextType): Unit = {
    implicit val p = context.p
    val tlBusToGetPrefixFrom = context.locateTLBusWrapper(crossingParams.mmioBaseAddressPrefixWhere)
    domain.element.hartIdNode := context.tileHartIdNodes(domain.element.tileId)
    domain.element.resetVectorNode := context.tileResetVectorNodes(domain.element.tileId)
    tlBusToGetPrefixFrom.prefixNode.foreach { domain.element.mmioAddressPrefixNode := _ }
  }

  /** Connect power/reset/clock resources. */
  def connectPRC(domain: TilePRCIDomain[TileType], context: TileContextType): Unit = {
    implicit val p = context.p
    val tlBusToGetClockDriverFrom = context.locateTLBusWrapper(crossingParams.master.where)
    (crossingParams.crossingType match {
      case _: SynchronousCrossing | _: CreditedCrossing =>
        if (crossingParams.forceSeparateClockReset) {
          domain.clockNode := tlBusToGetClockDriverFrom.clockNode
        } else {
          domain.clockNode := tlBusToGetClockDriverFrom.fixedClockNode
        }
      case _: RationalCrossing => domain.clockNode := tlBusToGetClockDriverFrom.clockNode
      case _: AsynchronousCrossing => {
        val tileClockGroup = ClockGroup()
        tileClockGroup := context.allClockGroupsNode
        domain.clockNode := tileClockGroup
      }
    })

    domain {
      domain.element_reset_domain.clockNode := crossingParams.resetCrossingType.injectClockNode := domain.clockNode
    }
  }

  /** Function to handle all trace crossings when tile is instantiated inside domains */
  def connectTrace(domain: TilePRCIDomain[TileType], context: TileContextType): Unit = {
    implicit val p = context.p
    val traceCrossingNode = BundleBridgeBlockDuringReset[TraceBundle](
      resetCrossingType = crossingParams.resetCrossingType)
    context.traceNodes(domain.element.tileId) := traceCrossingNode := domain.element.traceNode
    val traceCoreCrossingNode = BundleBridgeBlockDuringReset[TraceCoreInterface](
      resetCrossingType = crossingParams.resetCrossingType)
    context.traceCoreNodes(domain.element.tileId) :*= traceCoreCrossingNode := domain.element.traceCoreNode
  }

  //===== GuardianCouncil Function: Start ====//
  def connectGHSingals(domain: TilePRCIDomain[TileType], context: TileContextType): Unit = {
    implicit val p = context.p
    // // GHT connections
    if(p(EnableGuardianCouncilNodes)){

      if (tileParams.tileId == 0) {
        // GHT connections
        domain.element.ic_counter_SRNode.foreach { node =>
          context.tile_ic_counter_out_EPNode := node
        }
        domain.element.debug_maincore_status_SRNode.foreach { node =>
          context.debug_maincore_status_out_EPNode := node
        }
        domain.element.ght_packet_out_SRNode.foreach { node =>
          context.tile_ght_packet_out_EPNode := node
        }
        domain.element.core_r_arfs_SRNode.foreach { node =>
          context.tile_core_r_arfs_EPNode := node
        }
        domain.element.ght_packet_dest_SRNode.foreach { node =>
          context.tile_ght_packet_dest_EPNode := node
        }
        domain.element.ght_status_out_SRNode.foreach { node =>
          context.tile_ght_status_out_EPNode := node
        }
        domain.element.bigcore_hang_in_SKNode.foreach { node =>
          node := context.tile_bigcore_hang_EPNode
        }
        domain.element.bigcore_comp_in_SKNode.foreach { node =>
          node := context.tile_bigcore_comp_EPNode
        }
        domain.element.debug_bp_in_SKNode.foreach { node =>
          node := context.tile_debug_bp_EPNode
        }
        domain.element.debug_gcounter_SKNode.foreach { node =>
          node := context.tile_debug_gcounter_EPNode
        }
        println(s"#### Jessica #### Connecting BOOM **Nodes** on the sub-system, HartID: ${tileParams.tileId} ...!!")
      }else{
        // 创建所有 useless 节点
        val useless_ic_counter = BundleBridgeSink[UInt](Some(() => UInt((16*GH_GlobalParams.GH_NUM_CORES).W)))
        val useless_debug_maincore_status = BundleBridgeSink[UInt](Some(() => UInt(4.W)))
        val useless_ght_packet_out = BundleBridgeSink[UInt](Some(() => UInt((2*GH_GlobalParams.GH_WIDITH_PACKETS).W)))
        val useless_core_r_arfs = BundleBridgeSink[UInt](Some(() => UInt(153.W)))
        val useless_ght_packet_dest = BundleBridgeSink[UInt](Some(() => UInt(32.W)))
        val useless_ght_status_out = BundleBridgeSink[UInt](Some(() => UInt(32.W)))
        val useless_bigcore_hang = BundleBridgeSource[UInt](Some(() => UInt(1.W)))
        val useless_bigcore_comp = BundleBridgeSource[UInt](Some(() => UInt(3.W)))
        val useless_debug_bp = BundleBridgeSource[UInt](Some(() => UInt(2.W)))
        val useless_debug_gcounter = BundleBridgeSource[UInt](Some(() => UInt(64.W)))

        // 连接所有 useless 节点
        domain.element.ic_counter_SRNode.foreach { node =>
          useless_ic_counter := node
        }
        domain.element.debug_maincore_status_SRNode.foreach { node =>
          useless_debug_maincore_status := node
        }
        domain.element.ght_packet_out_SRNode.foreach { node =>
          useless_ght_packet_out := node
        }
        domain.element.core_r_arfs_SRNode.foreach { node =>
          useless_core_r_arfs := node
        }
        domain.element.ght_packet_dest_SRNode.foreach { node =>
          useless_ght_packet_dest := node
        }
        domain.element.ght_status_out_SRNode.foreach { node =>
          useless_ght_status_out := node
        }
        domain.element.bigcore_hang_in_SKNode.foreach { node =>
          node := useless_bigcore_hang
        }
        domain.element.bigcore_comp_in_SKNode.foreach { node =>
          node := useless_bigcore_comp
        }
        domain.element.debug_bp_in_SKNode.foreach { node =>
          node := useless_debug_bp
        }
        domain.element.debug_gcounter_SKNode.foreach { node =>
          node := useless_debug_gcounter
        }

        println(s"#### Jessica #### Connecting USELESS **Nodes** on the sub-system, HartID: ${tileParams.tileId} ...!!")
      }
      if(tileParams.tileId < GH_GlobalParams.GH_NUM_CORES) {
        // GHE connections
        val tile_ghe_packet_in_EPNode = BundleBridgeEphemeralNode[UInt]()
        context.tile_ghe_packet_in_EPNodes = context.tile_ghe_packet_in_EPNodes :+ tile_ghe_packet_in_EPNode
        domain.element.ghe_packet_in_SKNode.foreach { node =>
          node := tile_ghe_packet_in_EPNode
        }

        val core_r_arfs_c_EPNode = BundleBridgeEphemeralNode[UInt]()
        context.core_r_arfs_c_EPNodes = context.core_r_arfs_c_EPNodes :+ core_r_arfs_c_EPNode
        domain.element.core_r_arfs_c_SKNode.foreach { node =>
          node := core_r_arfs_c_EPNode
        }

        val tile_icsl_counter_in_EPNode = BundleBridgeEphemeralNode[UInt]()
        context.tile_icsl_counter_in_EPNodes = context.tile_icsl_counter_in_EPNodes :+ tile_icsl_counter_in_EPNode
        domain.element.ic_counter_SKNode.foreach { node =>
          node :*= tile_icsl_counter_in_EPNode
        }

        val tile_clear_ic_status_out_EPNode = BundleBridgeEphemeralNode[UInt]()
        context.tile_clear_ic_status_out_EPNodes = context.tile_clear_ic_status_out_EPNodes :+ tile_clear_ic_status_out_EPNode
        domain.element.clear_ic_status_SRNode.foreach { node =>
          tile_clear_ic_status_out_EPNode := node
        }

        val clear_ic_status_tomainEPNode = BundleBridgeEphemeralNode[UInt]()
        context.clear_ic_status_tomainEPNodes = context.clear_ic_status_tomainEPNodes :+ clear_ic_status_tomainEPNode
        domain.element.clear_ic_status_tomainSKNode.foreach { node =>
          node := clear_ic_status_tomainEPNode
        }

        val cdc_empty_tocheckerEPNode = BundleBridgeEphemeralNode[Bool]()
        context.cdc_empty_tocheckerEPNodes = context.cdc_empty_tocheckerEPNodes :+ cdc_empty_tocheckerEPNode
        domain.element.cdc_empty_tocheckerSKNode.foreach { node =>
          node := cdc_empty_tocheckerEPNode
        }

        val icsl_naEPNode = BundleBridgeEphemeralNode[UInt]()
        context.icsl_naEPNodes = context.icsl_naEPNodes :+ icsl_naEPNode
        domain.element.icsl_naSKNode.foreach { node =>
          node := icsl_naEPNode
        }

        val tile_ghe_status_in_EPNode = BundleBridgeEphemeralNode[UInt]()
        context.tile_ghe_status_in_EPNodes = context.tile_ghe_status_in_EPNodes :+ tile_ghe_status_in_EPNode
        domain.element.ghe_status_in_SKNode.foreach { node =>
          node := tile_ghe_status_in_EPNode
        }

        val tile_ghe_event_out_EPNode = BundleBridgeEphemeralNode[UInt]()
        context.tile_ghe_event_out_EPNodes = context.tile_ghe_event_out_EPNodes :+ tile_ghe_event_out_EPNode
        domain.element.ghe_event_out_SRNode.foreach { node =>
          tile_ghe_event_out_EPNode := node
        }

        val tile_clock_EPNode = BundleBridgeEphemeralNode[Clock]()
        context.tile_clock_EPNodes = context.tile_clock_EPNodes :+ tile_clock_EPNode
        domain.element.clock_SRNode.foreach { node =>
          tile_clock_EPNode := node
        }

        val tile_reset_EPNode = BundleBridgeEphemeralNode[Bool]()
        context.tile_reset_EPNodes = context.tile_reset_EPNodes :+ tile_reset_EPNode
        domain.element.reset_SRNode.foreach { node =>
          tile_reset_EPNode := node
        }

        val tile_ghe_revent_out_EPNode = BundleBridgeEphemeralNode[UInt]()
        context.tile_ghe_revent_out_EPNodes = context.tile_ghe_revent_out_EPNodes :+ tile_ghe_revent_out_EPNode
        domain.element.ghe_revent_out_SRNode.foreach { node =>
          tile_ghe_revent_out_EPNode := node
        }

        println(s"#### Jessica #### Connecting GHE **Nodes** on the sub-system, HartID: ${tileParams.tileId} ...!!")
      }else{
      // 创建所有 useless nodes
        val useless_ghe_packet_in = BundleBridgeSource[UInt](Some(() => UInt((GH_GlobalParams.GH_TOTAL_PACKETS*GH_GlobalParams.GH_WIDITH_PACKETS+1).W)))
         val useless_core_r_arfs_c = BundleBridgeSource[UInt](Some(() => UInt((GH_GlobalParams.GH_WIDITH_PACKETS+8+1).W)))
        val useless_icsl_counter = BundleBridgeSource[UInt](Some(() => UInt(20.W)))
        val useless_clear_ic_status = BundleBridgeSink[UInt](Some(() => UInt(1.W)))
        val useless_clear_ic_status_tomain = BundleBridgeSource[UInt](Some(() => UInt(GH_GlobalParams.GH_NUM_CORES.W)))
        val useless_cdc_empty = BundleBridgeSource[Bool](Some(() => Bool()))
        val useless_icsl_na = BundleBridgeSource[UInt](Some(() => UInt(GH_GlobalParams.GH_NUM_CORES.W)))
        val useless_ghe_status_in = BundleBridgeSource[UInt](Some(() => UInt(32.W)))
        val useless_ghe_event_out = BundleBridgeSink[UInt](Some(() => UInt(6.W)))
        val useless_clock = BundleBridgeSink[Clock](Some(() => Clock()))
        val useless_reset = BundleBridgeSink[Bool](Some(() => Bool()))
        val useless_ghe_revent_out = BundleBridgeSink[UInt](Some(() => UInt(1.W)))

        // 连接所有 useless nodes
        domain.element.ghe_packet_in_SKNode.foreach { node =>
          node := useless_ghe_packet_in
        }
        domain.element.core_r_arfs_c_SKNode.foreach { node =>
          node := useless_core_r_arfs_c
        }
        domain.element.ic_counter_SKNode.foreach { node =>
          node := useless_icsl_counter
        }
        domain.element.clear_ic_status_SRNode.foreach { node =>
          useless_clear_ic_status := node
        }
        domain.element.clear_ic_status_tomainSKNode.foreach { node =>
          node := useless_clear_ic_status_tomain
        }
        domain.element.cdc_empty_tocheckerSKNode.foreach { node =>
          node := useless_cdc_empty
        }
        domain.element.icsl_naSKNode.foreach { node =>
          node := useless_icsl_na
        }
        domain.element.ghe_status_in_SKNode.foreach { node =>
          node := useless_ghe_status_in
        }
        domain.element.ghe_event_out_SRNode.foreach { node =>
          useless_ghe_event_out := node
        }
        domain.element.clock_SRNode.foreach { node =>
          useless_clock := node
        }
        domain.element.reset_SRNode.foreach { node =>
          useless_reset := node
        }
        domain.element.ghe_revent_out_SRNode.foreach { node =>
          useless_ghe_revent_out := node
        }

        println(s"#### Jessica #### Connecting USELESS GHE **Nodes** on the sub-system, HartID: ${tileParams.tileId} ...!!")
      }
    }

  }
  
  //===== GuardianCouncil Function: End ======//
}

case class CloneTileAttachParams(
  sourceTileId: Int,
  cloneParams: CanAttachTile
) extends CanAttachTile {
  type TileType = cloneParams.TileType
  type TileContextType = cloneParams.TileContextType

  def tileParams = cloneParams.tileParams
  def crossingParams = cloneParams.crossingParams

  override def instantiate(allTileParams: Seq[TileParams], instantiatedTiles: SortedMap[Int, TilePRCIDomain[_]])(implicit p: Parameters): TilePRCIDomain[TileType] = {
    require(instantiatedTiles.contains(sourceTileId))
    val clockSinkParams = tileParams.clockSinkParams.copy(name = Some(tileParams.uniqueName))
    val tile_prci_domain = CloneLazyModule(
      new TilePRCIDomain[TileType](clockSinkParams, crossingParams) { self =>
        val element = self.element_reset_domain { LazyModule(tileParams.instantiate(crossingParams, PriorityMuxHartIdFromSeq(allTileParams))) }
      },
      instantiatedTiles(sourceTileId).asInstanceOf[TilePRCIDomain[TileType]]
    )
    tile_prci_domain
  }
}


