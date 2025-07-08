package freechips.rocketchip.r

import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}
import freechips.rocketchip.guardiancouncil._

// Revisit: add check of the correct_process!
class R_ICIO_kernel(params: R_ICParams) extends Bundle {
  val ic_run_isax                                = Input(UInt(1.W))
  val ic_exit_isax                               = Input(UInt(1.W))
  val ic_syscall                                 = Input(UInt(1.W))
  val ic_syscall_back                            = Input(UInt(1.W))
  val rsu_busy                                   = Input(UInt(1.W))
  //kernel
  val mode_switch                                = Input(Bool())
  val mode_ret                                   = Input(Bool())
  val excp_mode                                  = Input(Bool())
  val satp_switch                                = Input(Bool())
  val interrupt                                  = Input(Bool())
  val if_next_pc_can_ignore                      = Input(Bool())
  val if_next_pc_is_wfi                          = Input(Bool())

  val ic_threshold                               = Input(UInt((params.width_of_ic-1).W))
  val icsl_na                                    = Input(Vec(params.totalnumber_of_cores, UInt(1.W)))
  val ic_incr                                    = Input(UInt((3.W)))
  val if_ready_snap_shot                         = Input(UInt((1.W)))

  val crnt_target                                = Output(UInt(6.W))
  val old_crnt_target                            = Output(UInt(5.W))//used for ERCP
  val if_filtering                               = Output(UInt(1.W)) // 1: filtering; 0: non-filtering
  val if_pipeline_stall                          = Output(UInt(1.W))
  val if_dosnap                                  = Output(UInt(1.W))
  val if_dosnap_priv                             = Output(UInt(1.W))

  val ic_counter                                 = Output(Vec(params.totalnumber_of_cores, UInt(params.width_of_ic.W)))
  val ic_status                                  = Output(Vec(params.totalnumber_of_cores, UInt(1.W)))
  val clear_ic_status                            = Input(Vec(params.totalnumber_of_cores, UInt(1.W)))
  val if_correct_process                         = Input(UInt((1.W)))
  val num_of_checker                             = Input(UInt((8.W)))
  val changing_num_of_checker                    = Input(UInt((1.W)))
  val core_trace                                 = Input(UInt((1.W)))
  val ic_trace                                   = Input(UInt((1.W)))

  //debug signal
  val debug_perf_reset                           = Input(UInt((1.W)))
  val debug_perf_sel                             = Input(UInt(3.W))
  val debug_perf_val                             = Output(UInt(64.W))
  val debug_maincore_status                      = Output(UInt(4.W))
  val debug_perf_nocore                          = Output(Bool())
  val ctrl                                       = Output(UInt(3.W))
  val state                                      = Output(UInt(3.W))

  val shared_CP_CFG                              = Output(UInt(13.W))
}

trait HasR_ICIO_kernel extends BaseModule {
  val params: R_ICParams
  val io = IO(new R_ICIO_kernel(params))
}

class R_IC_kernel (val params: R_ICParams) extends Module with HasR_ICIO_kernel {
  val crnt_target                               = RegInit(0.U(3.W))
  val old_crnt_target                           = RegInit(0.U(5.W))
  val crnt_mask                                 = RegInit(0.U(6.W))
  val nxt_target                                = RegInit(0.U(3.W))

  val ctrl                                      = RegInit(0.U(3.W))
  io.ctrl := ctrl

  val if_filtering                              = WireInit(0.U(1.W))
  val if_pipeline_stall                         = WireInit(0.U(1.W))
  val if_dosnap                                 = WireInit(0.U(1.W))
  val if_dosnap_priv                            = WireInit(0.U(1.W))
  val sch_reset                                 = WireInit(0.U(1.W))
  // val old_crnt_target                           = RegInit(VecInit(Seq.fill(params.totalnumber_of_cores)(0.U(5.W))))
  val ic_counter                                = RegInit(VecInit(Seq.fill(params.totalnumber_of_cores)(0.U(params.width_of_ic.W))))
  val ic_status                                 = RegInit(VecInit(Seq.fill(params.totalnumber_of_cores)(0.U(1.W)))) // 0: idle; 1: running
  val clear_ic_status                           = WireInit(VecInit(Seq.fill(params.totalnumber_of_cores)(0.U(1.W)))) // 0: idle; 1: running
  val debug_delay_check_cnt                     = RegInit(VecInit(Seq.fill(params.totalnumber_of_cores)(0.U(64.W))))
  
