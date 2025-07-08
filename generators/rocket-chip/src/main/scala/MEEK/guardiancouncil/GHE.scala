package freechips.rocketchip.guardiancouncil

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config._
import freechips.rocketchip.tile._
//===== GuardianCouncil Function: Start ====//
import freechips.rocketchip.guardiancouncil._
import freechips.rocketchip.meek._
//===== GuardianCouncil Function: End   ====//


class GHE(opcodes: OpcodeSet)(implicit p: Parameters) extends LazyRoCCMEEK(opcodes) {
  override lazy val module = new GHEImp (this)
}

class GHEImp(outer: GHE)(implicit p: Parameters) extends LazyRoCCMEEKModuleImp(outer)
    with HasCoreParameters {
    val s_or_r                  = RegInit(0.U(2.W))    // If the core runs for security or relaibility? 
                                                       // 0: secuirty; 1: reliability

    val gh_packet_width         = GH_GlobalParams.GH_WIDITH_PACKETS
    val cmd                     = io.cmd
    val funct                   = cmd.bits.inst.funct
    val rs2                     = cmd.bits.inst.rs2
    val rs1                     = cmd.bits.inst.rs1
    val xd                      = cmd.bits.inst.xd
    val xs1                     = cmd.bits.inst.xs1
    val xs2                     = cmd.bits.inst.xs2
    val rd                      = cmd.bits.inst.rd
    val opcode                  = cmd.bits.inst.opcode

    val rs1_val                 = cmd.bits.rs1
    val rs2_val                 = cmd.bits.rs2
    val rd_val                  = WireInit(0.U(xLen.W))

    // Internal signals
    val channel_empty           = WireInit(true.B)
    val channel_full            = WireInit(false.B)
    val channel_nearfull        = WireInit(false.B)
    val channel_warning         = WireInit(0.U(1.W))
    val channel_sch_na          = RegInit(0.U(1.W))

    channel_empty              := 1.U
    channel_full               := 0.U
    channel_nearfull           := 0.U
    channel_warning            := 0.U

    // Software Funcs
    val doCheck                 = (cmd.fire && (funct === 0x00.U))
    val doSorR                  = (cmd.fire && (funct === 0x01.U))
    val doEvent                 = (cmd.fire && ((funct === 0x40.U) || (funct === 0x41.U) || (funct === 0x42.U) || (funct === 0x43.U)))
    val doCheckBigStatus        = (cmd.fire && (funct === 0x07.U))
    val doCheckAgg              = (cmd.fire && (funct === 0x10.U))
    val doInitialised           = (cmd.fire && ((funct === 0x50.U) || (funct === 0x51.U)))
    /* R Features */
    val doCopy                  = (cmd.fire && (funct === 0x60.U))
    val doCheckRSU              = (cmd.fire && (funct === 0x61.U))
    val doDeqELU                = (cmd.fire && (funct === 0x63.U))
    val doRecordPC              = (cmd.fire && (funct === 0x64.U))
    val doCoreTrace             = (cmd.fire && (funct === 0x69.U))

    // For big core
    val doBigCheckComp          = (cmd.fire && (funct === 0x6.U))
    val doMask                  = (cmd.fire && ((funct === 0x30.U) || (funct === 0x31.U) || (funct === 0x32.U) || (funct === 0x33.U) || (funct === 0x34.U) || (funct === 0x35.U) || (funct === 0x36.U) || (funct === 0x37.U) || (funct === 0x38.U)))
    val doCritical              = (cmd.fire && (funct === 0x39.U))
    val doCheckCritial          = (cmd.fire && (funct === 0x49.U))
    val doPID_Cfg               = (cmd.fire && (funct === 0x16.U))
    val doGHT_Cfg               = (cmd.fire && (funct === 0x6.U) && ((rs2_val === 2.U) || (rs2_val === 3.U) || (rs2_val === 4.U)))
    val doGetCsrPerf            = (cmd.fire && (funct === 0x55.U))
    val doGHTBufferCheck        = (cmd.fire && (funct === 0x8.U))
    val doTrapDebug             = (cmd.fire && (funct === 0x91.U||(funct === 0x90.U)))
    // val doCheckM_PPN            = (cmd.fire && (funct === 0x17.U))
    // val doCheckM_SysMode        = (cmd.fire && (funct === 0x18.U))
    val bigComp                 = io.bigcore_comp (1,0)//ghm传入
    val bigInialised            = io.bigcore_comp (2)//ghm传入
    val bigComp_reg             = RegInit(0x0.U(2.W))
    // val bigInialised_reg        = RegInit(0x0.U(2.W))
    when(io.bigcore_comp (1,0)===3.U){
      bigComp_reg := bigComp
    }
    val doBigCheckIni           = (cmd.fire && (funct === 0x1b.U))
    val doSetActivatedCheckers  = (cmd.fire && (funct === 0x1c.U))
    val doDebug_bp_checker      = (cmd.fire && (funct === 0x1d.U))
    val doDebug_bp_cdc          = (cmd.fire && (funct === 0x1e.U))
    val doDebug_bp_filter       = (cmd.fire && (funct === 0x1f.U))
    val doDebug_Reset_bp        = (cmd.fire && (funct === 0x2d.U))
    /* R Features */
    val doICCTRL                = (cmd.fire && (funct === 0x70.U))
    val doSetTValue             = (cmd.fire && (funct === 0x71.U))
    val doStoreFromChecker      = (cmd.fire && (funct === 0x72.U))
    val doStoreFromMain         = (cmd.fire && (funct === 0x73.U))
    val doRecord                = (cmd.fire && (funct === 0x75.U))
    val doPerfCtrl              = (cmd.fire && (funct === 0x76.U))
    val doPerfRead              = (cmd.fire && (funct === 0x77.U))

    dontTouch(doCheckBigStatus)
    dontTouch(doBigCheckComp)
    dontTouch(doEvent)
    dontTouch(doMask)
    dontTouch(doSetActivatedCheckers)
    val ghe_packet_in           = RegInit(0x0.U(gh_packet_width.W))
    ghe_packet_in              := io.ghe_packet_in
    val ghe_status_in           = io.ghe_status_in
    val ghe_status_reg          = RegInit(0x0.U(32.W))
    val ghe_event_reg           = RegInit(0x0.U(2.W))
    val ghe_initialised_reg     = RegInit(0x0.U(1.W))

    val ght_status_reg          = RegInit(0.U(32.W))
    val ght_critial_reg         = RegInit(0.U(2.W))
    val ght_monitor_satp_ppn    = RegInit(0.U(44.W))
    val ght_monitor_sys_mode    = RegInit(0.U(2.W))
    val has_monitor_target      = RegInit(0.U(1.W))
    val num_activated_cores     = RegInit(0.U(8.W))

    val ghe_trap_debug          = RegInit(false.B)
    
    // Check status
    // 0b01: empty
    // 0b10: full
    // 0b00: Not empty, not full.
    val channel_status_wire     = Cat(channel_full, channel_empty)

    // Response
    val zeros_channel_status    = WireInit(0.U((xLen-2).W))
    val zeros_63bits            = WireInit(0.U(63.W))
    val zeros_62bits            = WireInit(0.U(62.W))
    val zeros_20bits            = WireInit(0.U(20.W))
    val zeros_1bit              = WireInit(0.U(1.W))
    val zeros_3bit              = WireInit(0.U(3.W))

    val rsu_ready               = io.rsu_status_in===1.U
    val elu_sel                = RegInit(0.U(1.W))
    rd_val                     := MuxCase(0.U, 
                                    Array(doCheck             -> Cat(zeros_channel_status, channel_status_wire), 
                                          doCheckBigStatus    -> ghe_status_reg,
                                          doCheckAgg          -> Cat(zeros_62bits, io.agg_buffer_full, zeros_1bit),
                                          doBigCheckComp      -> Cat(bigComp_reg, rs1_val(15, 0)),//注意这个值
                                          doBigCheckIni       -> Cat(bigInialised),
                                          doGHTBufferCheck    -> Cat(zeros_62bits, io.ght_buffer_status),
                                          doCheckCritial      -> Cat(zeros_62bits, ght_critial_reg(1,0)),
                                          doCheckRSU          -> Cat(rsu_ready, zeros_3bit),
                                          doDebug_bp_checker  -> io.debug_bp_checker,
                                          doDebug_bp_cdc      -> io.debug_bp_cdc,
                                          doDebug_bp_filter   -> io.debug_bp_filter,
                                          doPerfRead          -> io.elu_data_in(63,0),
                                          doGetCsrPerf        -> Cat(0.U(32.W), io.csr_counter_in(rs1_val))
                                          )
                                          )
                                          
    dontTouch(rd_val)
    when (doEvent) {
      ghe_event_reg            := (funct & 0x0F.U);
    }

    when(doTrapDebug){
      ghe_trap_debug          := (funct & 0x0F.U);
    }
    when (doSorR) {
      s_or_r                   := rs1_val(1,0)
    }

    when(doBigCheckIni){
      // printf(midas.targetutils.SynthesizePrintf("Big Init state %d\n",(io.bigcore_comp(2,0) )))
    }
    when (doInitialised){
      // printf(midas.targetutils.SynthesizePrintf("Littel Init state %d\n",(funct )))
      ghe_initialised_reg      := (funct & 0x0F.U);
    }

    when (channel_nearfull) {
      channel_sch_na           := 1.U
    } otherwise {
      when (io.ght_sch_refresh === 1.U){
        channel_sch_na         := 0.U
      } otherwise {
        channel_sch_na         := channel_sch_na
      }
    }
    when(doInitialised&&(funct&0x0F.U)===0x01.U){
      // printf(midas.targetutils.SynthesizePrintf("Ghe State Empty\n"))
      ghe_status_reg             := 0.U 
    }
    .elsewhen(ghe_status_in===0x2.U){
      // printf(midas.targetutils.SynthesizePrintf("Ghe State %d\n",ghe_status_in))
      ghe_status_reg             := ghe_status_in
    }
    
    cmd.ready                  := true.B // Currently, it is always ready, because it is never block
    dontTouch(ghe_event_reg)
    io.ghe_event_out           := Cat(0.U, ghe_initialised_reg, ghe_event_reg, channel_warning)
    io.resp.valid              := cmd.valid && xd
    io.resp.bits.rd            := cmd.bits.inst.rd
    io.resp.bits.data          := rd_val
    io.busy                    := cmd.valid // Later add more situations
    io.interrupt               := false.B


    // Big core register
    // 0: test is not start; 
    // 1: test is started
    // 2: test is finished 
    // 30 - 23: number of activated cores
    // Registers 
    //开始校验
    when (doMask) {
      ght_status_reg           := (funct & 0x0F.U);
      // printf(midas.targetutils.SynthesizePrintf("Check State %d\n",(funct & 0x0F.U)))
    }

    when (doCritical) {
      ght_critial_reg          := rs1_val(1,0)
    }


    when (doSetActivatedCheckers) {
      num_activated_cores      := rs1_val
      // printf(midas.targetutils.SynthesizePrintf("Num Core %d\n",rs1_val))
    }

    val define_monitor_target   = WireInit(0.U(1.W))
    val undefine_monitor_target = WireInit(0.U(1.W))
    define_monitor_target      := Mux((doPID_Cfg && (rs1_val === 1.U)), 1.U, 0.U)
    undefine_monitor_target    := Mux((doPID_Cfg && (rs1_val === 2.U)), 1.U, 0.U)

    when ((define_monitor_target === 1.U) && (undefine_monitor_target === 0.U)) {
      ght_monitor_satp_ppn     := io.ght_satp_ppn
      ght_monitor_sys_mode     := io.ght_sys_mode
      has_monitor_target       := 1.U
    }

    when ((define_monitor_target === 0.U) && (undefine_monitor_target === 1.U)) {
      ght_monitor_satp_ppn     := 0.U
      ght_monitor_sys_mode     := 0.U
      has_monitor_target       := 0.U
    }

    val hit_satp_ppn            = (ght_monitor_satp_ppn === io.ght_satp_ppn)
    val hit_privi               = (ght_monitor_sys_mode === io.ght_sys_mode)

    io.if_correct_process      := Mux((define_monitor_target === 1.U), 1.U, (!ghe_trap_debug)&(hit_satp_ppn & hit_privi & has_monitor_target))

    io.ght_cfg_out             := Mux(doGHT_Cfg, rs1_val(31,0), 0.U) 
    io.ght_cfg_valid           := Mux(doGHT_Cfg, 1.U, 0.U)
    io.debug_bp_reset          := Mux(doDebug_Reset_bp, 1.U, 0.U)
    io.ght_mask_out            := ~(ght_status_reg(0))
    io.ght_status_out          := Cat(0.U, num_activated_cores, ght_status_reg(22,0))


    io.agg_packet_out          := 0.U
    io.agg_core_status         := Cat(0.U, (channel_empty & (ghe_packet_in === 0.U)))
    io.ght_sch_dorefresh       := 0.U
    io.ght_sch_na              := channel_sch_na


    /* R Features */
    val t_Value                = RegInit(200.U(15.W))
    when (doSetTValue){
      t_Value                 := rs1_val(14,0)     
    }

    io.elu_sel_out            := elu_sel
    io.t_value_out            := t_Value
    io.icctrl_out             := Mux(doICCTRL, rs1_val(3,0), 0.U)
    io.arf_copy_out           := doCopy
    io.s_or_r_out             := s_or_r
    io.elu_deq_out            := doDeqELU
    io.record_pc_out          := Mux(doRecordPC, 1.U, 0.U)

    /* Core Trace */
    val core_trace              = RegInit(0.U(2.W))
    when(doCoreTrace){
      // printf(midas.targetutils.SynthesizePrintf("Start Trace %x\n",rs1_val(1,0)))
    }
    core_trace                 := Mux(doCoreTrace, rs1_val(1,0), core_trace)
    io.core_trace_out          := core_trace
    /* Context Record */ 
    val store_from_checker      = RegInit(0.U(1.W))
    when (doStoreFromChecker) {
      store_from_checker       := 1.U
    } 
    
    when (doStoreFromMain) {
      // printf(midas.targetutils.SynthesizePrintf("Store Snapshot from main\n"))
      store_from_checker       := 0.U
    }
    io.record_and_store_out    := Cat(doRecord, store_from_checker)

    val debug_perf_ctrl         = RegInit(1.U(5.W))
    when (doPerfCtrl) {
      debug_perf_ctrl          := rs1_val(4,0)
    }
    io.debug_perf_ctrl         := debug_perf_ctrl
}
