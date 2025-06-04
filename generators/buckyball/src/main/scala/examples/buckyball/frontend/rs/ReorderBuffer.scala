package buckyball.frontend.rs

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.Parameters
import buckyball.BuckyBallConfig
import buckyball.util.Util._
import freechips.rocketchip.buckyball.RoCCResponseBB



object RoBState extends ChiselEnum {
  val sInvalid  = Value   // 无效状态
  val sWaiting  = Value   // 等待分发
  val sIssued   = Value   // 已发射到执行单元
  val sComplete = Value   // 执行完成，等待提交
}

class RoBEntry(implicit bbconfig: BuckyBallConfig) extends Bundle {
  val state    = RoBState()  // 声明类型而不是赋予默认值
  val cmd      = new BuckyBallCmd
  val cmd_type = UInt(2.W)
  val ready    = Bool()  // 前置指令是否发射完成
  
  def is_ready = ready && (state === RoBState.sWaiting)
  def can_commit = state === RoBState.sComplete
}

// Buckyball的ROB只有一个队列所有指令都按照FIFO顺序执行
// 顺序执行，Load/Store/Ex每次最多只会各自发射一个
// 为保证没有读写冲突，现在版本只支持Load/Ex并行和Store/Ex并行，不支持同时执行Load/Store
// 如果RoB内顺序为Ex -> Ex -> Store，则这条Store指令不会发射，
// 等后续流水线指令设计完成才可以发射整条流水线
// 最终也只能顺序提交
class ReorderBuffer(implicit bbconfig: BuckyBallConfig, p: Parameters) extends Module {
  val rob_entries = bbconfig.rob_entries
  val rob_id_width = log2Up(bbconfig.rob_entries)
  val cmd_t = new BuckyBallCmd
  
  val io = IO(new Bundle {
    val post_indexed_cmd_i = new Bundle {
      val cmd          = Flipped(Decoupled(new BuckyBallCmd))
      val new_head_ptr = Input(UInt(log2Up(bbconfig.rob_entries).W))
    }
    val issue_o        = Decoupled(new BuckyBallCmd)  // 按顺序发射到ISSQueue
    val commit_i       = Flipped(Valid(UInt(rob_id_width.W)))
    // to top
    val rob_cmt_o     = new Bundle {      
      val resp        = Decoupled(new RoCCResponseBB()(p))
    }
    // to ROBCounter
    val rob_robcnt_o  = Decoupled(UInt(log2Up(bbconfig.rob_entries).W))
  })

  // ROB条目数组
  val RobEntries = Reg(Vec(rob_entries, new RoBEntry))
  
  // 初始化ROB entries为无效状态
  for (i <- 0 until rob_entries) {
    when(reset.asBool) {
      RobEntries(i).state := RoBState.sInvalid
    }
  }
  
// -----------------------------------------------------------------------------
// 入队
// -----------------------------------------------------------------------------
  io.post_indexed_cmd_i.cmd.ready := true.B
  val cmd_i        = io.post_indexed_cmd_i.cmd.bits
  val rob_id       = io.post_indexed_cmd_i.cmd.bits.rob_id
  val cmd_type     = io.post_indexed_cmd_i.cmd.bits.cmd_type
  val head_ptr     = io.post_indexed_cmd_i.new_head_ptr

  when(io.post_indexed_cmd_i.cmd.fire) {
    assert(RobEntries(rob_id).state === RoBState.sInvalid || 
        RobEntries(rob_id).state === RoBState.sWaiting || 
        RobEntries(rob_id).state === RoBState.sIssued, "Inserting to non-empty ROB entry")
    
    RobEntries(rob_id).state    := RoBState.sWaiting
    RobEntries(rob_id).cmd      := cmd_i
    RobEntries(rob_id).cmd_type := cmd_type
    RobEntries(rob_id).ready    := true.B
  }

// -----------------------------------------------------------------------------
// 发射：按顺序发射到ISSQueue
// -----------------------------------------------------------------------------
  val issue_ptr = RegInit(0.U(log2Up(rob_entries).W))
  val can_issue = RobEntries(issue_ptr).state === RoBState.sWaiting && RobEntries(issue_ptr).ready
  
  io.issue_o.valid := can_issue
  io.issue_o.bits := RobEntries(issue_ptr).cmd
  
  when(io.issue_o.fire) {
    RobEntries(issue_ptr).state := RoBState.sIssued
    issue_ptr := (issue_ptr + 1.U) % rob_entries.U
  }

// -----------------------------------------------------------------------------
// 提交
// -----------------------------------------------------------------------------
  // 出队
  when(io.commit_i.valid) {
    RobEntries(io.commit_i.bits).state := RoBState.sComplete
  }

  // to ROBCounter
  io.rob_robcnt_o.valid       := io.commit_i.valid
  io.rob_robcnt_o.bits        := io.commit_i.bits
  
  // 清理已完成的ROB entry
  // 当ROBCounter接收到commit信号后，head_ptr会推进，此时可以清理对应的entry
  when(io.rob_robcnt_o.fire) {
    RobEntries(io.rob_robcnt_o.bits).state := RoBState.sInvalid
  }
  
  // to top
  io.rob_cmt_o.resp.valid     := io.commit_i.valid
  io.rob_cmt_o.resp.bits.rd   := 0.U
  io.rob_cmt_o.resp.bits.data := 0.U
} 