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
import mem.Scratchpad
import frontend.{FrontendTLB, Decoder}
import freechips.rocketchip.buckyball._
import freechips.rocketchip.buckyball.LazyRoCCBB



class BuckyBall(val bbconfig: BuckyBallConfig)(implicit p: Parameters)
  extends LazyRoCCBB (opcodes = bbconfig.opcodes, nPTWPorts = 2) {

  val xLen = p(TileKey).core.xLen   // the width of core's register file
  val spad = LazyModule(new Scratchpad(bbconfig))

  override lazy val module = new BuckyBallModule(this)
  override val tlNode = spad.id_node 
  override val atlNode = TLIdentityNode() 
  val node = tlNode 
}

class BuckyBallModule(outer: BuckyBall) extends LazyRoCCModuleImpBB(outer) 
  with HasCoreParameters {
  import outer.bbconfig._
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
// Frontend: Decode and Command Processing
// -----------------------------------------------------------------------------
  implicit val bbconfig: BuckyBallConfig = outer.bbconfig
  val decoder = Module(new Decoder)
  decoder.io.id_i.valid := io.cmd.valid
  decoder.io.id_i.bits.cmd := io.cmd.bits
  io.cmd.ready := decoder.io.id_i.ready

// -----------------------------------------------------------------------------
// Frontend: Reservation Station with integrated RoB
// -----------------------------------------------------------------------------
  // val rs = Module(new ReservationStation)
  // decoder.io.id_rs <> rs.io.

// -----------------------------------------------------------------------------
// Backend: Load Controller
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
// Backend: Store Controller
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
// Backend: Execute Controller
// -----------------------------------------------------------------------------


  //---------------------------------------------------------------------------
  // 响应接口连接
  //---------------------------------------------------------------------------

}
