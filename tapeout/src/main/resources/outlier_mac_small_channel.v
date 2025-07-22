`timescale 1ns / 1ps

module outlier_mac_small_channel #(
    parameter ROW_NUM = 32,
    parameter ROW_NUM_2 = 16,
    parameter ROW_NUM_4 = 4
)(
    input                               clk_cim,
    input                               clk_w,
    input                               rstn,
    input                               buffer0_rst,        // buffer0: 2bit buffer
    input                               buffer1_rst,        // buffer1: 4bit buffer
    input                               din2_valid,
    input                               din4_valid,
    input                               WEB,
    input                               MEB,
    input                               fp_en,              // 1 enable, 0 disable
    input                               W_sel,              // select which buffer to write
    input [$clog2(ROW_NUM_2)-1:0]       WADR_2bit,     
    input [$clog2(ROW_NUM_4)-1:0]       WADR_4bit,     
    input                               CIMADR_MSB,
    input [8*ROW_NUM-1:0]               full_NNIN,
    input [1:0]                         outlier_value2,
    input [3:0]                         outlier_value4,
    input [$clog2(ROW_NUM)-1:0]         outlier_index_2bit,
    input [$clog2(ROW_NUM)-1:0]         outlier_index_4bit,
    output signed[31:0]                 outlier_mac_out,
    output reg                          dout_valid
);

wire [7:0]                     NNIN[0:ROW_NUM-1];
genvar a;
generate
    for(a = 0; a < ROW_NUM; a = a + 1) begin
        assign NNIN[a] = full_NNIN[(a+1)*8-1 -: 8];
    end
endgenerate

reg                            din2_valid_0;
reg                            din4_valid_0;
always @(posedge clk_w or negedge rstn) begin
    if (!rstn) begin
        din2_valid_0 <= 'b0;
        din4_valid_0 <= 'b0;
    end
    else begin
        din2_valid_0 <= din2_valid;
        din4_valid_0 <= din4_valid;
    end
end

reg [1:0]                     value_buffer2[0:1][0:15]; 
reg [3:0]                     value_buffer4[0:1][0:3];                 
reg [$clog2(ROW_NUM)-1:0]     index_buffer2[0:1][0:15];
reg [$clog2(ROW_NUM)-1:0]     index_buffer4[0:1][0:3];
integer i,j;
always @(posedge clk_w or negedge rstn) begin
    if (!rstn) begin
        for(i = 0; i < 2; i = i + 1) begin
            for(j = 0; j < 16; j = j + 1) begin
                index_buffer2[i][j] <= 'b0;
                value_buffer2[i][j] <= 'b0;
            end
            for(j = 0; j < 4; j = j + 1) begin
                index_buffer4[i][j] <= 'b0;
                value_buffer4[i][j] <= 'b0;
            end
        end
    end
    else if(buffer0_rst || buffer1_rst) begin
        if(buffer0_rst == 1'b1) begin
            for(j = 0; j < 16; j = j + 1) begin
                index_buffer2[0][j] <= 'b0;
                value_buffer2[0][j] <= 'b0;
            end
            for(j = 0; j < 4; j = j + 1) begin
                index_buffer4[0][j] <= 'b0;
                value_buffer4[0][j] <= 'b0;
            end
        end
        if (buffer1_rst == 1'b1) begin
            for(j = 0; j < 16; j = j + 1) begin
                index_buffer2[1][j] <= 'b0;
                value_buffer2[1][j] <= 'b0;
            end
            for(j = 0; j < 4; j = j + 1) begin
                index_buffer4[1][j] <= 'b0;
                value_buffer4[1][j] <= 'b0;
            end
        end
    end
    else if(!WEB) begin
        if(din2_valid_0) begin
            value_buffer2[W_sel][WADR_2bit] <= outlier_value2;
            index_buffer2[W_sel][WADR_2bit] <= outlier_index_2bit;
        end
        if(din4_valid_0) begin        
            value_buffer4[W_sel][WADR_4bit] <= outlier_value4;
            index_buffer4[W_sel][WADR_4bit] <= outlier_index_4bit;
        end 
    end
end

reg [3:0] cnt;
always @(posedge clk_cim or negedge rstn) begin
    if(!rstn) begin
        cnt <= 4'b0000;
        dout_valid <= 1'b0;
    end
    else if(MEB || !fp_en || dout_valid) begin
        cnt <= 4'b0000;
        dout_valid <= 1'b0;
    end
    else if(cnt == 4'b0111) begin
        cnt <= 4'b000;
        dout_valid <= 1'b1;
    end
    else begin
        cnt <= cnt + 1'b1;
        dout_valid <= 1'b0;
    end
end

reg signed [13:0]  temp_pmul1;
reg signed [13:0]  temp_pmul2;

always @(posedge clk_cim or negedge rstn) begin
    if(!rstn) begin
        temp_pmul1 <= 'b0;
    end
    else if(MEB || !fp_en || dout_valid) begin
        temp_pmul1 <= 'b0;
    end
    else begin // 1,2,3,4,5,6,7
        temp_pmul1 <= temp_pmul1 + $signed(value_buffer2[CIMADR_MSB][(cnt << 1)])*$signed(NNIN[index_buffer2[CIMADR_MSB][(cnt << 1)]]) + $signed(value_buffer2[CIMADR_MSB][(cnt << 1) + 1'b1])*$signed(NNIN[index_buffer2[CIMADR_MSB][(cnt << 1) + 1'b1]]);
    end
end

always @(posedge clk_cim or negedge rstn) begin
    if(!rstn) begin
        temp_pmul2 <= 'b0;
    end
    else if(MEB || !fp_en || dout_valid || !cnt[2]) begin
        temp_pmul2 <= 'b0;
    end
    else begin
        temp_pmul2 <= temp_pmul2 + $signed(value_buffer4[CIMADR_MSB][cnt[1:0]])*$signed(NNIN[index_buffer4[CIMADR_MSB][cnt[1:0]]]);
    end
end

assign outlier_mac_out = dout_valid ? ({temp_pmul1[13],temp_pmul1} + {temp_pmul2[13],temp_pmul2}) : 'b0;

endmodule
