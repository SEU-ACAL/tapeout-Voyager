package voyager_tapeout.custom.uncore

import chisel3._
import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.tilelink._

class TLRequestFifoFalse(implicit p: Parameters) extends LazyModule {
  val node = new AdapterNode(TLImp)({ mp =>
    mp.v1copy(clients = mp.clients.map(c => c.v1copy(requestFifo = false)))
  },{
    sp => sp
  })

  lazy val module = new Impl
  class Impl extends LazyModuleImp(this) {
    (node.in zip node.out) foreach { case ((in, edgeIn), (out, edgeOut)) =>
      out <> in
    }
  }
}

object TLRequestFifoFalse {
  def apply()(implicit p: Parameters): TLNode = {
    val fifo_false = LazyModule(new TLRequestFifoFalse)
    fifo_false.node
  }
} 