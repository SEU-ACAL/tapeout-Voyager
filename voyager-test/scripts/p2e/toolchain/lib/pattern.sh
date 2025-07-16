#!/bin/bash
# ====================================================================
# MIGRATE PATTERNS - Verilog Pattern and Replacement Definitions
# ====================================================================
# 本文件包含所有用于Verilog文件迁移的模式匹配和替换定义
# 集中管理使得修改和维护更加方便

# ====================================================================
# MIGRATION CONSTANTS
# ====================================================================

# Verilog files to process
readonly VERILOG_FILES=("VCU118FPGATestHarness.sv" "XilinxVCU118MIGIsland.sv")

# XEPIC macros to add to files
readonly XEPIC_MACROS=("XEPIC_P2E" "XEPIC_XRAM_RTL")

# ====================================================================
# TESTHARNESS FILE PATTERNS AND REPLACEMENTS
# ====================================================================

# FPGA PLL reset signal pattern and replacement
readonly PATTERN_FPGA_PLL_RESET='assign fpgaPLLIn_reset = _resetIBUF_O | _powerOnReset_fpga_power_on_power_on_reset;'
readonly REPLACEMENT_FPGA_PLL_RESET='`ifndef XEPIC_P2E\
assign fpgaPLLIn_reset = _resetIBUF_O | _powerOnReset_fpga_power_on_power_on_reset;\
`else\
assign fpgaPLLIn_reset = reset | _powerOnReset_fpga_power_on_power_on_reset;\
`endif'

# System clock interface patterns
readonly PATTERN_SYS_CLOCK_START='^  input         sys_clock_p,'
readonly PATTERN_SYS_CLOCK_END='^  input         sys_clock_n,'
readonly REPLACEMENT_SYS_CLOCK='`ifndef XEPIC_P2E\
  input         sys_clock_p,\
                sys_clock_n,\
`else\
  input                clock,\
  output        sdio_sel,\
`endif'

# FPGA clock interface patterns
readonly PATTERN_FPGA_CLOCK_START='^  input         fpga_clock_p,'
readonly PATTERN_FPGA_CLOCK_END='^  input         fpga_clock_n,'
readonly REPLACEMENT_FPGA_CLOCK='`ifndef XEPIC_P2E\
  input         fpga_clock_p,\
                fpga_clock_n,\
`else\
  input                clock_2,\
`endif'

# ====================================================================
# MIG ISLAND FILE PATTERNS AND REPLACEMENTS
# ====================================================================

# Blackbox calibration complete pattern
readonly PATTERN_BLACKBOX_CALIB_COMPLETE='wire.*_blackbox_c0_init_calib_complete.*XilinxVCU118MIG\.scala'

# AXI4ASINK ready signal pattern and reset logic replacement
readonly PATTERN_AXI4ASINK_R_READY='^  wire        _axi4asink_auto_out_r_ready;'
readonly REPLACEMENT_RESET_LOGIC=$(cat << 'EOF'
  wire        com_reset;
  wire        _blackbox_c0_init_calib_complete;        // @[XilinxVCU118MIG.scala:51:26]
  assign com_reset = reset | (~_blackbox_c0_init_calib_complete);
EOF
)

# Reset connection patterns
readonly PATTERN_RESET_CONNECTION='\.reset                          (reset),'
readonly REPLACEMENT_RESET_CONNECTION='.reset                          (com_reset),'

# ====================================================================
# CONDITIONAL COMPILATION BLOCK PATTERNS
# ====================================================================

# Analog to UINT patterns for conditional compilation
readonly PATTERN_ANALOG_TO_UINT_START='UIntToAnalog_1 a2b_1 '
readonly PATTERN_ANALOG_TO_UINT_END='  );'

