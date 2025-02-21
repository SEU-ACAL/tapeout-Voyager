# 仓库开发手册

## 一、安装 anaconda

https://www.anaconda.com/download/

创建一个 conda 环境，并且需要其中安装 conda-lock==1.4.0。

## 二、安装 开发仓库

```
mkdir Voyager && cd Voyager 
git clone https://github.com/SEU-ACAL/tapeout-Voyager.git .
# git checkout 0.0.1 # 等第一版六核版更新后启用该版本号

./build-setup.sh
```

### 可提交物：

Voyager 仓库下只有 `generator`部分文件夹, `software` 和`doc`三个文件夹可提交，其余全部.gitignore

#### `generator` 文件夹下存放RTL design.
`generator`下可修改的目录如下:
- chipyard/src: 存放顶层TopConfig
- boom/src
- rocket-chip/src
- gemmini/src

#### `software` 文件夹用于存放各个方向的workload和执行的脚本.
现有workload：
- cpu
    - hello
    - spmm
- npu 
    - template


一键编译workload
```
cd Voyager/software
mkdir build && cd build 
cmake ..

# 编译所有workload
make all-bin
```

### 测试用例



## 三、安装 pre-commit
```
cd Voyager 
pip install pre-commit
pre-commit install
```
