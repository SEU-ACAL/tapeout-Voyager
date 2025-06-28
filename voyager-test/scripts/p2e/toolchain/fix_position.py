#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re
import sys
import os

def fix_xepic_position(filename):
    """修正XEPIC代码在XilinxVCU118MIGIsland.sv中的位置"""
    
    print("开始修正XEPIC代码位置...")
    
    if not os.path.exists(filename):
        print("错误: 文件 {} 不存在".format(filename))
        return False
    
    # 读取文件内容
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    # 找到关键位置
    axi4asink_end_line = -1
    vcu118mig_start_line = -1
    xepic_start_line = -1
    xepic_end_line = -1
    
    # 扫描文件找到关键位置
    for i, line in enumerate(lines):
        # 找到axi4asink模块的结束位置
        if 'auto_out_r_ready' in line and '_axi4asink_auto_out_r_ready' in line:
            # 检查下一行是否是 ");", 表示模块结束
            if i + 1 < len(lines) and re.match(r'^\s*\);\s*$', lines[i + 1]):
                axi4asink_end_line = i + 1
        
        # 找到vcu118mig模块的开始位置
        if 'vcu118mig blackbox' in line:
            vcu118mig_start_line = i
        
        # 找到XEPIC代码块
        if '`ifdef XEPIC_P2E' in line:
            xepic_start_line = i
        
        if '`endif' in line and xepic_start_line != -1 and xepic_end_line == -1:
            xepic_end_line = i
    
    print("关键位置:")
    print("  axi4asink结束行: {}".format(axi4asink_end_line))
    print("  vcu118mig开始行: {}".format(vcu118mig_start_line))
    print("  XEPIC开始行: {}".format(xepic_start_line))
    print("  XEPIC结束行: {}".format(xepic_end_line))
    
    # 创建正确的XEPIC代码块
    correct_xepic_code = [
        '\n',
        '`ifdef XEPIC_P2E\n',
        '        logic  [1:0]                      xram0_read;        \n',
        '        logic  [127:0]                    xram0_read_addr;  \n',
        '        logic  [1:0]                      xram0_read_data_ready; \n',
        '        logic  [1:0]                      xram0_write;       \n',
        '        logic  [127:0]                    xram0_write_addr; \n',
        '        logic  [1151:0]                   xram0_write_data;    \n',
        '        logic  [127:0]                    xram0_write_data_mask;\n',
        '        \n',
        '        logic  [1151:0]                   xram0_read_data;    \n',
        '        logic  [1:0]                      xram0_read_data_valid;\n',
        '        logic                             mmp_ddr4_calib_done;\n',
        '\n',
        '         // slave0 slave-embeded, support burst control\n',
        '         defparam u_axi_xram.AXI_MODE = 4;  // AXI Mode: 3 = AXI3, 4 = AXI4\n',
        '         defparam u_axi_xram.AXI_ID_WIDTH   = 4;\n',
        '         defparam u_axi_xram.AXI_DATA_WIDTH = 64;   // Data Width: 8,16,32,64,128,256,512,1024 \n',
        '         defparam u_axi_xram.AXI_ADDR_WIDTH = 32;  // Addr Width: 32..64\n',
        '         defparam u_axi_xram.AXI_USER_WIDTH = 0;  // \n',
        '         defparam u_axi_xram.MEM_SIZE = 64\'h4_0000_0000;  // 2^34\n',
        ' \n',
        '         xaxi4_slave_emb u_axi_xram ( //or xaxi4_slave_emb_wrapper\n',
        '            /*AUTOARG*/\n',
        '            .aclk      (io_port_c0_sys_clk_i),\n',
        '            .aresetn   (~io_port_sys_rst),\n',
        '            // AXI write address channel\n',
        '            .i_awvalid (_axi4asink_auto_out_aw_valid),\n',
        '            .o_awready (_blackbox_c0_ddr4_s_axi_awready),\n',
        '            .i_awid    (_axi4asink_auto_out_aw_bits_id),\n',
        '            .i_awaddr  (_axi4asink_auto_out_aw_bits_addr[30:0]),\n',
        '            .i_awlen   (_axi4asink_auto_out_aw_bits_len),     // in AXI3 .mode    (mode    ), [7:4] should be fixed to 0\n',
        '            .i_awsize  (_axi4asink_auto_out_aw_bits_size),\n',
        '            .i_awburst (_axi4asink_auto_out_aw_bits_burst),\n',
        '            .i_awlock  (_axi4asink_auto_out_aw_bits_lock),\n',
        '            .i_awcache (4\'h3),\n',
        '            .i_awprot  (_axi4asink_auto_out_aw_bits_prot),\n',
        '            .i_awqos   (_axi4asink_auto_out_aw_bits_qos),\n',
        '            .i_awregion(4\'b0),\n',
        '            // AXI write data channel\n',
        '            .i_wvalid  (_axi4asink_auto_out_w_valid),\n',
        '            .o_wready  (_blackbox_c0_ddr4_s_axi_wready),\n',
        '            .i_wid     (0),\n',
        '            .i_wdata   (_axi4asink_auto_out_w_bits_data),\n',
        '            .i_wstrb   (_axi4asink_auto_out_w_bits_strb),\n',
        '            .i_wlast   (_axi4asink_auto_out_w_bits_last),\n',
        '            // AXI write response channel\n',
        '            .o_bvalid  (_blackbox_c0_ddr4_s_axi_bvalid),\n',
        '            .i_bready  (_axi4asink_auto_out_b_ready),\n',
        '            .o_bid     (_blackbox_c0_ddr4_s_axi_bid),\n',
        '            .o_bresp   (_blackbox_c0_ddr4_s_axi_bresp),\n',
        '\n',
        '            // AXI read address channel\n',
        '            .i_arvalid (_axi4asink_auto_out_ar_valid),\n',
        '            .o_arready (_blackbox_c0_ddr4_s_axi_arready),\n',
        '            .i_arid    (_axi4asink_auto_out_ar_bits_id),\n',
        '            .i_araddr  (_axi4asink_auto_out_ar_bits_addr[30:0]),\n',
        '            .i_arlen   (_axi4asink_auto_out_ar_bits_len),     // in AXI3 .mode    (mode    ), [7:4] should be fixed to 0\n',
        '            .i_arsize  (_axi4asink_auto_out_ar_bits_size),\n',
        '            .i_arburst (_axi4asink_auto_out_ar_bits_burst),\n',
        '            .i_arlock  (_axi4asink_auto_out_ar_bits_lock),\n',
        '            .i_arcache (4\'h3),\n',
        '            .i_arprot  (_axi4asink_auto_out_ar_bits_prot),\n',
        '            .i_arqos   (_axi4asink_auto_out_ar_bits_qos),\n',
        '            .i_arregion(4\'b0),\n',
        '            // AXI read response\n',
        '            .o_rvalid  (_blackbox_c0_ddr4_s_axi_rvalid),\n',
        '            .i_rready  (_axi4asink_auto_out_r_ready),\n',
        '            .o_rid     (_blackbox_c0_ddr4_s_axi_rid),\n',
        '            .o_rresp   (_blackbox_c0_ddr4_s_axi_rresp),\n',
        '            .o_rdata   (_blackbox_c0_ddr4_s_axi_rdata),\n',
        '            .o_rlast   (_blackbox_c0_ddr4_s_axi_rlast)\n',
        '            );\n',
        '    \n',
        '        `ifdef XEPIC_XRAM_RTL\n',
        '          xram_bbox_wrapper u_xram_bbox_wrapper (\n',
        '              .uclk(io_port_c0_sys_clk_i),\n',
        '              .xram0_read(xram0_read),\n',
        '              .xram0_read_addr(xram0_read_addr),\n',
        '              .xram0_read_data_ready(xram0_read_data_ready),\n',
        '              .xram0_write(xram0_write),\n',
        '              .xram0_write_addr(xram0_write_addr),\n',
        '              .xram0_write_data(xram0_write_data),\n',
        '              .xram0_write_data_mask(xram0_write_data_mask),\n',
        '              .xram0_read_data(xram0_read_data),\n',
        '              .xram0_read_data_valid(xram0_read_data_valid), \n',
        '              .mmp_ddr4_calib_done(_blackbox_c0_init_calib_complete)\n',
        '          )/* synthesis syn_preserve=1 */;\n',
        '\n',
        '          assign xram0_write[0]                  = u_axi_xram.write_xram;\n',
        '          assign xram0_write_addr[0 +: 64]       = u_axi_xram.wr_addr_xram ;\n',
        '          assign xram0_write_data[0 +: 576]      = u_axi_xram.wrdata_xram;\n',
        '          assign xram0_write_data_mask[0 +: 64]  = u_axi_xram.wrdata_mask_xram;\n',
        '\n',
        '          assign xram0_read[0]                   = 1\'h0;\n',
        '          assign xram0_read_addr[0 +: 64]        = 64\'h0;\n',
        '          assign xram0_read_data_ready[0]        = 1\'h0;\n',
        '\n',
        '\n',
        '          assign u_axi_xram.init_calib_complete = _blackbox_c0_init_calib_complete;\n',
        '\n',
        '          assign xram0_write[1]                  = 1\'h0;\n',
        '          assign xram0_write_addr[64 +: 64]      = 64\'h0;\n',
        '          assign xram0_write_data[576 +: 576]    = 576\'h0;\n',
        '          assign xram0_write_data_mask[64 +: 64] = 64\'h0;\n',
        '\n',
        '          assign xram0_read[1]                   = u_axi_xram.read_xram;        \n',
        '          assign xram0_read_addr[64 +: 64]       = u_axi_xram.rd_addr_xram;     \n',
        '          assign xram0_read_data_ready[1]        = u_axi_xram.rddata_ready_xram;\n',
        '          assign u_axi_xram.rddata_xram        = xram0_read_data[576 +: 576];\n',
        '          assign u_axi_xram.rddata_valid_xram  = xram0_read_data_valid[1];\n',
        '        `endif\n',
        '        assign io_port_c0_ddr4_ui_clk = io_port_c0_sys_clk_i;\n',
        '        assign io_port_c0_ddr4_ui_clk_sync_rst = 1\'b0;\n',
        '\n',
        '`else\n'
    ]
    
    # 注意：这个函数只处理XEPIC代码块的位置，不处理完整的条件编译结构
    # 完整的结构应该在文件的其他地方有对应的vcu118mig模块和endif
    
    # 情况1: 没有XEPIC代码，需要添加
    if xepic_start_line == -1:
        print("没有找到XEPIC代码，将在正确位置添加...")
        insert_pos = axi4asink_end_line + 1
        final_lines = lines[:insert_pos] + correct_xepic_code + lines[insert_pos:]
        
        # 写回文件
        with open(filename, 'w') as f:
            f.writelines(final_lines)
        
        print("XEPIC代码添加完成！")
        print("文件行数: {}".format(len(final_lines)))
        return True
    
    # 情况2: XEPIC代码在错误位置（在vcu118mig之后）
    elif xepic_start_line > vcu118mig_start_line:
        print("检测到XEPIC代码在错误位置，开始修正...")
        
        # 从原始位置删除XEPIC代码
        new_lines = lines[:xepic_start_line] + lines[xepic_end_line + 1:]
        
        # 在正确位置插入XEPIC代码（axi4asink结束后）
        insert_pos = axi4asink_end_line + 1
        final_lines = new_lines[:insert_pos] + correct_xepic_code + new_lines[insert_pos:]
        
        # 写回文件
        with open(filename, 'w') as f:
            f.writelines(final_lines)
        
        print("XEPIC代码位置修正完成！")
        print("文件行数: {}".format(len(final_lines)))
        return True
    
    # 情况3: XEPIC代码位置已经正确
    else:
        print("XEPIC代码位置已经正确，无需修正")
        return True

