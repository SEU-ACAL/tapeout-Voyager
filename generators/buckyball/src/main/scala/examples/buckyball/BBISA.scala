package buckyball

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.buckyball.RoCCCommandBB

class BuckyBallRawCmd(implicit p: Parameters) extends Bundle {
  val cmd = new RoCCCommandBB
}

object BBISA {
  val MVIN_BITPAT  = BitPat("b0000010")
  val MVOUT_BITPAT = BitPat("b0000011")
  val MATMUL_WARP16_BITPAT = BitPat("b0011111")
}
