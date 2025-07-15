`timescale 1ns/1ps

module NPU_core_small #(
    parameter Macro_ROW_NUM = 32,
    parameter ROW_NUM_2 = 16,
    parameter ROW_NUM_4 = 4,
    parameter GROUP_ROW_NUM = 32,
    parameter ROW_GROUP_NUM = 1,
    parameter COL_NUM = 64,
    parameter COL_GROUP_NUM = 8,
    parameter WEIGHT_W = 8,
    parameter BUFFER_ROW = 16
)(
    // input public
    input                                   clk_cim,
    input                                   clk_w,
    input                                   rstn,     
    input                                   din_valid,

    // NNIN
    input [Macro_ROW_NUM*8*8-1:0]           NNIN_all,
    input [1:0]                             combine_mode,
	input [2:0]                             NNIN_sel,

    // outlier & macro public
    input [$clog2(Macro_ROW_NUM):0]         WADR,                   // 每个macro共用一个   
    input [7:0]                             WEB,                    // 每个macro不一样，位宽x8
    input [7:0]                             MEB,                    // 每个macro不一样，位宽x8

    // outlier_large_macro_top
    input                                   fp_en,                  // 1 enable, 0 disable
    input [64*8-1:0]                        E_most,                 // 每个macro不一样(每个channel都不一样，自然每个macro不一样)，位宽x8
    input [64*8-1:0]                        WD_E,                   // 每个macro不一样，位宽x8
    input [64*8-1:0]                        WD_M,                   // 每个macro不一样，位宽x8
    input [7:0]                             buffer0_rst,            // 每个macro不一样，位宽x8
    input [7:0]                             buffer1_rst,            // 每个macro不一样，位宽x8
    input [7:0]                             compute_valid,          // 每个macro不一样，位宽x8
    input [8*Macro_ROW_NUM-1:0]             full_NNIN,              

    // macro       
    input [1:0]                             CIMADR,                 // 每个macro共用一个 (小核的CIMADR只有最高位核最低位有用)              
    
    input                                   sign_bit,               // 每个macro共用一个
    input [7:0]                             adder_enb,              // 每个macro不一样，位宽x8
    input [3:0]                             buffer_row_addr,        // 共用
    
    // output
    output [15*8*8-1:0]                     outlier_sum,            // 每个macro不一样，位宽x8
    output [7:0]                            dout_valid,             // 每个macro不一样，位宽x8

    output [256*8-1:0]                      data_out,               // 每个macro不一样，位宽x8

    output                                  CIM_store_ready
);

    // between NNIN & macro
    wire [Macro_ROW_NUM*8-1:0]      		NNIN_bit;

    // between outlier & macro
    wire [COL_NUM*8-1:0]                    WD;                     // 每个macro不一样，位宽x8 

    //between NNIN & outlier
    wire [Macro_ROW_NUM*8*8-1:0]    		NNIN_INT8;

    // macro unuse signal
    wire                                    REN;
    wire [$clog2(COL_NUM)-1:0]              RA;
    wire [5:0]                              DM;                     
    wire                                    BIST_MODE;
    wire                                    SCAN_MODE;
    wire                                    SE;
    wire                                    NNIN_SI;
    wire                                    PSUM_SI;

    wire 									W_SEL;
	reg 									W_SEL_reg;

    assign W_SEL = WADR[$clog2(Macro_ROW_NUM)];
    always @(posedge clk_w or negedge rstn) begin
        if (!rstn)
            W_SEL_reg <= 1'b0;
        else
            W_SEL_reg <= W_SEL;
    end
    assign CIM_store_ready				 = !(W_SEL_reg ^ W_SEL);

    assign REN = 1'b0;
    assign RA = 6'b0;
    assign DM = 6'b0;
    assign BIST_MODE = 1'b0;
    assign SCAN_MODE = 1'b0;
    assign SE = 1'b0;
    assign NNIN_SI = 1'b0;
    assign PSUM_SI = 1'b0;

    NNIN #(
        .Macro_ROW_NUM(Macro_ROW_NUM)
    ) u_NNIN (
        .clk(clk_cim),
        .rstn(rstn),
        .din_valid(din_valid),               
        .NNIN_all(NNIN_all),
        .combine_mode(combine_mode),
        .NNIN_sel(NNIN_sel),
        .NNIN_bit(NNIN_bit),
        .NNIN_INT8(NNIN_INT8)
    );

    genvar i;
    generate
        for(i=0;i<8;i=i+1) begin : outlier_small_Macro_top_group
            outlier_small_Macro_top #(
                .ROW_NUM_Macro(Macro_ROW_NUM),
                .ROW_NUM_2(ROW_NUM_2),
                .ROW_NUM_4(ROW_NUM_4)
            ) u_outlier_large_Macro_top (
                .clk_cim(clk_cim),
                .clk_w(clk_w),
                .rstn(rstn),
                .fp_en(fp_en),
                .WADR(WADR),
                .E_most(E_most[i*64+:64]),
                .WD_E(WD_E[i*64+:64]),
                .WD_M(WD_M[i*64+:64]),
                .buffer0_rst(buffer0_rst[i]),
                .buffer1_rst(buffer1_rst[i]),
                .WEB(WEB[i]),
                .MEB(MEB[i]),
                .CIMADR_MSB(CIMADR[1]),
                .full_NNIN(NNIN_INT8[i*Macro_ROW_NUM*8+:Macro_ROW_NUM*8]),
                .WD_out(WD[i*COL_NUM+:COL_NUM]),
                .outlier_sum(outlier_sum[i*15*8+:15*8]),
                .dout_valid(dout_valid[i])
            );
        end
    endgenerate

    genvar j;
    generate
        for(j=0;j<8;j=j+1) begin : macro_group
            Macro_small #(
                .ROW_NUM(Macro_ROW_NUM),
                .GROUP_ROW_NUM(GROUP_ROW_NUM),
                .ROW_GROUP_NUM(ROW_GROUP_NUM),
                .COL_NUM(COL_NUM),
                .COL_GROUP_NUM(COL_GROUP_NUM),
                .WEIGHT_W(WEIGHT_W),
                .BUFFER_ROW(BUFFER_ROW)
            ) u_Macro_small (
                .clk_cim(clk_cim),
                .clk_w(clk_w),
                .rstn(rstn),
                .MEB(MEB[j]),
                .WEB(WEB[j]),
                .WADR(WADR),
                .CIMADR({CIMADR[1],4'b0,CIMADR[0]}),
                .NNIN(NNIN_bit[j*Macro_ROW_NUM+:Macro_ROW_NUM]),
                .WD(WD[j*COL_NUM+:COL_NUM]),
                .REN(REN),
                .RA(RA),
                .DM(DM),
                .BIST_MODE(BIST_MODE),
                .SCAN_MODE(SCAN_MODE),
                .SE(SE),
                .NNIN_SI(NNIN_SI),
                .PSUM_SI(PSUM_SI),
                .din_valid({sign_bit,din_valid}),
                .adder_enb(adder_enb[j]),
                .buffer_row_addr(buffer_row_addr[j*4+:4]),
                .Q(),
                .data_out(data_out[j*256+:256])
            );
        end
    endgenerate
endmodule