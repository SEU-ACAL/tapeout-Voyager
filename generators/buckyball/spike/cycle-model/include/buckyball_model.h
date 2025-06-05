#ifndef _BUCKYBALL_MODEL_H
#define _BUCKYBALL_MODEL_H

// #include <riscv/extension.h>
// #include <riscv/rocc.h>
#include <random>
#include <limits>
#include <vector>
#include <string>
#include <memory>
#include "buckyball.h"


//===----------------------------------------------------------------------===//
// Base Model
//===----------------------------------------------------------------------===//
template<typename ModelType>
struct unifiedModel {
  // Attr
  std::string type;
  // input
  // InputType input;
  // Processer
  ModelType model;
  // state Register
  bool start = model.start;
  bool arrive = model.arrive;
  bool finish = model.finish;
  // output
  // OutputType output;
  unifiedModel(std::string type) : type(type) {}
  virtual ~unifiedModel() = default;

  // virtual void exec_once(int64_t iteration) = 0;
  // virtual void sync_state() = 0;
  // virtual void reset() = 0;
};

//===----------------------------------------------------------------------===//
// Vector Model
//===----------------------------------------------------------------------===//
// struct unified_thread;
// template<typename T> struct warp;
// template<typename... ThreadTypes> using unified_warp = warp<unified_thread>;

// using buckyball_vecModel = unifiedModel<unified_warp<unified_thread>>;
//===----------------------------------------------------------------------===//
// Memory Model
//===----------------------------------------------------------------------===//
// struct memReadBus;
// struct memWriteBus;
struct unified_bus;
using buckyball_memModel = unifiedModel<unified_bus>;



#endif
