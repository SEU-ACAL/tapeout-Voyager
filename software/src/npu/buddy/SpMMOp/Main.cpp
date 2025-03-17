//===- Main.cpp -----------------------------------------------------------===//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//===----------------------------------------------------------------------===//
//
// This is the main file of Gemmini MatMul operation benchmark.
//
//===----------------------------------------------------------------------===//

#include "gemmini.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>

#include "Gemmini/Utils.h"
#include <buddy/Core/Container.h>

using namespace buddy::benchmark;

// -----------------------------------------------------------------------------
// Benchmark Configuration. You can change the number here as needed.
// -----------------------------------------------------------------------------

#define _SIZE_M 128
#define _SIZE_N 128
#define _SIZE_K 128
#define _BIAS 0
static float c_scale[1] = {1.0f};

// -----------------------------------------------------------------------------
// Include Kernel Functions.
// -----------------------------------------------------------------------------

extern "C" {
void _mlir_ciface_gemmini_matrix_matmul(MemRef<int8_t, 2> *input0,
                                        MemRef<int8_t, 2> *input1,
                                        MemRef<int8_t, 2> *output,
                                        MemRef<int32_t, 2> *inputBias);

void _mlir_ciface_gemmini_vector_matmul(MemRef<int8_t, 2> *input0,
                                        MemRef<int8_t, 2> *input1,
                                        MemRef<int8_t, 2> *output,
                                        MemRef<int32_t, 2> *inputBias);
                                        

// void _mlir_ciface_gemmini_sparse_dense_matmul(MemRef<int8_t, 2> *val,
//                                               MemRef<int8_t, 2> *colIdc,
//                                               MemRef<int8_t, 2> *rowPtr,
//                                               MemRef<int8_t, 2> *numRows,
//                                               MemRef<int8_t, 2> *numCols,
//                                               MemRef<int8_t, 2> *denseMatrix,
//                                               MemRef<int8_t, 2> *output,
//                                               MemRef<int32_t, 2> *bias);
}

// -----------------------------------------------------------------------------
// Global Variables.
// -----------------------------------------------------------------------------

static int8_t inputA[_SIZE_M * _SIZE_K] row_align(1);
static int8_t inputB[_SIZE_K * _SIZE_N] row_align(1);
static int32_t inputBias[_SIZE_M * _SIZE_N] row_align(1);
intptr_t sizesA[2] = {_SIZE_M, _SIZE_K};
intptr_t sizesB[2] = {_SIZE_K, _SIZE_N};
intptr_t sizesOutput[2] = {_SIZE_M, _SIZE_N};
intptr_t sizesBias[2] = {_SIZE_M, _SIZE_N};
MemRef<int8_t, 2> inputAMemRef(sizesA);
MemRef<int8_t, 2> inputBMemRef(sizesB);

// -----------------------------------------------------------------------------
// Benchmark Functions. The kernel functions are called here.
// -----------------------------------------------------------------------------

// Gemmini native matmul function.
// This function is used to get the expected output results for verification.
void MatrixDenseMatmul(int8_t *inputA, int8_t *inputB, int8_t *outputC,
                  int32_t *inputBias, const std::string &name)  {

  uint64_t start = gemmini::readCycles();
  tiled_matmul_auto(_SIZE_M, _SIZE_N, _SIZE_K, inputA, inputB, inputBias,
                    outputC, _SIZE_K, _SIZE_N, _SIZE_N, _SIZE_N,
                    MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY,
                    MVIN_SCALE_IDENTITY, NO_ACTIVATION, ACC_SCALE_IDENTITY, 0,
                    false, false, false, false, false, 0, WS);
  uint64_t end = gemmini::readCycles();
  std::cout << name << " cycles: " << end - start << std::endl;
  // gemmini::printArrayInt8(outputC, _SIZE_M, _SIZE_N);
}

// Buddy Gemmini dialect matmul benchmark function.
// Verifies the result against expected output.
using MLIRFunctionType = void (*)(MemRef<int8_t, 2> *, MemRef<int8_t, 2> *,
                                  MemRef<int8_t, 2> *, MemRef<int32_t, 2> *);
void VectorDenseMatmul(int8_t *outputExpected, MLIRFunctionType MLIRFunc,
                 const std::string &name) {
  
  int8_t output[_SIZE_M * _SIZE_N] row_align(1) = {0} ;
  MemRef<int8_t, 2> outputMemRef(sizesOutput, 0);
  outputMemRef = MemRef<int8_t, 2>(output, sizesOutput);
  MemRef<int32_t, 2> inputBiasMemRef(sizesBias, _BIAS);
  inputBiasMemRef = MemRef<int32_t, 2>(inputBias, sizesBias);
  
  uint64_t start = gemmini::readCycles();
  MLIRFunc(&inputAMemRef, &inputBMemRef, &outputMemRef, &inputBiasMemRef);
  uint64_t end = gemmini::readCycles();
  
  std::cout << name << " cycles: " << end - start << std::endl;
  int8_t *outputOptimized = outputMemRef.getData();

  gemmini::verify<int8_t>(outputExpected, outputOptimized, _SIZE_M, _SIZE_N,
                          name);
}

// -----------------------------------------------------------------------------
// Main Function.
// -----------------------------------------------------------------------------

int main() {
  // Initialize input data.


  // inputAMemRef = MemRef<int8_t, 2>(inputA, sizesA);
  // inputBMemRef = MemRef<int8_t, 2>(inputB, sizesB);

  std::cout << "\033[34m---------- Verification ----------\033[0m" << std::endl;

  int8_t outputExpected[_SIZE_M * _SIZE_N] row_align(1) = {0} ;

  MatrixDenseMatmul(inputA, inputB, outputExpected, inputBias, 
                    "Matrix Dense MatMul");

  VectorDenseMatmul(outputExpected, _mlir_ciface_gemmini_vector_matmul,
                    "Vector Dense MatMul");

  return 0;
}
