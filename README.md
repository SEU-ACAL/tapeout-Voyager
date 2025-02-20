# 仓库开发手册

## 一、安装 anaconda

https://www.anaconda.com/download/

创建一个 conda 环境，并且需要其中安装 conda-lock==1.4.0。

## 二、安装 开发仓库

```
mkdir Voyager && cd Voyager 
git clone https://github.com/SEU-ACAL/tapeout-Voyager.git .
# git checkout 1.0.0 # 等第一版六核版更新后启用该版本号

cd chipyard  
./build-setup.sh
```

### 可提交物：

Voyager 仓库下只有 `chipyard/generator`部分文件夹, `chipyard/software`, `scripts`和`doc`四个文件夹可提交，其余全部.gitignore

#### chipyard/generator 文件夹下存放RTL design。

#### chipyard/software 文件夹用于存放各个方向的workload和执行的脚本
现有workload：
- hello
- template

### 测试用例



## 三、安装 pre-commit
```
cd Voyager 
pip install pre-commit
pre-commit install
```
