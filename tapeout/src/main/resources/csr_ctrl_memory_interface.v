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

		//********************TEST
		output  	 [`CSR_WIDTH*`CSR_DEPTH-1:0]			TEST_reg

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

            always @(posedge clk or negedge rstn) begin
                if (~rstn)
                    csr_load_data <= 'b0;
                else if (csr_load_en && (csr_load_addr == i))
                    csr_load_data <= ctrl_reg[i];
            end
        end
    endgenerate

    assign NPU_AXI_SEL		 = ctrl_reg[0][0];

	//********************TEST
	generate
		for (i = 0; i < `CSR_DEPTH; i = i + 1) begin : gen_TEST_REG
			assign TEST_reg[`CSR_WIDTH*i+:`CSR_WIDTH] = ctrl_reg[i];
		end
	endgenerate


endmodule

