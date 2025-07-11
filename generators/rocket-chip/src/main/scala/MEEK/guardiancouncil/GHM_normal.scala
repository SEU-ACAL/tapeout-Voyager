package freechips.rocketchip.guardiancouncil


import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}
import org.chipsalliance.cde.config.{Field, Parameters}
import freechips.rocketchip.subsystem.{BaseSubsystem, HierarchicalLocation, TLBusWrapperLocation,HasHierarchicalElements,HasGHnodes,HasTileInputConstants}
import freechips.rocketchip.diplomacy._
//===== GuardianCouncil Function: Start ====//
import freechips.rocketchip.guardiancouncil._
//===== GuardianCouncil Function: End   ====//

// import boom.common.{BoomTile}
import freechips.rocketchip.util._


//==========================================================
// Implementations
//==========================================================
class GHM_normal (val params: GHMParams)(implicit p: Parameters) extends LazyModule
{
    // Creating nodes for connections.
    val bigcore_hang_SRNode                        = BundleBridgeSource[UInt](Some(() => UInt(1.W)))
    val bigcore_comp_SRNode                        = BundleBridgeSource[UInt](Some(() => UInt(3.W)))
    val debug_bp_SRNode                            = BundleBridgeSource[UInt](Some(() => UInt(2.W)))
    val ghm_ght_packet_in_SKNode                   = BundleBridgeSink[UInt](Some(() => UInt((GH_GlobalParams.GH_TOTAL_PACKETS*params.width_GH_packet).W)))
    val core_r_arfs_in_SKNode                      = BundleBridgeSink[UInt](Some(() => UInt((params.width_GH_packet+8+8+1).W)))
    val ic_counter_SKNode                          = BundleBridgeSink[UInt](Some(() => UInt((16*GH_GlobalParams.GH_NUM_CORES).W)))
    val debug_maincore_status_SKNode               = BundleBridgeSink[UInt](Some(() => UInt(4.W)))
    val ghm_ght_packet_dest_SKNode                 = BundleBridgeSink[UInt](Some(() => UInt(32.W)))
    val ghm_ght_status_in_SKNode                   = BundleBridgeSink[UInt](Some(() => UInt(32.W)))
    val ghm_ghe_packet_out_SRNodes   = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSource[UInt]())
    val core_r_arfs_c_SRNodes        = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSource[UInt]())
    val icsl_out_SRNodes             = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSource[UInt]())
    val ghm_ghe_status_out_SRNodes   = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSource[UInt]())
    val ghm_ghe_event_in_SKNodes     = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSink[UInt]())
    val ghm_clock_in_SKNodes         = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSink[Clock]())
    val ghm_reset_in_SKNodes         = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSink[Bool]())
    val ghm_cdc_empty_out_SKNodes    = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSource[Bool]())
    val ghm_ghe_revent_in_SKNodes    = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSink[UInt]())
    val clear_ic_status_SkNodes      = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSink[UInt]())
    val clear_ic_status_tomainSRNodes= Seq.fill(params.number_of_little_cores+1)(BundleBridgeSource[UInt]())
    val icsl_naSRNodes               = Seq.fill(params.number_of_little_cores+1)(BundleBridgeSource[UInt]())
    // val ghm_ghe_packet_out_SRNodes                 = Seq[BundleBridgeSource[UInt]]()
    // val core_r_arfs_c_SRNodes                      = Seq[BundleBridgeSource[UInt]]()
    // val icsl_out_SRNodes                           = Seq[BundleBridgeSource[UInt]]()
    // val ghm_ghe_status_out_SRNodes                 = Seq[BundleBridgeSource[UInt]]()
    // val ghm_ghe_event_in_SKNodes                   = Seq[BundleBridgeSink[UInt]]()
    // val ghm_clock_in_SKNodes                       = Seq[BundleBridgeSink[Clock]]()
    // val ghm_reset_in_SKNodes                       = Seq[BundleBridgeSink[Bool]]()
    // val ghm_cdc_empty_out_SKNodes                  = Seq[BundleBridgeSource[Bool]]()
    // val ghm_ghe_revent_in_SKNodes                  = Seq[BundleBridgeSink[UInt]]()
    // val clear_ic_status_SkNodes                    = Seq[BundleBridgeSink[UInt]]()
    // val clear_ic_status_tomainSRNodes              = Seq[BundleBridgeSource[UInt]]()
    // val icsl_naSRNodes                             = Seq[BundleBridgeSource[UInt]]()
    val debug_gcounter_SRNode                      = BundleBridgeSource[UInt](Some(() => UInt(64.W)))
    lazy val module = new GHM_normalImpl(params)(this)
}
class GHM_normalImpl(val params: GHMParams)(outer: GHM_normal) extends LazyModuleImp(outer) {
    val ghm_clock                                  = Wire(Vec(params.number_of_little_cores+1,Bool()))
    val ghm_reset                                  = Wire(Vec(params.number_of_little_cores+1,Bool()))


