package freechips.rocketchip.r

import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}
import freechips.rocketchip.guardiancouncil._
import freechips.rocketchip.rocket._

class R_ICSLIO_kernel(params: R_ICSLParams) extends Bundle {
  val ic_counter                                 = Input(UInt((params.width_of_ic).W))
  val icsl_run                                   = Input(UInt(1.W))
  // val icsl_ack                                   = Input(Bool())
  val new_commit                                 = Input(UInt(1.W))
  val if_correct_process                         = Input(UInt(1.W))
  val returned_to_special_address_valid          = Input(UInt(1.W))

  val self_xcpt                                  = Input(Bool())
  val self_ret                                   = Input(Bool())

  val if_check_done                              = Output(Bool())
  val debug_check_done                           = Output(UInt(2.W))
  val if_check_privrun                           = Input(Bool())
  val if_check_privret                           = Output(Bool())

  val excpt_mode                                 = Input(Bool())
  val crnt_priv                                  = Input(UInt(2.W))

  val fsm_reset                                  = Output(Bool())

  
  val kill_pipe                                  = Output(Bool())
  val icsl_checkermode                           = Output(UInt(1.W))
  val icsl_checkerpriv_mode                      = Output(UInt(1.W))
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

  val debug_perf_reset                           = Input(UInt(1.W))
  val debug_perf_sel                             = Input(UInt(4.W))
  val debug_perf_val                             = Output(UInt(64.W))   
  val debug_starting_CPS                         = Input(UInt(1.W))
  val main_core_status                           = Input(UInt(4.W))
  val checker_core_status                        = Output(UInt(4.W))
  val st_deq                                     = Input(UInt(1.W))
  val ld_deq                                     = Input(UInt(1.W))

  val debug_state                                = Output(UInt(3.W))
  val debug_comp                                 = Output(UInt(2.W))

  val state_reset                                = Output(Bool())
}

trait HasR_ICSLIO_kernel extends BaseModule {
  val params: R_ICSLParams
  val io = IO(new R_ICSLIO_kernel(params))
}

class R_ICSL_kernel (val params: R_ICSLParams) extends Module with HasR_ICSLIO_kernel {
  val fsm_reset :: fsm_nonchecking :: fsm_checking :: fsm_checking_priv :: fsm_self_xcpt :: fsm_self_xcpt_priv :: fsm_postchecking :: fsm_postchecking_priv :: Nil = Enum(8)
  val fsm_state                                  = RegInit(fsm_reset)
  io.state_reset := (fsm_state === fsm_reset)
  val ic_counter_shadow                          = RegInit(0.U((params.width_of_ic-1).W))
  val ic_counter_done                            = RegInit(0.U(1.W))
  val icsl_run                                   = WireInit(0.U(1.W))
  
  val icsl_checkermode                           = WireInit(0.U(1.W))
  val icsl_checkerpriv_mode                      = WireInit(0.U(1.W))
  val clear_ic_status                            = WireInit(0.U(1.W))

  val if_overtaking                              = RegInit(0.U(1.W))
  val if_overtaking_priv                         = RegInit(0.U(1.W))
  val if_ret_special_pc                          = RegInit(0.U(1.W))

  val self_xcpt_flag                             = RegInit(0.U(8.W))
  val self_eret_flag                             = RegInit(0.U(8.W))

  val if_rh_cp_pc                                = WireInit(0.U(1.W))
  val if_rh_cp_pc_priv                           = WireInit(0.U(1.W))

  val sl_counter                                  = RegInit(0.U(params.width_of_ic.W))


  val if_completion                              = Mux((io.if_correct_process.asBool && (fsm_state === fsm_checking) && ((sl_counter>= (ic_counter_shadow+1.U)) || (io.new_commit.asBool && ((sl_counter + 1.U) >= (ic_counter_shadow + 1.U)))) && ic_counter_done.asBool), true.B, false.B)
  val if_completion_priv                         = Mux((io.if_correct_process.asBool && (fsm_state === fsm_checking_priv) && ((sl_counter>= (ic_counter_shadow)) || (io.new_commit.asBool && ((sl_counter + 1.U) >= (ic_counter_shadow)))) && ic_counter_done.asBool), true.B, false.B)
  // val if_slow_completion                         = Mux((io.if_correct_process.asBool && (sl_counter >= ic_counter_shadow) && ic_counter_done.asBool), true.B, false.B)
  val if_just_overtaking                         = Mux((io.if_correct_process.asBool && io.new_commit.asBool && ((sl_counter + 1.U) >= ic_counter_shadow + 1.U) && (fsm_state === fsm_checking)), 1.U, 0.U)
  val if_just_overtaking_priv                    = Mux((io.if_correct_process.asBool && io.new_commit.asBool && ((sl_counter + 1.U) >= ic_counter_shadow) && (fsm_state === fsm_checking_priv)), 1.U, 0.U)

  
  io.fsm_reset                                  := fsm_state === fsm_reset
  // val icsl_check_speed                           = sl_counter===(GH_GlobalParams.GH_TOTAL_INSTS-4).U //
  // val icsl_exec_done                             = sl_counter===(ic_counter_shadow+1.U)&&(fsm_state===fsm_speed_check)
  // val exec_last_one                              = RegInit(false.B)
  
