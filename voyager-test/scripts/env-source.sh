#!/bin/bash

# 环境切换脚本
# 使用方法: source env-source.sh [vcs|dc]

# 清除可能存在的旧环境变量设置函数
unset setup_vcs
unset setup_dc

# VCS环境设置函数
setup_vcs() {
    echo "Step up VCS environment..."
    # 环境1
    export PATH="/home/hxm123/.local/bin:$PATH"
    export PATH="/home/hxm123/chipyard/firtool1/bin:$PATH"
    # export DISPLAY="localhost:10.0" // Config yourself if you want to use verdi
    #export SYNOPSYS="/usr/software/synopsys"
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
    
    echo "VCS environment setup completed"
}

# DC环境设置函数
setup_dc() {
    echo "Step up DC environment..."
    # 环境2
    export SNPSLMD_LICENSE_FILE=26000@devjz-ubt20-s01
    alias lmli="/home/gb515897968/synopsys/scl/2021.03/linux64/bin/lmgrd -c /home/gb515897968/synopsys/scl/2021.03/admin/license/Synopsys.dat"
    # #SCL
    export PATH=/home/gb515897968/synopsys/scl/2021.03/linux64/bin:$PATH
    export DC_HOME=/home/gb515897968/synopsys/syn/R-2020.09-SP5/bin/
    export PATH=$PATH:/home/gb515897968/synopsys/syn/R-2020.09-SP5/bin/
    export SCL_HOME=/usr/Synopsys/scl/2021.03
    export PATH=$PATH:$SCL_HOME/linux64/bin
    export VCS_ARCH_OVERRIDE=linux
    
    echo "DC environment setup completed"
}

if [ "$1" = "vcs" ] ; then
    setup_vcs
elif [ "$1" = "dc" ]; then
    setup_dc
else
    echo "错误: 请指定有效的环境参数 (vcs 或 dc)"
    echo "用法: source env-source.sh [vcs|dc]"
    echo "  vcs - 设置VCS环境 (VCS/Verdi 2018环境) - 默认选项"
    echo "  dc  - 设置DC环境 (Synopsys 2021环境)"
    return 1
fi
