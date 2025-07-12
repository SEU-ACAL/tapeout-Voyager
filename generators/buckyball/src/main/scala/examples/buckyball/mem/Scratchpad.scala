package buckyball.mem

import chisel3._
import chisel3.util._
import org.chipsalliance.cde.config.Parameters
import freechips.rocketchip.tile._

import buckyball.util.Util._
import buckyball.BuckyBallConfig

class Scratchpad(config: BuckyBallConfig)(implicit val p: Parameters) extends Module with HasCoreParameters {
  import config._

  val spad_w = inputType.getWidth * veclane
  val acc_w = accType.getWidth * accveclane

  assert(sp_singleported, "Scratchpad expects single-ported SRAM banks")

  val io = IO(new Bundle {
    val dma = new Bundle {
      val sramread = Flipped(Vec(sp_banks, new SramReadIO(sp_bank_entries, spad_w)))
      val sramwrite = Flipped(Vec(sp_banks, new SramWriteIO(sp_bank_entries, spad_w, (spad_w / (aligned_to * 8)) max 1)))
      val accread = Flipped(Vec(acc_banks, new SramReadIO(acc_bank_entries, acc_w)))
      val accwrite = Flipped(Vec(acc_banks, new AccWriteIO(acc_bank_entries, acc_w, (acc_w / (aligned_to * 8)) max 1)))
    }
    val exec = new Bundle {
      val sramread = Flipped(Vec(sp_banks, new SramReadIO(sp_bank_entries, spad_w)))
      val sramwrite = Flipped(Vec(sp_banks, new SramWriteIO(sp_bank_entries, spad_w, (spad_w / (aligned_to * 8)) max 1)))
      val accread = Flipped(Vec(acc_banks, new SramReadIO(acc_bank_entries, acc_w)))
      val accwrite = Flipped(Vec(acc_banks, new AccWriteIO(acc_bank_entries, acc_w, (acc_w / (aligned_to * 8)) max 1)))
    }
  })

  // SRAM banks
  val spad_mems = Seq.fill(sp_banks) {
    Module(new SramBank(sp_bank_entries, spad_w, aligned_to, sp_singleported))
  }

  // SRAM仲裁逻辑
  spad_mems.zipWithIndex.foreach { case (bank, i) =>
    val dma_read = io.dma.sramread(i)
    val exec_read = io.exec.sramread(i)
    val dma_write = io.dma.sramwrite(i)
    val exec_write = io.exec.sramwrite(i)
    
    // 读请求仲裁：exec优先
    val exec_read_sel = exec_read.req.valid
    val dma_read_sel = dma_read.req.valid && !exec_read_sel
    
    bank.io.read.req.valid := exec_read_sel || dma_read_sel
    bank.io.read.req.bits := Mux(exec_read_sel, exec_read.req.bits, dma_read.req.bits)
    
    dma_read.req.ready := dma_read_sel && bank.io.read.req.ready
    exec_read.req.ready := exec_read_sel && bank.io.read.req.ready
    
    // 响应分发
    val resp_to_dma = RegNext(dma_read_sel && bank.io.read.req.fire, false.B)
    val resp_to_exec = RegNext(exec_read_sel && bank.io.read.req.fire, false.B)
    
    dma_read.resp.valid := bank.io.read.resp.valid && resp_to_dma
    dma_read.resp.bits := bank.io.read.resp.bits
    exec_read.resp.valid := bank.io.read.resp.valid && resp_to_exec
    exec_read.resp.bits := bank.io.read.resp.bits
    
    bank.io.read.resp.ready := 
      (resp_to_dma && dma_read.resp.ready) || (resp_to_exec && exec_read.resp.ready)
    
    // 写请求仲裁：exec优先
    val exec_write_sel = exec_write.en
    bank.io.write.en := Mux(exec_write_sel, exec_write.en, dma_write.en)
    bank.io.write.addr := Mux(exec_write_sel, exec_write.addr, dma_write.addr)
    bank.io.write.data := Mux(exec_write_sel, exec_write.data, dma_write.data)
    bank.io.write.mask := Mux(exec_write_sel, exec_write.mask, dma_write.mask)
  }

  // Accumulator banks
  val acc_mems = Seq.fill(acc_banks) {
    Module(new AccBank(acc_bank_entries, acc_w, aligned_to, sp_singleported))
  }

  // Accumulator仲裁逻辑
  acc_mems.zipWithIndex.foreach { case (bank, i) =>
    val dma_read = io.dma.accread(i)
    val exec_read = io.exec.accread(i)
    val dma_write = io.dma.accwrite(i)
    val exec_write = io.exec.accwrite(i)
    
    // 读请求仲裁：exec优先
    val exec_read_sel = exec_read.req.valid
    val dma_read_sel = dma_read.req.valid && !exec_read_sel
    
    bank.io.read.req.valid := exec_read_sel || dma_read_sel
    bank.io.read.req.bits := Mux(exec_read_sel, exec_read.req.bits, dma_read.req.bits)
    
    dma_read.req.ready := dma_read_sel && bank.io.read.req.ready
    exec_read.req.ready := exec_read_sel && bank.io.read.req.ready
    
    // 响应分发
    val resp_to_dma = RegNext(dma_read_sel && bank.io.read.req.fire, false.B)
    val resp_to_exec = RegNext(exec_read_sel && bank.io.read.req.fire, false.B)
    
    dma_read.resp.valid := bank.io.read.resp.valid && resp_to_dma
    dma_read.resp.bits := bank.io.read.resp.bits
    exec_read.resp.valid := bank.io.read.resp.valid && resp_to_exec
    exec_read.resp.bits := bank.io.read.resp.bits
    
    bank.io.read.resp.ready := 
      (resp_to_dma && dma_read.resp.ready) || (resp_to_exec && exec_read.resp.ready)
    
    // 写请求仲裁：exec优先
    val exec_write_sel = exec_write.en
    bank.io.write.en := Mux(exec_write_sel, exec_write.en, dma_write.en)
    bank.io.write.addr := Mux(exec_write_sel, exec_write.addr, dma_write.addr)
    bank.io.write.data := Mux(exec_write_sel, exec_write.data, dma_write.data)
    bank.io.write.mask := Mux(exec_write_sel, exec_write.mask, dma_write.mask)
    bank.io.write.acc := Mux(exec_write_sel, exec_write.acc, false.B)
  }
}