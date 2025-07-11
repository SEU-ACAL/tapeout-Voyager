#!/bin/bash

# 严格模式设置
set -euo pipefail
IFS=$'\n\t'

CYDIR=$(git rev-parse --show-toplevel)
SCRIPT_DIR=$CYDIR/voyager-test/scripts/p2e
OUTPUT_DIR=$SCRIPT_DIR/../../output/p2e
GEN_DIR=$OUTPUT_DIR/gen-collateral

ROM_TYPE=""
SRC_DIR=""
ROM_SRC_DIR=""

# 检查bash版本
check_bash_version() {
    local current_version
    current_version=$(bash --version | head -n1 | grep -oP '\d+\.\d+' | head -1)
    
    if ! version_ge "$current_version" "$REQUIRED_BASH_VERSION"; then
        echo "需要bash版本 >= $REQUIRED_BASH_VERSION，当前版本: $current_version"
    fi

}

# 检查Python版本
check_python_version() {
    if ! command -v python >/dev/null 2>&1; then
        echo "未找到python命令，请安装Python >= $REQUIRED_PYTHON_VERSION"
    fi
    
    local python_version
    python_version=$(python --version 2>&1 | grep -oP '\d+\.\d+' | head -1)
    
    if ! version_ge "$python_version" "$REQUIRED_PYTHON_VERSION"; then
        echo "需要Python版本 >= $REQUIRED_PYTHON_VERSION，当前版本: $python_version"
    fi

}

# 版本比较函数
version_ge() {
    printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1 | grep -q "^$2$"
}

# 检查必需的命令
check_required_commands() {
    local required_commands=("sed" "grep" "cp" "mkdir" "rm" "wc")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        echo "缺少必需的命令: ${missing_commands[*]}"
    fi

}

# =============================================================================
# 参数解析和验证
# =============================================================================

#
# 环境检查
check_environment() {
    # 设置路径变量
    SRC_DIR="$GEN_DIR"
    ROM_SRC_DIR="$OUTPUT_DIR/TLROM"
}

# =============================================================================
# 核心功能函数
# =============================================================================

# 创建输出目录
setup_output_directory() {
    mkdir -p "$SRC_DIR"
    mkdir -p "$ROM_SRC_DIR"
}

# 处理TLROM文件
process_tlrom() {
    echo "TLROM.sv 处理完成"
}

# 处理Rocket.sv - 添加调试追踪标记
process_rocket() {
    local src_file="$SRC_DIR/Rocket.sv"
    
    if [[ ! -f "$src_file" ]]; then
        echo "Rocket.sv文件不存在: $src_file"
        return 1
    fi
    
    # 添加调试追踪标记
    local trace_signals=("ctrl_killx" "dcache_kill_mem" "killm_common" "wb_set_sboard" "id_sboard_hazard" "ctrl_killm")
    
    for signal in "${trace_signals[@]}"; do
        sed -i "s/^  wire             ${signal} = /  (* trace_net *) wire             ${signal} = /" "$src_file"
    done
    
    echo "Rocket.sv处理完成，已添加 ${#trace_signals[@]} 个trace标记"
}

