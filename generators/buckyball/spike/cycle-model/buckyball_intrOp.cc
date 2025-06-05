#include "./include/buckyball.h"
#include <riscv/mmu.h>
#include <riscv/trap.h>
#include <stdexcept>
#include <iostream>
#include <assert.h>
#include <math.h>
#include <cstring>

using namespace std;

// REGISTER_EXTENSION is defined in buckyball.cc

#define dprintf(...) { if (p->get_log_commits_enabled()) printf(__VA_ARGS__); }

void buckyball_state_t::reset() {
  spad.clear();
  accumulator.clear();
  // 可以在这里添加其他需要重置的状态
}

void buckyballCycle_t::reset() {
  buckyball_state.reset();
}

template <class T>
T buckyballCycle_t::read_from_dram(reg_t addr) {
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
buckyballCycle_t::read_matrix_from_dram(reg_t addr, reg_t rows, reg_t cols,
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
      result->at(i).at(j) = elem_t_bits_to_elem_t(buckyballCycle_t::read_from_dram<elem_t_bits>(dram_byte_addr));
#else
      result->at(i).at(j) = buckyballCycle_t::read_from_dram<elem_t>(dram_byte_addr);
#endif
    }
  }
  return result;
}

template <class T>
void buckyballCycle_t::write_to_dram(reg_t addr, T data) {
  for (size_t byte_idx = 0; byte_idx < sizeof(T); ++byte_idx) {
    p->get_mmu()->store<uint8_t>(addr + byte_idx, (data >> (byte_idx*8)) & 0xFF);
  }
}

// Move a buckyball block from DRAM at dram_addr (byte addr) to
// the scratchpad/accumulator at sp_addr (buckyball-row addressed)
void buckyballCycle_t::mvin(reg_t rs1, reg_t rs2) {
  // rs1 = memAddr
  // rs2 = nlen << addrLen | spadAddr
  int addrlen = 14;

  int nlen = (rs2 >> (2 * addrlen)) & 0xFFFF;
  size_t memAddr = rs1;
  size_t spadAddr = rs2 & 0xFFFF;

  // TODO: 实现内存模型的set_read调用
  // buckyball_state.memSisyphus->set_read(memAddr, spadAddr, nlen);

}

void buckyballCycle_t::mvout(reg_t rs1, reg_t rs2) {
  // rs1 = memAddr
  // rs2 = nlen << addrLen | spadAddr
  int addrlen = 14;

  int nlen = (rs2 >> (2 * addrlen)) & 0xFFFF;
  size_t memAddr = rs1;
  size_t spadAddr = rs2 & 0xFFFF;

  // TODO: 实现内存模型的set_write调用
  // buckyball_state.memSisyphus->set_write(memAddr, spadAddr, nlen);
}

void buckyballCycle_t::matmul(reg_t rs1, reg_t rs2) {
  // rs1 = nLen << (2 * addrLen) | aSpAddr << addrLen | bSpAddr
  // rs2 = cSpAddr
  int addrlen = 14;

  int nLen = (rs1 >> (2 * addrlen)) & 0xFFFF;
  int aSpAddr = (rs1 >> addrlen) & 0xFFFF;
  int bSpAddr = rs1 & 0xFFFF;
  int cSpAddr = rs2;

}

//===----------------------------------------------------------------------===//
// 计数器
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// buckyball命名空间函数实现
//===----------------------------------------------------------------------===//

// 全局处理器引用，用于buckyball命名空间函数
static processor_t* global_processor = nullptr;

namespace buckyball {
  void set_processor(processor_t* p) {
    global_processor = p;
  }
  
  processor_t* get_processor() {
    return global_processor;
  }
  
  template <class T>
  T read_from_dram(reg_t addr) {
    if (!global_processor) {
      throw std::runtime_error("Global processor not set for buckyball namespace");
    }
    T value;
    // 使用memcpy来读取任意类型的数据
    uint8_t* data = new uint8_t[sizeof(T)];
    for (size_t byte_idx = 0; byte_idx < sizeof(T); ++byte_idx) {
      data[byte_idx] = global_processor->get_mmu()->load<uint8_t>(addr + byte_idx);
    }
    memcpy(&value, data, sizeof(T));
    delete[] data;
    return value;
  }
  
  template <class T>
  void write_to_dram(reg_t addr, T data) {
    if (!global_processor) {
      throw std::runtime_error("Global processor not set for buckyball namespace");
    }
    // 使用memcpy来写入任意类型的数据
    uint8_t* bytes = new uint8_t[sizeof(T)];
    memcpy(bytes, &data, sizeof(T));
    for (size_t byte_idx = 0; byte_idx < sizeof(T); ++byte_idx) {
      global_processor->get_mmu()->store<uint8_t>(addr + byte_idx, bytes[byte_idx]);
    }
    delete[] bytes;
  }
  
  template <class T>
  std::vector<std::vector<T>>* read_matrix_from_dram(reg_t addr, reg_t rows, reg_t cols, 
                                                     bool zeroable, bool repeating_bias) {
    if (!global_processor) {
      throw std::runtime_error("Global processor not set for buckyball namespace");
    }
    
    // Initialize to all zeroes
    auto result = matrix_zeroes<T>(rows, cols);

    // if an input matrix is at addr 0, it is NULL, so don't do anything with it
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
        result->at(i).at(j) = elem_t_bits_to_elem_t(read_from_dram<elem_t_bits>(dram_byte_addr));
#else
        result->at(i).at(j) = read_from_dram<elem_t>(dram_byte_addr);
#endif
      }
    }
    return result;
  }
}

// 显式实例化常用的模板
template elem_t buckyball::read_from_dram<elem_t>(reg_t addr);
template void buckyball::write_to_dram<elem_t>(reg_t addr, elem_t data);
template std::vector<elem_t> buckyball::read_from_dram<std::vector<elem_t>>(reg_t addr);
template void buckyball::write_to_dram<std::vector<elem_t>>(reg_t addr, std::vector<elem_t> data);
