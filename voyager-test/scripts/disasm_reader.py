#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
RISC-V Disassembly Visualizer Enhanced
将RISC-V反汇编文件转换为可视化HTML页面，支持寄存器依赖链分析

使用方法:
python riscv_disasm_visualizer_enhanced.py input.txt output.html
"""

import re
import sys
import argparse
from typing import List, Dict, Tuple, Optional, Set
from dataclasses import dataclass
from pathlib import Path

@dataclass
class RegisterDependency:
    """寄存器依赖类"""
    source_regs: List[str]  # 源寄存器
    dest_reg: Optional[str]  # 目标寄存器
    instruction_index: int  # 指令索引
    address: str  # 指令地址

@dataclass
class Instruction:
    """指令类"""
    address: str
    hex_code: str
    mnemonic: str
    comment: str = ""
    operands: List[str] = None  # 操作数列表
    source_regs: List[str] = None  # 源寄存器
    dest_reg: Optional[str] = None  # 目标寄存器
    
    def __post_init__(self):
        if self.operands is None:
            self.operands = []
        if self.source_regs is None:
            self.source_regs = []

@dataclass
class Function:
    """函数类"""
    name: str
    address: str
    instructions: List[Instruction]
    start_line: int
    end_line: int

class RISCVRegisterAnalyzer:
    """RISC-V寄存器分析器"""
    
    def __init__(self):
        # RISC-V寄存器映射
        self.register_aliases = {
            'zero': 'x0', 'ra': 'x1', 'sp': 'x2', 'gp': 'x3',
            't0': 'x5', 't1': 'x6', 't2': 'x7', 's0': 'x8', 'fp': 'x8',
            's1': 'x9', 'a0': 'x10', 'a1': 'x11', 'a2': 'x12', 'a3': 'x13',
            'a4': 'x14', 'a5': 'x15', 'a6': 'x16', 'a7': 'x17',
            's2': 'x18', 's3': 'x19', 's4': 'x20', 's5': 'x21',
            's6': 'x22', 's7': 'x23', 's8': 'x24', 's9': 'x25',
            's10': 'x26', 's11': 'x27', 't3': 'x28', 't4': 'x29',
            't5': 'x30', 't6': 'x31'
        }
        
        # 反向映射：从x0~x31转换回寄存器名字
        self.register_names = {
            'x0': 'zero', 'x1': 'ra', 'x2': 'sp', 'x3': 'gp', 'x4': 'tp',
            'x5': 't0', 'x6': 't1', 'x7': 't2', 'x8': 's0',
            'x9': 's1', 'x10': 'a0', 'x11': 'a1', 'x12': 'a2', 'x13': 'a3',
            'x14': 'a4', 'x15': 'a5', 'x16': 'a6', 'x17': 'a7',
            'x18': 's2', 'x19': 's3', 'x20': 's4', 'x21': 's5',
            'x22': 's6', 'x23': 's7', 'x24': 's8', 'x25': 's9',
            'x26': 's10', 'x27': 's11', 'x28': 't3', 'x29': 't4',
            'x30': 't5', 'x31': 't6'
        }
        
        # 指令类型模式
        self.instruction_patterns = {
            # R-type: op rd, rs1, rs2
            'r_type': re.compile(r'^(add|sub|sll|slt|sltu|xor|srl|sra|or|and|mul|mulh|mulhsu|mulhu|div|divu|rem|remu|addw|subw|sllw|srlw|sraw)\s+(\w+),\s*(\w+),\s*(\w+)'),
            # I-type: op rd, rs1, imm
            'i_type': re.compile(r'^(addi|slti|sltiu|xori|ori|andi|slli|srli|srai|lb|lh|lw|ld|lbu|lhu|lwu|jalr|addiw|slliw|srliw|sraiw)\s+(\w+),\s*(\w+),\s*([^,]+)'),
            # S-type: op rs2, offset(rs1)
            's_type': re.compile(r'^(sb|sh|sw|sd)\s+(\w+),\s*([^(]+)\((\w+)\)'),
            # B-type: op rs1, rs2, label
            'b_type': re.compile(r'^(beq|bne|blt|bge|bltu|bgeu)\s+(\w+),\s*(\w+),\s*([^,\s]+)'),
            # U-type: op rd, imm
            'u_type': re.compile(r'^(lui|auipc)\s+(\w+),\s*([^,\s]+)'),
            # J-type: op rd, label or jal label
            'j_type': re.compile(r'^(jal)\s+(?:(\w+),\s*)?([^,\s]+)'),
            # CSR instructions: csrrs rd, csr, rs1 或 csrrw rd, csr, rs1
            'csr_type': re.compile(r'^(csrrs|csrrw|csrrc)\s+(\w+),\s*(\w+),\s*(\w+)'),
            # Special load with offset
            'load_offset': re.compile(r'^(ld|lw|lh|lb|lbu|lhu|lwu)\s+(\w+),\s*([^(]+)\((\w+)\)'),
            # BB custom instructions: 任何bb_开头的指令, 2个操作数
            'bb_type': re.compile(r'^(bb_\w+)\s+(\w+),\s*(\w+)'),
            # Special cases
            'li': re.compile(r'^(li)\s+(\w+),\s*([^,\s]+)'),
            'mv': re.compile(r'^(mv)\s+(\w+),\s*(\w+)'),
            'compressed': re.compile(r'^c\.(\w+)'),
        }
    
    def normalize_register(self, reg: str) -> str:
        """标准化寄存器名"""
        reg = reg.strip()
        return self.register_aliases.get(reg, reg)
    
    def get_register_display_name(self, reg: str) -> str:
        """获取寄存器的显示名称（优先使用别名）"""
        if not reg:
            return reg
        return self.register_names.get(reg, reg)
    
    def parse_instruction(self, instruction: Instruction) -> Instruction:
        """解析指令的寄存器依赖"""
        mnemonic = instruction.mnemonic.strip()
        full_line = mnemonic
        
        
        # 移除注释部分
        if '#' in full_line:
            full_line = full_line.split('#')[0].strip()
        
        # 解析压缩指令
        if mnemonic.startswith('c.'):
            return self._parse_compressed_instruction(instruction, full_line)
        
        # 解析标准指令
        for inst_type, pattern in self.instruction_patterns.items():
            match = pattern.match(full_line)
            if match:
                return self._parse_standard_instruction(instruction, inst_type, match)
        
        return instruction
    
    def _parse_compressed_instruction(self, instruction: Instruction, mnemonic: str) -> Instruction:
        """解析压缩指令"""
        # 简化的压缩指令解析
        if 'c.li' in mnemonic:
            # c.li rd, imm or c.li rd,imm
            parts = mnemonic.replace(',', ' ').split()
            if len(parts) >= 3:
                reg = parts[1]
                instruction.dest_reg = self.normalize_register(reg)
        elif 'c.lui' in mnemonic:
            # c.lui rd, imm
            parts = mnemonic.replace(',', ' ').split()
            if len(parts) >= 3:
                reg = parts[1]
                instruction.dest_reg = self.normalize_register(reg)
        elif 'c.mv' in mnemonic:
            # c.mv rd, rs or c.mv rd,rs
            parts = mnemonic.replace(',', ' ').split()
            if len(parts) >= 3:
                dest = parts[1]
                src = parts[2]
                instruction.dest_reg = self.normalize_register(dest)
                instruction.source_regs = [self.normalize_register(src)]
        elif 'c.add' in mnemonic:
            # c.add rd, rs or c.add rd,rs
            parts = mnemonic.replace(',', ' ').split()
            if len(parts) >= 3:
                dest = parts[1]
                src = parts[2]
                instruction.dest_reg = self.normalize_register(dest)
                instruction.source_regs = [self.normalize_register(dest), self.normalize_register(src)]
        elif any(x in mnemonic for x in ['c.or', 'c.and', 'c.xor', 'c.sub', 'c.addw', 'c.subw']):
            # c.or rd, rs, c.and rd, rs, c.xor rd, rs, c.sub rd, rs, c.addw rd, rs, c.subw rd, rs
            # 这些都是双操作数指令，第一个操作数既是源寄存器也是目标寄存器
            parts = mnemonic.replace(',', ' ').split()
            if len(parts) >= 3:
                dest = parts[1]
                src = parts[2]
                instruction.dest_reg = self.normalize_register(dest)
                instruction.source_regs = [self.normalize_register(dest), self.normalize_register(src)]
        elif 'c.addi16sp' in mnemonic:
            # c.addi16sp sp, imm
            instruction.dest_reg = 'x2'  # sp
            instruction.source_regs = ['x2']  # sp
        elif 'c.addi4spn' in mnemonic:
            # c.addi4spn rd, sp, imm
            parts = mnemonic.split(',')
            if len(parts) >= 2:
                dest = parts[0].split()[-1]  # 获取目标寄存器
                instruction.dest_reg = self.normalize_register(dest)
                instruction.source_regs = ['x2']  # sp
        elif any(x in mnemonic for x in ['c.ld', 'c.lw', 'c.ldsp', 'c.lwsp']):
            # 加载指令
            parts = mnemonic.split()
            if len(parts) >= 2:
                dest = parts[1].rstrip(',')
                instruction.dest_reg = self.normalize_register(dest)
                if 'sp' in mnemonic:
                    instruction.source_regs = ['x2']  # sp
        elif any(x in mnemonic for x in ['c.sd', 'c.sw', 'c.sdsp', 'c.swsp']):
            # 存储指令
            parts = mnemonic.split()
            if len(parts) >= 2:
                src = parts[1].rstrip(',')
                instruction.source_regs = [self.normalize_register(src)]
                if 'sp' in mnemonic:
                    instruction.source_regs.append('x2')  # sp
        elif 'c.beqz' in mnemonic:
            # c.beqz rs, label
            parts = mnemonic.split()
            if len(parts) >= 2:
                src = parts[1].rstrip(',')
                instruction.source_regs = [self.normalize_register(src)]
        elif 'c.addi' in mnemonic:
            # c.addi rd, imm
            parts = mnemonic.split()
            if len(parts) >= 2:
                reg = parts[1].rstrip(',')
                instruction.dest_reg = self.normalize_register(reg)
                instruction.source_regs = [self.normalize_register(reg)]
        elif 'c.addiw' in mnemonic:
            # c.addiw rd, imm  
            parts = mnemonic.replace(',', ' ').split()
            if len(parts) >= 3:
                reg = parts[1]
                instruction.dest_reg = self.normalize_register(reg)
                instruction.source_regs = [self.normalize_register(reg)]
        elif 'c.slli' in mnemonic:
            # c.slli rd, imm
            parts = mnemonic.split()
            if len(parts) >= 2:
                reg = parts[1].rstrip(',')
                instruction.dest_reg = self.normalize_register(reg)
                instruction.source_regs = [self.normalize_register(reg)]
        
        return instruction
    
    def _parse_standard_instruction(self, instruction: Instruction, inst_type: str, match) -> Instruction:
        """解析标准指令"""
        groups = match.groups()
        
        if inst_type == 'r_type':
            # op rd, rs1, rs2
            instruction.dest_reg = self.normalize_register(groups[1])
            instruction.source_regs = [
                self.normalize_register(groups[2]),
                self.normalize_register(groups[3])
            ]
        elif inst_type == 'i_type':
            # op rd, rs1, imm
            instruction.dest_reg = self.normalize_register(groups[1])
            instruction.source_regs = [self.normalize_register(groups[2])]
        elif inst_type == 's_type':
            # op rs2, offset(rs1)
            instruction.source_regs = [
                self.normalize_register(groups[1]),  # rs2
                self.normalize_register(groups[3])   # rs1
            ]
        elif inst_type == 'load_offset':
            # ld rd, offset(rs1)
            instruction.dest_reg = self.normalize_register(groups[1])
            instruction.source_regs = [self.normalize_register(groups[3])]
        elif inst_type == 'b_type':
            # op rs1, rs2, label
            instruction.source_regs = [
                self.normalize_register(groups[1]),
                self.normalize_register(groups[2])
            ]
        elif inst_type == 'u_type':
            # op rd, imm
            instruction.dest_reg = self.normalize_register(groups[1])
        elif inst_type == 'j_type':
            # jal [rd,] label
            if groups[1]:  # 有目标寄存器
                instruction.dest_reg = self.normalize_register(groups[1])
            else:  # 默认是ra寄存器
                instruction.dest_reg = 'x1'  # ra
        elif inst_type == 'li':
            # li rd, imm
            instruction.dest_reg = self.normalize_register(groups[1])
        elif inst_type == 'mv':
            # mv rd, rs
            instruction.dest_reg = self.normalize_register(groups[1])
            instruction.source_regs = [self.normalize_register(groups[2])]
        elif inst_type == 'bb_type':
            # bb_* rs1, rs2 (目标寄存器为x0被省略，两个操作数都是源寄存器)
            instruction.dest_reg = 'x0'  # 隐含的目标寄存器x0
            instruction.source_regs = [
                self.normalize_register(groups[1]),  # 第一个源寄存器
                self.normalize_register(groups[2])   # 第二个源寄存器
            ]
        elif inst_type == 'csr_type':
            # CSR指令: csrrs rd, csr, rs1
            rd = groups[1]
            rs1 = groups[3]
            if rd != 'zero':  # 如果目标寄存器不是zero，则写入目标寄存器
                instruction.dest_reg = self.normalize_register(rd)
            if rs1 != 'zero':  # 如果源寄存器不是zero，则读取源寄存器
                instruction.source_regs = [self.normalize_register(rs1)]
        
        return instruction
    
    def analyze_dependencies(self, instructions: List[Instruction]) -> Dict[int, Dict]:
        """分析指令间的寄存器依赖关系，返回树状依赖结构"""
        immediate_deps = {}  # 直接依赖
        register_writers = {}  # 记录每个寄存器的最后写入指令
        
        # 第一步：建立直接依赖关系
        for i, inst in enumerate(instructions):
            immediate_deps[i] = []
            
            # 查找读取依赖 (RAW - Read After Write)
            # 对于每个源寄存器，找到最近的写入它的指令
            for src_reg in inst.source_regs:
                if src_reg and src_reg != 'x0':  # x0寄存器总是0，不需要依赖
                    if src_reg in register_writers:
                        writer_idx = register_writers[src_reg]
                        if writer_idx not in immediate_deps[i]:
                            immediate_deps[i].append(writer_idx)
            
            # 更新寄存器写入记录
            if inst.dest_reg and inst.dest_reg != 'x0':  # x0不能被写入
                register_writers[inst.dest_reg] = i
        
        # 第二步：构建树状依赖结构
        tree_dependencies = {}
        for i in range(len(instructions)):
            tree_dependencies[i] = self._build_dependency_tree(i, immediate_deps, set())
        
        return tree_dependencies
    
    def _build_dependency_tree(self, inst_index: int, immediate_deps: Dict[int, List[int]], visited: set) -> Dict:
        """递归构建依赖树结构"""
        if inst_index in visited:
            return {}  # 避免循环依赖
        
        visited.add(inst_index)
        tree = {}
        
        # 获取直接依赖
        direct_deps = immediate_deps.get(inst_index, [])
        
        for dep_index in direct_deps:
            # 递归构建子树
            subtree = self._build_dependency_tree(dep_index, immediate_deps, visited.copy())
            tree[dep_index] = subtree
        
        return tree
    
    def _get_full_dependency_chain(self, inst_index: int, immediate_deps: Dict[int, List[int]], visited: set) -> List[int]:
        """递归获取完整的依赖链（保留用于兼容性）"""
        if inst_index in visited:
            return []  # 避免循环依赖
        
        visited.add(inst_index)
        full_chain = []
        
        # 获取直接依赖
        direct_deps = immediate_deps.get(inst_index, [])
        
        for dep_index in direct_deps:
            # 添加直接依赖
            if dep_index not in full_chain:
                full_chain.append(dep_index)
            
            # 递归获取间接依赖
            indirect_deps = self._get_full_dependency_chain(dep_index, immediate_deps, visited.copy())
            for indirect_dep in indirect_deps:
                if indirect_dep not in full_chain:
                    full_chain.append(indirect_dep)
        
        # 按指令索引排序，显示依赖链的顺序
        full_chain.sort()
        return full_chain

class RISCVDisasmParser:
    """RISC-V反汇编解析器"""
    
    def __init__(self):
        # 正则表达式模式
        self.function_pattern = re.compile(r'^([0-9a-f]+)\s+<([^>]+)>:')
        self.instruction_pattern = re.compile(r'^\s*([0-9a-f]+):\s+([0-9a-f\s]+)\s+(.+)$')
        self.section_pattern = re.compile(r'^Disassembly of section (.+):')
        self.analyzer = RISCVRegisterAnalyzer()
        
    def parse_file(self, file_path: str) -> Dict:
        """解析反汇编文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except UnicodeDecodeError:
            with open(file_path, 'r', encoding='gb2312') as f:
                lines = f.readlines()
        
        result = {
            'header': '',
            'sections': [],
            'functions': [],
            'total_instructions': 0
        }
        
        current_function = None
        current_section = None
        line_num = 0
        
        for i, line in enumerate(lines):
            line = line.rstrip()
            line_num = i + 1
            
            # 解析文件头
            if i < 5 and ('file format' in line or 'Disassembly' not in line):
                result['header'] += line + '\n'
                continue
            
            # 解析段信息
            section_match = self.section_pattern.match(line)
            if section_match:
                current_section = section_match.group(1)
                result['sections'].append(current_section)
                continue
            
            # 解析函数
            func_match = self.function_pattern.match(line)
            if func_match:
                # 保存之前的函数
                if current_function:
                    current_function.end_line = line_num - 1
                    # 分析寄存器依赖
                    self._analyze_function_dependencies(current_function)
                    result['functions'].append(current_function)
                
                # 开始新函数
                address = func_match.group(1)
                name = func_match.group(2)
                current_function = Function(
                    name=name,
                    address=address,
                    instructions=[],
                    start_line=line_num,
                    end_line=line_num
                )
                continue
            
            # 解析指令
            inst_match = self.instruction_pattern.match(line)
            if inst_match and current_function:
                address = inst_match.group(1)
                hex_code = inst_match.group(2).strip()
                mnemonic_comment = inst_match.group(3)
                
                # 分离助记符和注释
                if '\t' in mnemonic_comment:
                    parts = mnemonic_comment.split('\t', 1)
                    instruction_part = parts[0].strip()  # 指令部分（助记符）
                    operands_comment = parts[1].strip()  # 操作数和注释部分
                    
                    # 检查操作数部分是否有 # 注释
                    if '#' in operands_comment:
                        operand_parts = operands_comment.split('#', 1)
                        operands = operand_parts[0].strip()
                        comment = '#' + operand_parts[1].strip()
                        mnemonic = f"{instruction_part} {operands}".strip()
                    else:
                        # 没有注释，全部是操作数
                        mnemonic = f"{instruction_part} {operands_comment}".strip()
                        comment = ""
                else:
                    # 检查是否有 # 注释符号
                    if '#' in mnemonic_comment:
                        parts = mnemonic_comment.split('#', 1)
                        mnemonic = parts[0].strip()
                        comment = '#' + parts[1].strip()
                    else:
                        mnemonic = mnemonic_comment.strip()
                        comment = ""
                
                
                instruction = Instruction(
                    address=address,
                    hex_code=hex_code,
                    mnemonic=mnemonic,
                    comment=comment
                )
                
                # 解析寄存器依赖
                instruction = self.analyzer.parse_instruction(instruction)
                
                current_function.instructions.append(instruction)
                result['total_instructions'] += 1
        
        # 保存最后一个函数
        if current_function:
            current_function.end_line = line_num
            self._analyze_function_dependencies(current_function)
            result['functions'].append(current_function)
        
        return result
    
    def _analyze_function_dependencies(self, function: Function):
        """分析函数内的寄存器依赖关系"""
        dependencies = self.analyzer.analyze_dependencies(function.instructions)
        # 将依赖信息存储到函数中（可以扩展为更复杂的数据结构）
        function.dependencies = dependencies
    
    def analyze_global_dependencies(self, functions: List[Function]) -> Dict[int, Dict]:
        """分析全局的寄存器依赖关系"""
        # 收集所有指令
        all_instructions = []
        for func in functions:
            all_instructions.extend(func.instructions)
        
        # 分析全局依赖
        return self.analyzer.analyze_dependencies(all_instructions)