  // val ic_check_speed                           = RegInit(VecInit(Seq.fill(params.totalnumber_of_cores-1)(false.B)))



 
  // FSM to control the R_IC
  val fsm_reset :: fsm_presch :: fsm_sch :: fsm_cooling :: fsm_snap :: fsm_trans :: fsm_check :: fsm_postcheck :: Nil = Enum(8)
  val fsm_state                                 = RegInit(fsm_reset)
  val fsm_ini                                   = RegInit(0.U(1.W))
  val cooling_counter                           = RegInit(0.U(4.W))
  val cooling_threshold                         = 0.U
  io.state := fsm_state
  // FPS scheduler
  val sch_result                                = RegInit(0.U(5.W))
  val u_sch_fp                                  = Module (new GHT_SCH_ANYAVILIABLE(GHT_SCH_Params (params.totalnumber_of_cores-1)))
  u_sch_fp.io.core_s                           := 1.U
  u_sch_fp.io.core_e                           := io.num_of_checker
  //只有在前一个阶段才会给调度结构，然后使用寄存器存储
  // u_sch_fp.io.inst_c                           :=  io.ic_run_isax.asBool&&(fsm_state===fsm_presch)||(ctrl === 0.U)&&(fsm_state===fsm_postcheck)// Holding the scheduling results
  u_sch_fp.io.inst_c                           := 1.U
  for (i <- 1 to params.totalnumber_of_cores - 1) {
    u_sch_fp.io.core_na(i-1)                   := ic_status(i)
  }
  sch_result                                   := u_sch_fp.io.sch_dest
  u_sch_fp.io.rst_sch                          := sch_reset

  cooling_counter                              := Mux((fsm_state =/= fsm_cooling), 0.U, Mux(cooling_counter < cooling_threshold, cooling_counter + 1.U, cooling_counter))
  val if_cooled                                 = Mux((cooling_counter >= cooling_threshold) && !io.rsu_busy.asBool, true.B, false.B)
  sch_reset                                    := Mux((fsm_state === fsm_reset) || (io.changing_num_of_checker.asBool), 1.U, 0.U)
  if_dosnap                                    := Mux((fsm_state === fsm_snap) && (io.if_ready_snap_shot.asBool) && !io.if_next_pc_can_ignore, Mux(((ctrl === 2.U) && !(io.mode_switch || io.mode_ret ||io.excp_mode)) || (ctrl === 0.U), io.if_correct_process, Mux(((ctrl === 1.U)) || (ctrl === 3.U), 1.U, 0.U)), 0.U)
  if_dosnap_priv                               := Mux((fsm_state === fsm_snap) && (io.if_ready_snap_shot.asBool) && !io.if_next_pc_can_ignore, Mux(((ctrl === 2.U) && (io.mode_switch || io.mode_ret ||io.excp_mode)) || (ctrl === 4.U), io.if_correct_process, Mux((ctrl === 5.U), 1.U, 0.U)), 0.U)
  // if_dosnap                                    := Mux((fsm_state === fsm_snap) && (io.if_ready_snap_shot.asBool) && io.if_correct_process.asBool, 1.U, 0.U)
  //这两个信号的作用？
 val if_t_and_na                               = Mux(((io.ic_exit_isax.asBool || io.mode_switch || io.if_next_pc_is_wfi || io.satp_switch || io.mode_ret || (ic_counter(crnt_target) >= io.ic_threshold) || io.icsl_na(crnt_target).asBool) && (ic_status(sch_result).asBool)), 1.U, 0.U)
  val if_t_and_a                                = Mux(((io.ic_exit_isax.asBool || io.mode_switch || io.if_next_pc_is_wfi || io.satp_switch || io.mode_ret || (ic_counter(crnt_target) >= io.ic_threshold) || io.icsl_na(crnt_target).asBool) && (!ic_status(sch_result).asBool)), 1.U, 0.U)
  fsm_ini                                      := Mux(fsm_state === fsm_reset, 1.U, Mux(fsm_state === fsm_presch, fsm_ini, 0.U))
  dontTouch(if_t_and_na)
  dontTouch(if_t_and_a)
  val ic_exit_isax_buffer                       = RegInit(0.U(1.W))
  val end                                       = RegInit(0.U(1.W))
  ic_exit_isax_buffer                          := Mux(fsm_state === fsm_reset, 0.U, Mux(io.ic_exit_isax.asBool && fsm_state =/= fsm_check, 1.U, ic_exit_isax_buffer))

