#!/usr/bin/env python3
"""
SRAM拼接方案生成器
处理seq_mems.json文件并生成SRAM拼接方案
"""

import json
import os
import sys
import argparse
import yaml
from dataclasses import dataclass, asdict
from typing import Dict, List, Tuple, Optional
from itertools import combinations
from datetime import datetime


@dataclass
class MemoryCompilerSpec:
    """Memory Compiler规格定义"""
    bank_count: int
    mux: int
    min_words: int
    max_words: int
    min_bits: int
    max_bits: int
    word_step: int = 16
    bit_step: int = 1
    
    def is_valid_config(self, words: int, bits: int) -> bool:
        """检查给定的配置是否在此规格范围内"""
        words_valid = (self.min_words <= words <= self.max_words and 
                      (words - self.min_words) % self.word_step == 0)
        bits_valid = (self.min_bits <= bits <= self.max_bits and 
                     (bits - self.min_bits) % self.bit_step == 0)
        return words_valid and bits_valid
    
    def get_valid_words(self) -> List[int]:
        """获取此规格支持的所有有效字数"""
        valid_words = []
        current = self.min_words
        while current <= self.max_words:
            valid_words.append(current)
            current += self.word_step
        return valid_words
    
    def get_valid_bits(self) -> List[int]:
        """获取此规格支持的所有有效位宽"""
        valid_bits = []
        current = self.min_bits
        while current <= self.max_bits:
            valid_bits.append(current)
            current += self.bit_step
        return valid_bits


@dataclass 
class SRAMConfig:
    """单个SRAM配置"""
    words: int
    bits: int
    bank_count: int
    mux: int
    count: int = 1
    
    @property
    def total_capacity(self) -> int:
        """总容量（words × bits）"""
        return self.words * self.bits * self.count


@dataclass
class SRAMTilingConfig:
    """SRAM拼接配置"""
    target_words: int
    target_bits: int
    sram_configs: List[SRAMConfig]
    tiling_type: str
    
    @property
    def total_srams(self) -> int:
        """总SRAM数量"""
        return sum(config.count for config in self.sram_configs)
    
    @property
    def achieved_words(self) -> int:
        """实际达到的字数"""
        if self.tiling_type in ['word_tiling']:
            return sum(config.words * config.count for config in self.sram_configs)
        elif self.tiling_type in ['bit_tiling', 'redundant_bit_tiling']:
            return self.sram_configs[0].words if self.sram_configs else 0
        elif self.tiling_type in ['matrix_tiling', 'redundant_mixed_tiling']:
            return self.sram_configs[0].words if self.sram_configs else 0
        else:  # exact, redundant_exact
            return self.sram_configs[0].words if self.sram_configs else 0
    
    @property
    def achieved_bits(self) -> int:
        """实际达到的位宽"""
        if self.tiling_type in ['bit_tiling', 'redundant_bit_tiling']:
            return sum(config.bits * config.count for config in self.sram_configs)
        elif self.tiling_type in ['word_tiling']:
            return self.sram_configs[0].bits if self.sram_configs else 0
        elif self.tiling_type in ['matrix_tiling', 'redundant_mixed_tiling']:
            return sum(config.bits for config in self.sram_configs)
        else:  # exact, redundant_exact
            return self.sram_configs[0].bits if self.sram_configs else 0

    def to_dict(self):
        return {
            "target_words": self.target_words,
            "target_bits": self.target_bits,
            "sram_configs": [asdict(config) for config in self.sram_configs],
            "tiling_type": self.tiling_type,
            "total_srams": self.total_srams,
            "achieved_words": self.achieved_words,
            "achieved_bits": self.achieved_bits,
            "redundancy": getattr(self, 'redundancy', None)
        }


