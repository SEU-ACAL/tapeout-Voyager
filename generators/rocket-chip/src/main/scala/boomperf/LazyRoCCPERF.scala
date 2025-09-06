// // See LICENSE.Berkeley for license details.
// // See LICENSE.SiFive for license details.

// package freechips.rocketchip.boom_perf

// import chisel3._
// import chisel3.util._
// import chisel3.experimental.IntParam

// import org.chipsalliance.cde.config._
// import org.chipsalliance.diplomacy.lazymodule._

// import freechips.rocketchip.rocket.{
//   MStatus, HellaCacheIO, TLBPTWIO, CanHavePTW, CanHavePTWModule,
//   SimpleHellaCacheIF, M_XRD, PTE, PRV, M_SZ
// }
// import freechips.rocketchip.tile._
// import freechips.rocketchip.tilelink.{
//   TLNode, TLIdentityNode, TLClientNode, TLMasterParameters, TLMasterPortParameters
// }
// import freechips.rocketchip.util.InOrderArbiter


// case object BuildRoCCPERF extends Field[Seq[Parameters => LazyRoCCPERF]](Nil)
// case object HasPERF extends Field[Boolean](false)

// class RoCCCoreIOPERF(val nRoCCCSRs: Int = 0)(implicit p: Parameters) extends CoreBundle()(p) {
//   val cmd = Flipped(Decoupled(new RoCCCommand))
//   val resp = Decoupled(new RoCCResponse)
//   val mem = new HellaCacheIO
//   val busy = Output(Bool())
//   val interrupt = Output(Bool())
//   val exception = Input(Bool())
//   val csrs = Flipped(Vec(nRoCCCSRs, new CustomCSRIO))

//   val perf_data_in = Input(UInt(64.W))
//   val debug_perf_ctrl = Output(UInt(5.W))
// }

// class RoCCIOPERF(val nPTWPorts: Int, nRoCCCSRs: Int)(implicit p: Parameters) extends RoCCCoreIOPERF(nRoCCCSRs)(p) {
//   val ptw = Vec(nPTWPorts, new TLBPTWIO)
//   val fpu_req = Decoupled(new FPInput)
//   val fpu_resp = Flipped(Decoupled(new FPResult))
// }

// /** Base classes for Diplomatic TL2 RoCC units **/
// abstract class LazyRoCCPERF(
//   val opcodes: OpcodeSet,
//   val nPTWPorts: Int = 0,
//   val usesFPU: Boolean = false,
//   val roccCSRs: Seq[CustomCSR] = Nil
// )(implicit p: Parameters) extends LazyModule {
//   val module: LazyRoCCPERFModuleImp
//   require(roccCSRs.map(_.id).toSet.size == roccCSRs.size)
//   val atlNode: TLNode = TLIdentityNode()
//   val tlNode: TLNode = TLIdentityNode()
//   val stlNode: TLNode = TLIdentityNode()
// }

// class LazyRoCCPERFModuleImp(outer: LazyRoCCPERF) extends LazyModuleImp(outer) {
//   val io = IO(new RoCCIOPERF(outer.nPTWPorts, outer.roccCSRs.size))
//   io := DontCare
// }

// /** Mixins for including RoCC **/
// class OpcodeSetPERF(val opcodes: Seq[UInt]) {
//   def |(set: OpcodeSet) =
//     new OpcodeSet(this.opcodes ++ set.opcodes)

//   def matches(oc: UInt) = opcodes.map(_ === oc).reduce(_ || _)
// }

