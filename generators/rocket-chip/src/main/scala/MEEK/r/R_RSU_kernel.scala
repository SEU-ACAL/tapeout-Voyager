package freechips.rocketchip.r

import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}
import freechips.rocketchip.rocket._
import freechips.rocketchip.util._

//===== GuardianCouncil Function: Start ====//
import freechips.rocketchip.guardiancouncil._
import freechips.rocketchip.rocket.CSRshadows
//===== GuardianCouncil Function: End   ====//


class R_RSUIO_kernel(params: R_RSUParams) extends Bundle {
  val arfs_in = Input(Vec(params.numARFS, UInt(params.xLen.W)))
  val farfs_in = Input(Vec(params.numARFS, UInt(params.xLen.W)))
  val pcarf_in = Input(UInt(40.W))
  val fcsr_in = Input(UInt(8.W))
  val shadowcsr_in = Vec(CSRshadows.CSRsize, Input(UInt(params.xLen.W)))

  //kernel
  val csr_rw_valid    = Input(Bool())
  val csr_rw_addr     = Input(UInt(12.W))
  val ic_state        = Input(UInt(3.W))
  val ic_change_state = Input(Bool())
  val priv            = Input(UInt(2.W))
  val excpt_mode      = Input(UInt(2.W))

  val snapshot = Input(UInt(1.W))
  val merge = Input(UInt(1.W))
  val snapshot_priv = Input(Bool())
  val merge_priv    = Input(Bool())

  val core_hang_up = Output(UInt(1.W))
  val rsu_merging = Output(UInt(1.W))
  val rsu_merging_valid = Output(Bool())
  val arfs_merge = Output(Vec(params.scalarWidth, UInt((params.xLen*2).W)))
  val arfs_index = Output(Vec(params.scalarWidth, UInt((8+1).W)))
  val ic_crnt_target = Input(UInt(6.W))
  val ic_old_crnt_target = Input(UInt(5.W))
  val arfs_pidx = Output(Vec(params.scalarWidth, UInt(8.W)))
  val arfs_ecp_dest = Output(UInt(8.W))
  val rsu_busy = Output(UInt(1.W))
  val core_trace =Input(UInt(1.W))
  val ic_trace = Input(UInt((1.W)))
  val big_hang = Input(Bool())
}

trait HasR_RSUIO_kernel extends BaseModule {
  val params: R_RSUParams
  val io = IO(new R_RSUIO_kernel(params))
}

class R_RSU_kernel(val params: R_RSUParams) extends Module with HasR_RSUIO_kernel {
  val pcarf_ss                                    = RegInit(0.U(40.W))
  val arfs_ss                                     = Reg(Vec(params.numARFS, UInt(params.xLen.W)))
  val farfs_ss                                    = Reg(Vec(params.numARFS, UInt(params.xLen.W)))
  val fcsr_ss                                     = RegInit(0.U(8.W))
  val csrshadow_ss                                = Reg(Vec(CSRshadows.CSRsize, UInt(params.xLen.W)))
  val crt_priv                                    = RegInit(0.U(2.W))

  val merging                                     = RegInit(0.U(1.W))
  val merge_counter                               = RegInit(0.U(6.W)) // 32/4 + 1 (PC) = 9 Packets in total

  val merging_priv                                = RegInit(0.U(1.W))
  val merge_counter_priv                          = RegInit(0.U(6.W)) // 32/4 + 1 (PC) = 9 Packets in total
  val csr_merge_counter                           = RegInit(0.U(6.W))

  val csrshadow_haswrite                          = RegInit(VecInit(Seq.fill(CSRshadows.CSRsize)(false.B)))

  val doSnapshot                                  = RegInit(0.U(1.W))
  val doMerge                                     = RegInit(0.U(1.W))
  val io_merge_delay1                             = RegInit(0.U(1.W))
  val io_merge_delay2                             = RegInit(0.U(1.W))

  val doSnapshot_priv                             = RegInit(false.B)
  val doMerge_priv                                = RegInit(false.B)
  val io_merge_delay1_priv                        = RegInit(false.B)
  val io_merge_delay2_priv                        = RegInit(false.B)

  doSnapshot                                     := io.snapshot
  io_merge_delay1                                := io.merge
  io_merge_delay2                                := io_merge_delay1
  doMerge                                        := io_merge_delay2

  doSnapshot_priv                                := io.snapshot_priv
  io_merge_delay1_priv                           := io.merge_priv
  io_merge_delay2_priv                           := io_merge_delay1_priv
  doMerge_priv                                   := io_merge_delay2_priv
  
  when(io.ic_state === 6.U){
    for(i <- 0 until CSRshadows.CSRsize){
      csrshadow_haswrite(i)                  := false.B
    }
  }

