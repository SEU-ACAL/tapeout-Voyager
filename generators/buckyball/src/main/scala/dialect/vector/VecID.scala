package dialect.vector

package dialect.vector
import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters

import dialect.vector._
import buckyball.frontend.rs.{ReservationStationIssue, ReservationStationComplete, BuckyBallCmd}
import buckyball.mem.{SramReadIO, SramWriteIO}
import buckyball.BuckyBallConfig

class VecID(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
    val rob_id_width = log2Up(bbconfig.rob_entries)
    val spad_w = bbconfig.veclane * bbconfig.inputType.getWidth

    val io = IO(new Bundle{
        val cmdReq = Flipped(Decoupled(new ReservationStationIssue(new BuckyBallCmd, rob_id_width)))
        val cmdResp = Decoupled(new ReservationStationComplete(rob_id_width))
    
        val id_lu_o = Decoupled(new id_lu_req)
    })
    
    //寄存器定义
    val rob_id_reg = RegInit(0.U(rob_id_width.W))
    val iteration_reg = RegInit(0.U(10.W)) 

    //提取预译码的相关信号
    val op1_bank = io.cmdReq.bits.cmd.post_decode_cmd.op1_bank
    val op1_bank_addr = io.cmdReq.bits.cmd.post_decode_cmd.op1_bank_addr
    val op2_bank = io.cmdReq.bits.cmd.post_decode_cmd.op2_bank
    val op2_bank_addr = io.cmdReq.bits.cmd.post_decode_cmd.op2_bank_addr
    val wr_bank = io.cmdReq.bits.cmd.post_decode_cmd.wr_bank
    val wr_bank_addr = io.cmdReq.bits.cmd.post_decode_cmd.wr_bank_addr
    val iteration = io.cmdReq.bits.cmd.post_decode_cmd.iter

    //迭代计数
    when(io.cmdReq.valid){
        rob_id_reg := io.cmdReq.bits.rob_id
        iteration_reg := Mux(iteration_reg === iteration, 0.U, iteration_reg + 1.U)
    }

    //生成ID_LU请求
    io.id_lu_o.valid := io.cmdReq.valid
    io.id_lu_o.bits.op1_bank := op1_bank
    io.id_lu_o.bits.op1_bank_addr := op1_bank_addr + iteration_reg
    io.id_lu_o.bits.op2_bank := op2_bank
    io.id_lu_o.bits.op2_bank_addr := op2_bank_addr + iteration_reg
    io.id_lu_o.bits.wr_bank := wr_bank
    io.id_lu_o.bits.wr_bank_addr := wr_bank_addr
    io.id_lu_o.bits.opcode := 1.U

    io.cmdReq.ready := io.id_lu_o.ready

    //指令完成信号
    val complete = iteration_reg === iteration && io.cmdReq.valid
    io.cmdResp.bits.rob_id := rob_id_reg
    io.cmdResp.valid := complete

}