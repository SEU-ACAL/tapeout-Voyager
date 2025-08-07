#!/usr/bin/env python3
"""
IOCell 打拍修改脚本 - 优化版
功能：
1. 保留原有的不打拍IOCell文件用于特殊信号
2. 为需要打拍的IOCell创建新文件(CustomDigitalInIOCellTap等)
3. 修改ChipTop文件，对特殊信号使用原始IOCell，对普通信号使用新的打拍IOCell
4. 更新filelist文件，添加新创建的文件
"""

import re
import os
import sys

def create_tap_iocells(source_dir):
    """创建打拍的IOCell文件，用于普通信号"""
    
    # 创建CustomDigitalInIOCellTap.v文件
    tap_in_cell_content = """//==================================================================//
`define vcs
//======= would be auto replaced by voyager-code-gen.sh ============//

`timescale 1ns/1ps

`ifdef vcs
// `include "../gen-collateral/SPC28NHKCPD18RNP.v"
module CustomDigitalInIOCellTap(
    input pad,
    output i,
    input ie,
    input clk
);

    /* 打拍版本，用于普通信号 */
    wire i_internal;
    reg [9:0] ie_shift_reg;
    reg [9:0] i_shift_reg;

    // ie信号打10拍
    always @(posedge clk) begin
        ie_shift_reg <= {ie_shift_reg[8:0], ie};
    end

    // i信号打10拍
    always @(posedge clk) begin
        i_shift_reg <= {i_shift_reg[8:0], i_internal};
    end

    assign i = i_shift_reg[9];

    PBCD2RNC_X u_PAD_IO (
        .PAD(pad),        // 连接到外部 pad
        .I(),             // 输出数据线
        .OEN(1'b1),       // 输出使能，高电平表示禁用输出（即输入模式）
        .REN(1'b0),
        .IE(!ie_shift_reg[9]), // 输入使能，ie=1启用输入
        .C(i_internal)    // 从 PAD 读入的值
    );

endmodule
`endif // vcs

`ifdef chip
module CustomDigitalInIOCellTap(
    input pad,
    output i,
    input ie,
    input clk
);

    /* 打拍版本，用于普通信号 */
    wire i_internal;
    reg [9:0] ie_shift_reg;
    reg [9:0] i_shift_reg;

    // ie信号打10拍
    always @(posedge clk) begin
        ie_shift_reg <= {ie_shift_reg[8:0], ie};
    end

    // i信号打10拍
    always @(posedge clk) begin
        i_shift_reg <= {i_shift_reg[8:0], i_internal};
    end

    assign i = i_shift_reg[9];

    PBCD2RNC_X u_PAD_IO (
        .PAD(pad),        // 连接到外部 pad
        .I(),             // 输出数据线
        .OEN(1'b1),       // 输出使能，高电平表示禁用输出（即输入模式）
        .REN(1'b0),
        .IE(!ie_shift_reg[9]), // 输入使能，ie=1启用输入
        .C(i_internal)    // 从 PAD 读入的值
    );

endmodule
`endif // chip

`ifdef verilator
module CustomDigitalInIOCellTap(
    input pad,
    output i,
    input ie,
    input clk
);
    reg [9:0] ie_shift_reg;
    reg [9:0] i_shift_reg;
    wire i_internal;
    
    // ie信号打10拍
    always @(posedge clk) begin
        ie_shift_reg <= {ie_shift_reg[8:0], ie};
    end
    
    // i信号打10拍
    always @(posedge clk) begin
        i_shift_reg <= {i_shift_reg[8:0], i_internal};
    end
    
    assign i_internal = ie ? pad : 1'b0;
    assign i = i_shift_reg[9];

endmodule
`endif // verilator
"""
    
    # 创建CustomDigitalOutIOCellTap.v文件
    tap_out_cell_content = """//==================================================================//
`define vcs
//======= would be auto replaced by voyager-code-gen.sh ============//

`timescale 1ns/1ps

`ifdef vcs
// `include "../gen-collateral/SPC28NHKCPD18RNP.v"
module CustomDigitalOutIOCellTap(
    output pad,
    input o,
    input oe,
    input clk
);

    /* 打拍版本，用于普通信号 */
    reg [9:0] oe_shift_reg;
    reg [9:0] o_shift_reg;

    // oe信号打10拍
    always @(posedge clk) begin
        oe_shift_reg <= {oe_shift_reg[8:0], oe};
    end

    // o信号打10拍
    always @(posedge clk) begin
        o_shift_reg <= {o_shift_reg[8:0], o};
    end

    PBCD2RNC_X u_PAD_IO (
        .PAD(pad),        // 连接到外部 pad
        .I(o_shift_reg[9]), // 输出数据线
        .OEN(!oe_shift_reg[9]), // 输出使能，高电平表示禁用输出（即输入模式）
        .REN(1'b0),
        .IE(1'b0),        // 输入使能
        .C()              // 从 PAD 读入的值
    );
    
endmodule
`endif // vcs

`ifdef chip
module CustomDigitalOutIOCellTap(
    output pad,
    input o,
    input oe,
    input clk
);

    /* 打拍版本，用于普通信号 */
    reg [9:0] oe_shift_reg;
    reg [9:0] o_shift_reg;

    // oe信号打10拍
    always @(posedge clk) begin
        oe_shift_reg <= {oe_shift_reg[8:0], oe};
    end

    // o信号打10拍
    always @(posedge clk) begin
        o_shift_reg <= {o_shift_reg[8:0], o};
    end

    PBCD2RNC_X u_PAD_IO (
        .PAD(pad),        // 连接到外部 pad
        .I(o_shift_reg[9]), // 输出数据线
        .OEN(!oe_shift_reg[9]), // 输出使能，高电平表示禁用输出（即输入模式）
        .REN(1'b0),
        .IE(1'b0),        // 输入使能
        .C()              // 从 PAD 读入的值
    );

endmodule
`endif // chip

`ifdef verilator
module CustomDigitalOutIOCellTap(
    output pad,
    input o,
    input oe,
    input clk
);
    reg [9:0] oe_shift_reg;
    reg [9:0] o_shift_reg;

    // oe信号打10拍
    always @(posedge clk) begin
        oe_shift_reg <= {oe_shift_reg[8:0], oe};
    end

    // o信号打10拍
    always @(posedge clk) begin
        o_shift_reg <= {o_shift_reg[8:0], o};
    end
    
    assign pad = oe_shift_reg[9] ? o_shift_reg[9] : 1'bz;

endmodule
`endif // verilator
"""

    # 创建CustomDigitalGPIOCellTap.v文件
    tap_gpio_cell_content = """//==================================================================//
`define vcs
//======= would be auto replaced by voyager-code-gen.sh ============//

`timescale 1ns/1ps

`ifdef vcs
// `include "../gen-collateral/SPC28NHKCPD18RNP.v"
module CustomDigitalGPIOCellTap(
    inout pad,
    output i,
    input ie,
    input o,
    input oe,
    input clk
);

    /* 打拍版本，用于普通信号 */
    wire i_internal;
    reg [9:0] ie_shift_reg;
    reg [9:0] oe_shift_reg;
    reg [9:0] o_shift_reg;
    reg [9:0] i_shift_reg;

    // ie信号打10拍
    always @(posedge clk) begin
        ie_shift_reg <= {ie_shift_reg[8:0], ie};
    end

    // oe信号打10拍
    always @(posedge clk) begin
        oe_shift_reg <= {oe_shift_reg[8:0], oe};
    end

    // o信号打10拍
    always @(posedge clk) begin
        o_shift_reg <= {o_shift_reg[8:0], o};
    end

    // i信号打10拍
    always @(posedge clk) begin
        i_shift_reg <= {i_shift_reg[8:0], i_internal};
    end

    assign i = i_shift_reg[9];

    PBCD2RNC_X u_PAD_IO (
        .PAD(pad),        // 连接到外部 pad
        .I(o_shift_reg[9]), // 输出数据线
        .OEN(!oe_shift_reg[9]), // 输出使能，高电平表示禁用输出（即输入模式）
        .REN(1'b0),
        .IE(!ie_shift_reg[9]), // 输入使能，ie=1启用输入
        .C(i_internal)    // 从 PAD 读入的值
    );

endmodule
`endif // vcs

`ifdef chip
module CustomDigitalGPIOCellTap(
    inout pad,
    output i,
    input ie,
    input o,
    input oe,
    input clk
);

    /* 打拍版本，用于普通信号 */
    wire i_internal;
    reg [9:0] ie_shift_reg;
    reg [9:0] oe_shift_reg;
    reg [9:0] o_shift_reg;
    reg [9:0] i_shift_reg;

    // ie信号打10拍
    always @(posedge clk) begin
        ie_shift_reg <= {ie_shift_reg[8:0], ie};
    end

    // oe信号打10拍
    always @(posedge clk) begin
        oe_shift_reg <= {oe_shift_reg[8:0], oe};
    end

    // o信号打10拍
    always @(posedge clk) begin
        o_shift_reg <= {o_shift_reg[8:0], o};
    end

    // i信号打10拍
    always @(posedge clk) begin
        i_shift_reg <= {i_shift_reg[8:0], i_internal};
    end

    assign i = i_shift_reg[9];

    PBCD2RNC_X u_PAD_IO (
        .PAD(pad),        // 连接到外部 pad
        .I(o_shift_reg[9]), // 输出数据线
        .OEN(!oe_shift_reg[9]), // 输出使能，高电平表示禁用输出（即输入模式）
        .REN(1'b0),
        .IE(!ie_shift_reg[9]), // 输入使能，ie=1启用输入
        .C(i_internal)    // 从 PAD 读入的值
    );

endmodule
`endif // chip

`ifdef verilator
module CustomDigitalGPIOCellTap(
    inout pad,
    output i,
    input ie,
    input o,
    input oe,
    input clk
);
    wire i_internal;
    reg [9:0] ie_shift_reg;
    reg [9:0] oe_shift_reg;
    reg [9:0] o_shift_reg;
    reg [9:0] i_shift_reg;

    // ie信号打10拍
    always @(posedge clk) begin
        ie_shift_reg <= {ie_shift_reg[8:0], ie};
    end

    // oe信号打10拍
    always @(posedge clk) begin
        oe_shift_reg <= {oe_shift_reg[8:0], oe};
    end

    // o信号打10拍
    always @(posedge clk) begin
        o_shift_reg <= {o_shift_reg[8:0], o};
    end

    // i信号打10拍
    always @(posedge clk) begin
        i_shift_reg <= {i_shift_reg[8:0], i_internal};
    end
    
    assign pad = oe_shift_reg[9] ? o_shift_reg[9] : 1'bz;
    assign i_internal = ie_shift_reg[9] ? pad : 1'b0;
    assign i = i_shift_reg[9];

endmodule
`endif // verilator
"""
    
    # 写入文件
    files_to_create = [
        ('CustomDigitalInIOCellTap.v', tap_in_cell_content),
        ('CustomDigitalOutIOCellTap.v', tap_out_cell_content),
        ('CustomDigitalGPIOCellTap.v', tap_gpio_cell_content)
    ]
    
    created_files = []
    
    for filename, content in files_to_create:
        filepath = os.path.join(source_dir, filename)
        with open(filepath, 'w') as f:
            f.write(content)
        created_files.append(filename)
        print(f"✓ 已创建: {filename}")
    
    return created_files

