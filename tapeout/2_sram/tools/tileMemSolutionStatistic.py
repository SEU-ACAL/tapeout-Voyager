#!/usr/bin/env python3
"""
SRAM拼接方案统计器
读取sram_solution.json文件并生成CSV统计报告
"""

import json
import csv
import pandas as pd
import argparse
import sys
import os
from typing import Dict, List, Any



def read_solution_json(filename: str) -> Dict[str, Any]:
    """读取SRAM解决方案JSON文件"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return data
    except Exception as e:
        print(f"❌ 读取JSON文件失败: {e}")
        sys.exit(1)


def extract_sram_statistics(solution_data: Dict[str, Any]) -> List[Dict[str, Any]]:
    """提取SRAM统计信息 - 模块视角"""
    statistics = []
    
    for sram_result in solution_data.get('sram_results', []):
        module_name = sram_result.get('module_name', '')
        target_words = sram_result.get('target_words', 0)
        target_bits = sram_result.get('target_bits', 0)
        target_capacity = sram_result.get('target_capacity_bits', target_words * target_bits)
        
        solution = sram_result.get('solution')
        
        stat_row = {
            '模块名称': module_name,
            '目标规格': f"{target_words}W×{target_bits}B",
            '目标容量(bits)': target_capacity,
            '有解决方案': sram_result.get('has_solution', '否'),
        }
        
        if solution:
            # 拼接方案信息
            stat_row.update({
                '拼接类型': solution.get('tiling_type', ''),
                '实际规格': f"{solution.get('achieved_words', 0)}W×{solution.get('achieved_bits', 0)}B",
                '实际容量(bits)': solution.get('actual_capacity_bits', 0),
                '效率(%)': solution.get('efficiency_percent', 0),
                '冗余容量(bits)': solution.get('redundancy_bits', 0),
            })
            
            # SRAM配置详情
            sram_configs = solution.get('sram_configs', [])
            if sram_configs:
                # 详细配置描述
                config_descriptions = []
                for config in sram_configs:
                    count = config.get('count', 1)
                    words = config.get('words', 0)
                    bits = config.get('bits', 0)
                    bank = config.get('bank_count', 0)
                    mux = config.get('mux', 0)
                    
                    if count > 1:
                        desc = f"{count}个 {words}W×{bits}B (Bank{bank},MUX{mux})"
                    else:
                        desc = f"{words}W×{bits}B (Bank{bank},MUX{mux})"
                    config_descriptions.append(desc)
                
                stat_row['SRAM配置方案'] = ' + '.join(config_descriptions)
                stat_row['总SRAM数量'] = solution.get('total_srams', 0)
            else:
                stat_row.update({
                    'SRAM配置方案': '',
                    '总SRAM数量': 0,
                })
        else:
            # 无解的情况
            stat_row.update({
                '拼接类型': '无解决方案',
                '实际规格': 'N/A',
                '实际容量(bits)': 0,
                '效率(%)': 0,
                '冗余容量(bits)': 0,
                'SRAM配置方案': '无解决方案',
                '总SRAM数量': 0,
            })
        
        statistics.append(stat_row)
    
    return statistics


def extract_sram_spec_requirements(solution_data: Dict[str, Any]) -> List[Dict[str, Any]]:
    """提取SRAM规格需求 - 厂商采购视角"""
    spec_requirements = {}
    
    for sram_result in solution_data.get('sram_results', []):
        solution = sram_result.get('solution')
        if not solution:
            continue
            
        sram_configs = solution.get('sram_configs', [])
        for config in sram_configs:
            words = config.get('words', 0)
            bits = config.get('bits', 0)
            bank = config.get('bank_count', 0)
            mux = config.get('mux', 0)
            count = config.get('count', 1)
            
            # 创建规格键
            spec_key = f"{words}W×{bits}B_Bank{bank}_MUX{mux}"
            
            if spec_key not in spec_requirements:
                spec_requirements[spec_key] = {
                    'SRAM规格': f"{words}W×{bits}B",
                    'Bank数': bank,
                    'MUX': mux,
                    '总需求量': 0,
                    '使用模块': []
                }
            
            spec_requirements[spec_key]['总需求量'] += count
            spec_requirements[spec_key]['使用模块'].append(sram_result.get('module_name', ''))
    
    # 转换为列表并按需求量排序
    spec_list = []
    for spec_key, spec_info in spec_requirements.items():
        spec_list.append({
            'SRAM规格': spec_info['SRAM规格'],
            'Bank数': spec_info['Bank数'],
            'MUX': spec_info['MUX'],
            '总需求量': spec_info['总需求量'],
            '使用模块数': len(set(spec_info['使用模块'])),
            '主要使用模块': ', '.join(set(spec_info['使用模块'][:3]))  # 只显示前3个
        })
    
    # 按总需求量降序排序
    spec_list.sort(key=lambda x: x['总需求量'], reverse=True)
    
    return spec_list


def generate_summary_statistics(solution_data: Dict[str, Any]) -> Dict[str, Any]:
    """生成汇总统计信息"""
    summary = solution_data.get('summary', {})
    
    summary_stats = {
        'generation_time': solution_data.get('generation_time', ''),
        'total_requirements': solution_data.get('total_requirements', 0),
        'successful_solutions': summary.get('successful', 0),
        'failed_solutions': summary.get('failed', 0),
        'exact_matches': summary.get('exact_matches', 0),
        'bit_tilings': summary.get('bit_tilings', 0),
        'matrix_tilings': summary.get('matrix_tilings', 0),
        'redundant_tilings': summary.get('redundant_tilings', 0),
    }
    
    # 计算成功率
    total = summary_stats['total_requirements']
    if total > 0:
        summary_stats['success_rate_percent'] = round(summary_stats['successful_solutions'] / total * 100, 2)
    else:
        summary_stats['success_rate_percent'] = 0
    
    return summary_stats


def save_to_csv(statistics: List[Dict[str, Any]], spec_requirements: List[Dict[str, Any]], summary: Dict[str, Any], output_file: str):
    """保存统计信息到CSV文件"""
    try:
        if not statistics:
            print("❌ 没有统计数据可写入")
            return
        
        # 创建DataFrame
        df_modules = pd.DataFrame(statistics)
        df_specs = pd.DataFrame(spec_requirements)
        
        # 保存模块拼接方案CSV
        csv_file = output_file
        df_modules.to_csv(csv_file, index=False, encoding='utf-8-sig')
        print(f" 模块拼接方案CSV已保存到: {csv_file}")
        
        # 保存SRAM规格需求CSV
        spec_csv_file = output_file.replace('.csv', '_specs.csv')
        df_specs.to_csv(spec_csv_file, index=False, encoding='utf-8-sig')
        print(f" SRAM规格需求CSV已保存到: {spec_csv_file}")
        

        
    except Exception as e:
        print(f"❌ 保存文件失败: {e}")
        sys.exit(1)


def analyze_efficiency_distribution(statistics: List[Dict[str, Any]]) -> Dict[str, int]:
    """分析效率分布"""
    efficiency_ranges = {
        '100%': 0,        # 完全匹配
        '95-99%': 0,      # 高效率
        '90-94%': 0,      # 良好效率
        '80-89%': 0,      # 一般效率
        '<80%': 0,        # 低效率
        'No Solution': 0  # 无解
    }
    
    for stat in statistics:
        if stat['有解决方案'] == '否':
            efficiency_ranges['No Solution'] += 1
        else:
            eff = stat.get('效率(%)', 0)
            if eff == 100:
                efficiency_ranges['100%'] += 1
            elif eff >= 95:
                efficiency_ranges['95-99%'] += 1
            elif eff >= 90:
                efficiency_ranges['90-94%'] += 1
            elif eff >= 80:
                efficiency_ranges['80-89%'] += 1
            else:
                efficiency_ranges['<80%'] += 1
    
    return efficiency_ranges


def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='SRAM拼接方案统计器')
    parser.add_argument('-i', '--input', required=True, help='输入的SRAM解决方案JSON文件路径')
    parser.add_argument('-o', '--output', required=True, help='输出的CSV统计文件路径')
    
    args = parser.parse_args()
    
    # 检查输入文件
    if not os.path.exists(args.input):
        print(f"❌ 输入文件不存在: {args.input}")
        sys.exit(1)
    
    print("SRAM拼接方案统计器")
    print(f"输入文件: {args.input}")
    print(f"输出文件: {args.output}")
    
    # 读取JSON数据
    solution_data = read_solution_json(args.input)
    
    # 提取统计信息
    statistics = extract_sram_statistics(solution_data)
    spec_requirements = extract_sram_spec_requirements(solution_data)
    summary = generate_summary_statistics(solution_data)
    
    print(f"处理了 {len(statistics)} 条SRAM记录")
    print(f"需要 {len(spec_requirements)} 种不同的SRAM规格")
    
    # 保存文件
    save_to_csv(statistics, spec_requirements, summary, args.output)
    
    print(f"\n统计完成!")
    print(f"  模块拼接方案: {args.output}")
    print(f"  SRAM规格需求: {args.output.replace('.csv', '_specs.csv')}")


if __name__ == "__main__":
    main() 