# 处理VCU118FPGATestHarness.sv - 添加XEPIC支持
process_test_harness() {
    local src_file="$SRC_DIR/VCU118FPGATestHarness.sv"
    
    if [[ ! -f "$src_file" ]]; then
        echo "VCU118FPGATestHarness.sv文件不存在: $src_file"
        return 1
    fi
    
    echo "添加XEPIC宏定义"
    # 在第2行后添加XEPIC宏定义
    echo "添加XEPIC宏定义"
    # 在module声明之前添加XEPIC宏定义
    sed -i '/^module /i\
`define XEPIC_P2E\
`define XEPIC_XRAM_RTL\
' "$src_file"

    echo "1: fpgaPLLIn_reset"
    # 修改fpgaPLLIn_reset信号，添加条件编译
    sed -i '/assign fpgaPLLIn_reset = _resetIBUF_O | _powerOnReset_fpga_power_on_power_on_reset;/c\
`ifndef XEPIC_P2E\
assign fpgaPLLIn_reset = _resetIBUF_O | _powerOnReset_fpga_power_on_power_on_reset;\
`else\
assign fpgaPLLIn_reset = reset | _powerOnReset_fpga_power_on_power_on_reset;\
`endif' "$src_file"

    echo "2: 系统时钟输入"
    # 修改系统时钟接口
    sed -i '/^  input         sys_clock_p,/,/^  input         sys_clock_n,/c\
`ifndef XEPIC_P2E\
  input         sys_clock_p,\
                sys_clock_n,\
`else\
  input                clock,\
  output        sdio_sel,\
`endif' "$src_file"

    echo "3: FPGA时钟输入"
    # 修改FPGA时钟接口
    sed -i '/^  input         fpga_clock_p,/,/^  input         fpga_clock_n,/c\
`ifndef XEPIC_P2E\
  input         fpga_clock_p,\
                fpga_clock_n,\
`else\
  input                clock_2,\
`endif' "$src_file"

    echo "4-9: 删除原始实例"
    export TARGET_FILE="$src_file"
    python << 'EOF'
import os

filename = os.environ.get('TARGET_FILE')
with open(filename, 'r') as f:
    lines = f.readlines()

new_lines = []
i = 0
while i < len(lines):
    line = lines[i].strip()
    
    # 检查是否是要删除的实例开始
    if (line.startswith('IBUFDS #(') or 
        line.startswith('fpgaPLL fpgaPLL (') or
        line.startswith('harnessSysPLL harnessSysPLL (') or
        line.startswith('IBUF ') or
        line.startswith('PowerOnResetFPGAOnly ')):
        
        # 跳过直到找到实例结束 );
        while i < len(lines):
            if lines[i].strip().endswith(');') or lines[i].strip().startswith(');'):
                i += 1  # 跳过结束行
                break
            i += 1
    else:
        new_lines.append(lines[i])
        i += 1

with open(filename, 'w') as f:
    f.writelines(new_lines)
EOF

    echo "10: 添加条件编译块"
    # 在AnalogToUInt_1 a2b_4实例后添加完整的条件编译块
    sed -i '/AnalogToUInt_1 a2b_4 (/,/);/ {
        /);/ a\
\
`ifndef XEPIC_P2E\
  IBUFDS #(\
    .DIFF_TERM("FALSE"),\
    .IOSTANDARD("DEFAULT"),\
    .DQS_BIAS("FALSE"),\
    .CAPACITANCE("DONT_CARE"),\
    .IFD_DELAY_VALUE("AUTO"),\
    .IBUF_LOW_PWR("TRUE"),\
    .IBUF_DELAY_VALUE(0)\
  ) sys_clock_ibufds (\
    .I  (sys_clock_p),\
    .IB (sys_clock_n),\
    .O  (_sys_clock_ibufds_O)\
  );\
\
  harnessSysPLL harnessSysPLL (\
    .clk_in1  (_sys_clock_ibufds_O),\
    .reset    (_WIRE),\
    .clk_out1 (_harnessSysPLL_clk_out1),\
    .locked   (_harnessSysPLL_locked)\
  );\
\
  IBUF resetIBUF (\
    .I (reset),\
    .O (_resetIBUF_O)\
  );\
\
  PowerOnResetFPGAOnly powerOnReset_fpga_power_on (\
    .clock          (_sys_clock_ibufds_O),\
    .power_on_reset (_powerOnReset_fpga_power_on_power_on_reset)\
  );\
`else\
  assign _sys_clock_ibufds_O = clock;\
  assign _harnessSysPLL_clk_out1 = clock;\
  assign _harnessSysPLL_locked = 1;\
  assign _fpga_clock_ibufds_O = clock_2;\
  assign _fpgaPLL_clk_out1 = clock_2;\
  assign _fpgaPLL_locked = 1;\
