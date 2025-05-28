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
import frontend.rs.ReservationStation
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
  val rs = Module(new ReservationStation)
  decoder.io.id_rs <> rs.io.id_i

// =============================================================================
// DEFAULT INITIALIZATION FOR UNCONNECTED SIGNALS - START
// =============================================================================

  // -----------------------------------------------------------------------------
  // Initialize Scratchpad DMA Interfaces
  // -----------------------------------------------------------------------------
  spad.module.io.dma.read.req.valid := false.B
  spad.module.io.dma.read.req.bits.vaddr := 0.U
  spad.module.io.dma.read.req.bits.laddr.is_acc_addr := false.B
  spad.module.io.dma.read.req.bits.laddr.accumulate := false.B
  spad.module.io.dma.read.req.bits.laddr.read_full_acc_row := false.B
  spad.module.io.dma.read.req.bits.laddr.garbage := false.B
  spad.module.io.dma.read.req.bits.laddr.garbage_bit := 0.U
  spad.module.io.dma.read.req.bits.laddr.data := 0.U
  spad.module.io.dma.read.req.bits.len := 0.U
  spad.module.io.dma.read.req.bits.status := 0.U.asTypeOf(new freechips.rocketchip.rocket.MStatus)
  spad.module.io.dma.read.resp.ready := true.B

  spad.module.io.dma.write.req.valid := false.B
  spad.module.io.dma.write.req.bits.vaddr := 0.U
  spad.module.io.dma.write.req.bits.laddr.is_acc_addr := false.B
  spad.module.io.dma.write.req.bits.laddr.accumulate := false.B
  spad.module.io.dma.write.req.bits.laddr.read_full_acc_row := false.B
  spad.module.io.dma.write.req.bits.laddr.garbage := false.B
  spad.module.io.dma.write.req.bits.laddr.garbage_bit := 0.U
  spad.module.io.dma.write.req.bits.laddr.data := 0.U
  spad.module.io.dma.write.req.bits.len := 0.U
  spad.module.io.dma.write.req.bits.status := 0.U.asTypeOf(new freechips.rocketchip.rocket.MStatus)
  spad.module.io.dma.write.req.bits.cmd_id := 0.U
  spad.module.io.dma.write.resp.ready := true.B

  // -----------------------------------------------------------------------------
  // Initialize Scratchpad SRAM Read Interfaces
  // -----------------------------------------------------------------------------
  for (i <- 0 until 4) {
    spad.module.io.srams.read(i).req.valid := false.B
    spad.module.io.srams.read(i).req.bits.addr := 0.U
    spad.module.io.srams.read(i).req.bits.fromDMA := false.B
    spad.module.io.srams.read(i).resp.ready := true.B
  }

  // -----------------------------------------------------------------------------
  // Initialize Scratchpad SRAM Write Interfaces
  // -----------------------------------------------------------------------------
  for (i <- 0 until 4) {
    spad.module.io.srams.write(i).en := false.B
    spad.module.io.srams.write(i).addr := 0.U
    for (j <- 0 until 16) {
      spad.module.io.srams.write(i).mask(j) := false.B
    }
    spad.module.io.srams.write(i).data := 0.U
  }

  // -----------------------------------------------------------------------------
  // Initialize ReservationStation Issue Interfaces (Backend ready signals)
  // -----------------------------------------------------------------------------
  rs.io.issue_o.ld.ready := false.B
  rs.io.issue_o.st.ready := false.B
  rs.io.issue_o.ex.ready := false.B

  // -----------------------------------------------------------------------------
  // Initialize ReservationStation Commit Interfaces (Backend completion signals)
  // -----------------------------------------------------------------------------
  rs.io.commit_i.ld.valid := false.B
  rs.io.commit_i.ld.bits.rob_id := 0.U
  rs.io.commit_i.st.valid := false.B
  rs.io.commit_i.st.bits.rob_id := 0.U
  rs.io.commit_i.ex.valid := false.B
  rs.io.commit_i.ex.bits.rob_id := 0.U

// =============================================================================
// DEFAULT INITIALIZATION FOR UNCONNECTED SIGNALS - END
// =============================================================================

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
// 返回RoCC接口连接
//---------------------------------------------------------------------------
  io.resp <> rs.io.rs_rocc_o.resp

}