  ic_counter_done                               := io.ic_counter(params.width_of_ic-1)
  io.debug_state := fsm_state
  io.debug_comp  := Cat(if_completion.asUInt, if_completion_priv.asUInt)
  dontTouch(if_completion)
  dontTouch(if_completion_priv)

  val check_done = RegInit(false.B)
  val check_done_for_ret = check_done && !(io.excpt_mode || io.self_xcpt)

  switch (fsm_state) {
    is (fsm_reset) {
      self_xcpt_flag                            := 0.U
      self_eret_flag                            := 0.U
      sl_counter                                := 0.U
      clear_ic_status                           := 1.U
      icsl_checkermode                          := 0.U
      icsl_checkerpriv_mode                     := 0.U
      if_rh_cp_pc                               := 0.U
      if_rh_cp_pc_priv                          := 0.U
      fsm_state                                 := fsm_nonchecking
    }
    is (fsm_nonchecking) {
      self_xcpt_flag                            := 0.U
      self_eret_flag                            := 0.U
      sl_counter                                := sl_counter
      clear_ic_status                           := 0.U
      icsl_checkermode                          := 0.U
      icsl_checkerpriv_mode                     := 0.U
      if_rh_cp_pc                               := 0.U
      if_rh_cp_pc_priv                          := 0.U
      fsm_state                                 := Mux(icsl_run.asBool, fsm_checking, Mux(io.if_check_privrun, fsm_checking_priv, fsm_nonchecking))
    }
    //并未对lsl满作出处理
    is (fsm_checking){
      self_xcpt_flag                            := 0.U
      self_eret_flag                            := 0.U
      sl_counter                                := Mux(io.if_correct_process.asBool && io.new_commit.asBool, sl_counter + 1.U, sl_counter)
      clear_ic_status                           := 0.U
      icsl_checkermode                          := Mux(io.if_correct_process.asBool, 1.U, 0.U)
      icsl_checkerpriv_mode                     := 0.U
      if_rh_cp_pc                               := 0.U
      if_rh_cp_pc_priv                          := 0.U
      fsm_state                                 := Mux(io.self_xcpt, fsm_self_xcpt, Mux(if_completion && !io.something_inflight, fsm_postchecking, fsm_checking))
    }
    //进行高特权级检测
    is (fsm_checking_priv){
      self_xcpt_flag                            := 0.U
      self_eret_flag                            := 0.U
      sl_counter                                := Mux(io.if_correct_process.asBool && io.new_commit.asBool, sl_counter + 1.U, sl_counter)
      clear_ic_status                           := 0.U
      icsl_checkermode                          := 0.U
      icsl_checkerpriv_mode                     := Mux(io.if_correct_process.asBool, 1.U, 0.U)
      if_rh_cp_pc                               := 0.U
      if_rh_cp_pc_priv                          := 0.U
      fsm_state                                 := Mux(io.self_xcpt, fsm_self_xcpt_priv, Mux(if_completion_priv && !io.something_inflight, fsm_postchecking_priv, fsm_checking_priv))
    }
    // //cdc 真空期
    // is (fsm_cdc_clear){
    //   sl_counter                                := Mux(io.if_correct_process.asBool && io.new_commit.asBool, sl_counter + 1.U, sl_counter)
    //   clear_ic_status                           := 0.U
    //   icsl_checkermode                          := Mux(io.if_correct_process.asBool, 1.U, 0.U)
    //   if_rh_cp_pc                               := 0.U
    //   //注意这里需要添加流水线是否为空
    //   fsm_state                                 := Mux(if_completion, fsm_postchecking, fsm_cdc_clear)//错误的状态转换
    // }
    is (fsm_self_xcpt){
      self_xcpt_flag                            := Mux(io.self_xcpt, self_xcpt_flag + 1.U, self_xcpt_flag)
      self_eret_flag                            := Mux(io.self_ret, self_eret_flag + 1.U, self_eret_flag)
      sl_counter                                := sl_counter
      clear_ic_status                           := 0.U
      icsl_checkermode                          := 0.U
      icsl_checkerpriv_mode                     := 0.U
      if_rh_cp_pc                               := 0.U
      if_rh_cp_pc_priv                          := 0.U
      fsm_state                                 := Mux((io.self_ret && (self_xcpt_flag === self_eret_flag)) || (io.crnt_priv === PRV.U.U), fsm_checking, fsm_self_xcpt)
    }
    is (fsm_self_xcpt_priv){
      self_xcpt_flag                            := Mux(io.self_xcpt, self_xcpt_flag + 1.U, self_xcpt_flag)
      self_eret_flag                            := Mux(io.self_ret, self_eret_flag + 1.U, self_eret_flag)
      sl_counter                                := sl_counter
      clear_ic_status                           := 0.U
      icsl_checkermode                          := 0.U
      icsl_checkerpriv_mode                     := 0.U
      if_rh_cp_pc                               := 0.U
      if_rh_cp_pc_priv                          := 0.U
      fsm_state                                 := Mux((io.self_ret && (self_xcpt_flag === self_eret_flag)), fsm_checking_priv, fsm_self_xcpt_priv)
    }
    is (fsm_postchecking){//post check阶段会去将流水线指令执行完成，然后去return
      self_xcpt_flag                            := 0.U
      self_eret_flag                            := 0.U
      sl_counter                                := Mux(io.if_check_completed.asBool, 0.U, sl_counter)
      clear_ic_status                           := 0.U
      icsl_checkermode                          := Mux(io.if_correct_process.asBool && !(io.excpt_mode), 1.U, 0.U)
      icsl_checkerpriv_mode                     := 0.U
      if_rh_cp_pc                               := !(io.excpt_mode || io.self_xcpt).asUInt
      if_rh_cp_pc_priv                          := 0.U
      fsm_state                                 := Mux(io.returned_to_special_address_valid.asBool, fsm_reset, fsm_postchecking)
    }
    is(fsm_postchecking_priv){
      self_xcpt_flag                            := 0.U
      self_eret_flag                            := 0.U
      sl_counter                                := Mux(io.if_check_completed.asBool, 0.U, sl_counter)
      clear_ic_status                           := 0.U
      icsl_checkermode                          := 0.U
      icsl_checkerpriv_mode                     := 0.U
      if_rh_cp_pc                               := 0.U
      if_rh_cp_pc_priv                          := (check_done_for_ret && !io.returned_to_special_address_valid.asBool).asUInt
      fsm_state                                 := Mux(io.returned_to_special_address_valid.asBool, fsm_reset, fsm_postchecking_priv)
    }
  }
  val fsm_state_delay                            = RegInit(fsm_reset)
  fsm_state_delay                               := fsm_state
  if (GH_GlobalParams.GH_DEBUG == 1) {
    val ic_counter_shadow_delay                  = RegInit(0.U((params.width_of_ic-1).W))
    // ic_counter_shadow_delay                     := ic_counter_shadow
    // when ((fsm_state_delay =/= fsm_state) && (io.core_trace.asBool)) {
    //   printf(midas.targetutils.SynthesizePrintf("C%d:fsm_state=[%x]\n", io.core_id, fsm_state))
    // }
  }

  
  when(io.if_check_completed.asBool){
    check_done := false.B
  }.elsewhen(((if_completion && icsl_checkermode.asBool) || (icsl_checkerpriv_mode.asBool && if_completion_priv)) && !io.something_inflight && !(io.returned_to_special_address_valid.asBool) && !io.self_xcpt){
    check_done := true.B
  }

