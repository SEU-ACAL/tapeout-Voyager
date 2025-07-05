#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CYDIR=$(git rev-parse --show-toplevel)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置文件：定义不同测试套件的配置和测试用例
declare -A TEST_SUITES

# 对比测试模式标志
DIFFTEST_MODE="off"

# NPU测试套件配置
# 注意: 纯NPU配置跑不了hello (因为是多核的) 
BB_CONFIGS=("BuckyBallRocketConfig")
BB_TESTS=("bb_mvin_mvout_single"
          )

NPU_CONFIGS=("GemminiRocketConfig")
NPU_TESTS=("template"  
           "template")

# MEEK测试套件配置
MEEK_CONFIGS=("VoyagerVerilatorConfig")
MEEK_TESTS=("hello")

# 全量测试套件配置
SOC_CONFIGS=("VoyagerVerilatorConfig")
SOC_TESTS=("hello" 
            "bb_mvin_mvout_multi")

# 对比测试配置映射 (RTL配置 -> Spike扩展)
declare -A DIFFTEST_CONFIG_MAP
DIFFTEST_CONFIG_MAP["BuckyBallRocketConfig"]="buckyballFunc"
DIFFTEST_CONFIG_MAP["VoyagerVerilatorConfig"]="gemmini"
DIFFTEST_CONFIG_MAP["GemminiRocketConfig"]="gemmini"

help() {
  echo -e "${BLUE}批量测试脚本${NC}"
  echo
  echo "用法: $0 [测试套件] [选项]"
  echo
  echo "测试套件:"
  echo "  --npu-test          运行NPU相关测试  "
  echo "  --meek-test         运行Meek相关测试 "
  echo "  --soc-test          运行soc测试 "
  echo
  echo "选项:"
  echo "  --difftest=on       启用对比测试模式 (先跑spike后跑rtl并对比结果)"
  echo "  -h, --help          显示此帮助信息"
  echo
  echo "示例:"
  echo "  $0 --npu-test                    # 运行所有NPU测试"
  echo "  $0 --meek-test --difftest=on     # 运行Meek测试并启用对比模式"
  echo "  $0 --soc-test                    # 运行soc测试"
  exit 0
}

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}


log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# 构建指定配置 (永远使用debug模式)
build_config() {
  local config=$1
  
  log_info "构建配置: $config (debug模式)"
  ${SCRIPT_DIR}/build-verilator.sh --debug --config $config \
    $([ $config = VoyagerVerilatorConfig ] && echo "--project voyager_tapeout --sub-project voyager_tapeout") 

  if [ $? -eq 0 ]; then
    log_success "配置 $config 构建成功"
    return 0
  else
    log_error "配置 $config 构建失败"
    return 1
  fi
}

# 运行指定配置和测试用例 (永远使用debug模式)
run_test() {
  local config=$1
  local test=$2
  
  log_info "运行测试: ${BLUE}$config + $test${NC} (debug模式)"
  ${SCRIPT_DIR}/run-verilator.sh --debug --config $config $test --vcd2fst
  
  if [ $? -eq 0 ]; then
    log_success "测试 ${BLUE}$config + $test${NC} 通过"
    return 0
  else
    log_error "测试 ${BLUE}$config + $test${NC} 失败"
    return 1
  fi
}

# 过滤输出，移除干扰信息
filter_output() {
  local input="$1"
  # 过滤掉 verilator 的警告信息、UART信息、finish信息、日志信息等
  # 尽量精确不要误伤workload内的数据
  echo "$input" | grep -v "^%Warning:" | \
                   grep -v "^\[UART\]" | \
                   grep -v "^- .*Verilog \$finish" | \
                   grep -v "^$" | \
                   grep -v "Converting VCD waveform to FST format" | \
                   grep -v "Waveform conversion successful" | \
                   sed '/^$/d'
}

# 运行spike测试
run_spike_test() {
  local config=$1
  local test=$2
  
  # 从配置映射中获取对应的spike扩展
  local ext_config="${DIFFTEST_CONFIG_MAP[$config]}"
  if [ -z "$ext_config" ]; then
    log_error "未找到配置 $config 对应的Spike扩展，使用默认值 buckyballFunc"
    ext_config="buckyballFunc"
  fi
  
  # log_info "运行Spike测试: $test (扩展: $ext_config)"
  local spike_output
  spike_output=$(${SCRIPT_DIR}/run-spike.sh --ext=$ext_config $test 2>&1)
  local spike_result=$?
  
  if [ $spike_result -eq 0 ]; then
    echo "$spike_output"
    return 0
  else
    log_error "Spike测试失败: $test"
    echo "$spike_output" >&2
    return 1
  fi
}

