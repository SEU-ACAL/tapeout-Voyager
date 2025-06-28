#!/bin/bash

# P2E Build and Deploy Script
# This script provides direct SSH connection and file transfer

set -e

while [ $# -gt 0 ] ; do
  case $1 in
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

# Main execution
main() {
  # Step 1: Build bitstream
  Log "$BLUE" "====================== Step 1: Building bitstream ======================"
  cd $CYDIR/fpga
  make SUB_PROJECT=vcu118 CONFIG=$CONFIG bitstream || true
  mkdir -p $OUTPUT_DIR
  rm -rf $OUTPUT_DIR/gen-collateral
  cp -r $CYDIR/fpga/generated-src/chipyard.fpga.vcu118.VCU118FPGATestHarness.$CONFIG/gen-collateral $OUTPUT_DIR/
  
  # Step 2: integerate
  Log "$BLUE" "====================== Step 2: Integrating XEPIC ======================"
  # mkdir -p $OUTPUT_DIR/integerate
  cd $SCRIPT_DIR/toolchain
  ./integrate.sh 
  ./update_filelist.sh 
  

  # Step 3: Check if sshpass is available
  Log "$BLUE" "====================== Step 3: SSH connection ======================"
  check_sshpass
  if ! test_connection; then
    Log "$RED" "Connection test failed. Please check your configuration."
    exit 1
  fi
  
  Log "$YELLOW" "Uploading files to remote server..."
  sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "mkdir -p p2e && cd p2e && rm -rf "
  sshpass -p "$SSH_PASSWORD" scp -o StrictHostKeyChecking=no -P "$SSH_PORT" -r $OUTPUT_DIR $SSH_USER@$SSH_HOST:$REMOTE_BASE
  sshpass -p "$SSH_PASSWORD" scp -o StrictHostKeyChecking=no -P "$SSH_PORT" -r $SCRIPT_DIR/toolchain $SSH_USER@$SSH_HOST:$REMOTE_BASE/p2e
  
  # Step 4: Test connection first
  Log "$BLUE" "====================== Step 4: Compiling on remote server ======================"
  sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "source $REMOTE_BASE/p2e/toolchain/setup.sh && cd $REMOTE_BASE/p2e/toolchain && make vsyn && make vcom && make pnr"
  
  # # Start interactive SSH session
  # Log "$YELLOW" "Starting interactive SSH session..."
  # Log "$YELLOW" "Use 'exit' to return to local shell"
  # echo ""
  
  # sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no -p "$SSH_PORT" "$SSH_USER@$SSH_HOST"
  
  # Log "$GREEN" "SSH session ended."
}

# Run main function
main