  val complete = (sl_counter >= ic_counter_shadow) && ic_counter_done.asBool
  val complete_delay = RegNext(complete)
  val complete_rise = complete && !complete_delay

  io.if_check_done := check_done
  io.debug_check_done := Cat(check_done_for_ret, check_done)
  // io.if_check_privret := io.if_correct_process.asBool && RegNext(((io.new_commit.asBool && ((sl_counter + 1.U) >= (ic_counter_shadow)))) || (complete_rise)) && 
  //                        ic_counter_done.asBool && ((fsm_state === fsm_checking_priv) || (fsm_state === fsm_postchecking_priv)) && !(io.returned_to_special_address_valid.asBool) && !io.excpt_mode
  io.if_check_privret := (if_rh_cp_pc_priv & !RegNext(if_rh_cp_pc_priv)).asBool
  dontTouch(check_done)

  // when()
  // exec_last_one                                 := Mux((fsm_state===fsm_speed_check),Mux(io.big_complete,true.B,exec_last_one),false.B)
  // dontTouch(exec_last_one)
  // if_ret_special_pc                             := Mux(io.if_check_completed.asBool && icsl_checkermode.asBool, 1.U, 0.U)
  if_ret_special_pc                             := Mux(if_rh_cp_pc.asBool && icsl_checkermode.asBool, 1.U, 0.U)
  icsl_run                                      := io.icsl_run
  
