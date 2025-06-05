#include "../include/buckyball_model.h"
#include <riscv/mmu.h>
#include <riscv/trap.h>
#include <stdexcept>
#include <iostream>
#include <assert.h>
#include <math.h>

using namespace std;


// struct matrix_model : public baseModel<std::vector<std::vector<elem_t>>> {
//   size_t rows;
//   size_t cols;
  
//   matrix_model() : rows(0), cols(0) {}
//   matrix_model(size_t r, size_t c) : rows(r), cols(c) {
//     data.resize(r, std::vector<elem_t>(c));
//   }
  
//   // Convenience accessors
//   std::vector<std::vector<elem_t>>& get_matrix() { return data; }
//   const std::vector<std::vector<elem_t>>& get_matrix() const { return data; }
  
//   // Matrix-specific operations
//   elem_t& operator()(size_t row, size_t col) {
//     return data[row][col];
//   }
  
//   const elem_t& operator()(size_t row, size_t col) const {
//     return data[row][col];
//   }
  
//   void resize(size_t r, size_t c) {
//     rows = r;
//     cols = c;
//     data.resize(r, std::vector<elem_t>(c));
//   }
// };
