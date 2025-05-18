package gemmini.VecUnit
import chisel3._
import chisel3.util._
import gemmini.GemminiISA._
import gemmini.Util._
import org.chipsalliance.cde.config.Parameters
import midas.targetutils.PerfCounter
import gemmini.{GemminiArrayConfig, Arithmetic, ScratchpadReadIO, ScratchpadWriteIO, GemminiCmd}
import gemmini.{AccumulatorReadReq, AccumulatorWriteReq, AccumulatorScaleResp, Activation}
import gemmini.VecUnit.ex.VecALUThread

import gemmini.GemminiISA._
import gemmini.VecUnit.ex.{Vec4PE, Vec8PE}
class VecEXSparse [T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V]) 
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
    io.iss_ex_i.ready := true.B
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
    }
    io.ex_cmt_o.valid := false.B
    io.ex_cmt_o.bits := DontCare
}