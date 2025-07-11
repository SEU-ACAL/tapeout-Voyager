## Voyager SOC
 
本目录下包含Voyager SOC集成测试的所有流程及工具


### 1. 流片代码生成

1.1 代码生成
```bash
# verilator仿真代码
./voyager-test/scripts/build-verilator.sh --config VoyagerVerilatorConfig --project voyager_tapeout --sub-project voyager_tapeout
```


### 2. SRAM 替换

2.1 生成SRAM配置

2.2 从厂商拿到对应SRAM配置的verilog文件和lib文件

2.3 verliog代码替换SRAM模型
