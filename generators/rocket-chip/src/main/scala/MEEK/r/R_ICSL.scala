package freechips.rocketchip.r

import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}
import freechips.rocketchip.guardiancouncil._
import scala.util.matching.Regex

case class R_ICSLParams(
  width_of_ic: Int
)

class R_ICSLIO(params: R_ICSLParams) extends Bundle {
  val ic_counter                                 = Input(UInt((params.width_of_ic).W))
  val icsl_run                                   = Input(UInt(1.W))
  // val icsl_ack                                   = Input(Bool())
  // val big_switch                                 = Input(Bool())
  val cdc_empty                                  = Input(Bool())
  val lsl_empty                                  = Input(Bool())
  val new_commit                                 = Input(UInt(1.W))
  val if_correct_process                         = Input(UInt(1.W))
  val returned_to_special_address_valid          = Input(UInt(1.W))
  ///////////not used////
  // val if_big_complete                            = Output(Bool())
  // val big_complete                               = Input(Bool()) 
  //////////////////////
  // val kill_pipe                                  = Output(Bool())
  val icsl_checkermode                           = Output(UInt(1.W))
  val clear_ic_status                            = Output(UInt(1.W))
  val if_overtaking                              = Output(UInt(1.W))
  val if_overtaking_next_cycle                   = Output(UInt(1.W))
  val if_ret_special_pc                          = Output(UInt(1.W))
  val if_rh_cp_pc                                = Output(UInt(1.W))
  val if_check_completed                         = Input(UInt(1.W))
  val icsl_status                                = Output(UInt(2.W))
  val debug_sl_counter                           = Output(UInt(params.width_of_ic.W))
  val core_trace                                 = Input(UInt(1.W))
  val something_inflight                         = Input(UInt(1.W))
  val num_valid_insts_in_pipeline                = Input(UInt(4.W))
  val icsl_stalld                                = Output(Bool())
  val core_id                                    = Input(UInt(4.W))

  val check_done                                 = Output(Bool())
  val debug_perf_reset                           = Input(UInt(1.W))
  val debug_perf_sel                             = Input(UInt(4.W))
  val debug_perf_val                             = Output(UInt(64.W))   
  val debug_perf_blocking_DIV                    = Input(UInt(64.W))
  val debug_perf_bp_mispred                      = Input(UInt(64.W))
  val debug_perf_icache_miss                     = Input(UInt(64.W))
  val debug_perf_bp_inst                         = Input(UInt(64.W))
  val debug_starting_CPS                         = Input(UInt(1.W))
  val main_core_status                           = Input(UInt(4.W))
  val checker_core_status                        = Output(UInt(4.W))
  val st_deq                                     = Input(UInt(1.W))
  val ld_deq                                     = Input(UInt(1.W))
}

trait HasR_ICSLIO extends BaseModule {
  val params: R_ICSLParams
  val io = IO(new R_ICSLIO(params))
}

class R_ICSL (val params: R_ICSLParams) extends Module with HasR_ICSLIO {
  val ic_counter_shadow                          = RegInit(0.U((params.width_of_ic-1).W))
  val ic_counter_done                            = RegInit(0.U(1.W))
  val icsl_run                                   = WireInit(0.U(1.W))
  
  val icsl_checkermode                           = WireInit(0.U(1.W))
  val clear_ic_status                            = WireInit(0.U(1.W))
  val if_overtaking                              = RegInit(0.U(1.W))
  val if_ret_special_pc                          = RegInit(0.U(1.W))
  val if_rh_cp_pc                                = WireInit(0.U(1.W))

  val sl_counter                                 = RegInit(0.U(params.width_of_ic.W))
  val if_instants_completion                     = Mux((io.if_correct_process.asBool && io.new_commit.asBool && ((sl_counter + 1.U) >= ic_counter_shadow) && ic_counter_done.asBool), 1.U, 0.U)
  val if_slow_completion                         = Mux((io.if_correct_process.asBool && (sl_counter >= ic_counter_shadow) && ic_counter_done.asBool), true.B, false.B)
  val if_just_overtaking                         = Mux((io.if_correct_process.asBool && io.new_commit.asBool && ((sl_counter + 1.U) >= ic_counter_shadow)), 1.U, 0.U)
  val ic_counter_reg                             = RegInit(0.U((params.width_of_ic).W))


