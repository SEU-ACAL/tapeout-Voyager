`timescale 1ns / 1ps

module NNIN_shifter_x8 #(
    parameter Macro_ROW_NUM = 256
)(
    input                                   clk,
    input                                   rstn,
    input                                   din_valid,
    input       [Macro_ROW_NUM*8*8-1:0]     NNIN_data,

    output 	    [Macro_ROW_NUM*8-1:0]       NNIN_bit
);

genvar i;
generate
    for(i = 0; i < 8; i = i + 1) begin : NNIN_shifter_group
        NNIN_shifter #(
            .Macro_ROW_NUM(Macro_ROW_NUM)
        ) u_NNIN_shifter(
            .clk(clk),
            .rstn(rstn),
            .din_valid(din_valid),
            .NNIN_data(NNIN_data[i*Macro_ROW_NUM*8 +: Macro_ROW_NUM*8]),
            .NNIN_bit(NNIN_bit[i*Macro_ROW_NUM +: Macro_ROW_NUM])
        );
    end
endgenerate
endmodule