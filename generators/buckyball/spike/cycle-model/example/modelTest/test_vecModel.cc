#include "../../include/buckyball_frame.h"
#include "../../include/buckyball_model.h"
#include "../../model/buckyball_vecModel.cc"
#include <iostream>
#include <cassert>

void test_vector_add() {
  std::cout << "Testing vector addition..." << std::endl;
  
  // 创建thread with两个输入向量
  std::vector<elem_t> input1 = {1, 2, 3};
  std::vector<elem_t> input2 = {4, 5, 6};
  unified_thread thread(input1, input2, "vector_add");
  
  // 执行操作
  thread.exec_once();
  
  // 验证结果
  auto result = thread.get_vecOutput();
  std::vector<elem_t> expected = {5, 7, 9};
  
  assert(result.size() == expected.size());
  for (size_t i = 0; i < result.size(); ++i) {
    assert(result[i] == expected[i]);
  }
  
  std::cout << "Vector addition test passed! Result: ";
  for (auto val : result) std::cout << (int)val << " ";
  std::cout << std::endl;
}

void test_vector_scalar_mul() {
  std::cout << "Testing vector scalar multiplication..." << std::endl;
  
  // 创建thread with单个输入向量和标量
  std::vector<elem_t> input = {2, 4, 6};
  elem_t scalar = 3;
  unified_thread thread(input, scalar, "vector_scalar_mul");
  
  // 执行操作
  thread.exec_once();
  
  // 验证结果
  auto result = thread.get_vecOutput();
  std::vector<elem_t> expected = {6, 12, 18};
  
  assert(result.size() == expected.size());
  for (size_t i = 0; i < result.size(); ++i) {
    assert(result[i] == expected[i]);
  }
  
  std::cout << "Vector scalar multiplication test passed! Result: ";
  for (auto val : result) std::cout << (int)val << " ";
  std::cout << std::endl;
}

void test_vector_dot() {
  std::cout << "Testing vector dot product..." << std::endl;
  
  // 创建thread with两个输入向量
  std::vector<elem_t> input1 = {1, 2, 3};
  std::vector<elem_t> input2 = {4, 5, 6};
  unified_thread thread(input1, input2, "vector_dot");
  
  // 执行操作
  thread.exec_once();
  
  // 验证结果 (1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32)
  auto result = thread.get_vecOutput();
  assert(result.size() == 1);
  assert(result[0] == 32);
  
  std::cout << "Vector dot product test passed! Result: " << (int)result[0] << std::endl;
}

void test_warp_container() {
  std::cout << "Testing warp container..." << std::endl;
  
  // 创建warp容器
  warpContainer container;
  
  // 创建不同操作的threads
  unified_thread thread1({1, 2}, {3, 4}, "vector_add");
  unified_thread thread2({2, 4}, 2, "vector_scalar_mul");
  
  // 创建warp并添加threads
  unified_warp warp1;
  warp1.get_threads().push_back(thread1);
  warp1.get_threads().push_back(thread2);
  
  container.add_warp(warp1);
  
  // 执行所有threads的操作
  for (auto& warp : container.get_warps()) {
    for (auto& thread : warp.get_threads()) {
      thread.exec_once();
      std::cout << "Operation: " << thread.get_operation() << ", Result: ";
      for (auto val : thread.get_vecOutput()) std::cout << (int)val << " ";
      std::cout << std::endl;
    }
  }
  
  // 按操作类型筛选
  auto add_warps = container.get_warps_by_operation("vector_add");
  std::cout << "Found " << add_warps.size() << " warps with vector_add operation" << std::endl;
  
  std::cout << "Warp container test passed!" << std::endl;
}

void test_operation_change() {
  std::cout << "Testing operation change..." << std::endl;
  
  // 创建thread
  unified_thread thread({1, 2, 3}, {2, 3, 4}, "vector_add");
  
  // 执行加法
  thread.exec_once();
  auto add_result = thread.get_vecOutput();
  std::cout << "Add result: ";
  for (auto val : add_result) std::cout << (int)val << " ";
  std::cout << std::endl;
  
  // 改变操作为点积
  thread.exec_once("vector_dot");
  auto dot_result = thread.get_vecOutput();
  std::cout << "Dot result: " << (int)dot_result[0] << std::endl;
  
  assert(thread.get_operation() == "vector_dot");
  std::cout << "Operation change test passed!" << std::endl;
}

int main() {
  std::cout << "=== BuckyBall Vector Model Test ===" << std::endl;
  
  try {
    test_vector_add();
    test_vector_scalar_mul();
    test_vector_dot();
    test_warp_container();
    test_operation_change();
    
    std::cout << "\n=== All tests passed! ===" << std::endl;
  } catch (const std::exception& e) {
    std::cerr << "Test failed: " << e.what() << std::endl;
    return 1;
  }
  
  return 0;
} 