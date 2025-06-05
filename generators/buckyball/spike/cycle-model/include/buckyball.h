#ifndef _BUCKYBALL_H
#define _BUCKYBALL_H

#include <riscv/extension.h>
#include <riscv/rocc.h>
#include <random>
#include <limits>
#include "buckyball_params.h"
#include "buckyball_model.h"
// #include "buckyball_model.h"

// 前向声明
template<typename T> struct sisyphus_state_t;
struct unified_bus;

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
// Some constraints:
// 32-bit address space
//===----------------------------------------------------------------------===//

struct buckyball_state_t {
  void reset();

  std::vector<std::vector<elem_t>> spad; 
  std::vector<std::vector<acc_t>> accumulator;

  // 暂时注释掉以避免不完整类型问题
  // std::unique_ptr<sisyphus_state_t<unified_bus>> memSisyphus;
  
//   std::vector<vector_sisyphus_t> vector_sisyphus;
//   std::vector<matrix_sisyphus_t> matrix_sisyphus;
  
//   // Connection topology between sisyphus units
//   sisyphusConnectionArray_t sisyphus_connections;
};

//===----------------------------------------------------------------------===//
// buckyball namespace - 提供静态的内存访问函数
//===----------------------------------------------------------------------===//
namespace buckyball {
  // 前向声明，实现在 buckyball_intrOp.cc 中
  template <class T>
  T read_from_dram(reg_t addr);
  
  template <class T>
  void write_to_dram(reg_t addr, T data);
  
  template <class T>
  std::vector<std::vector<T>>* read_matrix_from_dram(reg_t addr, reg_t rows, reg_t cols, 
                                                     bool zeroable, bool repeating_bias);
  
  // 设置全局处理器引用，用于内存访问
  void set_processor(processor_t* p);
  processor_t* get_processor();
}

//===----------------------------------------------------------------------===//
// extension_t 指令集
//===----------------------------------------------------------------------===//
class buckyballCycle_t : public extension_t {
public:
  buckyballCycle_t() : cause(0), aux(0), debug(false) {}
  const char* name() override { return "buckyballCycle"; }

  reg_t CUSTOMFN(XCUSTOM_ACC)(rocc_insn_t insn, reg_t xs1, reg_t xs2);
  void reset();
  void set_processor(processor_t* p) { 
    this->p = p; 
    buckyball::set_processor(p);  // 同时设置命名空间的全局处理器
  }

  void mvin(reg_t rs1, reg_t rs2);
  void mvout(reg_t rs1, reg_t rs2);
  void matmul(reg_t rs1, reg_t rs2);

  virtual std::vector<insn_desc_t> get_instructions() override;
  virtual std::vector<disasm_insn_t*> get_disasms() override;

  template <class T> // T=什么类型，读什么类型
  T read_from_dram(reg_t addr); 

  template <class T> 
  std::vector<std::vector<T>> *
  read_matrix_from_dram(reg_t addr, reg_t rows, reg_t cols, 
                        bool zeroable, bool repeating_bias);

  template <class T> // T=什么类型，写什么类型
  void write_to_dram(reg_t addr, T data);

private:
  buckyball_state_t buckyball_state;
  reg_t cause;
  reg_t aux;
  bool debug;
  processor_t* p;

  const unsigned mvin_funct    = 1;
  const unsigned mvout_funct   = 2;
  const unsigned matmul_funct  = 3;
  const unsigned flush_funct   = 7;
  const unsigned fence_funct   = 127;



  void counter_increment(unsigned int counter_id);
};

#endif


