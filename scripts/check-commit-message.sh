#!/usr/bin/env bash

# 读取commit message文件（第一个参数是commit message文件路径）
commit_msg_file="$1"

if [[ -f "$commit_msg_file" ]]; then
  commit_msg=$(cat "$commit_msg_file")
  
  if [[ -n "$commit_msg" ]]; then
    if ! (echo "$commit_msg" | grep -q "need test:"); then
      echo "[ERROR] Commit message must contain 'need test:' field"
      echo "Current commit message:"
      echo "$commit_msg"
      echo ""
      echo "Please use format: XXXXXXXXX(your commit message) need test: [verilator-test] [p2e-test-with-rebuild] [p2e-test-wo-rebuild]"
      exit 1
    fi
  fi
fi

exit 0 