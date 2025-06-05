# 仓库开发手册

## 零、安装 mosh
针对网络波动问题（如在火车上写代码），建议使用MIT开发的mosh：https://mosh.org/

服务器端已安装mosh-server并配置，请本地机器安装mosh（以ubuntu为例）

```
$ sudo apt update
$ sudo apt install mosh
```

检查是否安装成功
```
$ mosh --version
mosh 1.4.0 [build mosh 1.4.0]
Copyright 2012 Keith Winstein <mosh-devel@mit.edu>
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

使用mosh连接服务器
```
$ mosh [UserName]@[ServerAddress]
```

效果：断线自动重连，重连后不会丢失任何正在运行的内容。


## 一、安装 anaconda

https://www.anaconda.com/download/

## 二、安装开发仓库

```shell
$ git clone https://github.com/SEU-ACAL/tapeout-Voyager.git
$ git checkout dev

$ ./build-setup.sh
```

## 三、Voyager Test

`voyager-test` 文件夹用于存放workload和执行的测试框架.
现有workload list 如下
- cpu
    - hello
    - spmm
- npu 
    - native
        - baremetal
        - imagenet
        - mlps
        - transformers
    - buddy
        - spmm
- tutorial (voyager-test tutorial)

**3.1 编译workload**

编译所有workload
```shell
$ cd Voyager/voyager-test/build
$ make build-all
```

如果只需单独编译部分workload
```shell
$ cd Voyager/voyager-test/build
$ make cpu-build
$ make npu-build
```

添加自定义workload请参考教程: [voyager-test tutorial](./voyager-test/README.md)


## 四、Spike

可以通过以下几个测试用例，测试Spike可以正常使用

```shell
$ cd Voyager
$ ./voyager-test/scripts/run-spike.sh hello 
$ ./voyager-test/scripts/run-spike.sh --pk cpu-spmm
$ ./voyager-test/scripts/run-spike.sh matmul_os

# 使用buckyballFunc扩展运行bb_mvin_mvout
$ ./voyager-test/scripts/run-spike.sh --ext=buckyballFunc bb_mvin_mvout
```


## 五、Verilator

**5.1 Build RTL**

可以通过以下几个测试用例，测试Verilator RTL的正确性

```shell
$ cd Voyager
$ ./voyager-test/scripts/build-verilator.sh --config RocketConfig # Build 单独Rocket
$ ./voyager-test/scripts/build-verilator.sh --config GemminiRocketConfig # Build 单独Gemmini
$ ./voyager-test/scripts/build-verilator.sh --config OurHeterSoCConfig --debug # Build 六核版, 并开启调试
```

Verilator编译出的可执行文件会被自动拷贝到 `voyager-test/output/verilator` 路径下

**5.2 测试运行workload**

可以通过下面测试用例，测试Verilator build的正确性

```shell
# 运行voyager-test/output/workloads/cpu/hello-baremetal
$ ./voyager-test/scripts/run-verilator.sh --config RocketConfig hello 

# 运行voyager-test/output/workloads/npu/native/vector-baremetal
$ ./voyager-test/scripts/run-verilator.sh --config GemminiRocketConfig vector 

# 对开启的调试的build文件可以同时输出波形
$ ./voyager-test/scripts/run-verilator.sh --config RocketConfig hello --debug 

