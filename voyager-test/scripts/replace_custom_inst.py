#!/usr/bin/env python3
import re
import sys

def decode_r_type_instruction(opcode_hex):
  """解析R型指令格式: funct7[31:25] rs2[24:20] rs1[19:15] funct3[14:12] rd[11:7] opcode[6:0]"""
  opcode = int(opcode_hex, 16)
  
  # 提取各个字段
  opcode_field = opcode & 0x7F  # bits [6:0]
  rd = (opcode >> 7) & 0x1F   # bits [11:7]
  funct3 = (opcode >> 12) & 0x7  # bits [14:12]
  rs1 = (opcode >> 15) & 0x1F  # bits [19:15]
  rs2 = (opcode >> 20) & 0x1F  # bits [24:20]
  funct7 = (opcode >> 25) & 0x7F # bits [31:25]
  
  return {
    'opcode': opcode_field,
    'rd': rd,
    'funct3': funct3,
    'rs1': rs1,
    'rs2': rs2,
    'funct7': funct7
  }

def get_register_name(reg_num):
  """获取RISC-V寄存器名称"""
  reg_names = {
    0: 'zero', 1: 'ra', 2: 'sp', 3: 'gp', 4: 'tp',
    5: 't0', 6: 't1', 7: 't2', 8: 's0', 9: 's1',
    10: 'a0', 11: 'a1', 12: 'a2', 13: 'a3', 14: 'a4', 15: 'a5',
    16: 'a6', 17: 'a7', 18: 's2', 19: 's3', 20: 's4', 21: 's5',
    22: 's6', 23: 's7', 24: 's8', 25: 's9', 26: 's10', 27: 's11',
    28: 't3', 29: 't4', 30: 't5', 31: 't6'
  }
  return reg_names.get(reg_num, f'x{reg_num}')

def get_instruction_info(funct7, funct3, opcode):
  """根据funct7识别Buckyball指令并返回指令信息"""
  if opcode == 0x7B:  # CUSTOM_3
    instruction_map = {
      24: ('bb_mvin', 'move_in'),    # BB_MVIN_FUNCT
      25: ('bb_mvout', 'move_out'),    # BB_MVOUT_FUNCT  
      34: ('bb_scatter_mvin', 'scatter_move_in'),  # BB_SCATTER_MVIN_FUNCT
      33: ('bb_sparse_mul_addr', 'sparse_mul')   # BB_SPARSE_MUL_ADDR_FUNCT
    }
    if funct7 in instruction_map:
      return instruction_map[funct7]
    else:
      return (f'bb_unknown_f{funct7}', 'unknown')
  return (f'unknown_opcode_{opcode:02x}', 'unknown')

def format_buckyball_instruction(instr_name, rs1, rs2, rd=0):
  """格式化Buckyball指令为更易读的形式"""
  rs1_name = get_register_name(rs1)
  rs2_name = get_register_name(rs2)
  
  # 根据指令类型格式化
  if 'mvin' in instr_name:
    return f"{instr_name:<20} {rs1_name}, {rs2_name}  # Move data: addr={rs1_name}, config={rs2_name}"
  elif 'mvout' in instr_name:
    return f"{instr_name:<20} {rs1_name}, {rs2_name}  # Move out: addr={rs1_name}, config={rs2_name}"
  elif 'sparse_mul' in instr_name:
    return f"{instr_name:<20} {rs1_name}, {rs2_name}  # Sparse multiply: config1={rs1_name}, config2={rs2_name}"
  else:
    return f"{instr_name:<20} {rs1_name}, {rs2_name}  # Custom instruction"

def replace_custom_instructions(input_filename, output_filename):
  """替换反汇编文件中的自定义指令"""
  
  # 自定义指令的模式
  insn_pattern = re.compile(r'(\s+)([0-9a-f]+):\s+([0-9a-f]{8})\s+\.insn\s+4,\s+0x([0-9a-f]+)')
  
  replaced_count = 0
  
  print(f"正在处理文件: {input_filename}")
  print(f"输出文件: {output_filename}")
  print("-" * 60)
  
  with open(input_filename, 'r') as infile, open(output_filename, 'w') as outfile:
    for line_num, line in enumerate(infile, 1):
      match = insn_pattern.search(line)
      
      if match:
        indent, addr, machine_code, opcode_hex = match.groups()
        
        # 解析指令
        try:
          decoded = decode_r_type_instruction(opcode_hex)
          instr_name, instr_type = get_instruction_info(decoded['funct7'], decoded['funct3'], decoded['opcode'])
          
          # 格式化新的指令行
          formatted_instr = format_buckyball_instruction(instr_name, decoded['rs1'], decoded['rs2'], decoded['rd'])
          
          # 构造新的行
          new_line = f"{indent}{addr}:\t{machine_code}\t{formatted_instr}\n"
          
          # 输出替换信息
          print(f"地址 0x{addr}: {instr_name} {get_register_name(decoded['rs1'])}, {get_register_name(decoded['rs2'])}")
          
          outfile.write(new_line)
          replaced_count += 1
          
        except Exception as e:
          print(f"警告: 无法解析指令 0x{opcode_hex} 在行 {line_num}: {e}")
          outfile.write(line)  # 保留原行
      else:
        # 非自定义指令，直接写入
        outfile.write(line)
  
  print("-" * 60)
  print(f"处理完成! 共替换了 {replaced_count} 条自定义指令")
  print(f"新文件已保存为: {output_filename}")

def main():
  if len(sys.argv) < 2:
    print("用法: python3 replace_instructions.py <input_file> [output_file]")
    print("示例: python3 replace_instructions.py log.txt log_decoded.txt")
    sys.exit(1)
  
  input_file = sys.argv[1]
  
  # 如果没有指定输出文件，自动生成文件名
  if len(sys.argv) >= 3:
    output_file = sys.argv[2]
  else:
    if input_file.endswith('.txt'):
      output_file = input_file.replace('.txt', '_decoded.txt')
    else:
      output_file = input_file + '_decoded'
  
  try:
    replace_custom_instructions(input_file, output_file)
  except FileNotFoundError:
    print(f"错误: 找不到输入文件 '{input_file}'")
    sys.exit(1)
  except Exception as e:
    print(f"错误: {e}")
    sys.exit(1)

if __name__ == "__main__":
  main() 