// `include "../gen-collateral/defines.v"
`include "../gen-collateral/defines.v"

module CIM_memory_interface_small #(
        parameter Macro_ROW_NUM = 32
    )(
        input 									clk,
        input 									rstn,

        input                            		CIM_store_en,
        input [$clog2(`CIM_DEPTH_S)-1:0]	    CIM_store_addr,
        input [`CIM_WIDTH-1:0]        	 		CIM_store_data,

        input [`EXP_DEPTH*`EXP_WIDTH-1:0]       exp_data,
        input                                   fp_en,

        output                                  AXI_din_valid_S,
        output [Macro_ROW_NUM*8-1:0]            AXI_NNIN_E_S,
		output [Macro_ROW_NUM*8-1:0]            AXI_NNIN_M_S,

        output [$clog2(Macro_ROW_NUM):0]        AXI_WADR_S,
        output [3:0]                            AXI_WEB_S,
        output [3:0]                            AXI_MEB_S,

        output [63:0]                           AXI_WD_E_S,
        output [63:0]                      	    AXI_WD_M_S,
        output 		                            AXI_buffer0_rst_S,
        output 		                            AXI_buffer1_rst_S,
        
        output [1:0]                            AXI_CIMADR_S,
        output 		                            AXI_adder_enb_S,
        output [3:0]                            AXI_buffer_row_addr_S                            
    );

    localparam BANK_SEL  = $clog2(`CIM_Bank_NUM);       // 2
    localparam LOCAL_ADDR = $clog2(`CIM_Bank_DEPTH_S);  // 6
    localparam ADDR_WIDTH = $clog2(`CIM_DEPTH_S);       // 8


    wire [BANK_SEL-1:0]     bank_idx;
    wire [`EXP_WIDTH-1:0]   exp_mem [0:`EXP_DEPTH-1];

    genvar i;
    generate
        for(i=0; i<`EXP_DEPTH; i=i+1) begin
            assign exp_mem[i] = exp_data[i*`EXP_WIDTH +: `EXP_WIDTH];
        end
    endgenerate

    //CIM_store_addr: Bank sel + Macro addr
    assign bank_idx = CIM_store_addr[ADDR_WIDTH-1-:BANK_SEL];

    // assign clk_axi = clk;
    assign AXI_din_valid_S = 1'b0;
    assign AXI_NNIN_E_S = 'd0;
	assign AXI_NNIN_M_S = 'd0;

    assign AXI_WADR_S = CIM_store_addr[LOCAL_ADDR-1:0];
    assign AXI_WEB_S= CIM_store_en ? 4'b0001 << bank_idx : 'd0;
    assign AXI_MEB_S = 'd0;


    // assign AXI_fp_en_S = fp_en;
    // E_reg的深度只有64，但小核的深度有32，所以要只取E_reg的一部分。
    assign AXI_WD_E_S = (fp_en && CIM_store_en) ? exp_mem[CIM_store_addr[LOCAL_ADDR-2:0]] : 'd0; 
    assign AXI_WD_M_S = CIM_store_data;
    assign AXI_buffer0_rst_S = 'd0;
    assign AXI_buffer1_rst_S = 'd0;

    assign AXI_CIMADR_S = {!CIM_store_addr[LOCAL_ADDR-1], 1'b0};
    assign AXI_adder_enb_S = 'd0;
    assign AXI_buffer_row_addr_S = 'd0;

endmodule
