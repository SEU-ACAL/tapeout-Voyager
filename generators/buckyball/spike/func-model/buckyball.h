#ifndef _BUCKYBALL_H
#define _BUCKYBALL_H

#include <riscv/extension.h>
#include <riscv/rocc.h>
#include <vector>
#include "buckyball_params.h"

static const uint32_t sp_matrices = (BANK_NUM * BANK_ROWS) / DIM;
static const uint64_t addr_len = ADDR_LEN;

#define MAKECUSTOMFN(opcode) custom ## opcode
#define CUSTOMFN(opcode) MAKECUSTOMFN(opcode)

struct buckyball_state_t {
  void reset();

  bool enable;
  bool resetted = false;

  std::vector<std::vector<elem_t>> spad; // Scratchpad only
};

class buckyballFunc_t : public extension_t {
public:
  buckyballFunc_t() {}
  const char* name() { return "buckyballFunc"; }

  reg_t CUSTOMFN(XCUSTOM_ACC)(rocc_insn_t insn, reg_t xs1, reg_t xs2);
  void reset();
  void set_processor(processor_t* p) { this->p = p; }

  void mvin(reg_t dram_addr, reg_t sp_addr);
  void mvout(reg_t dram_addr, reg_t sp_addr);
  void matmul_warp16(reg_t rs1, reg_t rs2);

  std::vector<insn_desc_t> get_instructions();
  std::vector<disasm_insn_t*> get_disasms();

private:
  buckyball_state_t buckyball_state;
  processor_t* p;

  const unsigned mvin_funct = 2;   // func7: 0000010
  const unsigned mvout_funct = 3;  // func7: 0000011
  const unsigned matmul_funct = 31; // func7: 0011111 (bb_matmul_warp16)
  const unsigned flush_funct = 7;

  template <class T>
  T read_from_dram(reg_t addr);

  template <class T>
  void write_to_dram(reg_t addr, T data);
};

#endif
