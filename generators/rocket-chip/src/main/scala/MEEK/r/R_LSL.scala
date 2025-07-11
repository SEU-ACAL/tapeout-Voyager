package freechips.rocketchip.r

import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}
import freechips.rocketchip.guardiancouncil._

case class R_LSLParams(
  nEntries: Int,
  xLen: Int
)

class R_LSLIO(params: R_LSLParams) extends Bundle {
  val m_ld_valid  = Input(Vec(GH_GlobalParams.GH_TOTAL_PACKETS,Bool()))
  val m_st_valid  = Input(Vec(GH_GlobalParams.GH_TOTAL_PACKETS,Bool()))
  val m_ldst_data = Input(Vec(GH_GlobalParams.GH_TOTAL_PACKETS,UInt(params.xLen.W)))
  val m_ldst_addr = Input(Vec(GH_GlobalParams.GH_TOTAL_PACKETS,UInt(params.xLen.W)))
  val m_csr_valid = Input(Vec(GH_GlobalParams.GH_TOTAL_PACKETS,Bool()))
  val m_csr_data  = Input(Vec(GH_GlobalParams.GH_TOTAL_PACKETS,UInt(params.xLen.W)))


  val cdc_ready = Output(Bool())


  val req_ready = Output(Bool())
  val req_valid = Input(Bool())
  val req_addr = Input(UInt(40.W)) // Later used for comparision
  val req_tag = Input(UInt(8.W))
  val req_cmd = Input(UInt(2.W)) // 01: load; 10: store; 11: load & store
  val req_data = Input(UInt(params.xLen.W)) // Later used for comparision
  val req_size = Input(UInt(2.W))
  val req_kill = Input(Bool())
  val req_valid_csr = Input(Bool())
  val req_ready_csr = Output(Bool())

  val resp_valid = Output(Bool())
  val resp_tag = Output(UInt(8.W))
  val resp_size = Output(UInt(2.W))
  val resp_data = Output(UInt(params.xLen.W))
  val resp_has_data = Output(Bool())
  val resp_addr = Output(UInt(40.W))
  val resp_replay = Output(Bool())
  val near_full = Output(Bool())
  val resp_data_csr = Output(UInt(params.xLen.W))
  val if_empty = Output(Bool())
  val lsl_highwatermark = Output(Bool())
  // val resp_replay_csr = Output(UInt(1.W))
  val st_deq = Output(Bool())
  val ld_deq = Output(Bool())

  //for debug
  val lsl_deq_ptr = Output(UInt((log2Ceil(GH_GlobalParams.GH_TOTAL_PACKETS)+1).W))
  val vec_enq_valid = Output(Vec(GH_GlobalParams.GH_TOTAL_PACKETS, Bool()))
  val vec_enq_data  = Output(Vec(GH_GlobalParams.GH_TOTAL_PACKETS, UInt(( 2*params.xLen + 2).W)))
}

trait HasR_RLSLIO extends BaseModule {
  val params: R_LSLParams
  val io = IO(new R_LSLIO(params))
}

class R_LSL(val params: R_LSLParams) extends Module with HasR_RLSLIO {
  val fifowidth               = 2*params.xLen + 2 // extra two bits added to indicate inst type
  val u_channel               = Seq.fill(GH_GlobalParams.GH_TOTAL_PACKETS) {Module(new GH_MemFIFO(FIFOParams (fifowidth, params.nEntries)))}
  val u_channel_csr           = Seq.fill(GH_GlobalParams.GH_TOTAL_PACKETS) {Module(new GH_FIFO(FIFOParams (params.xLen, 11)))}
  
