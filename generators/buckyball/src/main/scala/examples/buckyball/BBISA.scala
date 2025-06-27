package buckyball

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.buckyball.RoCCCommandBB

class BuckyBallRawCmd(implicit p: Parameters) extends Bundle {
  val cmd = new RoCCCommandBB
}

object BBISA {
  val MVIN_BITPAT             = BitPat("b0011000")
  val MVOUT_BITPAT            = BitPat("b0011001")
  val MATMUL_WARP16_BITPAT    = BitPat("b0100000")
  val VECTHREAD_VMUL_BITPAT   = BitPat("b0100001")
  val BFPTHREAD_REDUCE_BITPAT = BitPat("b0100010")
  val CITU0_MATMUL_BITPAT     = BitPat("b0100011")
  val CITU1_MATMUL_BITPAT     = BitPat("b0100100")
}
