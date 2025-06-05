#include "../include/buckyball_frame.h"
#include <stdexcept>
#include <iostream>
#include <assert.h>
#include <math.h>

using namespace std;

// 基于邻接矩阵的流水线管理器
template<typename SisyphusType>
class pipeline {
private:
  std::vector<SisyphusType*> sisyphus_units;
  std::vector<std::vector<bool>> adjacency_matrix; // 邻接矩阵：matrix[i][j] = true表示i->j有连接
  std::vector<std::vector<bool>> data_ready_matrix; // 数据准备状态矩阵
  std::vector<int> in_degree;  // 入度：前驱数量
  std::vector<int> out_degree; // 出度：后继数量
  size_t sisyphusNum;

  bool start;
  bool arrive;
  bool finish;

public:

  // 添加sisyphus单元
  void add_sisyphus(SisyphusType* sisyphus, int sid) {
    if (sid >= sisyphusNum) {
      sisyphusNum = sid + 1;
    }
    sisyphus_units.resize(sisyphusNum, nullptr);
    sisyphus_units[sid] = sisyphus;
    sisyphus->set_sid(sid);
  }
  
  // 添加流水线连接
  void add_connection(int from_sid, int to_sid) {
    if (from_sid >= sisyphusNum || to_sid >= sisyphusNum) return;
    
    if (!adjacency_matrix[from_sid][to_sid]) {
      adjacency_matrix[from_sid][to_sid] = true;
      out_degree[from_sid]++;
      in_degree[to_sid]++;
    }
  }
  
  // 移除连接
  void remove_connection(int from_sid, int to_sid) {
    if (from_sid >= sisyphusNum || to_sid >= sisyphusNum) return;
    
    if (adjacency_matrix[from_sid][to_sid]) {
      adjacency_matrix[from_sid][to_sid] = false;
      data_ready_matrix[from_sid][to_sid] = false;
      out_degree[from_sid]--;
      in_degree[to_sid]--;
    }
  }
  
  // 启动流水线（从入度为0的sisyphus开始）
  void start_pipeline() {
    for (int i = 0; i < sisyphusNum; i++) {
      if (sisyphus_units[i] && in_degree[i] == 0) {
        sisyphus_units[i]->set_start();
        printf("Pipeline started from sisyphus_%d\n", i);
      }
    }
  }
  
  // 流水线时钟周期
  void tick() {
    // 1. 所有sisyphus执行tick
    for (auto* sisyphus : sisyphus_units) {
      if (sisyphus) {
        sisyphus->tick();
      }
    }
    
    // 2. 检查流水线传递条件
    pipeline_handshake();
  }
  
  // 检查流水线传递
  void pipeline_handshake() {
    for (int i = 0; i < sisyphusNum; i++) {
      if (!sisyphus_units[i]) continue;
      
      // 当sisyphus i arrive时，检查所有后继是否可以启动
      if (sisyphus_units[i]->is_arrive()) {
        for (int j = 0; j < sisyphusNum; j++) {
          if (adjacency_matrix[i][j] && sisyphus_units[j] && !sisyphus_units[j]->is_start()) {
            // 检查sisyphus j是否有两个输入都准备好了
            if (check_dual_inputs_ready(j)) {
              // 找到两个输入sisyphus并传递数据
              auto inputs = get_input_sisyphus(j);
              if (inputs.size() == 2) {
                transfer_data(sisyphus_units[inputs[0]], sisyphus_units[inputs[1]], sisyphus_units[j]);
                sisyphus_units[j]->set_start();
                data_ready_matrix[i][j] = true;
                printf("Pipeline propagation: sisyphus_%d + sisyphus_%d -> sisyphus_%d\n", 
                       inputs[0], inputs[1], j);
              }
            }
          }
        }
      }
      
      // 当sisyphus i finish时，通知所有前驱可以arrive（数据已被消费）
      if (sisyphus_units[i]->is_finish()) {
        for (int j = 0; j < sisyphusNum; j++) {
          if (adjacency_matrix[j][i] && sisyphus_units[j] && 
              sisyphus_units[j]->is_start() && !sisyphus_units[j]->is_arrive()) {
            sisyphus_units[j]->set_arrive();
            printf("sisyphus_%d arrived (triggered by sisyphus_%d finish)\n", j, i);
          }
        }
      }
    }
  }
  
  // 数据传递
  void transfer_data(SisyphusType* from1, SisyphusType* from2, SisyphusType* to) {
    if (from1) {
      to->model.vecInput1 = from1->model.vecOutput;
      to->model.scalInput1 = from1->model.scalarOutput;
    }
    if (from2) {
      to->model.vecInput2 = from2->model.vecOutput;
    }
  }
  
