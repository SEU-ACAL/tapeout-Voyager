#include "buckyball.h"
#include <cstdio>
#include <riscv/mmu.h>
#include <riscv/trap.h>
#include <iostream>

using namespace std;

REGISTER_EXTENSION(buckyballFunc, []() { return new buckyballFunc_t; })

#define dprintf(...) { if (p->get_log_commits_enabled()) printf(__VA_ARGS__); }

void buckyball_state_t::reset() {
  enable = true;
  
  spad.clear();
  spad.resize(sp_matrices*DIM, std::vector<elem_t>(DIM, 0));
  
  resetted = true;
  
  // printf("buckyball extension configured with:\n");
  // printf("    dim = %u\n", DIM);
}

void buckyballFunc_t::reset() {
  buckyball_state.reset();
}

template <class T>
T buckyballFunc_t::read_from_dram(reg_t addr) {
  T value = 0;
  for (size_t byte_idx = 0; byte_idx < sizeof(T); ++byte_idx) {
    value |= p->get_mmu()->load<uint8_t>(addr + byte_idx) << (byte_idx*8);
  }
  return value;
}

template <class T>
void buckyballFunc_t::write_to_dram(reg_t addr, T data) {
  for (size_t byte_idx = 0; byte_idx < sizeof(T); ++byte_idx) {
    p->get_mmu()->store<uint8_t>(addr + byte_idx, (data >> (byte_idx*8)) & 0xFF);
  }
}

// Move data from DRAM to scratchpad
// rs1: mem_addr, rs2: sp_addr[spAddrLen-1:0] | rows[spAddrLen+9:spAddrLen]
// 每次都搬运完整的行(DIM个元素)
void buckyballFunc_t::mvin(reg_t rs1, reg_t rs2) {
  auto const base_dram_addr = rs1 & ((1UL << memAddrLen) - 1); // rs1 memddrLen-1:0
  auto const base_sp_addr = rs2 & ((1UL << spAddrLen) - 1);  // rs2[spAddrLen-1:0]
  auto const rows = (rs2 >> spAddrLen) & 0x3FF;  // rs2[spAddrLen+9:spAddrLen], 10 bits
  
  dprintf("rs1=%lx, rs2=%lx\n", rs1, rs2);
  dprintf("BUCKYBALL: mvin - 0x%02lx rows from mem 0x%08lx to spad 0x%08lx\n", 
          rows, base_dram_addr, base_sp_addr);
  
  for (size_t i = 0; i < rows; ++i) {
    auto const dram_row_addr = base_dram_addr + i*DIM*sizeof(elem_t);
    const size_t spad_row = base_sp_addr + i;

    for (size_t j = 0; j < DIM; ++j) {
      auto const dram_byte_addr = dram_row_addr + j*sizeof(elem_t);
      elem_t value = read_from_dram<elem_t>(dram_byte_addr);
      buckyball_state.spad.at(spad_row).at(j) = value;
      // dprintf("%d ", value);
    }
    // dprintf("\n");
  }
}

// Move data from scratchpad to DRAM  
// rs1: mem_addr, rs2: sp_addr[spAddrLen-1:0] | rows[spAddrLen+9:spAddrLen]
// 每次都搬运完整的行(DIM个元素)
void buckyballFunc_t::mvout(reg_t rs1, reg_t rs2) {
  auto const base_dram_addr = rs1 & ((1UL << memAddrLen) - 1); // rs1 memddrLen-1:0
  auto const base_sp_addr = rs2 & ((1UL << spAddrLen) - 1);  // rs2[spAddrLen-1:0]
  auto const rows = (rs2 >> spAddrLen) & 0x3FF;  // rs2[spAddrLen+9:spAddrLen], 10 bits

  dprintf("rs1=%lx, rs2=%lx\n", rs1, rs2);
  dprintf("BUCKYBALL: mvout - 0x%02lx rows from spad 0x%08lx to mem 0x%08lx\n", 
          rows, base_sp_addr, base_dram_addr);

  for (size_t i = 0; i < rows; ++i) {
    auto const dram_row_addr = base_dram_addr + i*DIM*sizeof(elem_t);
    const size_t spad_row = base_sp_addr + i;

    for (size_t j = 0; j < DIM; ++j) {
      auto const dram_byte_addr = dram_row_addr + j*sizeof(elem_t);
      elem_t value = buckyball_state.spad.at(spad_row).at(j);
      write_to_dram<elem_t>(dram_byte_addr, value);
      // dprintf("%d ", value);
    }
    // dprintf("\n");
  }
}

