`timescale 1ns / 1ps

module NNIN #(
    parameter Macro_ROW_NUM = 256
)(
    // NNIN_shifter_x8
    input                                   clk,
    input                                   rstn,
    input                                   din_valid,

    //NNIN_NOC
    input  [Macro_ROW_NUM*8*8-1:0]          NNIN_all,
	input  [1:0]                            combine_mode,
	input  [2:0]                            NNIN_sel,

	output [Macro_ROW_NUM*8-1:0]      		NNIN_bit,
	output [Macro_ROW_NUM*8*8-1:0]    		NNIN_INT8
);

// wire [Macro_ROW_NUM*8*8-1:0]    NNIN_data;

NNIN_NOC #(
    .Macro_ROW_NUM(Macro_ROW_NUM)
) u_NNIN_NOC(
    .NNIN_all(NNIN_all),
    .combine_mode(combine_mode),
    .NNIN_sel(NNIN_sel),
    .NNIN_NOC_out(NNIN_INT8)
);

NNIN_shifter_x8 #(
    .Macro_ROW_NUM(Macro_ROW_NUM)
) u_NNIN_shifter_x8(
    .clk(clk),
    .rstn(rstn),
    .din_valid(din_valid),
    .NNIN_data(NNIN_INT8),
    .NNIN_bit(NNIN_bit)
);
    
endmodule