  val fsm_reset :: fsm_nonchecking :: fsm_checking :: fsm_postchecking :: Nil = Enum(4)
  val fsm_state                                  = RegInit(fsm_reset)
  ic_counter_reg                                 := Mux(io.ic_counter=/=0.U, io.ic_counter, ic_counter_reg)
  switch (fsm_state) {
    is (fsm_reset) { // 00
      sl_counter                                := 0.U
      clear_ic_status                           := 1.U
      icsl_checkermode                          := 0.U
      if_rh_cp_pc                               := 0.U
      fsm_state                                 := fsm_nonchecking
    }

    is (fsm_nonchecking) { //01
      sl_counter                                := sl_counter
      clear_ic_status                           := 0.U
      icsl_checkermode                          := 0.U
      if_rh_cp_pc                               := 0.U
      fsm_state                                 := Mux(icsl_run.asBool, fsm_checking, fsm_nonchecking)
    }

    is (fsm_checking){ //10
      sl_counter                                := Mux(io.if_correct_process.asBool && io.new_commit.asBool, sl_counter + 1.U, sl_counter)
      clear_ic_status                           := 0.U
      icsl_checkermode                          := Mux(io.if_correct_process.asBool, 1.U, 0.U)
      if_rh_cp_pc                               := 0.U
      fsm_state                                 := Mux((if_instants_completion.asBool || if_slow_completion.asBool) && (!io.something_inflight), fsm_postchecking, fsm_checking)
    }


    is (fsm_postchecking){
      // sl_counter                                := sl_counter
      sl_counter                                := Mux(io.if_check_completed.asBool, 0.U, sl_counter)
      clear_ic_status                           := 0.U
      icsl_checkermode                          := Mux(io.if_correct_process.asBool, 1.U, 0.U)
      if_rh_cp_pc                               := 1.U
      fsm_state                                 := Mux(io.returned_to_special_address_valid.asBool, fsm_reset, fsm_postchecking)
    }

  }

  val fsm_state_delay                            = RegInit(fsm_reset)
  fsm_state_delay                               := fsm_state
  if (GH_GlobalParams.GH_DEBUG == 1) {
    val ic_counter_shadow_delay                  = RegInit(0.U((params.width_of_ic-1).W))
    ic_counter_shadow_delay                     := ic_counter_shadow
    val ic_cnt_done_reg                         = RegNext(ic_counter_done)
    when ((fsm_state_delay =/= fsm_state) && (io.core_trace.asBool)) {
      printf(midas.targetutils.SynthesizePrintf("C%d:fsm_state=[%x] sl_cnt[%x]\n", io.core_id, fsm_state,sl_counter))
    }
    when(ic_counter_done.asBool&&(ic_cnt_done_reg===0.U)&&(io.core_trace.asBool)){
      printf(midas.targetutils.SynthesizePrintf("C%d:Boom is done=[%x]\n", io.core_id, ic_counter_shadow))
    }
  
  }

  // io.check_done                                 := (if_instants_completion.asBool || if_slow_completion.asBool) && (!io.something_inflight)&&(fsm_state===fsm_checking)
  val check_done = RegInit(false.B)
  when(io.if_check_completed.asBool){
    check_done := false.B
  }.elsewhen((if_instants_completion.asBool || if_slow_completion.asBool) && (!io.something_inflight) && (icsl_checkermode.asBool) && !(io.returned_to_special_address_valid.asBool)){
    check_done := true.B
  }
  io.check_done := check_done

  ic_counter_shadow                             := ic_counter_reg(params.width_of_ic-2,0) + 1.U // The checker core requires to run one more insts due to the custom jump
  ic_counter_done                               := ic_counter_reg(params.width_of_ic-1)
  if_overtaking                                 := Mux((if_just_overtaking.asBool ||  (sl_counter >= ic_counter_shadow)), 1.U, 0.U)
  val if_overtaking_next_cycle                   = WireInit(0.U(1.W))
  if_overtaking_next_cycle                      := Mux((if_just_overtaking.asBool ||  (sl_counter >= ic_counter_shadow)), 1.U, 0.U)
  

  // if_ret_special_pc                             := Mux(io.if_check_completed.asBool && icsl_checkermode.asBool, 1.U, 0.U)
  if_ret_special_pc                             := Mux(if_rh_cp_pc.asBool && icsl_checkermode.asBool, 1.U, 0.U)
  