  val lsl_enq_ptr                            = RegInit(0.U((log2Ceil(GH_GlobalParams.GH_TOTAL_PACKETS)+1).W))//to avoid overflow
  val lsl_deq_ptr                            = RegInit(0.U((log2Ceil(GH_GlobalParams.GH_TOTAL_PACKETS)+1).W))
  val cdc_ready                              = RegInit(false.B)
/*
ENQ logic
*/
  //这里打了一拍
  val enq_data                = RegInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U(fifowidth.W)))
  val enq_valid               = RegInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U(false.B)))

  for(i<- 0 until GH_GlobalParams.GH_TOTAL_PACKETS){
    enq_data(i)  := Cat(io.m_st_valid(i),io.m_ld_valid(i),io.m_ldst_data(i), io.m_ldst_addr(i))
    enq_valid(i) := io.m_st_valid(i)|io.m_ld_valid(i)
  }
  val numEnq = WireInit(PopCount(enq_valid))

  when(enq_valid.reduce(_|_)){//需要保证回绕正确
    lsl_enq_ptr := Mux(lsl_enq_ptr + numEnq>=GH_GlobalParams.GH_TOTAL_PACKETS.U,lsl_enq_ptr+numEnq-GH_GlobalParams.GH_TOTAL_PACKETS.U,lsl_enq_ptr + numEnq)
  }

  val enq_idxs    = VecInit.tabulate(GH_GlobalParams.GH_TOTAL_PACKETS)(i => PopCount(enq_valid.take(i)))
  val enq_offset  = enq_idxs.map(i=>Mux(lsl_enq_ptr + i>=GH_GlobalParams.GH_TOTAL_PACKETS.U,lsl_enq_ptr+i-GH_GlobalParams.GH_TOTAL_PACKETS.U,lsl_enq_ptr+i))
  
  for (i <- 0 to GH_GlobalParams.GH_TOTAL_PACKETS - 1) {
    val enq_OH    = (0 until GH_GlobalParams.GH_TOTAL_PACKETS).map(idx => (enq_offset(idx) === i.U)&(enq_valid(idx)))
    val wdata  = Mux1H(enq_OH, enq_data) 
    u_channel(i).io.enq_valid                   := enq_OH.reduce(_|_)//
    u_channel(i).io.enq_bits                    := wdata
    io.vec_enq_valid(i) := u_channel(i).io.enq_valid
    io.vec_enq_data(i)  := u_channel(i).io.enq_bits
  }

/*
DEQ logic
*/
  val deq_data                = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U(fifowidth.W)))
  val deq_valid               = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(false.B))
  val lsl_empty               = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(true.B))
  val req_valid_reg           = RegInit(false.B)
  val resp_valid_reg          = RegInit(false.B)
  val resp_kill_reg           = RegInit(false.B)
  val resp_tag                = RegInit(0.U(8.W))
  val cmd                     = RegInit(0.U(2.W))
  val req_size_reg            = RegInit(0.U(2.W))

  val out_packet              = WireInit(Mux1H(RegNext(deq_valid), deq_data))
  val lsl_nearly_full         = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(false.B))
  val lsl_highwatermark       = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(false.B))
  dontTouch(deq_data)
  dontTouch(deq_valid)
  dontTouch(out_packet)
  // dontTouch(deq_OH)
  for (i <- 0 to GH_GlobalParams.GH_TOTAL_PACKETS - 1) {
    deq_valid(i)                               := lsl_deq_ptr === i.U && io.req_valid && !u_channel(i).io.empty && !io.req_kill
    u_channel(i).io.deq_ready                  := deq_valid(i)
    deq_data(i)                                := u_channel(i).io.deq_bits
    lsl_empty(i)                               := u_channel(i).io.empty
    lsl_nearly_full(i)                         := u_channel(i).io.status_twoslots
    lsl_highwatermark(i)                       := u_channel(i).io.high_watermark
  }

  when(deq_valid.reduce(_|_)){
    lsl_deq_ptr := Mux(lsl_deq_ptr + 1.U>=GH_GlobalParams.GH_TOTAL_PACKETS.U,lsl_deq_ptr+1.U-GH_GlobalParams.GH_TOTAL_PACKETS.U,lsl_deq_ptr + 1.U)
  }

  io.lsl_deq_ptr := lsl_deq_ptr

  resp_kill_reg              := io.req_kill // already in the replay procedure.... 
  val if_lsl_empty            = lsl_empty(lsl_deq_ptr)
  req_valid_reg              := io.req_valid
  resp_valid_reg             := io.req_valid && !if_lsl_empty && !io.req_kill
  resp_tag                   := io.req_tag
  cmd                        := io.req_cmd
  req_size_reg               := io.req_size

  io.req_ready               := !if_lsl_empty
  io.resp_valid              := resp_valid_reg
  io.resp_tag                := resp_tag
  // Revisit
  io.resp_size               := Mux((resp_valid_reg), req_size_reg, 0.U)
  io.resp_data               := Mux((resp_valid_reg), out_packet(127,64), 0.U)
  io.resp_addr               := Mux((resp_valid_reg), out_packet(63, 0), 0.U)
  io.resp_has_data           := Mux((resp_valid_reg) && (cmd(0) === 1.U), 1.U, 0.U)
  io.resp_replay             := req_valid_reg && !resp_valid_reg && !resp_kill_reg

  io.ld_deq                  := Mux(deq_valid.reduce(_|_), Mux(io.req_cmd === 0x01.U, 1.U, 0.U), 0.U)
  io.st_deq                  := Mux(deq_valid.reduce(_|_), Mux(io.req_cmd === 0x02.U, 1.U, 0.U), 0.U)


