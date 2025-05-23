package gemmini.VecUnit

import chisel3._
import chisel3.util._
import chisel3.stage._
import org.chipsalliance.cde.config.Parameters
import gemmini.{GemminiArrayConfig}


case class ROBParams() {
  val robEntries = 32  
  val robPtrWidth = log2Up(robEntries)
}

class ROBEntry(implicit rob: ROBParams) extends Bundle {
  val valid         = Bool()          
  val inst          = UInt(32.W)      
  val pc            = UInt(16.W)      
  val rob_id        = UInt(rob.robPtrWidth.W)     
}



class VecEXROB[T <: Data, U <: Data, V <: Data](config: GemminiArrayConfig[T, U, V])
                                  (implicit p: Parameters, vc: VecConfig) extends Module {
  import config._
  val io = IO(new Bundle {

  })

// -----------------------------------------------------------------------------
// 
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 
// -----------------------------------------------------------------------------

}