class HTMLGenerator:
    """HTML生成器"""
    
    def __init__(self):
        self.css_template = """
        <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
            background-color: #1e1e1e;
            color: #d4d4d4;
            line-height: 1.4;
        }
        
        .header {
            background-color: #2d2d30;
            padding: 20px;
            border-bottom: 2px solid #007acc;
        }
        
        .title {
            font-size: 24px;
            color: #007acc;
            margin-bottom: 10px;
        }
        
        .file-info {
            background-color: #252526;
            padding: 10px;
            border-radius: 4px;
            white-space: pre-wrap;
            font-size: 12px;
            color: #cccccc;
        }
        
        .controls {
            background-color: #2d2d30;
            padding: 15px 20px;
            border-bottom: 1px solid #3c3c3c;
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .search-box {
            background-color: #3c3c3c;
            border: 1px solid #464647;
            padding: 6px 10px;
            color: #cccccc;
            border-radius: 3px;
            font-family: inherit;
            min-width: 200px;
        }
        
        .search-box:focus {
            outline: none;
            border-color: #007acc;
        }
        
        .btn {
            background-color: #0e639c;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 3px;
            cursor: pointer;
            font-family: inherit;
            font-size: 12px;
        }
        
        .btn:hover {
            background-color: #1177bb;
        }
        
        .stats {
            color: #cccccc;
            font-size: 12px;
        }
        
        .container {
            display: flex;
            height: calc(100vh - 140px);
        }
        
        .sidebar {
            width: 300px;
            background-color: #252526;
            border-right: 1px solid #3c3c3c;
            overflow-y: auto;
        }
        
        .function-list {
            padding: 10px;
        }
        
        .function-item {
            padding: 8px 12px;
            cursor: pointer;
            border-radius: 3px;
            margin-bottom: 2px;
            border-left: 3px solid transparent;
        }
        
        .function-item:hover {
            background-color: #2a2d2e;
        }
        
        .function-item.active {
            background-color: #094771;
            border-left-color: #007acc;
        }
        
        .function-name {
            font-weight: bold;
            font-size: 13px;
            color: #dcdcaa;
        }
        
        .function-addr {
            font-size: 11px;
            color: #888888;
            margin-top: 2px;
        }
        
        .function-stats {
            font-size: 10px;
            color: #608b4e;
            margin-top: 2px;
        }
        
        .main-content {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
        }
        
        .function-block {
            margin-bottom: 30px;
            background-color: #252526;
            border-radius: 6px;
            border: 1px solid #3c3c3c;
        }
        
        .function-header {
            background-color: #2d2d30;
            padding: 12px 16px;
            border-bottom: 1px solid #3c3c3c;
            border-radius: 6px 6px 0 0;
        }
        
        .function-title {
            font-size: 16px;
            font-weight: bold;
            color: #dcdcaa;
        }
        
        .function-address {
            font-size: 12px;
            color: #888888;
            margin-left: 10px;
        }
        
        .instructions {
            padding: 0;
        }
        
        .instruction {
            display: flex;
            padding: 6px 16px;
            border-bottom: 1px solid #2d2d30;
            font-size: 13px;
            line-height: 1.5;
            position: relative;
            cursor: pointer;
        }
        
        .instruction:hover {
            background-color: #2a2d2e;
        }
        
        .instruction.highlight {
            background-color: #264f78;
        }
        
        .instruction.dependency-highlight {
            background-color: #4a4a00;
        }
        
        .instruction.selected {
            background-color: #0e4884;
            border-left: 3px solid #007acc;
        }
        
        .instruction.current-search-result {
            background-color: #5a5a00 !important;
            border-left: 3px solid #ffcc00;
        }
        
        .addr {
            width: 100px;
            color: #888888;
            font-size: 11px;
            margin-right: 15px;
            flex-shrink: 0;
        }
        
        .hex {
            width: 120px;
            color: #b5cea8;
            font-size: 11px;
            margin-right: 15px;
            flex-shrink: 0;
        }
        
        .mnemonic {
            width: 400px;
            color: #569cd6;
            margin-right: 15px;
            flex-shrink: 0;
        }
        
        .comment {
            color: #608b4e;
            font-style: italic;
            flex: 1;
        }
        

        
        .dependency-panel {
            position: fixed;
            right: 20px;
            top: 140px;
            width: 300px;
            height: 400px;
            min-width: 250px;
            min-height: 200px;
            max-width: 600px;
            max-height: 80vh;
            background-color: #2d2d30;
            border: 1px solid #007acc;
            border-radius: 6px;
            padding: 15px;
            display: none;
            z-index: 1000;
            overflow-y: auto;
            resize: both;
            overflow: hidden;
        }
        
        .dependency-panel-header {
            position: absolute;
            top: 0;
            left: 0;
            right: 25px;
            height: 30px;
            background-color: #007acc;
            border-radius: 6px 6px 0 0;
            cursor: move;
            display: flex;
            align-items: center;
            padding: 0 10px;
            font-size: 12px;
            font-weight: bold;
            color: white;
            user-select: none;
        }
        
        .dependency-panel-header:hover {
            background-color: #1177bb;
        }
        
        .dependency-content {
            height: calc(100% - 30px);
            margin-top: 30px;
            overflow-y: auto;
            padding-right: 5px;
        }
        
        .resize-handle {
            position: absolute;
            bottom: 0;
            right: 0;
            width: 15px;
            height: 15px;
            background: linear-gradient(-45deg, transparent 0%, transparent 40%, #007acc 40%, #007acc 60%, transparent 60%);
            cursor: se-resize;
            border-bottom-right-radius: 6px;
        }
        
        .dependency-panel h3 {
            color: #007acc;
            margin-bottom: 10px;
            font-size: 14px;
        }
        
        .dependency-list {
            margin-bottom: 15px;
        }
        
        .dependency-item {
            padding: 5px 8px;
            margin: 2px 0;
            background-color: #3c3c3c;
            border-radius: 3px;
            font-size: 11px;
            cursor: pointer;
        }
        
        .dependency-item:hover {
            background-color: #4a4a4a;
        }
        
        .dependency-item.backward {
            border-left: 3px solid #ff6b6b;
        }
        
        .dependency-item.forward {
            border-left: 3px solid #4ecdc4;
        }
        
        .close-btn {
            position: absolute;
            top: 2px;
            right: 5px;
            background: none;
            border: none;
            color: white;
            font-size: 18px;
            cursor: pointer;
            width: 25px;
            height: 25px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 0 6px 0 0;
            z-index: 1001;
        }
        
        .close-btn:hover {
            background-color: #ff4757;
        }
        
        .no-results {
            text-align: center;
            color: #888888;
            padding: 40px;
            font-style: italic;
        }
        
        /* 滚动条样式 */
        ::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }
        
        ::-webkit-scrollbar-track {
            background: #2d2d30;
        }
        
        ::-webkit-scrollbar-thumb {
            background: #464647;
            border-radius: 4px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: #5a5a5a;
        }
        
        /* 响应式设计 */
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
                height: auto;
            }
            
            .sidebar {
                width: 100%;
                max-height: 200px;
            }
            
            .main-content {
                height: auto;
            }
            
            .controls {
                flex-direction: column;
                align-items: stretch;
            }
            
            .search-box {
                min-width: auto;
            }
            
            .dependency-panel {
                position: relative;
                width: 100%;
                max-height: 300px;
                right: 0;
                top: 0;
                margin-top: 10px;
            }
        }
        </style>
        """
        
        self.js_template = """
        <script>
        class DisasmVisualizer {
            constructor() {
                this.searchBox = document.getElementById('searchBox');
                this.functionItems = document.querySelectorAll('.function-item');
                this.functionBlocks = document.querySelectorAll('.function-block');
                this.instructions = document.querySelectorAll('.instruction');
                this.dependencyPanel = document.getElementById('dependencyPanel');
                this.selectedInstruction = null;
                this.dependencies = {};
                this.searchResults = [];
                this.currentSearchIndex = -1;
                
                this.initEventListeners();
                this.parseDependencies();
            }
            
            initEventListeners() {
                // 搜索功能
                this.searchBox.addEventListener('input', (e) => {
                    this.handleSearch(e.target.value);
                });
                
                // 函数导航
                this.functionItems.forEach(item => {
                    item.addEventListener('click', (e) => {
                        const funcName = e.currentTarget.dataset.function;
                        this.scrollToFunction(funcName);
                        this.setActiveFunction(funcName);
                    });
                });
                
                // 指令点击事件
                this.instructions.forEach((inst, index) => {
                    inst.addEventListener('click', (e) => {
                        this.selectInstruction(inst, index);
                    });
                });
                
                // 键盘快捷键
                document.addEventListener('keydown', (e) => {
                    if (e.key === 'Escape') {
                        this.clearSelection();
                    }
                });
                
                // 清除搜索
                document.getElementById('clearSearch').addEventListener('click', () => {
                    this.clearSearch();
                });
                
                // 跳转到地址
                document.getElementById('goToAddr').addEventListener('click', () => {
                    this.goToAddress();
                });
                
                // 搜索导航按钮
                document.getElementById('prevSearch').addEventListener('click', () => {
                    this.prevSearchResult();
                });
                
                document.getElementById('nextSearch').addEventListener('click', () => {
                    this.nextSearchResult();
                });
                
                // 依赖面板关闭按钮
                document.getElementById('closeDependency').addEventListener('click', () => {
                    this.closeDependencyPanel();
                });
                
                // 依赖面板拖拽调整大小
                this.initResizeHandle();
                
                // 依赖面板拖拽移动
                this.initDragMove();
            }
            
            parseDependencies() {
                // 从HTML中解析依赖信息
                this.instructions.forEach((inst, index) => {
                    const depData = inst.dataset.dependencies;
                    if (depData && depData.trim()) {
                        try {
                            // 尝试解析JSON格式的树状依赖结构
                            this.dependencies[index] = JSON.parse(depData);
                        } catch (e) {
                            // 如果解析失败，尝试旧格式（逗号分隔）
                            this.dependencies[index] = depData.split(',').map(d => parseInt(d.trim())).filter(d => !isNaN(d));
                        }
                    } else {
                        this.dependencies[index] = {};
                    }
                });
            }
            
            selectInstruction(instElement, index) {
                // 清除之前的选择
                this.clearSelection();
                
                // 选择当前指令
                instElement.classList.add('selected');
                this.selectedInstruction = index;
                
                // 显示寄存器依赖
                this.showDependencies(index);
            }
            
            clearSelection() {
                this.instructions.forEach(inst => {
                    inst.classList.remove('selected', 'dependency-highlight');
                });
                this.selectedInstruction = null;
                this.closeDependencyPanel();
            }
            
            showDependencies(index) {
                const dependencyTree = this.dependencies[index] || {};
                const inst = this.instructions[index];
                const addr = inst.querySelector('.addr').textContent;
                const mnemonic = inst.querySelector('.mnemonic').textContent;
                
                // 从树状结构中提取所有依赖指令索引
                const allDependencies = this.flattenDependencyTree(dependencyTree);
                
                // 高亮依赖的指令
                allDependencies.forEach(depIndex => {
                    if (this.instructions[depIndex]) {
                        this.instructions[depIndex].classList.add('dependency-highlight');
                    }
                });
                
                // 更新依赖面板，显示树状依赖结构
                this.updateDependencyPanel(index, addr, mnemonic, dependencyTree);
            }
            
            flattenDependencyTree(tree) {
                // 递归提取树状结构中的所有依赖索引
                const flattened = [];
                
                function traverse(node) {
                    if (typeof node === 'object' && node !== null) {
                        for (const key in node) {
                            const depIndex = parseInt(key);
                            if (!isNaN(depIndex)) {
                                flattened.push(depIndex);
                                traverse(node[key]);
                            }
                        }
                    }
                }
                
                traverse(tree);
                return flattened;
            }
            
            updateDependencyPanel(index, addr, mnemonic, dependencyTree) {
                const panel = this.dependencyPanel;
                const content = panel.querySelector('.dependency-content');
                
                // 获取当前指令的寄存器信息
                const currentInst = this.instructions[index];
                const mnemonicText = currentInst.querySelector('.mnemonic').textContent;
                const commentText = currentInst.querySelector('.comment').textContent;
                
                let html = `
                    <div class="selected-instruction">
                        <strong>${addr}: ${mnemonicText}</strong>
                    </div>
                `;
                
                if (commentText && commentText.trim()) {
                    html += `<div style="font-size: 11px; color: #888; margin: 5px 0;">${commentText}</div>`;
                }
                
                html += `<hr style="margin: 10px 0; border-color: #3c3c3c;">`;
                
                // 显示前置依赖树
                const treeHtml = this.renderDependencyTree(dependencyTree, commentText, 0);
                if (treeHtml) {
                    const totalDeps = this.flattenDependencyTree(dependencyTree).length;
                    html += `
                        <div class="dependency-list">
                            <h4 style="color: #ff6b6b; font-size: 12px; margin-bottom: 5px;">
                                🌳 前置依赖树 (${totalDeps} 个指令)
                            </h4>
                            ${treeHtml}
                        </div>
                    `;
                } else {
                    html += `<div style="color: #888888; font-style: italic; padding: 10px;">此指令没有寄存器依赖关系</div>`;
                }
                
                content.innerHTML = html;
                panel.style.display = 'block';
            }
            
            renderDependencyTree(tree, currentCommentText, depth) {
                // 递归渲染依赖树
                let html = '';
                const indent = '  '.repeat(depth);
                const registerColors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#feca57', '#ff9ff3', '#54a0ff'];
                const currentRegInfo = this.extractRegisterInfo(currentCommentText);
                
                for (const depIndexStr in tree) {
                    const depIndex = parseInt(depIndexStr);
                    if (isNaN(depIndex)) continue;
                    
                    const depInst = this.instructions[depIndex];
                    if (!depInst) continue;
                    
                    const depAddr = depInst.querySelector('.addr').textContent;
                    const depMnemonic = depInst.querySelector('.mnemonic').textContent;
                    const depComment = depInst.querySelector('.comment').textContent;
                    const depRegInfo = this.extractRegisterInfo(depComment);
                    
                    // 找到共同的寄存器并分配颜色
                    const commonRegs = this.findCommonRegisters(currentRegInfo.sources, depRegInfo.dest);
                    let regColorStyle = '';
                    let treePrefix = '';
                    
                    if (depth === 0) {
                        treePrefix = '├─ ';
                    } else {
                        treePrefix = indent + '├─ ';
                    }
                    
                    if (commonRegs.length > 0) {
                        const colorIndex = Math.abs(commonRegs[0].charCodeAt(0)) % registerColors.length;
                        regColorStyle = `border-left: 3px solid ${registerColors[colorIndex]};`;
                    }
                    
                    html += `
                        <div class="dependency-item tree-item" onclick="visualizer.jumpToInstruction(${depIndex})" 
                             style="${regColorStyle} margin-left: ${depth * 15}px; position: relative;">
                            <span style="color: #888; font-family: monospace;">${treePrefix}</span>
                            <span style="color: #ff6b6b;">→</span> ${depAddr}: ${depMnemonic}
                            ${commonRegs.length > 0 ? `<span style="color: ${registerColors[Math.abs(commonRegs[0].charCodeAt(0)) % registerColors.length]}; font-size: 10px;"> [${commonRegs.join(',')}]</span>` : ''}
                        </div>
                    `;
                    
                    // 递归渲染子树
                    const subtree = tree[depIndexStr];
                    if (typeof subtree === 'object' && Object.keys(subtree).length > 0) {
                        html += this.renderDependencyTree(subtree, depComment, depth + 1);
                    }
                }
                
                return html;
            }
            
            extractRegisterInfo(commentText) {
                // 从注释中提取寄存器信息，格式如 [a0,a1,→a2]
                const regMatch = commentText.match(/\\[([^\\]]+)\\]/);
                if (!regMatch) return { sources: [], dest: [] };
                
                const regStr = regMatch[1];
                const parts = regStr.split('→');
                const sources = parts[0] ? parts[0].split(',').map(r => r.trim()) : [];
                const dest = parts[1] ? [parts[1].trim()] : [];
                
                return { sources, dest };
            }
            
            findCommonRegisters(sources, destArray) {
                // 找到源寄存器和目标寄存器的交集
                const common = [];
                sources.forEach(src => {
                    if (destArray.includes(src)) {
                        common.push(src);
                    }
                });
                return common;
            }
            
            jumpToInstruction(index) {
                if (this.instructions[index]) {
                    this.instructions[index].scrollIntoView({ behavior: 'smooth', block: 'center' });
                    this.selectInstruction(this.instructions[index], index);
                }
            }
            
            closeDependencyPanel() {
                this.dependencyPanel.style.display = 'none';
            }
            
            initResizeHandle() {
                const resizeHandle = document.getElementById('resizeHandle');
                const panel = this.dependencyPanel;
                let isResizing = false;
                let startX, startY, startWidth, startHeight;
                
                resizeHandle.addEventListener('mousedown', (e) => {
                    isResizing = true;
                    startX = e.clientX;
                    startY = e.clientY;
                    startWidth = parseInt(document.defaultView.getComputedStyle(panel).width, 10);
                    startHeight = parseInt(document.defaultView.getComputedStyle(panel).height, 10);
                    
                    // 防止文本选择
                    e.preventDefault();
                    document.body.style.userSelect = 'none';
                    document.body.style.cursor = 'se-resize';
                });
                
                document.addEventListener('mousemove', (e) => {
                    if (!isResizing) return;
                    
                    const width = startWidth + (e.clientX - startX);
                    const height = startHeight + (e.clientY - startY);
                    
                    // 应用最小和最大尺寸限制
                    const minWidth = 250;
                    const minHeight = 200;
                    const maxWidth = 600;
                    const maxHeight = window.innerHeight * 0.8;
                    
                    const finalWidth = Math.max(minWidth, Math.min(width, maxWidth));
                    const finalHeight = Math.max(minHeight, Math.min(height, maxHeight));
                    
                    panel.style.width = finalWidth + 'px';
                    panel.style.height = finalHeight + 'px';
                });
                
                document.addEventListener('mouseup', () => {
                    if (isResizing) {
                        isResizing = false;
                        document.body.style.userSelect = '';
                        document.body.style.cursor = '';
                    }
                });
            }
            
            initDragMove() {
                const panelHeader = document.getElementById('panelHeader');
                const panel = this.dependencyPanel;
                let isDragging = false;
                let startX, startY, startLeft, startTop;
                
                panelHeader.addEventListener('mousedown', (e) => {
                    isDragging = true;
                    startX = e.clientX;
                    startY = e.clientY;
                    
                    // 获取当前位置
                    const rect = panel.getBoundingClientRect();
                    startLeft = rect.left;
                    startTop = rect.top;
                    
                    // 防止文本选择
                    e.preventDefault();
                    document.body.style.userSelect = 'none';
                    document.body.style.cursor = 'move';
                    
                    // 提高面板层级，确保在拖拽时显示在最前面
                    panel.style.zIndex = '1001';
                });
                
                document.addEventListener('mousemove', (e) => {
                    if (!isDragging) return;
                    
                    const deltaX = e.clientX - startX;
                    const deltaY = e.clientY - startY;
                    
                    let newLeft = startLeft + deltaX;
                    let newTop = startTop + deltaY;
                    
                    // 边界检查，确保面板不会完全移出屏幕
                    const panelRect = panel.getBoundingClientRect();
                    const minVisible = 50; // 至少保持50px可见
                    
                    newLeft = Math.max(-panelRect.width + minVisible, newLeft);
                    newLeft = Math.min(window.innerWidth - minVisible, newLeft);
                    newTop = Math.max(0, newTop);
                    newTop = Math.min(window.innerHeight - 30, newTop); // 保持标题栏可见
                    
                    panel.style.left = newLeft + 'px';
                    panel.style.top = newTop + 'px';
                    panel.style.right = 'auto'; // 取消right定位
                });
                
                document.addEventListener('mouseup', () => {
                    if (isDragging) {
                        isDragging = false;
                        document.body.style.userSelect = '';
                        document.body.style.cursor = '';
                        panel.style.zIndex = '1000'; // 恢复原始层级
                    }
                });
            }
            
            handleSearch(query) {
                if (!query.trim()) {
                    this.clearHighlight();
                    this.showAllFunctions();
                    this.hideSearchNavigation();
                    return;
                }
                
                query = query.toLowerCase();
                this.searchResults = [];
                this.currentSearchIndex = -1;
                
                // 搜索函数名
                this.functionItems.forEach(item => {
                    const funcName = item.querySelector('.function-name').textContent.toLowerCase();
                    const funcAddr = item.querySelector('.function-addr').textContent.toLowerCase();
                    
                    if (funcName.includes(query) || funcAddr.includes(query)) {
                        item.style.display = 'block';
                    } else {
                        item.style.display = 'none';
                    }
                });
                
                // 搜索指令并收集结果
                this.instructions.forEach((inst, index) => {
                    const addr = inst.querySelector('.addr').textContent.toLowerCase();
                    const hex = inst.querySelector('.hex').textContent.toLowerCase();
                    const mnemonic = inst.querySelector('.mnemonic').textContent.toLowerCase();
                    const comment = inst.querySelector('.comment').textContent.toLowerCase();
                    
                    if (addr.includes(query) || hex.includes(query) || 
                        mnemonic.includes(query) || comment.includes(query)) {
                        inst.classList.add('highlight');
                        
                        // 找到指令所在的函数
                        const funcBlock = inst.closest('.function-block');
                        const funcName = funcBlock ? funcBlock.dataset.function : 'Unknown';
                        
                        this.searchResults.push({
                            element: inst,
                            index: index,
                            function: funcName,
                            address: inst.querySelector('.addr').textContent,
                            mnemonic: inst.querySelector('.mnemonic').textContent.trim()
                        });
                    } else {
                        inst.classList.remove('highlight');
                    }
                });
                
                // 显示搜索结果统计和导航
                this.updateSearchStats(this.searchResults.length);
                if (this.searchResults.length > 0) {
                    this.showSearchNavigation();
                    this.currentSearchIndex = 0;
                    this.highlightCurrentResult();
                } else {
                    this.hideSearchNavigation();
                }
            }
            
            showSearchNavigation() {
                document.getElementById('prevSearch').style.display = 'inline-block';
                document.getElementById('nextSearch').style.display = 'inline-block';
            }
            
            hideSearchNavigation() {
                document.getElementById('prevSearch').style.display = 'none';
                document.getElementById('nextSearch').style.display = 'none';
            }
            
            nextSearchResult() {
                if (this.searchResults.length === 0) return;
                this.currentSearchIndex = (this.currentSearchIndex + 1) % this.searchResults.length;
                this.highlightCurrentResult();
            }
            
            prevSearchResult() {
                if (this.searchResults.length === 0) return;
                this.currentSearchIndex = (this.currentSearchIndex - 1 + this.searchResults.length) % this.searchResults.length;
                this.highlightCurrentResult();
            }
            
            highlightCurrentResult() {
                if (this.searchResults.length === 0) return;
                
                // 清除之前的当前结果高亮
                this.instructions.forEach(inst => {
                    inst.classList.remove('current-search-result');
                });
                
                const currentResult = this.searchResults[this.currentSearchIndex];
                currentResult.element.classList.add('current-search-result');
                
                // 滚动到当前结果
                currentResult.element.scrollIntoView({ behavior: 'smooth', block: 'center' });
                
                // 在左侧函数列表中高亮所在函数
                this.setActiveFunction(currentResult.function);
                
                // 更新搜索统计显示
                this.updateSearchResultsDisplay();
            }
            
            updateSearchResultsDisplay() {
                const statsEl = document.querySelector('.search-stats');
                const resultsEl = document.querySelector('.search-results');
                
                if (this.searchResults.length > 0) {
                    const current = this.searchResults[this.currentSearchIndex];
                    statsEl.textContent = `${this.currentSearchIndex + 1}/${this.searchResults.length} 个匹配项`;
                    resultsEl.innerHTML = `
                        <div style="font-size: 11px; color: #888; margin-top: 5px;">
                            当前: ${current.function} - ${current.address}: ${current.mnemonic.substring(0, 30)}${current.mnemonic.length > 30 ? '...' : ''}
                        </div>
                    `;
                    resultsEl.style.display = 'block';
                } else {
                    statsEl.textContent = '';
                    resultsEl.style.display = 'none';
                }
            }
            
            clearSearch() {
                this.searchBox.value = '';
                this.clearHighlight();
                this.showAllFunctions();
                this.hideSearchNavigation();
                this.searchResults = [];
                this.currentSearchIndex = -1;
                this.updateSearchStats(0);
                document.querySelector('.search-results').style.display = 'none';
            }
            
            clearHighlight() {
                this.instructions.forEach(inst => {
                    inst.classList.remove('highlight', 'current-search-result');
                });
            }
            
            showAllFunctions() {
                this.functionItems.forEach(item => {
                    item.style.display = 'block';
                });
            }
            
            scrollToFunction(funcName) {
                const funcBlock = document.querySelector(`.function-block[data-function="${funcName}"]`);
                if (funcBlock) {
                    funcBlock.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            }
            
            setActiveFunction(funcName) {
                this.functionItems.forEach(item => {
                    item.classList.remove('active');
                });
                
                const activeItem = document.querySelector(`.function-item[data-function="${funcName}"]`);
                if (activeItem) {
                    activeItem.classList.add('active');
                }
            }
            
            goToAddress() {
                const addr = prompt('请输入要跳转的地址 (16进制):');
                if (!addr) return;
                
                const cleanAddr = addr.replace(/^0x/, '').toLowerCase();
                const targetInst = Array.from(this.instructions).find(inst => {
                    const instAddr = inst.querySelector('.addr').textContent.toLowerCase();
                    return instAddr.includes(cleanAddr);
                });
                
                if (targetInst) {
                    targetInst.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    const index = Array.from(this.instructions).indexOf(targetInst);
                    this.selectInstruction(targetInst, index);
                } else {
                    alert('未找到指定地址');
                }
            }
            
            updateSearchStats(count) {
                const statsEl = document.querySelector('.search-stats');
                if (statsEl) {
                    if (count > 0 && this.searchResults.length > 0) {
                        // 由updateSearchResultsDisplay处理
                        return;
                    } else {
                        statsEl.textContent = count > 0 ? `找到 ${count} 个匹配项` : '';
                    }
                }
            }
        }
        
        // 全局变量，方便在HTML中调用
        let visualizer;
        
        // 初始化
        document.addEventListener('DOMContentLoaded', () => {
            visualizer = new DisasmVisualizer();
        });
        </script>
        """
    
    def generate_html(self, data: Dict, output_path: str):
        """生成HTML文件"""
        # 分析全局依赖关系
        parser = RISCVDisasmParser()
        global_dependencies = parser.analyze_global_dependencies(data['functions'])
        
        functions_html = self._generate_functions_html(data['functions'], global_dependencies)
        sidebar_html = self._generate_sidebar_html(data['functions'])
        
        html = f"""
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>RISC-V 反汇编可视化</title>
            {self.css_template}
        </head>
        <body>
            <div class="header">
                <div class="title">RISC-V 反汇编可视化</div>
                <div class="file-info">{data['header']}</div>
            </div>
            
            <div class="controls">
                <input type="text" id="searchBox" class="search-box" placeholder="搜索函数、地址或指令...">
                <button id="prevSearch" class="btn" style="display:none">上一个</button>
                <button id="nextSearch" class="btn" style="display:none">下一个</button>
                <button id="clearSearch" class="btn">清除</button>
                <button id="goToAddr" class="btn">跳转到地址</button>
                <div class="stats">
                    函数: {len(data['functions'])} | 指令: {data['total_instructions']} | 段: {', '.join(data['sections'])} | 
                    <span style="color: #ffcc00;">点击指令查看寄存器依赖</span>
                </div>
                <div class="search-stats"></div>
                <div class="search-results" style="display:none;"></div>
            </div>
            
            <div class="container">
                <div class="sidebar">
                    <div class="function-list">
                        {sidebar_html}
                    </div>
                </div>
                
                <div class="main-content">
                    {functions_html}
                </div>
            </div>
            
            <div id="dependencyPanel" class="dependency-panel">
                <div class="dependency-panel-header" id="panelHeader">
                    📊 指令依赖分析
                </div>
                <button id="closeDependency" class="close-btn">×</button>
                <div class="dependency-content"></div>
                <div class="resize-handle" id="resizeHandle"></div>
            </div>
            
            {self.js_template}
        </body>
        </html>
        """
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html)
    
    def _generate_sidebar_html(self, functions: List[Function]) -> str:
        """生成侧边栏HTML"""
        if not functions:
            return '<div class="no-results">未找到函数</div>'
        
        html = ''
        for func in functions:
            inst_count = len(func.instructions)
            html += f'''
            <div class="function-item" data-function="{func.name}">
                <div class="function-name">{func.name}</div>
                <div class="function-addr">0x{func.address}</div>
                <div class="function-stats">{inst_count} 条指令</div>
            </div>
            '''
        
        return html
    
    def _generate_functions_html(self, functions: List[Function], global_dependencies: Dict[int, Dict]) -> str:
        """生成函数HTML"""
        if not functions:
            return '<div class="no-results">未找到反汇编代码</div>'
        
        html = ''
        instruction_offset = 0
        
        for func in functions:
            # 为当前函数的指令创建依赖映射
            func_dependencies = {}
            for i in range(len(func.instructions)):
                global_idx = instruction_offset + i
                if global_idx in global_dependencies:
                    func_dependencies[i] = global_dependencies[global_idx]
            
            instructions_html = self._generate_instructions_html(func.instructions, func_dependencies)
            html += f'''
            <div class="function-block" data-function="{func.name}">
                <div class="function-header">
                    <span class="function-title">{func.name}</span>
                    <span class="function-address">0x{func.address}</span>
                </div>
                <div class="instructions">
                    {instructions_html}
                </div>
            </div>
            '''
            
            instruction_offset += len(func.instructions)
        
        return html
    
    def _generate_instructions_html(self, instructions: List[Instruction], dependencies: Dict[int, Dict]) -> str:
        """生成指令HTML"""
        html = ''
        analyzer = RISCVRegisterAnalyzer()  # 创建分析器实例用于获取寄存器显示名
        
        for i, inst in enumerate(instructions):
            # 依赖信息 - 现在是树状结构，需要转换为JSON
            dep_tree = dependencies.get(i, {})
            import json
            dep_data = f'data-dependencies=\'{json.dumps(dep_tree)}\'' if dep_tree else ''
            
            # 生成寄存器信息 - 使用寄存器名字而不是x0~x31
            reg_parts = []
            if inst.source_regs:
                display_regs = [analyzer.get_register_display_name(reg) for reg in inst.source_regs]
                reg_parts.extend(display_regs)
            if inst.dest_reg:
                dest_display = analyzer.get_register_display_name(inst.dest_reg)
                reg_parts.append(f"→{dest_display}")
            
            # 合并原有注释和寄存器信息
            full_comment = inst.comment
            if reg_parts:
                reg_str = f"[{','.join(reg_parts)}]"
                if full_comment and full_comment.strip():
                    full_comment = f"{full_comment} {reg_str}"
                else:
                    full_comment = reg_str
            
            html += f'''
            <div class="instruction" {dep_data}>
                <div class="addr">{inst.address}</div>
                <div class="hex">{inst.hex_code}</div>
                <div class="mnemonic">{inst.mnemonic}</div>
                <div class="comment">{full_comment}</div>
            </div>
            '''
        
        return html