// Matrix multiplication using warp16 pattern (simplified placeholder)
void buckyballFunc_t::matmul_warp16(reg_t rs1, reg_t rs2) {
  dprintf("buckyball: matmul_warp16 - rs1=0x%08lx, rs2=0x%08lx\n", rs1, rs2);
  

}

reg_t buckyballFunc_t::CUSTOMFN(XCUSTOM_ACC)(rocc_insn_t insn, reg_t xs1, reg_t xs2) {
  if (!buckyball_state.resetted) {
    reset();
  }

  if (insn.funct == mvin_funct) {
    mvin(xs1, xs2);
  } else if (insn.funct == mvout_funct) {
    mvout(xs1, xs2);
  } else if (insn.funct == matmul_funct) {
    matmul_warp16(xs1, xs2);
  } else if (insn.funct == flush_funct) {
    dprintf("buckyball: flush\n");
  } else {
    dprintf("buckyball: encountered unknown instruction with funct: %d\n", insn.funct);
    illegal_instruction();
  }
  
  return 0;
}

static reg_t buckyball_custom(processor_t* p, insn_t insn, reg_t pc) {
  buckyballFunc_t* buckyball = static_cast<buckyballFunc_t*>(p->get_extension("buckyballFunc"));
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

std::vector<insn_desc_t> buckyballFunc_t::get_instructions() {
  std::vector<insn_desc_t> insns;
  push_custom_insn(insns, ROCC_OPCODE3, ROCC_OPCODE_MASK, ILLEGAL_INSN_FUNC, buckyball_custom);
  return insns;
}

std::vector<disasm_insn_t*> buckyballFunc_t::get_disasms() {
  std::vector<disasm_insn_t*> insns;
  
  // Define argument types for buckyball instructions
  struct : public arg_t {
    std::string to_string(insn_t insn) const {
      return "x" + std::to_string(insn.rs1());
    }
  } static buckyball_rs1;
  
  struct : public arg_t {
    std::string to_string(insn_t insn) const {
      return "x" + std::to_string(insn.rs2());
    }
  } static buckyball_rs2;
  
  // Custom-3 opcode is ROCC_OPCODE3 (0111 1011)
  // MVIN instruction (funct = 24)
  insns.push_back(new disasm_insn_t("bb_mvin", 
    ROCC_OPCODE3 | (24 << 25), 
    ROCC_OPCODE_MASK | (0x7F << 25), 
    {&buckyball_rs1, &buckyball_rs2}));
  
  // MVOUT instruction (funct = 25)
  insns.push_back(new disasm_insn_t("bb_mvout", 
    ROCC_OPCODE3 | (25 << 25), 
    ROCC_OPCODE_MASK | (0x7F << 25), 
    {&buckyball_rs1, &buckyball_rs2}));
  
  // MATMUL instruction (funct = 32)
  insns.push_back(new disasm_insn_t("bb_matmul_warp16", 
    ROCC_OPCODE3 | (32 << 25), 
    ROCC_OPCODE_MASK | (0x7F << 25), 
    {&buckyball_rs1, &buckyball_rs2}));
  
  // FLUSH instruction (funct = 7) - no operands needed
  insns.push_back(new disasm_insn_t("bb_flush", 
    ROCC_OPCODE3 | (7 << 25), 
    ROCC_OPCODE_MASK | (0x7F << 25), 
    {}));
  
  return insns;
}
