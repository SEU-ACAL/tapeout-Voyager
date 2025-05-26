#ifndef _BUCKYBALL_H
#define _BUCKYBALL_H

#include <riscv/extension.h>
#include <riscv/rocc.h>
#include <random>
#include <limits>
#include "buckyball_params.h"

typedef acc_t output_t; // Systolic array output datatype (coming down from PEs, moving into accumulator)
static const uint32_t sp_matrices = (BANK_NUM * BANK_ROWS) / DIM; // Size the scratchpad to fit sp_matrices matrices
static const uint32_t accum_rows = ACC_ROWS; // Number of systolic array rows in the accumulator
static const uint64_t addr_len = ADDR_LEN; // Number of bits used to address the scratchpad/accumulator
#define LOAD_STATES 3

#ifndef NORM_STAT_IDS
#define NORM_STAT_IDS 4
#endif

// WARNING: If you change this, you must also change the bits in the counter op config register decoding union in gemmini.cc.
#define NUM_COUNTERS 8
#define NUM_EXTERNAL_COUNTERS 6 

#define MAKECUSTOMFN(opcode) custom ## opcode
#define CUSTOMFN(opcode) MAKECUSTOMFN(opcode)


//===----------------------------------------------------------------------===//
// buckyball_state_t 寄存器
//===----------------------------------------------------------------------===//
struct buckyball_state_t {
  enum Dataflow {OS, WS};
  enum Activation {NONE, RELU, LAYERNORM, IGELU, SOFTMAX};
  enum NormCmd {RESET, SUM, MEAN, VARIANCE, INV_STDDEV, MAX, SUM_EXP, INV_SUM_EXP};
  void reset();

  // 32-bit gemmini address space
  uint32_t output_sp_addr;
  uint32_t preload_sp_addr;
  uint16_t preload_cols, preload_rows;
  uint16_t output_cols, output_rows;
  Dataflow mode;
  Activation sys_act;
  Activation acc_act;
  reg_t sys_shift;
  acc_t igelu_qb, igelu_qc;
  acc_t qln2, qln2_inv;
  reg_t load_strides[LOAD_STATES];
  reg_t store_stride;
  uint16_t load_block_strides[LOAD_STATES];
  bool load_shrunks[LOAD_STATES];
#if defined(HAS_MVIN_SCALE) || defined(HAS_MVIN_ACC_SCALE)
  scale_t load_scales[LOAD_STATES];
#endif
  uint8_t pixels_per_rows[LOAD_STATES];
  acc_scale_t acc_shift;
  acc_scale_t sys_acc_shift;
  uint16_t c_stride;
  uint16_t a_stride;
  uint8_t pool_stride;
  uint8_t pool_size;
  uint8_t pool_out_dim;
  uint8_t pool_porows;
  uint8_t pool_pocols;
  uint8_t pool_orows;
  uint8_t pool_ocols;
  uint8_t pool_lpad;
  uint8_t pool_upad;
  bool a_transpose;
  bool b_transpose;
  uint16_t loop_ws_I, loop_ws_J, loop_ws_K;
  uint16_t loop_ws_pad_I, loop_ws_pad_J, loop_ws_pad_K;
  uint64_t loop_ws_A, loop_ws_B, loop_ws_D, loop_ws_C;
  uint64_t loop_ws_A_stride, loop_ws_B_stride, loop_ws_D_stride, loop_ws_C_stride;
  uint16_t loop_conv_ws_batch_size, loop_conv_ws_in_row_dim, loop_conv_ws_in_col_dim, loop_conv_ws_in_channels, loop_conv_ws_out_channels;
  uint16_t loop_conv_ws_in_stride, loop_conv_ws_weight_stride, loop_conv_ws_out_stride;
  uint16_t loop_conv_ws_out_row_dim, loop_conv_ws_pool_out_row_dim, loop_conv_ws_out_col_dim, loop_conv_ws_pool_out_col_dim, loop_conv_ws_stride, loop_conv_ws_padding;
  uint16_t loop_conv_ws_kernel_dim, loop_conv_ws_pool_size, loop_conv_ws_pool_stride, loop_conv_ws_pool_padding;
  uint16_t loop_conv_ws_batches, loop_conv_ws_porows, loop_conv_ws_pocols, loop_conv_ws_pochs;
  uint16_t loop_conv_ws_krows, loop_conv_ws_kcols, loop_conv_ws_kchs, loop_conv_ws_lpad;
  uint16_t loop_conv_ws_rpad, loop_conv_ws_upad, loop_conv_ws_dpad, loop_conv_ws_plpad;
  uint16_t loop_conv_ws_prad, loop_conv_ws_pupad, loop_conv_ws_pdpad, loop_conv_ws_orows;
  uint16_t loop_conv_ws_ocols, loop_conv_ws_kernel_dilation;
  uint64_t loop_conv_ws_input, loop_conv_ws_weights, loop_conv_ws_output, loop_conv_ws_bias;

