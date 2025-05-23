package buckyball

import scala.math.{max, pow, sqrt}
import chisel3._
import chisel3.util._
import freechips.rocketchip.tile._
import org.chipsalliance.cde.config._

import mem.LocalAddr

sealed abstract trait BuckyBallMemCapacity
case class CapacityInKilobytes(kilobytes: Int) extends BuckyBallMemCapacity
case class CapacityInVectors(vectors: Int) extends BuckyBallMemCapacity
// case class CapacityInMatrices(matrices: Int) extends BuckyBallMemCapacity

case class BuckyBallConfig(
  opcodes: OpcodeSet = OpcodeSet.custom3,
  
  inputType: Data,
  accType: Data,

  veclane: Int = 16,

  tlb_size: Int = 4,
  rob_entries: Int = 32,  // RoB条目数量
  
  dma_maxbytes: Int = 64,
  dma_buswidth: Int = 128,
  
  sp_banks: Int = 4,
  acc_banks: Int = 2,
  
  sp_singleported: Boolean = false,
  
  sp_capacity: BuckyBallMemCapacity = CapacityInKilobytes(256),
  acc_capacity: BuckyBallMemCapacity = CapacityInKilobytes(64),
  
  max_in_flight_mem_reqs: Int = 16,
  aligned_to: Int = 1,
  spad_read_delay: Int = 0,

  addr_length: Int = 14, // 256KB的索引长度
  
) {
  val sp_width = veclane * inputType.getWidth
  val sp_bank_entries = sp_capacity match {
    case CapacityInKilobytes(kb) => kb * 1024 * 8 / (sp_banks * sp_width)
    case CapacityInVectors(vs) => vs * veclane / sp_banks
  }
  val acc_width = veclane * accType.getWidth
  val acc_bank_entries = acc_capacity match {
    case CapacityInKilobytes(kb) => kb * 1024 * 8 / (acc_banks * acc_width)
    case CapacityInVectors(vs) => vs * veclane / acc_banks
  }
  val local_addr_t = new LocalAddr(sp_banks, sp_bank_entries, acc_banks, acc_bank_entries)



}


object BuckyBallConfigs {
  val defaultConfig = BuckyBallConfig(
    inputType = UInt(8.W),
    accType = UInt(32.W)
  )
}