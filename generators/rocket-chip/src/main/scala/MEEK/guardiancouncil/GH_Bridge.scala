package freechips.rocketchip.guardiancouncil

import chisel3._
import chisel3.experimental.{BaseModule}


case class GH_BridgeParams(
  width: Int
)

class GH_BridgeIO(params: GH_BridgeParams) extends Bundle {
  val in = Input(UInt(params.width.W))
  val out = Output(UInt(params.width.W))
}

trait HasGH_BridgeIO extends BaseModule {
  val params: GH_BridgeParams
  val io = IO(new GH_BridgeIO(params))
}

class GH_Bridge (val params: GH_BridgeParams) extends Module with HasGH_BridgeIO {
  io.out <> io.in
}
