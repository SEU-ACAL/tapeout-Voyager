#include "buckyball.h"
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
  
  printf("buckyball extension configured with:\n");
  printf("    dim = %u\n", DIM);
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
// rs1: mem_addr, rs2: sp_addr[addrLen-1:0] | rows[2*addrLen-1:addrLen] | cols[2*addrLen+9:2*addrLen] 
// cols: 最后一行的元素个数，其他行默认为完整一行(DIM个元素)
void buckyballFunc_t::mvin(reg_t dram_addr, reg_t sp_addr) {
  auto const base_sp_addr = sp_addr & ((1UL << addr_len) - 1);  // rs2[addrLen-1:0]
  auto const rows = (sp_addr >> addr_len) & ((1UL << addr_len) - 1);  // rs2[2*addrLen-1:addrLen]
  auto const last_row_cols = (sp_addr >> (2 * addr_len)) & 0x3FF;  // rs2[2*addrLen+9:2*addrLen], 10 bits

  dprintf("BUCKYBALL: mvin - 0x%02lx last_row_cols and 0x%02lx rows from 0x%08lx to addr 0x%08lx\n", 
          last_row_cols, rows, dram_addr, sp_addr & 0xFFFFFFFF);

  size_t dram_offset = 0;
  for (size_t i = 0; i < rows; ++i) {
    // 前面的行是完整行(DIM个元素)，最后一行是last_row_cols个元素
    size_t current_row_cols = (i == rows - 1) ? last_row_cols : DIM;
    
    for (size_t j = 0; j < current_row_cols; ++j) {
      const size_t spad_row = base_sp_addr + i;
      const size_t spad_col = j;

      auto const dram_byte_addr = dram_addr + dram_offset * sizeof(elem_t);
      elem_t value = read_from_dram<elem_t>(dram_byte_addr);

      buckyball_state.spad.at(spad_row).at(spad_col) = value;

      dprintf("%d ", buckyball_state.spad.at(spad_row).at(spad_col));
      dram_offset++;
    }
    dprintf("\n");
  }
}

// Move data from scratchpad to DRAM  
// rs1: mem_addr, rs2: sp_addr[addrLen-1:0] | rows[addrLen+9:addrLen]
// mvout不存在col，每次都搬完整的行出去(DIM个元素)
void buckyballFunc_t::mvout(reg_t dram_addr, reg_t sp_addr) {
  auto const base_sp_addr = sp_addr & ((1UL << addr_len) - 1);  // rs2[addrLen-1:0]
  auto const rows = (sp_addr >> addr_len) & 0x3FF;  // rs2[addrLen+9:addrLen], 10 bits

  dprintf("buckyball: mvout - 0x%02lx rows from 0x%08lx to addr 0x%08lx\n", 
          rows, sp_addr, dram_addr);

  for (size_t i = 0; i < rows; ++i) {
    auto const dram_row_addr = dram_addr + i*DIM*sizeof(elem_t);

    for (size_t j = 0; j < DIM; ++j) {
      const size_t spad_row = base_sp_addr + i;
      const size_t spad_col = j;

      auto const dram_byte_addr = dram_row_addr + j*sizeof(elem_t);
      elem_t value = buckyball_state.spad.at(spad_row).at(spad_col);

      write_to_dram<elem_t>(dram_byte_addr, value);
      dprintf("%d ", value);
    }
    dprintf("\n");
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

std::vector<disasm_insn_t*> buckyballFunc_t::get_disasms()
{
  std::vector<disasm_insn_t*> insns;
  return insns;
}
