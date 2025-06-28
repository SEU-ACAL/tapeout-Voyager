import re
import sys

def process_file(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()

    # 插入 #include <meek.h>
    include_inserted = False
    new_lines = []
    for line in lines:
        if not include_inserted and re.match(r'#include\s+<stdio\.h>', line):
            new_lines.append(line)
            new_lines.append('#if defined(CHECK) && (CHECK == 1)\n')
            new_lines.append('#include <meek.h>\n')
            new_lines.append('#endif\n')
            include_inserted = True
        else:
            new_lines.append(line)

    # 处理 main 函数
    in_main = False
    brace_count = 0
    for i, line in enumerate(new_lines):
        # 检测 main 函数开始
        if not in_main and re.search(r'\bint\s+main\s*\(', line):
            in_main = True
            # 找到 main 的第一个 {
            while '{' not in new_lines[i]:
                i += 1
            brace_count = 1
            # 在 main 函数体开始后插入 rStartup
            insert_pos = i + 1
            new_lines.insert(insert_pos, '  #if defined(CHECK) && (CHECK == 1)\n  rStartup();\n  #endif\n')
            continue

        if in_main:
            brace_count += line.count('{')
            brace_count -= line.count('}')
            # 在 return 前插入 rCleanup
            if re.search(r'\breturn\b', line):
                indent = re.match(r'(\s*)', line).group(1)
                new_lines.insert(i, f'{indent}#if defined(CHECK) && (CHECK == 1)\n{indent}  rCleanup();\n{indent}#endif\n')
                break
            # main 结束
            if brace_count == 0:
                break

    with open(filename, 'w') as f:
        f.writelines(new_lines)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("用法: python3 add_check_macro.py <c文件路径>")
    else:
        process_file(sys.argv[1])