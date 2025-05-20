package boom.meek.trans
import boom.meek.exu._
import boom.meek.ifu._
import boom.meek.lsu._
import boom.meek.util._
import boom.meek.common._
import chisel3._
import chisel3.util._
import chisel3.experimental.{BaseModule}
import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.guardiancouncil._
import freechips.rocketchip.rocket._
import freechips.rocketchip.util._
//==========================================================
// Parameters
//==========================================================
case class GH_BUF_Params(
    xlen: Int,
    packet_size: Int,
    core_width: Int,
    use_prfs: Boolean
)

//==========================================================
// I/Os
//==========================================================
class GH_BUF_IO (params: GH_BUF_Params)(implicit p: Parameters) extends Bundle {


  val commit_valids                             = Input(Vec(params.core_width, Bool()))
  val commit_uops                               = Input(Vec(params.core_width, new MicroOp()))
  val alu_in                                    = Input(Vec(params.core_width, UInt((2*params.xlen).W)))
  val gh_prfs_rd                                = Input(Vec(params.core_width, UInt(params.xlen.W)))//csr read data
  val cdc_not_ready                             = Input(Bool())
  // val gh_csr_addr_in                            = Input(Vec(params.core_width, UInt(12.W)))
  val packet_out                                = Output(UInt((GH_GlobalParams.GH_TOTAL_PACKETS*(params.packet_size)).W))
  val gh_packet_dest                            = Output(UInt((GH_GlobalParams.GH_NUM_CORES-1).W))                                     

  val core_hang_up                              = Output(UInt(1.W))
  val ght_filters_empty                         = Output(UInt(1.W))
  /* R Features */
  val ic_crnt_target                            = Input(UInt(5.W)) 
  val gh_can_fwd                                = Input(UInt(1.W))
  // val gtimer                                    = Input(UInt(62.W))
  // val gtimer_reset                              = Input(UInt(1.W))
  // val use_fi_mode                               = Input(UInt(1.W))
  val ght_buffer_status                         = Output(UInt(2.W))
}




//==========================================================
// Implementations 为了去缓冲数据
//==========================================================
class GH_BUF (val params: GH_BUF_Params)(implicit p: Parameters) extends BoomModule
{
  val io = IO(new GH_BUF_IO(params)(p))
  // val numPackets                                = 2
  val buffer_width                              = (2*params.xlen+8)
  val csr_addr                                  = Wire(Vec(params.core_width, UInt(12.W)))
  val csrshadow_seq                               = Seq(CSRs.fflags.U, CSRs.fcsr.U, CSRs.frm.U)
  
  val u_buffer                                  = Seq.fill(params.core_width) {Module(new GH_FIFO(FIFOParams (params.packet_size, 32)))}
  val can_fwd                                   = WireInit(VecInit.fill(params.core_width)(false.B))


  val core_hang_up                              = u_buffer(params.core_width-1).io.status_threeslots

  // Connecting filters
  val filter_inst_index                         = WireInit(VecInit(Seq.fill(params.core_width)(0.U(8.W))))
  val inst_type_enc                             = WireInit(VecInit(Seq.fill(params.core_width)(0.U(3.W))))
  val filter_packet                             = WireInit(VecInit(Seq.fill(params.core_width)(0.U((2*params.xlen).W))))
  val one                                       = Mux(io.ic_crnt_target(3,0) === 0.U, 0.U, 1.U)
  val dest_OH                                   = WireInit(0.U((GH_GlobalParams.GH_NUM_CORES-1).W))
  val is_amo                                    = WireInit(VecInit(Seq.fill(params.core_width)(false.B)))
  dest_OH                                      := Mux(io.ic_crnt_target(3,0) === 0.U, 0.U, UIntToOH(io.ic_crnt_target(3,0)-1.U))
  dontTouch(dest_OH)
  dontTouch(inst_type_enc)
  for(i <- 0 until params.core_width){
    is_amo(i)                                  := io.commit_valids(i)&&io.commit_uops(i).is_amo
    csr_addr(i)                                := io.commit_uops(i).csr_addr

    inst_type_enc(i)                           := MuxCase(0.U, 
                                                      Array((io.commit_valids(i)&&io.commit_uops(i).uses_ldq) -> 1.U,
                                                            (io.commit_valids(i)&&io.commit_uops(i).uses_stq) -> 2.U,
                                                            (io.commit_valids(i)&&io.commit_uops(i).is_csr&&(!(csr_addr(i)).isOneOf(csrshadow_seq))) -> 3.U
                                                            ))
                                                            
    can_fwd(i)                                 := (io.gh_can_fwd===0.U)&&io.commit_valids(i)&&(io.commit_uops(i).uses_ldq||io.commit_uops(i).uses_stq&&(!io.commit_uops(i).is_fence)||io.commit_valids(i)&&io.commit_uops(i).is_csr&&(!(csr_addr(i)).isOneOf(csrshadow_seq)))
    filter_inst_index(i)                       := Mux(can_fwd(i), Cat(one, io.ic_crnt_target(3,0),inst_type_enc(i)), 0.U)
    filter_packet(i)                           := MuxCase(0.U, 
                                                      Array((io.commit_valids(i)&&io.commit_uops(i).uses_ldq) -> io.alu_in(i),
                                                            (io.commit_valids(i)&&io.commit_uops(i).uses_stq&(!is_amo(i))) -> io.alu_in(i),
                                                            (io.commit_valids(i)&&io.commit_uops(i).uses_stq&(is_amo(i)))  -> Cat(io.gh_prfs_rd(i),io.alu_in(i)(63,0)),
                                                            (io.commit_valids(i)&&io.commit_uops(i).is_csr&&(!(csr_addr(i)).isOneOf(csrshadow_seq))) -> io.gh_prfs_rd(i)
                                                            ))
      Mux(io.commit_valids(i)&&io.commit_uops(i).is_csr&&(!(csr_addr(i)).isOneOf(csrshadow_seq)),io.gh_prfs_rd(i),io.alu_in(i))
  }

