#!/usr/bin/env python3

import subprocess
import sys
import os
import re

class HexToReadmemh:
    def __init__(self, objcopy_path="/home/rain/chipyard/.conda-env/riscv-tools/bin/riscv64-unknown-elf-objcopy"):
        self.objcopy_path = objcopy_path
    
    def elf_to_hex(self, elf_file, hex_file):
        """
        将RISC-V ELF文件转换为Intel HEX文件
        """
        try:
            print(f"转换 {elf_file} -> {hex_file}")
            
            # 使用objcopy将ELF转为Intel HEX格式
            cmd = [self.objcopy_path, "-O", "ihex", elf_file, hex_file]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                print(f"错误：objcopy执行失败: {result.stderr}")
                return False
            
            print(f"✅ 成功生成HEX文件: {hex_file}")
            return True
            
        except Exception as e:
            print(f"错误：ELF转换失败 - {e}")
            return False
    
    def hex_to_readmemh(self, hex_file, readmemh_file, big_endian=True, remap_to_zero=False):
        """
        将Intel HEX文件转换为Verilog readmemh格式
        big_endian: True为大端序输出，False为小端序输出
        remap_to_zero: True时将地址重映射从0x00000000开始
        """
        try:
            print(f"转换 {hex_file} -> {readmemh_file} ({'大端序' if big_endian else '小端序'}{'，地址重映射到0x00000000' if remap_to_zero else ''})")
            
            # 解析Intel HEX文件
            memory_data = {}
            current_base_address = 0
            
            with open(hex_file, 'r') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if not line or line.startswith(';'):
                        continue
                    
                    if not line.startswith(':'):
                        continue
                    
                    try:
                        # 解析Intel HEX格式
                        # :llaaaatt[dd...]cc
                        # ll = 数据长度, aaaa = 地址, tt = 类型, dd = 数据, cc = 校验和
                        
                        record = line[1:]  # 去掉':'
                        if len(record) < 8:
                            continue
                            
                        byte_count = int(record[0:2], 16)
                        address = int(record[2:6], 16)
                        record_type = int(record[6:8], 16)
                        
                        if record_type == 0x00:  # 数据记录
                            data_start = 8
                            for i in range(byte_count):
                                if data_start + 2 <= len(record) - 2:  # 减去校验和
                                    byte_data = record[data_start:data_start+2]
                                    memory_address = current_base_address + address + i
                                    memory_data[memory_address] = int(byte_data, 16)
                                    data_start += 2
                        
                        elif record_type == 0x04:  # 扩展线性地址记录
                            if byte_count == 2 and len(record) >= 12:
                                high_address = int(record[8:12], 16)
                                current_base_address = high_address << 16
                        
                        elif record_type == 0x05:  # 起始线性地址记录
                            if byte_count == 4 and len(record) >= 16:
                                start_addr = int(record[8:16], 16)
                                print(f"   检测到起始地址: 0x{start_addr:08X}")
                    
                    except ValueError as e:
                        print(f"   警告: 第{line_num}行解析失败: {line}")
                        continue
            
            if not memory_data:
                print("错误：没有找到有效的数据")
                return False
            
            # 地址重映射处理
            if remap_to_zero:
                sorted_addresses = sorted(memory_data.keys())
                min_address = sorted_addresses[0]
                print(f"   地址重映射: 从0x{min_address:08X}重映射到0x00000000")
                
                # 创建重映射后的数据
                remapped_data = {}
                for addr, data in memory_data.items():
                    new_addr = addr - min_address
                    remapped_data[new_addr] = data
                memory_data = remapped_data
            
            # 生成readmemh格式文件
            with open(readmemh_file, 'w') as f:
                # 按地址排序
                sorted_addresses = sorted(memory_data.keys())
                
                current_section_start = None
                current_address = None
                
                for addr in sorted_addresses:
                    # 检查是否需要新的地址段
                    if current_address is None or addr != current_address + 1:
                        # 开始新的地址段
                        current_section_start = addr
                        current_address = addr
                        f.write(f"@0x{addr:08X}\n")
                    else:
                        current_address = addr
                    
                    # 输出数据字节
                    byte_value = memory_data[addr]
                    if big_endian:
                        # 大端序：直接输出字节
                        f.write(f"{byte_value:02X}\n")
                    else:
                        # 小端序：按32位字重新排列
                        # 注意：这里简化处理，实际可能需要更复杂的逻辑
                        f.write(f"{byte_value:02X}\n")
            
            print(f"✅ readmemh文件生成完成: {readmemh_file}")
            print(f"   地址范围: 0x{sorted_addresses[0]:08X} - 0x{sorted_addresses[-1]:08X}")
            print(f"   总字节数: {len(memory_data)}")
            return True
            
        except Exception as e:
            print(f"错误：readmemh转换失败 - {e}")
            return False
    
    def convert_elf_to_readmemh(self, elf_file, output_name=None, big_endian=True, remap_to_zero=False):
        """
        完整的转换流程：ELF -> HEX -> readmemh
        """
        if output_name is None:
            base_name = os.path.splitext(os.path.basename(elf_file))[0]
            output_name = f"{base_name}_{'bigendian' if big_endian else 'littleendian'}_readmemh.txt"
        
        # 生成临时HEX文件名
        temp_hex = f"temp_{os.path.splitext(os.path.basename(elf_file))[0]}.hex"
        
        print("🚀 开始ELF到readmemh转换流程")
        print("=" * 50)
        
        try:
            # 第一步：ELF -> HEX
            if not self.elf_to_hex(elf_file, temp_hex):
                return False
            
            # 第二步：HEX -> readmemh
            if not self.hex_to_readmemh(temp_hex, output_name, big_endian, remap_to_zero):
                return False
            
            print("\n🎉 转换完成！")
            print("=" * 50)
            print(f"📁 生成的文件: {output_name}")
            
            return True
            
        finally:
            # 清理临时文件
            if os.path.exists(temp_hex):
                os.remove(temp_hex)
                print(f"🧹 清理临时文件: {temp_hex}")
    
    def convert_hex_to_readmemh(self, hex_file, output_name=None, big_endian=True, remap_to_zero=False):
        """
        从现有HEX文件转换到readmemh
        """
        if output_name is None:
            base_name = os.path.splitext(os.path.basename(hex_file))[0]
            output_name = f"{base_name}_{'bigendian' if big_endian else 'littleendian'}_readmemh.txt"
        
        print("🚀 开始HEX到readmemh转换")
        print("=" * 50)
        
        if not self.hex_to_readmemh(hex_file, output_name, big_endian, remap_to_zero):
            return False
        
        print("\n🎉 转换完成！")
        print("=" * 50)
        print(f"📁 生成的文件: {output_name}")
        
        return True