  // io.if_big_complete                            := false.B//(fsm_state===fsm_cdc_clear||fsm_state===fsm_checking)&&(icsl_check_speed)
  // dontTouch(io.if_big_complete)
  // dontTouch(io.big_complete)
  // val if_overtaking                             = RegInit(0.U(1.W))
  if_overtaking                                 := Mux(if_just_overtaking.asBool || (sl_counter >= (ic_counter_shadow + 1.U)), 1.U, 0.U)
  if_overtaking_priv                            := Mux(if_just_overtaking_priv.asBool || (sl_counter >= (ic_counter_shadow)), 1.U, 0.U)
  val if_overtaking_next_cycle                   = WireInit(0.U(1.W))
  val if_overtaking_priv_next_cycle              = WireInit(0.U(1.W))
  if_overtaking_next_cycle                      := Mux(if_just_overtaking.asBool || (sl_counter >= (ic_counter_shadow + 1.U)), 1.U, 0.U)
  if_overtaking_priv_next_cycle                 := Mux(if_just_overtaking_priv.asBool || (sl_counter >= (ic_counter_shadow)), 1.U, 0.U)
  
  val stall_checking                            = RegInit(false.B)
  val stall_postchecking                        = RegInit(false.B)
  val stall_checking_priv                       = RegInit(false.B)
  val stall_postchecking_priv                   = RegInit(false.B)
  stall_checking           := Mux(ic_counter_shadow + 1.U <= sl_counter + io.num_valid_insts_in_pipeline, true.B,false.B)
  stall_postchecking       := Mux(io.num_valid_insts_in_pipeline > 0.U, true.B,false.B)
  stall_checking_priv      := Mux(ic_counter_shadow <= sl_counter + io.num_valid_insts_in_pipeline, true.B,false.B)
  stall_postchecking_priv  := Mux(io.num_valid_insts_in_pipeline > 0.U, true.B,false.B)


  dontTouch(stall_checking)
  ic_counter_shadow                             := Mux(io.ic_counter=/=0.U,io.ic_counter,ic_counter_shadow)
  io.clear_ic_status                            := clear_ic_status
  io.icsl_checkermode                           := icsl_checkermode
  io.icsl_checkerpriv_mode                      := icsl_checkerpriv_mode
  // io.if_overtaking                              := if_overtaking
  io.if_overtaking                              := Mux((fsm_state === fsm_checking) || (fsm_state === fsm_postchecking), if_overtaking, Mux((fsm_state === fsm_checking_priv) || (fsm_state === fsm_postchecking_priv), if_overtaking_priv, 0.U))
  // io.if_overtaking_next_cycle                   := if_overtaking_next_cycle//(icsl_checkermode & if_overtaking_next_cycle)
  io.if_overtaking_next_cycle                   := Mux((fsm_state === fsm_checking) || (fsm_state === fsm_postchecking), if_overtaking_next_cycle, Mux((fsm_state === fsm_checking_priv) || (fsm_state === fsm_postchecking_priv), if_overtaking_priv_next_cycle, 0.U))
  io.if_ret_special_pc                          := if_ret_special_pc
  io.if_rh_cp_pc                                := if_rh_cp_pc
  io.icsl_status                                := Mux(fsm_state === fsm_nonchecking, 1.U, 0.U)
  io.debug_sl_counter                           := sl_counter

