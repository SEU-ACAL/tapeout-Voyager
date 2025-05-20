package freechips.rocketchip.r

import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}
import freechips.rocketchip.guardiancouncil._
import freechips.rocketchip.npu.RegFile
import freechips.rocketchip.meek.RegFileshadow
import java.util.concurrent.PriorityBlockingQueue

case class R_RSUSLParams(
  xLen: Int,
  numARFS: Int
)

class R_RSUSLIO(params: R_RSUSLParams) extends Bundle {
  val arfs_out = Output(UInt(params.xLen.W))
  val farfs_out = Output(UInt(params.xLen.W))
  val arfs_idx_out = Output(UInt(8.W))
  val arfs_valid_out = Output(UInt(1.W))

  // val id_raddr = Input(Vec(2, UInt(5.W)))

  // val id_rs    = Output(Vec(2, UInt(64.W)))

  val check_done = Input(Bool())
  val pcarf_out = Output(UInt(40.W))
  val fcsr_out = Output(UInt(8.W))
  val pfarf_valid_out = Output(UInt(1.W))
  val core_hang_up = Output(UInt(1.W))

  val arfs_merge = Input(UInt((params.xLen*2).W))
  val arfs_index = Input(UInt(7.W))
  val arfs_if_ARFS = Input(UInt(1.W))
  val arfs_if_CPS = Input(UInt(1.W))
  val paste_arfs = Input(UInt(1.W))
  val rsu_status = Output(UInt(2.W))
  val clear_ic_status = Input(UInt(1.W))

  val cdc_ready = Output(UInt(1.W))

  val do_cp_check = Input(UInt(1.W))
  val if_cp_check_completed = Output(UInt(1.W))
  val core_arfs_in = Input(Vec(params.numARFS, UInt(params.xLen.W)))
  val core_farfs_in = Input(Vec(params.numARFS, UInt(params.xLen.W)))
  val elu_cp_deq = Input(UInt(1.W))
  val elu_cp_data = Output(UInt((4*params.xLen+8).W))
  val elu_status = Output(UInt(1.W))

  val core_trace = Input(UInt(1.W))
  val record_context = Input(UInt(1.W))
  val store_from_checker = Input(UInt(1.W)) // 0: from main; 1: from checker.
  val core_id = Input(UInt(4.W)) // 0: from main; 1: from checker.
  
  val starting_CPS = Output(UInt(1.W))
}

trait HasR_RSUSLIO extends BaseModule {
  val params: R_RSUSLParams
  val io = IO(new R_RSUSLIO(params))
}

class R_RSUSL(val params: R_RSUSLParams) extends Module with HasR_RSUSLIO {
  // Revisit: move it to the instruction counter
  val rsu_status                                  = RegInit(0.U(2.W))

  /* Loading snapshot from RSU Master */
  val arfs_ss                                     = SyncReadMem(params.numARFS+1, UInt(params.xLen.W))
  val farfs_ss                                    = SyncReadMem(params.numARFS+1, UInt(params.xLen.W))
  //for debug
  val arfs_ss_ECP                                 = Reg(Vec(params.numARFS, UInt(params.xLen.W)))
  val farfs_ss_ECP                                = Reg(Vec(params.numARFS, UInt(params.xLen.W)))


  val arfs_ss_GMode                               = SyncReadMem(params.numARFS+1, UInt(params.xLen.W))
  val farfs_ss_GMode                              = SyncReadMem(params.numARFS+1, UInt(params.xLen.W))
  // val rf_shadow                                   = new RegFileshadow(32, 64)

  val pcarfs_ss                                   = RegInit(0.U(40.W))
  
  val if_RSU_packet                               = WireInit(0.U(1.W))
  val packet_valid                                = RegInit(0.U(1.W)) 
  val packet_index                                = RegInit(0.U(8.W))
  val packet_arfs                                 = RegInit(0.U(params.xLen.W))
  val packet_farfs                                = RegInit(0.U(params.xLen.W))



  if_RSU_packet                                  := Mux(io.arfs_if_ARFS.asBool && io.arfs_if_CPS.asBool, 1.U, 0.U) 
  packet_valid                                   := Mux(if_RSU_packet === 1.U, 1.U, 0.U)
  packet_arfs                                    := Mux(if_RSU_packet === 1.U, io.arfs_merge(63,0), 0.U)
  packet_farfs                                   := Mux(if_RSU_packet === 1.U, io.arfs_merge(127,64), 0.U)
  packet_index                                   := Mux(if_RSU_packet === 1.U, io.arfs_index, 0.U)
  io.starting_CPS                                := if_RSU_packet.asBool && (packet_index === 0.U)

