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
        // input [Macro_ROW_NUM*8-1:0]          NNIN_all,
        input [Macro_ROW_NUM*8-1:0]          	NNIN_E,
        input [Macro_ROW_NUM*8-1:0]          	NNIN_M,

        // outlier & macro public
        input [$clog2(Macro_ROW_NUM):0]         WADR,
        input [3:0]                             WEB,
        input [3:0]                             MEB,

        // outlier_large_macro_top
        input                                   fp_en,                  // 1 enable, 0 disable
        input [64*4-1:0]                        E_most,
        input [64*4-1:0]                        WD_E,
        input [64*4-1:0]                        WD_M,
        input 		                            buffer0_rst,
        input 		                            buffer1_rst,
        // input [7:0]                          compute_valid,

        // macro
        input [1:0]                             CIMADR,

        input 		                            adder_enb,
        input [3:0]                             buffer_row_addr,

        // output
        //output [32*8*4-1:0]                   outlier_sum,
        //output 		                        outlier_out_valid,


        output [256*4-1:0]                      data_out,
        output 		                            Macro_out_valid
    );

    // between NNIN & macro
    wire [Macro_ROW_NUM-1:0]      		        NNIN_bit;

    // between outlier & macro
    wire [COL_NUM*4-1:0]                        WD;
    wire [32*8*4-1:0]                           outlier_sum;

    //between NNIN & outlier
    //wire [Macro_ROW_NUM*8*4-1:0]    		    NNIN_INT8;
    wire [Macro_ROW_NUM*8-1:0]                  NNIN_data;

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
    //wire [3:0]						    dout_valid;

	wire [7:0]                              E_max;

    assign Macro_out_valid   = |Macro_out_valid_w;
    //assign outlier_out_valid = |dout_valid;

    assign REN = 1'b0;
    assign RA = 6'b0;
    assign DM = 6'b0;
    assign BIST_MODE = 1'b0;
    assign SCAN_MODE = 1'b0;
    assign SE = 1'b0;
    assign NNIN_SI = 1'b0;
    assign PSUM_SI = 1'b0;

    // adder_enb 打三拍
    reg adder_enb_d1, adder_enb_d2, adder_enb_d3;
    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn) begin
            adder_enb_d1 <= 1'b0;
            adder_enb_d2 <= 1'b0;
            adder_enb_d3 <= 1'b0;
        end
        else begin
            adder_enb_d1 <= adder_enb;
            adder_enb_d2 <= adder_enb_d1;
            adder_enb_d3 <= adder_enb_d2;
        end
    end

    // buffer_row_addr 打四拍
    reg [3:0] buffer_row_addr_d1, buffer_row_addr_d2, buffer_row_addr_d3, buffer_row_addr_d4;
    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn) begin
            buffer_row_addr_d1 <= 4'b0;
            buffer_row_addr_d2 <= 4'b0;
            buffer_row_addr_d3 <= 4'b0;
            buffer_row_addr_d4 <= 4'b0;
        end
        else begin
            buffer_row_addr_d1 <= buffer_row_addr;
            buffer_row_addr_d2 <= buffer_row_addr_d1;
            buffer_row_addr_d3 <= buffer_row_addr_d2;
            buffer_row_addr_d4 <= buffer_row_addr_d3;
        end
    end

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
                 .NNIN_data      ( NNIN_data      ),
				 .E_max          ( E_max          )
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
                                        .buffer0_rst    ( buffer0_rst	             ),
                                        .buffer1_rst    ( buffer1_rst	             ),
                                        .WEB            ( WEB[i]                     ),
                                        .MEB            ( MEB[i]                     ),
                                        .CIMADR_MSB     ( CIMADR[1]                  ),
                                        .full_NNIN      ( NNIN_data                  ),
                                        .WD_out         ( WD[i*COL_NUM+:COL_NUM]     ),
                                        .outlier_sum    ( outlier_sum[i*32*8+:32*8]  ),
                                        .dout_valid     (                            )
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
                            .fp_en                      ( fp_en                          ),
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
                            .adder_enb                  ( adder_enb_d3	                 ),
                            .buffer_row_addr            ( buffer_row_addr_d4             ),
                            .outlier_sum                ( outlier_sum[j*32*8+:32*8]      ),
							.NNIN_E_max                 ( E_max                          ),
							.W_E_most                    ( E_most[j*64+:64]              ),
                            .Q                          (                                ),
                            .data_out                   ( data_out[j*256+:256]           ),
                            .Macro_dout_valid           ( Macro_out_valid_w[j]           )
                        );
        end
    endgenerate
endmodule
