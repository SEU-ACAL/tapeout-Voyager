package buckyball

import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.tile._
import freechips.rocketchip.util.ClockGate
import freechips.rocketchip.tilelink.TLIdentityNode
import BBISA._
import front.FrontendTLB
import mem.Scratchpad

import freechips.rocketchip.buckyball._

class BuckyBallCmd(rob_entries: Int)(implicit p: Parameters) extends Bundle {
  val cmd = new RoCCCommandBB
  val rob_id = UInt(log2Up(rob_entries).W)
  val from_matmul_fsm = Bool()
  val from_conv_fsm = Bool()
}

class BuckyBall(val config: BuckyBallConfig)(implicit p: Parameters)
  extends LazyRoCCBB (opcodes = config.opcodes, nPTWPorts = 2) {

  val xLen = p(TileKey).core.xLen   // the width of core's register file
  val spad = LazyModule(new Scratchpad(config))

  override lazy val module = new BuckyBallModule(this)
  override val tlNode = spad.id_node 
  override val atlNode = TLIdentityNode() 
  val node = tlNode 
}

class BuckyBallModule(outer: BuckyBall) extends LazyRoCCModuleImpBB(outer) 
  with HasCoreParameters {
  import outer.config._
  import outer.spad
  
  val tagWidth = 32

// -----------------------------------------------------------------------------
// Frontend: TLB
// -----------------------------------------------------------------------------
  implicit val edge = outer.spad.id_node.edges.out.head
  val tlb = Module(new FrontendTLB(2, tlb_size, dma_maxbytes))
  (tlb.io.clients zip outer.spad.module.io.tlb).foreach(t => t._1 <> t._2)

  tlb.io.exp.foreach(_.flush_skip := false.B)
  tlb.io.exp.foreach(_.flush_retry := false.B)

  io.ptw <> tlb.io.ptw

  spad.module.io.flush := tlb.io.exp.map(_.flush()).reduce(_ || _)
// -----------------------------------------------------------------------------
// Frontend: Decode
// -----------------------------------------------------------------------------
  // val decoder = Module(new Decoder())

// -----------------------------------------------------------------------------
// Frontend: Reservation Station
// -----------------------------------------------------------------------------
  // val rs = Module(new ReservationStation(rob_entries, xLen)) // 使用配置中的 rob_entries


// -----------------------------------------------------------------------------
// Frontend: Instruction Dispatch 
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
// Backend: Load Controller
// -----------------------------------------------------------------------------
  // val LoadModule = Module(new LoadController(xLen))


// -----------------------------------------------------------------------------
// Backend: Store Controller
// -----------------------------------------------------------------------------
  // val StoreModule = Module(new StoreController(xLen))

// -----------------------------------------------------------------------------
// Backend: Execute Controller
// -----------------------------------------------------------------------------
  // val ExecuteModule = Module(new ExecuteController(xLen))  

  //---------------------------------------------------------------------------
  // 流水线连接
  //---------------------------------------------------------------------------
}