  /* Storing the checker's current states */
  val recording_context                           = RegInit(false.B)
  val recording_counter                           = RegInit(20.U(7.W))



  when (io.record_context.asBool && !recording_context) {
    recording_context                            := true.B
    recording_counter                            := 0.U
  } .elsewhen (recording_context === 1.U){
    recording_context                            := Mux(recording_counter === 0x20.U, false.B, true.B)
    recording_counter                            := Mux(recording_counter === 0x20.U, 0.U, recording_counter + 1.U)
  } .otherwise {
    recording_context                            := recording_context
    recording_counter                            := recording_counter
  }

  when (recording_context) {
    arfs_ss_GMode.write(recording_counter, io.core_arfs_in(recording_counter))
    farfs_ss_GMode.write(recording_counter, io.core_farfs_in(recording_counter))
  }

  /* Loading snapshot at End of Check Point from RSU Master */
  val if_RSU_packet_ECP                           = WireInit(false.B)
  val packet_valid_ECP                            = RegInit(0.U(1.W)) 
  val packet_index_ECP                            = RegInit(0.U(8.W))
  val packet_arfs_ECP                             = RegInit(0.U(params.xLen.W))
  val packet_farfs_ECP                            = RegInit(0.U(params.xLen.W))
  // val packet_arfs_ECP                             = RegInit(0.U(params.xLen.W))
  // val packet_farfs_ECP                            = RegInit(0.U(params.xLen.W))
  
  if_RSU_packet_ECP                              := io.arfs_if_ARFS.asBool && !io.arfs_if_CPS.asBool 
  packet_valid_ECP                               := Mux(if_RSU_packet_ECP , 1.U, 0.U)
  packet_arfs_ECP                                := Mux(if_RSU_packet_ECP , io.arfs_merge(63,0), 0.U)
  packet_farfs_ECP                               := Mux(if_RSU_packet_ECP , io.arfs_merge(127,64), 0.U)
  packet_index_ECP                               := Mux(if_RSU_packet_ECP , io.arfs_index, 0.U)
  val has_ECP                                     = RegInit(false.B)
  val det_fall                                    = (!if_RSU_packet_ECP)&&RegNext(if_RSU_packet_ECP)
  has_ECP                                        := Mux(if_RSU_packet===1.U,false.B,Mux(det_fall,true.B,has_ECP))
  when (packet_valid === 1.U) {
    arfs_ss.write(packet_index, packet_arfs)
    farfs_ss.write(packet_index, packet_farfs)
    when(io.core_trace.asBool){
      printf(midas.targetutils.SynthesizePrintf("[C%x SRCP] = [idx %x arfs %x farfs %x]\n", io.core_id,packet_index,packet_arfs,packet_farfs))
      // printf(midas.targetutils.SynthesizePrintf("[C%x-farfs] = [%x %x]\n", io.core_id,packet_index,packet_arfs))
    }
    // when(packet_index =/= 0x20.U){
    //   rf_shadow.write(packet_index, packet_arfs)
    // }
  } 
  




  
  

  
  
  dontTouch(has_ECP)
  arfs_ss_ECP(0)  := 0.U
  when(packet_valid_ECP===1.U&&(!has_ECP)&&(packet_index_ECP=/=0x20.U)){
    
    farfs_ss_ECP(packet_index_ECP) := packet_farfs_ECP
    when(packet_index_ECP=/=0.U){
      arfs_ss_ECP(packet_index_ECP) := packet_arfs_ECP
    }
  }


  
  pcarfs_ss                                      := Mux(packet_valid.asBool && (packet_index === 0x20.U), packet_arfs(39,0), pcarfs_ss)
  rsu_status                                     := Mux(io.clear_ic_status.asBool, 0.U, Mux(packet_index === 0x20.U, 1.U, Mux(io.check_done, 3.U, rsu_status)))