    val ghm_packet_in                              = Wire(UInt((params.width_GH_packet*GH_GlobalParams.GH_TOTAL_PACKETS).W))
    val ghm_packet_dest                            = Wire(UInt((params.number_of_little_cores*2).W))
    val ghm_status_in                              = Wire(UInt(32.W))
    val ghm_packet_outs                            = Wire(Vec(params.number_of_little_cores, UInt((params.width_GH_packet*GH_GlobalParams.GH_TOTAL_PACKETS+1).W)))
    val ghm_status_outs                            = Wire(Vec(params.number_of_little_cores, UInt(32.W)))
    val ghe_event_in                               = Wire(Vec(params.number_of_little_cores, UInt(6.W)))
    val clear_ic_status                            = Wire(Vec(params.number_of_little_cores, UInt(1.W)))
    val clear_ic_status_tomain                     = Wire(UInt(GH_GlobalParams.GH_NUM_CORES.W))
    val bigcore_hang                               = Wire(UInt(1.W))
    val bigcore_comp                               = Wire(UInt(3.W))
    val debug_bp                                   = Wire(UInt(2.W))
    val ic_counter                                 = Wire(UInt((16*GH_GlobalParams.GH_NUM_CORES).W))
    val debug_maincore_status                      = Wire(UInt(4.W))
    val icsl_counter                               = Wire(Vec(params.number_of_little_cores, UInt(20.W)))
    val ghe_revent_in                              = Wire(Vec(params.number_of_little_cores, UInt(1.W)))
    val ghm_cdc_empty_out                          = Wire(Vec(params.number_of_little_cores, Bool()))
    val icsl_na                                    = Wire(UInt((GH_GlobalParams.GH_NUM_CORES).W))
    val debug_gcounter                             = Wire(UInt(64.W))
    val core_r_arfs_in                             = Wire(UInt((params.width_GH_packet+8+8+1).W))
    val core_r_arfs_c                              = Wire(Vec(params.number_of_little_cores, UInt((params.width_GH_packet+8+1).W)))

    core_r_arfs_in                := outer.core_r_arfs_in_SKNode.bundle   
    ghm_packet_in                 := outer.ghm_ght_packet_in_SKNode.bundle
    ghm_packet_dest               := outer.ghm_ght_packet_dest_SKNode.bundle
    ghm_status_in                 := outer.ghm_ght_status_in_SKNode.bundle

