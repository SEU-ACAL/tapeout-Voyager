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
j="256"

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

DEBUG_POSTFIX=""
if [ "$debug" == "debug" ]; then
  DEBUG_POSTFIX="-debug"
fi

CYDIR=$(git rev-parse --show-toplevel)
cd ${CYDIR}/sims/vcs/ || { echo "Cannot enter the directory: ${CYDIR}/sims/verilator/"; exit 1; }
make -j$j ${debug} CONFIG=GemminiRocketConfig USE_VPD=1
echo "Success"
cp ${CYDIR}/sims/vcs/simv-chipyard.harness-${CONFIG}${DEBUG_POSTFIX} ${CYDIR}/voyager-test/build-results/vcs
cp ${CYDIR}/sims/vcs/simv-chipyard.harness-${CONFIG}${DEBUG_POSTFIX}.daidir ${CYDIR}/voyager-test/build-results/vcs -r
# make print_vars
