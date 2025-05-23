package gemmini.VecUnit
import chisel3._
import chisel3.util._
import gemmini.GemminiISA._
import gemmini.Util._
import org.chipsalliance.cde.config.Parameters
import midas.targetutils.PerfCounter
import gemmini.{GemminiArrayConfig, Arithmetic, ScratchpadReadIO, ScratchpadWriteIO, GemminiCmd}
import gemmini.{AccumulatorReadReq, AccumulatorWriteReq, AccumulatorScaleResp, Activation}
import gemmini.VecUnit.ex.VecThread
// import gemmini.VecUnit.ex.VecLUTThread
// import gemmini.VecUnit.ex.VecTC
import gemmini.GemminiISA._
import gemmini.VecUnit.ex.{Vec4PE, Vec8PE}
class VecEX [T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V]) 
                                (implicit p: Parameters, ev: Arithmetic[T])extends Module{
    import config._
    import ev._
  val io = IO(new Bundle {
    val iss_ex_i = Flipped(Decoupled(new IssExReq()))
    val ex_cmt_o = Decoupled(new ExCmtReq())
     val acc = new Bundle {
            val read_req = Vec(acc_banks, Decoupled(new AccumulatorReadReq(
                acc_bank_entries, accType, acc_scale_t
            )))

            val read_resp = Flipped(Vec(acc_banks, Decoupled(new AccumulatorScaleResp(
                Vec(meshColumns, Vec(tileColumns, inputType)),
                Vec(meshColumns, Vec(tileColumns, accType))
            ))))

            val write = Vec(acc_banks, Decoupled(new AccumulatorWriteReq(acc_bank_entries, Vec(meshColumns, Vec(tileColumns, accType)))))
            }
  })
  val vec8PE  = Module(new Vec8PE())
  val vec4PE1 = Module(new Vec4PE())
  val vec4PE2 = Module(new Vec4PE())
  io.iss_ex_i.ready := true.B

  vec4PE1.io.out.ready := io.ex_cmt_o.ready
  vec4PE2.io.out.ready := io.ex_cmt_o.ready
  vec8PE.io.out.ready := io.ex_cmt_o.ready

  vec4PE1.io.west <> DontCare
  vec8PE.io.west <> vec4PE1.io.east
  vec4PE2.io.west <> vec8PE.io.east
  vec4PE2.io.east.ready := io.ex_cmt_o.ready

  vec4PE1.io.in.valid := false.B
  vec4PE1.io.in.bits := DontCare
  vec4PE2.io.in.valid := false.B
  vec4PE2.io.in.bits := DontCare
  vec8PE.io.in.valid := false.B
  vec8PE.io.in.bits := DontCare
  vec4PE1.io.thread_id := 0.U
  vec4PE2.io.thread_id := 0.U
  vec8PE.io.thread_id := 0.U

  when(io.iss_ex_i.valid && io.iss_ex_i.bits.mode === 0.U){
    when(io.iss_ex_i.bits.funct === INST_Vec_LoopMul_CMD_16){
      vec4PE1.io.west.valid := true.B
      vec4PE1.io.west.bits.vector_rst := VecInit(Seq.fill(16)(0.U(8.W)))
      vec4PE1.io.west.bits.funct := io.iss_ex_i.bits.funct
      vec4PE1.io.west.bits.waddr := io.iss_ex_i.bits.waddr
      when(io.iss_ex_i.bits.thread_id <= 3.U){
        vec4PE1.io.in <> io.iss_ex_i
        vec4PE1.io.thread_id := io.iss_ex_i.bits.thread_id
      }.elsewhen(io.iss_ex_i.bits.thread_id <= 11.U && io.iss_ex_i.bits.thread_id > 3.U){
        vec8PE.io.in <> io.iss_ex_i
        vec8PE.io.thread_id := io.iss_ex_i.bits.thread_id - 4.U
      }.otherwise{
        vec4PE2.io.in <> io.iss_ex_i
        vec4PE2.io.thread_id := io.iss_ex_i.bits.thread_id - 12.U
      }
    }.elsewhen(io.iss_ex_i.bits.funct === INST_Vec_LoopMul_CMD_4){
      vec4PE1.io.west.valid := true.B
      vec4PE1.io.west.bits.vector_rst := VecInit(Seq.fill(16)(0.U(8.W)))
      vec4PE1.io.west.bits.funct := io.iss_ex_i.bits.funct
      vec4PE1.io.west.bits.waddr := io.iss_ex_i.bits.waddr
      vec4PE1.io.in <> io.iss_ex_i
      vec4PE1.io.thread_id := io.iss_ex_i.bits.thread_id
    }.elsewhen(io.iss_ex_i.bits.funct === INST_Vec_LoopMul_CMD_8){
      vec8PE.io.in <> io.iss_ex_i
      vec8PE.io.thread_id := io.iss_ex_i.bits.thread_id
      vec8PE.io.west.bits.funct := io.iss_ex_i.bits.funct
      vec8PE.io.west.bits.waddr := io.iss_ex_i.bits.waddr
      vec8PE.io.west.valid := true.B
      vec8PE.io.west.bits.vector_rst := VecInit(Seq.fill(16)(0.U(8.W)))
    }
  }

  io.ex_cmt_o.valid := false.B
  io.ex_cmt_o.bits := DontCare
  when(vec4PE1.io.out.bits.funct === INST_Vec_LoopMul_CMD_4){
    io.ex_cmt_o.valid := vec4PE1.io.out.valid
    io.ex_cmt_o.bits := vec4PE1.io.out.bits
  }.elsewhen(vec8PE.io.out.bits.funct === INST_Vec_LoopMul_CMD_8){
    io.ex_cmt_o.valid := vec8PE.io.out.valid
    io.ex_cmt_o.bits := vec8PE.io.out.bits
  }.otherwise{
    io.ex_cmt_o.valid := false.B
    io.ex_cmt_o.bits := DontCare
  }


  val vec4PE2_out_d1 = RegNext(vec4PE2.io.out.valid)
  val in_valid_d1 = RegNext(io.iss_ex_i.valid)
  val read_acc = RegInit(false.B)
  val clear_acc = RegInit(false.B)
  val acc_write_counter = RegInit(0.U(4.W))
  val acc_read_counter = RegInit(0.U(4.W))
  val acc_clear_counter = RegInit(0.U(4.W))

  //---------------------------------默认赋值---------------------------------
  for(i <- 0 until acc_banks){
        //读请求
        io.acc.read_req(i).bits.addr := 0.U
        io.acc.read_req(i).valid := false.B
        io.acc.read_req(i).bits.scale := 1.U.asTypeOf(acc_scale_t)
        io.acc.read_req(i).bits.full := false.B
        io.acc.read_req(i).bits.fromDMA := false.B
        io.acc.read_req(i).bits.igelu_qb := DontCare
        io.acc.read_req(i).bits.igelu_qc := DontCare
        io.acc.read_req(i).bits.iexp_qln2 := DontCare
        io.acc.read_req(i).bits.iexp_qln2_inv := DontCare
        io.acc.read_req(i).bits.act       := Activation.NONE
        //读响应
        io.acc.read_resp(i).ready := true.B
        //写请求
        io.acc.write(i).bits.addr := 0.U
        io.acc.write(i).bits.data := VecInit(Seq.fill(meshColumns)(VecInit(Seq.fill(tileColumns)(0.U.asTypeOf(accType)))))
        io.acc.write(i).valid := false.B
        io.acc.write(i).bits.mask := VecInit(Seq.fill(64)(true.B))
        io.acc.write(i).bits.acc  := false.B
        io.acc.write(i).bits.fast_write := false.B
        io.acc.write(i).bits.end_fast_write := false.B
    }
  //---------------------------------读写ACC---------------------------------
  when(io.iss_ex_i.bits.funct === INST_Vec_LoopMul_CMD_16 && io.iss_ex_i.bits.mode === 0.U ){
    when(vec4PE2_out_d1 && !vec4PE2.io.out.valid) {
      read_acc := true.B
    }.elsewhen(acc_read_counter === 15.U) {
      read_acc := false.B
    }
    when(io.iss_ex_i.valid && !in_valid_d1){
      clear_acc := true.B
    }.elsewhen(acc_clear_counter === 15.U){
      clear_acc := false.B
    }
    //写入部分和
    when(vec4PE2.io.out.valid && io.acc.write(acc_write_counter).ready){
      acc_write_counter := acc_write_counter + 1.U
      io.acc.write(acc_write_counter).valid := true.B
      io.acc.write(acc_write_counter).bits.addr := 0.U
      io.acc.write(acc_write_counter).bits.data := VecInit.tabulate(16)(i => VecInit(Seq(vec4PE2.io.out.bits.wb_data(i).asSInt.pad(32))))
      io.acc.write(acc_write_counter).bits.mask := VecInit(Seq.fill(64)(true.B))
      io.acc.write(acc_write_counter).bits.acc  := true.B
    }
    //清除ACC内的旧数据
    when(clear_acc && io.acc.write(acc_clear_counter).ready){
      acc_clear_counter := acc_clear_counter + 1.U
      io.acc.write(acc_clear_counter).valid := true.B
      io.acc.write(acc_clear_counter).bits.addr := 0.U
      io.acc.write(acc_clear_counter).bits.data := VecInit(Seq.fill(meshColumns)(VecInit(Seq.fill(tileColumns)(0.U.asTypeOf(accType)))))
      io.acc.write(acc_clear_counter).bits.acc  := false.B
    }
    when(read_acc){
      acc_read_counter := acc_read_counter + 1.U
      io.acc.read_req(acc_read_counter).valid := true.B
    }
    for(i <- 0 until acc_banks){
      when(io.acc.read_resp(i).valid){
        val wb_data = VecInit(Seq.fill(16)(0.U(8.W)))
        for(j <- 0 until 16){
          wb_data(j) := io.acc.read_resp(i).bits.data(j).asUInt(7,0)
        }
        io.ex_cmt_o.valid := true.B
        io.ex_cmt_o.bits.wb_data := wb_data
        io.ex_cmt_o.bits.wb_addr := io.iss_ex_i.bits.waddr
        io.ex_cmt_o.bits.wb_en := true.B
        io.ex_cmt_o.bits.is_acc := true.B
        io.ex_cmt_o.bits.rob_id := io.iss_ex_i.bits.rob_id
        io.ex_cmt_o.bits.funct := io.iss_ex_i.bits.funct
      }
    }          
  }.elsewhen(io.iss_ex_i.valid && io.iss_ex_i.bits.mode === 1.U && 
            io.iss_ex_i.bits.funct === INST_Vec_LoopMul_CMD_16){
    val clear_acc :: fast_write :: end_fast_write :: read_acc :: Nil = Enum(4)
    for(i <- 0 until acc_banks){
      when(io.acc.write(i).ready){
        when(io.iss_ex_i.bits.config === fast_write){
          io.acc.write(i).valid := true.B
          io.acc.write(i).bits.data := VecInit.tabulate(16)(i => VecInit(Seq(io.iss_ex_i.bits.op1(i).asSInt.pad(32))))
          io.acc.write(i).bits.mask := VecInit(Seq.fill(64)(true.B))
          io.acc.write(i).bits.acc  := true.B
          io.acc.write(i).bits.fast_write := true.B
        }.elsewhen(io.iss_ex_i.bits.config === end_fast_write){
          io.acc.write(i).valid := true.B
          io.acc.write(i).bits.mask := VecInit(Seq.fill(64)(true.B))
          io.acc.write(i).bits.fast_write := true.B
          io.acc.write(i).bits.end_fast_write := true.B
          io.acc.write(i).bits.acc := true.B
        }.elsewhen(io.iss_ex_i.bits.config === clear_acc){
          io.acc.write(i).valid := true.B
          io.acc.write(i).bits.data := VecInit.tabulate(16)(i => VecInit(Seq(0.U.asSInt.pad(32))))
          io.acc.write(i).bits.mask := VecInit(Seq.fill(64)(true.B))
        }
      }
      when(io.iss_ex_i.bits.config === read_acc &&io.acc.read_resp(i).ready){
        io.acc.read_req(i).valid := true.B
      }
    }
  }
}
 