  switch (fsm_state) {
    is (fsm_reset){ // 000
      end                                       := 0.U
      ctrl                                      := 2.U
      crnt_target                               := 0.U
      crnt_mask                                 := 0.U
      nxt_target                                := 0.U
      if_filtering                              := 0.U
      if_pipeline_stall                         := 0.U
      for (i <- 0 to params.totalnumber_of_cores - 1) {
        ic_status(i)                            := Mux(clear_ic_status(i).asBool, 0.U, ic_status(i))
        ic_counter(i)                           := Mux(clear_ic_status(i).asBool, 0.U, ic_counter(i))
      }
      fsm_state                                 := fsm_presch
    }

    is (fsm_presch){ // 001
      end                                       := end
      ctrl                                      := 2.U
      crnt_target                               := crnt_target
      crnt_mask                                 := crnt_mask
      nxt_target                                := nxt_target
      if_filtering                              := 0.U
      if_pipeline_stall                         := Mux(fsm_ini.asBool, 0.U, io.if_correct_process.asBool && !io.if_next_pc_can_ignore)
      for (i <- 0 to params.totalnumber_of_cores - 1) {
        ic_status(i)                            := Mux(clear_ic_status(i).asBool, 0.U, ic_status(i))
        ic_counter(i)                           := Mux(clear_ic_status(i).asBool, 0.U, ic_counter(i))
      }
      fsm_state                                 := Mux(fsm_ini.asBool, Mux(io.ic_run_isax.asBool, fsm_sch, fsm_presch), fsm_sch)
    }

    is (fsm_sch){ // 010
      end                                       := end
      // ctrl                                      := Mux(ctrl === 0.U, Mux(io.ic_syscall.asBool, 1.U, ctrl), ctrl)
      ctrl                                      := Mux((io.mode_switch || io.excp_mode) && if_t_and_a.asBool && (ctrl === 0.U), 4.U, ctrl)
      crnt_target                               := crnt_target
      crnt_mask                                 := crnt_mask
      nxt_target                                := Mux(!ic_status(sch_result).asBool && io.if_correct_process.asBool, sch_result, nxt_target)
      if_filtering                              := 0.U
      if_pipeline_stall                         := io.if_correct_process.asBool && !io.if_next_pc_can_ignore
      for (i <- 0 to params.totalnumber_of_cores - 1) {
        ic_status(i)                            := Mux(clear_ic_status(i).asBool, 0.U, ic_status(i))
        ic_counter(i)                           := Mux(clear_ic_status(i).asBool, 0.U, ic_counter(i))
      }
      // fsm_state                                 := Mux(!ic_status(sch_result).asBool && io.if_correct_process.asBool, fsm_cooling, Mux(io.ic_syscall.asBool, fsm_cooling, fsm_sch))
      fsm_state                                 := Mux(!ic_status(sch_result).asBool && io.if_correct_process.asBool && !io.if_next_pc_can_ignore, fsm_cooling, fsm_sch)
    }

    is (fsm_cooling){ // 011
      end                                       := end
      ctrl                                      := Mux((io.mode_switch || io.excp_mode) && if_t_and_a.asBool && (ctrl === 0.U), 4.U, ctrl)
      crnt_target                               := Mux(if_cooled, nxt_target, crnt_target)
      crnt_mask                                 := crnt_mask
      nxt_target                                := nxt_target
      if_filtering                              := 0.U
      if_pipeline_stall                         := io.if_correct_process.asBool && !io.if_next_pc_can_ignore
      for (i <- 0 to params.totalnumber_of_cores - 1) {
        ic_status(i)                            := Mux(clear_ic_status(i).asBool, 0.U, ic_status(i))
        ic_counter(i)                           := Mux(clear_ic_status(i).asBool, 0.U, ic_counter(i))
      }
      fsm_state                                 := Mux(if_cooled && !io.if_next_pc_can_ignore, fsm_snap, fsm_cooling)
    }

    is (fsm_snap){ // 100
      end                                       := end
      // ctrl                                      := Mux(ctrl === 0.U, Mux(io.ic_syscall.asBool, 1.U, ctrl), ctrl)
      ctrl                                      := Mux((io.mode_switch || io.excp_mode) && if_t_and_a.asBool && (ctrl === 0.U), 4.U, ctrl)
      crnt_target                               := crnt_target
      crnt_mask                                 := Mux((ctrl === 2.U) || (ctrl === 0.U) || (ctrl === 4.U), Mux(io.if_ready_snap_shot.asBool && io.if_correct_process.asBool && !io.if_next_pc_can_ignore, Cat(ctrl, crnt_target), crnt_mask), Mux(io.if_ready_snap_shot.asBool && !io.if_next_pc_can_ignore, Cat(ctrl, crnt_target), crnt_mask))      
      // crnt_mask                                 := Mux((ctrl === 2.U) || (ctrl === 0.U) || (ctrl === 4.U), Mux(io.if_ready_snap_shot.asBool && io.if_correct_process.asBool, Cat(ctrl, crnt_target), crnt_mask), Mux(io.if_ready_snap_shot.asBool, Cat(ctrl, crnt_target), crnt_mask))      
      nxt_target                                := nxt_target
      if_filtering                              := 0.U
      if_pipeline_stall                         := io.if_correct_process.asBool && !io.if_next_pc_can_ignore
      for (i <- 0 to params.totalnumber_of_cores - 1) {
        ic_status(i)                            := Mux(clear_ic_status(i).asBool, 0.U, Mux((crnt_target === i.U) && (ctrl(0) === 0.U) && io.if_ready_snap_shot.asBool && io.if_correct_process.asBool && !io.if_next_pc_can_ignore, 1.U, ic_status(i)))
        ic_counter(i)                           := Mux(clear_ic_status(i).asBool, 0.U, ic_counter(i))
      }
      // fsm_state                                 := Mux((ctrl === 2.U) || (ctrl === 0.U), Mux(io.if_ready_snap_shot.asBool && io.if_correct_process.asBool, fsm_trans, fsm_snap), Mux(io.if_ready_snap_shot.asBool, fsm_trans, fsm_snap))
      fsm_state                                 := Mux((ctrl === 2.U) || (ctrl === 0.U) || (ctrl === 4.U), Mux(io.if_ready_snap_shot.asBool && io.if_correct_process.asBool && !io.if_next_pc_can_ignore, fsm_trans, fsm_snap), Mux(io.if_ready_snap_shot.asBool && !io.if_next_pc_can_ignore, fsm_trans, fsm_snap))
    }

    is (fsm_trans){ // 101 Do we really need a signal to transmit the snapshot? 
      end                                       := Mux(!end.asBool && (ic_exit_isax_buffer.asBool || io.ic_exit_isax.asBool), Mux(!io.rsu_busy.asBool, 1.U, end), end)
      ctrl                                      := Mux(!end.asBool && (ic_exit_isax_buffer.asBool || io.ic_exit_isax.asBool), Mux(!io.rsu_busy.asBool, 3.U, ctrl), ctrl)
      crnt_target                               := crnt_target
      crnt_mask                                 := crnt_mask
      nxt_target                                := nxt_target
      if_filtering                              := 0.U
      if_pipeline_stall                         := io.if_correct_process.asBool && !io.if_next_pc_can_ignore
      for (i <- 0 to params.totalnumber_of_cores - 1) {
        ic_status(i)                            := Mux(clear_ic_status(i).asBool, 0.U, ic_status(i))
        ic_counter(i)                           := Mux(clear_ic_status(i).asBool, 0.U, ic_counter(i))
      }
      fsm_state                                 := Mux(end.asBool, Mux(!io.rsu_busy.asBool, fsm_reset, fsm_trans),
                                                   Mux(ic_exit_isax_buffer.asBool || io.ic_exit_isax.asBool, Mux(!io.rsu_busy.asBool, fsm_postcheck, fsm_trans),
                                                   Mux(ctrl === 3.U, Mux(!io.rsu_busy.asBool, fsm_reset, fsm_trans), 
                                                   Mux(ctrl === 1.U || ctrl === 5.U, fsm_presch, fsm_check))))
    }

    is (fsm_check){ // 110，如果接收到小核心的lsl满，会停止提交，小核心的lsl满
      end                                       := end
      ctrl                                      := Mux(io.ic_exit_isax.asBool, 3.U, Mux(if_t_and_na.asBool && !(io.mode_switch || io.mode_ret || io.excp_mode), 1.U, Mux((if_t_and_na.asBool && (io.mode_switch || io.if_next_pc_is_wfi || io.mode_ret || io.excp_mode)) || io.satp_switch, 5.U, Mux((io.mode_switch || io.if_next_pc_is_wfi || io.mode_ret || io.excp_mode) && if_t_and_a.asBool, 4.U, Mux(if_t_and_a.asBool, 0.U, ctrl)))))
      crnt_target                               := crnt_target
      crnt_mask                                 := crnt_mask
      nxt_target                                := nxt_target 
      if_filtering                              := Mux(io.ic_exit_isax.asBool || io.ic_syscall.asBool || (ic_counter(crnt_target) >= io.ic_threshold) || io.icsl_na(crnt_target).asBool, 0.U, 1.U)
      if_pipeline_stall                         := Mux((io.ic_exit_isax.asBool || (io.mode_switch || io.mode_ret) || (ic_counter(crnt_target) >= io.ic_threshold) || io.icsl_na(crnt_target).asBool || io.satp_switch) && !io.if_next_pc_can_ignore, 1.U, 0.U)
      for (i <- 0 to params.totalnumber_of_cores - 1) {
        ic_status(i)                            := Mux(clear_ic_status(i).asBool, 0.U,  ic_status(i))
        ic_counter(i)                           := Mux(clear_ic_status(i).asBool, 0.U,  Mux((crnt_target === i.U) && (io.if_correct_process.asBool), (ic_counter(i) + io.ic_incr), ic_counter(i)))
      }
      fsm_state                                 := Mux(io.ic_exit_isax.asBool || (io.mode_switch || io.if_next_pc_is_wfi || io.mode_ret) || (ic_counter(crnt_target) >= io.ic_threshold) || io.icsl_na(crnt_target).asBool || io.satp_switch, fsm_postcheck, fsm_check)
    }

    is (fsm_postcheck){ // 111
      end                                       := end
      ctrl                                      := ctrl
      crnt_target                               := crnt_target
      crnt_mask                                 := crnt_mask
      nxt_target                                := nxt_target 
      if_filtering                              := 0.U
      if_pipeline_stall                         := io.if_correct_process.asBool && !io.if_next_pc_can_ignore
      for (i <- 0 to params.totalnumber_of_cores - 1) {
        ic_status(i)                            := Mux(clear_ic_status(i).asBool, 0.U,  ic_status(i))
        ic_counter(i)                           := Mux(clear_ic_status(i).asBool, 0.U,  Mux((crnt_target === i.U), (ic_counter(i) | 0x8000.U), ic_counter(i)))
      }
      fsm_state                                 := Mux((ctrl === 0.U) || (ctrl === 4.U), fsm_sch, fsm_cooling)
    }
  }

