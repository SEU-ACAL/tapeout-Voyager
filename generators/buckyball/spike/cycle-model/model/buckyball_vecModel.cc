// #include "../include/buckyball_model.h"
// #include <stdexcept>
// #include <iostream>
// #include <assert.h>
// #include <math.h>
// #include <vector>
// #include <memory>
// #include <string>
// #include <variant>

// using namespace std;

// //===----------------------------------------------------------------------===//
// // Operation Implementations
// //===----------------------------------------------------------------------===//
// // Operation
// struct Operation {
//   virtual ~Operation() = default;
//   virtual std::vector<elem_t> execute(const std::vector<std::vector<elem_t>>& vecInputs, 
//                     elem_t scalarInput = elem_t{}) = 0;
//   virtual std::string get_name() const = 0;
// };

// // 向量加法操作
// class VectorAddOperation : public Operation {
// public:
//   std::vector<elem_t> execute(const std::vector<std::vector<elem_t>>& vecInputs, 
//                              elem_t scalarInput = elem_t{}) override {
//     if (vecInputs.size() < 2) return {};
    
//     std::vector<elem_t> result = vecInputs[0];
//     for (size_t i = 0; i < result.size() && i < vecInputs[1].size(); ++i) {
//       result[i] += vecInputs[1][i];
//     }
//     return result;
//   }
//   std::string get_name() const override { return "vector_add"; }
// };

// // 向量标量乘法操作
// class VectorScalarMulOperation : public Operation {
// public:
//   std::vector<elem_t> execute(const std::vector<std::vector<elem_t>>& vecInputs, 
//                              elem_t scalarInput = elem_t{}) override {
//     if (vecInputs.empty()) return {};
    
//     std::vector<elem_t> result = vecInputs[0];
//     for (auto& elem : result) {
//       elem *= scalarInput;
//     }
//     return result;
//   }
//   std::string get_name() const override { return "vector_scalar_mul"; }
// };

// // 向量点积操作
// class VectorDotOperation : public Operation {
// public:
//   std::vector<elem_t> execute(const std::vector<std::vector<elem_t>>& vecInputs, 
//                              elem_t scalarInput = elem_t{}) override {
//     if (vecInputs.size() < 2) return {};
    
//     elem_t dot_result = 0;
//     for (size_t i = 0; i < vecInputs[0].size() && i < vecInputs[1].size(); ++i) {
//       dot_result += vecInputs[0][i] * vecInputs[1][i];
//     }
//     return {dot_result};  // 返回单元素向量
//   }
//   std::string get_name() const override { return "vector_dot"; }
// };


// // Operation工厂
// class OperationFactory {
// public:
//   static std::unique_ptr<Operation> create(const std::string& op_name) {
//     if (op_name == "vector_add") return std::make_unique<VectorAddOperation>();
//     if (op_name == "vector_scalar_mul") return std::make_unique<VectorScalarMulOperation>();
//     if (op_name == "vector_dot") return std::make_unique<VectorDotOperation>();
//     return nullptr;
//   }
// };


// //===----------------------------------------------------------------------===//
// // unified_thread Implementation
// //===----------------------------------------------------------------------===//

// // Thread
// struct unified_thread {
//   std::vector<std::vector<elem_t>> threadInputs;
//   elem_t scalarInput;
//   std::vector<elem_t> threadOutputs;
//   std::string operation;
  
//   unified_thread(const std::vector<elem_t>& input, elem_t scalar, const std::string& op);
//   unified_thread(const std::vector<elem_t>& input1, const std::vector<elem_t>& input2, const std::string& op);
//   unified_thread() = default;
  
//   void set_operation(const std::string& op) { operation = op; }
//   std::string get_operation() const { return operation; }
  
//   std::vector<elem_t>& get_vecInput(size_t index = 0) { return threadInputs[index]; }
//   const std::vector<elem_t>& get_vecInput(size_t index = 0) const { return threadInputs[index]; }
//   void set_vecInput(const std::vector<elem_t>& value, size_t index = 0) { threadInputs[index] = value; }
  
