package buckyball.mem

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.diplomacy.{LazyModule, LazyModuleImp}
import freechips.rocketchip.rocket._
import freechips.rocketchip.tile._
import freechips.rocketchip.tilelink._

import buckyball.util.Util._
import buckyball.util.Pipeline
import buckyball.BuckyBallConfig
import buckyball.front.FrontendTLBIO


// DMA Memory IO类定义
class ScratchpadReadMemIO(local_addr_t: LocalAddr)(implicit p: Parameters) extends CoreBundle {
  val req = Decoupled(new Bundle {
    val vaddr = UInt(coreMaxAddrBits.W)
    val laddr = local_addr_t.cloneType
    val len = UInt(16.W)
    val status = new MStatus
  })
  val resp = Flipped(Decoupled(new Bundle {
    val cmd_id = UInt(8.W)
    val bytesRead = UInt(16.W)
  }))
}

class ScratchpadWriteMemIO(local_addr_t: LocalAddr, accTypeWidth: Int)(implicit p: Parameters) extends CoreBundle {
  val req = Decoupled(new Bundle {
    val vaddr = UInt(coreMaxAddrBits.W)
    val laddr = local_addr_t.cloneType
    val len = UInt(16.W)
    val status = new MStatus
    val cmd_id = UInt(8.W)
  })
  val resp = Flipped(Decoupled(new Bundle {
    val cmd_id = UInt(8.W)
  }))
}