    ic_counter                    := outer.ic_counter_SKNode.bundle
    debug_maincore_status         := outer.debug_maincore_status_SKNode.bundle
    for (i <- 0 to params.number_of_little_cores) {
        ghm_clock(i)                        :=outer.ghm_clock_in_SKNodes(i).bundle.asBool
        ghm_reset(i)                        :=outer.ghm_reset_in_SKNodes(i).bundle.asBool
        if (i == 0) { // The big core
        // GHE is not connected to the big core
        outer.ghm_ghe_packet_out_SRNodes(i).bundle    := 0.U 
        outer.core_r_arfs_c_SRNodes(i).bundle         := 0.U
        outer.ghm_ghe_status_out_SRNodes(i).bundle    := 0.U
        outer.clear_ic_status_tomainSRNodes(i).bundle := clear_ic_status_tomain
        outer.icsl_naSRNodes(i).bundle                := icsl_na
        outer.icsl_out_SRNodes(i).bundle              := 0.U
        } else {// -1 big core
        outer.ghm_ghe_packet_out_SRNodes(i).bundle    := ghm_packet_outs(i-1)
        outer.core_r_arfs_c_SRNodes(i).bundle         := core_r_arfs_c(i-1)
        outer.ghm_ghe_status_out_SRNodes(i).bundle    := ghm_status_outs(i-1)
        outer.clear_ic_status_tomainSRNodes(i).bundle := 0.U
        outer.icsl_naSRNodes(i).bundle                := 0.U
        outer.ghm_cdc_empty_out_SKNodes(i).bundle     := ghm_cdc_empty_out(i-1)
        outer.icsl_out_SRNodes(i).bundle              := icsl_counter(i-1)
        ghe_event_in(i-1)                             := outer.ghm_ghe_event_in_SKNodes(i).bundle
        ghe_revent_in(i-1)                            := outer.ghm_ghe_revent_in_SKNodes(i).bundle
        clear_ic_status(i-1)                          := outer.clear_ic_status_SkNodes(i).bundle
        }
    }

    outer.bigcore_hang_SRNode.bundle                  := bigcore_hang
    outer.bigcore_comp_SRNode.bundle                  := bigcore_comp
    outer.debug_bp_SRNode.bundle                      := debug_bp
    outer.debug_gcounter_SRNode.bundle                := debug_gcounter
    // Adding a register to avoid the critical path
    // val packet_dest                                = WireInit(0.U((params.number_of_little_cores).W))
    //加入了flag
    val packet_out_wires                           = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(0.U((params.width_GH_packet*GH_GlobalParams.GH_TOTAL_PACKETS+1).W))))
    val cdc_busy                                   = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(false.B)))
    val arfs_cdc_busy                              = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(false.B)))
    val cdc_empty                                  = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(false.B)))

    val data_cdc_ready                             = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(false.B)))
    // val arfs_dest                                  = WireInit(0.U((params.number_of_little_cores).W))

    // packet_dest                                   := io.ghm_packet_dest(params.number_of_little_cores-1, 0)
    val packet_dest                                = WireInit(VecInit(Seq.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U(4.W))))
    val arfs_pidx                                  = WireInit(core_r_arfs_in(params.width_GH_packet+7+1, params.width_GH_packet+1))
    val arfs_ecp_idx                               = WireInit(core_r_arfs_in(params.width_GH_packet+15+1, params.width_GH_packet+8+1))

    val arfs_dest                                  = arfs_pidx(5, 3)
    val arfs_ecp_dest                              = arfs_ecp_idx(5, 3)
    dontTouch(arfs_dest)
    dontTouch(arfs_ecp_dest)
    dontTouch(packet_dest)
    for(i<- 0 until GH_GlobalParams.GH_TOTAL_PACKETS){
        packet_dest(i)                              := ghm_packet_in((i+1)*params.width_GH_packet-1, (i+1)*params.width_GH_packet-8)(6,3)
    }