  /* Applying snapshot to the core */
  val arf_data                                    = WireInit(0.U((params.xLen.W)))
  val farf_data                                   = WireInit(0.U((params.xLen.W)))
  val arf_addr                                    = WireInit(0.U(8.W))
  val farf_addr                                   = WireInit(0.U(8.W))

  
  val apply_snapshot                              = RegInit(0.U(1.W))
  val apply_snapshot_memdelay                     = RegInit(0.U(1.W))
  val apply_counter                               = RegInit(20.U(8.W))
  val apply_counter_memdelay                      = RegInit(0.U(8.W))
  val do_check                                    = RegInit(0.U(1.W))
  val checking_counter                            = RegInit(0.U(8.W))


  apply_snapshot_memdelay                        := apply_snapshot
  apply_counter_memdelay                         := apply_counter
  arf_addr                                       := Mux(apply_snapshot.asBool, apply_counter, 0.U)
  farf_addr                                      := Mux(apply_snapshot.asBool, apply_counter, 0.U)
  arf_data                                       := Mux(!io.store_from_checker, arfs_ss.read(arf_addr, apply_snapshot.asBool), arfs_ss_GMode.read(arf_addr, apply_snapshot.asBool))
  farf_data                                      := Mux(!io.store_from_checker, farfs_ss.read(farf_addr, apply_snapshot.asBool), farfs_ss_GMode.read(arf_addr, apply_snapshot.asBool))

  // arf_addr_ECP                                   := Mux(do_check.asBool, checking_counter, 0.U)
  // farf_addr_ECP                                  := Mux(do_check.asBool, checking_counter, 0.U)
  // arf_data_ECP                                   := arfs_ss_ECP.read(arf_addr_ECP,  do_check.asBool)
  // farf_data_ECP                                  := farfs_ss_ECP.read(farf_addr_ECP, do_check.asBool)


  when ((io.paste_arfs === 0x01.U) && (apply_snapshot === 0.U)) {
    apply_snapshot                               := 1.U
    apply_counter                                := 0.U
  } .elsewhen (apply_snapshot === 1.U){
    apply_snapshot                               := Mux(apply_counter === 0x20.U, 0.U, 1.U)
    apply_counter                                := Mux(apply_counter === 0x20.U, 0.U, apply_counter + 1.U)
  } .otherwise {
    apply_snapshot                               := apply_snapshot
    apply_counter                                := apply_counter
  }

  val arfs_out_printf                             = Mux(((apply_snapshot_memdelay === 1.U) && (apply_counter_memdelay =/= 0x20.U)), arf_data, 0.U)
  val arfs_out_valid_printf                       = Mux(((apply_snapshot_memdelay === 1.U) && (apply_counter_memdelay =/= 0x20.U)), 1.U, 0.U)
  val arfs_out_idx                                = Mux(((apply_snapshot_memdelay === 1.U) && (apply_counter_memdelay =/= 0x20.U)), apply_counter_memdelay, 0.U)



  io.arfs_out                                    := Mux(((apply_snapshot_memdelay === 1.U) && (apply_counter_memdelay =/= 0x20.U)), arf_data, 0.U)
  io.farfs_out                                   := Mux(((apply_snapshot_memdelay === 1.U) && (apply_counter_memdelay =/= 0x20.U)), farf_data, 0.U)
  io.arfs_idx_out                                := Mux(((apply_snapshot_memdelay === 1.U) && (apply_counter_memdelay =/= 0x20.U)), apply_counter_memdelay, 0.U)
  io.arfs_valid_out                              := Mux(((apply_snapshot_memdelay === 1.U) && (apply_counter_memdelay =/= 0x20.U)), 1.U, 0.U)

  val pcarfs_ss_delay                             = RegInit(0.U(40.W))
  pcarfs_ss_delay                                := pcarfs_ss


 
  io.pcarf_out                                   := pcarfs_ss
  io.fcsr_out                                    := Mux(((apply_snapshot_memdelay === 1.U) && (apply_counter_memdelay === 0x20.U)), farf_data, 0.U)
  io.pfarf_valid_out                             := Mux(((apply_snapshot_memdelay === 1.U) && (apply_counter_memdelay === 0x20.U)), 1.U, 0.U)
  io.cdc_ready                                   := packet_valid | packet_valid_ECP

  io.rsu_status                                  := rsu_status



