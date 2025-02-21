package freechips.rocketchip.npu

import chisel3._
import chisel3.util._
import chisel3.util.HasBlackBoxResource
import chisel3.experimental.IntParam
import org.chipsalliance.cde.config._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.rocket._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.util.InOrderArbiter
import freechips.rocketchip.tile._

case object BuildRoCCNpu extends Field[Seq[Parameters => LazyRoCCNpu]](Nil)
class RoCCNpuCommand(implicit p: Parameters) extends CoreBundle()(p) {
  val inst = new RoCCInstruction
  val rs1 = Bits(xLen.W)
  val rs2 = Bits(xLen.W)
  val status = new MStatus
}

class RoCCNpuResponse(implicit p: Parameters) extends CoreBundle()(p) {
  val rd = Bits(5.W)
  val data = Bits(xLen.W)
}

class RoCCNpuCoreIO(implicit p: Parameters) extends CoreBundle()(p) {
  val cmd = Flipped(Decoupled(new RoCCNpuCommand))
  val resp = Decoupled(new RoCCNpuResponse)
  val mem = new HellaCacheIO
  val busy = Output(Bool())
  val interrupt = Output(Bool())
  val exception = Input(Bool())

  val custom    = Input(Bool())
}

class RoCCNpuIO(val nPTWPorts: Int)(implicit p: Parameters) extends RoCCNpuCoreIO()(p) {
  val ptw = Vec(nPTWPorts, new TLBPTWIO)
  val fpu_req = Decoupled(new FPInput)
  val fpu_resp = Flipped(Decoupled(new FPResult))
}

/** Base classes for Diplomatic TL2 Npu RoCC units **/
abstract class LazyRoCCNpu(
      val opcodes: OpcodeSet,
      val nPTWPorts: Int = 0,
      val usesFPU: Boolean = false
    )(implicit p: Parameters) extends LazyModule {
  val module: LazyRoCCNpuModuleImp
  val atlNode: TLNode = TLIdentityNode()
  val tlNode: TLNode = TLIdentityNode()
}

class LazyRoCCNpuModuleImp(outer: LazyRoCCNpu) extends LazyModuleImp(outer) {
  val io = IO(new RoCCNpuIO(outer.nPTWPorts))
}

class RoccNpuCommandRouter(opcodes: Seq[OpcodeSet])(implicit p: Parameters)
    extends CoreModule()(p) {
  val io = new Bundle {
    val in = Flipped(Decoupled(new RoCCNpuCommand))
    val out = Vec(opcodes.size, Decoupled(new RoCCNpuCommand))
    val busy = Output(Bool())
  }

  val cmd = Queue(io.in)
  val cmdReadys = io.out.zip(opcodes).map { case (out, opcode) =>
    val me = opcode.matches(cmd.bits.inst.opcode)
    out.valid := cmd.valid && me
    out.bits := cmd.bits
    out.ready && me
  }
  cmd.ready := cmdReadys.reduce(_ || _)
  io.busy := cmd.valid

  assert(PopCount(cmdReadys) <= 1.U,
    "Custom opcode matched for more than one accelerator")
}

/** Mixins for including RoCC **/

trait HasLazyRoCCNpu extends CanHavePTW { this: BaseTile =>
  val roccs = p(BuildRoCCNpu).map(_(p))

  roccs.map(_.atlNode).foreach { atl => tlMasterXbar.node :=* atl }
  roccs.map(_.tlNode).foreach { tl => tlOtherMastersNode :=* tl }

  nPTWPorts += roccs.map(_.nPTWPorts).sum
  nDCachePorts += roccs.size
}

trait HasLazyRoCCNpuModule extends CanHavePTWModule
    with HasCoreParameters { this: RocketTileNpuModuleImp with HasFpuNpuOpt =>

  val (respArb, cmdRouter) = if(outer.roccs.nonEmpty) {
    val respArb = Module(new RRArbiter(new RoCCNpuResponse()(outer.p), outer.roccs.size))
    val cmdRouter = Module(new RoccNpuCommandRouter(outer.roccs.map(_.opcodes))(outer.p))
    outer.roccs.zipWithIndex.foreach { case (rocc, i) =>
      rocc.module.io.ptw ++=: ptwPorts
      rocc.module.io.cmd <> cmdRouter.io.out(i)
      rocc.module.io.custom := false.B
      val dcIF = Module(new SimpleHellaCacheIF()(outer.p))
      dcIF.io.requestor <> rocc.module.io.mem
      dcachePorts += dcIF.io.cache
      respArb.io.in(i) <> Queue(rocc.module.io.resp)
    }

    fpuOpt foreach { fpu =>
      val nFPUPorts = outer.roccs.count(_.usesFPU)
      if (usingFPU && nFPUPorts > 0) {
        val fpArb = Module(new InOrderArbiter(new FPInput()(outer.p), new FPResult()(outer.p), nFPUPorts))
        val fp_rocc_ios = outer.roccs.filter(_.usesFPU).map(_.module.io)
        fpArb.io.in_req <> fp_rocc_ios.map(_.fpu_req)
        fp_rocc_ios.zip(fpArb.io.in_resp).foreach {
          case (rocc, arb) => rocc.fpu_resp <> arb
        }
        fpu.io.cp_req <> fpArb.io.out_req
        fpArb.io.out_resp <> fpu.io.cp_resp
      } else {
        fpu.io.cp_req.valid := false.B
        fpu.io.cp_resp.ready := false.B
      }
    }
    (Some(respArb), Some(cmdRouter))
  } else {
    (None, None)
  }
}