# 使用--vcd2fst参数，可以生成压缩后的FST波形
$ ./voyager-test/scripts/run-verilator.sh --config RocketConfig hello --debug --vcd2fst
```

**5.3 批测试**

批量测试脚本，通过添加测试的配置和workload，可以批量测试所有配置和workload；每个RTL配置会和所有workload进行组合测试。

```shell
$ ./voyager-test/scripts/batch-test.sh --npu-test # 运行NPU相关测试
$ ./voyager-test/scripts/batch-test.sh --meek-test # 运行Meek相关测试
$ ./voyager-test/scripts/batch-test.sh --full-test # 运行所有测试配置
```

## 六、VCS

**6.1 Build RTL**

可以通过以下几个测试用例，测试Verilator RTL的正确性

```shell
$ cd Voyager
$ ./voyager-test/scripts/build-vcs.sh --config RocketConfig 
$ ./voyager-test/scripts/build-vcs.sh --config GemminiRocketConfig 
$ ./voyager-test/scripts/build-vcs.sh --config OurHeterSoCConfig --debug 
```

VCS编译出的可执行文件会被自动拷贝到 `voyager-test/output/vcs` 路径下

**6.2 测试运行workload**

可以通过下面测试用例，测试VCS build的正确性，操作与Verilator基本类似

```shell
$ ./voyager-test/scripts/run-vcs.sh --config RocketConfig hello 
$ ./voyager-test/scripts/run-vcs.sh --config GemminiRocketConfig vector 
$ ./voyager-test/scripts/run-vcs.sh --config RocketConfig hello --debug 
```
**6.3 Verdi**

服务器上看波形很卡，建议本地装个verdi看

```shell
$ source ./voyager-test/scripts/env-source.sh vcs
$ verdi
```

## 七、firesim

firesim 由`./build-setup.sh`已经安装好, 参考[教程](docs/firesim-README.md)运行(求补充)

## 八、后端 (DC)

使用`run-dc.sh`脚本会先使用verilator自动生成对应版本的Config，之后进行DC综合. 报告和网表文件将生成在 `./voyager-test/output/dc/reports` 路径下.
DC所用到的db_file存放在`/opt/dc/lib/TSMCHOME`路径下.
```shell
# 不指定--top会使用默认的ChipTop综合所有模块
$ ./voyager-test/scripts/run-dc.sh --config RocketConfig
# 使用指定top综合局部模块
$ ./voyager-test/scripts/run-dc.sh --config GemminiRocketConfig --top RocketTile
```

注：vcs和dc版本不同，所以环境变量也不同，单独使用需要使用脚本切换。
```shell
$ source ./voyager-test/scripts/env-source.sh vcs
$ source ./voyager-test/scripts/env-source.sh dc
```
如果由于 license 问题导致脚本切换失败，可使用`lmdown`和 `lmli` 手动切换
如果直接使用 `build-vcs.sh`, `run-vcs.sh` 和 `run-dc.sh` 会自动切换，无需手动切换。

## 九、CI

**9.1 pre-commit (提交前检查)**

pre-commit 由`./build-setup.sh`已经安装好，无需单独安装。
Commit代码前，请打开 `scripts/permission-check.sh` 找到`allowed_dirs`，将你需要修改的文件夹路径取消注释。
通过这种方式我们防止提交文件夹污染，只有位于这几个文件夹的文件修改允许提交。

**9.2 可提交物说明**

Voyager 仓库下只有 `generator`部分文件夹, `voyager-test`, `docs` 和 `scripts` 四个文件夹可提交，其余全部.gitignore

`generator` 文件夹下存放RTL design.
`generator`下可修改的目录如下:
- chipyard/src: 存放顶层TopConfig
- boom/src
- rocket-chip/src
- gemmini/src
- bar-fetchers/src: 存放预取器代码


**9.3 专用测试**

为了尽可能增大CI的覆盖范围，可以通过在commit message中包含特定的tag，来触发特定的测试；测试用例在batch-test.sh中自行添加即可。

- [npu-test] 触发NPU相关测试。
- [meek-test] 触发Meek相关测试。
- [full-test] 触发除DC外的所有测试。
- [dc-eval] 触发DC综合。

## 十、文档目录

其余具体可见`docs`下的文档，欢迎大家多写文档，记录下用法和一些坑.

- [[Q&A List](docs/Q&A.md)] 仓库使用遇到问题可以在群里询问，问题解决后将解决方法记录在这里.    
- [[firesim](docs/firesim-README.md)] firesim 的简略文档，求补充.  
- [[NPU-README](docs/NPU-README.md)] 主要关于buddy-mlir的使用.
- [[sram_README](docs/sram_readme.md)] 主要关于sram替换的文档. 
