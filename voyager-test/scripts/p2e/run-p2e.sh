#!/bin/bash

# P2E Build and Deploy Script
# This script provides direct SSH connection and file transfer

set -e

# Default values
SKIP_STEPS=0

# Help function
help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -s, --skip NUMBER    跳过前几步 (例如: -s 2 从第3步开始)"
  echo "  -h, --help           显示帮助信息"
  echo ""
  echo "Steps:"
  echo "  Step 1: Generate workload"
  echo "  Step 2: Sync Config (includes serial port configuration)"
  echo "  Step 3: SSH connection"
  echo "  Step 4: Setup Serial on remote server"
  echo "  Step 5: Running VDBG with integrated serial screen"
  exit 0
}

while [ $# -gt 0 ] ; do
  case $1 in
    -s|--skip)
      if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
        SKIP_STEPS="$2"
        shift
      else
        echo "错误: -s 或 --skip 选项需要一个数字参数"
        help
      fi
      ;;
    -h|--help)
      help
      ;;
    *)
      echo "未知选项: $1"
      help
      ;;
  esac
  shift
done


# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function with color support
Log() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

# Script directory
CYDIR=$(git rev-parse --show-toplevel)
SCRIPT_DIR=$CYDIR/voyager-test/scripts/p2e
CONFIG_FILE="$SCRIPT_DIR/p2e_config.yaml"
OUTPUT_DIR="$SCRIPT_DIR/../../output/p2e"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  Log "$RED" "Error: Configuration file not found: $CONFIG_FILE"
  exit 1
fi

# Function to parse nested YAML (simple parsing for our use case)
parse_yaml() {
  local key=$1
  grep "^[[:space:]]*$key:" "$CONFIG_FILE" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/'
}

# Read configuration from nested YAML
SSH_HOST=$(parse_yaml "host")
SSH_PORT=$(parse_yaml "port")
SSH_USER=$(parse_yaml "username")
SSH_PASSWORD=$(parse_yaml "password")
REMOTE_BASE=$(parse_yaml "remote_base")
FPGA_IP=$(parse_yaml "ip")
WORKLOAD=$(parse_yaml "workload_name")
SERIAL=$(parse_yaml "serial")

# Function to check if sshpass is installed
check_sshpass() {
  if ! command -v sshpass &> /dev/null; then
    Log "$YELLOW" "Warning: sshpass is not installed."
    Log "$YELLOW" "Installing sshpass..."
    
    # Try to install sshpass
    if command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install -y sshpass
    elif command -v yum &> /dev/null; then
      sudo yum install -y sshpass
    elif command -v brew &> /dev/null; then
      brew install sshpass
    else
      Log "$RED" "Error: Cannot install sshpass automatically. Please install it manually."
      Log "$YELLOW" "On Ubuntu/Debian: sudo apt-get install sshpass"
      Log "$YELLOW" "On CentOS/RHEL: sudo yum install sshpass"
      Log "$YELLOW" "On macOS: brew install sshpass"
      exit 1
    fi
  fi
}

# Function to test SSH connection
test_connection() {
  Log "$YELLOW" "Testing SSH connection..."
  
  if sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "echo 'Connection successful'" 2>/dev/null; then
    Log "$GREEN" "✓ SSH connection successful"
    return 0
  else
    Log "$RED" "✗ SSH connection failed"
    return 1
  fi
}

