`timescale 1ns/1ps

module NPU_core_large #(
        parameter Macro_ROW_NUM = 256,
        parameter ROW_NUM_2 = 32,
        parameter ROW_NUM_4 = 16,
        parameter GROUP_ROW_NUM = 32,
        parameter ROW_GROUP_NUM = 8,
        parameter COL_NUM = 64,
        parameter COL_GROUP_NUM = 8,
        parameter WEIGHT_W = 8,
        parameter BUFFER_ROW = 16
    )(
        // input public
        input                                   clk_w,
        input                                   clk_cim,
        input                                   rstn,
        input                                   din_valid,

        // NNIN
        input [Macro_ROW_NUM*8-1:0]          	NNIN,
        // input [1:0]                             combine_mode,
        // input [2:0]                             NNIN_sel,

        // outlier & macro public
        input [$clog2(Macro_ROW_NUM):0]         WADR,                   // 所有macro共用一个
        input [7:0]                             WEB,                    // 每个macro不一样，位宽x8
        input [7:0]                             MEB,                    // 每个macro不一样，位宽x8

        // outlier_large_macro_top
        input                                   fp_en,                  // 1 enable, 0 disable
        input [64*8-1:0]                        E_most,                 // 每个macro不一样(每个channel都不一样，自然每个macro不一样)，位宽x8
        input [64*8-1:0]                        WD_E,                   // 每个macro不一样，位宽x8
        input [64*8-1:0]                       	WD_M,                   // 每个macro不一样，位宽x8
        input [7:0]                       		buffer0_rst,            // 每个macro不一样，位宽x8
        input [7:0]                       	    buffer1_rst,            // 每个macro不一样，位宽x8
        input [7:0]                             compute_valid,          // 每个macro不一样，位宽x8
        // input [8*Macro_ROW_NUM-1:0]             full_NNIN,
        // input [8*Macro_ROW_NUM-1:0]             NNIN_all,

        // macro
        input [$clog2(Macro_ROW_NUM):0]         CIMADR,                 // 所有macro共用一个

        input                                   sign_bit,               // 所有macro共用一个
        input [7:0]                             adder_enb,              // 每个macro不一样，位宽x8
        input [3:0]                        		buffer_row_addr,        // 每个macro不一样，位宽x8  //7.7修改共用

        // output
        output [32*8*8-1:0]                     outlier_sum,            // 每个macro不一样，位宽x8
        output [7:0]                            dout_valid,             // 每个macro不一样，位宽x8

        output [256*8-1:0]                      data_out,                // 每个macro不一样，位宽x8

        output								  	CIM_compute_ready         // =1,CIM计算准备好
    );

    // between NNIN & macro
    wire [Macro_ROW_NUM-1:0]      			NNIN_bit;

    // between outlier & macro
    wire [COL_NUM*8-1:0]                    WD;                     // 每个macro不一样，位宽x8

    // macro unuse signal
    wire                                    REN;
    wire [$clog2(COL_NUM)-1:0]              RA;
    wire [5:0]                              DM;
    wire                                    BIST_MODE;
    wire                                    SCAN_MODE;
    wire                                    SE;
    wire                                    NNIN_SI;
    wire                                    PSUM_SI;

    wire 									C_SEL;
    reg 									C_SEL_reg;

    assign W_SEL = WADR[$clog2(Macro_ROW_NUM)];
    always @(posedge clk_w or negedge rstn) begin
        if (!rstn)
            C_SEL_reg <= 1'b0;
        else
            C_SEL_reg <= W_SEL;
    end
    assign CIM_compute_ready				 = !(C_SEL_reg ^ C_SEL);


    assign REN       = 1'b0;
    assign RA        = 6'b0;
    assign DM        = 6'b0;
    assign BIST_MODE = 1'b0;
    assign SCAN_MODE = 1'b0;
    assign SE        = 1'b0;
    assign NNIN_SI   = 1'b0;
    assign PSUM_SI   = 1'b0;

    NNIN_shifter#(
                    .Macro_ROW_NUM ( Macro_ROW_NUM )
                )u_NNIN_shifter(
                    .clk       ( clk_cim   	 ),
                    .rstn      ( rstn     	 ),
                    .din_valid ( din_valid	 ),
                    .NNIN_data ( NNIN		 ),
                    .NNIN_bit  ( NNIN_bit 	 )
                );



    genvar i;
    generate
        for(i=0;i<8;i=i+1) begin : outlier_large_Macro_top_group
            outlier_large_Macro_top #(
                                        .ROW_NUM_Macro ( Macro_ROW_NUM ),
                                        .ROW_NUM_2     ( ROW_NUM_2     ),
                                        .ROW_NUM_4     ( ROW_NUM_4     )
                                    ) u_outlier_large_Macro_top (
                                        .clk_cim       ( clk_cim                                 ),
                                        .clk_w         ( clk_w                                   ),
                                        .rstn          ( rstn                                    ),
                                        .fp_en         ( fp_en                                   ),
                                        .WADR          ( WADR                                    ),
                                        .E_most        ( E_most[i*64+:64]                        ),
                                        .WD_E          ( WD_E[i*64+:64]                          ),
                                        .WD_M          ( WD_M[i*64+:64]                          ),
                                        .buffer0_rst   ( buffer0_rst[i]                          ),
                                        .buffer1_rst   ( buffer1_rst[i]                          ),
                                        .WEB           ( WEB[i]                                  ),
                                        .MEB           ( MEB[i]                                  ),
                                        .CIMADR_MSB    ( CIMADR[$clog2(Macro_ROW_NUM)]           ),
                                        .compute_valid ( compute_valid[i]                        ),
                                        .full_NNIN     ( NNIN 								 	 ),
                                        .WD_out        ( WD[i*COL_NUM+:COL_NUM]                  ),
                                        .outlier_sum   ( outlier_sum[i*32*8+:32*8]               ),
                                        .dout_valid    ( dout_valid[i]                           )
                                    );
        end
    endgenerate

    genvar j;
    generate
        for(j=0;j<8;j=j+1) begin : macro_group
            Macro_large #(
                            .ROW_NUM         ( Macro_ROW_NUM   ),
                            .GROUP_ROW_NUM   ( GROUP_ROW_NUM   ),
                            .ROW_GROUP_NUM   ( ROW_GROUP_NUM   ),
                            .COL_NUM         ( COL_NUM         ),
                            .COL_GROUP_NUM   ( COL_GROUP_NUM   ),
                            .WEIGHT_W        ( WEIGHT_W        ),
                            .BUFFER_ROW      ( BUFFER_ROW      )
                        ) u_Macro_large (
                            .clk_cim         ( clk_cim                     ),
                            .clk_w           ( clk_w                       ),
                            .rstn            ( rstn                        ),
                            .MEB             ( MEB[j]                      ),
                            .WEB             ( WEB[j]                      ),
                            .WADR            ( WADR                        ),
                            .CIMADR          ( CIMADR                      ),
                            .NNIN            ( NNIN_bit                    ),
                            .WD              ( WD[j*COL_NUM+:COL_NUM]      ),
                            .REN             ( REN                         ),
                            .RA              ( RA                          ),
                            .DM              ( DM                          ),
                            .BIST_MODE       ( BIST_MODE                   ),
                            .SCAN_MODE       ( SCAN_MODE                   ),
                            .SE              ( SE                          ),
                            .NNIN_SI         ( NNIN_SI                     ),
                            .PSUM_SI         ( PSUM_SI                     ),
                            .din_valid       ( {sign_bit,din_valid}        ),
                            .adder_enb       ( adder_enb[j]                ),
                            .buffer_row_addr ( buffer_row_addr  		   ),
                            .Q               (                             ),
                            .data_out        ( data_out[j*256+:256]        )
                        );
        end
    endgenerate
endmodule
