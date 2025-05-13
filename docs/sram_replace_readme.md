# 内存模型转换工具

这个Python脚本用于将Chipyard生成的内存模型转换为目标SRAM格式。该工具根据JSON配置文件中的内存规格，将Verilog中的内存模型转换为目标格式，使其可以使用标准SRAM宏单元进行实现。

## 功能特点

- 根据JSON配置文件解析内存规格
- 自动识别不同类型的内存模型(RW, R/W分离端口)
- 生成适合目标SRAM宏的Verilog代码
- 自动选择合适的SRAM尺寸和数量
- 处理多个宏单元组合成更大的内存模型
- 支持智能匹配工艺库中可用的SRAM尺寸
- 可自定义输出文件路径

## 使用方法

```bash
python sram-replace.py <seq_mems.json文件路径> <mems.v文件路径> [-o 输出文件路径] [-d DC脚本路径]
```

### 参数说明

- `seq_mems.json文件路径`: 包含内存规格信息的JSON文件路径
- `mems.v文件路径`: 原始Verilog内存模型文件路径
- `-o, --output`: 输出Verilog文件路径（默认: converted_mems.v）
- `-d, --dc_script`: 包含SRAM库信息的DC脚本路径（可选）

### 示例

```bash
# 基本用法
python sram-replace.py voyager-test/output/dc/design/gen-collateral/metadata/seq_mems.json sims/verilator/generated-src/chipyard.harness.TestHarness.GemminiRocketConfig/gen-collateral/chipyard.harness.TestHarness.GemminiRocketConfig.top.mems.v

# 指定输出文件
python sram-replace.py voyager-test/output/dc/design/gen-collateral/metadata/seq_mems.json sims/verilator/generated-src/chipyard.harness.TestHarness.GemminiRocketConfig/gen-collateral/chipyard.harness.TestHarness.GemminiRocketConfig.top.mems.v -o output/converted_top_mems.v

# 指定DC脚本（用于获取可用SRAM尺寸）
python sram-replace.py voyager-test/output/dc/design/gen-collateral/metadata/seq_mems.json input.v -d voyager-test/scripts/dc_script.tcl
```

## 输出

脚本运行后，将在指定的输出路径生成转换后的Verilog文件，其中包含使用工艺库SRAM实现的内存模型。

### 输出示例

```verilog
// Auto-generated SRAM macro file
// Generated from: chipyard.harness.TestHarness.GemminiRocketConfig.top.mems.v
// Using memory specs from: seq_mems.json

module cc_dir_ext(
  input [9:0] RW0_addr,
  input  RW0_clk,
  input [135:0] RW0_wdata,
  output [135:0] RW0_rdata,
  input  RW0_en,
  input  RW0_wmode,
  input [7:0] RW0_wmask
);

    wire [9:0] addr = RW0_addr;

    wire CE = ~RW0_en;
    wire WEB = ~RW0_wmode;
    wire OEB = RW0_wmode;

    wire [255:0] O;
    wire [255:0] I;

    assign I = {120'b0, RW0_wdata};

    TEM5N28HPCPLVTA1024x256M4SWBSO sram_inst (
        .A(addr),
        .CE(CE),
        .WEB(WEB),
        .OEB(OEB),
        .CSB(1'b0),
        .I(I),
        .O(O)
    );

    assign RW0_rdata = O[135:0];

endmodule
```

### SRAM选择算法

脚本会智能地选择最合适的SRAM宏单元:

1. 从DC脚本中提取可用的SRAM尺寸列表
2. 对于每个内存模块，根据其宽度和深度，找到资源浪费最小的SRAM宏
3. 如果需要多个SRAM宏组合成一个大的内存，生成适当的地址解码逻辑
4. 如果无法找到合适的SRAM宏，则使用默认尺寸

## 支持的SRAM类型

本工具支持TSMC 28nm工艺库中的SRAM宏，格式为`TEM5N28HPCPLVTAxxxxyyyM4SWBSO`，其中:
- xxxx: SRAM深度
- yyy: SRAM宽度

脚本能够识别如下形式的SRAM宏:
```
TEM5N28HPCPLVTA1024x128M4SWBSO
TEM5N28HPCPLVTA1024x64M4SWBSO 
TEM5N28HPCPLVTA256x128M4SWBSO
TEM5N28HPCPLVTA64x128M4SWBSO
```

## 转换规则

1. 对于RW型内存(读写端口合并):
   - 将转换为使用CE, WEB, OEB等控制信号的SRAM宏
   - 支持地址选择逻辑自动生成
   - 自动处理位宽不匹配的情况

2. 对于R/W分离型内存:
   - 将转换为共享地址总线的SRAM宏
   - 处理读写端口间的冲突逻辑
   - 生成适当的多路复用器逻辑

## 集成到设计流程

脚本可以轻松集成到设计流程中，例如在`run-dc.sh`脚本中：

```bash
# 替换顶层SRAM
python ${CYDIR}/voyager-test/scripts/sram-replace.py $JSON_FILE $TOP_MEMS_V -o $DESIGN_DIR/gen-collateral/chipyard.harness.TestHarness.${CONFIG}.top.srams.v

# 替换模型SRAM
python ${CYDIR}/voyager-test/scripts/sram-replace.py $JSON_FILE $MODEL_MEMS_V -o $DESIGN_DIR/gen-collateral/chipyard.harness.TestHarness.${CONFIG}.model.srams.v
``` 