  dontTouch(ic_counter_shadow)
  // dontTouch(icsl_exec_done)
  //这里可能会出问题
  // io.icsl_stalld                                := Mux(icsl_checkermode.asBool,
  //                                                 Mux(fsm_state === fsm_checking, stall_checking, 
  //                                                 Mux(fsm_state === fsm_postchecking, (!io.if_check_completed), false.B)), false.B)
  io.icsl_stalld                                := Mux(icsl_checkermode.asBool,
                                                      Mux(fsm_state === fsm_checking, stall_checking, 
                                                      Mux(fsm_state === fsm_postchecking, stall_postchecking, false.B)), 
                                                   Mux(icsl_checkerpriv_mode.asBool, 
                                                      Mux(fsm_state === fsm_checking_priv, stall_checking_priv, false.B),
                                                   Mux(fsm_state === fsm_postchecking_priv, stall_postchecking_priv && !io.excpt_mode, false.B)))
  io.kill_pipe                                  := false.B//(fsm_state===fsm_speed_check)&&(sl_counter===(ic_counter_shadow))&&(io.new_commit.asBool)||icsl_exec_done//此时需要去清除其他指令，为什么不用-1，因为小核心会多执行一条
  /* Debug Perf */
  /* Debug Perf */
  val debug_perf_howmany_checkpoints             = RegInit(0.U(64.W))
  val debug_perf_checking                        = RegInit(0.U(64.W))
  val debug_perf_postchecking                    = RegInit(0.U(64.W))
  val debug_perf_otherthread                     = RegInit(0.U(64.W))
  val debug_perf_nonchecking                     = RegInit(0.U(64.W))
  val debug_perf_nonchecking_OtherThreads        = RegInit(0.U(64.W))
  val debug_perf_nonchecking_MOtherThreads       = RegInit(0.U(64.W))
  val debug_perf_nonchecking_MSched              = RegInit(0.U(64.W))
  val debug_perf_nonchecking_MCheck              = RegInit(0.U(64.W))
  val debug_perf_RAW                             = RegInit(0.U(64.W))
  val debug_perf_exetime                         = RegInit(0.U(64.W))
  val debug_perf_insts                           = RegInit(0.U(64.W))
  val debug_perf_CPStrans                        = RegInit(0.U(64.W))
  val debug_perf_CPStrans_ifGo                   = RegInit(0.U(1.W))

