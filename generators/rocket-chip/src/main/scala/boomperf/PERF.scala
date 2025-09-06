package freechips.rocketchip.boom_perf




import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config._
import freechips.rocketchip.tile._


case object HasPERF extends Field[Boolean](false)
class PERF(opcodes: OpcodeSet)(implicit p: Parameters) extends LazyRoCC(opcodes) {
  override lazy val module = new PERFImp (this)
}

class PERFImp(outer: PERF)(implicit p: Parameters) extends LazyRoCCModuleImp(outer)
    with HasCoreParameters {

    val cmd                     = io.cmd
    val funct                   = cmd.bits.inst.funct
    val rs2                     = cmd.bits.inst.rs2
    val rs1                     = cmd.bits.inst.rs1
    val xd                      = cmd.bits.inst.xd
    val xs1                     = cmd.bits.inst.xs1
    val xs2                     = cmd.bits.inst.xs2
    val rd                      = cmd.bits.inst.rd
    val opcode                  = cmd.bits.inst.opcode

    val rs1_val                 = cmd.bits.rs1
    val rs2_val                 = cmd.bits.rs2
    val rd_val                  = WireInit(0.U(xLen.W))


    val doPerfCtrl              = (cmd.fire && (funct === 0x76.U))
    val doPerfRead              = (cmd.fire && (funct === 0x77.U))


    rd_val                     := MuxCase(0.U, 
                                    Array(
                                          doPerfRead          -> io.perf_data_in.getOrElse(0.U)
                                          )
                                          )
                                          






    
    cmd.ready                  := true.B // Currently, it is always ready, because it is never block

    io.resp.valid              := cmd.valid && xd
    io.resp.bits.rd            := cmd.bits.inst.rd
    io.resp.bits.data          := rd_val
    io.busy                    := cmd.valid // Later add more situations
    io.interrupt               := false.B


    val debug_perf_ctrl         = RegInit(0.U(12.W))
    when (doPerfCtrl) {
      debug_perf_ctrl          := rs1_val(11,0)
    }
    io.debug_perf_ctrl.getOrElse(0.U(12.W)) := debug_perf_ctrl
}
