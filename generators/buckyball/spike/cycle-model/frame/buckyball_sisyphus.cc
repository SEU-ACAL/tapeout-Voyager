#include "../include/buckyball_frame.h"
#include <riscv/mmu.h>
#include <riscv/trap.h>
#include <stdexcept>
#include <iostream>
#include <assert.h>
#include <math.h>

using namespace std;



#include <cstdio>

// 前向声明

//===----------------------------------------------------------------------===//
// sisyphus
//===----------------------------------------------------------------------===//
template<typename ModelType>
struct sisyphus_state_t {
  int8_t sid;
  ModelType model;

  int64_t cycle;
  int64_t iteration;
  
  // 来自内部model
  bool start = model.start; 
  bool arrive = model.arrive;
  bool finish = model.finish;

  // 来自外部pipeline
  bool hungry;  // 被上一级饥饿
  bool blocked; // 被下一级阻塞  

  processor_t* processor_ref;
  
  sisyphus_state_t() : sid(-1), cycle(0), iteration(0), hungry(false), blocked(false), processor_ref(nullptr) {}
  
  
  // 提供给内部model的接口
  void set_start(bool start) { this->start = start;}
  void set_arrive(bool arrive) { this->arrive = arrive;}
  void set_finish(bool finish) { this->finish = finish;}

  // 提供给外部pipeline的接口
  void set_sid(int8_t sid) { this->sid = sid;}
  void set_hungry(bool hungry) { this->hungry = hungry;}
  void set_blocked(bool blocked) { this->blocked = blocked;}

  void exec_once(int64_t iteration) { model.exec_once(iteration);}
  
  void tick() {
    if (start && !finish) {
      cycle++;
    } 

    if (!hungry && !blocked) {
      // 可以通过model.input()/model.output() 来获取输入/输出
      exec_once(iteration); 

      if (arrive && !finish && iteration > 0) {
        iteration--;
        if (iteration == 0) { reset(); }
      }
    }
  }
  
  bool is_start() { return start; }
  bool is_arrive() { return arrive; }
  bool is_finish() { return finish; }
  bool is_hungry() { return hungry; }
  bool is_blocked() { return blocked; }

  void reset() {
    cycle = 0;
    iteration = 0;

    start = false;
    arrive = false;
    finish = false;

    hungry = false;
    blocked = false;
  }

  int64_t get_cycle() const {
    return cycle;
  }
  
  // 获取当前状态信息
  std::string get_status() const {
    std::string status = "sisyphus_" + std::to_string(sid) + " cycle:" + std::to_string(cycle);
    if (start) status += " [STARTED]";
    if (arrive) status += " [ARRIVED]";
    if (finish) status += " [FINISHED]";
    return status;
  }
};
