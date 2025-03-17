func.func @gemmini_matrix_matmul(%inputA : memref<128x128xi8>, 
                                 %inputB : memref<128x128xi8>, 
                                 %output : memref<128x128xi8>, 
                                 %inputBias : memref<128x128xi32>) {
  gemmini.tile_matmul %inputA %inputB %output %inputBias: memref<128x128xi8> 
    memref<128x128xi8> memref<128x128xi8> memref<128x128xi32>
  return
}

func.func @gemmini_vector_matmul(%inputA : memref<128x128xi8>, 
                                 %inputB : memref<128x128xi8>, 
                                 %output : memref<128x128xi8>, 
                                 %inputBias : memref<128x128xi32>) {
  gemmini.tile_vector_matmul %inputA %inputB %output %inputBias: memref<128x128xi8> 
    memref<128x128xi8> memref<128x128xi8> memref<128x128xi32>
  return
}

// func.func @gemmini_sparse_dense_matmul(%val : memref<?xi8>,              
//                                        %colIdc : memref<?xi8>,        
//                                        %rowPtr : memref<?xi8>,        
//                                        %numRows : index,                    
//                                        %numCols : index,                    
//                                        %denseMatrix : memref<128x128xi8>,
//                                        %output : memref<128x128xi8>,
//                                        %bias : memref<128x128xi32>) {
  
//   gemmini.tile_vector_spmm_csr %val %colIdc %rowPtr %numRows %numCols 
//     %denseMatrix %output %bias : memref<?xi8> memref<?xi8> memref<?xi8> 
//     index index memref<128x128xi8> memref<128x128xi8> memref<128x128xi32>
//   return
// }
