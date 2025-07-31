`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/17 19:38:57
// Design Name:
// Module Name: psum_self_adder
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module psum_self_adder #(
        parameter PSUM_W = 21,                                          // Width of the Macro PSUM output
        parameter BUFFER_ROW = 16                                       // row bum of the output buffer
    )(
        input                   clk,
        input                   rstn,                                   // Active low reset signal
        input                   fp_en,
        input                   adder_enb,                              // Active low reset signal
        input                   din_valid,
        input [3:0]             buffer_row_addr,                        // Address for the output buffer
        input [PSUM_W*8-1:0]    Macro_out,                              // Input Macro output values
        input [32*8-1:0]        outlier_sum,
        input [7:0]             NNIN_E_max,
        input [63:0]	        W_E_most,

        output [255:0]          data_out,                               // Output value
        output reg 				Macro_out_valid
    );

    reg                         din_valid_d0;
    reg [3:0]                   buffer_row_addr_reg;

    reg signed [32-1:0]         Macro_out_reg [0:7];                    // Split Macro_out into 8 parts
    reg [31:0]                  self_buffer [0:7][0:BUFFER_ROW-1];      // output buffer 8x16x32bit
    reg [7:0]                   self_buffer_exp [0:7][0:BUFFER_ROW-1];      // output buffer 8x16x8bit

    wire signed[31:0]           adder_din_a [0:7];
    wire        [7:0]           adder_din_a_exp [0:7];
    wire        [7:0]           exp_delta_a [0:7];					//添加exp信号，单独处理尾数
    reg  signed[31:0]           adder_din_b [0:7];
    reg 	   [7:0]            adder_din_b_exp [0:7];
    wire        [7:0]           exp_delta_b [0:7];
    wire signed[31:0]           self_adder_out [0:7];
    wire       [7:0]            self_adder_out_exp [0:7];

    wire       [31:0] 			data_out_fp [0:7];

    wire signed [31:0]      outlier_sum_ext[0:7];
    wire 		[7 :0]		Macro_out_reg_exp[0:7];
    genvar l;
    generate
        for (l = 0; l < 8; l = l + 1) begin : gen_outlier_sum_yiwei
            assign outlier_sum_ext[l] = { outlier_sum[l*32+31], outlier_sum[l*32+:24], 7'b0 };
        end
    endgenerate


    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            buffer_row_addr_reg    <= 'b0;
            din_valid_d0           <= 'b0;
            Macro_out_valid		   <= 'b0;
        end
        else begin
            buffer_row_addr_reg    <= buffer_row_addr;
            din_valid_d0           <= din_valid;
            Macro_out_valid		   <= din_valid_d0;
        end
    end

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_Macro_out_w           // Split Macro_out into 8 parts
            always @(posedge clk or negedge rstn) begin
                if(!rstn)
                    Macro_out_reg[i] <= 'b0;
                else if (din_valid)
                    //考虑了fp_en。Macro_out使用显示符号扩展；浮点计算下outlier_sum会保持，所以可以不用采样直接用输入的，节约面积。
                    Macro_out_reg[i] <= fp_en ? $signed({{(32-PSUM_W){Macro_out[i*PSUM_W+PSUM_W-1]}}, Macro_out[i*PSUM_W+:PSUM_W]}) + $signed(outlier_sum_ext[i])
                                 : $signed({{(32-PSUM_W){Macro_out[i*PSUM_W+PSUM_W-1]}}, Macro_out[i*PSUM_W+:PSUM_W]});
            end

        end
    endgenerate


    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_adder_out
            assign adder_din_a[i]     = Macro_out_reg[i];
            assign adder_din_a_exp[i] = NNIN_E_max + W_E_most[i];

            always @(posedge clk or negedge rstn) begin
                if(!rstn) begin
                    adder_din_b[i]     <= 'b0;
                    adder_din_b_exp[i] <= 'b0;
                end
                else if (din_valid) begin
                    adder_din_b[i]     <= adder_enb? 'b0: self_buffer[i][buffer_row_addr];
                    adder_din_b_exp[i] <= adder_enb? 'b0: self_buffer_exp[i][buffer_row_addr];
                end
            end

            assign exp_delta_a[i] 		 = adder_din_a_exp[i]>adder_din_b_exp[i]? adder_din_a_exp[i] - adder_din_b_exp[i]: 'b0;
            assign exp_delta_b[i] 		 = adder_din_b_exp[i]>adder_din_a_exp[i]? adder_din_b_exp[i] - adder_din_a_exp[i]: 'b0;

            assign self_adder_out[i]     = fp_en ? adder_din_a[i]<<<exp_delta_a[i] + adder_din_b[i]<<<exp_delta_b[i] : adder_din_a[i] + adder_din_b[i];
            assign self_adder_out_exp[i] = fp_en ? (adder_din_a_exp[i] < adder_din_b_exp[i] ? adder_din_a_exp[i] : adder_din_b_exp[i]) : 'b0;
        end
    endgenerate

    integer j,k;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            for ( j = 0; j < BUFFER_ROW; j = j + 1)
                for ( k = 0; k < 8; k = k + 1) begin
                    self_buffer[k][j]     <= 'b0;
                    self_buffer_exp[k][j] <= 'b0;
                end
        else
            if(din_valid_d0)
                for ( k = 0; k < 8; k = k + 1) begin
                    //Macro_out_reg已经为32位有符号数，不再需要显示扩展
                    self_buffer[k][buffer_row_addr_reg] <= self_adder_out[k];
                    self_buffer_exp[k][buffer_row_addr_reg] <= self_adder_out_exp[k];
                end
    end

    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_fp_combine
            fp_combine u_fp_combine (
                           .mantissa(self_buffer[i][buffer_row_addr_reg]),
                           .exponent(self_buffer_exp[i][buffer_row_addr_reg]),
                           .fp32_val(data_out_fp[i])
                       );
        end
    endgenerate


    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_data_out
            assign data_out[i*32+:32] = fp_en? data_out_fp[i]: self_buffer[i][buffer_row_addr_reg];
        end
    endgenerate

endmodule

module fp_combine (
        input  [31:0] mantissa,    // 32bit 补码尾数
        input  [7:0]  exponent,    // 8bit 无符号指数
        output reg [31:0] fp32_val // 输出 IEEE754 FP32
    );

    reg [31:0] abs_val;
    reg        sign;
    reg [5:0]  leading_one_pos;
    reg [7:0]  fp_exp;
    reg [31:0] mantissa_shifted;
    reg [26:0] mantissa_27b;

    reg        found_one;
    integer    k;

    always @(*) begin
        // 1. 符号位
        sign = mantissa[31];

        // 2. 取绝对值
        abs_val = sign ? (~mantissa + 1'b1) : mantissa;

        // 3. 查找最高位1（优先编码器）
        leading_one_pos = 0;
        found_one = 1'b0;
        for (k = 31; k >= 0; k = k - 1) begin
            if (!found_one && abs_val[k]) begin
                leading_one_pos = k[5:0];
                found_one = 1'b1;
            end
        end

        // 4. 指数计算
        fp_exp = found_one ? (exponent + leading_one_pos + 8'd127) : 8'd0;

        // 5. 移位对齐，保留27bit
        mantissa_shifted = (found_one) ? (abs_val << (31 - leading_one_pos)) : 32'd0;
        mantissa_27b     = mantissa_shifted[31:5]; // 27位(含隐藏位和Guard bits)

        // 6. 拼装fp32（只取23位mantissa）
        fp32_val = (abs_val == 32'd0) ? 32'd0 : {sign, fp_exp[7:0], mantissa_27b[26:4]};
    end

endmodule
