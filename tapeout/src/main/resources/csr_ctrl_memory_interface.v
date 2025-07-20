`include "../gen-collateral/defines.v"

module csr_ctrl_memory_interface(
        input 				clk,
        input 				rstn,

        input                                   csr_load_en,
        input  [$clog2(`CSR_DEPTH)-1:0]         csr_load_addr,
        output reg [`CSR_WIDTH-1:0]             csr_load_data,

        input                                   csr_store_en,
        input  [$clog2(`CSR_DEPTH)-1:0]         csr_store_addr,
        input  [`CSR_WIDTH-1:0]                 csr_store_data,

        output 		   							NPU_AXI_SEL,
        output 		   							fp_en,
        output									start_en,

        output	[3:0]							MAC_INPUT_ROW_L,
        output	[3:0]							MAC_LENGTH_L,
        output	[9:0]							FM_ADDR_START_L,
        output	[7:0]							last_CIMADR_L,
        output	[64*4-1:0]						E_most_L,

        output	[3:0]							MAC_INPUT_ROW_S,
        output	[3:0]							MAC_LENGTH_S,
        output	[9:0]							FM_ADDR_START_S,
        output	[64*4-1:0]						E_most_S
    );

    reg [63:0] ctrl_reg[0:`CSR_DEPTH-1];

    genvar i;
    generate
        for (i = 0; i < `CSR_DEPTH; i = i + 1) begin : gen_CSR_REG
            always @(posedge clk or negedge rstn) begin
                if (~rstn)
                    ctrl_reg[i] <= 'b0;
                else if (csr_store_en && (csr_store_addr == i))
                    ctrl_reg[i] <= csr_store_data;
            end
        end
    endgenerate

    always @(posedge clk or negedge rstn) begin
        if (~rstn)
            csr_load_data <= 'b0;
        else if (csr_load_en )
            csr_load_data <= ctrl_reg[csr_load_addr];
    end

    assign NPU_AXI_SEL		 = ctrl_reg[8][0];
    assign fp_en			 = ctrl_reg[8][1];

    assign MAC_INPUT_ROW_L	 = ctrl_reg[9][0  +:4];
    assign MAC_LENGTH_L		 = ctrl_reg[9][4  +:4];
    assign FM_ADDR_START_L	 = ctrl_reg[9][8  +:10];
    assign last_CIMADR_L	 = ctrl_reg[9][18 +:8];

    assign MAC_INPUT_ROW_S	 = ctrl_reg[10][0  +:4];
    assign MAC_LENGTH_S		 = ctrl_reg[10][4  +:4];
    assign FM_ADDR_START_S	 = ctrl_reg[10][8  +:10];

    wire pulse_en;
    reg signal_d;
    assign pulse_en			 =ctrl_reg[11][0];
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            signal_d <= 1'b0;
        else
            signal_d <= pulse_en;  // 对原始信号打一拍
    end
    assign start_en = pulse_en & ~signal_d;  // 检测上升沿，生成1周期脉冲


    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_E_most
            assign E_most_L[64*i +:64] = ctrl_reg[i];
            assign E_most_S[64*i +:64] = ctrl_reg[i+8];
        end
    endgenerate


endmodule

