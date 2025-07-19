// `define CIM_DEPTH_S   512
// `define CIM_WIDTH   64
`include "defines.v"

module CIM_memory_interface_small #(
        parameter Macro_ROW_NUM = 32
    )(
        input 									clk,
        input 									rstn,
        output 									clk_axi,

        input                            		CIM_store_en,
        input [$clog2(`CIM_DEPTH_S)-1:0]	    CIM_store_addr,
        input [`CIM_WIDTH-1:0]        	 		CIM_store_data,

        input [`EXP_DEPTH*`EXP_WIDTH-1:0]       exp_data,
        input                                   fp_en,

        output [Macro_ROW_NUM*8*8-1:0]          AXI_NNIN_all,
        output [1:0]                            AXI_combine_mode,
        output [2:0]                            AXI_NNIN_sel,

        output [$clog2(Macro_ROW_NUM):0]        AXI_WADR,
        output [7:0]                            AXI_WEB,
        output [7:0]                            AXI_MEB,

        output                                  AXI_fp_en,
        output [63:0]                           AXI_WD_E,
        output [63:0]                      	    AXI_WD_M,
        output [7:0]                            AXI_buffer0_rst,
        output [7:0]                            AXI_buffer1_rst,
        
        output [1:0]                            AXI_CIMADR,
        output [7:0]                            AXI_adder_enb,
        output [3:0]                            AXI_buffer_row_addr                            
    );

    localparam BANK_SEL  = $clog2(`CIM_Bank_NUM);       // 3
    localparam LOCAL_ADDR = $clog2(`CIM_Bank_DEPTH_S);  // 6
    localparam ADDR_WIDTH = $clog2(`CIM_DEPTH_S);       // 9


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

    assign clk_axi = clk;
    assign AXI_NNIN_all = 'd0;
    assign AXI_combine_mode = 'd0;
    assign AXI_NNIN_sel = 'd0;

    assign AXI_WADR = CIM_store_addr[LOCAL_ADDR-1:0];
    assign AXI_WEB = CIM_store_en ? 8'h01 << bank_idx : 'd0;
    assign AXI_MEB = 'd0;


    assign AXI_fp_en = fp_en;
    // E_reg的深度只有64，但小核的深度有32，所以要只取E_reg的一部分。
    assign AXI_WD_E = (fp_en && CIM_store_en) ? exp_mem[CIM_store_addr[LOCAL_ADDR-2:0]] : 'd0; 
    assign AXI_WD_M = CIM_store_data;
    assign AXI_buffer0_rst = 8'd0;
    assign AXI_buffer1_rst = 8'd0;

    assign AXI_CIMADR = {!CIM_store_addr[LOCAL_ADDR-1], 1'b0};
    assign AXI_adder_enb = 8'd0;
    assign AXI_buffer_row_addr = 4'd0;

endmodule