  // Connecting buffers: Enqueue Phase
  val buffer_enq_valid                          = WireInit(VecInit(Seq.fill(params.core_width)(false.B)))
  val buffer_enq_data                           = WireInit(VecInit(Seq.fill(params.core_width)(0.U(((params.packet_size)).W))))
  val buffer_empty                              = WireInit(VecInit(Seq.fill(params.core_width)(false.B)))
  val buffer_full                               = WireInit(VecInit(Seq.fill(params.core_width)(false.B)))
  val buffer_deq_data                           = WireInit(VecInit(Seq.fill(params.core_width)(0.U((params.packet_size).W))))
  val buffer_deq_valid                          = WireInit(false.B)
  val is_valid_packet                           = WireInit(VecInit(Seq.fill(params.core_width)(0.U(13.W))))

  val new_packet                                = WireInit(VecInit(Seq.fill(params.core_width)(false.B)))

  val buffer_inst_type                          = WireInit(VecInit(Seq.fill(params.core_width)(0.U(8.W))))
  val bp                                        = WireInit(VecInit(Seq.fill(params.core_width)(0.U((2*(params.xlen)).W))))
  val doPull                                    = WireInit(0.U(1.W))

  val buffer_enq_ptr                            = RegInit(0.U((log2Ceil(params.core_width)+1).W))//to avoid overflow
  val buffer_deq_ptr                            = RegInit(0.U((log2Ceil(params.core_width)+1).W))
  dontTouch(new_packet)

  val numEnq = WireInit(PopCount(new_packet))
  for (i <- 0 to params.core_width - 1) {
    new_packet(i)                              := (filter_inst_index(i)(6,3) =/= 0.U)         //判断是否传入小核心                                    
    buffer_enq_data(i)                         := Mux((filter_inst_index(i)(6,3) =/= 0.U) ,  
                                                    Cat(filter_inst_index(i), filter_packet(i)), 0.U)//包含目的核心
  }
  //有新数据
  when(new_packet.reduce(_|_)){//需要保证回绕正确
    buffer_enq_ptr := Mux(buffer_enq_ptr + numEnq>=params.core_width.U,buffer_enq_ptr+numEnq-params.core_width.U,buffer_enq_ptr + numEnq)
  }
  val enq_idxs    = VecInit.tabulate(params.core_width)(i => PopCount(new_packet.take(i)))
  val enq_offset  = enq_idxs.map(i=>Mux(buffer_enq_ptr + i>=params.core_width.U,buffer_enq_ptr+i-params.core_width.U,buffer_enq_ptr+i))
  for (i <- 0 to params.core_width - 1) {
    val enq_OH    = (0 until params.core_width).map(idx => (enq_offset(idx) === i.U)&(new_packet(idx)))
    val enq_data  = Mux1H(enq_OH, buffer_enq_data) 
    u_buffer(i).io.enq_valid                   := enq_OH.reduce(_|_)//四个buffer共享入队信号？有可能会出现无效的数据？
    u_buffer(i).io.enq_bits                    := enq_data
  }

  
  // Connecting buffers: Dequeue Phase
  /* Buffer Finite State Machine */
  val buf_all_empty     = WireInit(buffer_empty.reduce(_&_))//全部fifo空
  val buf_almost_empty  = WireInit(PopCount(buffer_empty)>2.U)//此时凑不齐两个data
  val buf_deq_valid     = (!buf_all_empty)


