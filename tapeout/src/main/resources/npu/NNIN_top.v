`timescale 1ns / 1ps

module NNIN_top #(
    parameter Macro_ROW_NUM = 256
)(
    input                                   clk,
    input                                   rstn,
    input                                   din_valid,

    input                                   fp_en,
    input [Macro_ROW_NUM*8-1:0]             NNIN_E_all,
    input [Macro_ROW_NUM*8-1:0]             NNIN_M_all,

    output [Macro_ROW_NUM-1:0]      		NNIN_bit,
	output [Macro_ROW_NUM*8-1:0]    		NNIN_data,
	output [7:0]                      	    E_max
);


NNIN_pre_align #(
    .Macro_ROW_NUM(Macro_ROW_NUM)
) u_NNIN_pre_align (
    .fp_en      (fp_en      ),
    .NNIN_E_all (NNIN_E_all ),
    .NNIN_M_all (NNIN_M_all ),
    .NNIN_data  (NNIN_data  ),
	.E_max      (E_max	    )
);

NNIN_shifter #(
    .Macro_ROW_NUM(Macro_ROW_NUM)
) u_NNIN_shifter(
    .clk(clk),
    .rstn(rstn),
    .din_valid(din_valid),
    .NNIN_data(NNIN_data),
    .NNIN_bit(NNIN_bit)
);

endmodule
