package gemmini

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.diplomacy.{LazyModule, LazyModuleImp}
import freechips.rocketchip.rocket._
import freechips.rocketchip.tile._
import freechips.rocketchip.tilelink._

// TODO do we still need to flush when the dataflow is weight stationary? Won't the result just keep travelling through on its own?
class ScratchpadVecController[T <: Data, U <: Data, V <: Data](xLen: Int, tagWidth: Int, config: GemminiArrayConfig[T, U, V])
                                  (implicit p: Parameters, ev: Arithmetic[T]) extends Module {
  import config._
  import ev._

  val io = IO(new Bundle {
     val acc_in = new Bundle {
        val read_req = Flipped(Vec(acc_banks, Decoupled(new AccumulatorReadReq(
          acc_bank_entries, accType, acc_scale_t.asInstanceOf[V]
        ))))
        val read_resp = Vec(acc_banks, Decoupled(new AccumulatorScaleResp(
          Vec(meshColumns, Vec(tileColumns, inputType)),
          Vec(meshColumns, Vec(tileColumns, accType))
        )))
        val write = Flipped(Vec(acc_banks, Decoupled(new AccumulatorWriteReq(
          acc_bank_entries, Vec(meshColumns, Vec(tileColumns, accType))
        ))))
      }
     val acc_out = new Bundle {
        val read_req = Vec(acc_banks, Decoupled(new AccumulatorReadReq(
          acc_bank_entries, accType, acc_scale_t
      )))

      val read_resp = Flipped(Vec(acc_banks, Decoupled(new AccumulatorScaleResp(
        Vec(meshColumns, Vec(tileColumns, inputType)),
        Vec(meshColumns, Vec(tileColumns, accType))
      ))))

      // val write = Vec(acc_banks, new AccumulatorWriteIO(acc_bank_entries, Vec(meshColumns, Vec(tileColumns, accType))))
      val write = Vec(acc_banks, Decoupled(new AccumulatorWriteReq(acc_bank_entries, Vec(meshColumns, Vec(tileColumns, accType)))))
      }      
  })
//默认连接
  io.acc_out.read_req <> io.acc_in.read_req
  io.acc_in.read_resp <> io.acc_out.read_resp
  io.acc_out.write <> io.acc_in.write

  val regs = RegInit(
    VecInit(Seq.fill(acc_banks)(
        VecInit(Seq.fill(meshColumns)(
          VecInit(Seq.fill(tileColumns)(0.U.asTypeOf(accType)))
        ))
      )
    ))
  for (i <- 0 until acc_banks) {
    when(io.acc_in.write(i).valid && io.acc_in.write(i).bits.fast_write) {
      for (j <- 0 until meshColumns) {
        for (k <- 0 until tileColumns) {
          regs(i)(j)(k) := io.acc_in.write(i).bits.data(j)(k) + regs(i)(j)(k)
        }
      }
      io.acc_out.write(i).valid := false.B
      when(io.acc_out.write(i).ready && io.acc_in.write(i).bits.end_fast_write) {
        io.acc_out.write(i).valid := true.B
        io.acc_out.write(i).bits.data := regs(i)
      }
    }
  }
  
}