def update_filelist(source_dir, new_files):
    """更新filelist.f文件，添加新创建的文件"""
    filelist_path = os.path.join(source_dir, 'firrtl_black_box_resource_files.f')
    
    if not os.path.exists(filelist_path):
        print(f"⚠ 警告: firrtl_black_box_resource_files.f 文件不存在: {filelist_path}")
        
        # 尝试在上层目录查找
        parent_dir = os.path.dirname(source_dir)
        potential_paths = [
            os.path.join(parent_dir, 'firrtl_black_box_resource_files.f'),
            os.path.join(source_dir, 'gen-collateral', 'firrtl_black_box_resource_files.f'),
            os.path.join(parent_dir, 'gen-collateral', 'firrtl_black_box_resource_files.f')
        ]
        
        for path in potential_paths:
            if os.path.exists(path):
                filelist_path = path
                print(f"✓ 找到替代文件列表: {filelist_path}")
                break
        else:
            # 如果找不到文件，创建一个新的
            print(f"⚠ 无法找到filelist.f，将创建新文件")
            with open(filelist_path, 'w') as f:
                f.write("// 自动生成的filelist.f\n")
                f.write('\n'.join(new_files))
            print(f"✓ 已创建新的filelist.f: {filelist_path}")
            return True
    
    # 读取现有文件内容
    with open(filelist_path, 'r') as f:
        content = f.read().splitlines()
    
    # 检查文件是否已存在
    already_exists = []
    for file in new_files:
        if any(file == line.strip() for line in content):
            already_exists.append(file)
    
    if already_exists:
        print(f"⚠ 以下文件已存在于filelist.f中，将不重复添加: {', '.join(already_exists)}")
        # 移除已存在的文件
        new_files = [f for f in new_files if f not in already_exists]
        
        if not new_files:
            print(f"✓ 所有文件已存在于filelist.f中，无需更新")
            return True
    
    # 定位添加位置 - 查找最后一个IOCell文件或者ChipTop.sv
    insert_index = None
    for marker in ['CustomDigitalInIOCell.v', 'CustomDigitalOutIOCell.v', 'CustomDigitalGPIOCell.v', 'ChipTop.sv']:
        for i, line in enumerate(content):
            if marker in line:
                insert_index = i + 1  # 插入到该文件之后
    
    # 如果没找到插入点，附加到文件末尾
    if insert_index is None:
        print(f"⚠ 在filelist.f中未找到合适的插入点，将附加到文件末尾")
        # 添加一个标记注释和新文件
        content.append("")
        # content.append("// 新添加的自定义IOCell模块")
        content.extend(new_files)
    else:
        # 插入到标记文件之后
        # content.insert(insert_index, "// 新添加的自定义IOCell模块")
        for i, file in enumerate(new_files, 1):
            content.insert(insert_index + i, file)
        print(f"✓ 已在合适位置插入新模块")
    
    # 写回文件
    with open(filelist_path, 'w') as f:
        f.write('\n'.join(content))
    
    print(f"✓ 已更新filelist.f文件，添加了以下模块:")
    for file in new_files:
        print(f"  - {file}")
    
    return True
