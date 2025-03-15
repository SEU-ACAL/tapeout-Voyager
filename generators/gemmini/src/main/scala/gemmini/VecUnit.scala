
package gemmini

import chisel3._
import chisel3.util._
import GemminiISA._
import Util._
import org.chipsalliance.cde.config.Parameters
import midas.targetutils.PerfCounter
import freechips.rocketchip.npu.CSR.S

class VecUnit[T <: Data, U <: Data, V <: Data](xLen: Int, tagWidth: Int, config: GemminiArrayConfig[T, U, V], entries: Int, heads: Int, maxpop: Int=2 )
                                  (implicit p: Parameters, ev: Arithmetic[T]) extends Module {
    import config._
    import ev._
    val io = IO(new Bundle {
        val cmd = new Bundle {
            val valid = Input(Vec(heads, Bool()))
            val bits = Input(Vec(heads, new GemminiCmd(reservation_station_entries)))
            val pop = Output(UInt(log2Ceil((entries min maxpop) + 1).W))
        }
        val srams = new Bundle {
            val read = new ScratchpadReadIO(sp_bank_entries, sp_width)
            val write = new ScratchpadWriteIO(sp_bank_entries, sp_width, (sp_width / (aligned_to * 8)) max 1)
        }
        val completed = Valid(UInt(log2Up(reservation_station_entries).W))
    })

    val RespData = io.srams.read.resp.bits.data
    val RespValid = io.srams.read.resp.valid
    val S1_counter = RegInit(0.U(5.W))
    val functs = io.cmd.bits.map(_.cmd.inst.funct)
    val rs1s = VecInit(io.cmd.bits.map(_.cmd.rs1))
    //新增vec计算指令译码
    val DoLoadMulAdd = functs(0) === LOAD_MUL_ADD_CMD
    val DoStore = functs(0) === STORE_VEC_CMD
    val DoPreloadScalar = functs(0) === PRELOAD_SCALAR_CMD
    val DoBroadcast = functs(0) === BROADCAST_CMD


    val VecRead = WireInit(false.B)
    val ScalarRead = WireInit(false.B)
    val VecAddr = rs1s(0)(15,0) + S1_counter
    val ScalarAddr = rs1s(0)(31,16) + S1_counter
   
    io.srams.read.req.valid :=  VecRead || ScalarRead//|| ((VecState === inputA) && perform_vec_add_vec) || (VecState === inputB) //删掉了控制信号队列的cntl_ready
    io.srams.read.req.bits.fromDMA := false.B
    io.srams.read.req.bits.addr := MuxCase(DontCare,
    Seq(
      (VecRead, VecAddr),
      (ScalarRead, ScalarAddr)
    ))


    val queue = Module(new Queue(new GemminiCmd(1), 8))
    val ScalarRegs = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
    val OperationLength = RegInit(1.U(5.W))

    val idle :: load_mul_add :: load_scalar :: store :: Nil = Enum(4)
    val S1_state = RegInit(idle)
    //----------------------S1-----------------------------
    //默认赋值
    queue.io.enq.valid := false.B
    io.cmd.pop := false.B
    io.completed.valid := false.B
    io.completed.bits := 0.U
    queue.io.enq.bits := DontCare
    when(DoLoadMulAdd && io.cmd.valid(0) && io.srams.read.req.ready){
        when(S1_state === idle){
        OperationLength := rs1s(0)(35,32)
        S1_state := load_scalar
        }.elsewhen(S1_state === load_scalar){
        when(S1_counter === OperationLength + 1.U){
            S1_counter := 0.U
            S1_state := idle
            queue.io.enq.valid := false.B
            io.cmd.pop := true.B
            io.completed.bits := io.cmd.bits(0).rob_id.bits
            io.completed.valid := true.B
        }.otherwise{
            S1_state := load_mul_add
            ScalarRead := true.B
            queue.io.enq.valid := true.B
            queue.io.enq.bits.cmd.inst.funct := PRELOAD_SCALAR_CMD
        }
        }.otherwise{
        S1_state := load_scalar
        S1_counter := S1_counter + 1.U
        ScalarRead := true.B
        queue.io.enq.valid := true.B
        queue.io.enq.bits.cmd.inst.funct := LOAD_MUL_ADD_CMD
        queue.io.enq.bits.cmd.rs1 := S1_counter
        VecRead := true.B
        }
    }.elsewhen(io.cmd.valid(0) && DoStore){
        when(S1_state === idle){
        S1_state := store
        OperationLength := rs1s(0)(19,16)
        }.otherwise{
        S1_counter := S1_counter + 1.U
        queue.io.enq.valid := true.B
        queue.io.enq.bits.cmd.inst.funct := STORE_VEC_CMD
        queue.io.enq.bits.cmd.rs1 := Cat(S1_counter, rs1s(0)(15,0)) 
        when(S1_counter === OperationLength + 1.U){
            S1_counter := 0.U
            S1_state := idle
            queue.io.enq.valid := false.B
            io.cmd.pop := true.B
            io.completed.bits := io.cmd.bits(0).rob_id.bits
            io.completed.valid := true.B
        }
        }
    }.elsewhen(io.cmd.valid(0) && DoBroadcast){
        queue.io.enq.valid := true.B
        queue.io.enq.bits.cmd.inst.funct := BROADCAST_CMD
        io.cmd.pop := true.B
        io.completed.bits := io.cmd.bits(0).rob_id.bits
        io.completed.valid := true.B
    }
    val S1_cmd = queue.io.deq.bits.cmd
    val S1_valid = queue.io.deq.valid && !(S1_cmd.inst.funct === LOAD_MUL_ADD_CMD && !RespValid)
    //-------------------S2-----------------------------
    val S2_valid = RegInit(false.B)
    S2_valid := S1_valid
    val S2_vec = RegInit(VecInit(Seq.fill(16)(0.U(8.W))))
    val S2_cmd_funct = RegInit(UInt(7.W), 0.U)
    S2_cmd_funct := S1_cmd.inst.funct
    val S2_cmd_rs1 = RegInit(UInt(64.W), 0.U)
    S2_cmd_rs1 := S1_cmd.rs1

    io.srams.read.resp.ready := false.B
    queue.io.deq.ready := false.B
    S2_vec := VecInit(Seq.fill(16)(0.U(8.W)))
    when(S1_valid){
        when(RespValid && (S1_cmd.inst.funct === LOAD_MUL_ADD_CMD || S1_cmd.inst.funct === PRELOAD_SCALAR_CMD)){
            io.srams.read.resp.ready := true.B
            queue.io.deq.ready := true.B
            when(S1_cmd.inst.funct === LOAD_MUL_ADD_CMD){
            S2_vec := RespData.asTypeOf(S2_vec)
            }.otherwise{
            ScalarRegs := RespData.asTypeOf(ScalarRegs)
            }
        }.elsewhen(S1_cmd.inst.funct === STORE_VEC_CMD || S1_cmd.inst.funct === BROADCAST_CMD){
            io.srams.read.resp.ready := false.B
            queue.io.deq.ready := true.B
            S2_vec := VecInit(Seq.fill(16)(0.U(8.W)))
        }
    }
    //------------------------S3----------------------
    val S3_valid = RegInit(false.B)
    S3_valid := S2_valid 
    val ResultVecs = RegInit(VecInit(Seq.fill(16)(VecInit(Seq.fill(16)(0.U(8.W))))))
    // val MulResults = WireInit(VecInit(Seq.fill(16)(0.U(8.W))))
    val VecWrite = WireInit(false.B)
    val WriteAddr = S2_cmd_rs1(15,0) + S2_cmd_rs1(20,16)
    val WriteData = ResultVecs(S2_cmd_rs1(20,16)).asTypeOf(UInt(128.W))
    when(S2_valid && S2_cmd_funct === LOAD_MUL_ADD_CMD){
        for (i <- 0 until 16) {
        ResultVecs(i) := ResultVecs(i).zip(S2_vec.map(_ * ScalarRegs(i))).map({case (a, b) => a + b})
        }
    }.elsewhen(S2_valid && S2_cmd_funct === BROADCAST_CMD){
        ResultVecs := VecInit(Seq.fill(16)(VecInit(Seq.fill(16)(0.U(8.W)))))
    }.elsewhen(S2_valid && S2_cmd_funct === STORE_VEC_CMD){
        VecWrite := true.B
    }
    io.srams.write.mask := VecInit(Seq.fill(16)(true.B))
    io.srams.write.addr := WriteAddr
    io.srams.write.data := WriteData
    io.srams.write.en := VecWrite
}