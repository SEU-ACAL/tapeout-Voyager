package voyager_tapeout.custom.harness


import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.{Parameters, Field}
import freechips.rocketchip.subsystem._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.util._
import freechips.rocketchip.prci._
import freechips.rocketchip.amba.axi4._
import testchipip.serdes._
import testchipip.tsi.{TSIToTileLink, TSIIO}
import testchipip.dram.{SimDRAM}
import java.nio.ByteBuffer
import java.nio.file.{Files, Paths}


class SerialDRAM(tl_serdesser: TLSerdesser, params: SerialTLParams)(implicit p: Parameters) extends LazyModule {
  val managerParams = tl_serdesser.module.client_edge.map(_.slave) // the managerParams are the chip-side clientParams
  val clientParams = tl_serdesser.module.manager_edge.map(_.master) // The clientParams are the chip-side managerParams
  val serdesser = LazyModule(new TLSerdesser(
    tl_serdesser.flitWidth,
    clientParams,
    managerParams,
    tl_serdesser.bundleParams,
    nameSuffix = Some("SerialDRAM")
  ))

  // If this serdesser expects a manager, connect tsi2tl
  val tsi2tl = serdesser.managerNode.map { managerNode =>
    val tsi2tl = LazyModule(new TSIToTileLink)
    serdesser.managerNode.get := TLBuffer() := tsi2tl.node
    tsi2tl
  }

  serdesser.clientNode.foreach { clientNode =>
    val beatBytes = 8
    val memParams = params.manager.get.memParams
    val romParams = params.manager.get.romParams
    val cohParams = params.manager.get.cohParams

    // Create SimDRAM modules instead of TileLink RAM
    val simDRAMs = memParams.map { memParams =>
      AddressSet.misaligned(memParams.address, memParams.size).map { aset =>
        LazyModule(new SimDRAMModule(aset, beatBytes) {override lazy val desiredName = "SerialSimDRAM"})
      }
    }.flatten

    // Connect SimDRAM modules through TLToAXI4 converters
    simDRAMs.foreach { simDRAM =>
      simDRAM.node := 
        AXI4UserYanker() := 
        AXI4Buffer() := 
        TLToAXI4() := 
        TLBuffer() :=
        TLFragmenter(beatBytes, p(CacheBlockBytes),holdFirstDeny=true, nameSuffix = Some("SerialSimDRAM")) := 
        clientNode
    }

    // val rom = romParams.map { romParams => SerialTLROM(romParams, beatBytes) }
    // rom.foreach { r => (r.node
    //   := TLFragmenter(beatBytes, p(CacheBlockBytes), nameSuffix = Some("SerialRAM_ROM"))
    //   := xbar)
    // }

    // val cohrams = cohParams.map { cohParams =>
    //   AddressSet.misaligned(cohParams.address, cohParams.size).map { aset =>
    //     LazyModule(new TLRAM(aset, beatBytes = beatBytes) { override lazy val desiredName = "SerialRAM_COH" })
    //   }
    // }.flatten
    // cohrams.foreach { s => (s.node
    //   := TLBuffer()
    //   := TLFragmenter(beatBytes, p(CacheBlockBytes), nameSuffix = Some("SerialRAM_COH"))
    //   := TLBroadcast(p(CacheBlockBytes))
    //   := xbar)
    // }

    // xbar := clientNode
  }

  lazy val module = new Impl
  class Impl extends LazyModuleImp(this) {
    val io = IO(new Bundle {
      val ser = new DecoupledPhitIO(params.phyParams.phitWidth)
      val tsi = tsi2tl.map(_ => new TSIIO)
      val tsi2tl_state = Output(UInt())
    })

    val phy = Module(new DecoupledSerialPhy(5, params.phyParams))
    phy.io.outer_clock := clock
    phy.io.outer_reset := reset
    phy.io.inner_clock := clock
    phy.io.inner_reset := reset
    phy.io.outer_ser <> io.ser
    for (i <- 0 until 5) {
      serdesser.module.io.ser(i) <> phy.io.inner_ser(i)
    }
    io.tsi.foreach(_ <> tsi2tl.get.module.io.tsi)
    io.tsi2tl_state := tsi2tl.map(_.module.io.state).getOrElse(0.U(1.W))

    require(serdesser.module.mergedParams == tl_serdesser.module.mergedParams,
    "Mismatch between chip-side diplomatic params and harness-side diplomatic params:\n" +
      s"Harness-side params: ${serdesser.module.mergedParams}\n" +
      s"Chip-side params: ${tl_serdesser.module.mergedParams}")

  }
}

class SimDRAMModule(address: AddressSet, beatBytes: Int)(implicit p: Parameters) extends LazyModule {

    val node = AXI4SlaveNode(Seq(AXI4SlavePortParameters(
    slaves = Seq(AXI4SlaveParameters(
        address = List(address),
        executable = true,
        supportsWrite = TransferSizes(1, beatBytes),
        supportsRead = TransferSizes(1, beatBytes),
        interleavedId = Some(0)
    )),
    beatBytes = beatBytes
    )))

    
    override lazy val desiredName = "SerialSimDRAM"
    
    lazy val module = new Impl
    class Impl extends LazyModuleImp(this) {
    val (in, edgeIn) = node.in(0)
    
    // Calculate memory parameters
    val memSize = address.max - address.base + 1
    val lineSize = 64 // cache block size
    val clockFreqHz = 100000000L // 100MHz default
    
    // Instantiate SimDRAM
    val mem = Module(new SimDRAM(memSize, lineSize, clockFreqHz, address.base, in.params, 0))
    mem.suggestName("simdram")
    
    // Connect SimDRAM
    mem.io.clock := clock
    mem.io.reset := reset
    mem.io.axi <> in
    }
}