  val if_check_fail                               = RegInit(false.B)
  val debug_fail                                  = RegInit(VecInit(Seq.fill(params.numARFS)(false.B)))
  for(i <-0 until params.numARFS){
    when(do_check.asBool&&(io.core_arfs_in(i)=/=arfs_ss_ECP(i)||io.core_farfs_in(i)=/=farfs_ss_ECP(i))){
      if_check_fail := true.B
      debug_fail(i) := true.B
    }.otherwise{
      debug_fail(i) := false.B
      if_check_fail := false.B
    }
  }

  dontTouch(if_check_fail)
  dontTouch(debug_fail)
  assert((!if_check_fail),"check failure")

  if (GH_GlobalParams.GH_DEBUG == 1) {
    // when ((io.core_trace.asBool) && (pcarfs_ss_delay =/= pcarfs_ss)) {
    //   printf(midas.targetutils.SynthesizePrintf("[C%x] Paste PC [%x]\n", io.core_id, pcarfs_ss))
    // }
    // when ((io.core_trace.asBool) && packet_valid_ECP===1.U&&(!has_ECP)&&(packet_index_ECP=/=0x20.U)) {
    //   printf(midas.targetutils.SynthesizePrintf("[C%x] ECP idx[%x] arfs %x farfs %x\n", io.core_id,packet_index_ECP,packet_arfs_ECP,packet_farfs_ECP))
    // }

    val fail_idx= PriorityEncoder(debug_fail)

    when(do_check.asBool && (io.core_trace.asBool)) {
      printf(midas.targetutils.SynthesizePrintf("[C%x] Check Finish %x\n", io.core_id,if_check_fail))
    }
    // when (if_check_fail && (io.core_trace.asBool)) {

    //   printf(midas.targetutils.SynthesizePrintf("Check FAIL C[%x] [FAIL][C_ARFS,C_FARFS,ECP_ARFS,ECP_FARFS] = \n" +
    //     "[%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x]\n"+
    //     "[%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x]\n"+
    //     "[%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x]\n"+
    //     "[%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x]\n"+
    //     "[%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x]\n"+
    //     "[%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x]\n"+
    //     "[%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x]\n"+
    //     "[%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x] [%x][%x,%x,%x,%x]\n"
    //     , io.core_id,debug_fail(0),io.core_arfs_in(0),io.core_farfs_in(0),arfs_ss_ECP(0),farfs_ss_ECP(0),
    //     debug_fail(1),io.core_arfs_in(1),io.core_farfs_in(1),arfs_ss_ECP(1),farfs_ss_ECP(1),
    //     debug_fail(2),io.core_arfs_in(2),io.core_farfs_in(2),arfs_ss_ECP(2),farfs_ss_ECP(2),
    //     debug_fail(3),io.core_arfs_in(3),io.core_farfs_in(3),arfs_ss_ECP(3),farfs_ss_ECP(3),
    //     debug_fail(4),io.core_arfs_in(4),io.core_farfs_in(4),arfs_ss_ECP(4),farfs_ss_ECP(4),
    //     debug_fail(5),io.core_arfs_in(5),io.core_farfs_in(5),arfs_ss_ECP(5),farfs_ss_ECP(5),
    //     debug_fail(6),io.core_arfs_in(6),io.core_farfs_in(6),arfs_ss_ECP(6),farfs_ss_ECP(6),
    //     debug_fail(7),io.core_arfs_in(7),io.core_farfs_in(7),arfs_ss_ECP(7),farfs_ss_ECP(7),
    //     debug_fail(8),io.core_arfs_in(8),io.core_farfs_in(8),arfs_ss_ECP(8),farfs_ss_ECP(8),
    //     debug_fail(9),io.core_arfs_in(9),io.core_farfs_in(9),arfs_ss_ECP(9),farfs_ss_ECP(9),
    //     debug_fail(10),io.core_arfs_in(10),io.core_farfs_in(10),arfs_ss_ECP(10),farfs_ss_ECP(10),
    //     debug_fail(11),io.core_arfs_in(11),io.core_farfs_in(11),arfs_ss_ECP(11),farfs_ss_ECP(11),
    //     debug_fail(12),io.core_arfs_in(12),io.core_farfs_in(12),arfs_ss_ECP(12),farfs_ss_ECP(12),
    //     debug_fail(13),io.core_arfs_in(13),io.core_farfs_in(13),arfs_ss_ECP(13),farfs_ss_ECP(13),
    //     debug_fail(14),io.core_arfs_in(14),io.core_farfs_in(14),arfs_ss_ECP(14),farfs_ss_ECP(14),
    //     debug_fail(15),io.core_arfs_in(15),io.core_farfs_in(15),arfs_ss_ECP(15),farfs_ss_ECP(15),
    //     debug_fail(16),io.core_arfs_in(16),io.core_farfs_in(16),arfs_ss_ECP(16),farfs_ss_ECP(16),
    //     debug_fail(17),io.core_arfs_in(17),io.core_farfs_in(17),arfs_ss_ECP(17),farfs_ss_ECP(17),
    //     debug_fail(18),io.core_arfs_in(18),io.core_farfs_in(18),arfs_ss_ECP(18),farfs_ss_ECP(18),
    //     debug_fail(19),io.core_arfs_in(19),io.core_farfs_in(19),arfs_ss_ECP(19),farfs_ss_ECP(19),
    //     debug_fail(20),io.core_arfs_in(20),io.core_farfs_in(20),arfs_ss_ECP(20),farfs_ss_ECP(20),
    //     debug_fail(21),io.core_arfs_in(21),io.core_farfs_in(21),arfs_ss_ECP(21),farfs_ss_ECP(21),
    //     debug_fail(22),io.core_arfs_in(22),io.core_farfs_in(22),arfs_ss_ECP(22),farfs_ss_ECP(22),
    //     debug_fail(23),io.core_arfs_in(23),io.core_farfs_in(23),arfs_ss_ECP(23),farfs_ss_ECP(23),
    //     debug_fail(24),io.core_arfs_in(24),io.core_farfs_in(24),arfs_ss_ECP(24),farfs_ss_ECP(24),
    //     debug_fail(25),io.core_arfs_in(25),io.core_farfs_in(25),arfs_ss_ECP(25),farfs_ss_ECP(25),
    //     debug_fail(26),io.core_arfs_in(26),io.core_farfs_in(26),arfs_ss_ECP(26),farfs_ss_ECP(26),
    //     debug_fail(27),io.core_arfs_in(27),io.core_farfs_in(27),arfs_ss_ECP(27),farfs_ss_ECP(27),
    //     debug_fail(28),io.core_arfs_in(28),io.core_farfs_in(28),arfs_ss_ECP(28),farfs_ss_ECP(28),
    //     debug_fail(29),io.core_arfs_in(29),io.core_farfs_in(29),arfs_ss_ECP(29),farfs_ss_ECP(29),
    //     debug_fail(30),io.core_arfs_in(30),io.core_farfs_in(30),arfs_ss_ECP(30),farfs_ss_ECP(30),
    //     debug_fail(31),io.core_arfs_in(31),io.core_farfs_in(31),arfs_ss_ECP(31),farfs_ss_ECP(31)
    //   ))
    //   printf(midas.targetutils.SynthesizePrintf("[C%x] Check Fail [idx %x ECP arfs %x farfs %x Checker arfs %x farfs %x]\n", io.core_id,fail_idx,arfs_ss_ECP(fail_idx),farfs_ss_ECP(fail_idx),io.core_arfs_in(fail_idx),io.core_farfs_in(fail_idx)))
    // }
  }

  // Faking ELU data
  val checking_counter_memdelay                   = RegInit(0.U(2.W))
  checking_counter_memdelay                      := checking_counter
  val if_check_completed                          = WireInit(0.U(1.W))

  when (!do_check.asBool) {
    do_check                                     := Mux(io.do_cp_check.asBool && !if_check_completed.asBool, 1.U, 0.U)
    checking_counter                             := Mux(io.clear_ic_status.asBool, 0.U, checking_counter)
  } .otherwise {
    do_check                                     := Mux(if_check_completed.asBool, 0.U, 1.U)
    checking_counter                             := Mux(checking_counter === 0x2.U, checking_counter, checking_counter + 1.U)
  }
  if_check_completed                             := (checking_counter_memdelay === 0x2.U).asUInt
  io.if_cp_check_completed                       := if_check_completed

  io.core_hang_up                                := apply_snapshot | apply_snapshot_memdelay | io.record_context | recording_context | (do_check.asBool && !if_check_completed.asBool)  
  io.elu_cp_data                                 := 0.U
  io.elu_status                                  := 0.U
}