`timescale 1ns / 1ps

module outlier_mac_small_Macro #(
    parameter ROW_NUM = 32,
    parameter ROW_NUM_2 = 16,
    parameter ROW_NUM_4 = 4

)(
    input                               clk_cim,
    input                               clk_w,
    input                               rstn,
    input                               buffer0_rst,        // buffer0: 2bit buffer
    input                               buffer1_rst,        // buffer1: 4bit buffer
    input [7:0]                         din2_valid,
    input [7:0]                         din4_valid,
    input                               WEB,
    input                               MEB,
    input                               fp_en,              // 1 enable, 0 disable
    input                               W_sel,              // select which buffer to write
    input [$clog2(ROW_NUM_2)*8-1:0]     WADR_2bit,     
    input [$clog2(ROW_NUM_4)*8-1:0]     WADR_4bit,     
    input                               CIMADR_MSB,
    input [8*ROW_NUM-1:0]               full_NNIN,
    input [15:0]                        outlier_value2,
    input [31:0]                        outlier_value4,
    input [$clog2(ROW_NUM)-1:0]         outlier_index_2bit,
    input [$clog2(ROW_NUM)-1:0]         outlier_index_4bit,
    output [15*8-1:0]                   outlier_mac_out,
    output reg                          dout_valid
);

genvar i;
generate
    for(i = 0; i < 8; i = i + 1) begin
        outlier_mac_small_channel #(
            .ROW_NUM      (32),
            .ROW_NUM_2    (16),
            .ROW_NUM_4    (4 )
        ) u_outlier_mac_small_channel (
            .clk_cim                    (clk_cim                                            ) ,
            .clk_w                      (clk_w                                              ) ,
            .rstn                       (rstn                                               ) ,
            .buffer0_rst                (buffer0_rst                                        ) ,      
            .buffer1_rst                (buffer1_rst                                        ) ,      
            .din2_valid                 (din2_valid[i]                                      ) ,
            .din4_valid                 (din4_valid[i]                                      ) ,
            .WEB                        (WEB                                                ) ,
            .MEB                        (MEB                                                ) ,
            .fp_en                      (fp_en                                              ) ,            
            .W_sel                      (W_sel                                              ) ,            
            .WADR_2bit                  (WADR_2bit[i*$clog2(ROW_NUM_2) +: $clog2(ROW_NUM_2)]) ,     
            .WADR_4bit                  (WADR_4bit[i*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)]) ,      
            .CIMADR_MSB                 (CIMADR_MSB                                         ) ,
            .full_NNIN                  (full_NNIN                                          ) ,
            .outlier_value2             (outlier_value2[i*2 +: 2]                           ) ,
            .outlier_value4             (outlier_value4[i*4 +: 4]                           ) ,
            .outlier_index_2bit         (outlier_index_2bit                                 ) ,
            .outlier_index_4bit         (outlier_index_4bit                                 ) ,
            .outlier_mac_out            (outlier_mac_out[i*15 +: 15]                        ) ,
            .dout_valid                 (dout_valid                                         )
        );
    end

endgenerate

endmodule