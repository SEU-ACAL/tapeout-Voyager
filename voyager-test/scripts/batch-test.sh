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

# NPU测试套件配置
NPU_CONFIGS=("GemminiRocketConfig")
NPU_TESTS=("hello" 
           "template")

# CPU测试套件配置
MEEK_CONFIGS=("OurHeterSoCConfig")
MEEK_TESTS=("hello")

# 全量测试套件配置
FULL_CONFIGS=("OurHeterSoCConfig")
FULL_TESTS=("hello" 
            "cpu-spmm" 
            "template")

help() {
  echo -e "${BLUE}批量测试脚本${NC}"
  echo
  echo "用法: $0 [测试套件]"
  echo
  echo "测试套件:"
  echo "  --npu-test          运行NPU相关测试  "
  echo "  --meek-test         运行Meek相关测试 "
  echo "  --full-test         运行所有测试配置 "
  echo
  echo "选项:"
  echo "  -h, --help          显示此帮助信息"
  echo
  echo "示例:"
  echo "  $0 --npu-test                    # 运行所有NPU测试"
  echo "  $0 --meek-test                   # 运行所有Meek测试"
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
  ${SCRIPT_DIR}/build-verilator.sh --debug --config $config
  
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
  
  log_info "运行测试: $config + $test (debug模式)"
  ${SCRIPT_DIR}/run-verilator.sh --debug --config $config $test
  
  if [ $? -eq 0 ]; then
    log_success "测试 $config + $test 通过"
    return 0
  else
    log_error "测试 $config + $test 失败"
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
  
  log_info "开始批量测试..."
  log_info "配置列表: ${configs[*]}"
  log_info "测试用例: ${tests[*]}"
  
  # 构建阶段
  log_info "=== 构建阶段 ==="
  for config in "${configs[@]}"; do
    build_config "$config"
    if [ $? -ne 0 ]; then
      log_error "构建失败，终止测试"
      exit 1
    fi
  done
  
  # 测试阶段
  log_info "=== 测试阶段 ==="
  for config in "${configs[@]}"; do
    for test in "${tests[@]}"; do
      total_tests=$((total_tests + 1))
      run_test "$config" "$test"
      if [ $? -eq 0 ]; then
        passed_tests=$((passed_tests + 1))
      else
        failed_tests=$((failed_tests + 1))
      fi
    done
  done
  
  # 总结
  log_info "=== 测试总结 ==="
  log_info "总测试数: $total_tests"
  log_success "通过: $passed_tests"
  if [ $failed_tests -gt 0 ]; then
    log_error "失败: $failed_tests"
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
    --npu-test)
      TEST_SUITE="npu"
      ;;
    --meek-test)
      TEST_SUITE="meek"
      ;;
    --full-test)
      TEST_SUITE="full"
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
  log_error "请指定测试套件 (--npu-test, --meek-test, 或 --full-test)"
  help
fi

# 根据测试套件执行相应测试
case $TEST_SUITE in
  "npu")
    log_info "执行NPU测试套件"
    run_batch_test NPU_TESTS "${NPU_CONFIGS[@]}"
    ;;
  "meek")
    log_info "执行Meek测试套件"
    run_batch_test MEEK_TESTS "${MEEK_CONFIGS[@]}"
    ;;
  "full")
    log_info "执行全量测试套件"
    run_batch_test FULL_TESTS "${FULL_CONFIGS[@]}"
    ;;
  *)
    log_error "未知的测试套件: $TEST_SUITE"
    help
    ;;
esac 