package voyager_tapeout.custom.fpga

import chisel3._
import chisel3.util._
import chisel3.experimental.dataview._
import org.chipsalliance.cde.config.{Parameters, Field}
import freechips.rocketchip.subsystem._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.devices.tilelink._
// import org.chipsalliance.diplomacy._
// import org.chipsalliance.diplomacy.lazymodule._
import freechips.rocketchip.util._
import freechips.rocketchip.prci._
import freechips.rocketchip.amba.axi4._
import testchipip.serdes._
// import freechips.rocketchip.diplomacy.{AddressSet}
import freechips.rocketchip.diplomacy._
import java.nio.ByteBuffer
import java.nio.file.{Files, Paths}
import freechips.rocketchip.diplomacy.AddressSet.misaligned

// import freechips.rocketchip.diplomacy._


class Serial(tl_serdesser: TLSerdesser, params: SerialTLParams)(implicit p: Parameters) extends LazyModule {
  val managerParams = tl_serdesser.module.client_edge.map(_.slave) // the managerParams are the chip-side clientParams
  val clientParams = tl_serdesser.module.manager_edge.map(_.master) // The clientParams are the chip-side managerParams
  
  val serdesser = LazyModule(new TLSerdesser(
    tl_serdesser.flitWidth,
    clientParams,
    managerParams,
    tl_serdesser.bundleParams,
    nameSuffix = Some("Serial")
  ))

   // 创建终结节点 - 使用标准参数
  val semanagerNode = {
    val nodeBeatBytes = 8
    val memParams = params.manager.get.memParams
    val senamagerNode = TLManagerNode(Seq(TLSlavePortParameters.v1(
       managers = memParams.map{ memParams =>   TLSlaveParameters.v1(
          address            = AddressSet.misaligned(memParams.address, memParams.size),
          resources          = new SimpleDevice("lbram",Nil).reg,
          regionType         = RegionType.UNCACHED, // cacheable
          executable         = true,
          supportsGet        = TransferSizes(1, nodeBeatBytes),
          supportsPutFull    = TransferSizes(1, nodeBeatBytes),
          supportsPutPartial = TransferSizes(1, nodeBeatBytes)
          )},
          beatBytes = nodeBeatBytes,
          endSinkId = 0,
          minLatency = 1
        )))
      senamagerNode
 }


  serdesser.clientNode.foreach { clientNode =>
    val beatBytes = 8
    val memParams = params.manager.get.memParams
    val romParams = params.manager.get.romParams
    val cohParams = params.manager.get.cohParams

    semanagerNode := TLBuffer() := clientNode
    
  }


  lazy val module = new Impl
  class Impl extends LazyModuleImp(this) {
    // 创建扩展的IO Bundle，包含序列化IO和TileLink接口
    val io = IO(new Bundle {
      // 原始的物理层IO
      val ser = new DecoupledPhitIO(params.phyParams.phitWidth)
      val tl = {
        val clinentParam =  semanagerNode.in(0)._1.params
        val bundle = new TLBundle(clinentParam)
        Some(bundle)
      }
    }).suggestName("SerialRAM_IO")
    

    // 连接TileLink接口到semanagerNode
      io.tl.foreach { tlIO =>
        // 连接IO的TileLink接口到Diplomacy节点 - 使用标准模式获取连接
        if (semanagerNode.in.nonEmpty) {
          semanagerNode.in.head._1 <> tlIO
        } else {
          println("Warning: semanagerNode exists but has no connections")
        }
      }

  val phy = Module(new DecoupledSerialPhy(5, params.phyParams))
      phy.io.outer_clock := clock
      phy.io.outer_reset := reset
      phy.io.inner_clock := clock
      phy.io.inner_reset := reset
      phy.io.outer_ser <> io.ser
 
    
    for (i <- 0 until 5) {
      serdesser.module.io.ser(i) <> phy.io.inner_ser(i)
    }

    require(serdesser.module.mergedParams == tl_serdesser.module.mergedParams,
    "Mismatch between chip-side diplomatic params and harness-side diplomatic params:\n" +
      s"Harness-side params: ${serdesser.module.mergedParams}\n" +
      s"Chip-side params: ${tl_serdesser.module.mergedParams}")

  }
}
