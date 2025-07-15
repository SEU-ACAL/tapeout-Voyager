`timescale 1ns/1ps

module outlier_small_Macro_top #(
    parameter ROW_NUM_Macro = 32,
    parameter ROW_NUM_2 = 16,
    parameter ROW_NUM_4 = 4
)(
    input                            clk_cim,
    input                            clk_w,
    input                            rstn,
    //WD_shifter
    input                            fp_en,   // 1 enable, 0 disable
    input [$clog2(ROW_NUM_Macro):0]  WADR,
    input [63:0]                     E_most,
    input [63:0]                     WD_E,
    input [63:0]                     WD_M,
    //outlier_process
    input                            buffer0_rst,
    input                            buffer1_rst,
    input                            WEB,
    input                            MEB,
    input                            CIMADR_MSB,
    input [8*ROW_NUM_Macro-1:0]      full_NNIN,

    output [63:0]                    WD_out,
    output [15*8-1:0]                outlier_sum,
    output                           dout_valid    
);

wire [7:0]  outlier_valid_2bit;
wire [$clog2(ROW_NUM_Macro)-1:0] outlier_index_2bit;
wire [15:0] outlier_value_2bit;

wire [7:0]  outlier_valid_4bit;
wire [$clog2(ROW_NUM_Macro)-1:0] outlier_index_4bit;
wire [31:0] outlier_value_4bit;

WD_shifter_macro #(
    .ROW_NUM                (ROW_NUM_Macro),
    .COL_GROUP_NUM          (8),
    .WD_E_W                 (8),
    .WD_M_W                 (8)
) u_WD_shifter_macro (
    .FPEN                   (fp_en),
    .WADR                   (WADR),
    .E_most                 (E_most),
    .WD_E                   (WD_E),
    .WD_M                   (WD_M),
    .outlier_valid_2b       (outlier_valid_2bit),
    .input_idx_2b           (outlier_index_2bit),
    .outlier_value_2b       (outlier_value_2bit),
    .outlier_valid_4b       (outlier_valid_4bit),
    .input_idx_4b           (outlier_index_4bit),
    .outlier_value_4b       (outlier_value_4bit),
    .WD_out                 (WD_out)
);

reg [8*$clog2(ROW_NUM_2)-1:0] WADR_2bit;
reg [8*$clog2(ROW_NUM_4)-1:0] WADR_4bit;
genvar k;
generate
    for(k = 0; k < 8; k = k + 1) begin
        always @(posedge clk_w or negedge rstn) begin
            if(!rstn) begin
                WADR_2bit[k*$clog2(ROW_NUM_2) +: $clog2(ROW_NUM_2)] <= 'd0;
                WADR_4bit[k*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)] <= 'd0;
            end
            else begin
                if(outlier_valid_2bit[k]) begin
                    WADR_2bit[k*$clog2(ROW_NUM_2) +: $clog2(ROW_NUM_2)] <= WADR_2bit[k*$clog2(ROW_NUM_2) +: $clog2(ROW_NUM_2)] + 1'b1;
                end
                if(outlier_valid_4bit[k]) begin
                    WADR_4bit[k*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)] <= WADR_4bit[k*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)] + 1'b1;
                end  
            end
        end 
    end
endgenerate

outlier_mac_small_Macro #(
    .ROW_NUM         (ROW_NUM_Macro),
    .ROW_NUM_2       (ROW_NUM_2    ),
    .ROW_NUM_4       (ROW_NUM_4    ) 
) u_outlier_mac_small_Macro(
    .clk_cim                (clk_cim),
    .clk_w                  (clk_w),
    .rstn                   (rstn),
    .buffer0_rst            (buffer0_rst),
    .buffer1_rst            (buffer1_rst),
    .din2_valid             (outlier_valid_2bit),
    .din4_valid             (outlier_valid_4bit),
    .WEB                    (WEB),
    .MEB                    (MEB),
    .fp_en                  (fp_en),
    .W_sel                  (WADR[$clog2(ROW_NUM_Macro)]), 
    .WADR_2bit              (WADR_2bit),
    .WADR_4bit              (WADR_4bit),
    .CIMADR_MSB             (CIMADR_MSB),
    .full_NNIN              (full_NNIN),
    .outlier_value2         (outlier_value_2bit),
    .outlier_value4         (outlier_value_4bit),
    .outlier_index_2bit     (outlier_index_2bit),
    .outlier_index_4bit     (outlier_index_4bit),
    .outlier_mac_out        (outlier_sum),
    .dout_valid             (dout_valid)    
);

endmodule