  //给出回应
  io.ic_counter(0):=0.U
  //4周期一传输，然后自动上寄存器
  if(GH_GlobalParams.IF_CDC_OPEN){
    val cdc_cnt = RegInit(0.U(2.W))
    ///////////////////////////////
    cdc_cnt := cdc_cnt+1.U
    for (i <- 0 until params.totalnumber_of_cores - 1) {
      // ic_check_speed(i)         :=Mux(io.if_big_complete_req(i).asBool, true.B,Mux((ic_counter(i+1) &0x8000.U)=/=0.U,false.B,ic_check_speed(i)))
      // io.if_big_complete_ack(i) := ic_check_speed(i)&&((ic_counter(i+1) &0x8000.U)=/=0.U)
      io.ic_counter(i+1)        := Mux(cdc_cnt===3.U,ic_counter(i+1),0.U)
    }
  }else{
    for (i <- 0 until params.totalnumber_of_cores - 1) {
      io.ic_counter(i+1)        := ic_counter(i+1)
    }
  }

  // dontTouch(ic_check_speed)
  if (GH_GlobalParams.GH_DEBUG == 1) {
    // when ((io.ic_incr =/= 0.U) && (fsm_state === fsm_check) && (io.core_trace.asBool)) {
    //   printf(midas.targetutils.SynthesizePrintf("sl_counter=[%x]\n", (ic_counter(crnt_target)+io.ic_incr)))
    // }




    val fsm_state_delay                          = RegInit(fsm_reset)
    fsm_state_delay                              := fsm_state
    val debug_clear_status                       = Wire(Vec(params.totalnumber_of_cores, Bool()))
    for (i <- 0 until params.totalnumber_of_cores) {
      debug_clear_status(i) := clear_ic_status(i).asBool
    }
    // when(debug_clear_status.reduce(_|_)&& (io.ic_trace.asBool)){
    //   printf(midas.targetutils.SynthesizePrintf("fsm_state[%x] Little Finish[%x %x %x %x]\n", fsm_state,clear_ic_status(1),clear_ic_status(2),clear_ic_status(3),clear_ic_status(4)))
    // }
    // when ((fsm_state_delay =/= fsm_state) && (io.ic_trace.asBool)) {
    //   printf(midas.targetutils.SynthesizePrintf("fsm_state=[%x]\n", fsm_state))
    // }
    // when(fsm_state_delay===fsm_check&&fsm_state===fsm_postcheck&&io.core_trace.asBool){
    //   printf(midas.targetutils.SynthesizePrintf("Boom: Finish[%x] Waiting Little Finish=[v %x cnt %x v %x cnt %x v %x cnt %x v %x cnt %x ]\n",crnt_target,ic_status(1),ic_counter(1),ic_status(2),ic_counter(2),ic_status(3),ic_counter(3),ic_status(4),ic_counter(4) ))
    // }
    // when(io.core_trace.asBool&&if_cooled&&(fsm_state===fsm_cooling)) {
    //   printf(midas.targetutils.SynthesizePrintf("Big Sch Result=[%x] old Result=[%x]\n", nxt_target,old_crnt_target))
    // }
  }


