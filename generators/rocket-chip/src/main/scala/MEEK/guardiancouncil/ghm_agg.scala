package freechips.rocketchip.guardiancouncil

import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}

//==========================================================
// Parameters
//==========================================================
case class GHM_AGG_Params(
  number_of_little_cores: Int,
  width_GH_packet: Int
)

//==========================================================
// I/Os
//==========================================================
class GHM_AGG_IO (params: GHM_AGG_Params) extends Bundle {
  val agg_packet_in                              = Input(Vec(params.number_of_little_cores, UInt(params.width_GH_packet.W)))
  val agg_buffer_full                            = Output(Vec(params.number_of_little_cores, UInt(1.W)))

  val agg_packet_out                             = Output(UInt(params.width_GH_packet.W))
  val agg_core_full                              = Input(UInt(1.W))
  val agg_empty                                  = Output(UInt(1.W))
}



trait HasGHM_AGG_IO extends BaseModule {
  val params: GHM_AGG_Params
  val io = IO(new GHM_AGG_IO(params))
}

//==========================================================
// Implementations
//==========================================================
class GHT_AGG (val params: GHM_AGG_Params) extends Module with HasGHM_AGG_IO
{ 
  val agg_buffer                                 = Seq.fill(params.number_of_little_cores) {Module(new GH_FIFO(FIFOParams (params.width_GH_packet, 2)))}
  
  val agg_buffer_data                            = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(0.U(params.width_GH_packet.W))))
  val agg_buffer_empty                           = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(false.B)))
  val agg_buffer_full                            = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(false.B)))

  val doPush                                     = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(false.B)))
  val doPull                                     = WireInit(VecInit(Seq.fill(params.number_of_little_cores)(false.B)))

  val sch_index                                  = RegInit(0.U(log2Ceil(params.number_of_little_cores).W))
  

  // Connections for FIFO queues
  for (i <- 0 to params.number_of_little_cores - 1) {
    agg_buffer(i).io.enq_valid                  := doPush(i)
    agg_buffer(i).io.enq_bits                   := io.agg_packet_in(i)
    agg_buffer(i).io.deq_ready                  := doPull(i)
    agg_buffer_data(i)                          := agg_buffer(i).io.deq_bits
    agg_buffer_empty(i)                         := agg_buffer(i).io.empty
    agg_buffer_full(i)                          := agg_buffer(i).io.full
  }

  for (i <- 0 to params.number_of_little_cores - 1) {
    doPush(i)                                   := ((io.agg_packet_in(i) =/= 0.U) && (!agg_buffer_full(i)))
    doPull(i)                                   := ((!io.agg_core_full) && (!agg_buffer_empty(sch_index)) && (sch_index === i.U))
  }
 

  when (agg_buffer_empty(sch_index) === 1.U) {
    sch_index                                   := Mux((sch_index === (params.number_of_little_cores - 1).U),
                                                        0.U,
                                                        sch_index + 1.U)
  } otherwise {
    sch_index                                   := sch_index
  }

  for (i <- 0 to params.number_of_little_cores - 1) {
    io.agg_buffer_full(i)                       := agg_buffer_full(i)
  }
  io.agg_packet_out                             := Mux((doPull(sch_index) && !agg_buffer_empty(sch_index)),
                                                        agg_buffer_data(sch_index),
                                                        0.U)

  io.agg_empty                                  := agg_buffer_empty.reduce(_&_)
}