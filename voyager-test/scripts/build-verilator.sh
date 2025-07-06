#!/bin/bash

help() {
  echo "用法: $0 [选项]"
  echo
  echo "选项:"
  echo "  -h, --help           显示此帮助信息并退出"
  echo "  --debug              启用调试模式"
  echo "  --fst                启用 FST 波形"
  echo "  -j <num>             指定并行任务数 (默认: 128)"
  echo "  -c, --config <config> 指定配置参数"
  echo "  -p, --project <project> 指定 SBT 项目 (默认: chipyard)"
  echo "  -s, --sub-project <sub> 指定子项目 (如: voyager_tapeout)"
  exit 0
}

show_help=0
debug=""
j="256"
SBT_PROJECT="chipyard"
SUB_PROJECT=""

# CYDIR表示chipyard的路径
CYDIR=$(git rev-parse --show-toplevel)
CONFIG=
USE_FST=
while [ $# -gt 0 ] ; do
  case $1 in
    -h|--help)
      show_help=1
      ;;
    --debug)
      debug="debug"
      ;;
    --fst)
      USE_FST=1
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

DEBUG_POSTFIX=""
if [ "$debug" == "debug" ]; then
  DEBUG_POSTFIX="-debug"
fi

cd ${CYDIR}/sims/verilator/ || { echo "Cannot enter the directory: ${CYDIR}/sims/verilator/"; exit 1; }
make -j$j ${debug} CONFIG=$CONFIG \
  USE_FST=$USE_FST \
  SBT_PROJECT=$SBT_PROJECT \
  $([ -n "$SUB_PROJECT" ] && echo "SUB_PROJECT=$SUB_PROJECT") \
  || { echo "[Build verilator Failed!]==================="; exit 1; }

# 编译成功了才会搬过来
mkdir -p ${CYDIR}/voyager-test/output/verilator
cp ${CYDIR}/sims/verilator/simulator-chipyard.harness-${CONFIG}${DEBUG_POSTFIX} ${CYDIR}/voyager-test/output/verilator
