`timescale 1ns / 1ps

// 7.12更新

module WD_shifter #(
	parameter ROW_NUM = 256,
	parameter WD_E_W = 8,
	parameter WD_M_W = 8
)(
	input												FPEN,              	// FP16使能信号，高有效
	input	[$clog2(ROW_NUM):0]							WADR,              	// memory write addr, MSB is buffer index, 9bit, 最高比特位为控制信号, 后8bit为地址       
	input	[7:0] 										E_most,            	// E_most
	input	[7:0]       		   				 		WD_E,				// 输入weight的E
	input	[7:0]										WD_M,				// 输入weight的M
	
	// 给右边输出
	output	reg											outlier_valid_2b,	
	output	reg [$clog2(ROW_NUM)-1:0]					input_idx_2b,       // 8bit
	output	reg	[1:0]									outlier_value_2b,   // 2bit
	output	reg											outlier_valid_4b,   
	output	reg [$clog2(ROW_NUM)-1:0]					input_idx_4b,       // 8bit
	output	reg [3:0]									outlier_value_4b,   // 4bit
	
	// 给macro输出
	output	reg [7:0]									WD_out              // 8bit
);

wire [8:0]											delta_E;                // 9bit
reg 												delta_E_sign;
reg	[7:0]											delta_E_man;            // 8bit
reg [7:0]											WD_M_shifted;           // 8bit

wire [8:0]											WD_M_sup1;              // 9bit, WD_M补1后的, 为了不损失精度用9bit
wire [8:0]											WD_M_sup1_bu;           // 9bit, WD_M_bu1的补码

assign delta_E = WD_E - E_most;
assign WD_M_sup1 = {WD_M[7],1'b1,WD_M[6:0]};
assign WD_M_sup1_bu = (!WD_M[7]) ? (WD_M_sup1) : ({1'b1,~WD_M_sup1[7:0]} + 9'b1);

always @(*) begin
	// 计算
	delta_E_sign = delta_E[8];
	delta_E_man = delta_E_sign ? (~delta_E[7:0]+1'b1):delta_E[7:0];

	// 给macro
	case(delta_E_man)
		8'd0:WD_M_shifted = {WD_M[7],WD_M_sup1_bu[7:1]};
		8'd1:WD_M_shifted = (!delta_E_sign) ? ({WD_M[7],WD_M_sup1_bu[6:0]})		        :	({{(8'd2){WD_M[7]}},WD_M_sup1_bu[7:2]});
		8'd2:WD_M_shifted = (!delta_E_sign) ? ({WD_M[7],WD_M_sup1_bu[5:0],1'b0})        :	({{(8'd3){WD_M[7]}},WD_M_sup1_bu[7:3]});
		8'd3:WD_M_shifted = (!delta_E_sign) ? ({WD_M[7],WD_M_sup1_bu[4:0],2'b00})	    :	({{(8'd4){WD_M[7]}},WD_M_sup1_bu[7:4]});
		8'd4:WD_M_shifted = (!delta_E_sign) ? ({WD_M[7],WD_M_sup1_bu[3:0],3'b000})	    :	({{(8'd5){WD_M[7]}},WD_M_sup1_bu[7:5]});
		8'd5:WD_M_shifted = (!delta_E_sign) ? ({WD_M[7],WD_M_sup1_bu[2:0],4'b0000})	    :	({{(8'd6){WD_M[7]}},WD_M_sup1_bu[7:6]});
		8'd6:WD_M_shifted = (!delta_E_sign) ? ({WD_M[7],WD_M_sup1_bu[1:0],5'b00000})	:	({{(8'd7){WD_M[7]}},WD_M_sup1_bu[7]});
		8'd7:WD_M_shifted = (!delta_E_sign) ? ({WD_M[7],WD_M_sup1_bu[0],6'b000000})		:	8'b0;
		default:WD_M_shifted = 8'b0;
	endcase
	
	// 给右边
	// valid
	outlier_valid_2b = (!delta_E_sign) && (delta_E_man == 8'b1);
	outlier_valid_4b = (!delta_E_sign) && (delta_E_man > 8'b1) && (delta_E_man < 8'd11);
	// idx
	input_idx_2b = ((!delta_E_sign) && (delta_E_man == 8'b1)) ? WADR[$clog2(ROW_NUM)-1:0] : {$clog2(ROW_NUM){1'b0}};
	input_idx_4b = ((!delta_E_sign) && (delta_E_man > 8'b1) && (delta_E_man < 8'd11)) ? WADR[$clog2(ROW_NUM)-1:0] : {$clog2(ROW_NUM){1'b0}};
	// value
	if(!delta_E_sign) begin
		case(delta_E_man)
			8'd1:begin outlier_value_2b = {WD_M[7],1'b1}; outlier_value_4b = 4'b0; end
			8'd2:begin outlier_value_2b = 2'b0; outlier_value_4b = {WD_M[7],WD_M[7],WD_M_sup1_bu[7:6]}; end
			8'd3:begin outlier_value_2b = 2'b0; outlier_value_4b = {WD_M[7],WD_M_sup1_bu[7:5]}; end
			8'd4:begin outlier_value_2b = 2'b0; outlier_value_4b = {WD_M[7],WD_M_sup1_bu[6:4]}; end    //从这里开始已经有cover不到的了
			8'd5:begin outlier_value_2b = 2'b0; outlier_value_4b = {WD_M[7],WD_M_sup1_bu[5:3]}; end 
			8'd6:begin outlier_value_2b = 2'b0; outlier_value_4b = {WD_M[7],WD_M_sup1_bu[4:2]}; end
			8'd7:begin outlier_value_2b = 2'b0; outlier_value_4b = {WD_M[7],WD_M_sup1_bu[3:1]}; end
			8'd8:begin outlier_value_2b = 2'b0; outlier_value_4b = {WD_M[7],WD_M_sup1_bu[2:0]}; end
			8'd9:begin outlier_value_2b = 2'b0; outlier_value_4b = {WD_M[7],WD_M_sup1_bu[1:0],1'b0}; end
			8'd10:begin outlier_value_2b = 2'b0; outlier_value_4b = {WD_M[7],WD_M_sup1_bu[0],2'b00}; end
			default:begin outlier_value_2b = 2'b0; outlier_value_4b = 8'b0; end
		endcase
	end
	else begin
		outlier_value_2b = 2'b0; 
		outlier_value_4b = 8'b0;
	end
	
	if(FPEN) begin
		WD_out = WD_M_shifted;
	end
	else begin
		WD_out = WD_M;
	end
	
end

endmodule
