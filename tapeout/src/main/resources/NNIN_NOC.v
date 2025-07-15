`timescale 1ns / 1ps

module NNIN_NOC #(
	parameter Macro_ROW_NUM = 256
  )(
	input  [Macro_ROW_NUM*8*8-1:0]    NNIN_all,
	input  [1:0]                      combine_mode,
	input  [2:0]                      NNIN_sel,

	output [Macro_ROW_NUM*8*8-1:0]    NNIN_NOC_out
  );

  wire [Macro_ROW_NUM*8-1:0] NNIN_in[0:7];
  reg  [Macro_ROW_NUM*8-1:0] NNIN_out[0:7];

  genvar i;
  generate
	for(i = 0; i < 8; i = i + 1) begin : gen_NNIN_group
	  assign NNIN_in[i] = NNIN_all[i*Macro_ROW_NUM*8 +: Macro_ROW_NUM*8];
	  assign NNIN_NOC_out[i*Macro_ROW_NUM*8 +: Macro_ROW_NUM*8] = NNIN_out[i];
	end
  endgenerate

  integer j;
  always @(*) begin
	case (combine_mode)
	  2'b00: begin  //8*1
		for (j = 0; j < 8; j = j + 1) NNIN_out[j] = NNIN_in[j];
	  end

	  2'b01: begin  //4*2
		for (j = 0; j < 8; j = j + 1) NNIN_out[j] = NNIN_in[{NNIN_sel[2], j[1:0]}];
	  end

	  2'b10: begin  //2*4
		for (j = 0; j < 8; j = j + 1) NNIN_out[j] = NNIN_in[{NNIN_sel[2:1], j[0]}];
	  end

	  2'b11: begin  //1*8
		for (j = 0; j < 8; j = j + 1) NNIN_out[j] = NNIN_in[NNIN_sel];
	  end

	  default: begin // Default case, no operation
		for (j = 0; j < 8; j = j + 1) NNIN_out[j] = 'b0;
	  end
	endcase
  end



endmodule