\
  PowerOnResetFPGAOnly powerOnReset_fpga_power_on (\
    .clock          (clock),\
    .power_on_reset (_powerOnReset_fpga_power_on_power_on_reset)\
  );\
`endif\
\
assign sdio_sel = 1'\''b0;
    }' "$src_file"

    echo "确保endmodule存在"
    # 检查文件末尾几行是否包含endmodule，如果没有则添加
    if ! tail -n 5 "$src_file" | grep -q "endmodule"; then
        echo "endmodule" >> "$src_file"
        echo "已添加endmodule"
    fi

    echo "VCU118FPGATestHarness.sv处理完成"
}

# 处理XilinxVCU118MIGIsland.sv - 添加XRAM接口
process_mig_island() {
    local src_file="$SRC_DIR/XilinxVCU118MIGIsland.sv"
    
    if [[ ! -f "$src_file" ]]; then
        echo "XilinxVCU118MIGIsland.sv文件不存在: $src_file"
        return 1
    fi
    
    # 在第2行后添加XEPIC宏定义
    sed -i '2a\
`define XEPIC_P2E\
`define XEPIC_XRAM_RTL' "$src_file"

    # 删除原来的_blackbox_c0_init_calib_complete声明行
    sed -i '/^  wire        _blackbox_c0_init_calib_complete;.*XilinxVCU118MIG.scala/d' "$src_file"

    # 在_axi4asink_auto_out_r_ready行后添加复位逻辑
    sed -i '/^  wire        _axi4asink_auto_out_r_ready;/a\
  wire        com_reset;\
  wire        _blackbox_c0_init_calib_complete;        // @[XilinxVCU118MIG.scala:51:26]\
  assign com_reset = reset | (~_blackbox_c0_init_calib_complete);' "$src_file"

    # 修改复位信号
    sed -i 's/\.reset                          (reset),/.reset                          (com_reset),/' "$src_file"

    add_xram_interface "$src_file"
    
    echo "XilinxVCU118MIGIsland.sv处理完成"
}

# 使用Python添加XRAM接口
add_xram_interface() {
    local target_file="$1"

    
    # 设置环境变量传递给Python
    export TARGET_FILE="$target_file"

    python << 'EOF'
# -*- coding: utf-8 -*-
import re
import os

filename = os.environ.get('TARGET_FILE')

with open(filename, 'r') as f:
    content = f.read()

# 找到axi4asink模块结束位置
axi4asink_end = content.find('  );', content.find('auto_out_r_ready'))
if axi4asink_end != -1:
    axi4asink_end += 4  # include '  );'
    
    # 在axi4asink结束后、vcu118mig开始前插入XEPIC代码
    xepic_code = '''

`ifdef XEPIC_P2E
        logic  [1:0]                      xram0_read;        
        logic  [127:0]                    xram0_read_addr;  
        logic  [1:0]                      xram0_read_data_ready; 
        logic  [1:0]                      xram0_write;       
        logic  [127:0]                    xram0_write_addr; 
        logic  [1151:0]                   xram0_write_data;    
        logic  [127:0]                    xram0_write_data_mask;
        
        logic  [1151:0]                   xram0_read_data;    
        logic  [1:0]                      xram0_read_data_valid;
        logic                             mmp_ddr4_calib_done;

         // slave0 slave-embeded, support burst control
         defparam u_axi_xram.AXI_MODE = 4;  // AXI Mode: 3 = AXI3, 4 = AXI4
         defparam u_axi_xram.AXI_ID_WIDTH   = 4;
         defparam u_axi_xram.AXI_DATA_WIDTH = 64;   // Data Width: 8,16,32,64,128,256,512,1024 
         defparam u_axi_xram.AXI_ADDR_WIDTH = 32;  // Addr Width: 32..64
         defparam u_axi_xram.AXI_USER_WIDTH = 0;  // 
         defparam u_axi_xram.MEM_SIZE = 64'h4_0000_0000;  // 2^34
 
         xaxi4_slave_emb u_axi_xram ( //or xaxi4_slave_emb_wrapper
            /*AUTOARG*/
            .aclk      (io_port_c0_sys_clk_i),
            .aresetn   (~io_port_sys_rst),
            // AXI write address channel
            .i_awvalid (_axi4asink_auto_out_aw_valid),
            .o_awready (_blackbox_c0_ddr4_s_axi_awready),
            .i_awid    (_axi4asink_auto_out_aw_bits_id),
            .i_awaddr  (_axi4asink_auto_out_aw_bits_addr[30:0]),
            .i_awlen   (_axi4asink_auto_out_aw_bits_len),     // in AXI3 .mode    (mode    ), [7:4] should be fixed to 0
            .i_awsize  (_axi4asink_auto_out_aw_bits_size),
            .i_awburst (_axi4asink_auto_out_aw_bits_burst),
            .i_awlock  (_axi4asink_auto_out_aw_bits_lock),
            .i_awcache (4'h3),
            .i_awprot  (_axi4asink_auto_out_aw_bits_prot),
            .i_awqos   (_axi4asink_auto_out_aw_bits_qos),
            .i_awregion(4'b0),
            // AXI write data channel
            .i_wvalid  (_axi4asink_auto_out_w_valid),
            .o_wready  (_blackbox_c0_ddr4_s_axi_wready),
            .i_wid     (0),
            .i_wdata   (_axi4asink_auto_out_w_bits_data),
            .i_wstrb   (_axi4asink_auto_out_w_bits_strb),
            .i_wlast   (_axi4asink_auto_out_w_bits_last),
            // AXI write response channel
            .o_bvalid  (_blackbox_c0_ddr4_s_axi_bvalid),
            .i_bready  (_axi4asink_auto_out_b_ready),
            .o_bid     (_blackbox_c0_ddr4_s_axi_bid),
            .o_bresp   (_blackbox_c0_ddr4_s_axi_bresp),

            // AXI read address channel
            .i_arvalid (_axi4asink_auto_out_ar_valid),
            .o_arready (_blackbox_c0_ddr4_s_axi_arready),
            .i_arid    (_axi4asink_auto_out_ar_bits_id),
            .i_araddr  (_axi4asink_auto_out_ar_bits_addr[30:0]),
            .i_arlen   (_axi4asink_auto_out_ar_bits_len),     // in AXI3 .mode    (mode    ), [7:4] should be fixed to 0
            .i_arsize  (_axi4asink_auto_out_ar_bits_size),
            .i_arburst (_axi4asink_auto_out_ar_bits_burst),
            .i_arlock  (_axi4asink_auto_out_ar_bits_lock),
            .i_arcache (4'h3),
            .i_arprot  (_axi4asink_auto_out_ar_bits_prot),
            .i_arqos   (_axi4asink_auto_out_ar_bits_qos),
            .i_arregion(4'b0),
            // AXI read response
            .o_rvalid  (_blackbox_c0_ddr4_s_axi_rvalid),
            .i_rready  (_axi4asink_auto_out_r_ready),
            .o_rid     (_blackbox_c0_ddr4_s_axi_rid),
            .o_rresp   (_blackbox_c0_ddr4_s_axi_rresp),
            .o_rdata   (_blackbox_c0_ddr4_s_axi_rdata),
            .o_rlast   (_blackbox_c0_ddr4_s_axi_rlast)
            );
    
        `ifdef XEPIC_XRAM_RTL
          xram_bbox_wrapper u_xram_bbox_wrapper (
              .uclk(io_port_c0_sys_clk_i),
              .xram0_read(xram0_read),
              .xram0_read_addr(xram0_read_addr),
              .xram0_read_data_ready(xram0_read_data_ready),
              .xram0_write(xram0_write),
              .xram0_write_addr(xram0_write_addr),
              .xram0_write_data(xram0_write_data),
              .xram0_write_data_mask(xram0_write_data_mask),
              .xram0_read_data(xram0_read_data),
              .xram0_read_data_valid(xram0_read_data_valid), 
              .mmp_ddr4_calib_done(_blackbox_c0_init_calib_complete)
          )/* synthesis syn_preserve=1 */;

          assign xram0_write[0]                  = u_axi_xram.write_xram;
          assign xram0_write_addr[0 +: 64]       = u_axi_xram.wr_addr_xram ;
          assign xram0_write_data[0 +: 576]      = u_axi_xram.wrdata_xram;
          assign xram0_write_data_mask[0 +: 64]  = u_axi_xram.wrdata_mask_xram;

          assign xram0_read[0]                   = 1'h0;
          assign xram0_read_addr[0 +: 64]        = 64'h0;
          assign xram0_read_data_ready[0]        = 1'h0;


          assign u_axi_xram.init_calib_complete = _blackbox_c0_init_calib_complete;

          assign xram0_write[1]                  = 1'h0;
          assign xram0_write_addr[64 +: 64]      = 64'h0;
          assign xram0_write_data[576 +: 576]    = 576'h0;
          assign xram0_write_data_mask[64 +: 64] = 64'h0;

          assign xram0_read[1]                   = u_axi_xram.read_xram;        
          assign xram0_read_addr[64 +: 64]       = u_axi_xram.rd_addr_xram;     
          assign xram0_read_data_ready[1]        = u_axi_xram.rddata_ready_xram;
          assign u_axi_xram.rddata_xram        = xram0_read_data[576 +: 576];
          assign u_axi_xram.rddata_valid_xram  = xram0_read_data_valid[1];
        `endif
        assign io_port_c0_ddr4_ui_clk = io_port_c0_sys_clk_i;
        assign io_port_c0_ddr4_ui_clk_sync_rst = 1'b0;

`else'''
    
    # 插入XEPIC代码
    content = content[:axi4asink_end] + xepic_code + content[axi4asink_end:]
    
    # 找到vcu118mig模块的结束位置并插入endif
    vcu118mig_start = content.find('vcu118mig blackbox')
    if vcu118mig_start != -1:
        # 从vcu118mig开始位置向后找到对应的模块结束位置
        vcu118mig_end = content.find('  );', vcu118mig_start)
        if vcu118mig_end != -1:
            vcu118mig_end += 4  # include '  );'
            # 在vcu118mig模块结束后插入endif
            endif_code = '\n`endif'
            content = content[:vcu118mig_end] + endif_code + content[vcu118mig_end:]

# 写回文件
with open(filename, 'w') as f:
    f.write(content)
EOF


}

# 修正XEPIC代码位置
fix_xepic_position() {
    local fix_script="$SCRIPT_DIR/toolchain/fix_position.py"
    local target_file="$SRC_DIR/XilinxVCU118MIGIsland.sv"
    
    # 检查Python脚本是否存在
    if [[ ! -f "$fix_script" ]]; then
        echo "修正脚本不存在: $fix_script"
        return 1
    fi
    
    # 检查目标文件是否存在
    if [[ ! -f "$target_file" ]]; then
        echo "目标文件不存在: $target_file"
        return 1
    fi
    
    echo "运行XEPIC位置修正脚本..."
    echo "脚本路径: $fix_script"
    echo "目标文件: $target_file"
    
    # 运行Python脚本
    if python "$fix_script" "$target_file"; then
        echo "XEPIC代码位置修正完成"
        return 0
    else
        echo "XEPIC代码位置修正失败"
        return 1
    fi
}




main() {
    check_environment
    setup_output_directory
    # process_tlrom
    # process_rocket
    process_test_harness
    process_mig_island
    
    fix_xepic_position
    
    
}

main "$@"