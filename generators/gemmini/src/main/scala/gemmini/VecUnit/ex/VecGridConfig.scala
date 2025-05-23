// package gemmini.VecUnit.ex

// import chisel3._
// import chisel3.util._
// import chisel3.stage._


// case class GridParams(val warpConfig: Seq[WarpParams] = Seq(
// //===----------------------------------------------------------------------===//
// // 第一横行
// //===----------------------------------------------------------------------===//
//   // WarpParams(warpId = 0, thread = 4, attr = "vpipe", gatherType = 32, gatherLane = 0, 
//   //   tConfig = Seq(
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true))
//   //   )),  
//   WarpParams(warpId = 1, thread = 8, attr = "base", gatherType = 32, gatherLane = 16,  
//     tConfig = Seq(
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true, pop = true)), 
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),  
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)), 
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true))
//     )),  
//   WarpParams(warpId = 2, thread = 8, attr = "base", gatherType = 32, gatherLane = 16, 
//     tConfig = Seq(
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),  
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),  
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)), 
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true))
//     )),  
//   // WarpParams(warpId = 3, thread = 4, attr = "vpipe", gatherType = 32, gatherLane = 0,  
//   //   tConfig = Seq(
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true))
//   //   )),  
// //===----------------------------------------------------------------------===//
// // 第二横行
// //===----------------------------------------------------------------------===//
//   // WarpParams(warpId = 4, thread = 4, attr = "vpipe", gatherType = 32, gatherLane = 0,  
//   //   tConfig = Seq(
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //   )),  
//   WarpParams(warpId = 5, thread = 4, attr = "base", gatherType = 32, gatherLane = 16,  
//     tConfig = Seq(
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),  
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)), 
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true))
//     )),  
//   WarpParams(warpId = 6, thread = 4, attr = "base", gatherType = 32, gatherLane = 16,  
//     tConfig = Seq(
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),  
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)), 
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true))
//     )),  
//   WarpParams(warpId = 7, thread = 4, attr = "base", gatherType = 32, gatherLane = 16,  
//     tConfig = Seq(
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),  
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)), 
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true))
//     )),  
//   WarpParams(warpId = 8, thread = 4, attr = "base", gatherType = 32, gatherLane = 16,  
//     tConfig = Seq(
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),  
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)), 
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true)),
//       ThreadParams(lane = 16, attr = "base", Ops = new SupportedFuncUnits(mul = true))
//     )),  
//   // WarpParams(warpId = 9, thread = 4, attr = "vpipe", gatherType = 32, gatherLane = 0,  
//   //   tConfig = Seq(
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //   )),  
// //===----------------------------------------------------------------------===//
// // 第三横行 CPU use
// //===----------------------------------------------------------------------===//
//   // WarpParams(warpId = 10, thread = 4, attr = "cpu-vpipe", gatherType = 32, gatherLane = 0,  
//   //   tConfig = Seq(
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true))  
//   //   )),   
// //===----------------------------------------------------------------------===//
// // 第四横行 Acc use
// //===----------------------------------------------------------------------===//
//   // WarpParams(warpId = 10, thread = 2, attr = "dma-acc-vpipe", gatherType = 32, gatherLane = 0, 
//   //   tConfig = Seq(
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true))  
//   //   )),
// //===----------------------------------------------------------------------===//
// // 第五横行 Spad use
// //===----------------------------------------------------------------------===//
//   // WarpParams(warpId = 10, thread = 2, attr = "spad-acc-vpipe", gatherType = 32, gatherLane = 0, 
//   //   tConfig = Seq(
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true)),  
//   //     ThreadParams(lane = 16, attr = "vpipe", Ops = new SupportedFuncUnits(mul = true))  
//   //   )),
// )) {
//   def warpNum = warpConfig.length
//   def threadNum(warpId: Int) = warpConfig.find(_.warpId == warpId).map(_.tConfig.length).getOrElse(0)
// }

// // base: thread->Mul          gather->accumulate
// // cpu:  thread->Mul          gather->accumulate
// // pre:  thread->Mul/Pop/Idx  gather->accumulate/combine
