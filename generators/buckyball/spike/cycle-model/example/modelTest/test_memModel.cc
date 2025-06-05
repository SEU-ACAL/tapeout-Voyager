#include "../../include/buckyball_model.h"
#include "../../model/buckyball_memModel.cc"
#include <iostream>
#include <cassert>

// 测试新的内存模型设计
void test_unified_bus_standalone() {
  std::cout << "Testing unified_bus standalone..." << std::endl;
  
  // 创建unified_bus实例
  unified_bus bus;
  
  // 测试初始状态
  assert(bus.start == false);
  assert(bus.arrive == false);
  assert(bus.finish == false);
  std::cout << "✓ Initial state check passed" << std::endl;
  
  // 测试读操作设置
  bus.set_read(0x1000, 0x100, 3);  // 3次迭代
  assert(bus.memAddrInput == 0x1000);
  assert(bus.spadAddrInput == 0x100);
  assert(bus.total_iter == 3);
  std::cout << "✓ Read operation setup completed" << std::endl;
  
  // 第一次执行读操作
  auto result = bus.exec_once("read");
  assert(bus.cycle == 1);
  assert(bus.start == true);
  assert(bus.arrive == true);
  assert(bus.finish == false);
  assert(!result.empty());  // 应该有数据返回
  std::cout << "✓ First read execution: start=true, arrive=true, finish=false" << std::endl;
  
  // 第二次执行读操作
  bus.exec_once("read");
  assert(bus.cycle == 2);
  assert(bus.start == true);
  assert(bus.arrive == true);
  assert(bus.finish == false);
  std::cout << "✓ Second read execution: still in progress" << std::endl;
  
  // 第三次执行读操作 - 应该完成
  bus.exec_once("read");
  assert(bus.cycle == 3);
  assert(bus.start == true);
  assert(bus.arrive == true);
  assert(bus.finish == true);
  std::cout << "✓ Third read execution: finish=true" << std::endl;
  
  // 测试重置
  bus.reset();
  assert(bus.cycle == 0);
  assert(bus.start == false);
  assert(bus.arrive == false);
  assert(bus.finish == false);
  std::cout << "✓ Reset operation successful" << std::endl;
  
  // 测试写操作
  std::vector<elem_t> writeData = {1, 2, 3, 4};
  bus.set_write(0x2000, 0x200, writeData, 2);  // 2次迭代
  assert(bus.memAddrInput == 0x2000);
  assert(bus.wdataInput == writeData);
  
  // 执行写操作
  bus.exec_once("write");
  assert(bus.cycle == 1);
  assert(bus.start == true);
  assert(bus.arrive == true);
  assert(bus.finish == false);
  std::cout << "✓ Write operation first execution" << std::endl;
  
  bus.exec_once("write");
  assert(bus.cycle == 2);
  assert(bus.finish == true);
  std::cout << "✓ Write operation completed" << std::endl;
  
  std::cout << "\n=== unified_bus standalone tests passed! ===" << std::endl;
}

void test_sisyphus_with_unified_bus() {
  std::cout << "Testing sisyphus with unified_bus integration..." << std::endl;
  
  // 创建包含unified_bus的sisyphus
  sisyphus_state_t<unified_bus> memSisyphus;
  
  // 测试初始状态 - sisyphus应该反映model的状态
  assert(memSisyphus.is_start() == memSisyphus.model.start);
  assert(memSisyphus.is_arrive() == memSisyphus.model.arrive);
  assert(memSisyphus.is_finish() == memSisyphus.model.finish);
  std::cout << "✓ Sisyphus initial state sync check passed" << std::endl;
  
  // 设置读操作
  memSisyphus.model.set_read(0x3000, 0x300, 2);
  
  // 执行一次读操作
  memSisyphus.model.exec_once("read");
  assert(memSisyphus.is_start() == true);
  assert(memSisyphus.is_arrive() == true);
  assert(memSisyphus.is_finish() == false);
  std::cout << "✓ Sisyphus state reflects model state after first execution" << std::endl;
  
  // 完成操作
  memSisyphus.model.exec_once("read");
  assert(memSisyphus.is_finish() == true);
  std::cout << "✓ Sisyphus finish state synchronized" << std::endl;
  
  // 测试sisyphus的tick功能
  memSisyphus.reset();
  memSisyphus.model.set_write(0x4000, 0x400, {5, 6, 7}, 1);
  
  // 使用sisyphus的tick来执行
  memSisyphus.model.total_iter = 1;
  memSisyphus.tick();
  
  // tick应该调用model.exec_once并同步状态
  assert(memSisyphus.model.cycle > 0);
  std::cout << "✓ Sisyphus tick functionality works" << std::endl;
  
  std::cout << "\n=== sisyphus integration tests passed! ===" << std::endl;
}

int main() {
  try {
    test_unified_bus_standalone();
    test_sisyphus_with_unified_bus();
    
    std::cout << "\n🎉 All tests passed successfully! 🎉" << std::endl;
    return 0;
  } catch (const std::exception& e) {
    std::cerr << "❌ Test failed: " << e.what() << std::endl;
    return 1;
  }
}


