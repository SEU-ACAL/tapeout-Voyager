# Q&A List

## 如何使用服务器上的DC？

由于DC版本和vcs verdi不同，所以需要对更换环境，具体的：

```
export PATH="/home/hxm123/.local/bin:$PATH"
# export PATH="/home/hxm123/chipyard/firrtl/utils/bin:$PATH"
# # export PATH="/home/hxm123/chipyard/firtool/bin:$PATH"
export PATH="/home/hxm123/chipyard/firtool1/bin:$PATH"
export DISPLAY="localhost:10.0"
#export export SYNOPSYS="/usr/software/synopsys"
export VCS_TARGET_ARCH="amd64"
export PATH="/usr/stone/software/vcs2018/vcs/O-2018.09-SP2/gui/dve/bin:"$PATH
export DVE_HOME="/usr/stone/software/vcs2018/vcs/O-2018.09-SP2/gui/dve"
export PATH="/usr/stone/software/vcs2018/vcs/O-2018.09-SP2/bin:"$PATH
export VCS_HOME="/usr/stone/software/vcs2018/vcs/O-2018.09-SP2"
#export VCS_ARCH_OVERRIDE="linux"
#verdi
export PATH="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2/bin:"$PATH
export VERDI_HOME="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2"
export LD_LIBRARY_PATH="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2/share/PLI/lib/LINUX64":$LD_LIBRARY_PATH
export VERDI_DIR="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2"
export NOVAS_INST_DIR="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2"
export NPI_PLATFORM="LINUX64_GNU_472"
export LD_LIBRARY_PATH="$NOVAS_INST_DIR/share/NPI/lib/LINUX64_GNU_520":$LD_LIBRARY_PATH
export NOVAS_HOME="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2"

#LICENSE
export SNPSLMD_LICENSE_FILE="/usr/stone/software/Liscen/Synopsys.dat"
export SNPSLMD_LICENSE_FILE=27000@devjz-ubt20-s01
export LM_LICENSE_FILE="/usr/stone/software/Liscen/Synopsys.dat"

alias lmli="/usr/stone/software/SCL2018/scl/2018.06/linux64/bin/lmgrd -c /usr/stone/software/License/Synopsys.dat"
#SCL
export PATH=/usr/stone/software/SCL2018/scl/2018.06/linux64/bin:$PATH
alias dve="dve -full64 &"
alias vcs64="vcs -full64"
alias verdi="verdi -full64 &"export PATH="/home/hxm123/.local/bin:$PATH"
# export PATH="/home/hxm123/chipyard/firrtl/utils/bin:$PATH"
# # export PATH="/home/hxm123/chipyard/firtool/bin:$PATH"
export PATH="/home/hxm123/chipyard/firtool1/bin:$PATH"
export DISPLAY="localhost:10.0"
#export export SYNOPSYS="/usr/software/synopsys"
export VCS_TARGET_ARCH="amd64"
export PATH="/usr/stone/software/vcs2018/vcs/O-2018.09-SP2/gui/dve/bin:"$PATH
export DVE_HOME="/usr/stone/software/vcs2018/vcs/O-2018.09-SP2/gui/dve"
export PATH="/usr/stone/software/vcs2018/vcs/O-2018.09-SP2/bin:"$PATH
export VCS_HOME="/usr/stone/software/vcs2018/vcs/O-2018.09-SP2"
#export VCS_ARCH_OVERRIDE="linux"
#verdi
export PATH="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2/bin:"$PATH
export VERDI_HOME="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2"
export LD_LIBRARY_PATH="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2/share/PLI/lib/LINUX64":$LD_LIBRARY_PATH
export VERDI_DIR="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2"
export NOVAS_INST_DIR="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2"
export NPI_PLATFORM="LINUX64_GNU_472"
export LD_LIBRARY_PATH="$NOVAS_INST_DIR/share/NPI/lib/LINUX64_GNU_520":$LD_LIBRARY_PATH
export NOVAS_HOME="/usr/stone/software/verdi/verdi/Verdi_O-2018.09-SP2"

#LICENSE
export SNPSLMD_LICENSE_FILE="/usr/stone/software/Liscen/Synopsys.dat"
export SNPSLMD_LICENSE_FILE=27000@devjz-ubt20-s01
export LM_LICENSE_FILE="/usr/stone/software/Liscen/Synopsys.dat"

alias lmli="/usr/stone/software/SCL2018/scl/2018.06/linux64/bin/lmgrd -c /usr/stone/software/License/Synopsys.dat"
#SCL
export PATH=/usr/stone/software/SCL2018/scl/2018.06/linux64/bin:$PATH
alias dve="dve -full64 &"
alias vcs64="vcs -full64"
alias verdi="verdi -full64 &"
```