  //提前获取csr_exe写入csr寄存器之前的旧值
  when(((io.ic_state =/= 6.U) || ((io.ic_state === 6.U) && io.ic_change_state)) && io.csr_rw_valid){
    for(i <- 0 until CSRshadows.CSRsize){
      when(io.csr_rw_addr === CSRshadows.csrshadow_seq_nouse(i)){
        csrshadow_ss(i)                        := io.shadowcsr_in(i)
        csrshadow_haswrite(i)                  := true.B
      }
    }
    when((io.csr_rw_addr === CSRshadows.mstatus.U) || (io.csr_rw_addr === CSRshadows.sstatus.U)){
      csrshadow_ss(CSRshadowsindex.mstatus)    := io.shadowcsr_in(CSRshadowsindex.mstatus)
      csrshadow_ss(CSRshadowsindex.sstatus)    := io.shadowcsr_in(CSRshadowsindex.sstatus)
      csrshadow_haswrite(CSRshadowsindex.mstatus) := true.B
      csrshadow_haswrite(CSRshadowsindex.sstatus) := true.B
    }.elsewhen((io.csr_rw_addr === CSRshadows.mie.U) || (io.csr_rw_addr === CSRshadows.sie.U)){
      csrshadow_ss(CSRshadowsindex.mie)    := io.shadowcsr_in(CSRshadowsindex.mie)
      csrshadow_ss(CSRshadowsindex.sie)    := io.shadowcsr_in(CSRshadowsindex.sie)
      csrshadow_haswrite(CSRshadowsindex.mie) := true.B
      csrshadow_haswrite(CSRshadowsindex.sie) := true.B
    }.elsewhen((io.csr_rw_addr === CSRshadows.mip.U) || (io.csr_rw_addr === CSRshadows.sip.U)){
      csrshadow_ss(CSRshadowsindex.mip)    := io.shadowcsr_in(CSRshadowsindex.mip)
      csrshadow_ss(CSRshadowsindex.sip)    := io.shadowcsr_in(CSRshadowsindex.sip)
      csrshadow_haswrite(CSRshadowsindex.mip) := true.B
      csrshadow_haswrite(CSRshadowsindex.sip) := true.B
    }
  }

  when (doSnapshot === 1.U) {
    for (i <- 0 until params.numARFS) {
      arfs_ss(i)                               := io.arfs_in(i)
      farfs_ss(i)                              := io.farfs_in(i)
    }
    pcarf_ss                                   := io.pcarf_in
    fcsr_ss                                    := io.fcsr_in
    crt_priv                                   := io.priv
  }.elsewhen(doSnapshot_priv){
    for (i <- 0 until params.numARFS) {
      arfs_ss(i)                               := io.arfs_in(i)
      farfs_ss(i)                              := io.farfs_in(i)
    }
    for (i <- 0 until CSRshadows.CSRsize){
      when(!csrshadow_haswrite(i)){
        csrshadow_ss(i)                          := io.shadowcsr_in(i)
      }
    }
    pcarf_ss                                   := io.pcarf_in
    fcsr_ss                                    := io.fcsr_in
    crt_priv                                   := io.priv
  }




  // val merge_cdc_counter                           = RegInit(0.U(1.W))
  // when ((doMerge === 1.U) && (merging === 0.U)){
  //   merging                                      := 1.U
  //   merge_counter                                := 0.U
  //   merge_cdc_counter                            := 0.U
  // } .elsewhen (merging === 1.U) {
  //   merging                                      := Mux((merge_counter === 32.U) && (merge_cdc_counter === 1.U), 0.U, 1.U)
  //   merge_counter                                := Mux((!io.big_hang) && (merge_cdc_counter === 1.U), Mux((merge_counter === 32.U), 0.U, merge_counter + 1.U), merge_counter)    
  //   merge_cdc_counter                            := merge_cdc_counter + 1.U
  // } .otherwise {
  //   merging                                      := merging
  //   merge_counter                                := merge_counter
  // }
  when ((doMerge === 1.U) && (merging === 0.U)){
    merging                                      := 1.U
    merge_counter                                := 0.U
  } .elsewhen (merging === 1.U) {
    merging                                      := Mux((merge_counter === 32.U), 0.U, 1.U)
    merge_counter                                := Mux((!io.big_hang), Mux((merge_counter === 32.U), 0.U, merge_counter + 1.U), merge_counter)
  } .otherwise {
    merging                                      := merging
    merge_counter                                := merge_counter
  }

