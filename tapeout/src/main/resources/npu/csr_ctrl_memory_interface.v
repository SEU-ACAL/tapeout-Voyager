//`include "defines.v"
// `include "../0-RTL/AXI_SLAVE/defines.v"
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
		output 		   							ctrl_rstn,

        output									start_en,

        output	[4:0]							MAC_INPUT_ROW_L,
        output	[4:0]							MAC_LENGTH_L,
        output	[9:0]							FM_ADDR_START_L,
        output	[3:0]							CSR_MEB_L,
        output	[7:0]							last_CIMADR_L,
        output	[64*4*6-1:0]					E_most_L,

        output	[4:0]							MAC_INPUT_ROW_S,
        output	[4:0]							MAC_LENGTH_S,
        output	[9:0]							FM_ADDR_START_S,
        output	[3:0]							CSR_MEB_S,
        output	[64*4*6-1:0]					E_most_S
    );

    reg [63:0] ctrl_reg[0:`CSR_DEPTH-1];

    genvar i;
    generate
        for (i = 0; i < `CSR_DEPTH-1; i = i + 1) begin : gen_CSR_REG
            always @(posedge clk or negedge rstn) begin
                if (~rstn)
                    ctrl_reg[i] <= 'b0;
                else if (csr_store_en && (csr_store_addr == i))
                    ctrl_reg[i] <= csr_store_data;
            end
        end
    endgenerate

    // for CPU read test
    always @(posedge clk or negedge rstn) begin
    	if (~rstn)
    		ctrl_reg[`CSR_DEPTH-1] <= 64'h0123456789ABCDEF;
    	else if (csr_store_en && (csr_store_addr == `CSR_DEPTH-1))
    		ctrl_reg[`CSR_DEPTH-1] <= 64'h0123456789ABCDEF; // Default value for the last CSR register
    end
    // always @(*) begin
    //     ctrl_reg[`CSR_DEPTH-1] = 64'h0123456789ABCDEF; // Default value for the last CSR register
    // end

    always @(posedge clk or negedge rstn) begin
        if (~rstn)
            csr_load_data <= 'b0;
        else if (csr_load_en )
            csr_load_data <= ctrl_reg[csr_load_addr];
    end

    assign NPU_AXI_SEL		 = ctrl_reg[0][0];
    assign fp_en			 = ctrl_reg[0][1];
	assign ctrl_rstn		 = ctrl_reg[0][2];

    assign MAC_INPUT_ROW_L	 = ctrl_reg[1][0  +:5];
    assign MAC_LENGTH_L		 = ctrl_reg[1][5  +:5];
    assign FM_ADDR_START_L	 = ctrl_reg[1][10 +:10];
    assign CSR_MEB_L		 = ctrl_reg[1][20 +:4];
    assign last_CIMADR_L	 = ctrl_reg[1][24 +:8];

    assign MAC_INPUT_ROW_S	 = ctrl_reg[2][0  +:5];
    assign MAC_LENGTH_S		 = ctrl_reg[2][5  +:5];
    assign FM_ADDR_START_S	 = ctrl_reg[2][10 +:10];
    assign CSR_MEB_S		 = ctrl_reg[2][20 +:4];

    assign start_en			 = ctrl_reg[3][0];

    generate
        for (i = 0; i < 4*6; i = i + 1) begin : gen_E_most
            assign E_most_L[64*i +:64] = ctrl_reg[i+4];
            assign E_most_S[64*i +:64] = ctrl_reg[i+28];
        end
    endgenerate


endmodule

