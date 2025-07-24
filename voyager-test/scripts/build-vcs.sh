#!/bin/bash

help () {
  echo "Build a cycle-accurate VCS simulator for RISCV Gemmini programs,"
  echo 'matching `customConfig` in `configs/GemminiCustomConfigs.scala`.'
  echo
  echo "Usage: $0 [-h|--help] [--debug] [-j [N]]"
  echo
  echo "Options:"
  echo " debug   Builds a VCS simulator which generates waveforms. Without this"
  echo "         option, the simulator will not generate any waveforms."
  echo " j [N]   Allow N jobs at once. Default is 1."
  exit
}

show_help=0
debug=""
j="2"

while [ $# -gt 0 ] ; do
  case $1 in
    -h|--help)
      show_help=1
      ;;
    --debug)
      debug="debug"
      ;;
    -j)
      if [[ -n $2 && $2 != -* ]]; then
        j="$2"
        shift
      else
        echo "错误: -j 选项需要一个参数"
        help
      fi
      ;;
    -c|--config)
      if [[ -n $2 && $2 != -* ]]; then
        CONFIG="$2"
        shift
      else
        echo "错误: -c 或 --config 选项需要一个参数"
        help
      fi
      ;;
    -p|--project)
      if [[ -n $2 && $2 != -* ]]; then
        SBT_PROJECT="$2"
        shift
      else
        echo "错误: -p 或 --project 选项需要一个参数"
        help
      fi
      ;;
    -s|--sub-project)
      if [[ -n $2 && $2 != -* ]]; then
        SUB_PROJECT="$2"
        shift
      else
        echo "错误: -s 或 --sub-project 选项需要一个参数"
        help
      fi
      ;;
    *)
      echo "未知选项: $1"
      help
      ;;
  esac
  shift
done


if [ "$show_help" -eq 1 ]; then
  help
fi

# CONFIG 是必须项
if [ -z "$CONFIG" ]; then
  echo "ERROR: CONFIG 参数未指定。请使用 -c 或 --config 选项提供配置。"
  help
fi
# 检查是否需要清理缓存
CACHE_DIR="${CYDIR}/.classpath_cache"

# 当使用voyager_tapeout项目时，自动清理缓存以避免配置冲突
if [ "$SBT_PROJECT" = "voyager_tapeout" ] ; then
  rm -rf "$CACHE_DIR"
fi

DASH_DEBUG_POSTFIX=""
POINT_DEBUG_POSTFIX=""
if [ "$debug" == "debug" ]; then
  DASH_DEBUG_POSTFIX="-debug"
  POINT_DEBUG_POSTFIX=".debug"
fi

CYDIR=$(git rev-parse --show-toplevel)
# 切换环境变量
source ${CYDIR}/voyager-test/scripts/env-source.sh vcs

export PATH="/usr/bin:$PATH"          # 系统 gcc/g++/ld 优先
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export LD=/usr/bin/ld

# 编译阶段只让 ld 找到系统基础库 + VCS 私有库
export LIBRARY_PATH="$VCS_LIB:/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu"
unset LD_LIBRARY_PATH
export LDFLAGS="-L$VCS_LIB -Wl,--no-as-needed \
      -lvcsnew -lvirsim -lvcsucli -lvfs -lsnpsmalloc -lerrorinf -lzerosoft_rt_stubs \
      -lsimprofile -luclinative -lpthread -ldl -lrt -lm -lstdc++ -lpthread"
cd ${CYDIR}/sims/vcs/ || { echo "Cannot enter the directory: ${CYDIR}/sims/vcs/"; exit 1; }
make -j$j ${debug} CONFIG=$CONFIG \
  USE_FST=$USE_FST \
  SBT_PROJECT=$SBT_PROJECT \
  $([ -n "$SUB_PROJECT" ] && echo "SUB_PROJECT=$SUB_PROJECT") \
  || { echo "[Build VCS Failed!]==================="; exit 1; } 
mkdir -p ${CYDIR}/voyager-test/output/vcs
cp ${CYDIR}/sims/vcs/simv-chipyard.harness-${CONFIG}${DASH_DEBUG_POSTFIX} ${CYDIR}/voyager-test/output/vcs/
# cp ${CYDIR}/sims/vcs/simv-chipyard.harness-${CONFIG}${DEBUG_POSTFIX}.daidir/ ${CYDIR}/voyager-test/output/vcs/ -r
cp ${CYDIR}/sims/vcs/generated-src/chipyard.harness.TestHarness.${CONFIG}/chipyard.harness.TestHarness.${CONFIG}${POINT_DEBUG_POSTFIX} ${CYDIR}/voyager-test/output/vcs/ -r
