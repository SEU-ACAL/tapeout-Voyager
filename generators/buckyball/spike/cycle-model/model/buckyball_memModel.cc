#include "../include/buckyball_model.h"
#include "../include/buckyball.h"
#include <riscv/mmu.h>
#include <riscv/trap.h>
#include <assert.h>
#include <math.h>

using namespace std;

// 包含sisyphus_state_t的定义
#include "../frame/buckyball_sisyphus.cc"

// Memory Read Bus
struct memReadBus {
  size_t memAddrInput; // from dram
  size_t spadAddrInput; // to spad
  std::vector<elem_t> rdataOutput;
  lantency_t latency;               

  std::vector<elem_t> exec_once(size_t memAddrInput, size_t spadAddrInput) {
    this->memAddrInput = memAddrInput;
    this->spadAddrInput = spadAddrInput;
    rdataOutput = buckyball::read_from_dram<std::vector<elem_t>>(memAddrInput);
    return rdataOutput;
  }
};

// Memory Write Bus
struct memWriteBus {
  size_t memAddrInput; // to dram
  size_t spadAddrInput; // from spad
  std::vector<elem_t> wdataInput;
  lantency_t latency;               

  void exec_once(size_t memAddrInput, size_t spadAddrInput, std::vector<elem_t> wdataInput) {
    this->memAddrInput = memAddrInput;
    this->spadAddrInput = spadAddrInput;
    this->wdataInput = wdataInput;
    buckyball::write_to_dram<std::vector<elem_t>>(memAddrInput, wdataInput);
  }
};


struct unified_bus {
  memReadBus* memRead = new memReadBus();
  memWriteBus* memWrite = new memWriteBus();
  
  size_t memAddrInput;
  size_t spadAddrInput;
  std::vector<elem_t> wdataInput;
  std::vector<elem_t> rdataOutput;
  
  lantency_t latency;
  int64_t total_iter = 0;
  size_t current_iter = 0;
  size_t cycle = 0;

  bool start = false;
  bool arrive = false;
  bool finish = false;

  unified_bus() {}
  
  ~unified_bus() {
    if (memRead) delete memRead;
    if (memWrite) delete memWrite;
  }

  void reset() {
    cycle = 0;
    current_iter = 0;
    memAddrInput = 0;
    spadAddrInput = 0;
    wdataInput = {};
    rdataOutput = {};
    
    start = false;
    arrive = false;
    finish = false;
  }

  // 执行操作的核心方法
  std::vector<elem_t> exec_once(std::string type) { 
    if (type == "read" && memRead) {
      size_t offset = current_iter * memRead->rdataOutput.size();
      memRead->exec_once(memAddrInput + offset, spadAddrInput + offset);   
      cycle++;
      current_iter++;
      sync_state();
      return memRead->rdataOutput;
    } else if (type == "write" && memWrite) {
      size_t offset = current_iter * memWrite->wdataInput.size();
      memWrite->exec_once(memAddrInput + offset, spadAddrInput + offset, wdataInput);
      cycle++;
      current_iter++;
      sync_state();

      return std::vector<elem_t>();
    }
    return std::vector<elem_t>();
  }

  void sync_state() {
    if (cycle == 1) { start = true; }
    if (cycle > 0) { arrive = true; }
    if (cycle == total_iter) { finish = true; }
  }

  void set_read(size_t memAddrInput, size_t spadAddrInput, size_t iteration) {
    this->memAddrInput = memAddrInput;
    this->spadAddrInput = spadAddrInput;
    this->total_iter = total_iter;
  }
  
  void set_write(size_t memAddrInput, size_t spadAddrInput, std::vector<elem_t> wdataInput, size_t iteration) {
    this->memAddrInput = memAddrInput;
    this->spadAddrInput = spadAddrInput;
    this->wdataInput = wdataInput;
    this->total_iter = total_iter;
  }
};