# 运行对比测试 (先跑spike，再跑rtl，对比结果)
run_difftest() {
  local config=$1
  local test=$2
  
  log_info "测试用例: ${BLUE}$config + $test${NC}"
  
  # 1. 运行spike测试
  log_info "第1步: 运行Spike测试"
  local spike_output
  spike_output=$(run_spike_test "$config" "$test")
  local spike_result=$?
  
  if [ $spike_result -ne 0 ]; then
    log_error "Spike测试失败，跳过RTL测试"
    return 1
  fi
  
  # 2. 运行RTL测试
  log_info "第2步: 运行RTL测试"
  local rtl_output
  rtl_output=$(${SCRIPT_DIR}/run-verilator.sh --debug --config $config $test --vcd2fst 2>&1)
  local rtl_result=$?
  
  if [ $rtl_result -ne 0 ]; then
    log_error "RTL测试失败"
    return 1
  fi
  
  # 3. 过滤输出
  local filtered_spike_output
  local filtered_rtl_output
  filtered_spike_output=$(filter_output "$spike_output")
  filtered_rtl_output=$(filter_output "$rtl_output")
  
  # 4. 对比结果
  log_info "第3步: 对比输出结果"
  
  # 显示输出结果
  echo -e "${YELLOW}=== Spike输出 ===${NC}"
  echo "$filtered_spike_output"
  echo -e "${YELLOW}=== RTL输出 ===${NC}"
  echo "$filtered_rtl_output"
  echo -e "${YELLOW}===============${NC}"
  
  if [ "$filtered_spike_output" = "$filtered_rtl_output" ]; then
    log_success "对比测试通过: ${BLUE}$config + $test${NC}"
    return 0
  else
    log_error "对比测试失败: ${BLUE}$config + $test${NC}"
    return 1
  fi
}

# 执行批量测试
run_batch_test() {
  local configs=("$@")
  local tests_ref=$1
  shift
  local configs=("$@")
  
  # 通过引用获取测试用例数组
  local -n tests=$tests_ref
  
  local total_tests=0
  local passed_tests=0
  local failed_tests=0
  
  # 测试结果记录数组
  local test_results=()
  
  log_info "开始批量测试..."
  log_info "配置列表: ${configs[*]}"
  log_info "测试用例: ${tests[*]}"
  
  if [ "$DIFFTEST_MODE" = "on" ]; then
    log_info "对比测试模式已启用 (Spike vs RTL)"
  fi
  
  # 构建阶段
  echo
  log_info "=== 构建阶段 ==="
  for config in "${configs[@]}"; do
    build_config "$config"
    if [ $? -ne 0 ]; then
      log_error "构建失败，终止测试"
      exit 1
    fi
  done
  
  # 测试阶段
  echo
  log_info "=== 测试阶段 ==="
  for config in "${configs[@]}"; do
    for test in "${tests[@]}"; do
      total_tests=$((total_tests + 1))
      local test_name="${config} + ${test}"
      
      if [ "$DIFFTEST_MODE" = "on" ]; then
        run_difftest "$config" "$test"
      else
        run_test "$config" "$test"
      fi
      
      if [ $? -eq 0 ]; then
        passed_tests=$((passed_tests + 1))
        test_results+=("[PASS] ${BLUE}${test_name}${NC}")
      else
        failed_tests=$((failed_tests + 1))
        test_results+=("[FAILED] ${BLUE}${test_name}${NC}")
      fi
    done
  done
  
  # 总结
  echo
  log_info "=== 测试总结 ==="
  log_info "总测试数: $total_tests"
  log_success "通过: $passed_tests"
  if [ $failed_tests -gt 0 ]; then
    log_error "失败: $failed_tests"
  fi
  
  # echo
  # log_info "=== 详细测试结果 ==="
  for result in "${test_results[@]}"; do
    if [[ $result == *"[PASS]"* ]]; then
      echo -e "${GREEN}${result}${NC}"
    else
      echo -e "${RED}${result}${NC}"
    fi
  done
  
  if [ $failed_tests -gt 0 ]; then
    exit 1
  else
    log_success "所有测试通过！"
  fi
}

# 解析命令行参数
TEST_SUITE=""

while [ $# -gt 0 ]; do
  case $1 in
    -h|--help)
      help
      ;;
    --bb-test)
      TEST_SUITE="bb"
      ;;
    --npu-test)
      TEST_SUITE="npu"
      ;;
    --meek-test)
      TEST_SUITE="meek"
      ;;
    --soc-test)
      TEST_SUITE="soc"
      ;;
    --difftest=on)
      DIFFTEST_MODE="on"
      ;;
    *)
      log_error "未知选项: $1"
      help
      ;;
  esac
  shift
done

# 检查测试套件是否指定
if [ -z "$TEST_SUITE" ]; then
  log_error "请指定测试队列 (--bb-test, --npu-test, --meek-test, 或 --soc-test)"
  help
fi

# 根据测试套件执行相应测试
case $TEST_SUITE in
  "bb")
    log_info "执行BuckyBall测试队列"
    run_batch_test BB_TESTS "${BB_CONFIGS[@]}"
    ;;  
  "npu")
    log_info "执行NPU测试队列"
    run_batch_test NPU_TESTS "${NPU_CONFIGS[@]}"
    ;;
  "meek")
    log_info "执行Meek测试队列"
    run_batch_test MEEK_TESTS "${MEEK_CONFIGS[@]}"
    ;;
  "soc")
    log_info "执行全量测试队列"
    run_batch_test SOC_TESTS "${SOC_CONFIGS[@]}"
    ;;
  *)
    log_error "未知的测试队列: $TEST_SUITE"
    help
    ;;
esac 