class MemoryCompilerManager:
    """Memory Compiler管理器"""
    
    def __init__(self):
        self.specs: List[MemoryCompilerSpec] = []
    
    def load_specs_from_yaml(self, yaml_file: str):
        """从YAML文件加载规格"""
        try:
            with open(yaml_file, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
            
            for spec_data in data['sram_specs']:
                spec = MemoryCompilerSpec(
                    bank_count=spec_data['bank_count'],
                    mux=spec_data['mux'],
                    min_words=spec_data['min_words'],
                    max_words=spec_data['max_words'],
                    min_bits=spec_data['min_bits'],
                    max_bits=spec_data['max_bits'],
                    word_step=spec_data.get('word_step', 16),
                    bit_step=spec_data.get('bit_step', 1)
                )
                self.specs.append(spec)
            
            print(f"已加载 {len(self.specs)} 个SRAM规格")
            
        except Exception as e:
            print(f"❌ 加载YAML文件失败: {e}")
            sys.exit(1)


class SRAMTilingGenerator:
    """SRAM拼接生成器"""
    
    def __init__(self, manager: MemoryCompilerManager):
        self.manager = manager
    
    def generate_valid_sram_configs(self) -> List[SRAMConfig]:
        """生成所有有效的SRAM配置"""
        configs = []
        for spec in self.manager.specs:
            valid_words = spec.get_valid_words()
            valid_bits = spec.get_valid_bits()
            
            for words in valid_words:
                for bits in valid_bits:
                    config = SRAMConfig(
                        words=words,
                        bits=bits,
                        bank_count=spec.bank_count,
                        mux=spec.mux
                    )
                    configs.append(config)
        
        return configs
    
    def find_exact_match(self, target_words: int, target_bits: int) -> Optional[SRAMTilingConfig]:
        """查找完全匹配的单个SRAM"""
        configs = self.generate_valid_sram_configs()
        
        for config in configs:
            if config.words == target_words and config.bits == target_bits:
                return SRAMTilingConfig(
                    target_words=target_words,
                    target_bits=target_bits,
                    sram_configs=[config],
                    tiling_type='exact'
                )
        
        return None
    
    def find_bit_tiling(self, target_words: int, target_bits: int, max_srams: int = 8) -> List[SRAMTilingConfig]:
        """查找位方向拼接"""
        configs = self.generate_valid_sram_configs()
        solutions = []
        
        matching_configs = [c for c in configs if c.words == target_words]
        
        for config in matching_configs:
            if target_bits % config.bits == 0:
                needed_count = target_bits // config.bits
                if 1 < needed_count <= max_srams:
                    tiling_config = SRAMConfig(
                        words=config.words,
                        bits=config.bits,
                        bank_count=config.bank_count,
                        mux=config.mux,
                        count=needed_count
                    )
                    
                    solution = SRAMTilingConfig(
                        target_words=target_words,
                        target_bits=target_bits,
                        sram_configs=[tiling_config],
                        tiling_type='bit_tiling'
                    )
                    solutions.append(solution)
        
        return solutions
    
    def find_mixed_tiling(self, target_words: int, target_bits: int, max_srams: int = 8) -> List[SRAMTilingConfig]:
        """查找混合拼接"""
        configs = self.generate_valid_sram_configs()
        solutions = []
        
        word_matching = [c for c in configs if c.words == target_words]
        
        if not word_matching:
            return solutions
        
        max_combinations = min(len(word_matching), max_srams, 10)
        
        for i in range(2, max_combinations + 1):
            combo_count = 0
            for combo in combinations(word_matching, i):
                combo_count += 1
                if combo_count > 1000:
                    break
                    
                total_bits = sum(c.bits for c in combo)
                if total_bits == target_bits:
                    config_signatures = [(c.words, c.bits, c.bank_count, c.mux) for c in combo]
                    if len(set(config_signatures)) == len(combo):
                        solution = SRAMTilingConfig(
                            target_words=target_words,
                            target_bits=target_bits,
                            sram_configs=list(combo),
                            tiling_type='matrix_tiling'
                        )
                        solutions.append(solution)
            
            if combo_count > 1000:
                break
        
        return solutions
    
    def find_redundant_solutions(self, target_words: int, target_bits: int, max_srams: int = 8) -> List[SRAMTilingConfig]:
        """查找冗余方案"""
        configs = self.generate_valid_sram_configs()
        solutions = []
        
        # 查找单个SRAM的冗余方案
        for config in configs:
            if config.words >= target_words and config.bits >= target_bits:
                redundancy = (config.words * config.bits) - (target_words * target_bits)
                solution = SRAMTilingConfig(
                    target_words=target_words,
                    target_bits=target_bits,
                    sram_configs=[config],
                    tiling_type='redundant_exact'
                )
                solution.redundancy = redundancy
                solutions.append(solution)
        
        # 查找位拼接的冗余方案
        suitable_configs = [c for c in configs if c.words >= target_words]
        
        word_groups = {}
        for config in suitable_configs:
            if config.words not in word_groups:
                word_groups[config.words] = []
            word_groups[config.words].append(config)
        
        for words, group_configs in word_groups.items():
            for count in range(2, max_srams + 1):
                for config in group_configs:
                    total_bits = config.bits * count
                    if total_bits >= target_bits:
                        redundancy = (words * total_bits) - (target_words * target_bits)
                        tiling_config = SRAMConfig(
                            words=config.words,
                            bits=config.bits,
                            bank_count=config.bank_count,
                            mux=config.mux,
                            count=count
                        )
                        
                        solution = SRAMTilingConfig(
                            target_words=target_words,
                            target_bits=target_bits,
                            sram_configs=[tiling_config],
                            tiling_type='redundant_bit_tiling'
                        )
                        solution.redundancy = redundancy
                        solutions.append(solution)
                        break
        
        return solutions
    
    def get_best_solution(self, target_words: int, target_bits: int, max_srams: int = 8) -> Optional[SRAMTilingConfig]:
        """获取最佳拼接方案"""
        all_solutions = []
        
        # 1. 精确匹配
        exact = self.find_exact_match(target_words, target_bits)
        if exact:
            exact.redundancy = 0
            all_solutions.append((exact, 1, 0))
        
        # 2. 位拼接
        bit_tiling = self.find_bit_tiling(target_words, target_bits, max_srams)
        for solution in bit_tiling:
            solution.redundancy = 0
            all_solutions.append((solution, 2, 0))
        
        # 3. 混合拼接
        mixed = self.find_mixed_tiling(target_words, target_bits, max_srams)
        for solution in mixed:
            solution.redundancy = 0
            all_solutions.append((solution, 3, 0))
        
        # 4. 如果没有精确方案，尝试冗余方案
        if not all_solutions:
            redundant = self.find_redundant_solutions(target_words, target_bits, max_srams)
            for solution in redundant:
                all_solutions.append((solution, 4, solution.redundancy))
        
        # 按优先级、SRAM数量、冗余量排序
        all_solutions.sort(key=lambda x: (x[1], x[0].total_srams, x[2]))
        
        return all_solutions[0][0] if all_solutions else None


def read_seq_mems_json(filename: str) -> Tuple[List[Tuple[int, int, str]], List[Dict]]:
    """读取seq_mems.json文件"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            sram_data = json.load(f)
        
        sram_requirements = []
        for item in sram_data:
            if 'depth' in item and 'width' in item and 'module_name' in item:
                depth = item['depth']
                width = item['width']
                module_name = item['module_name']
                sram_requirements.append((depth, width, module_name))
        
        return sram_requirements, sram_data
    
    except Exception as e:
        print(f"❌ 读取文件失败: {e}")
        sys.exit(1)


def save_results_to_json(results: Dict, output_file: str):
    """保存结果到JSON文件"""
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        print(f"✅ 结果已保存到: {output_file}")
    except Exception as e:
        print(f"❌ 保存文件失败: {e}")
        sys.exit(1)


def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='SRAM拼接方案生成器')
    parser.add_argument('-i', '--input', required=True, help='输入的seq_mems.json文件路径')
    parser.add_argument('-o', '--output', required=True, help='输出的结果JSON文件路径')
    parser.add_argument('-s', '--spec', default='sramSpec.yaml', help='SRAM规格YAML文件路径')
    parser.add_argument('--max-srams', type=int, default=6, help='最大SRAM数量限制')
    
    args = parser.parse_args()
    
    # 检查输入文件
    if not os.path.exists(args.input):
        print(f"❌ 输入文件不存在: {args.input}")
        sys.exit(1)
    
    if not os.path.exists(args.spec):
        print(f"❌ 规格文件不存在: {args.spec}")
        sys.exit(1)
    
    print("SRAM拼接方案生成器")
    print(f"输入文件: {args.input}")
    print(f"输出文件: {args.output}")
    print(f"规格文件: {args.spec}")
    
    # 创建管理器和生成器
    manager = MemoryCompilerManager()
    manager.load_specs_from_yaml(args.spec)
    generator = SRAMTilingGenerator(manager)
    
    # 读取SRAM需求
    sram_requirements, original_data = read_seq_mems_json(args.input)
    print(f"读取到 {len(sram_requirements)} 个SRAM需求")
    
    # 处理结果
    results = {
        "generation_time": datetime.now().isoformat(),
        "total_requirements": len(sram_requirements),
        "original_data": original_data,
        "summary": {
            "successful": 0,
            "failed": 0,
            "exact_matches": 0,
            "bit_tilings": 0,
            "matrix_tilings": 0,
            "redundant_tilings": 0
        },
        "sram_results": []
    }
    
    # 批量处理
    for depth, width, module_name in sram_requirements:
        solution = generator.get_best_solution(depth, width, args.max_srams)
        
        sram_result = {
            "module_name": module_name,
            "target_words": depth,
            "target_bits": width,
            "target_capacity_bits": depth * width,
            "has_solution": "否",
            "solution": None
        }
        
        if solution:
            results["summary"]["successful"] += 1
            sram_result["has_solution"] = "是"
            
            # 统计类型和转换为中文
            if solution.tiling_type == 'exact':
                results["summary"]["exact_matches"] += 1
                status = "✅ 完全匹配"
                solution_type_zh = "完全匹配"
            elif solution.tiling_type == 'bit_tiling':
                results["summary"]["bit_tilings"] += 1
                status = "✅ 位拼接"
                solution_type_zh = "位拼接"
            elif solution.tiling_type == 'matrix_tiling':
                results["summary"]["matrix_tilings"] += 1
                status = "✅ 混合拼接"
                solution_type_zh = "混合拼接"
            else:
                results["summary"]["redundant_tilings"] += 1
                status = "✅ 冗余拼接"
                if solution.tiling_type == 'redundant_exact':
                    solution_type_zh = "冗余完全匹配"
                elif solution.tiling_type == 'redundant_bit_tiling':
                    solution_type_zh = "冗余位拼接"
                elif solution.tiling_type == 'redundant_mixed_tiling':
                    solution_type_zh = "冗余混合拼接"
                else:
                    solution_type_zh = "冗余拼接"
            
            # 转换为字典并添加详细信息
            solution_data = solution.to_dict()
            # 将英文类型替换为中文
            solution_data["tiling_type"] = solution_type_zh
            
            # 计算效率
            actual_capacity = solution.achieved_words * solution.achieved_bits
            target_capacity = depth * width
            
            if hasattr(solution, 'redundancy') and solution.redundancy is not None:
                solution_data["efficiency_percent"] = round(target_capacity / actual_capacity * 100, 2)
                solution_data["redundancy_bits"] = solution.redundancy
                solution_data["redundancy_percent"] = round(solution.redundancy / target_capacity * 100, 2)
            else:
                solution_data["efficiency_percent"] = 100.0
                solution_data["redundancy_bits"] = 0
                solution_data["redundancy_percent"] = 0.0
            
            solution_data["actual_capacity_bits"] = actual_capacity
            
            sram_result["solution"] = solution_data
            print(f"{module_name}: {status} ({solution.total_srams} SRAMs)")
            
        else:
            results["summary"]["failed"] += 1
            print(f"{module_name}: ❌ 无解")
        
        results["sram_results"].append(sram_result)
    
    # 输出汇总
    summary = results["summary"]
    print(f"\n处理完成:")
    print(f"  成功: {summary['successful']}")
    print(f"  失败: {summary['failed']}")
    print(f"  精确匹配: {summary['exact_matches']}")
    print(f"  位拼接: {summary['bit_tilings']}")
    print(f"  混合拼接: {summary['matrix_tilings']}")
    print(f"  冗余拼接: {summary['redundant_tilings']}")
    
    # 保存结果
    save_results_to_json(results, args.output)


if __name__ == "__main__":
    main() 
    