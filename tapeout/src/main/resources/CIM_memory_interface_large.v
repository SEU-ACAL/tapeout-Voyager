// `include "../gen-collateral/defines.v"
`include "../gen-collateral/defines.v"

module CIM_memory_interface_large #(
        parameter Macro_ROW_NUM = 256
    )(
        input 									clk,
        input 									rstn,

        input                            		CIM_store_en,
        input [$clog2(`CIM_DEPTH_L)-1:0]	    CIM_store_addr,
        input [`CIM_WIDTH-1:0]        	 		CIM_store_data,

        input [`EXP_DEPTH*`EXP_WIDTH-1:0]       exp_data,
        input                                   fp_en,

        output                                  AXI_din_valid_L,
        output [Macro_ROW_NUM*8-1:0]            AXI_NNIN_E_L,
		output [Macro_ROW_NUM*8-1:0]            AXI_NNIN_M_L,

        output [$clog2(Macro_ROW_NUM):0]        AXI_WADR_L,
        output [3:0]                            AXI_WEB_L,
        output [3:0]                            AXI_MEB_L,

        output [63:0]                           AXI_WD_E_L,
        output [63:0]                           AXI_WD_M_L,
        output                                  AXI_buffer0_rst_L,
        output                                  AXI_buffer1_rst_L,
        output                                  AXI_compute_valid_L,

        output [$clog2(Macro_ROW_NUM):0]        AXI_CIMADR_L,
        output                                  AXI_adder_enb_L,
        output [3:0]                            AXI_buffer_row_addr_L
    );

    localparam BANK_SEL  = $clog2(`CIM_Bank_NUM);       // 2
    localparam LOCAL_ADDR = $clog2(`CIM_Bank_DEPTH_L);  // 9
    localparam ADDR_WIDTH = $clog2(`CIM_DEPTH_L);       // 11


    wire [BANK_SEL-1:0]     bank_idx;
    wire [`EXP_WIDTH-1:0]   exp_mem [0:`EXP_DEPTH-1];
    assign bank_idx = CIM_store_addr[ADDR_WIDTH-1-:BANK_SEL];

    genvar i;
    generate
        for(i=0; i<`EXP_DEPTH; i=i+1) begin
            assign exp_mem[i] = exp_data[i*`EXP_WIDTH +: `EXP_WIDTH];
        end
    endgenerate

    assign AXI_din_valid_L = 1'b0;
    assign AXI_NNIN_E_L = 'd0;
	assign AXI_NNIN_M_L = 'd0;

    assign AXI_WADR_L = CIM_store_addr[LOCAL_ADDR-1:0];
    assign AXI_WEB_L = CIM_store_en ? 4'b0001 << bank_idx : 'd0;
    assign AXI_MEB_L = 4'h0;

    // E_reg的深度只有64，但大核的深度有256，所以要分4次写Macro，每次写64个，所以这里减4。
    assign AXI_WD_E_L = (fp_en && CIM_store_en) ? exp_mem[CIM_store_addr[LOCAL_ADDR-4:0]] : 'd0;
    assign AXI_WD_M_L = CIM_store_data;
    assign AXI_buffer0_rst_L = 'd0;
    assign AXI_buffer1_rst_L = 'd0;
    assign AXI_compute_valid_L = 'd0;

    assign AXI_CIMADR_L = {!CIM_store_addr[LOCAL_ADDR-1], 8'b0};
    assign AXI_adder_enb_L = 'd0;
    assign AXI_buffer_row_addr_L = 'd0;

endmodule
