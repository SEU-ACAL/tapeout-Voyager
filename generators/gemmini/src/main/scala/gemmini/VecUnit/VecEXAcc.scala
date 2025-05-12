package gemmini.VecUnit
import chisel3._
import chisel3.util._
import gemmini.GemminiISA._
import gemmini.Util._
import org.chipsalliance.cde.config.Parameters
import midas.targetutils.PerfCounter
import gemmini.{GemminiArrayConfig, Arithmetic, ScratchpadReadIO, ScratchpadWriteIO, GemminiCmd}
import gemmini.{AccumulatorReadReq, AccumulatorWriteReq, AccumulatorScaleResp, Activation}
import freechips.rocketchip.rocket.PRV
import freechips.rocketchip.tilelink.MemoryOpCategories.wr
import os.write
class VecEXAcc[T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V]) 
                                (implicit p: Parameters, ev: Arithmetic[T])extends Module{
    import config._
    import ev._
    val io = IO(new Bundle {
        val iss_ex_i = Flipped(Decoupled(new IssExReq()))
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
    io.iss_ex_i.ready := true.B
    val op1 = io.iss_ex_i.bits.op1
    val op2 = io.iss_ex_i.bits.op2
    val write_to_spad = RegInit(0.U(1.W))
    //默认赋值
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
    }
/*
    when((io.iss_ex_i.bits.thread_id === 15.U && io.iss_ex_i.bits.funct === INST_Vec_LoopMul_CMD_16) ||
            (io.iss_ex_i.bits.thread_id === 7.U && io.iss_ex_i.bits.funct === INST_Vec_LoopMul_CMD_8) ||
            (io.iss_ex_i.bits.thread_id === 3.U && io.iss_ex_i.bits.funct === INST_Vec_LoopMul_CMD_4) 
            ){
                write_to_spad := true.B
            }
                
    
    when(io.iss_ex_i.valid && io.iss_ex_i.bits.funct === INST_Vec_LoopMul_CMD_16){
        for(i <- 0 until acc_banks){
            when(io.acc.write(i).ready){
                val wdata = Wire(Vec(meshColumns, Vec(tileColumns, accType)))
                for(j <- 0 until meshColumns){
                    for(k <- 0 until tileColumns){
                        wdata(j)(k) := op1(i).asTypeOf(accType) * op2(j).asTypeOf(accType)
                    }
                }
                io.acc.write(i).bits.addr := 0.U
                io.acc.write(i).bits.data := wdata
                io.acc.write(i).bits.acc  := true.B
                io.acc.write(i).valid := true.B
                
            }
        }
    }      
        when(write_to_spad === true.B){
            for(i <- 0 until acc_banks){
                when(io.acc.read_resp(i).ready){
                    io.acc.read_req(i).bits.addr := 0.U
                    io.acc.read_req(i).valid := true.B
                    write_to_spad := false.B
                }
               when(io.acc.read_resp(i).valid) {
                    io.acc.write(i).bits.addr := 1.U
                    io.acc.write(i).bits.data := io.acc.read_resp(i).bits.data
                    io.acc.write(i).bits.acc  := true.B
                    io.acc.write(i).valid := true.B
               }
            }
        }
    */
}