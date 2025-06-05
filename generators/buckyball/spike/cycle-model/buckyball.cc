#include "include/buckyball.h"
#include <riscv/mmu.h>
#include <riscv/trap.h>
#include <stdexcept>
#include <iostream>
#include <assert.h>
#include <math.h>

using namespace std;

REGISTER_EXTENSION(buckyballCycle, []() { return new buckyballCycle_t; })

#define dprintf(...) { if (p->get_log_commits_enabled()) printf(__VA_ARGS__); }

//===----------------------------------------------------------------------===//
// 所有指令实现的索引
//===----------------------------------------------------------------------===//
reg_t buckyballCycle_t::CUSTOMFN(XCUSTOM_ACC)(rocc_insn_t insn, reg_t xs1, reg_t xs2) {
  if (insn.funct == mvin_funct) {
    mvin(xs1, xs2);
  } else if (insn.funct == mvout_funct) {
    mvout(xs1, xs2);
  } else if (insn.funct == matmul_funct) {
    matmul(xs1, xs2);
  } else if (insn.funct == fence_funct) {
    dprintf("BUCKYBALL: fence instruction\n");
  } else {
    dprintf("BUCKYBALL: encountered unknown instruction with funct: %d\n", insn.funct);
    illegal_instruction();
  }
  return 0;
}

//===----------------------------------------------------------------------===//
// 自定义指令
//===----------------------------------------------------------------------===//
static reg_t buckyball_custom(processor_t* p, insn_t insn, reg_t pc) {
  buckyballCycle_t* buckyball = static_cast<buckyballCycle_t*>(p->get_extension("buckyballCycle"));
  rocc_insn_union_t u;
  state_t* state = p->get_state();
  buckyball->set_processor(p);
  u.i = insn;
  reg_t xs1 = u.r.xs1 ? state->XPR[insn.rs1()] : -1;
  reg_t xs2 = u.r.xs2 ? state->XPR[insn.rs2()] : -1;
  reg_t xd = buckyball->CUSTOMFN(XCUSTOM_ACC)(u.r, xs1, xs2);
  if (u.r.xd) {
    state->log_reg_write[insn.rd() << 4] = {xd, 0};
    state->XPR.write(insn.rd(), xd);
  }
  return pc+4;
}

//===----------------------------------------------------------------------===//
// 注册指令，负责将指令集注册到Spike中
//===----------------------------------------------------------------------===//
std::vector<insn_desc_t> buckyballCycle_t::get_instructions() {
  std::vector<insn_desc_t> insns;
  push_custom_insn(insns, ROCC_OPCODE3, ROCC_OPCODE_MASK, ILLEGAL_INSN_FUNC, buckyball_custom);
  return insns;
}

//===----------------------------------------------------------------------===//
// 反汇编：目前返回空值，不支持反汇编
//===----------------------------------------------------------------------===//
std::vector<disasm_insn_t*> buckyballCycle_t::get_disasms() {
  std::vector<disasm_insn_t*> insns;
  
  // Define argument types for buckyball instructions
  struct : public arg_t {
    std::string to_string(insn_t insn) const {
      return "0x" + std::to_string(insn.rs1());
    }
  } static buckyball_rs1;
  
  struct : public arg_t {
    std::string to_string(insn_t insn) const {
      return "0x" + std::to_string(insn.rs2());
    }
  } static buckyball_rs2;
  
  struct : public arg_t {
    std::string to_string(insn_t insn) const {
      return "0x" + std::to_string(insn.rd());
    }
  } static buckyball_rd;
  
  // Add disassembly for common buckyball instructions
  // MVIN instruction (funct = 2)
  insns.push_back(new disasm_insn_t("buckyball.mvin", 
    ROCC_OPCODE3 | (mvin_funct << 25), 
    ROCC_OPCODE_MASK | (0x7F << 25), 
    {&buckyball_rs1, &buckyball_rs2}));
  
  return insns;
}

// reset() function is defined in buckyball_intrOp.cc
