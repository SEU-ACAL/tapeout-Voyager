package boom.fdip.util

import chisel3._
import chisel3.util._

import org.chipsalliance.cde.config.{Parameters}
import freechips.rocketchip.util.{Str}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.tile._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.util._
import freechips.rocketchip.util.property._
import freechips.rocketchip.rocket.{HasL1ICacheParameters, ICacheParams, ICacheErrors, ICacheReq}
import boom.fdip.ifu._
import boom.fdip.common._
import boom.fdip.exu._
import boom.fdip.util._
import freechips.rocketchip.tilelink.TLMessages.isA
class SRAMRReqBundle[T <: Data]( depth: Int, dataType: T)(implicit p: Parameters) extends BoomBundle {
    val raddr = (UInt(log2Ceil(depth).W))
}
class SRAMRRespBundle[T <: Data]( depth: Int, dataType: T)(implicit p: Parameters) extends BoomBundle {
    val rdata = Output(dataType)
}
class SRAMRIO[T <: Data]( depth: Int, dataType: T)(implicit p: Parameters) extends BoomBundle {
    val req = Flipped(Decoupled(new SRAMRReqBundle( depth, dataType)))
    val resp = (new SRAMRRespBundle( depth, dataType))
}
class SRAMWIO[T <: Data]( depth: Int, dataType: T)(implicit p: Parameters) extends BoomBundle {
    val waddr = Input(UInt(log2Ceil(depth).W))
    val wdata = Input(dataType)
    val wen   = Input(Bool())
}
class SRAMHelper[T <: Data]( depth: Int,dataType:T)(implicit p: Parameters) extends  BoomModule{

    val io = IO(new Bundle{
        val r  = new SRAMRIO( depth, dataType)
        val w  = new SRAMWIO( depth, dataType)
    })  

    val mem = SyncReadMem(depth, dataType) 
    io.r.req.ready := !(io.w.wen)
    val ren             = io.r.req.fire
    val raddr           = io.r.req.bits.raddr
    val wen             = io.w.wen 
    val waddr           = io.w.waddr
    val wdata           = io.w.wdata
    // assert(!(io.enable && io.write && ()))
    io.r.resp.rdata := mem.readWrite(Mux(wen,waddr,raddr),wdata,wen||ren,wen)
}

class ICacheSRAMHelper[T <: Data](name:String,way:Int,bank:Int,depth: Int,dataType:T)(implicit p: Parameters) extends  BoomModule{

    val io = IO(new Bundle{
        val r  = new SRAMRIO( depth, dataType)
        val w  = new SRAMWIO( depth, dataType)
    })  

    val mem =  DescribedSRAM(
          name = s"dataArrayWay_${way}_bank_${bank}",
          desc = s"${name}",
          size = depth,
          data = dataType
        )
    io.r.req.ready := !(io.w.wen)
    val ren             = io.r.req.fire
    val raddr           = io.r.req.bits.raddr
    val wen             = io.w.wen 
    val waddr           = io.w.waddr
    val wdata           = io.w.wdata
    // assert(!(io.enable && io.write && ()))
    io.r.resp.rdata := mem.readWrite(Mux(wen,waddr,raddr),wdata,wen||ren,wen)


}
// class BankedSRAMHelper[T <: Data]( depth: Int,dataType:T,bankNum: Int)(implicit p: Parameters) extends  BoomModule{

//     val io = IO(new BankedSRAMIO( depth, dataType,bankNum))  
//     val mem = SyncReadMem(depth, dataType) 
//     // assert(!(io.enable && io.write && ()))
//     io.dataOut := mem.readWrite(io.addr, io.dataIn, io.enable, io.write)
//     class BankedSRAMIO[T <: Data]( depth: Int, dataType: T,bankNum:Int) extends BoomBundle {
//         val addr    = Input(Vec(bankNum,UInt(log2Ceil(depth).W)))
//         val dataIn  = Input(Vec(bankNum,dataType))
//         val dataOut = Output(Vec(bankNum,dataType))
//         val enable  = Input(Vec(bankNum,Bool()))
//         val write   = Input(Vec(bankNum,Bool()))
//     }

// }
class DCacheDataSRAMHelper(depth: Int,width:Int)(implicit p: Parameters) extends BoomModule {

    val io = IO(new SRAMIO( depth, width))  
    val mem = SyncReadMem(depth, Vec(width/8,UInt(8.W)))

    
    class SRAMIO( depth: Int, width: Int) extends Bundle {
        val addr = Input(UInt(log2Ceil(depth).W))
        val dataIn = Input(Vec(width/8,UInt(8.W)))
        val mask   = Input(Vec(width/8,Bool()))
        val dataOut = Output(UInt(width.W))
        val enable = Input(Bool())
        val write = Input(Bool())
    }
    io.dataOut := mem.readWrite(io.addr,io.dataIn,io.mask,io.enable, io.write)

}
class DualSRAMHelper[T <: Data]( depth: Int,dataType:T)(implicit p: Parameters) extends BoomModule {

    val mem = SyncReadMem(depth, dataType) 
    def write(en: Bool, waddr: UInt, dataIn: T): Unit = {
        when(en) {
            mem.write(waddr, dataIn)
        }
    }
    def read(en: Bool, raddr: UInt): T = {
        mem.read(raddr,en)
    }

}