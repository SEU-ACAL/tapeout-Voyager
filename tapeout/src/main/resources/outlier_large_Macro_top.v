`timescale 1ns/1ps
module outlier_large_Macro_top #(
        parameter ROW_NUM_Macro = 256,
        parameter ROW_NUM_2 = 32,
        parameter ROW_NUM_4 = 16
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
        input                            compute_valid,
        input [8*ROW_NUM_Macro-1:0]      full_NNIN,

        output [63:0]                    WD_out,
        output [32*8-1:0]                outlier_sum,
        output                           dout_valid
		// output							 W_sel
    );

    // wire W_sel;
    // assign W_sel = WADR[$clog2(ROW_NUM_Macro)];

    wire [7:0]  outlier_valid_2bit;                         //data valid flag
    wire [7:0]  outlier_valid_4bit;
    wire [15:0] outlier_value_2bit;                         //outlier data
    wire [31:0] outlier_value_4bit;
    wire [$clog2(ROW_NUM_Macro)-1:0] outlier_index_2bit;    //NNIN index
    wire [$clog2(ROW_NUM_Macro)-1:0] outlier_index_4bit;

    WD_shifter_macro #(
                         .ROW_NUM                (ROW_NUM_Macro),
                         .COL_GROUP_NUM          (8            ),
                         .WD_E_W                 (8            ),
                         .WD_M_W                 (8            )
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

    reg [8*(1+$clog2(ROW_NUM_2))-1:0] WADR_2bit; //write 2bit buffer address
    reg [8*$clog2(ROW_NUM_4)-1:0] WADR_4bit; //write 4bit buffer address

    genvar k;
    generate
        for(k = 0; k < 8; k = k + 1) begin
            always @(posedge clk_w or negedge rstn) begin
                if(!rstn) begin
                    WADR_2bit[k*(1+$clog2(ROW_NUM_2)) +: (1+$clog2(ROW_NUM_2))] <= 'd0;
                end
                else begin
                    if(outlier_valid_2bit[k]) begin
                        WADR_2bit[k*(1+$clog2(ROW_NUM_2)) +: (1+$clog2(ROW_NUM_2))] <= WADR_2bit[k*(1+$clog2(ROW_NUM_2)) +: (1+$clog2(ROW_NUM_2))] + 1'b1;
                    end
                end
            end
        end
    endgenerate

    generate
        for(k = 0; k < 8; k = k + 1) begin
            always @(posedge clk_w or negedge rstn) begin
                if(!rstn) begin
                    WADR_4bit[k*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)] <= 'd0;
                end
                else if(WADR_2bit[k*(1+$clog2(ROW_NUM_2)) +: (1+$clog2(ROW_NUM_2))] <= (ROW_NUM_2 - 1)) begin
                    if(outlier_valid_4bit[k]) begin
                        WADR_4bit[k*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)] <= WADR_4bit[k*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)] + 1'b1;
                    end
                end
                else begin
                    if(outlier_valid_2bit[k]) begin
                        WADR_4bit[k*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)] <= WADR_4bit[k*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)] + 1'b1;
                    end
                    if(outlier_valid_4bit[k]) begin
                        WADR_4bit[k*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)] <= WADR_4bit[k*$clog2(ROW_NUM_4) +: $clog2(ROW_NUM_4)] + 1'b1;
                    end
                end
            end
        end
    endgenerate

    wire [7:0]  valid_2bit;                         //data valid flag
    wire [7:0]  valid_4bit;
    wire [15:0] value_2bit;
    wire [31:0] value_4bit;
    wire [$clog2(ROW_NUM_Macro)-1:0] index_2bit;  //NNIN index
    wire [$clog2(ROW_NUM_Macro)-1:0] index_4bit;

    genvar i;
    generate
        for(i = 0; i < 8; i = i + 1) begin
            assign valid_2bit[i] = (WADR_2bit[i*(1+$clog2(ROW_NUM_2)) +: (1+$clog2(ROW_NUM_2))] <= (ROW_NUM_2 - 1)) ? outlier_valid_2bit[i] : 1'b0;
            assign valid_4bit[i] = (WADR_2bit[i*(1+$clog2(ROW_NUM_2)) +: (1+$clog2(ROW_NUM_2))] <= (ROW_NUM_2 - 1)) ?
                   outlier_valid_4bit[i] : (outlier_valid_2bit[i] | outlier_valid_4bit[i]);
            assign value_4bit[i*4 +: 4] =  (WADR_2bit[i*(1+$clog2(ROW_NUM_2)) +: (1+$clog2(ROW_NUM_2))] <= (ROW_NUM_2 - 1)) ? outlier_value_4bit[i*4 +: 4] :
                   outlier_valid_2bit[i] ? {{2{outlier_value_2bit[2*i+1]}} , outlier_value_2bit[i*2 +: 2]}: outlier_value_4bit[i*4 +: 4];
        end
    endgenerate
    assign index_2bit = outlier_index_2bit;
    assign index_4bit = outlier_index_2bit | outlier_index_4bit;
    assign value_2bit = outlier_valid_2bit;


    outlier_process_large_Macro #(
                                    .ROW_NUM_Macro          (ROW_NUM_Macro),
                                    .ROW_NUM_2              (ROW_NUM_2),
                                    .ROW_NUM_4              (ROW_NUM_4),
                                    .BUFFER_2               (2),
                                    .BUFFER_4               (4)
                                ) u_outlier_process_large_Macro (
                                    .clk_cim                (clk_cim),
                                    .clk_w                  (clk_w),
                                    .rstn                   (rstn),
                                    .buffer0_rst            (buffer0_rst),
                                    .buffer1_rst            (buffer1_rst),
                                    .fp_en                  (fp_en),
                                    .WEB                    (WEB),
                                    .din2_valid             (valid_2bit),
                                    .din4_valid             (valid_4bit),
                                    .W_sel                  (WADR[$clog2(ROW_NUM_Macro)]),
                                    .WADR_2bit              ({WADR_2bit[46:42],WADR_2bit[40:36],WADR_2bit[34:30],WADR_2bit[28:24],
                                                              WADR_2bit[22:18],WADR_2bit[16:12],WADR_2bit[10:6],WADR_2bit[4:0]}),
                                    .WADR_4bit              (WADR_4bit),
                                    .outlier_2bit           (value_2bit),
                                    .outlier_4bit           (value_4bit),
                                    .outlier_index_2bit     (index_2bit),
                                    .outlier_index_4bit     (index_4bit),
                                    .compute_valid          (compute_valid),
                                    .MEB                    (MEB),
                                    .CIMADR_MSB             (CIMADR_MSB),
                                    .full_NNIN              (full_NNIN),
                                    .outlier_sum            (outlier_sum),
                                    .dout_valid             (dout_valid)
                                );


endmodule
