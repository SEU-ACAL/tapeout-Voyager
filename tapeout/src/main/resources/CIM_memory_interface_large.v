`define CIM_DEPTH   512
`define CIM_WIDTH   64


module CIM_memory_interface_large #(
        parameter Macro_ROW_NUM = 256
    )(
        input 									clk,
        input 									rstn,
        output 									clk_axi,

        input                            		CIM_store_en,
        input [$clog2(`CIM_DEPTH):0]	 		CIM_store_addr,
        input [`CIM_WIDTH-1:0]        	 		CIM_store_data,

        input							 		W_SEL_ready,
        output    								CIM_store_ready,

        output                                  AXI_din_valid,
        output [Macro_ROW_NUM*8-1:0]          	AXI_NNIN,
        output [$clog2(Macro_ROW_NUM):0]        AXI_WADR,
        output [7:0]                            AXI_WEB,
        output [7:0]                            AXI_MEB,
        output                                  AXI_fp_en,
        // output [64*8-1:0]                       AXI_E_most,
        // output [64*8-1:0]                       AXI_WD_E,
        output [64*8-1:0]                      	AXI_WD_M,
        output [7:0]                       		AXI_buffer0_rst,
        output [7:0]                       	    AXI_buffer1_rst,
        output [7:0]                            AXI_compute_valid,
        output [$clog2(Macro_ROW_NUM):0]        AXI_CIMADR,
        // output                                  AXI_sign_bit,
        output [7:0]                            AXI_adder_enb,
        output [3:0]                        	AXI_buffer_row_addr
    );

    // wire [$clog2(`CIM_DEPTH)-1:0]	 			CIM_WADR;
    // wire  						 				CIM_W_SEL;
    // reg 										W_SEL_reg;

    assign clk_axi 				 = clk;
    // assign CIM_WADR 			 = CIM_store_addr[$clog2(`CIM_DEPTH)-1:0];
    // assign CIM_W_SEL			 = CIM_store_addr[$clog2(`CIM_DEPTH)];

    // always @(posedge clk or negedge rstn) begin
    //     if (!rstn)
    //         W_SEL_reg <= 1'b0;
    //     else
    //         W_SEL_reg <= CIM_W_SEL;
    // end

    assign CIM_store_ready				 = W_SEL_ready;
    assign AXI_din_valid 				 = 'b0;
    assign AXI_NNIN 					 = 'b0;
    assign AXI_WADR 					 = CIM_store_addr;
    assign AXI_WEB 						 = CIM_store_en;
    assign AXI_MEB 						 = 'b1;
    assign AXI_fp_en 					 = 'b0;
    // assign AXI_E_most 				 = 'b0;
    // assign AXI_WD_E 					 = 'b0;
    assign AXI_WD_M 					 = CIM_store_data;
    assign AXI_buffer0_rst 				 = 'b0;
    assign AXI_buffer1_rst 				 = 'b0;
    assign AXI_compute_valid 			 = 'b0;
    assign AXI_CIMADR 					 = !CIM_store_addr[$clog2(`CIM_DEPTH)];
    // assign AXI_sign_bit 				 = 'b0;  // 注释掉，因为输出端口中没有定义
    assign AXI_adder_enb 				 = 'b0;
    assign AXI_buffer_row_addr			 = 'b0;


endmodule
