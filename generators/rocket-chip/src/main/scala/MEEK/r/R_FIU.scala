package freechips.rocketchip.r

import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}
import freechips.rocketchip.guardiancouncil._

case class R_FIUParams(
  nEntries: Int,
  totalnumber_of_checkers: Int
)

class R_FIUIO(params: R_FIUParams) extends Bundle {
  val gtimer = Input(UInt(64.W))
  val fi_d = Input(Vec(params.totalnumber_of_checkers, UInt(57.W)))

  val sel = Input(UInt(7.W))
  val fi_rslt = Output(UInt(57.W))
  
}

trait HasR_FIUIO extends BaseModule {
  val params: R_FIUParams
  val io = IO(new R_FIUIO(params))
}

class R_FIU (val params: R_FIUParams) extends Module with HasR_FIUIO {
  val fi_valid                            = WireInit(VecInit(Seq.fill(params.totalnumber_of_checkers)(0.U(1.W))))
  val fi_latency                          = WireInit(VecInit(Seq.fill(params.totalnumber_of_checkers)(0.U(40.W))))
  val fi_index                            = WireInit(VecInit(Seq.fill(params.totalnumber_of_checkers)(0.U(8.W))))
  val latency                             = RegInit(VecInit(Seq.fill(params.nEntries)(0.U(40.W))))
  
  for (i <- 0 until params.totalnumber_of_checkers) {
    fi_valid(i)                          := io.fi_d(i)(56)
    fi_latency(i)                        := Mux(fi_valid(i).asBool, (io.gtimer(39,0) - io.fi_d(i)(39,0)), 0.U)
    fi_index(i)                          := Mux(fi_valid(i).asBool, (io.fi_d(i)(47,40)), 0.U)

    // Make sure the index is within range
    when (fi_valid(i).asBool && (fi_index(i) < params.nEntries.U)){
      latency(fi_index(i))               := fi_latency(i)
    }
  }

  io.fi_rslt                             := latency(io.sel)
}
