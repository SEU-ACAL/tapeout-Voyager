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

# CDIR表示chipyard的路径
CDIR=$(git rev-parse --show-toplevel)
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

cd ${CDIR}/sims/verilator/ || { echo "无法进入目录 ${CDIR}/sims/verilator/"; exit 1; }
make -j$j ${debug} CONFIG=$CONFIG || { echo "[Build verilator Failed!]==============="; exit 1; }
# 编译成功了才会搬过来
mkdir -p ${CDIR}/software/build-rtl/
cp ${CDIR}/sims/verilator/simulator-chipyard-${CONFIG}${debug} ${CDIR}/software/build-rtl/
