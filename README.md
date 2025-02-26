# 仓库开发手册

## 零、安装 mosh ##
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
mosh [UserName]@[ServerAddress]
```

效果：断线自动重连，重连后不会丢失任何正在运行的内容。


## 一、安装 anaconda

https://www.anaconda.com/download/

创建一个 conda 环境，并且需要其中安装 conda-lock==1.4.0，并检查：

```
conda-lock --version
```

## 二、安装 开发仓库

```
mkdir Voyager && cd Voyager 
git clone https://github.com/SEU-ACAL/tapeout-Voyager.git .
# git checkout 0.0.1 # 等第一版六核版更新后启用该版本

./build-setup.sh
```
注：`./build-setup.sh` 脚本自动安装firesim并不稳定，现已移除，直接手动安装吧
```
cd Voyager/../
git clone https://github.com/firesim/firesim.git
cd firesim
git checkout 1.17.1
./build-setup.sh
```

### 可提交物：

Voyager 仓库下只有 `generator`部分文件夹, `software`, `scripts` 和 `doc` 四个文件夹可提交，其余全部.gitignore

#### `generator` 文件夹下存放RTL design.
`generator`下可修改的目录如下:
- chipyard/src: 存放顶层TopConfig
- firechip/src: 存放firesim的调试config
- boom/src
- rocket-chip/src
- gemmini/src

#### `software` 文件夹用于存放各个方向的workload和执行的脚本.
现有workload：
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
        - BuddyLeNet
        - GemminiDialect


一键编译workload

```
source env.sh
cd Voyager/software
mkdir build && cd build 
cmake ..

# 编译所有workload
make all-bin
```

### 测试用例
#### RTL Build 测试
```
cd Voyager
# Build 六核版
./software/scripts/build-verilator.sh --config OurHeterSoCConfig
# Build 单独Rocket
./software/scripts/build-verilator.sh --config RocketConfig
# Build 单独Gemmini
./software/scripts/build-verilator.sh --config CustomGemminiSoCConfig
```

#### 运行 workload  
编译 barematal 的 workload
<!-- ```
cd Voyager/software/build
make baremetal
``` -->

#### 运行 firesim


## 三、安装 pre-commit
```
cd Voyager 
pip install pre-commit
pre-commit install
```

---

## 四、其他工具

理想情况下工作目录应该如下
```
- workspace
    - Voyager
    - firesim
    - buddy-mlir (only npu need)
```

具体见`documents`下的文档。

NPU相关事项（如一核gemmini调试配置，BuddyCompiler安装指南等）可见`documents/NPU-README.md`