  // 检查流水线是否完成
  bool is_pipeline_finished() {
    // 检查所有出度为0的sisyphus（最后一级）是否都完成
    for (int i = 0; i < sisyphusNum; i++) {
      if (sisyphus_units[i] && out_degree[i] == 0) {
        if (!sisyphus_units[i].is_finish) {
          return false;
        }
      }
    }
    return true;
  }
  
  // 重置流水线
  void reset_pipeline() {
    for (auto* sisyphus : sisyphus_units) {
      if (sisyphus) {
        sisyphus->reset();
      }
    }
    
    // 重置数据准备状态
    for (int i = 0; i < sisyphusNum; i++) {
      for (int j = 0; j < sisyphusNum; j++) {
        data_ready_matrix[i][j] = false;
      }
    }
  }
  
  // 打印邻接矩阵
  void print_adjacency_matrix() {
    printf("=== Adjacency Matrix ===\n");
    printf("   ");
    for (int j = 0; j < sisyphusNum; j++) {
      printf("%2d ", j);
    }
    printf("\n");
    
    for (int i = 0; i < sisyphusNum; i++) {
      printf("%2d ", i);
      for (int j = 0; j < sisyphusNum; j++) {
        printf(" %d ", adjacency_matrix[i][j] ? 1 : 0);
      }
      printf("| out:%d\n", out_degree[i]);
    }
    
    printf("   ");
    for (int j = 0; j < sisyphusNum; j++) {
      printf("---");
    }
    printf("\n   ");
    for (int j = 0; j < sisyphusNum; j++) {
      printf("in:%d ", in_degree[j]);
    }
    printf("\n========================\n");
  }
  
  // 获取流水线状态
  void print_pipeline_status() {
    printf("=== Pipeline Status ===\n");
    for (int i = 0; i < sisyphusNum; i++) {
      if (sisyphus_units[i]) {
        printf("%s\n", sisyphus_units[i]->get_status().c_str());
      }
    }
    
    printf("=== Data Ready Matrix ===\n");
    for (int i = 0; i < sisyphusNum; i++) {
      for (int j = 0; j < sisyphusNum; j++) {
        if (adjacency_matrix[i][j]) {
          printf("sisyphus_%d -> sisyphus_%d [%s]\n", 
                 i, j, data_ready_matrix[i][j] ? "READY" : "WAITING");
        }
      }
    }
    printf("=====================\n");
  }
  
  // 获取特定sisyphus
  SisyphusType* get_sisyphus(int sid) {
    if (sid < sisyphusNum) {
      return sisyphus_units[sid];
    }
    return nullptr;
  }
  
  // 获取入度
  int get_in_degree(int sid) const {
    return (sid < sisyphusNum) ? in_degree[sid] : -1;
  }
  
  // 获取出度
  int get_out_degree(int sid) const {
    return (sid < sisyphusNum) ? out_degree[sid] : -1;
  }
  
  // 检查连接
  bool is_connected(int from_sid, int to_sid) const {
    if (from_sid >= sisyphusNum || to_sid >= sisyphusNum) return false;
    return adjacency_matrix[from_sid][to_sid];
  }
  
  // 检查sisyphus的两个输入是否都准备好了
  bool check_dual_inputs_ready(int sid) const {
    if (sid >= sisyphusNum) return false;
    
    // 对于入度为0的sisyphus（初始节点），直接返回true
    if (in_degree[sid] == 0) return true;
    
    // 对于入度为1的sisyphus，只需要一个输入
    if (in_degree[sid] == 1) {
      for (int i = 0; i < sisyphusNum; i++) {
        if (adjacency_matrix[i][sid] && sisyphus_units[i] && sisyphus_units[i]->is_arrive()) {
          return true;
        }
      }
      return false;
    }
    
    // 对于入度为2的sisyphus，需要两个输入都arrive
    int ready_count = 0;
    for (int i = 0; i < sisyphusNum; i++) {
      if (adjacency_matrix[i][sid] && sisyphus_units[i] && sisyphus_units[i]->is_arrive()) {
        ready_count++;
      }
    }
    return ready_count >= 2;
  }
  
  // 获取sisyphus的输入sisyphus列表
  std::vector<int> get_input_sisyphus(int sid) const {
    std::vector<int> inputs;
    if (sid >= sisyphusNum) return inputs;
    
    for (int i = 0; i < sisyphusNum; i++) {
      if (adjacency_matrix[i][sid] && sisyphus_units[i]) {
        inputs.push_back(i);
      }
    }
    return inputs;
  }
};