//   elem_t get_scalarInput() const { return scalarInput; }
//   void set_scalarInput(elem_t value) { scalarInput = value; }
  
//   std::vector<elem_t>& get_vecOutput() { return threadOutputs; }
//   const std::vector<elem_t>& get_vecOutput() const { return threadOutputs; }
  
//   void exec_once() {
//     auto op = OperationFactory::create(operation);
//     if (op) {
//       threadOutputs = op->execute(threadInputs, scalarInput);
//     } else {
//       throw std::runtime_error("Null operation: " + operation);
//     }
//   }
//   void exec_once(const std::string& op_name) {
//     auto op = OperationFactory::create(op_name);
//     if (op) {
//       operation = op_name;  // 更新操作名称
//       threadOutputs = op->execute(threadInputs, scalarInput);
//     } else {
//       throw std::runtime_error("Null operation: " + op_name);
//     }
//   }
// };




// //===----------------------------------------------------------------------===//
// // warp Implementation
// //===----------------------------------------------------------------------===//
// struct threadGather {
//   bool start  = false;
//   bool arrive = false;
//   bool finish = false;


// };

// using ThreadVariant = std::variant<unified_thread>;

// struct vpipeWarp {
//   size_t current_iter = 0;

//   std::vector<ThreadVariant> threads;
  
//   vpipeWarp() = default;
  
//   void exec_once(size_t bypass) {
//     for (auto& thread : threads) {
//       std::visit([](auto& t) { 
//         t.exec_once(); 
//       }, thread);
//     }
//   }

//   threadGather threadGather;

//   bool start = threadGather.start;
//   bool arrive = threadGather.arrive;
//   bool finish = threadGather.finish;
  
//   size_t get_threadNum() const { return threads.size(); }
  
//   std::vector<ThreadVariant>& get_threads() { return threads; }
//   const std::vector<ThreadVariant>& get_threads() const { return threads; }
// };

// template<typename threadType>
// struct baseWarp {
//   size_t current_iter = 0;

//   baseWarp() = default;
//   std::vector<threadType> threads;

//   threadGather threadGather;

//   bool start = threadGather.start;
//   bool arrive = threadGather.arrive;
//   bool finish = threadGather.finish;


//   size_t get_threadNum() const { return threads.size(); }
//   std::vector<threadType>& get_threads() { return threads; }
//   const std::vector<threadType>& get_threads() const { return threads; }
  
//   void exec_once(size_t current_iter) {
//     for (auto& thread : threads) {
//       thread.exec_once();
//     }
//   }

//   void reset() {
//     current_iter = 0;
//     for (auto& thread : threads) {
//       thread.reset();
//     }
//   }

// };



// //===----------------------------------------------------------------------===//
// // warpContainer Implementation  
// //===----------------------------------------------------------------------===//

// template<typename warpType>
// struct unified_warpContainer {
//   warpType warp;
//   size_t cycle = 0;
//   size_t current_iter = 0;
//   size_t total_iter   = 0;

//   bool start  = warp.start;
//   bool arrive = warp.arrive;
//   bool finish = warp.finish;

//   warpType& get_warp() { return warp; }
//   const warpType& get_warp() const { return warp; }

//   void reset() { 
//     warp.reset();
//     cycle = 0;
//     current_iter = 0;
//     total_iter = 0;
//     start = false;
//     arrive = false;
//     finish = false;
//   }

//   void exec_once() {
//     warp.exec_once();
//     cycle++;
//     this->current_iter++;
//     warp.current_iter = this->current_iter;
//     sync_state();
//   }

//   void sync_state() {
//     if (cycle == 1) { start = true; }
//     if (cycle > 0) { arrive = true; }
//     if (cycle == total_iter) { finish = true; }
//   }
// };


// //===----------------------------------------------------------------------===//
// // Vector Model
// //===----------------------------------------------------------------------===//