def main():
    import sys
    if len(sys.argv) > 1:
        filename = sys.argv[1]
    else:
        filename = "modified_v/XilinxVCU118MIGIsland.sv"
    
    if fix_xepic_position(filename):
        print("位置修正成功！")
        
        # 验证结果
        with open(filename, 'r') as f:
            content = f.read()
        
        if '`ifdef XEPIC_P2E' in content:
            print("✓ XEPIC宏定义存在")
            
            # 检查位置
            lines = content.split('\n')
            axi4asink_line = -1
            xepic_line = -1
            vcu118mig_line = -1
            
            for i, line in enumerate(lines):
                if 'auto_out_r_ready' in line and '_axi4asink_auto_out_r_ready' in line:
                    axi4asink_line = i
                if '`ifdef XEPIC_P2E' in line:
                    xepic_line = i
                if 'vcu118mig blackbox' in line:
                    vcu118mig_line = i
            
            if axi4asink_line != -1 and xepic_line != -1 and vcu118mig_line != -1:
                if axi4asink_line < xepic_line < vcu118mig_line:
                    print("✓ XEPIC代码位置正确 (行 {} < {} < {})".format(axi4asink_line, xepic_line, vcu118mig_line))
                else:
                    print("✗ XEPIC代码位置仍然不正确")
        else:
            print("✗ XEPIC宏定义未找到")
    else:
        print("位置修正失败！")
        sys.exit(1)

if __name__ == "__main__":
    main() 