main() {
  # Step 1: Generate workload
  if [ $SKIP_STEPS -lt 1 ]; then
    Log "$BLUE" "====================== Step 1: Generate workload ======================"
    mkdir -p $OUTPUT_DIR/image
    cd $SCRIPT_DIR/../marshal
    Log "$YELLOW" "Generating workload..."
    ./marshal -v -d build $WORKLOAD.json  
    ./marshal -v -d install -t prototype $WORKLOAD.json
    cp ${CYDIR}/software/firemarshal/images/prototype/${WORKLOAD}/${WORKLOAD}-bin-nodisk $OUTPUT_DIR/image/
    cd $OUTPUT_DIR/image
    Log "$YELLOW" "Converting image to hex... (This may take a while)"
    python3 $SCRIPT_DIR/toolchain/elf2hex.py $OUTPUT_DIR/image/$WORKLOAD-bin-nodisk $OUTPUT_DIR/image/$WORKLOAD.hex --remap-to-zero 
  else
    Log "$YELLOW" "Step 1 skipped"
  fi

  # Step 2: Sync Config
  if [ $SKIP_STEPS -lt 2 ]; then
    Log "$BLUE" "====================== Step 2: Sync Config ======================"
    cd $SCRIPT_DIR/toolchain
    Log "$YELLOW" "Syncing FPGA IP ($FPGA_IP) to hw-config.hdf..."
    sed -i "s/\"IP\": \"[^\"]*\"/\"IP\": \"$FPGA_IP\"/g" hw-config.hdf
    Log "$YELLOW" "Setting workload name ($WORKLOAD) in debug_trigger.tcl"
    sed -i "s/-file [^.]*\.hex/-file ..\/image\/$WORKLOAD.hex/g" debug_trigger.tcl
    Log "$YELLOW" "Setting serial port ($SERIAL) in run_vdbg.exp"
    sed -i "s|send \"screen /dev/tty[0-9]*gpio 4800\\\\r\"|send \"screen $SERIAL 4800\\\\r\"|g" run_vdbg.exp
  else
    Log "$YELLOW" "Step 2 skipped"
  fi
  
  # Step 3: SSH connection and upload
  if [ $SKIP_STEPS -lt 3 ]; then
    Log "$BLUE" "====================== Step 3: SSH connection ======================"
    check_sshpass
    if ! test_connection; then
      Log "$RED" "Connection test failed. Please check your configuration."
      exit 1
    fi
    
    Log "$YELLOW" "Uploading files to remote server..."
    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "mkdir -p p2e && cd p2e && mkdir -p image"
    sshpass -p "$SSH_PASSWORD" scp -o StrictHostKeyChecking=no -P "$SSH_PORT" -r $SCRIPT_DIR/toolchain $SSH_USER@$SSH_HOST:$REMOTE_BASE/p2e
    echo "$OUTPUT_DIR/image/${WORKLOAD}.hex"
    sshpass -p "$SSH_PASSWORD" scp -o StrictHostKeyChecking=no -P "$SSH_PORT" ${OUTPUT_DIR}/image/${WORKLOAD}.hex $SSH_USER@$SSH_HOST:$REMOTE_BASE/p2e/image/${WORKLOAD}.hex
  else
    Log "$YELLOW" "Step 3 skipped"
  fi
  
  # Step 4: Setup Serial on remote server
  if [ $SKIP_STEPS -lt 4 ]; then
    Log "$BLUE" "====================== Step 4: Setup Serial on remote server ======================"
    Log "$YELLOW" "Modifying default_div in .design_info file..."
    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "cd $REMOTE_BASE/p2e/toolchain && sed -i 's/\"default_div\" : [0-9]*/\"default_div\" : 15/g' .design_info"
    Log "$GREEN" "✓ Set Baud Rate to 4800"
  else
    Log "$YELLOW" "Step 4 skipped"
  fi

  # Step 5: Running VDBG on remote server (in background)
  if [ $SKIP_STEPS -lt 5 ]; then
    Log "$BLUE" "====================== Step 5: Running VDBG on remote server (background) ======================"
    Log "$YELLOW" "Running VDBG with debug_trigger.tcl in background..."
    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no -t -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "cd $REMOTE_BASE/p2e/toolchain && source ./setup.sh && ./run_vdbg.exp"
  else
    Log "$YELLOW" "Step 5 skipped"
  fi
}

# Run main function
main