class Scratchpad(config: BuckyBallConfig)
    (implicit p: Parameters) extends LazyModule {

  import config._


  val maxBytes = dma_maxbytes
  val dataBits = dma_buswidth

  val block_rows = veclane
  val block_cols = veclane
  val spad_w = inputType.getWidth *  block_cols
  val acc_w = accType.getWidth * block_cols

  val id_node = TLIdentityNode()
  val xbar_node = TLXbar()

  val reader = LazyModule(new SimpleStreamReader(max_in_flight_mem_reqs, dataBits, maxBytes, spad_w max acc_w))
  val writer = LazyModule(new SimpleStreamWriter(max_in_flight_mem_reqs, dataBits, maxBytes, spad_w max acc_w))

  // TODO make a cross-bar vs two separate ports a config option
  // id_node :=* reader.node
  // id_node :=* writer.node

  xbar_node := TLBuffer() := reader.node // TODO
  xbar_node := TLBuffer() := writer.node
  id_node := TLWidthWidget(config.dma_buswidth/8) := TLBuffer() := xbar_node

  lazy val module = new Impl
  class Impl extends LazyModuleImp(this) with HasCoreParameters {
    val io = IO(new Bundle {
      // DMA ports
      val dma = new Bundle {
        val read = Flipped(new ScratchpadReadMemIO(local_addr_t))
        val write = Flipped(new ScratchpadWriteMemIO(local_addr_t, accType.getWidth))
      }

      // SRAM ports
      val srams = new Bundle {
        val read = Flipped(Vec(sp_banks, new SramReadIO(sp_bank_entries, spad_w)))
        val write = Flipped(Vec(sp_banks, new SramWriteIO(sp_bank_entries, spad_w, (spad_w / (aligned_to * 8)) max 1)))
      }

      // TLB ports
      val tlb = Vec(2, new FrontendTLBIO)

      // Misc. ports
      val busy = Output(Bool())
      val flush = Input(Bool())
    })

    // 简化的DMA写入逻辑
    val simple_write_req = Wire(Decoupled(new SimpleWriteRequest(spad_w max acc_w)))
    val write_data = Reg(UInt((spad_w max acc_w).W))
    val write_data_valid = RegInit(false.B)
    
    // 对于垃圾数据，直接响应成功
    when (io.dma.write.req.bits.laddr.is_garbage()) {
      io.dma.write.req.ready := true.B
      io.dma.write.resp.valid := io.dma.write.req.valid
      io.dma.write.resp.bits.cmd_id := io.dma.write.req.bits.cmd_id
      
      simple_write_req.valid := false.B
      simple_write_req.bits := DontCare
    } .otherwise {
      // 等待写入数据准备就绪
      io.dma.write.req.ready := simple_write_req.ready && write_data_valid
      io.dma.write.resp.valid := false.B
      io.dma.write.resp.bits.cmd_id := DontCare
      
      simple_write_req.valid := io.dma.write.req.valid && write_data_valid
      simple_write_req.bits.vaddr := io.dma.write.req.bits.vaddr
      simple_write_req.bits.len := io.dma.write.req.bits.len * (inputType.getWidth / 8).U
      simple_write_req.bits.status := io.dma.write.req.bits.status
      simple_write_req.bits.data := write_data
    }

    // 连接到简化的writer
    writer.module.io.req <> simple_write_req

    // 简化的DMA读取逻辑  
    val simple_read_req = Wire(Decoupled(new SimpleReadRequest()))
    
    simple_read_req.valid := io.dma.read.req.valid
    simple_read_req.bits.vaddr := io.dma.read.req.bits.vaddr
    simple_read_req.bits.len := (block_cols * inputType.getWidth / 8).U // 读取一行数据
    simple_read_req.bits.status := io.dma.read.req.bits.status
    
    io.dma.read.req.ready := simple_read_req.ready
    
    // 连接到简化的reader
    reader.module.io.req <> simple_read_req

    // 简化的读取响应
    val simple_read_resp_ready = Wire(Bool())
    reader.module.io.resp.ready := simple_read_resp_ready
    
    // 当读取完成时响应
    when (reader.module.io.resp.valid && reader.module.io.resp.bits.last) {
      io.dma.read.resp.valid := true.B
      io.dma.read.resp.bits.cmd_id := 0.U // 简化：不使用cmd_id
      io.dma.read.resp.bits.bytesRead := (block_cols * inputType.getWidth / 8).U
      simple_read_resp_ready := true.B
    } .otherwise {
      io.dma.read.resp.valid := false.B
      io.dma.read.resp.bits := DontCare
      simple_read_resp_ready := true.B // 继续接收数据
    }

    io.tlb(0) <> writer.module.io.tlb
    io.tlb(1) <> reader.module.io.tlb

    writer.module.io.flush := io.flush
    reader.module.io.flush := io.flush

    io.busy := writer.module.io.busy || reader.module.io.busy || simple_write_req.valid || simple_read_req.valid

    val spad_mems = {
      val banks = Seq.fill(sp_banks) { Module(new SramBank(
        sp_bank_entries, spad_w,
        aligned_to, false
      )) }
      val bank_ios = VecInit(banks.map(_.io))
      // Reading from the SRAM banks
      bank_ios.zipWithIndex.foreach { case (bio, i) =>
        val ex_read_req = io.srams.read(i).req
        val exread = ex_read_req.valid

        // TODO we tie the write dispatch queue's, and write issue queue's, ready and valid signals together here
        val dmawrite = io.dma.write.req.valid && write_data_valid &&
          !io.dma.write.req.bits.laddr.is_garbage() &&
          !(bio.write.en && config.sp_singleported.B) &&
          !io.dma.write.req.bits.laddr.is_acc_addr && io.dma.write.req.bits.laddr.sp_bank() === i.U

        bio.read.req.valid := exread || dmawrite
        ex_read_req.ready := bio.read.req.ready

        // The ExecuteController gets priority when reading from SRAMs
        when (exread) {
          bio.read.req.bits.addr := ex_read_req.bits.addr
          bio.read.req.bits.fromDMA := false.B
        }.elsewhen (dmawrite) {
          bio.read.req.bits.addr := io.dma.write.req.bits.laddr.sp_row()
          bio.read.req.bits.fromDMA := true.B

          when (bio.read.req.fire) {
            write_data_valid := true.B
          }
        }.otherwise {
          bio.read.req.bits := DontCare
        }

        val dma_read_resp = Wire(Decoupled(new SramReadResp(spad_w)))
        dma_read_resp.valid := bio.read.resp.valid && bio.read.resp.bits.fromDMA
        dma_read_resp.bits := bio.read.resp.bits
        val ex_read_resp = Wire(Decoupled(new SramReadResp(spad_w)))
        ex_read_resp.valid := bio.read.resp.valid && !bio.read.resp.bits.fromDMA
        ex_read_resp.bits := bio.read.resp.bits

        val dma_read_pipe = Pipeline(dma_read_resp, spad_read_delay)
        val ex_read_pipe = Pipeline(ex_read_resp, 0)

        bio.read.resp.ready := Mux(bio.read.resp.bits.fromDMA, dma_read_resp.ready, ex_read_resp.ready)

        dma_read_pipe.ready := simple_write_req.ready &&
          !io.dma.write.req.bits.laddr.is_acc_addr && io.dma.write.req.bits.laddr.sp_bank() === i.U &&
          !io.dma.write.req.bits.laddr.is_garbage()
        when (dma_read_pipe.fire) {
          write_data := dma_read_pipe.bits.data
        }

        io.srams.read(i).resp <> ex_read_pipe
      }

      // Writing to the SRAM banks
      bank_ios.zipWithIndex.foreach { case (bio, i) =>
        val exwrite = io.srams.write(i).en

        // 简化：不再支持从DMA读取到SRAM的功能，因为SimpleStreamReader
        // 的响应接口不包含地址信息
        bio.write.en := exwrite

        when (exwrite) {
          bio.write.addr := io.srams.write(i).addr
          bio.write.data := io.srams.write(i).data
          bio.write.mask := io.srams.write(i).mask
        }.otherwise {
          bio.write.addr := DontCare
          bio.write.data := DontCare
          bio.write.mask := DontCare
        }
      }
      banks
    }
  }
}
