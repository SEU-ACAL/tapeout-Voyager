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

  val io = IO(new Bundle {
    // SRAM读写接口
    val srams = new Bundle {
      val read = Flipped(Vec(sp_banks, new SramReadIO(sp_bank_entries, spad_w)))
      val write = Flipped(Vec(sp_banks, new SramWriteIO(sp_bank_entries, spad_w, (spad_w / (aligned_to * 8)) max 1)))
    }
    // 额外的读接口用于执行单元
    val exec = new Bundle {
      val readA = Flipped(Vec(sp_banks, new SramReadIO(sp_bank_entries, spad_w)))
      val readB = Flipped(Vec(sp_banks, new SramReadIO(sp_bank_entries, spad_w)))
      val write = Flipped(Vec(sp_banks, new SramWriteIO(sp_bank_entries, spad_w, (spad_w / (aligned_to * 8)) max 1)))
    }
  })

  // SRAM banks - 这就是Scratchpad的全部内容
  val spad_mems = Seq.fill(sp_banks) { Module(new SramBank(
    sp_bank_entries, spad_w,
    aligned_to, true // 需要支持多个读端口
  )) }

  // 连接主要的SRAM接口
  spad_mems.zipWithIndex.foreach { case (bank, i) =>
    // 读取端口仲裁：支持三个读取客户端 (main, execA, execB)
    val main_read_req = io.srams.read(i).req
    val execA_read_req = io.exec.readA(i).req  
    val execB_read_req = io.exec.readB(i).req
    
    // 优先级：execA > execB > main
    val execA_sel = execA_read_req.valid
    val execB_sel = execB_read_req.valid && !execA_sel
    val main_sel = main_read_req.valid && !execA_sel && !execB_sel
    
    // 仲裁输入到 SramBank
    bank.io.read.req.valid := execA_sel || execB_sel || main_sel
    bank.io.read.req.bits := Mux(execA_sel, execA_read_req.bits,
                                 Mux(execB_sel, execB_read_req.bits, main_read_req.bits))
    
    // 反向ready信号
    main_read_req.ready := main_sel && bank.io.read.req.ready
    execA_read_req.ready := execA_sel && bank.io.read.req.ready  
    execB_read_req.ready := execB_sel && bank.io.read.req.ready
    
    // 读取响应分发 - 使用寄存器记录谁发起了请求
    val resp_to_main = RegNext(main_sel && bank.io.read.req.fire, false.B)
    val resp_to_execA = RegNext(execA_sel && bank.io.read.req.fire, false.B)
    val resp_to_execB = RegNext(execB_sel && bank.io.read.req.fire, false.B)
    
    // 主读取接口响应
    io.srams.read(i).resp.valid := bank.io.read.resp.valid && resp_to_main
    io.srams.read(i).resp.bits := bank.io.read.resp.bits
    
    // 执行单元A读取接口响应
    io.exec.readA(i).resp.valid := bank.io.read.resp.valid && resp_to_execA
    io.exec.readA(i).resp.bits := bank.io.read.resp.bits
    
    // 执行单元B读取接口响应
    io.exec.readB(i).resp.valid := bank.io.read.resp.valid && resp_to_execB
    io.exec.readB(i).resp.bits := bank.io.read.resp.bits
    
    // SramBank ready信号由所有客户端的ready决定
    bank.io.read.resp.ready := 
      (resp_to_main && io.srams.read(i).resp.ready) ||
      (resp_to_execA && io.exec.readA(i).resp.ready) ||
      (resp_to_execB && io.exec.readB(i).resp.ready)
    
    // 写入端口仲裁：exec有更高优先级
    val write_sel = io.exec.write(i).en
    
    bank.io.write.en := Mux(write_sel, io.exec.write(i).en, io.srams.write(i).en)
    bank.io.write.addr := Mux(write_sel, io.exec.write(i).addr, io.srams.write(i).addr)
    bank.io.write.data := Mux(write_sel, io.exec.write(i).data, io.srams.write(i).data)
    bank.io.write.mask := Mux(write_sel, io.exec.write(i).mask, io.srams.write(i).mask)
  }
}