  // Normalization statistics
  uint8_t norm_stat_id;
  acc_t norm_sum[NORM_STAT_IDS];
  acc_t norm_running_max[NORM_STAT_IDS];
  acc_t norm_max[NORM_STAT_IDS];
  acc_t norm_count[NORM_STAT_IDS];
  acc_t norm_mean[NORM_STAT_IDS];
  acc_scale_t norm_inv_stddev[NORM_STAT_IDS];
  acc_scale_t norm_inv_sum_exp[NORM_STAT_IDS];
  bool norm_reset[NORM_STAT_IDS];

  // Counter
  uint32_t counter_val[NUM_COUNTERS];
  uint32_t counter_snapshot_val[NUM_COUNTERS];
  uint16_t counter_config[NUM_COUNTERS];
  uint32_t counter_external[NUM_EXTERNAL_COUNTERS];
  bool counter_external_flag[NUM_COUNTERS];
  bool snapshot_enable;
  bool op_in_progress;

  bool enable;
  bool resetted = false;

  std::vector<std::vector<elem_t>> spad; // Scratchpad constructed as systolic array rows
  std::vector<std::vector<acc_t>> pe_state; // Stores each PE's internal accumulator state
  std::vector<std::vector<acc_t>> accumulator;

  // cisc state
  reg_t a_addr, b_addr, c_addr, d_addr;
  reg_t m, n, k;
  bool repeating_bias;
};

//===----------------------------------------------------------------------===//
// extension_t 指令集
//===----------------------------------------------------------------------===//
class buckyball_t : public extension_t {
public:
  buckyball_t() : cause(0), aux(0), debug(false) {}
  const char* name() override { return "buckyball"; }

  reg_t CUSTOMFN(XCUSTOM_ACC)(rocc_insn_t insn, reg_t xs1, reg_t xs2);
  void reset();
  void set_processor(processor_t* p) { this->p = p; }

  void mvin(reg_t dram_addr, reg_t sp_addr, int state_id);
  void mvout(reg_t dram_addr, reg_t sp_addr);
  void compute(reg_t a_addr, reg_t bd_addr, bool preload);

  virtual std::vector<insn_desc_t> get_instructions() override;
  virtual std::vector<disasm_insn_t*> get_disasms() override;

private:
  buckyball_state_t buckyball_state;
  reg_t cause;
  reg_t aux;
  bool debug;
  processor_t* p;

  const unsigned mvin_funct = 2;
  const unsigned flush_funct = 7;
  const unsigned fence_funct = 127;

  template <class T>
  T read_from_dram(reg_t addr);

  template <class T>
  std::vector<std::vector<T>> *
  read_matrix_from_dram(reg_t addr, reg_t rows, reg_t cols, 
                        bool zeroable, bool repeating_bias);

  template <class T>
  void write_to_dram(reg_t addr, T data);

  void counter_increment(unsigned int counter_id);
};

#endif