//==========================================================
// Multi Bits 1:1 fifo
//==========================================================


    val u_data_cdc                                      = Seq.fill(params.number_of_little_cores) {Module(new Queue(UInt((params.width_GH_packet*GH_GlobalParams.GH_TOTAL_PACKETS).W),8))}
    val u_arfs_cdc                                      = Seq.fill(params.number_of_little_cores) {Module(new Queue(UInt((params.width_GH_packet+8+1).W), (8)))}//留8个余量防止写入太快
    // val u_l2b_ctrl_cdc                                  = Seq.fill(params.number_of_little_cores) {Module(new Queue(UInt(9.W), 64))}
    // val u_b2l_ctrl_cdc                                  = Seq.fill(params.number_of_little_cores) {Module(new Queue(UInt((22).W), 4))}//早晚会满

    val l_wctrl = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(0.U(8.W))))
    val b_rctrl = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(0.U(8.W))))

    //如果添加控制信号，必须去加位宽!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    val l_rctrl = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(0.U((22).W))))
    val b_wctrl = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(0.U((22).W))))
    //需要对控制信号扩展，以此来防止信号出错,控制信号大部分都是一系列高电平，需要去转换为单个高电平,同时需要保证CDC FIFO不能满
    println(s"GHM${params.number_of_little_cores}\n")
    for (i <- 0 to params.number_of_little_cores - 1) {
      
      val if_data_en = (0 until GH_GlobalParams.GH_TOTAL_PACKETS).map{j=>
        packet_dest(j)===(i+1).U
      }.reduce(_|_)
      dontTouch(if_data_en)
      //data  

    //   u_data_cdc(i).io.deq_clock := ghm_clock(i+1).asClock
    //   u_data_cdc(i).io.deq_reset := ghm_reset(i+1)

        u_data_cdc(i).io.enq.valid := if_data_en
        u_data_cdc(i).io.enq.bits  := ghm_packet_in
        data_cdc_ready(i)          := ghe_event_in(i)(4)&(!ghe_event_in(i)(0))
        u_data_cdc(i).io.deq.ready := data_cdc_ready(i)
        packet_out_wires(i)        := Mux(u_data_cdc(i).io.deq.fire,u_data_cdc(i).io.deq.bits,0.U)
        cdc_busy(i)                := (!u_data_cdc(i).io.enq.ready)
        cdc_empty(i)               := (!u_data_cdc(i).io.deq.valid)




        u_arfs_cdc(i).io.enq.valid := arfs_dest===(i+1).U||arfs_ecp_dest===(i+1).U
        u_arfs_cdc(i).io.enq.bits  := core_r_arfs_in
        u_arfs_cdc(i).io.deq.ready := true.B
        core_r_arfs_c(i)        := Mux(u_arfs_cdc(i).io.deq.fire,u_arfs_cdc(i).io.deq.bits,0.U)

        arfs_cdc_busy(i)          := (!u_arfs_cdc(i).io.enq.ready)
        dontTouch(u_arfs_cdc(i).io.enq.ready)
      //little to big CDC
        l_wctrl(i)                     := Cat(clear_ic_status(i),ghe_revent_in(i),ghe_event_in(i))

        // u_l2b_ctrl_cdc(i).io.enq.valid := clear_ic_status(i)|ghe_revent_in(i)|ghe_event_in(i)=/=0.U
        // u_l2b_ctrl_cdc(i).io.enq.bits  := l_wctrl(i)
        // u_l2b_ctrl_cdc(i).io.deq.ready := true.B
        // dontTouch(u_l2b_ctrl_cdc(i).io.enq.ready)
        b_rctrl(i)                     := l_wctrl(i)
      //big to little CDC

        b_wctrl(i)                     := Cat(ic_counter((i+2)*16-1,(i+1)*16),ghm_status_in(31),ghm_status_in(4,0))

        // u_b2l_ctrl_cdc(i).io.enq.valid := ghm_status_in(31)|ghm_status_in(4,0)=/=0.U|ic_counter((i+2)*16-1,(i+1)*16)=/=0.U
        // u_b2l_ctrl_cdc(i).io.enq.bits  := b_wctrl(i)
        // u_b2l_ctrl_cdc(i).io.deq.ready := true.B
        l_rctrl(i)                     := b_wctrl(i)
      // when(u_b2l_ctrl_cdc(i).io.enq.valid&&(!u_b2l_ctrl_cdc(i).io.enq.ready)){
      //   printf(midas.targetutils.SynthesizePrintf("Big core to little core ctrl CDC FIFO IS FULL!!! ghm_status %x ic_cnt %x\n",io.ghm_status_in,io.ic_counter))
      // }
        // dontTouch(u_b2l_ctrl_cdc(i).io.enq.ready)
    }
    dontTouch(l_wctrl)
    dontTouch(b_wctrl)
    dontTouch(data_cdc_ready)
    
    //所有信号都需要展宽
    val cdc_ghe_event                              = WireInit(VecInit(b_rctrl.map{i=>i(5,0)}))  //可以采样，3周期一采样,但这样做就无法去得到正确的反压信号
    val cdc_ghe_revent                             = WireInit(VecInit(b_rctrl.map{i=>i(6)} ))   //只采样高信号
    val cdc_clear_ic_status                        = WireInit(VecInit(b_rctrl.map{i=>i(7)} ))   //只采样高信号
    // val cdc_if_big_complete                        = WireInit(VecInit(b_rctrl.map{i=>i(8)} ))   //只采样高信号 not uesd
    
    val cdc_icsl_cnt                               = l_rctrl.map{i=>i(21,6)}
    val cdc_filter_empty                           = l_rctrl.map{i=>i(5)} //只采样高信号
    val cdc_ghm_status                             = l_rctrl.map{i=>i(4,0)} //3个周期一采样
    // val cdc_icsl_ack                               = l_rctrl.map{i=>i(6)}//只采样高信号
    // val cdc_big_complete_ack                       = WireInit(VecInit(l_rctrl.map{i=>i(7)}))//只采样高信号 not used
    
    // dontTouch(cdc_big_complete_ack)
    // val cdc_big_switch_req                         = l_rctrl.map{i=>i(27)}

    val zero                                       = WireInit(0.U(1.W))

    val ghe_event                                  = WireInit(0.U(3.W))
    val initalised                                 = WireInit(0.U(1.W))
    val big_bp                                     = WireInit(false.B)//大核反压
    val little_bp                                  = WireInit(false.B)//小核反压

    val if_filters_empty                           = ghm_status_in(31)

    val if_cdc_empty                               = cdc_empty.reduce(_&_)//这个信号不知道会不会出问题？
    val if_no_inflight_packets                     = WireInit(VecInit((0 until params.number_of_little_cores).map{i=>cdc_filter_empty(i) & cdc_empty(i) } )) 
    // big_bp := u_b2l_ctrl_cdc.map({i=>i.io.enq.ready}).reduce(_&_)
    // little_bp := u_l2b_ctrl_cdc.map({i=>i.io.enq.ready}).reduce(_&_)
    //need CDC
    // dontTouch(big_bp)
    clear_ic_status_tomain                     := Cat(Cat(cdc_clear_ic_status.reverse), zero)//小核心到大核心//1bit 会延迟2个周期
    // io.if_big_complete_req                        := Cat(cdc_if_big_complete.reverse)



    dontTouch(if_no_inflight_packets)
    dontTouch(if_filters_empty)
    dontTouch(if_cdc_empty)
    dontTouch(cdc_busy)
    // dontTouch(if_no_inflight_packets)
    val zeros_59bit                                = WireInit(0.U(59.W))
    //这里也需要CDC，可以考虑将这个ghm_status_outs存入CDC FIFO //to little 
    for(i <- 0 to params.number_of_little_cores - 1) {
      ghm_packet_outs(i)                       := packet_out_wires(i)
      ghm_status_outs(i)                       := Mux(if_no_inflight_packets(i)===1.U, Cat(zeros_59bit, cdc_ghm_status(i)), 1.U)
      // io.ghm_big_complete(i)                      := cdc_big_complete_ack(i)
    }

    dontTouch(ghm_packet_outs)
    dontTouch(ghm_status_outs)




    bigcore_hang                              := cdc_busy.reduce(_|_)|arfs_cdc_busy.reduce(_|_)
    bigcore_comp                              := cdc_ghe_event.map{i=>i(3,1)}.reduce(_&_)//cdc 这里实话会出问题，但应该不是功能bug
    dontTouch(cdc_ghe_event)
    debug_gcounter                            := 0.U//cdc

    val debug_collecting_checker_status           = cdc_ghe_event.reduce(_|_)//小->大
    val debug_backpressure_checkers               = debug_collecting_checker_status(0)
    debug_bp                                  := Cat(cdc_busy.reduce(_|_), debug_backpressure_checkers) // [1]: CDC; [0]: Checker

    for (i <- 0 to params.number_of_little_cores - 1) {
      icsl_counter(i)                         := cdc_icsl_cnt(i)
      // io.ghm_icsl_ack_out(i)                     := cdc_icsl_ack(i)
      ghm_cdc_empty_out(i)                    := cdc_empty(i)
      // io.ghm_big_switch_out(i)                   := cdc_big_switch_req(i)
    }
    icsl_na                                   := Cat(Cat(cdc_ghe_revent.reverse), zero)//小->大 1bit
}