def modify_chiptop(content):
    """修改ChipTop文件，对特殊信号使用原始IOCell，对普通信号使用新的打拍IOCell"""
    
    # 修正REN和OEN常值的写法 (1\'b0 -> 1'b0)
    content = content.replace("1\\'b0", "1'b0")
    content = content.replace("1\\'b1", "1'b1")
    
    # 添加时钟信号定义（如果尚未定义）
    if "wire _iocell_clock_10tap;" not in content:
        # 查找合适的插入点
        insert_point = content.find("wire        _system_auto_cbus_fixedClockNode_anon_out_clock;")
        if insert_point != -1:
            # 在定义该信号后添加10拍时钟定义
            clock_def = """
  // IOCell 10拍时钟信号
  wire _iocell_clock_10tap;
  
  // 连接到系统时钟
  assign _iocell_clock_10tap = _system_auto_cbus_fixedClockNode_anon_out_clock;"""
            
            content = content[:insert_point] + content[insert_point:].replace(
                "wire        _system_auto_cbus_fixedClockNode_anon_out_clock;",
                "wire        _system_auto_cbus_fixedClockNode_anon_out_clock;" + clock_def
            )
    
    # 检查并删除重复的_iocell_clock_10tap定义
    duplicate_pattern = r'(// IOCell 10拍时钟信号\s*\n\s*wire _iocell_clock_10tap;\s*\n\s*\n\s*// 连接到系统时钟\s*\n\s*assign _iocell_clock_10tap = [^;]+;).*?\1'
    content = re.sub(duplicate_pattern, r'\1', content, flags=re.DOTALL)
    
    # 定义特殊信号，这些信号不需要打拍
    special_signals = [
        'clock', 'reset', 
        'jtag_TCK', 'jtag_TMS', 'jtag_TDI', 'jtag_TDO', 
        'serial_tl_0_clock_in',
        'serial_tl_0_in_ready', 'serial_tl_0_in_valid', 
        'serial_tl_0_out_ready', 'serial_tl_0_out_valid'
        # 'spi_flash_0_sck','spi_flash_0_cs_0',
        # 'spi_flash_0_dq_0',
        # 'spi_flash_0_dq_1',
        # 'spi_flash_0_dq_2',
        # 'spi_flash_0_dq_3'
    ]
    
    # 添加serial_tl_0_in_bits_phit_0到serial_tl_0_in_bits_phit_31
    for i in range(32):
        special_signals.append(f'serial_tl_0_in_bits_phit_{i}')
        
    # 添加serial_tl_0_out_bits_phit_0到serial_tl_0_out_bits_phit_31
    for i in range(32):
        special_signals.append(f'serial_tl_0_out_bits_phit_{i}')
    
    # 正则表达式模式，匹配所有普通IOCell实例（排除特殊信号）
    # 匹配并替换CustomDigitalInIOCell（但不是特殊信号）
    in_iocell_pattern = r'(CustomDigitalInIOCell\s+(?!iocell_(?:' + '|'.join(special_signals) + '))\w+\s*\()([^;]*?)(\);)'
    
    def replace_in_normal_iocell(match):
        instance_prefix = match.group(1)
        instance_body = match.group(2)
        instance_suffix = match.group(3)
        
        # 替换为打拍的IOCell
        new_instance_prefix = instance_prefix.replace('CustomDigitalInIOCell', 'CustomDigitalInIOCellTap')
        
        # 添加时钟参数
        # 处理带注释的情况
        parts = instance_body.split('\n')
        if len(parts) <= 1:
            # 单行实例，直接添加时钟
            new_instance_body = f"{instance_body},\n    .clk (_iocell_clock_10tap)"
        else:
            # 多行实例，找到最后一个参数行
            last_param_idx = -1
            for i in range(len(parts)-1, -1, -1):
                if re.search(r'\.(\w+)\s*\([^)]*\)', parts[i].strip()):
                    last_param_idx = i
                    break
            
            if last_param_idx == -1:
                # 没找到参数行，直接添加时钟
                new_instance_body = f"{instance_body},\n    .clk (_iocell_clock_10tap)"
            else:
                # 在最后一个参数后添加逗号，然后添加时钟参数
                last_param = parts[last_param_idx]
                
                # 根据是否有注释修改最后一行
                if '//' in last_param:
                    param_part, comment_part = last_param.split('//', 1)
                    parts[last_param_idx] = f"{param_part.rstrip()}, // {comment_part}"
                else:
                    parts[last_param_idx] = f"{last_param.rstrip()},"
                
                # 添加时钟参数
                parts.insert(last_param_idx + 1, "    .clk (_iocell_clock_10tap)")
                
                new_instance_body = '\n'.join(parts)
        
        return new_instance_prefix + new_instance_body + instance_suffix
    
    content = re.sub(in_iocell_pattern, replace_in_normal_iocell, content, flags=re.DOTALL)
    
    # 匹配并替换CustomDigitalOutIOCell（但不是特殊信号）
    out_iocell_pattern = r'(CustomDigitalOutIOCell\s+(?!iocell_(?:' + '|'.join(special_signals) + '))\w+\s*\()([^;]*?)(\);)'
    
    def replace_out_normal_iocell(match):
        instance_prefix = match.group(1)
        instance_body = match.group(2)
        instance_suffix = match.group(3)
        
        # 替换为打拍的IOCell
        new_instance_prefix = instance_prefix.replace('CustomDigitalOutIOCell', 'CustomDigitalOutIOCellTap')
        
        # 添加时钟参数
        # 处理带注释的情况
        parts = instance_body.split('\n')
        if len(parts) <= 1:
            # 单行实例，直接添加时钟
            new_instance_body = f"{instance_body},\n    .clk (_iocell_clock_10tap)"
        else:
            # 多行实例，找到最后一个参数行
            last_param_idx = -1
            for i in range(len(parts)-1, -1, -1):
                if re.search(r'\.(\w+)\s*\([^)]*\)', parts[i].strip()):
                    last_param_idx = i
                    break
            
            if last_param_idx == -1:
                # 没找到参数行，直接添加时钟
                new_instance_body = f"{instance_body},\n    .clk (_iocell_clock_10tap)"
            else:
                # 在最后一个参数后添加逗号，然后添加时钟参数
                last_param = parts[last_param_idx]
                
                # 根据是否有注释修改最后一行
                if '//' in last_param:
                    param_part, comment_part = last_param.split('//', 1)
                    parts[last_param_idx] = f"{param_part.rstrip()}, // {comment_part}"
                else:
                    parts[last_param_idx] = f"{last_param.rstrip()},"
                
                # 添加时钟参数
                parts.insert(last_param_idx + 1, "    .clk (_iocell_clock_10tap)")
                
                new_instance_body = '\n'.join(parts)
        
        return new_instance_prefix + new_instance_body + instance_suffix
    
    content = re.sub(out_iocell_pattern, replace_out_normal_iocell, content, flags=re.DOTALL)
    
    # 匹配并替换CustomDigitalGPIOCell（但不是特殊信号）
    gpio_iocell_pattern = r'(CustomDigitalGPIOCell\s+(?!iocell_(?:' + '|'.join(special_signals) + '))\w+\s*\()([^;]*?)(\);)'
    
    def replace_gpio_normal_iocell(match):
        instance_prefix = match.group(1)
        instance_body = match.group(2)
        instance_suffix = match.group(3)
        
        # 替换为打拍的IOCell
        new_instance_prefix = instance_prefix.replace('CustomDigitalGPIOCell', 'CustomDigitalGPIOCellTap')
        
        # 添加时钟参数
        # 处理带注释的情况
        parts = instance_body.split('\n')
        if len(parts) <= 1:
            # 单行实例，直接添加时钟
            new_instance_body = f"{instance_body},\n    .clk (_iocell_clock_10tap)"
        else:
            # 多行实例，找到最后一个参数行
            last_param_idx = -1
            for i in range(len(parts)-1, -1, -1):
                if re.search(r'\.(\w+)\s*\([^)]*\)', parts[i].strip()):
                    last_param_idx = i
                    break
            
            if last_param_idx == -1:
                # 没找到参数行，直接添加时钟
                new_instance_body = f"{instance_body},\n    .clk (_iocell_clock_10tap)"
            else:
                # 在最后一个参数后添加逗号，然后添加时钟参数
                last_param = parts[last_param_idx]
                
                # 根据是否有注释修改最后一行
                if '//' in last_param:
                    param_part, comment_part = last_param.split('//', 1)
                    parts[last_param_idx] = f"{param_part.rstrip()}, // {comment_part}"
                else:
                    parts[last_param_idx] = f"{last_param.rstrip()},"
                
                # 添加时钟参数
                parts.insert(last_param_idx + 1, "    .clk (_iocell_clock_10tap)")
                
                new_instance_body = '\n'.join(parts)
        
        return new_instance_prefix + new_instance_body + instance_suffix
    
    content = re.sub(gpio_iocell_pattern, replace_gpio_normal_iocell, content, flags=re.DOTALL)
    
    # 清理可能出现的多个.clk参数
    content = re.sub(
        r'\.clk\s*\(_iocell_clock_10tap\),\s*\n\s*\.clk\s*\(_iocell_clock_10tap\)',
        r'.clk (_iocell_clock_10tap)',
        content,
        flags=re.DOTALL
    )
    
    # 最终检查全文是否还有错误写法
    content = content.replace("1\\'b0", "1'b0")
    content = content.replace("1\\'b1", "1'b1")
    
    return content