    // val merge_cdc_counter_priv                     = RegInit(0.U(1.W))
    // when ((doMerge_priv === 1.U) && (merging_priv === 0.U)){
    //   merging_priv                                 := 1.U
    //   merge_counter_priv                           := 0.U
    //   merge_cdc_counter_priv                       := 0.U
    //   csr_merge_counter                            := 0.U
    // } .elsewhen (merging_priv === 1.U) {
    //   merging_priv                                 := Mux((merge_counter_priv === 32.U) && (merge_cdc_counter_priv === 1.U) && (csr_merge_counter === 7.U), 0.U, 1.U)
    //   merge_counter_priv                           := Mux(merge_cdc_counter_priv === 1.U && ((!io.big_hang)), Mux((merge_counter_priv === 32.U), Mux(csr_merge_counter === 7.U, 0.U, merge_counter_priv), merge_counter_priv + 1.U), merge_counter_priv)    
    //   csr_merge_counter                            := Mux(merge_cdc_counter_priv === 1.U && ((!io.big_hang)), Mux(merge_counter_priv === 32.U, Mux(csr_merge_counter === 7.U, 0.U, csr_merge_counter + 1.U), csr_merge_counter), csr_merge_counter)
    //   merge_cdc_counter_priv                       := merge_cdc_counter_priv + 1.U
    // } .otherwise {
    //   merging_priv                                 := merging_priv
    //   merge_counter_priv                           := merge_counter_priv
    //   csr_merge_counter                            := csr_merge_counter
    // }
    when ((doMerge_priv === 1.U) && (merging_priv === 0.U)){
      merging_priv                                 := 1.U
      merge_counter_priv                           := 0.U
      csr_merge_counter                            := 0.U
    } .elsewhen (merging_priv === 1.U) {
      merging_priv                                 := Mux((merge_counter_priv === 32.U) && (csr_merge_counter === 7.U), 0.U, 1.U)
      merge_counter_priv                           := Mux( ((!io.big_hang)), Mux((merge_counter_priv === 32.U), Mux(csr_merge_counter === 7.U, 0.U, merge_counter_priv), merge_counter_priv + 1.U), merge_counter_priv)    
      csr_merge_counter                            := Mux( ((!io.big_hang)), Mux(merge_counter_priv === 32.U, Mux(csr_merge_counter === 7.U, 0.U, csr_merge_counter + 1.U), csr_merge_counter), csr_merge_counter)
    } .otherwise {
      merging_priv                                 := merging_priv
      merge_counter_priv                           := merge_counter_priv
      csr_merge_counter                            := csr_merge_counter
    }



  io.core_hang_up                                := io.snapshot | doSnapshot| io.snapshot_priv.asUInt | doSnapshot_priv.asUInt

  val zeros_24bits                                = WireInit(0.U(24.W))
  val zeros_56bits                                = WireInit(0.U(56.W))
  val seven_3bits                                 = WireInit(7.U(3.W))
  val five_3bits                                  = WireInit(5.U(3.W))
  
  // io.arfs_merge(0)                               := MuxCase(0.U,
  //                                                   Array(((merging === 1.U) && (merge_counter =/= 32.U)) -> Cat(farfs_ss(merge_counter), arfs_ss(merge_counter)),
  //                                                         ((merging === 1.U) && (merge_counter === 32.U)) -> Cat(zeros_56bits, fcsr_ss, zeros_24bits, pcarf_ss)
  //                                                         )
  //                                                         )

  val merge_data      =                           MuxCase(0.U,
                                                         Array(((merging === 1.U) && (merge_counter =/= 32.U)) -> Cat(farfs_ss(merge_counter), arfs_ss(merge_counter)),
                                                               ((merging === 1.U) && (merge_counter === 32.U)) -> Cat(zeros_56bits, fcsr_ss, zeros_24bits, pcarf_ss)
                                                              )
                                                         )

  val merge_data_priv =                           MuxCase(0.U,
                                                         Array(((merging_priv === 1.U) && (merge_counter_priv =/= 32.U) && (csr_merge_counter === 0.U)) -> Cat(farfs_ss(merge_counter_priv), arfs_ss(merge_counter_priv)),
                                                               ((merging_priv === 1.U) && (merge_counter_priv === 32.U) && (csr_merge_counter === 0.U)) -> Cat(zeros_56bits, fcsr_ss, zeros_24bits, pcarf_ss),
                                                               ((merging_priv === 1.U) && (merge_counter_priv === 32.U) && (csr_merge_counter =/= 0.U) && (csr_merge_counter =/= 7.U)) -> Cat(csrshadow_ss(((csr_merge_counter - 1.U) << 1) + 1.U), csrshadow_ss(((csr_merge_counter - 1.U) << 1))),
                                                               ((merging_priv === 1.U) && (merge_counter_priv === 32.U) && (csr_merge_counter =/= 0.U) && (csr_merge_counter === 7.U)) -> Cat(0.U(64.W), csrshadow_ss(((csr_merge_counter - 1.U) << 1)))
                                                             )
                                                          )

