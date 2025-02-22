#!/bin/bash

help() {
  echo "用法: $0 [选项]"
  echo
  echo "选项:"
  echo "  -h, --help           显示此帮助信息并退出"
  echo "  --debug              启用调试模式"
  echo "  -j <num>             指定并行任务数 (默认: 128)"
  echo "  -c, --config <config> 指定配置参数"
  exit 0
}

show_help=0
debug=""
j="128"

# CYDIR表示chipyard的路径
CYDIR=$(git rev-parse --show-toplevel)
CONFIG=

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

cd ${CYDIR}/sims/verilator/ || { echo "Cannot enter the directory: ${CYDIR}/sims/verilator/"; exit 1; }
make -j$j ${debug} CONFIG=$CONFIG || { echo "[Build verilator Failed!]==================="; exit 1; }
# 编译成功了才会搬过来
mkdir -p ${CYDIR}/software/build-results/verilator
cp ${CYDIR}/sims/verilator/simulator-chipyard-${CONFIG}${debug} ${CYDIR}/software/build-results/verilator
