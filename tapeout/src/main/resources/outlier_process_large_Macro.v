module outlier_process_large_Macro #(
        parameter ROW_NUM_Macro  = 256,
        parameter ROW_NUM_2      = 32,
        parameter ROW_NUM_4      = 16,
        parameter BUFFER_2       = 2,     //bit
        parameter BUFFER_4       = 4
    )(
        input                                                clk_cim,
        input                                                clk_w,
        input                                                rstn,
        input                                                buffer0_rst,
        input                                                buffer1_rst,
        input                                                fp_en,
        input                                                WEB,
        input [7:0]											 din2_valid,
        input [7:0]											 din4_valid,
        input                                                W_sel,
        input [$clog2(ROW_NUM_2)*8-1:0]                      WADR_2bit,     //cnt
        input [$clog2(ROW_NUM_4)*8-1:0]                      WADR_4bit,     //cnt
        input [BUFFER_2*8-1:0]                               outlier_2bit,         //single bit, 2 bits per channel
        input [BUFFER_4*8-1:0]                               outlier_4bit,         //single bit, 4 bits per channel
        input [$clog2(ROW_NUM_Macro)-1:0]                    outlier_index_2bit,  //shared address
        input [$clog2(ROW_NUM_Macro)-1:0]                    outlier_index_4bit,  //shared address

        input compute_valid,
        input MEB,
        input CIMADR_MSB,
        input [8*ROW_NUM_Macro-1:0] full_NNIN,

        output [32*8-1:0] outlier_sum,
        output dout_valid

    );

    reg [$clog2(ROW_NUM_Macro)-1:0]           outlier_index;
    always @(*) begin
        if(din2_valid)
            outlier_index		= outlier_index_2bit;
        else if(din4_valid)
            outlier_index		= outlier_index_4bit;
        else
            outlier_index		= 'b0;
    end

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_outlier_process_large_channel
            outlier_process_large_channel #(
                                              .ROW_NUM_Macro                     ( ROW_NUM_Macro ),
                                              .ROW_NUM_2                         ( ROW_NUM_2     ),
                                              .ROW_NUM_4                         ( ROW_NUM_4     ),
                                              .BUFFER_2                          ( BUFFER_2      ),
                                              .BUFFER_4                          ( BUFFER_4      )
                                          )u_outlier_process_large_channel(
                                              .clk_cim                           ( clk_cim                                               ),
                                              .clk_w                             ( clk_w                                                 ),
                                              .rstn                              ( rstn                                                  ),
                                              .buffer0_rst                       ( buffer0_rst                                           ),
                                              .buffer1_rst                       ( buffer1_rst                                           ),
                                              .fp_en                             ( fp_en                                                 ),
                                              .WEB                               ( WEB                                                   ),
                                              .din2_valid                        ( din2_valid[i]                                         ),
                                              .din4_valid                        ( din4_valid[i]                                         ),
                                              .W_sel                             ( W_sel                                                 ),
                                              .WADR_2bit                         ( WADR_2bit[i*$clog2(ROW_NUM_2) +: $clog2(ROW_NUM_2)]   ),
                                              .WADR_4bit                         ( WADR_4bit[i*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)]   ),
                                              .outlier_2bit                      ( outlier_2bit[i*BUFFER_2 +: BUFFER_2]                  ),
                                              .outlier_4bit                      ( outlier_4bit[i*BUFFER_4 +: BUFFER_4]                  ),
                                              .outlier_index                     ( outlier_index                                         ),
                                              .compute_valid                     ( compute_valid                                         ),
                                              .MEB                               ( MEB                                                   ),
                                              .CIMADR_MSB                        ( CIMADR_MSB                                            ),
                                              .full_NNIN                         ( full_NNIN                                             ),
                                              .outlier_sum                       ( outlier_sum[i*32 +: 32]                               ),
                                              .dout_valid_sum                    ( dout_valid                                            )
                                          );

        end
    endgenerate

endmodule