  // val debug_delay_check_cnt = RegInit(0.U(64.W))
  // for(i<- 0 until params.totalnumber_of_cores){
  //   debug_delay_check_cnt(i)                 := Mux(clear_ic_status(i).asBool, 0.U, Mux(ic_status(i).asBool && (fsm_state =/= fsm_check), debug_delay_check_cnt(i) + 1.U, debug_delay_check_cnt(i)))
  //   when(clear_ic_status(i).asBool){
  //     printf("C[%d]debug_delay_check_cnt=%x\n", i.U, debug_delay_check_cnt(i))
  //   }
  // }

  
  old_crnt_target                               := Mux(if_cooled&&(fsm_state===fsm_cooling),crnt_target,old_crnt_target)
  io.crnt_target                                := crnt_mask
  io.if_filtering                               := if_filtering & io.if_correct_process // Not used yet
  io.if_pipeline_stall                          := if_pipeline_stall & io.if_correct_process
  io.if_dosnap                                  := if_dosnap
  io.if_dosnap_priv                             := if_dosnap_priv
  io.old_crnt_target                            := old_crnt_target

  
  io.ic_status                                  := ic_status
  
  for (i <- 0 to params.totalnumber_of_cores - 1){
    clear_ic_status(i)                          := io.clear_ic_status(i)
  }
  var nocore_available                           = WireInit(1.U(1.W))
  for (i <- 1 to params.totalnumber_of_cores - 1){
    nocore_available                             = Mux(i.U<io.num_of_checker,nocore_available & ic_status(i),nocore_available)
  }
  io.debug_perf_nocore                          := nocore_available.asBool&&(io.if_pipeline_stall.asBool)
  val debug_perf_CCounter                        = RegInit(0.U(GH_GlobalParams.GH_WIDITH_PERF.W))
  val debug_perf_BCounter                        = RegInit(0.U(GH_GlobalParams.GH_WIDITH_PERF.W))
  val debug_perf_SchState                        = RegInit(0.U(GH_GlobalParams.GH_WIDITH_PERF.W))
  val debug_perf_CheckState                      = RegInit(0.U(GH_GlobalParams.GH_WIDITH_PERF.W))
  val debug_perf_OtherThread                     = RegInit(0.U(GH_GlobalParams.GH_WIDITH_PERF.W))
  val debug_perf_SchState_Allbusy                = RegInit(0.U(GH_GlobalParams.GH_WIDITH_PERF.W))
  val debug_perf_SchState_OT                     = RegInit(0.U(GH_GlobalParams.GH_WIDITH_PERF.W))



