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
        // input [Macro_ROW_NUM*8-1:0]          NNIN_all,   //共用
        input [Macro_ROW_NUM*8-1:0]          	NNIN_E,
        input [Macro_ROW_NUM*8-1:0]          	NNIN_M,

        // outlier & macro public
        input [$clog2(Macro_ROW_NUM):0]         WADR,                   // 每个macro共用一个
        input [3:0]                             WEB,                    // 每个macro不一样，位宽x4
        input [3:0]                             MEB,                    // 每个macro不一样，位宽x4

        // outlier_large_macro_top
        input                                   fp_en,                  // 1 enable, 0 disable
        input [64*4-1:0]                        E_most,                 // 每个macro不一样(每个channel都不一样，自然每个macro不一样)，位宽x4
        input [64*4-1:0]                        WD_E,                   // 每个macro不一样，位宽x4
        input [64*4-1:0]                        WD_M,                   // 每个macro不一样，位宽x4
        input 		                            buffer0_rst,            // 每个macro不一样，位宽x4
        input 		                            buffer1_rst,            // 每个macro不一样，位宽x4
        // 小核不需要compute_valid
        // input [7:0]                          compute_valid,          // 每个macro不一样，位宽x8

        // macro
        input [1:0]                             CIMADR,                 // 每个macro共用一个 (小核的CIMADR只有最高位核最低位有用)

        input 		                            adder_enb,              // 每个macro不一样，位宽x4
        input [3:0]                             buffer_row_addr,        // 修改为共用

        // output
        output [15*8*4-1:0]                     outlier_sum,            // 每个macro不一样，位宽x4


        output 		                            outlier_out_valid,      // 每个macro不一样，位宽x4


        output [256*4-1:0]                      data_out,               // 每个macro不一样，位宽x4
        output 		                            Macro_out_valid
    );

    // between NNIN & macro
    wire [Macro_ROW_NUM-1:0]      		        NNIN_bit;               // NNIN的单比特输出

    // between outlier & macro
    wire [COL_NUM*4-1:0]                        WD;                     // 每个macro不一样，位宽x4

    //between NNIN & outlier
    //由于NNIN是共用的，所以不再需要从NNIN_NOC中引出重组之后的NNIN_INT8     // 7.19修改 再使用NNIN_top之后，还需要从NNIN_pre_align移位后(FP16)引出MMIN_data
    //wire [Macro_ROW_NUM*8*4-1:0]    		    NNIN_INT8;
    wire [Macro_ROW_NUM*8-1:0]                  NNIN_data;              // 每个macro共用一个输入

    // macro unuse signal
    wire                                    REN;
    wire [$clog2(COL_NUM)-1:0]              RA;
    wire [5:0]                              DM;
    wire                                    BIST_MODE;
    wire                                    SCAN_MODE;
    wire                                    SE;
    wire                                    NNIN_SI;
    wire                                    PSUM_SI;
    wire [3:0]								Macro_out_valid_w;
    wire [3:0]								dout_valid;

    assign Macro_out_valid   = |Macro_out_valid_w;
    assign outlier_out_valid = |dout_valid;

    assign REN = 1'b0;
    assign RA = 6'b0;
    assign DM = 6'b0;
    assign BIST_MODE = 1'b0;
    assign SCAN_MODE = 1'b0;
    assign SE = 1'b0;
    assign NNIN_SI = 1'b0;
    assign PSUM_SI = 1'b0;

    NNIN_top #(
        .Macro_ROW_NUM  ( Macro_ROW_NUM  )  
    ) u_NNIN_top (
        .clk            ( clk_cim        ),          
        .rstn           ( rstn           ),       
        .din_valid      ( din_valid      ),    
        .fp_en          ( fp_en          ),      
        .NNIN_E_all     ( NNIN_E         ),   
        .NNIN_M_all     ( NNIN_M         ), 
        .NNIN_bit       ( NNIN_bit       ),     
        .NNIN_data      ( NNIN_data      )     
    );

    genvar i;
    generate
        for(i=0;i<4;i=i+1) begin : outlier_small_Macro_top_group
            outlier_small_Macro_top #(
                                        .ROW_NUM_Macro  ( Macro_ROW_NUM  ),
                                        .ROW_NUM_2      ( ROW_NUM_2      ),
                                        .ROW_NUM_4      ( ROW_NUM_4      )
                                    ) u_outlier_large_Macro_top (
                                        .clk_cim        ( clk_cim                    ),
                                        .clk_w          ( clk_w                      ),
                                        .rstn           ( rstn                       ),
                                        .fp_en          ( fp_en                      ),
                                        .WADR           ( WADR                       ),
                                        .E_most         ( E_most[i*64+:64]           ),
                                        .WD_E           ( WD_E[i*64+:64]             ),
                                        .WD_M           ( WD_M[i*64+:64]             ),
                                        .buffer0_rst    ( buffer0_rst             ),
                                        .buffer1_rst    ( buffer1_rst             ),
                                        .WEB            ( WEB[i]                     ),
                                        .MEB            ( MEB[i]                     ),
                                        .CIMADR_MSB     ( CIMADR[1]                  ),
                                        .full_NNIN      ( NNIN_data                  ),
                                        .WD_out         ( WD[i*COL_NUM+:COL_NUM]     ),
                                        .outlier_sum    ( outlier_sum[i*15*8+:15*8]  ),
                                        .dout_valid     ( dout_valid[i]              )
                                    );
        end
    endgenerate

    genvar j;
    generate
        for(j=0;j<4;j=j+1) begin : macro_group
            Macro_small #(
                            .ROW_NUM                    ( Macro_ROW_NUM              ),
                            .GROUP_ROW_NUM              ( GROUP_ROW_NUM              ),
                            .ROW_GROUP_NUM              ( ROW_GROUP_NUM              ),
                            .COL_NUM                    ( COL_NUM                    ),
                            .COL_GROUP_NUM              ( COL_GROUP_NUM              ),
                            .WEIGHT_W                   ( WEIGHT_W                   ),
                            .BUFFER_ROW(BUFFER_ROW)
                        ) u_Macro_small (
                            .clk_cim                    ( clk_cim                        ),
                            .clk_w                      ( clk_w                          ),
                            .rstn                       ( rstn                           ),
                            .MEB                        ( MEB[j]                         ),
                            .WEB                        ( WEB[j]                         ),
                            .WADR                       ( WADR                           ),
                            .CIMADR                     ( {CIMADR[1],4'b0,CIMADR[0]}     ),
                            .NNIN                       ( NNIN_bit                       ),
                            .WD                         ( WD[j*COL_NUM+:COL_NUM]         ),
                            .REN                        ( REN                            ),
                            .RA                         ( RA                             ),
                            .DM                         ( DM                             ),
                            .BIST_MODE                  ( BIST_MODE                      ),
                            .SCAN_MODE                  ( SCAN_MODE                      ),
                            .SE                         ( SE                             ),
                            .NNIN_SI                    ( NNIN_SI                        ),
                            .PSUM_SI                    ( PSUM_SI                        ),
                            .din_valid                  ( din_valid                      ),
                            .adder_enb                  ( adder_enb                   ),
                            .buffer_row_addr            ( buffer_row_addr                ),
                            .Q                          (                                ),
                            .data_out                   ( data_out[j*256+:256]           ),
                            .Macro_dout_valid           ( Macro_out_valid_w[j]           )
                        );
        end
    endgenerate
endmodule