  icsl_run                                      := io.icsl_run
  io.clear_ic_status                            := clear_ic_status
  io.icsl_checkermode                           := icsl_checkermode
  io.if_overtaking                              := (icsl_checkermode & if_overtaking)
  io.if_overtaking_next_cycle                   := (icsl_checkermode & if_overtaking_next_cycle)
  io.if_ret_special_pc                          := if_ret_special_pc
  io.if_rh_cp_pc                                := if_rh_cp_pc
  io.icsl_status                                := Mux(fsm_state === fsm_nonchecking, 1.U, 0.U)
  io.debug_sl_counter                           := sl_counter
  
  val icsl_stalld_fsm_checking                   = Reg(Bool())
  val icsl_stalld_fsm_postchecking               = Reg(Bool())
  icsl_stalld_fsm_checking                      := ((sl_counter + io.num_valid_insts_in_pipeline) >= ic_counter_shadow)
  // icsl_stalld_fsm_postchecking                  := (io.num_valid_insts_in_pipeline > 0.U) || (!if_ret_special_pc.asBool)
  icsl_stalld_fsm_postchecking                  := (io.num_valid_insts_in_pipeline > 0.U)
  io.icsl_stalld                                := Mux(icsl_checkermode.asBool,
                                                   Mux(fsm_state === fsm_checking, icsl_stalld_fsm_checking, 
                                                   Mux(fsm_state === fsm_postchecking, icsl_stalld_fsm_postchecking, false.B)), false.B)
  /* Debug Perf */
  val checking_cycle                            = RegInit(0.U(64.W))
  val checking_inst                             = RegInit(0.U(64.W))

  dontTouch(checking_cycle)
  dontTouch(checking_inst)


  checking_cycle                                := Mux(io.if_correct_process.asBool && fsm_state===fsm_checking, checking_cycle + 1.U, checking_cycle)
  checking_inst                                 := Mux(io.if_correct_process.asBool && fsm_state===fsm_checking && io.new_commit.asBool, checking_inst + 1.U, checking_inst)
  // when()
  // val debug_perf_fsm_reset                       = RegInit(0.U(64.W))
  // val debug_perf_fsm_nonchecking                 = RegInit(0.U(64.W))
  // val debug_perf_fsm_checking                    = RegInit(0.U(64.W))
  // val debug_perf_fsm_fsm_postchecking            = RegInit(0.U(64.W))
  val debug_perf_howmany_checkpoints             = RegInit(0.U(64.W))
  val debug_perf_checking                        = RegInit(0.U(64.W))
  val debug_perf_postchecking                    = RegInit(0.U(64.W))
  val debug_perf_otherthread                     = RegInit(0.U(64.W))
  val debug_perf_nonchecking                     = RegInit(0.U(64.W))
  val debug_perf_nonchecking_OtherThreads        = RegInit(0.U(64.W))
  val debug_perf_nonchecking_MOtherThreads       = RegInit(0.U(64.W))
  val debug_perf_nonchecking_MSched              = RegInit(0.U(64.W))
  val debug_perf_nonchecking_MCheck              = RegInit(0.U(64.W))
  val debug_perf_num_st                          = RegInit(0.U(64.W))
  val debug_perf_num_ld                          = RegInit(0.U(64.W))
  val debug_L_timer_worest                       = RegInit(0.U(64.W))

  val debug_perf_insts                           = RegInit(0.U(64.W))
  val debug_perf_CPStrans                        = RegInit(0.U(64.W))
  val debug_perf_CPStrans_ifGo                   = RegInit(0.U(1.W))

