#!/bin/bash

help () {
  echo "Run a RISCV program on Spike, our functional ISA simulator"
  echo
  echo "Usage: $0 [-h|--help] [--pk] [--ext=EXTENSION] BINARY"
  echo
  echo "Options:"
  echo " pk      Run binaries on the proxy kernel, which enables virtual memory"
  echo "         and a few syscalls. If this option is not set, binaries will be"
  echo "         run in baremetal mode."
  echo " ext     Specify extension to use: gemmini or buckyballCycle or buckyballFunc (default: gemmini)"
  echo " BINARY  The RISCV binary that you want to run. This can either be the"
  echo '         name of a program in `software/gemmini-rocc-tests`, or it can'
  echo "         be the full path to a binary you compiled."
  echo
  echo "Examples:"
  echo "         $0 resnet50"
  echo "         $0 --pk mvin_mvout"
  echo "         $0 --ext=buckyballFunc path/to/binary-baremetal"
  echo "         $0 path/to/binary-baremetal"
  echo
  echo 'Note:    Run this command after running `scripts/build-spike.sh`.'
  echo
  echo "Note:    On Spike, cycle counts, SoC counter values, and performance"
  echo "         statistics are all meaningless. Use Spike only to check if your"
  echo "         programs are functionally correct. For meaningful metrics, you"
  echo "         must run your programs on VCS, Verilator, or Firesim instead."
  exit
}

if [ $# -le 0 ]; then
    help
fi

CYDIR=$(git rev-parse --show-toplevel)

pk=0
show_help=0
binary=""
extension="gemmini"

while [ $# -gt 0 ] ; do
  case $1 in
    --pk) pk=1 ;;
    --ext=*) extension="${1#--ext=}" ;;
    --ext) 
        shift
        extension="$1" ;;
    -h | --help) show_help=1 ;;
    *) binary=$1
  esac

  shift
done

if [ $show_help -eq 1 ]; then
   help
fi

# Validate extension
if [ "$extension" != "gemmini" ] && [ "$extension" != "buckyballCycle" ] && [ "$extension" != "buckyballFunc" ]; then
    echo "Error: Unknown extension '$extension'. Use 'gemmini' or 'buckyballCycle' or 'buckyballFunc'."
    exit 1
fi

if [ $pk -eq 1 ]; then
    default_suffix="-linux"
    PK="pk -p"
else
    default_suffix="-baremetal"
    PK=""
fi

path=""
suffix=""

find_binary_in_dir() {
    local search_dir="$1"
    local binary_name="$2"
    local suffix="$3"
    if [ -f "${search_dir}/${binary_name}${suffix}" ]; then
        echo "${search_dir}/"
        return 0
    fi
    for subdir in $(find "${search_dir}" -type d); do
        if [ -f "${subdir}/${binary_name}${suffix}" ]; then
            echo "${subdir}/"
            return 0
        fi
    done
    return 1
}

for dir in cpu npu tutorial; do
    base_dir="${CYDIR}/voyager-test/output/workloads/${dir}"
    if [ -d "${base_dir}" ]; then
        found_path=$(find_binary_in_dir "${base_dir}" "${binary}" "${default_suffix}")
        if [ $? -eq 0 ]; then
            path="${found_path}"
            suffix="${default_suffix}"
            break
        fi
    fi
done

full_binary_path="${path}${binary}${suffix}"

if [ ! -f "${full_binary_path}" ]; then
    echo "Binary not found: $full_binary_path"
    exit 1
fi

spike --extension=${extension} $PK "${full_binary_path}"
