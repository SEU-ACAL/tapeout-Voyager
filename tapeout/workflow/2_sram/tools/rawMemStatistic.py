import json
import csv
import pandas as pd
import argparse
import os
from collections import defaultdict

def main():
    # 解析命令行参数
    parser = argparse.ArgumentParser(description='分析SRAM设计数据并生成CSV报告')
    parser.add_argument('-i', '--input', help='seq_mems.json文件的路径')
    parser.add_argument('-o', '--output', help='输出CSV文件路径')
    
    args = parser.parse_args()
    
    # 检查输入文件是否存在
    if not os.path.exists(args.input):
        print(f"错误: 文件 '{args.input}' 不存在")
        return
    
    # 获取输入文件的目录
    input_dir = os.path.dirname(os.path.abspath(args.input))
    
    # 生成输出文件路径（在输入文件的相同目录下）
    output_csv = os.path.join(input_dir, args.output)
    
    print(f"读取文件: {args.input}")
    print(f"输出文件: {output_csv}")
    
    # 读取JSON文件
    try:
        with open(args.input, 'r') as f:
            sram_data = json.load(f)
    except Exception as e:
        print(f"错误: 无法读取JSON文件 - {e}")
        return

    # 分析SRAM数据
    analysis_data = []

    for sram in sram_data:
        # 计算总容量（深度 * 宽度 / 8，单位：字节）
        capacity_bytes = sram['depth'] * sram['width'] / 8
        capacity_kb = capacity_bytes / 1024
        
        # 计算层次结构中的实例数量
        instance_count = len(sram['hierarchy'])
        
        # 计算总端口数
        total_ports = sram['read'] + sram['write'] + sram['readwrite']
        
        # 提取模块类型（从层次结构中推断）
        module_type = "Unknown"
        if any("cache" in h.lower() for h in sram['hierarchy']):
            module_type = "Cache"
        elif any("btb" in h.lower() or "bpd" in h.lower() for h in sram['hierarchy']):
            module_type = "Branch Predictor"
        elif any("rob" in h.lower() for h in sram['hierarchy']):
            module_type = "ROB"
        elif any("tlb" in h.lower() for h in sram['hierarchy']):
            module_type = "TLB"
        elif any("spad" in h.lower() for h in sram['hierarchy']):
            module_type = "Scratchpad"
        elif any("ram" in h.lower() for h in sram['hierarchy']):
            module_type = "Main Memory"
        elif any("register" in h.lower() or "rf" in h.lower() for h in sram['hierarchy']):
            module_type = "Register File"
        elif any("ftq" in h.lower() for h in sram['hierarchy']):
            module_type = "Fetch Queue"
        elif any("lsl" in h.lower() or "icsl" in h.lower() or "elu" in h.lower() for h in sram['hierarchy']):
            module_type = "Load Store Queue"
        
        analysis_data.append({
            '模块名称': sram['module_name'],
            '深度': sram['depth'],
            '宽度': sram['width'],
            '单个容量(KB)': round(capacity_kb, 2),
            '实例数量': instance_count,
            '总容量(KB)': round(capacity_kb * instance_count, 2),
            '是否掩码': '是' if sram['masked'] else '否',
            '掩码粒度': sram.get('mask_granularity', 'N/A'),
            '读端口': sram['read'],
            '写端口': sram['write'],
            '读写端口': sram['readwrite'],
            '总端口数': total_ports,
            '模块类型': module_type,
            '层次结构示例': sram['hierarchy'][0] if sram['hierarchy'] else 'N/A'
        })

    # 创建DataFrame
    df = pd.DataFrame(analysis_data)

    # 保存为CSV
    try:
        df.to_csv(output_csv, index=False, encoding='utf-8-sig')
        print(f"CSV文件已生成: {output_csv}")
    except Exception as e:
        print(f"错误: 无法保存CSV文件 - {e}")
        return

    # 生成统计信息
    stats = {
        '总SRAM模块数': len(sram_data),
        '总实例数': sum(len(sram['hierarchy']) for sram in sram_data),
        '总容量(KB)': sum(row['总容量(KB)'] for row in analysis_data),
        '模块类型分布': df['模块类型'].value_counts().to_dict()
    }

    print("\n" + "="*50)
    print("SRAM分析完成！")
    print("="*50)
    print(f"总共有 {stats['总SRAM模块数']} 种不同的SRAM模块")
    print(f"总共有 {stats['总实例数']} 个SRAM实例")
    print(f"总容量约为 {stats['总容量(KB)']:.2f} KB ({stats['总容量(KB)']/1024:.2f} MB)")
    print("\n模块类型分布：")
    for module_type, count in stats['模块类型分布'].items():
        print(f"  {module_type}: {count} 个模块")

if __name__ == "__main__":
    main() 