  debug_perf_exetime                            := Mux(io.debug_perf_reset.asBool, 0.U, debug_perf_exetime + 1.U)
  debug_perf_howmany_checkpoints                := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_reset) && ((fsm_state_delay === fsm_postchecking) || (fsm_state_delay === fsm_postchecking_priv)), debug_perf_howmany_checkpoints + 1.U, debug_perf_howmany_checkpoints))
  debug_perf_checking                           := Mux(io.debug_perf_reset.asBool, 0.U, Mux(((fsm_state === fsm_checking) || (fsm_state === fsm_checking_priv)), debug_perf_checking + 1.U, debug_perf_checking))
  debug_perf_postchecking                       := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_postchecking) || (fsm_state === fsm_postchecking_priv), debug_perf_postchecking + 1.U, debug_perf_postchecking))
  debug_perf_otherthread                        := Mux(io.debug_perf_reset.asBool, 0.U, Mux(((fsm_state === fsm_checking) || (fsm_state === fsm_postchecking)) && (!io.if_correct_process.asBool),  debug_perf_otherthread + 1.U, debug_perf_otherthread))
  debug_perf_nonchecking                        := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_nonchecking), debug_perf_nonchecking + 1.U, debug_perf_nonchecking))
  /*
  debug_perf_nonchecking_OtherThreads           := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_nonchecking) && (!io.if_correct_process.asBool), debug_perf_nonchecking_OtherThreads + 1.U, debug_perf_nonchecking_OtherThreads))
  debug_perf_nonchecking_MOtherThreads          := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_nonchecking) && (io.if_correct_process.asBool) && (io.main_core_status === 3.U), debug_perf_nonchecking_MOtherThreads + 1.U, debug_perf_nonchecking_MOtherThreads))
  debug_perf_nonchecking_MCheck                 := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_nonchecking) && (io.if_correct_process.asBool) && (io.main_core_status === 2.U), debug_perf_nonchecking_MCheck + 1.U, debug_perf_nonchecking_MCheck))
  debug_perf_insts                              := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_checking) && io.new_commit.asBool, debug_perf_insts + 1.U, debug_perf_insts))*/
  // debug_perf_RAW                                := Mux(io.debug_perf_reset.asBool, 0.U, Mux(((fsm_state === fsm_checking) || (fsm_state === fsm_checking_priv)) && io.load_use_RAW, debug_perf_RAW + 1.U, debug_perf_RAW))
  debug_perf_insts                              := Mux(io.debug_perf_reset.asBool, 0.U, Mux(((fsm_state === fsm_checking) || (fsm_state === fsm_checking_priv)) && io.new_commit.asBool, debug_perf_insts + 1.U, debug_perf_insts))
  debug_perf_CPStrans_ifGo                      := Mux(io.debug_starting_CPS.asBool, 1.U, Mux(((fsm_state === fsm_checking) || (fsm_state === fsm_checking_priv)), 0.U, debug_perf_CPStrans_ifGo))
  debug_perf_CPStrans                           := Mux(io.debug_perf_reset.asBool, 0.U, Mux(debug_perf_CPStrans_ifGo.asBool, debug_perf_CPStrans + 1.U, debug_perf_CPStrans))
  // debug_perf_nonchecking_MSched                 := Mux(io.debug_perf_reset.asBool, 0.U, Mux((fsm_state === fsm_nonchecking) && (io.if_correct_process.asBool) && (io.main_core_status === 1.U), debug_perf_nonchecking_MSched + 1.U, debug_perf_nonchecking_MSched))


  val debug_perf_num_st                          = RegInit(0.U(64.W))
  val debug_perf_num_ld                          = RegInit(0.U(64.W))
  val debug_L_timer_worest                       = RegInit(0.U(64.W))

  debug_perf_num_st                             := Mux(io.debug_perf_reset.asBool, 0.U, debug_perf_num_st + io.st_deq)
  debug_perf_num_ld                             := Mux(io.debug_perf_reset.asBool, 0.U, debug_perf_num_ld + io.ld_deq)

  // val u_channel                                  = Module(new GH_MemFIFO(FIFOParams (32, 50)))
  // val debug_L_timer                              = RegInit(0.U(64.W))
  // debug_L_timer                                 := Mux(fsm_state === fsm_nonchecking, 0.U, Mux(fsm_state === fsm_checking, debug_L_timer + 1.U, debug_L_timer))
  // u_channel.io.enq_valid                        := Mux((fsm_state === fsm_postchecking) && (fsm_state_delay === fsm_checking) && ((debug_perf_howmany_checkpoints & 0x1FF.U) === 0x00.U), true.B, false.B)
  // u_channel.io.enq_bits                         := debug_L_timer
  // val debug_perf_sel_delay                       = RegInit(0.U(4.W))
  // debug_perf_sel_delay                          := io.debug_perf_sel
  // u_channel.io.deq_ready                        := (io.debug_perf_sel === 14.U) && (debug_perf_sel_delay === 15.U)

  // debug_L_timer_worest                          := Mux(io.debug_perf_reset.asBool, 0.U, Mux(debug_L_timer > debug_L_timer_worest, debug_L_timer, debug_L_timer_worest))


  io.debug_perf_val                             := Mux(io.debug_perf_sel === 7.U, debug_perf_howmany_checkpoints, 
                                                   Mux(io.debug_perf_sel === 1.U, debug_perf_checking,
                                                   Mux(io.debug_perf_sel === 2.U, debug_perf_postchecking,
                                                   Mux(io.debug_perf_sel === 3.U, debug_perf_otherthread,
                                                   Mux(io.debug_perf_sel === 4.U, debug_perf_nonchecking, 
                                                   Mux(io.debug_perf_sel === 5.U, debug_perf_nonchecking_OtherThreads,
                                                   Mux(io.debug_perf_sel === 6.U, debug_perf_RAW,
                                                   Mux(io.debug_perf_sel === 8.U, debug_perf_nonchecking_MCheck,
                                                   Mux(io.debug_perf_sel === 9.U, debug_perf_insts, 
                                                   Mux(io.debug_perf_sel === 11.U, debug_L_timer_worest,
                                                   Mux(io.debug_perf_sel === 10.U, debug_perf_CPStrans,
                                                   Mux(io.debug_perf_sel === 12.U, debug_perf_exetime,
                                                   Mux(io.debug_perf_sel === 13.U, debug_perf_num_ld, 0.U
                                                   )))))))))))))
  
  
  io.checker_core_status                        := Mux(!io.if_correct_process.asBool, 3.U, 
                                                   Mux(fsm_state === fsm_checking, 1.U, 0.U))
 
  // io.debug_perf_val                             := 0.U
}

