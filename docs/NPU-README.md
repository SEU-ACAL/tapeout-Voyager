# NPU 方向开发指南




## E2E buddy-mlir for gemmini
https://github.com/shirohasuki/buddy-examples/blob/main/BuddyGemmini/README.md

## Gemmini rocket
由于gemmini里的rocc都换成了新的roccnpu，所以在配置gemmini的时候，对应的rocket核也要配成rocketnpu，目前RoCCAcceleratorConfigs下的几个配置都改过来了，后面大家有一些其他关于gemmini配置的话记得改一下rocket的配置

## BuckyBall Dialect
目前支持算子：
- linalg.matmul 
- linalg.batchmatmul 
