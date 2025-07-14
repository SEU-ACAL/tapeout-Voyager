package dialect.vector

package dialect.vector
import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters

import dialect.vector._
import buckyball.frontend.rs.{ReservationStationIssue, ReservationStationComplete, BuckyBallCmd}
import buckyball.mem.{SramReadIO, SramWriteIO, SramReadResp, AccWriteIO}
import buckyball.BuckyBallConfig

class VecEX(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
    val rob_id_width = log2Up(bbconfig.rob_entries)
    val spad_w = bbconfig.veclane * bbconfig.inputType.getWidth

    val io = IO(new Bundle {
        val sramWrite = Vec(bbconfig.sp_banks, new SramWriteIO(bbconfig.sp_bank_entries, spad_w, spad_w/8))
        val lu_ex_i = Flipped(Decoupled(new lu_ex_req))
        val sramReadResp = Vec(bbconfig.sp_banks, Flipped(Decoupled(new SramReadResp(spad_w))))
        val accWrite = Vec(bbconfig.acc_banks, new AccWriteIO(bbconfig.acc_bank_entries, bbconfig.acc_width, bbconfig.acc_width/8))
        val cmdResp = Decoupled(new ReservationStationComplete(rob_id_width))
    })
    // 提取流水线前端的信号
    val op1_bank = io.lu_ex_i.bits.op1_bank
    val op2_bank = io.lu_ex_i.bits.op2_bank
    val wr_bank = io.lu_ex_i.bits.wr_bank
    val opcode = io.lu_ex_i.bits.opcode
    val iter = io.lu_ex_i.bits.iter
    val thread_id = io.lu_ex_i.bits.thread_id

    //创建thread和PE的序列
    implicit val threadParams: ThreadParams = new ThreadParams() 
    val threads = Seq.fill(bbconfig.numVecPE)(Module(new VecThread))
    val PEs = Seq.fill(bbconfig.numVecPE)(Module(new PE()))

    for(i <-0 until bbconfig.numVecPE) {
        //默认thread输入
        threads(i).io.in.valid       := false.B
        threads(i).io.in.bits.op1    := VecInit(Seq.fill(bbconfig.numVecPE)(0.U(8.W)))
        threads(i).io.in.bits.op2    := VecInit(Seq.fill(bbconfig.numVecPE)(0.U(8.W)))
        threads(i).io.in.bits.opcode := 0.U
        threads(i).io.in.bits.iter := 0.U

        //生成thread输入
        when(thread_id(log2Ceil(bbconfig.numVecPE) - 1, 0) === i.U && io.lu_ex_i.valid && 
             io.sramReadResp(op1_bank).valid && io.sramReadResp(op2_bank).valid) {
            threads(i).io.in.valid       := true.B
            threads(i).io.in.bits.op1    := io.sramReadResp(op1_bank).bits.data.asTypeOf(Vec(16, UInt(8.W)))
            threads(i).io.in.bits.op2    := io.sramReadResp(op2_bank).bits.data.asTypeOf(Vec(16, UInt(8.W)))
            threads(i).io.in.bits.opcode := opcode
            threads(i).io.in.bits.iter := iter.min(16.U) // 限制最大迭代次数为16
        }

        //连接PE和thread
        PEs(i).io.north.valid := threads(i).io.out.valid
        PEs(i).io.north.bits.vector_rst := threads(i).io.out.bits.vRst
        PEs(i).io.north.bits.config := 0.U
        threads(i).io.out.ready := PEs(i).io.north.ready
    }

    //PE之间的连接
    for(i <- 1 until 16){
        PEs(i).io.west <> PEs(i - 1).io.east
    }
    PEs(0).io.west.valid := true.B
    PEs(0).io.west.bits := DontCare
    PEs(0).io.west.bits.waddr := io.lu_ex_i.bits.wr_bank_addr
    PEs(bbconfig.numVecPE - 1).io.east.ready := true.B

    val acc_wr_counter = RegInit(0.U(10.W))
    val wr_start_addr = RegEnable(io.lu_ex_i.bits.wr_start_addr, io.lu_ex_i.valid)
    when(PEs(bbconfig.numVecPE - 1).io.east.valid) {
        acc_wr_counter := acc_wr_counter + 1.U
    }.otherwise({
        acc_wr_counter := 0.U
    })
    //SPAD写端口默认赋值
    for(i <- 0 until bbconfig.sp_banks) {
        io.sramWrite(i).en := false.B
        io.sramWrite(i).addr := 0.U
        io.sramWrite(i).data := 0.U
        io.sramWrite(i).mask := VecInit(Seq.fill(spad_w / 8)(false.B))
    }
    for(i <- 0 until bbconfig.acc_banks) {
        io.accWrite(i).en := PEs(bbconfig.numVecPE - 1).io.east.valid
        io.accWrite(i).addr := (wr_start_addr >> log2Ceil(bbconfig.acc_banks)) + acc_wr_counter(log2Ceil(bbconfig.numVecPE) - 1, 0)
        io.accWrite(i).data := PEs(bbconfig.numVecPE - 1).io.east.bits.vector_rst.asUInt(i * 128 + 127, i * 128)
        io.accWrite(i).mask := VecInit(Seq.fill(bbconfig.acc_width / 8)(true.B))
        io.accWrite(i).acc := true.B
    }

    // 响应完成信号
    io.lu_ex_i.ready := true.B
    io.sramReadResp.foreach { resp =>
        resp.ready := true.B
    }

    val rob_id_reg = RegEnable(io.lu_ex_i.bits.rob_id, io.lu_ex_i.valid)
    io.cmdResp.bits.rob_id := rob_id_reg
    io.cmdResp.valid := (acc_wr_counter === iter - 1.U) && PEs(bbconfig.numVecPE - 1).io.east.valid
}