def main():
    parser = argparse.ArgumentParser(description='RISC-V反汇编文件可视化HTML生成器')
    parser.add_argument('input', help='输入的反汇编文件路径')
    parser.add_argument('output', nargs='?', help='输出的HTML文件路径')
    parser.add_argument('--encoding', default='utf-8', help='输入文件编码 (默认: utf-8)')
    
    args = parser.parse_args()
    
    # 检查输入文件
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"错误: 输入文件 '{args.input}' 不存在")
        sys.exit(1)
    
    # 确定输出文件路径
    if args.output:
        output_path = args.output
    else:
        output_path = str(input_path).replace('.txt', '_enhanced.html')
    
    print(f"正在解析文件: {input_path}")
    
    # 解析反汇编文件
    parser_obj = RISCVDisasmParser()
    try:
        data = parser_obj.parse_file(str(input_path))
    except Exception as e:
        print(f"错误: 解析文件时出错 - {e}")
        sys.exit(1)
    
    print(f"解析完成:")
    print(f"  - 函数数量: {len(data['functions'])}")
    print(f"  - 指令数量: {data['total_instructions']}")
    print(f"  - 段数量: {len(data['sections'])}")
    
    # 统计寄存器依赖
    total_deps = 0
    total_instructions_with_regs = 0
    for func in data['functions']:
        if hasattr(func, 'dependencies'):
            total_deps += sum(len(deps) for deps in func.dependencies.values())
        
        # 统计有寄存器信息的指令
        for inst in func.instructions:
            if inst.source_regs or inst.dest_reg:
                total_instructions_with_regs += 1
    
    print(f"  - 寄存器依赖关系: {total_deps}")
    print(f"  - 识别到寄存器的指令: {total_instructions_with_regs}")
    
    # 生成HTML
    print(f"正在生成HTML文件: {output_path}")
    
    generator = HTMLGenerator()
    try:
        generator.generate_html(data, output_path)
        print(f"HTML文件生成成功: {output_path}")
        print(f"请在浏览器中打开 {output_path} 查看可视化结果")
        print("\n使用说明:")
        print("- 点击任意指令查看其寄存器依赖关系")
        print("- 右侧会显示依赖分析面板")
        print("- 点击依赖项可跳转到对应指令")
        print("- 红色箭头表示前置依赖链")
    except Exception as e:
        print(f"错误: 生成HTML文件时出错 - {e}")
        sys.exit(1)

if __name__ == '__main__':
    main() 
