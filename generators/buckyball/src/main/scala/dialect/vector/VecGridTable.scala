// package dialect.vector

// import chisel3._
// import chisel3.util._
// import chisel3.stage._


// class WarpTableEntry extends Bundle {
//   val busy             = Bool()          
//   val warpId           = UInt(16.W)              
//   val opcode           = UInt(32.W)     
//   val iter             = UInt(16.W)    // 剩余的iter
//   val robId            = UInt(16.W)              
//   val arrive           = Bool() // 是否开始第一个提交了
//   val firstInStage     = Bool() // 是否是bond内第一个Warp
//   val lastInStage      = Bool() // 是否是bond内最后一个Warp
//   val connected        = Bool() // 是否向右连接下一个warp
// }

// class StageTableEntry extends Bundle {
//   val busy             = Bool()          
//   val stageId          = UInt(16.W)              
//   val iter             = UInt(16.W)  // 剩余的iter
//   val warp             = Vec(4, new WarpTableEntry)           
//   val gateOpen         = Bool() // 是否放出流水
// }

// class PipeLineEntry extends Bundle {
//   val busy             = Bool()          
//   val pipelineId       = UInt(16.W)              
//   val stage            = Vec(4, new StageTableEntry)
// }

// class GridTable extends Module {
//   val config = GridParams()
//   val io = IO(new Bundle {
//     val wcmdReq = Flipped(Decoupled(new wCmdReq()))
//     val wCmdResp = Decoupled(new wCmdResp())
//   })

//   val warp = Seq.tabulate(config.warpNum)(i => Module(new VecWarp(config.warpConfig(i))))
//   warp.zipWithIndex.foreach { case (w, i) =>
//     w.io.wcmdReq <> io.wcmdReq
//     io.wCmdResp <> w.io.wCmdResp
//   }

//   // init table
//   val GridTable = Reg(Vec(config.warpNum, new WarpTableEntry()))
//   GridTable.foreach { entry =>
//     entry.busy := false.B
//     entry.inst := 0.U
//   }

//   // 更新某个warp的状态
//   def updateWarpState(warpId: UInt, busy: Bool, inst: UInt, rob_id: UInt): Unit = {
//     GridTable(warpId).busy   := busy
//     GridTable(warpId).inst   := inst
//     GridTable(warpId).rob_id := rob_id
//   }

//   // 设置warp的暂停状态
//   def stallWarp(warpId: UInt, stalled: Bool): Unit = {
//     GridTable(warpId).stalled := stalled
//   }

//   // 判断warp是否可以调度
//   def isWarpReady(warpId: UInt): Bool = {
//     !GridTable(warpId).stalled && GridTable(warpId).busy && 
//     !GridTable(warpId).waitingForBranch && !GridTable(warpId).waitingForMemory
//   }
// }
