// //===- VecWarp.scala - Level 2: Warp ---===//
// package gemmini.VecUnit.ex

// import chisel3._
// import chisel3.util._
// import chisel3.stage._

// import gemmini.VecUnit.ex.{VecThread, VecThreadGather, tOpLoad}

// class wCmdReq extends tOpLoad {
//   val tid = UInt(4.W)
// }

// class wBondIn extends Bundle {
//   val vRst = Vec(16, UInt(8.W))
// }

// class wCmdResp extends Bundle {
//   val finish = Bool()
// }

// class wBondOut extends Bundle {
//   val vRst = Vec(16, UInt(8.W))
// }

// // Level 2: Wrap
// //===----------------------------------------------------------------------===//
// // Warp            | wcmdReq
// //           ______↓_______
// //          |             |
// //  wbondin |             | wbondout
// //  ------> |    warp     |----->
// //          |             |
// //          |_____________|
// //      
// //===----------------------------------------------------------------------===//
// case class WarpParams(val warpId: Int,
//                       val thread: Int = 16,
//                       val attr: String = "base",
//                       val tConfig: Seq[ThreadParams],
//                       val gatherType: Int = 32,
//                       val gatherLane: Int = 32
// ) 

// class VecWarp(w: WarpParams) extends Module {
//   implicit val warpParams: WarpParams = w

//   val io = IO(new Bundle {
//     val wcmdReq   = Flipped(Decoupled(new wCmdReq()))   // north
//     val bondIn  = Flipped(Decoupled(new wBondIn())) // west
//     val bondOut = Decoupled(new wBondOut())        // east
//     val wCmdResp  = new wCmdResp()        // south
//   })

//   // Create threads with their corresponding ThreadParams
//   val threads = w.tConfig.zipWithIndex.map { case (tConfig, i) =>
//     implicit val threadParams: ThreadParams = tConfig
//     Module(new VecThread())
//   }
//   val threadInputIOs = VecInit(threads.map(_.io.in))

//   val gather = Module(new VecThreadGather())

// //===----------------------------------------------------------------------===//
// // 纵向连接
// // wCmdReq -> threads -> gather -> wCmdResp
// //===----------------------------------------------------------------------===//
//   when (io.wcmdReq.fire) {
//     threadInputIOs(io.wcmdReq.bits.tid) <> io.wcmdReq
//   }.otherwise {
//     threadInputIOs(io.wcmdReq.bits.tid) <> DontCare
//   }

//   threads.zipWithIndex.foreach { case (thread, i) =>
//     thread.io.out <> gather.io.threadIn(i)
//   }

//   io.wCmdResp.finish := gather.io.bondOut.valid

// //===----------------------------------------------------------------------===//
// // 横向连接
// // bondin -> gather -> bondout
// //===----------------------------------------------------------------------===//

//   gather.io.bondIn <> io.bondIn
//   io.bondOut <> gather.io.bondOut

// }
