`timescale 1ns / 1ps

module NNIN_shifter #(
    parameter Macro_ROW_NUM = 256
  )(
    input                                   clk,
    input                                   rstn,
    input                                   din_valid,
    input        [Macro_ROW_NUM*8-1:0]      NNIN_data,

    output reg   [Macro_ROW_NUM-1:0]        NNIN_bit
  );

  reg [2:0] cnt;

  integer i;

  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      cnt <= 'b0;
    else if (cnt == 3'd0) begin
      if(din_valid)
        cnt <= cnt + 1'b1;
    end
    else
      cnt <= cnt + 1'b1;
  end

  always @(*) begin
    // if (!rstn)
    //   NNIN_bit <= 'b0;
    // else
    for (i = 0; i < Macro_ROW_NUM; i = i + 1)
      NNIN_bit[i] = NNIN_data[i*8+cnt];
  end

endmodule