// case class GHMCoreLocated(loc: HierarchicalLocation) extends Field[Option[GHMParams]](None)

// object GHMCore {
// // def attach(params: BootROMParams, subsystem: BaseSubsystem with HasHierarchicalElements with HasTileInputConstants, where: TLBusWrapperLocation)
//   def attach(params: GHMParams, subsystem: BaseSubsystem with HasHierarchicalElements with HasTileInputConstants with HasGHnodes, where: TLBusWrapperLocation)(implicit p: Parameters):GHM= {
    
//     val number_of_ghes                             = subsystem.tile_ghe_packet_in_EPNodes.size
//     println("#### Jessica #### Tieing off GHM **Nodes**, core number:", number_of_ghes,"...!!")


//     val bus = subsystem.locateTLBusWrapper(where)
//     val GHMDomainWrapper = bus.generateSynchronousDomain("GHM").suggestName("ghm_domain")


    
//     val ghm = GHMDomainWrapper {
//       LazyModule (new GHM (GHMParams (params.number_of_little_cores, params.width_GH_packet)))
//     }

//     ghm.core_r_arfs_in_SKNode                         := subsystem.tile_core_r_arfs_EPNode
//     ghm.ghm_ght_packet_in_SKNode                      := subsystem.tile_ght_packet_out_EPNode
//     ghm.ic_counter_SKNode                             := subsystem.tile_ic_counter_out_EPNode
//     ghm.debug_maincore_status_SKNode                  := subsystem.debug_maincore_status_out_EPNode
//     ghm.ghm_ght_packet_dest_SKNode                    := subsystem.tile_ght_packet_dest_EPNode
//     ghm.ghm_ght_status_in_SKNode                      := subsystem.tile_ght_status_out_EPNode