  val if_blocked_bySched                         = WireInit(false.B)
  if_blocked_bySched                            := ((fsm_state === fsm_sch) && io.if_correct_process.asBool) && ic_status(sch_result).asBool

  debug_perf_CCounter                           := Mux(io.debug_perf_reset.asBool, 0.U, debug_perf_CCounter + 1.U)
  debug_perf_BCounter                           := Mux(io.debug_perf_reset.asBool, 0.U, Mux(if_blocked_bySched && !nocore_available.asBool, debug_perf_BCounter + 1.U, debug_perf_BCounter))
  debug_perf_SchState_Allbusy                   := Mux(io.debug_perf_reset.asBool, 0.U, Mux(if_blocked_bySched && nocore_available.asBool, debug_perf_SchState_Allbusy + 1.U, debug_perf_SchState_Allbusy))
  debug_perf_SchState                           := Mux(io.debug_perf_reset.asBool, 0.U, Mux(fsm_state === fsm_sch, debug_perf_SchState + 1.U, debug_perf_SchState))
  debug_perf_CheckState                         := Mux(io.debug_perf_reset.asBool, 0.U, Mux(fsm_state === fsm_check, debug_perf_CheckState + 1.U, debug_perf_CheckState))
  debug_perf_OtherThread                        := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_sch) && (!io.if_correct_process.asBool), debug_perf_OtherThread + 1.U, debug_perf_OtherThread))
  debug_perf_SchState_OT                        := Mux(io.debug_perf_reset.asBool, 0.U, Mux(!io.if_correct_process.asBool, debug_perf_SchState_OT + 1.U, debug_perf_SchState_OT))


  io.debug_perf_val                             := Mux(io.debug_perf_sel === 7.U, debug_perf_CCounter, 
                                                   Mux(io.debug_perf_sel === 1.U, debug_perf_BCounter,
                                                   Mux(io.debug_perf_sel === 2.U, debug_perf_SchState, 
                                                   Mux(io.debug_perf_sel === 3.U, debug_perf_CheckState,
                                                   Mux(io.debug_perf_sel === 4.U, debug_perf_OtherThread, 
                                                   Mux(io.debug_perf_sel === 5.U, debug_perf_SchState_Allbusy, 
                                                   Mux(io.debug_perf_sel === 6.U, debug_perf_SchState_OT, 0.U)))))))

  io.debug_maincore_status                      := Mux(!io.if_correct_process.asBool, 3.U,
                                                   Mux(fsm_state === fsm_sch, 1.U,
                                                   Mux(fsm_state === fsm_check, 2.U, 0.U)))
  // io.debug_perf_val                             := 0.U

  val one                                        = WireInit(1.U(1.W))
  val one_fourbits                               = WireInit(1.U(4.W))
  val seven_threebits                            = WireInit(7.U(3.W))
  val core_bitmap                                = WireInit(0.U(4.W))
  val cp_bitmap                                  = WireInit(0.U(8.W))
  

  core_bitmap                                   := (one_fourbits << (crnt_target - 1.U)) | (one_fourbits << (sch_result - 1.U))
  cp_bitmap                                     := Cat(sch_result, seven_threebits)
  

  io.shared_CP_CFG                              := Mux(((fsm_state === fsm_sch) && !ic_status(sch_result).asBool && io.if_correct_process.asBool && (ctrl === 0.U)), Cat(one, cp_bitmap, core_bitmap), 0.U)
}
