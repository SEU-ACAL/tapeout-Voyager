#!/bin/bash

CYDIR=$(git rev-parse --show-toplevel)
ROOT=${CYDIR}/voyager-test
OUTPUT_DIR="${ROOT}/output/disasm"
mkdir -p "${OUTPUT_DIR}"

TIMESTAMP=$(date +%Y-%m-%d-%H-%M)

help () {
  echo "Generate disassembly and visualization webpage for RISCV binary"
  echo
  echo "Usage: $0 [--pk] [--config CONFIG] [--output DIR] BINARY"
  echo
  echo "Options:"
  echo " pk      Search for binaries with -pk suffix (proxy kernel mode)."
  echo "         If not set, will search for -baremetal suffix."
  echo
  echo " config   --config/-c your scala Config (for simulator compatibility)"
  echo
  echo " output   --output/-o output directory (default: ${OUTPUT_DIR})"
  echo
  echo " BINARY  The RISCV binary name that you want to disassemble. This can"
  echo '         be the name of a program in `voyager-test/output/workloads`,'
  echo "         or the full path to a binary."
  echo
  echo "Examples:"
  echo "         $0 template"
  echo "         $0 --pk mvin_mvout"
  echo "         $0 --output /tmp/disasm template"
  echo "         $0 path/to/binary-baremetal"
  echo
  echo 'Output:  Generated files will be placed in the output directory:'
  echo '         - original.txt: Original objdump output'
  echo '         - decoded.txt: Custom instructions replaced'
  echo '         - visualization.html: Interactive webpage'
  exit
}

if [ $# -le 0 ]; then
    help
fi

pk=0
show_help=0
binary=""
CONFIG=""

while [ $# -gt 0 ] ; do
  case $1 in
    --pk) pk=1 ;;
    -c|--config)
      if [[ -n $2 && $2 != -* ]]; then
        CONFIG="$2"
        shift
      else
        echo "Error: -c or --config need a parameter"
        help
      fi
      ;;
    -o|--output)
      if [[ -n $2 && $2 != -* ]]; then
        OUTPUT_DIR="$2"
        mkdir -p "${OUTPUT_DIR}"
        shift
      else
        echo "Error: -o or --output need a parameter"
        help
      fi
      ;;
    -h | --help) show_help=1 ;;
    *) binary=$1
  esac

  shift
done

if [ $show_help -eq 1 ]; then
   help
fi

if [ -z "$binary" ]; then
  echo "Error: No binary specified"
  help
fi

if [ $pk -eq 1 ]; then
  default_suffix="-pk"
else
  default_suffix="-baremetal"
fi

path=""
suffix=""

source ${CYDIR}/env.sh

# 递归查找函数 
find_binary_in_dir() {
  local search_dir="$1"
  local binary_name="$2"
  local suffix="$3"
    
  # 检查当前目录
  if [ -f "${search_dir}/${binary_name}${suffix}" ]; then
    echo "${search_dir}/"
    return 0
  fi
  # 递归检查所有子目录
  for subdir in $(find "${search_dir}" -type d); do
    if [ -f "${subdir}/${binary_name}${suffix}" ]; then
        echo "${subdir}/"
        return 0
    fi
  done
  return 1
}

# 检查是否是完整路径的二进制文件
if [ -f "${binary}" ]; then
  full_binary_path="${binary}"
  binary_name=$(basename "${binary}")
else
  # 在cpu和npu及其子目录中查找二进制文件
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
  binary_name="${binary}"
fi

if [ ! -f "${full_binary_path}" ]; then
  echo "Binary not found: $full_binary_path"
  echo "Searched in:"
  for dir in cpu npu tutorial; do
    base_dir="${CYDIR}/voyager-test/output/workloads/${dir}"
    if [ -d "${base_dir}" ]; then
      echo "  - ${base_dir} (recursive)"
    fi
  done
  exit 1
fi

echo "Found binary: ${full_binary_path}"
echo "Output directory: ${OUTPUT_DIR}"

# 生成输出文件名
output_prefix="${OUTPUT_DIR}/${TIMESTAMP}-${binary_name}"
original_disasm="${output_prefix}-original.txt"
decoded_disasm="${output_prefix}-decoded.txt"  
html_output="${output_prefix}-visualization.html"

echo "Processing ${full_binary_path}..."

# 步骤1: 生成原始反汇编
echo "Step 1: Generating original disassembly..."
if ! riscv64-unknown-elf-objdump -d -M no-aliases "${full_binary_path}" > "${original_disasm}"; then
  echo "Error: Failed to generate disassembly with objdump"
  echo "Make sure riscv64-unknown-elf-objdump is in your PATH"
  exit 1
fi

echo "Original disassembly saved to: ${original_disasm}"

# 步骤2: 替换自定义指令
echo "Step 2: Replacing custom instructions..."
script_dir="$(dirname "$0")"
replace_script="${script_dir}/replace_custom_inst.py"

if [ ! -f "${replace_script}" ]; then
  echo "Error: replace_custom_inst.py not found at ${replace_script}"
  exit 1
fi

if ! python3 "${replace_script}" "${original_disasm}" "${decoded_disasm}"; then
  echo "Error: Failed to replace custom instructions"
  exit 1
fi

echo "Decoded disassembly saved to: ${decoded_disasm}"

# 步骤3: 生成可视化网页
echo "Step 3: Generating visualization webpage..."
viz_script="${script_dir}/disasm_reader.py"

if [ ! -f "${viz_script}" ]; then
  echo "Error: disasm_reader.py not found at ${viz_script}"
  exit 1
fi

if ! python3 "${viz_script}" "${decoded_disasm}" "${html_output}"; then
  echo "Error: Failed to generate visualization webpage"
  exit 1
fi

echo "Visualization webpage saved to: ${html_output}"

# 总结
echo ""
echo "=========================================="
echo "Disassembly and Visualization Complete!"
echo "=========================================="
echo "Binary:           ${full_binary_path}"
echo "Original disasm:  ${original_disasm}"
echo "Decoded disasm:   ${decoded_disasm}"
echo "Visualization:    ${html_output}"
echo ""
echo "To view the visualization, open the HTML file in a web browser:"
echo "  firefox ${html_output}  # or your preferred browser"
echo ""

# 可选：自动打开浏览器
if command -v xdg-open > /dev/null 2>&1; then
  read -p "Open visualization in default browser? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    xdg-open "${html_output}"
  fi
fi