  //这里有重复逻辑!!!
  val deq_idxs          = VecInit.tabulate(GH_GlobalParams.GH_TOTAL_PACKETS)(i => Mux(buffer_deq_ptr+i.U>=params.core_width.U,buffer_deq_ptr+i.U-params.core_width.U,buffer_deq_ptr+i.U))
  dontTouch(deq_idxs)
  dontTouch(buf_deq_valid)
  //vec
  val deq_OH= (0 until GH_GlobalParams.GH_TOTAL_PACKETS).map{i=>
    (0 until params.core_width).map{j=>
      j.U===Mux(buffer_deq_ptr+i.U>=params.core_width.U,buffer_deq_ptr+i.U-params.core_width.U,buffer_deq_ptr+i.U)
    }
  }
  val deq_valid = WireInit(VecInit.fill(params.core_width)(false.B))
  val numDeq    = WireInit(PopCount(deq_valid))
  assert(numDeq<=GH_GlobalParams.GH_TOTAL_PACKETS.U,"Deq too much packet")
  // dontTouch(deq_OH)
//TODO 需要反压
  for (i <- 0 to params.core_width - 1) {
    deq_valid(i)                               := (0 until GH_GlobalParams.GH_TOTAL_PACKETS).map{idx=>
      buf_deq_valid&&deq_idxs(idx)===i.U&&(!buffer_empty(i))&&(!io.cdc_not_ready)
    }.reduce(_|_)
    buffer_empty(i)                            := u_buffer(i).io.empty
    buffer_full(i)                             := u_buffer(i).io.full
    buffer_deq_data(i)                         := Mux(deq_valid(i),u_buffer(i).io.deq_bits,0.U)
    buffer_inst_type(i)                        := buffer_deq_data(i)(buffer_width - 1, (2*params.xlen))
    bp(i)                                      := buffer_deq_data(i)((2*params.xlen) - 1, 0)
    u_buffer(i).io.deq_ready                   := deq_valid(i)
    is_valid_packet(i)                         := Mux(buffer_inst_type(i) =/= 0.U, 1.U, 0.U)
  }


  val out_buf                                   = WireInit(VecInit(Seq.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U(((2*params.xlen)).W))))
  val out_inst_type                             = WireInit(VecInit(Seq.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U((8).W))))
  // val out_packet                                = RegInit(VecInit(Seq.fill(numPackets)(0.U((params.packet_size).W))))
  val packet_out                                = WireInit(VecInit(Seq.fill(GH_GlobalParams.GH_TOTAL_PACKETS)(0.U((params.packet_size).W))))
  // ((7,0),(127,0)) 只需要136bit
  for(i <- 0 until GH_GlobalParams.GH_TOTAL_PACKETS){
    out_buf(i)        := Mux1H(deq_OH(i),bp)
    out_inst_type(i)  := Mux1H(deq_OH(i),buffer_inst_type) 
    packet_out(i)     := Cat(out_inst_type(i),out_buf(i))
  }
  dontTouch(out_buf)
  dontTouch(out_inst_type)
  dontTouch(packet_out)
  when(deq_valid.reduce(_|_)){
    buffer_deq_ptr := Mux(buffer_deq_ptr + numDeq>=params.core_width.U,buffer_deq_ptr+numDeq-params.core_width.U,buffer_deq_ptr + numDeq)
  }


  if (GH_GlobalParams.GH_DEBUG == 1) {
    when(deq_valid.reduce(_||_)){
        printf(midas.targetutils.SynthesizePrintf("BOOM Packet: Dest0 %d Data %x Dest1 %d Data %x\n",
          out_inst_type(0)(6,3), out_buf(0),
          out_inst_type(1)(6,3), out_buf(1)))
    }
  }
  // dontTouch()
  // Outputs
  io.packet_out                               := Cat(packet_out.reverse) // Added inst_type for checker cores
  io.core_hang_up                             := core_hang_up 
  io.ght_buffer_status                        := Cat(buffer_full(params.core_width-1), buf_all_empty)
  io.ght_filters_empty                        := buf_all_empty//需要去加入cdc cnt
  io.gh_packet_dest                           := out_inst_type.map(i=>i(6,3)).reduce(_|_)
}