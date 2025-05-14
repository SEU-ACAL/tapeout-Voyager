package barf

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.{Field, Parameters}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.util._
import freechips.rocketchip.tile._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.subsystem.{CacheBlockBytes}
import freechips.rocketchip.rocket.{ExpandedInstruction}
import freechips.rocketchip.rocket.InlineInstance
import freechips.rocketchip.rocket.Instructions._
import freechips.rocketchip.rocket.ALU._
import freechips.rocketchip.rocket.CustomInstructions._
import scala.collection.mutable.ArrayBuffer

// a=[10,20,30,40] -> vlu 
// stride = vec 
// vec addr = 0,1,2,3 + stride*lane id
// depenload  10, 20 ++ 1,3 
// b=[1,2,3,4................]

case class VectorizerParams(
  nVecLanes: Int = 8,
  nVecRegs: Int = 32,
  VecBitWidth: Int = 256,
  nScalarRegs: Int = 8,
  ScalarBitWidth: Int = 64
) 

object VecUtil {
  def unpack(data: UInt, width: Int, nVecLanes: Int, VecBitWidth: Int): Vec[UInt] = {
    VecInit((0 until nVecLanes).map { i =>
      val elemWidth = width
      val startBit = i * elemWidth
      val endBit = (i + 1) * elemWidth - 1
      if (endBit < VecBitWidth) {
        data(endBit, startBit)
      } else {
        0.U(elemWidth.W)
      }
    })
  }

  def pack(results: Vec[UInt]): UInt = {
    Cat(results.reverse)
  }
}

class VecRegFile(params:VectorizerParams)(implicit p: Parameters) {
  val rf = Mem(params.nVecRegs, UInt(params.VecBitWidth.W))
  private def access(addr: UInt) = rf(~addr(log2Up(params.nVecRegs)-1,0))
  private val reads = ArrayBuffer[(UInt,UInt)]()
  private var canRead = true
  def read(addr: UInt) = {
    require(canRead)
    reads += addr -> Wire(UInt())
    reads.last._2
  }
  def write(addr: UInt, data: UInt) = {
    canRead = false
    access(addr) := data
    for ((raddr, rdata) <- reads)
      when (addr === raddr) { rdata := data }
  }
}

trait HasVecLen {
  val vlen = UInt()
}

class VecSrcSignal(implicit override val p: Parameters)extends CoreBundle {
    val uop     = Bits(FN_X.getWidth.W)
    val op2     = UInt(xLen.W)
    val op1     = UInt(xLen.W)
    val rd      = UInt()
    val s1      = Bool()
    val s2      = Bool()
    val srd     = Bool()
}


class ALUCtrlSignal(implicit override val p: Parameters)extends CoreBundle with HasVecLen {
    val uop     = Bits(FN_X.getWidth.W)
    val vrd     = UInt()
    val vrs1    = UInt()
    val vrs2    = UInt()
}

class Vectorizer(params:VectorizerParams)(implicit p: Parameters) extends CoreModule()(p) {
    val io = IO(new Bundle{
      val src  = Input(new VecSrcSignal())
      val prf  = Output(new Prefetch)
      val resp = Flipped(Decoupled(new VecLoadResp(params)))
    })

    val ctrl = Reg(new ALUCtrlSignal())

    val alus = new ALUCluster(params)
    val vlu  = new VecLoadUnit(params)
    val vrf  = new VecRegFile(params)
}