  io.arfs_merge(0)                               := Mux(merging.asBool, merge_data, Mux(merging_priv.asBool, merge_data_priv, 0.U))

  io.arfs_index(0)                               := Mux(merging === 1.U, Cat(0.U(1.W), crt_priv, merge_counter), Mux(merging_priv === 1.U, Mux(csr_merge_counter =/= 0.U, Cat(1.U(1.W), crt_priv, csr_merge_counter), Cat(0.U(1.W), crt_priv, merge_counter_priv)), 0.U(9.W)))

  
  io.arfs_pidx(0)                                := Mux((((merging === 1.U)) || ((merging_priv === 1.U))) && (!io.big_hang), Cat(io.ic_crnt_target(4,0), seven_3bits), 0.U)
  io.arfs_ecp_dest                               := Mux((((merging === 1.U)) || ((merging_priv === 1.U))) && (!io.big_hang), Cat(io.ic_old_crnt_target(4,0), seven_3bits), 0.U)

  /*
  for (w <- 0 until params.scalarWidth) {
    if (w == 0) {
      io.arfs_merge(w)                             := MuxCase(0.U,
                                                      Array(((merging === 1.U) && (merge_counter =/= 8.U)) -> Cat(farfs_ss(merge_counter<<2), arfs_ss(merge_counter<<2)),
                                                            ((merging === 1.U) && (merge_counter === 8.U)) -> Cat(zeros_56bits, fcsr_ss, zeros_24bits, pcarf_ss)
                                                          )
                                                          )

      io.arfs_index(w)                             := Mux((merging === 1.U), (merge_counter<<2), 0.U)
      io.arfs_pidx(w)                              := Mux((merging === 1.U), Cat(io.ic_crnt_target(4,0), seven_3bits), 0.U)
    } else {
      io.arfs_merge(w)                             := MuxCase(0.U,
                                                      Array(((merging === 1.U) && (merge_counter =/= 8.U)) -> Cat(farfs_ss((merge_counter<<2)+w.U), arfs_ss((merge_counter<<2)+w.U)),
                                                            ((merging === 1.U) && (merge_counter === 8.U)) -> 0.U
                                                          )
                                                          )

      io.arfs_index(w)                             := Mux(((merging === 1.U) && (merge_counter =/= 8.U)), ((merge_counter<<2) + w.U), 0.U)
      io.arfs_pidx(w)                              := Mux(((merging === 1.U) && (merge_counter =/= 8.U)), Cat(io.ic_crnt_target(4,0), seven_3bits), 0.U)
    }
  }*/
  
  io.rsu_merging                                   := merging | merging_priv
  io.rsu_merging_valid                             := merging
  io.rsu_busy                                      :=  Mux(io.snapshot.asBool || io.merge.asBool || io_merge_delay1.asBool || io_merge_delay2.asBool || doSnapshot.asBool || doMerge.asBool || merging.asBool
                                                          || io.snapshot_priv || io.merge_priv || io_merge_delay1_priv || io_merge_delay2_priv || doSnapshot_priv || doMerge_priv || merging_priv.asBool, 1.U, 0.U)

  // if (GH_GlobalParams.GH_DEBUG == 1) {
  //   when ((io.core_trace.asBool) && (doSnapshot === 1.U)) {
  //     printf(midas.targetutils.SynthesizePrintf("[CP-Main]: [PC =%x]\n", io.pcarf_in))
  //   }
  // }

  
  // if (GH_GlobalParams.GH_DEBUG == 1) {
  //   when ((doSnapshot === 1.U) && (io.core_trace.asBool)) {
  //     printf(midas.targetutils.SynthesizePrintf("[CHECK POINTS --- Boom]: SCP[%x] ECP[%x] ARFS = [%x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x    %x]\n", 
  //     io.ic_crnt_target(4,0),io.ic_old_crnt_target(4,0),io.arfs_in(0), io.arfs_in(1), io.arfs_in(2), io.arfs_in(3),io.arfs_in(4), io.arfs_in(5), io.arfs_in(6), io.arfs_in(7),
  //     io.arfs_in(8), io.arfs_in(9), io.arfs_in(10), io.arfs_in(11),io.arfs_in(12), io.arfs_in(13), io.arfs_in(14), io.arfs_in(15),
  //     io.arfs_in(16), io.arfs_in(17), io.arfs_in(18), io.arfs_in(19),io.arfs_in(20), io.arfs_in(21), io.arfs_in(22), io.arfs_in(23),
  //     io.arfs_in(24), io.arfs_in(25), io.arfs_in(26), io.arfs_in(27),io.arfs_in(28), io.arfs_in(29), io.arfs_in(30), io.arfs_in(31)))
  //   }
  // }
  
}