def process_files(source_dir):
    """处理所有IOCell相关文件"""
    
    # 创建打拍的IOCell文件
    new_files = create_tap_iocells(source_dir)
    
    # 更新filelist文件
    update_filelist(source_dir, new_files)
    
    # 修改ChipTop文件
    chipTop_path = os.path.join(source_dir, 'ChipTop.sv')
    if os.path.exists(chipTop_path):
        print(f"处理文件: ChipTop.sv")
        
        with open(chipTop_path, 'r') as f:
            content = f.read()
        
        # 应用修改
        modified_content = modify_chiptop(content)
        
        # 再次全局检查常量写法
        modified_content = modified_content.replace("1\\'b0", "1'b0")
        modified_content = modified_content.replace("1\\'b1", "1'b1")
        
        # 写回文件
        with open(chipTop_path, 'w') as f:
            f.write(modified_content)
        
        print(f"✓ 已修改: ChipTop.sv")
    else:
        print(f"⚠ 警告: 文件 ChipTop.sv 不存在")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        source_dir = sys.argv[1]
    else:
        source_dir = os.getcwd()
    
    if not os.path.exists(source_dir):
        print(f"错误: 目录 {source_dir} 不存在")
        sys.exit(1)
    
    print("开始修改IOCell文件，为需要打拍的信号创建新文件...")
    process_files(source_dir)
    print("IOCell修改完成!")