/*
CSR ENQ logic
*/
  val csr_enq_ptr                            = RegInit(0.U((log2Ceil(GH_GlobalParams.GH_TOTAL_PACKETS)+1).W))//to avoid overflow
  val csr_deq_ptr                            = RegInit(0.U((log2Ceil(GH_GlobalParams.GH_TOTAL_PACKETS)+1).W))
  //这里打了一拍
  val csr_enq_data                = RegInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U(params.xLen.W)))
  val csr_enq_valid               = RegInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U(false.B)))

  for(i<- 0 until GH_GlobalParams.GH_TOTAL_PACKETS){
    csr_enq_data(i)  := io.m_csr_data(i)
    csr_enq_valid(i) := io.m_csr_valid(i)
  }
  val csr_numEnq = WireInit(PopCount(csr_enq_valid))

  when(csr_enq_valid.reduce(_|_)){//需要保证回绕正确
    csr_enq_ptr := Mux(csr_enq_ptr + csr_numEnq>=GH_GlobalParams.GH_TOTAL_PACKETS.U,csr_enq_ptr+csr_numEnq-GH_GlobalParams.GH_TOTAL_PACKETS.U,csr_enq_ptr + csr_numEnq)
  }

  val csr_enq_idxs    = VecInit.tabulate(GH_GlobalParams.GH_TOTAL_PACKETS)(i => PopCount(csr_enq_valid.take(i)))
  val csr_enq_offset  = csr_enq_idxs.map(i=>Mux(csr_enq_ptr + i>=GH_GlobalParams.GH_TOTAL_PACKETS.U,csr_enq_ptr+i-GH_GlobalParams.GH_TOTAL_PACKETS.U,csr_enq_ptr+i))
  
  for (i <- 0 to GH_GlobalParams.GH_TOTAL_PACKETS - 1) {
    val csr_enq_OH    = (0 until GH_GlobalParams.GH_TOTAL_PACKETS).map(idx => (csr_enq_offset(idx) === i.U)&(csr_enq_valid(idx)))
    val csr_wdata  = Mux1H(csr_enq_OH, csr_enq_data) 
    u_channel_csr(i).io.enq_valid := csr_enq_OH.reduce(_|_)//
    u_channel_csr(i).io.enq_bits  := csr_wdata
  }

/*
CSR DEQ logic
*/
  val csr_deq_data                = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U(params.xLen.W)))
  val csr_deq_valid               = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(false.B))
  val csr_lsl_empty               = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(true.B))
  val csr_out_packet              = WireInit(Mux1H(csr_deq_valid,csr_deq_data))
  val csr_nearly_full             = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(false.B))
  val csr_highwatermark           = WireInit(VecInit.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(false.B))

  dontTouch(csr_deq_data)
  dontTouch(csr_deq_valid)
  dontTouch(csr_out_packet)
  for (i <- 0 to GH_GlobalParams.GH_TOTAL_PACKETS - 1) {
    csr_deq_valid(i)                               := csr_deq_ptr===i.U&&io.req_valid_csr & !u_channel_csr(i).io.empty
    u_channel_csr(i).io.deq_ready                  := csr_deq_valid(i)
    csr_deq_data(i)                                := u_channel_csr(i).io.deq_bits
    csr_lsl_empty(i)                               := u_channel_csr(i).io.empty
    csr_nearly_full(i)                             := u_channel_csr(i).io.status_twoslots
    csr_highwatermark(i)                           := u_channel_csr(i).io.status_threeslots
  }

  when(csr_deq_valid.reduce(_|_)){
    csr_deq_ptr := Mux(csr_deq_ptr + 1.U>=GH_GlobalParams.GH_TOTAL_PACKETS.U,csr_deq_ptr+1.U-GH_GlobalParams.GH_TOTAL_PACKETS.U,csr_deq_ptr + 1.U)
  }
  io.resp_data_csr           := csr_out_packet


  //之前有数据来过?

  io.cdc_ready               :=(!io.near_full )
  io.near_full               := lsl_nearly_full.reduce(_|_)|csr_nearly_full.reduce(_|_)
  io.req_ready_csr           := !csr_lsl_empty(csr_deq_ptr)
  io.if_empty                := csr_lsl_empty.reduce(_&_)&lsl_empty.reduce(_&_)
  io.lsl_highwatermark       := lsl_highwatermark.reduce(_|_)|csr_highwatermark.reduce(_|_)
}