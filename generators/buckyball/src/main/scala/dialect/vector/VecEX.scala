package dialect.vector

package dialect.vector
import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters

import dialect.vector._
import buckyball.frontend.rs.{ReservationStationIssue, ReservationStationComplete, BuckyBallCmd}
import buckyball.mem.{SramReadIO, SramWriteIO, SramReadResp}
import buckyball.BuckyBallConfig

class VecEX(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
    val rob_id_width = log2Up(bbconfig.rob_entries)
    val spad_w = bbconfig.veclane * bbconfig.inputType.getWidth

    val io = IO(new Bundle {
        val sramWrite = Vec(bbconfig.sp_banks, Flipped(Decoupled(new SramWriteIO(bbconfig.sp_bank_entries, spad_w, spad_w/8))))
        val lu_ex_i = Flipped(Decoupled(new lu_ex_req))
        val sramReadResp = Vec(bbconfig.sp_banks, new SramReadResp(spad_w))
  })
    // 提取预译码的相关信号
    val op1_bank = io.lu_ex_i.bits.op1_bank
    val op2_bank = io.lu_ex_i.bits.op2_bank
    val wr_bank = io.lu_ex_i.bits.wr_bank
    val wr_bank_addr = io.lu_ex_i.bits.wr_bank_addr
    val opcode = io.lu_ex_i.bits.opcode

    // 结果寄存器
    val result = RegInit(0.U(spad_w.W))


    // 写回结果到SRAM
    for (i <- 0 until bbconfig.sp_banks) {
        io.sramWrite(i).valid := false.B
        io.sramWrite(i).bits.addr := 0.U
        io.sramWrite(i).bits.data := 0.U
        io.sramWrite(i).bits.mask := 0.U
    }

    when(io.lu_ex_i.valid) {
        io.sramWrite(wr_bank).valid := true.B
        io.sramWrite(wr_bank).bits.addr := wr_bank_addr
        io.sramWrite(wr_bank).bits.data := io.sramReadResp(op1_bank).data + io.sramReadResp(op2_bank).data
        io.sramWrite(wr_bank).bits.mask := Fill(spad_w/8, 1.U)
    }

    // 响应完成信号
    io.lu_ex_i.ready := true.B
}