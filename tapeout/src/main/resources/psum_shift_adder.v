`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/08 13:03:58
// Design Name: 
// Module Name: psum_shift_adder
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


module psum_shift_adder #(
    parameter PSUM_4_W = 12,         //4+$log2(256)
    parameter COL_GROUP_NUM = 8
)(
    input                                        clk,
    input                                        rstn,
    input                                        din_valid,
    input  [PSUM_4_W*2*COL_GROUP_NUM-1:0]        PSUM_4,
    output [(PSUM_4_W + 12)*COL_GROUP_NUM-1:0]   PSUM,
    output reg                                   dout_valid
);

localparam PSUM_8_W = PSUM_4_W + 5;   //17

reg [2:0]                                bitcount;
reg                                      din_valid_d1;
reg                                      din_valid_d2;
//reg [1:0]                                din_valid_d3;                            
reg [(PSUM_8_W + 7)*COL_GROUP_NUM-1:0]   psum_temp;
reg [PSUM_8_W*COL_GROUP_NUM-1:0]         PSUM_8;


always @(posedge clk or negedge rstn)
    if(!rstn) begin
        din_valid_d1 <= 1'b0;
        din_valid_d2 <= 1'b0;
//        din_valid_d3 <= 2'b00;
    end
    else begin
        din_valid_d1 <= din_valid;
        din_valid_d2 <= din_valid_d1;
//        din_valid_d3 <= din_valid_d2;
    end

always @(posedge clk or negedge rstn)
    if(!rstn) begin
        bitcount <= 3'b000;
    end
    else if(bitcount == 3'b111) begin
        bitcount <= 3'b000;
        dout_valid <= 1'b1; 
    end
    else if(din_valid_d2) begin
        bitcount <= bitcount + 1'b1;
        dout_valid <= 1'b0;
    end
    else begin
        bitcount <= bitcount;
        dout_valid <= 1'b0;
    end

always @(*) begin
   PSUM_8 = psum_8(PSUM_4);
end

wire signed [1:0] sign;
assign sign = (bitcount==3'b111) ? 2'b11 : 2'b01;
//得到4bit*8bit/8bit*8bit的累加结果
genvar k;
generate
    for (k=0; k<COL_GROUP_NUM; k=k+1) begin
        always @(posedge clk or negedge rstn) begin
            if (!rstn) begin
                psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= 'd0;  //24位
            end
            else if (!din_valid_d2) begin
                psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= 'd0;
            end
            else begin
                 psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)]) + sign*($signed({{7{PSUM_8[(k+1)*PSUM_8_W-1]}},PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W]}) << bitcount);
            end
//            else begin
//                if (bitcount == 3'b000) begin
//                    psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W]);
//                end
//                else if (bitcount == 3'b001) begin
//                    psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)]) + $signed({PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W],1'b0});
//                end
//                else if (bitcount == 3'b010) begin
//                    psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)]) + $signed({PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W],2'b00});
//                end
//                else if (bitcount == 3'b011) begin
//                    if(din_valid_d2[1]) begin
//                        psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)]) - $signed({PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W],3'b000});
//                    end
//                    else begin
//                        psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)]) + $signed({PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W],3'b000});
//                    end
//                end
//                else if (bitcount == 3'b100) begin
//                    psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)]) + $signed({PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W],4'b0000});
//                end
//                else if (bitcount == 3'b101) begin
//                    psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)]) + $signed({PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W],5'b0_0000});
//                end
//                else if (bitcount == 3'b110) begin
//                    psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)]) + $signed({PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W],6'b00_0000});
//                end
//                else if (bitcount == 3'b111) begin
//                    if(din_valid_d2[1]) begin
//                        psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)]) - $signed({PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W],7'b000_0000});
//                    end
//                    else begin
//                        psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)] <= $signed(psum_temp[(k+1)*(PSUM_8_W + 7)-1 -: (PSUM_8_W + 7)]) + $signed({PSUM_8[(k+1)*PSUM_8_W-1 -: PSUM_8_W],7'b000_0000});
//                    end
//                end
           
        end
    end
endgenerate

//assign dout_valid = (rstn && din_valid_d3[1]) ? 1'b1 : 1'b0;
assign PSUM = psum_temp;

//高4bit累加结果和低4bit累加结果移位相加
function [PSUM_8_W*COL_GROUP_NUM-1:0] psum_8;
    input [PSUM_4_W*2*COL_GROUP_NUM-1:0]  data;
        integer i;
begin
        psum_8 = 0;
        for (i=0; i<COL_GROUP_NUM; i=i+1)
            psum_8[(i+1)*PSUM_8_W-1 -: PSUM_8_W] = $signed({data[(i+1)*2*PSUM_4_W-1],data[(i+1)*2*PSUM_4_W-1 -: PSUM_4_W],4'b0000}) + $signed({5'b0000,data[(i+1)*2*PSUM_4_W-1-PSUM_4_W -: PSUM_4_W]});
end
endfunction



endmodule
