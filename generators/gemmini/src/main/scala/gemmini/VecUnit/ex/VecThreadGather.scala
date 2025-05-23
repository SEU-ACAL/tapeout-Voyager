// package gemmini.VecUnit.ex

// import chisel3._
// import chisel3.util._
// import chisel3.stage._

// import gemmini.VecUnit.ex.{tOut, wBondOut}


// class GatherUnit(w: WarpParams) extends Module {
//   val io = IO(new Bundle {
//     val north = Flipped(Decoupled(new tOut()))
//     val west = Flipped(Decoupled(new wBondOut()))
//     val east = Decoupled(new wBondOut())
//   })

//   val VecReg = VecInit(Seq.fill(w.gatherLane)(RegInit(0.U(w.gatherType.W))))
//   val ScalarReg = RegInit(0.U(w.gatherType.W))
  
//   when(io.west.fire && io.west.valid) {
//     VecReg := io.west.bits.vRst
//     ScalarReg := io.north.bits.sRst
//   }

//   io.east.valid := io.north.valid && io.west.valid
//   io.east.bits.vRst := VecReg.zip(io.north.bits.vRst).map{case (a, b) => a + b}
// }

// class VecThreadGather(implicit w: WarpParams) extends Module {
//   val io = IO(new Bundle {
//     val threadIn = Vec(w.thread, Flipped(Decoupled(new tOut())))
//     val bondIn = Flipped(Decoupled(new wBondOut()))
//     val bondOut = Decoupled(new wBondOut())
//   })

//   // Create modules and connect them
//   val gatherUnits = (0 until w.thread).map(_ => Module(new GatherUnit(w)))
  
//   // inputs
//   for (i <- 0 until w.thread) {
//     gatherUnits(i).io.north <> io.threadIn(i)
//     if (i > 0) {
//       gatherUnits(i).io.west <> gatherUnits(i-1).io.east
//     } else {
//       gatherUnits(i).io.west <> io.bondIn
//     }
//   }

//   // outputs
//   io.bondOut <> gatherUnits.last.io.east
// }