  debug_perf_howmany_checkpoints                := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_reset) && (fsm_state_delay === fsm_postchecking), debug_perf_howmany_checkpoints + 1.U, debug_perf_howmany_checkpoints))
  debug_perf_checking                           := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_checking), debug_perf_checking + 1.U, debug_perf_checking))
  debug_perf_postchecking                       := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_postchecking), debug_perf_postchecking + 1.U, debug_perf_postchecking))
  debug_perf_otherthread                        := Mux(io.debug_perf_reset.asBool, 0.U, Mux(((fsm_state === fsm_checking) || (fsm_state === fsm_postchecking)) && (!io.if_correct_process.asBool),  debug_perf_otherthread + 1.U, debug_perf_otherthread))
  debug_perf_nonchecking                        := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_nonchecking), debug_perf_nonchecking + 1.U, debug_perf_nonchecking))
  
  /*
  debug_perf_nonchecking_OtherThreads           := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_nonchecking) && (!io.if_correct_process.asBool), debug_perf_nonchecking_OtherThreads + 1.U, debug_perf_nonchecking_OtherThreads))
  debug_perf_nonchecking_MOtherThreads          := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_nonchecking) && (io.if_correct_process.asBool) && (io.main_core_status === 3.U), debug_perf_nonchecking_MOtherThreads + 1.U, debug_perf_nonchecking_MOtherThreads))
  debug_perf_nonchecking_MCheck                 := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_nonchecking) && (io.if_correct_process.asBool) && (io.main_core_status === 2.U), debug_perf_nonchecking_MCheck + 1.U, debug_perf_nonchecking_MCheck))
  debug_perf_insts                              := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_checking) && io.new_commit.asBool, debug_perf_insts + 1.U, debug_perf_insts))*/
  debug_perf_CPStrans_ifGo                      := Mux(io.debug_starting_CPS.asBool, 1.U, Mux((fsm_state === fsm_checking), 0.U, debug_perf_CPStrans_ifGo))
  debug_perf_CPStrans                           := Mux(io.debug_perf_reset.asBool, 0.U, Mux(debug_perf_CPStrans_ifGo.asBool, debug_perf_CPStrans + 1.U, debug_perf_CPStrans))
  // debug_perf_nonchecking_MSched                 := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_nonchecking) && (io.if_correct_process.asBool) && (io.main_core_status === 1.U), debug_perf_nonchecking_MSched + 1.U, debug_perf_nonchecking_MSched))
  



  debug_perf_num_st                             := Mux(io.debug_perf_reset.asBool, 0.U, debug_perf_num_st + io.st_deq)
  debug_perf_num_ld                             := Mux(io.debug_perf_reset.asBool, 0.U, debug_perf_num_ld + io.ld_deq)

  val u_channel                                  = Module(new GH_MemFIFO(FIFOParams (32, 50)))
  val debug_L_timer                              = RegInit(0.U(64.W))
  debug_L_timer                                 := Mux(fsm_state === fsm_nonchecking, 0.U, Mux(fsm_state === fsm_checking, debug_L_timer + 1.U, debug_L_timer))
  u_channel.io.enq_valid                        := Mux((fsm_state === fsm_postchecking) && (fsm_state_delay === fsm_checking) && ((debug_perf_howmany_checkpoints & 0x1FF.U) === 0x00.U), true.B, false.B)
  u_channel.io.enq_bits                         := debug_L_timer
  val debug_perf_sel_delay                       = RegInit(0.U(4.W))
  debug_perf_sel_delay                          := io.debug_perf_sel
  u_channel.io.deq_ready                        := (io.debug_perf_sel === 14.U) && (debug_perf_sel_delay === 15.U)

  debug_L_timer_worest                          := Mux(io.debug_perf_reset.asBool, 0.U, Mux(debug_L_timer > debug_L_timer_worest, debug_L_timer, debug_L_timer_worest))


  io.debug_perf_val                             := Mux(io.debug_perf_sel === 7.U, debug_perf_howmany_checkpoints, 
                                                   Mux(io.debug_perf_sel === 1.U, debug_perf_checking,
                                                   Mux(io.debug_perf_sel === 2.U, debug_perf_postchecking,
                                                   Mux(io.debug_perf_sel === 3.U, debug_perf_otherthread,
                                                   Mux(io.debug_perf_sel === 4.U, debug_perf_nonchecking, 
                                                   Mux(io.debug_perf_sel === 5.U, debug_perf_nonchecking_OtherThreads,
                                                   Mux(io.debug_perf_sel === 6.U, debug_perf_nonchecking_MOtherThreads,
                                                   Mux(io.debug_perf_sel === 8.U, debug_perf_nonchecking_MCheck,
                                                   Mux(io.debug_perf_sel === 9.U, io.debug_perf_bp_inst, 
                                                   Mux(io.debug_perf_sel === 11.U, io.debug_perf_icache_miss,
                                                   Mux(io.debug_perf_sel === 10.U, io.debug_perf_bp_mispred,
                                                   Mux(io.debug_perf_sel === 12.U, io.debug_perf_blocking_DIV,
                                                   Mux(io.debug_perf_sel === 13.U, checking_cycle,
                                                   Mux(io.debug_perf_sel === 14.U, checking_inst, 
                                                   Mux(io.debug_perf_sel === 15.U, u_channel.io.deq_bits, 0.U
                                                   )))))))))))))))
  
  io.checker_core_status                        := Mux(!io.if_correct_process.asBool, 3.U, 
                                                   Mux(fsm_state === fsm_checking, 1.U, 0.U))
 
  // io.debug_perf_val                             := 0.U
}
