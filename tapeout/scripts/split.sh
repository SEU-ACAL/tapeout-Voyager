#!/bin/bash
# 用法: bash split_verilog.sh input.v

input="$1"
if [ -z "$input" ]; then
  echo "请提供输入文件名"
  exit 1
fi

awk '
  # 匹配 module 行，提取模块名
  /^module[ \t]+([a-zA-Z0-9_]+)/ {
    if (in_module) {
      print "错误: 检测到嵌套module, 脚本不支持嵌套" > "/dev/stderr"
      exit 2
    }
    match($0, /^module[ \t]+([a-zA-Z0-9_]+)/, arr)
    modname = arr[1]
    out = modname ".v"
    in_module = 1
    print $0 > out
    next
  }
  # 处理 endmodule
  /^endmodule/ {
    if (in_module) {
      print $0 >> out
      close(out)
      in_module = 0
      next
    }
  }
  # module 内内容
  {
    if (in_module) {
      print $0 >> out
    }
  }
' "$input"