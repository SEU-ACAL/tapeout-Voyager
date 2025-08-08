#!/usr/bin/env python3
"""
修改TestHarness.sv中GPIO默认值的脚本
适用于CIRCT firtool生成的TestHarness.sv文件

使用方法:
python3 gpio_set.py <TestHarness.sv文件路径> [GPIO修改列表] [--remove-gpio 6,7,8]

示例:
python3 gpio_set.py ./TestHarness.sv 4:0 5:1
python3 gpio_set.py ./TestHarness.sv 4:0 5:1 --remove-gpio 6,7,8
"""

import re
import os
import sys

def modify_gpio_defaults(file_path, gpio_changes):
    """
    修改TestHarness.sv中GPIO的默认值
    
    Args:
        file_path: TestHarness.sv文件路径
        gpio_changes: 字典，格式为 {gpio_number: new_value}
    """
    
    if not os.path.exists(file_path):
        print(f"错误: 文件不存在: {file_path}")
        return False
    
    # 读取文件内容
    with open(file_path, 'r') as f:
        content = f.read()
    
    # 执行修改
    modified_count = 0
    for gpio_num, new_value in gpio_changes.items():
        # 修复正则表达式 - 正确匹配格式
        # 匹配模式：AnalogConst #( .CONST(<old_value>), .WIDTH(1) ) AnalogConst_<num>
        pattern = rf'(AnalogConst\s*#\(\s*\.CONST\()\d+(\),\s*\.WIDTH\(1\)\s*\)\s*AnalogConst_{gpio_num})'
        replacement = rf'\g<1>{new_value}\g<2>'
        
        if re.search(pattern, content, re.DOTALL):
            content = re.sub(pattern, replacement, content, flags=re.DOTALL)
            print(f"✓ 已修改GPIO{gpio_num}默认值为{new_value}")
            modified_count += 1
        else:
            print(f"⚠ 未找到GPIO{gpio_num}的AnalogConst_{gpio_num}定义")
            # 调试：打印匹配尝试
            print(f"  尝试匹配模式: {pattern}")
            # 查找包含AnalogConst_<num>的行
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if f'AnalogConst_{gpio_num}' in line:
                    print(f"  找到相关行 {i+1}: {line.strip()}")
    
    if modified_count == 0:
        print("⚠ 没有找到任何需要修改的GPIO定义")
        return False
    
    # 写回文件
    with open(file_path, 'w') as f:
        f.write(content)
    
    print(f"✓ 已成功修改文件: {file_path}")
    return True

def remove_gpio_modules(file_path, gpio_numbers):
    """
    删除指定GPIO的AnalogConst模块 - 使用精确字符串匹配
    """
    
    if not os.path.exists(file_path):
        print(f"错误: 文件不存在: {file_path}")
        return False
    
    # 读取文件内容
    with open(file_path, 'r') as f:
        content = f.read()
    
    # 执行删除
    removed_count = 0
    for gpio_num in gpio_numbers:
        # 精确匹配要删除的模块文本
        module_text = f"""  AnalogConst #(
    .CONST(1),
    .WIDTH(1)
  ) AnalogConst_{gpio_num} (	// @[generators/chipyard/src/main/scala/iocell/Analog.scala:17:49]
    .io (_gpio_0_{gpio_num}_wire)
  );	// @[generators/chipyard/src/main/scala/iocell/Analog.scala:17:49]"""
        
        if module_text in content:
            content = content.replace(module_text, '')
            print(f"✓ 已删除GPIO{gpio_num}的AnalogConst模块")
            removed_count += 1
        else:
            print(f"⚠ 未找到GPIO{gpio_num}的AnalogConst模块")
            # 调试：查找包含AnalogConst_<num>的行
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if f'AnalogConst_{gpio_num}' in line:
                    print(f"  找到相关行 {i+1}: {line.strip()}")
    
    if removed_count == 0:
        print("⚠ 没有找到任何需要删除的GPIO模块")
        return False
    
    # 写回文件
    with open(file_path, 'w') as f:
        f.write(content)
    
    print(f"✓ 已成功删除{removed_count}个GPIO模块")
    return True

def parse_arguments():
    """解析命令行参数"""
    if len(sys.argv) < 2:
        return None, {}, []
    
    file_path = sys.argv[1]
    gpio_changes = {}
    remove_gpio_numbers = []
    
    i = 2
    while i < len(sys.argv):
        arg = sys.argv[i]
        
        if arg == '--remove-gpio':
            if i + 1 < len(sys.argv):
                try:
                    gpio_list = sys.argv[i + 1].split(',')
                    remove_gpio_numbers = [int(x.strip()) for x in gpio_list]
                    i += 2  # 跳过--remove-gpio和它的参数
                except ValueError:
                    print(f"警告: --remove-gpio参数格式错误: {sys.argv[i + 1]}")
                    i += 2
            else:
                print("警告: --remove-gpio缺少参数")
                i += 1
        elif ':' in arg:
            # GPIO修改参数
            try:
                gpio_num, value = arg.split(':')
                gpio_num = int(gpio_num)
                value = int(value)
                if value in [0, 1]:
                    gpio_changes[gpio_num] = value
                else:
                    print(f"警告: GPIO值必须是0或1，跳过 {arg}")
            except ValueError:
                print(f"警告: GPIO参数格式错误，跳过 {arg}")
            i += 1
        else:
            print(f"警告: 未知参数，跳过 {arg}")
            i += 1
    
    return file_path, gpio_changes, remove_gpio_numbers

def main():
    """主函数"""
    file_path, gpio_changes, remove_gpio_numbers = parse_arguments()
    
    if not file_path:
        print("使用方法: python3 gpio_set.py <TestHarness.sv文件路径> [GPIO修改列表] [--remove-gpio 6,7,8]")
        print("示例: python3 gpio_set.py ./TestHarness.sv 4:0 5:1")
        print("示例: python3 gpio_set.py ./TestHarness.sv 4:0 5:1 --remove-gpio 6,7,8")
        return False
    
    # 如果没有指定GPIO修改，使用默认值
    if not gpio_changes and not remove_gpio_numbers:
        gpio_changes = {4: 0, 5: 1}
        print("使用默认GPIO修改设置")
    
    print("GPIO默认值修改脚本")
    print("=" * 50)
    print(f"文件路径: {file_path}")
    
    success = True
    
    # 执行GPIO值修改
    if gpio_changes:
        print("修改内容:")
        for gpio_num, value in gpio_changes.items():
            print(f"  - GPIO{gpio_num}: 设置为{value}")
        print()
        
        success &= modify_gpio_defaults(file_path, gpio_changes)
    
    # 执行GPIO模块删除
    if remove_gpio_numbers:
        print("删除内容:")
        for gpio_num in remove_gpio_numbers:
            print(f"  - 删除GPIO{gpio_num}的AnalogConst模块")
        print()
        
        success &= remove_gpio_modules(file_path, remove_gpio_numbers)
    
    if success:
        print("\n所有操作完成！")
    else:
        print("\n部分操作失败！")
    
    return success

if __name__ == "__main__":
    main()