如果要使用DC需要删除上面的环境变量（如果没有不用管），然后添加以下环境变量：

```
 export SNPSLMD_LICENSE_FILE=26000@devjz-ubt20-s01
# #export LM_LICENSE_FILE="/home/gb515897968/synopsys/scl/2021.03/admin/license/Synopsys.dat"

 alias lmli="/home/gb515897968/synopsys/scl/2021.03/linux64/bin/lmgrd -c /home/gb515897968/synopsys/scl/2021.03/admin/license/Synopsys.dat"
# #SCL
 export PATH=/home/gb515897968/synopsys/scl/2021.03/linux64/bin:$PATH
 export DC_HOME=/home/gb515897968/synopsys/syn/R-2020.09-SP5/bin/
 export PATH=$PATH:/home/gb515897968/synopsys/syn/R-2020.09-SP5/bin/
 export SCL_HOME=/usr/Synopsys/scl/2021.03
 export PATH=$PATH:$SCL_HOME/linux64/bin
 export VCS_ARCH_OVERRIDE=linux
```

之后source  后就可以使用dc

如果打开dc无法使用方向键和tab键，可以在环境变量加入：

```
export TERM=xterm-16color
```

## Metal 用不了怎么办？

删除 `~/.cache/coursier` 和 `~/.cache/bloop` 目录，然后重新import metal.

## Firesim board_part 问题

```
ERROR: [Board 49-71] The board_part definition was not found for xilinx.com:au280:part0:1.2. The project's board_part property was not set, but the project's part property was set to xcu280-fsvh2892-2L-e. Valid board_part values can be retrieved with the 'get_board_parts' Tcl command. Check if board.repoPaths parameter is set and the board_part is installed from the tcl app store.
```

解决办法：
将所有下面的0:1.2 改为 0:1.0或0:1.1 (注意别把这个文档也一键改了)

```
set_property board_part xilinx.com:au280:part0:1.2
```

## 服务器重启之后vcs和verdi用不了

按照以下教程第五步开始即可：
https://blog.csdn.net/qq_41717683/article/details/122267191

新增加build-vcs和run-vcs脚本 目前只在npu上验证。

## **Firesim 运行命令途中使用ctrl c中断命令导致之后无法执行命令**

```
Fatal error: One or more hosts failed while executing task 'infrasetup_node_wrapper'
```

ctrl c会去让linux把FPGA板子对应的端口卸载，然后重新加载，该情况就是在卸载后执行了ctrl c，导致未成功加载

解决方法：

```
echo 1 | sudo tee /sys/bus/pci/rescan
```

**尽量不要ctrl c**

## 使用Firesim前需要去看是否有人在用相应端口，否则可能导致FPGA端口挂载出问题

直接使用TOP看，是否有firesim线程

> 21端口的FPGA板子有概率一启动就导致服务器崩溃，目前暂时未找到解决方法（此时请不要使用21端口的板子）

## 仿真时间设置过短导致报错问题

```
[10000001000] %Fatal: TestDriver.v:147: Assertion failed in TOP.TestDriver
%Error: /home/gb515897968/tape/tapeout-Voyager/sims/verilator/generated-src/chipyard.harness.TestHarness.MEEKConfig/gen-collateral/TestDriver.v:147: Verilog $stop
Aborting...
```

遇到这种问题直接改tapeout根目录variables.mk的TIMEOUT_CYCLES
