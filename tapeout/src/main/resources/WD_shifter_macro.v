`timescale 1ns / 1ps

module WD_shifter_macro #(
	parameter ROW_NUM = 256,
	parameter COL_GROUP_NUM = 8,
	parameter WD_E_W = 8,
	parameter WD_M_W = 8
)(
	input												FPEN,              	// FP16使能信号，高有效
	input	[$clog2(ROW_NUM):0]							WADR,              	// memory write addr, 9*8=72bit      
	input	[8*COL_GROUP_NUM-1:0] 						E_most,            	// E_most,8*8=64bit
	input	[8*COL_GROUP_NUM-1:0]    				   	WD_E,				// 输入weight的E,8*8=64bit
	input	[8*COL_GROUP_NUM-1:0]						WD_M,				// 输入weight的M,8*8=64bit
	
	
	// 给右边输出
	output	[COL_GROUP_NUM-1:0]						outlier_valid_2b,	// 1*8=8bit
	output	[$clog2(ROW_NUM)-1:0]					input_idx_2b,       // 8*8=64bit
	output	[2*COL_GROUP_NUM-1:0]					outlier_value_2b,   // 2*8=16bit
	output	[COL_GROUP_NUM-1:0]						outlier_valid_4b,   // 1*8=8bit
	output	[$clog2(ROW_NUM)-1:0]					input_idx_4b,       // 8*8=64bit
	output  [4*COL_GROUP_NUM-1:0]					outlier_value_4b,   // 4*8=32bit
	
	// 给macro输出
	output  [8*COL_GROUP_NUM-1:0]					WD_out 
);

localparam WADR_W = $clog2(ROW_NUM) + 1;  // 9

wire	[8*$clog2(ROW_NUM)-1:0]					input_idx_2b_all;       // 8*8=64bit
wire	[8*$clog2(ROW_NUM)-1:0]					input_idx_4b_all;       // 8*8=64bit

genvar  j;
generate
	if(ROW_NUM == 256) begin
		for(j=0;j<8;j=j+1) begin
			assign input_idx_2b[j] = input_idx_2b_all[j] | input_idx_2b_all[j+8] | input_idx_2b_all[j+16] | input_idx_2b_all[j+24] | input_idx_2b_all[j+32] | input_idx_2b_all[j+40] | input_idx_2b_all[j+48] | input_idx_2b_all[j+56];
			assign input_idx_4b[j] = input_idx_4b_all[j] | input_idx_4b_all[j+8] | input_idx_4b_all[j+16] | input_idx_4b_all[j+24] | input_idx_4b_all[j+32] | input_idx_4b_all[j+40] | input_idx_4b_all[j+48] | input_idx_4b_all[j+56];
		end
	end
	else begin
		for(j=0;j<8;j=j+1) begin
			assign input_idx_2b[j] = input_idx_2b_all[j] | input_idx_2b_all[j+5] | input_idx_2b_all[j+10] | input_idx_2b_all[j+15] | input_idx_2b_all[j+20] | input_idx_2b_all[j+25] | input_idx_2b_all[j+30] | input_idx_2b_all[j+35];
			assign input_idx_4b[j] = input_idx_4b_all[j] | input_idx_4b_all[j+5] | input_idx_4b_all[j+10] | input_idx_4b_all[j+15] | input_idx_4b_all[j+20] | input_idx_4b_all[j+25] | input_idx_4b_all[j+30] | input_idx_4b_all[j+35];
		end
	end
endgenerate

genvar i;
generate
	for(i=0;i<8;i=i+1) begin : gen_WD_shifter
		WD_shifter #(
			.ROW_NUM(ROW_NUM),
			.WD_E_W(WD_E_W),
			.WD_M_W(WD_M_W)
		) u_WD_shifter(
			.FPEN(FPEN),
			.WADR(WADR),
			.E_most(E_most[i*8+:8]),
			.WD_E(WD_E[i*8+:8]),
			.WD_M(WD_M[i*8+:8]),
			.outlier_valid_2b(outlier_valid_2b[i]),
			.input_idx_2b(input_idx_2b_all[i*$clog2(ROW_NUM)+:$clog2(ROW_NUM)]),
			.outlier_value_2b(outlier_value_2b[i*2+:2]),
			.outlier_valid_4b(outlier_valid_4b[i]),
			.input_idx_4b(input_idx_4b_all[i*$clog2(ROW_NUM)+:$clog2(ROW_NUM)]),
			.outlier_value_4b(outlier_value_4b[i*4+:4]),
			.WD_out(WD_out[i*8+:8])
		);
	end
endgenerate

endmodule
