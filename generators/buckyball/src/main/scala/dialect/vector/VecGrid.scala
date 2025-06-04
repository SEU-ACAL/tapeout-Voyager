// package dialect.vector

// import chisel3._
// import chisel3.util._
// import chisel3.stage._


// // Level 4: Grid
// class VecGrid(g: GridParams) extends Module {
//   val io = IO(new Bundle {
//     val cmdReq = Flipped(Decoupled(new wCmdReq()))
//     val cmdResp = Decoupled(new wCmdResp())
//   })

//   val warp = Seq.tabulate(g.warpNum)(i => Module(new VecWarp(g.warpConfig(i))))
//   warp.zipWithIndex.foreach { case (w, i) =>
//     w.io.wcmdReq <> io.cmdReq
//     io.cmdResp <> w.io.wCmdResp
//   }
  
// }