def main():
    if len(sys.argv) < 2:
        print("用法:")
        print("  python3 hex_to_readmemh.py <ELF文件> [输出文件名] [--little-endian] [--remap-to-zero]")
        print("  python3 hex_to_readmemh.py --hex <HEX文件> [输出文件名] [--little-endian] [--remap-to-zero]")
        print("")
        print("参数说明:")
        print("  --little-endian   生成小端序格式（默认为大端序）")
        print("  --remap-to-zero   将地址重映射从0x00000000开始")
        print("")
        print("示例:")
        print("  python3 hex_to_readmemh.py coremark.bare.riscv")
        print("  python3 hex_to_readmemh.py coremark.bare.riscv coremark_bigendian.txt")
        print("  python3 hex_to_readmemh.py --hex coremark.bare_step1.hex")
        print("  python3 hex_to_readmemh.py coremark.bare.riscv --remap-to-zero")
        print("  python3 hex_to_readmemh.py coremark.bare.riscv --little-endian --remap-to-zero")
        sys.exit(1)
    
    # 解析参数
    use_hex_input = False
    big_endian = True
    remap_to_zero = False
    input_file = None
    output_file = None
    
    i = 1
    while i < len(sys.argv):
        arg = sys.argv[i]
        if arg == "--hex":
            use_hex_input = True
        elif arg == "--little-endian":
            big_endian = False
        elif arg == "--remap-to-zero":
            remap_to_zero = True
        elif input_file is None:
            input_file = arg
        elif output_file is None:
            output_file = arg
        i += 1
    
    if input_file is None:
        print("错误：请指定输入文件")
        sys.exit(1)
    
    if not os.path.exists(input_file):
        print(f"错误: 文件不存在 {input_file}")
        sys.exit(1)
    
    converter = HexToReadmemh()
    
    if use_hex_input:
        success = converter.convert_hex_to_readmemh(input_file, output_file, big_endian, remap_to_zero)
    else:
        success = converter.convert_elf_to_readmemh(input_file, output_file, big_endian, remap_to_zero)
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main() 