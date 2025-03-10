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

创建一个 conda 环境，并且需要其中安装 conda-lock==1.4.0，并检查：

```
conda-lock --version
```

## 二、安装开发仓库

### 2.1 仓库初始化

```
$ mkdir Voyager && cd Voyager 
$ git clone https://github.com/SEU-ACAL/tapeout-Voyager.git .
$ git checkout dev

$ ./build-setup.sh
```

### 2.2 仓库介绍

**2.2.1 可提交物**

Voyager 仓库下只有 `generator`部分文件夹, `software`, `scripts` 和 `doc` 四个文件夹可提交，其余全部.gitignore

`generator` 文件夹下存放RTL design.
`generator`下可修改的目录如下:
- chipyard/src: 存放顶层TopConfig
- boom/src
- rocket-chip/src
- gemmini/src

其余maintain的代码文件(已经修改完成，默认不允许提交代码到此处):
- firechip/src: 存放firesim的调试config
- testchipip: 存放firesim的调试接口连接

`software` 文件夹用于存放各个方向的workload和执行的脚本.
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


## 三、Workload

**3.1 编译workload**

按照如下命令初始化workload

```
$ cd Voyager
$ source env.sh

$ cd Voyager/software
$ mkdir build && cd build 
$ cmake ..
```

编译所有workload
```
$ make build-all
```

如果只需单独编译部分workload
```
$ make cpu-build
$ make npu-build
```

**3.2 添加自定义workload**

*TBC*


## 四、Spike

可以通过以下几个测试用例，测试Spike可以正常使用

```
$ cd Voyager
$ ./software/scripts/run-spike.sh hello 
$ ./software/scripts/run-spike.sh --pk cpu-spmm
$ ./software/scripts/run-spike.sh matmul_os
```


## 五、Verilator

**5.1 Build RTL**

可以通过以下几个测试用例，测试Verilator RTL的正确性

```
$ cd Voyager
$ ./software/scripts/build-verilator.sh --config RocketConfig # Build 单独Rocket
$ ./software/scripts/build-verilator.sh --config CustomGemminiSoCConfig # Build 单独Gemmini
$ ./software/scripts/build-verilator.sh --config OurHeterSoCConfig # Build 六核版
```

Verilator编译出的可执行文件会被自动拷贝到 `software/build-results/verilator` 路径下

**5.2 测试运行workload**

可以通过下面测试用例，测试Verilator build的正确性

```
# 运行software/build-results/workloads/cpu/hello-baremetal
$ ./software/scripts/run-verilator.sh --config RocketConfig hello 

# 运行software/build-results/workloads/npu/native/vector-baremetal
$ ./software/scripts/run-verilator.sh --config CustomGemminiSoCConfig vector 
```


## 六、firesim

**6.1 使用library 模式安装**

强烈建议firesim安装在Voyager目录旁边，否则路径可能会出问题(自定义路径需修改代码注释在 firesim 的 make 文件代码中)

```
$ git clone https://github.com/firesim/firesim.git
$ cd firesim
$ git checkout 1.17.1
$ source Voyager/env.sh
$ ./build-setup.sh --library
```

执行完请检查`firesim/env.sh`这里的conda环境是否为Voyager目录下的conda环境，默认需要手动修改.

**6.2 firesim对接chipyard**

```
$ cd firesim
$ rm -rf ./sim
$ ln -s ../Voyager/sims/firesim/sim ./sim
```
注意检查是否正确软连接到 Voyager目录，之后操作与firesim文档完全一致.

注：如果在执行firesim buildbitstream时，出现 "No rule to make target /lib/libdromajo_cosim.a" 的报错，请运行`./scripts/firesim_replacement.sh`，之后再执行firesim buildbitstream 就不会出现这个问题.

## 七、安装 pre-commit 

安装 pre-commit 用于 CI 测试

```
$ cd Voyager
$ source env.sh 
$ pip install pre-commit
$ pre-commit install
$ git update-index --assume-unchanged scripts/permission_check.sh
```

安装完 pre-commit 后请打开 `scripts/permission_check.sh` 将你需要修改的文件夹路径取消注释。
通过这种方式我们防止提交文件夹污染，只有位于这几个文件夹的文件修改允许提交。

```
allowed_dirs=( \
    # "generators/boom/src" \  # # just enabled for cpu team
    # "generators/gemmini/src" \ # just enabled for npu team
    # "generators/rocket-chip/src/main/scala/npu" \  # just enabled for npu team
    # "generators/rocket-chip/src/main/scala/rocket" \  # just enabled for cpu team
    "generators/chipyard/src" \
    "software" \
    "documents" \
    "scripts")
```

## 八、文档目录

其余具体可见`documents`下的文档，欢迎大家多写文档，记录下用法和一些坑.

[[Q&A List](documents/Q&A.md)] 仓库使用遇到问题可以在群里询问，问题解决后将解决方法记录在这里.    
[[firesim](documents/firesim-README.md)] firesim 的简略文档，求补充.  
[[NPU-README](documents/NPU-README.md)] 主要关于buddy-mlir的安装.