//     // 2. 批量连接节点
//     for (i <- 0 until number_of_ghes) {
//       if(i<=params.number_of_little_cores){
//         subsystem.tile_ghe_packet_in_EPNodes(i)         := ghm.ghm_ghe_packet_out_SRNodes(i)
//         subsystem.core_r_arfs_c_EPNodes(i)              := ghm.core_r_arfs_c_SRNodes(i)
//         subsystem.tile_icsl_counter_in_EPNodes(i)       := ghm.icsl_out_SRNodes(i)
//         subsystem.tile_ghe_status_in_EPNodes(i)         := ghm.ghm_ghe_status_out_SRNodes(i)
//         ghm.ghm_ghe_event_in_SKNodes(i)                 := subsystem.tile_ghe_event_out_EPNodes(i)
//         ghm.ghm_clock_in_SKNodes(i)                     := subsystem.tile_clock_EPNodes(i)
//         ghm.ghm_reset_in_SKNodes(i)                     := subsystem.tile_reset_EPNodes(i)
//         subsystem.cdc_empty_tocheckerEPNodes(i)         := ghm.ghm_cdc_empty_out_SKNodes(i)
//         ghm.ghm_ghe_revent_in_SKNodes(i)                := subsystem.tile_ghe_revent_out_EPNodes(i)
//         ghm.clear_ic_status_SkNodes(i)                  := subsystem.tile_clear_ic_status_out_EPNodes(i)
//         subsystem.clear_ic_status_tomainEPNodes(i)      := ghm.clear_ic_status_tomainSRNodes(i)
//         subsystem.icsl_naEPNodes(i)                     := ghm.icsl_naSRNodes(i)
//       }
//       // else{
//       //   val useless_ghm_ghe_packet_out_SRNodes   = (BundleBridgeSource[UInt]())
//       //   val useless_core_r_arfs_c_SRNodes        = (BundleBridgeSource[UInt]())
//       //   val useless_icsl_out_SRNodes             = (BundleBridgeSource[UInt]())
//       //   val useless_ghm_ghe_status_out_SRNodes   = (BundleBridgeSource[UInt]())
//       //   val useless_ghm_ghe_event_in_SKNodes     = (BundleBridgeSink[UInt]())
//       //   val useless_ghm_clock_in_SKNodes         = (BundleBridgeSink[Clock]())
//       //   val useless_ghm_reset_in_SKNodes         = (BundleBridgeSink[Bool]())
//       //   val useless_ghm_cdc_empty_out_SKNodes    = (BundleBridgeSource[Bool]())
//       //   val useless_ghm_ghe_revent_in_SKNodes    = (BundleBridgeSink[UInt]())
//       //   val useless_clear_ic_status_SkNodes      = (BundleBridgeSink[UInt]())
//       //   val useless_clear_ic_status_tomainSRNodes= (BundleBridgeSource[UInt]())
//       //   val useless_icsl_naSRNodes               = (BundleBridgeSource[UInt]())
//       //   subsystem.tile_ghe_packet_in_EPNodes(i)         := useless_ghm_ghe_packet_out_SRNodes
//       //   subsystem.core_r_arfs_c_EPNodes(i)              := useless_core_r_arfs_c_SRNodes
//       //   subsystem.tile_icsl_counter_in_EPNodes(i)       := useless_icsl_out_SRNodes
//       //   subsystem.tile_ghe_status_in_EPNodes(i)         := useless_ghm_ghe_status_out_SRNodes
//       //   subsystem.cdc_empty_tocheckerEPNodes(i)         := useless_ghm_cdc_empty_out_SKNodes
//       //   subsystem.clear_ic_status_tomainEPNodes(i)      := useless_clear_ic_status_tomainSRNodes
//       //   subsystem.icsl_naEPNodes(i)                     := useless_icsl_naSRNodes
//       //   useless_ghm_ghe_event_in_SKNodes                := subsystem.tile_ghe_event_out_EPNodes(i)
//       //   useless_ghm_clock_in_SKNodes                    := subsystem.tile_clock_EPNodes(i)
//       //   useless_ghm_reset_in_SKNodes                    := subsystem.tile_reset_EPNodes(i)
//       //   useless_ghm_ghe_revent_in_SKNodes               := subsystem.tile_ghe_revent_out_EPNodes(i)
//       //   useless_clear_ic_status_SkNodes                 := subsystem.tile_clear_ic_status_out_EPNodes(i)

//       // }
//     }

//     subsystem.tile_bigcore_comp_EPNode            := ghm.bigcore_comp_SRNode
//     subsystem.tile_bigcore_hang_EPNode            := ghm.bigcore_hang_SRNode
//     subsystem.tile_debug_bp_EPNode                := ghm.debug_bp_SRNode


//     subsystem.tile_debug_gcounter_EPNode          := ghm.debug_gcounter_SRNode

//     ghm

//   }
// }