# Large conditional compilation block replacement
readonly REPLACEMENT_CONDITIONAL_BLOCK=$(cat << 'EOF'

`ifndef XEPIC_P2E
  IBUFDS #(
    .DIFF_TERM("FALSE"),
    .IOSTANDARD("DEFAULT"),
    .DQS_BIAS("FALSE"),
    .CAPACITANCE("DONT_CARE"),
    .IFD_DELAY_VALUE("AUTO"),
    .IBUF_LOW_PWR("TRUE"),
    .IBUF_DELAY_VALUE(0)
  ) sys_clock_ibufds (
    .I  (sys_clock_p),
    .IB (sys_clock_n),
    .O  (_sys_clock_ibufds_O)
  );

  harnessSysPLL harnessSysPLL (
    .clk_in1  (_sys_clock_ibufds_O),
    .reset    (_WIRE),
    .clk_out1 (_harnessSysPLL_clk_out1),
    .locked   (_harnessSysPLL_locked)
  );

  IBUF resetIBUF (
    .I (reset),
    .O (_resetIBUF_O)
  );

  PowerOnResetFPGAOnly powerOnReset_fpga_power_on (
    .clock          (_sys_clock_ibufds_O),
    .power_on_reset (_powerOnReset_fpga_power_on_power_on_reset)
  );
`else
  assign _sys_clock_ibufds_O = clock;
  assign _harnessSysPLL_clk_out1 = clock;
  assign _harnessSysPLL_locked = 1;
  assign _fpga_clock_ibufds_O = clock_2;
  assign _fpgaPLL_clk_out1 = clock_2;
  assign _fpgaPLL_locked = 1;

  PowerOnResetFPGAOnly powerOnReset_fpga_power_on (
    .clock          (clock),
    .power_on_reset (_powerOnReset_fpga_power_on_power_on_reset)
  );
`endif

assign sdio_sel = 1'b0;
EOF
)

# ====================================================================
# PYTHON SCRIPT PATTERNS AND TEMPLATES
# ====================================================================

# Hardware instances to remove (used by Python script)
readonly HARDWARE_INSTANCES_TO_REMOVE=('IBUFDS #(' 'fpgaPLL fpgaPLL (' 'harnessSysPLL harnessSysPLL (' 'IBUF ' 'PowerOnResetFPGAOnly ')

# XRAM interface insertion patterns
readonly XRAM_SEARCH_PATTERN='auto_out_r_ready'
readonly XRAM_ANCHOR_PATTERN='  );'
readonly XRAM_VCU118MIG_PATTERN='vcu118mig blackbox'

# XEPIC XRAM interface code template - complex Verilog code using HERE document
readonly XEPIC_XRAM_TEMPLATE=$(cat << 'EOF'

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

`else
EOF
)

# XRAM endif code
readonly XRAM_ENDIF_CODE='
`endif'

# ====================================================================
# PATTERN VALIDATION
# ====================================================================

# Function to validate that all required patterns are defined
validate_patterns() {
    local patterns=(
        "VERILOG_FILES"
        "XEPIC_MACROS"
        "PATTERN_FPGA_PLL_RESET"
        "REPLACEMENT_FPGA_PLL_RESET"
        "PATTERN_SYS_CLOCK_START"
        "PATTERN_SYS_CLOCK_END"
        "REPLACEMENT_SYS_CLOCK"
        "PATTERN_FPGA_CLOCK_START"
        "PATTERN_FPGA_CLOCK_END"
        "REPLACEMENT_FPGA_CLOCK"
        "PATTERN_BLACKBOX_CALIB_COMPLETE"
        "PATTERN_AXI4ASINK_R_READY"
        "REPLACEMENT_RESET_LOGIC"
        "PATTERN_RESET_CONNECTION"
        "REPLACEMENT_RESET_CONNECTION"
        "PATTERN_ANALOG_TO_UINT_START"
        "PATTERN_ANALOG_TO_UINT_END"
        "REPLACEMENT_CONDITIONAL_BLOCK"
        "HARDWARE_INSTANCES_TO_REMOVE"
        "XRAM_SEARCH_PATTERN"
        "XRAM_ANCHOR_PATTERN"
        "XRAM_VCU118MIG_PATTERN"
        "XEPIC_XRAM_TEMPLATE"
        "XRAM_ENDIF_CODE"
    )
    
    local missing_patterns=()
    for pattern in "${patterns[@]}"; do
        if [[ -z "${!pattern:-}" ]]; then
            missing_patterns+=("$pattern")
        fi
    done
    
    if [[ ${#missing_patterns[@]} -gt 0 ]]; then
        echo "错误：以下模式变量未定义：" >&2
        printf '  %s\n' "${missing_patterns[@]}" >&2
        return 1
    fi
    
    return 0
} 