#include "buckyball.h"
#include <riscv/mmu.h>
#include <riscv/trap.h>
#include <stdexcept>
#include <iostream>
#include <assert.h>
#include <math.h>

using namespace std;

REGISTER_EXTENSION(buckyball, []() { return new buckyball_t; })

#define dprintf(...) { if (p->get_log_commits_enabled()) printf(__VA_ARGS__); }

void buckyball_t::reset() {
  buckyball_state.reset();
}

template <class T>
T buckyball_t::read_from_dram(reg_t addr) {
  T value = 0;
  for (size_t byte_idx = 0; byte_idx < sizeof(T); ++byte_idx) {
    value |= p->get_mmu()->load<uint8_t>(addr + byte_idx) << (byte_idx*8);
  }
  return value;
}

template <class T>
std::vector<std::vector<T>> *
matrix_zeroes(reg_t rows, reg_t cols) {
  return new std::vector<std::vector<T>>(rows, std::vector<T>(cols, 0));
}

template <class T>
std::vector<std::vector<T>> *
buckyball_t::read_matrix_from_dram(reg_t addr, reg_t rows, reg_t cols,
                                  bool zeroable, bool repeating_bias) {
  // Read and return Matrix of size `rows*cols` from address `addr` in main
  // memory

  // Initialize to all zeroes
  auto result = matrix_zeroes<T>(rows, cols);

  // if an input matrix is at addr 0, it is NULL, so don't do anything with
  // it only the D matrix is zeroable; the A, B matrices must be valid
  if(addr == 0) {
    if(zeroable) {
      return result;
    }
    printf("ERROR: non-zeroable matrix given address zero!\n");
    exit(1);
  }

  // Load from memory
  for (size_t i = 0; i < rows; i++) {
    auto ii = repeating_bias ? 0 : i;
    auto const dram_row_addr = addr + ii*sizeof(T)*cols;
    for (size_t j = 0; j < cols; j++) {
      auto const dram_byte_addr = dram_row_addr + j*sizeof(T);
#ifdef ELEM_T_IS_FLOAT
      result->at(i).at(j) = elem_t_bits_to_elem_t(buckyball_t::read_from_dram<elem_t_bits>(dram_byte_addr));
#else
      result->at(i).at(j) = buckyball_t::read_from_dram<elem_t>(dram_byte_addr);
#endif
    }
  }
  return result;
}

template <class T>
void buckyball_t::write_to_dram(reg_t addr, T data) {
  for (size_t byte_idx = 0; byte_idx < sizeof(T); ++byte_idx) {
    p->get_mmu()->store<uint8_t>(addr + byte_idx, (data >> (byte_idx*8)) & 0xFF);
  }
}

// Move a buckyball block from DRAM at dram_addr (byte addr) to
// the scratchpad/accumulator at sp_addr (buckyball-row addressed)
void buckyball_t::mvin(reg_t dram_addr, reg_t sp_addr, int state_id) {

}

//===----------------------------------------------------------------------===//
// 计数器
//===----------------------------------------------------------------------===//
void buckyball_t::counter_increment(unsigned int counter_id) {
  for (size_t i = 0; i < NUM_COUNTERS; i++) {
    if (buckyball_state.counter_config[i] == counter_id) {
      buckyball_state.counter_val[i]++;
      break;
    }
  }
}

