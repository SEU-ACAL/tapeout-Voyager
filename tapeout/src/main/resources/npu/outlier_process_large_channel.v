module outlier_process_large_channel #(
        parameter ROW_NUM_Macro  = 256,
        parameter ROW_NUM_2      = 32,
        parameter ROW_NUM_4      = 16,
        parameter BUFFER_2       = 2,     //bit
        parameter BUFFER_4       = 4
    )(

        input                               clk_cim,
        input                               clk_w,
        input                               rstn,
        input                               buffer0_rst,
        input                               buffer1_rst,
        input                               fp_en,   // 1 enable, 0 disable

        input                               WEB,
        input                               din2_valid,
        input                               din4_valid,
        input                               W_sel,
        input [$clog2(ROW_NUM_2)-1:0]       WADR_2bit,  //6bit*8
        input [$clog2(ROW_NUM_4)-1:0]       WADR_4bit, //4bit*8
        input [BUFFER_2-1:0]                outlier_2bit,
        input [BUFFER_4-1:0]                outlier_4bit,
        input [$clog2(ROW_NUM_Macro)-1:0]   outlier_index,

        input                               compute_valid,
        input                               MEB,
        input                               CIMADR_MSB,
        input [8*ROW_NUM_Macro-1:0]         full_NNIN,

        output reg  signed [31:0]           outlier_sum,
        output reg                          dout_valid_sum
    );

    localparam GROUP_2 = ROW_NUM_2/8;  //64/8=8
    localparam GROUP_4 = ROW_NUM_4/8;  //16/8=2
    localparam MAC_WIDTH_2 = BUFFER_2 + 8 + $clog2(GROUP_2);  //2+8+3=13
    localparam MAC_WIDTH_4 = BUFFER_4 + 8 + $clog2(GROUP_4);  //4+8+2=12

    wire [7:0]                            NNIN[0:ROW_NUM_Macro-1];

    reg [BUFFER_2-1:0]                    value_buffer_2bit[0:1][0:ROW_NUM_2-1];
    reg [BUFFER_4-1:0]                    value_buffer_4bit[0:1][0:ROW_NUM_4-1];
    reg [$clog2(ROW_NUM_Macro)-1:0]       index_buffer_2bit[0:1][0:ROW_NUM_2-1];
    reg [$clog2(ROW_NUM_Macro)-1:0]       index_buffer_4bit[0:1][0:ROW_NUM_4-1];

    genvar a;
    generate
        for(a = 0; a < ROW_NUM_Macro; a = a + 1) begin:gen_NNIN
            assign NNIN[a] = full_NNIN[a*8 +: 8];
        end
    endgenerate


    //rstn logic
    integer i,j,k;
    always @(posedge clk_w or negedge rstn) begin
        if (!rstn) begin
            for(i = 0; i < 2; i = i + 1) begin
                for(j = 0; j < ROW_NUM_2; j = j + 1) begin
                    value_buffer_2bit[i][j] <= 'b0;
                    index_buffer_2bit[i][j] <= 'b0;
                end
                for(j = 0; j < ROW_NUM_4; j = j + 1) begin
                    value_buffer_4bit[i][j] <= 'b0;
                    index_buffer_4bit[i][j] <= 'b0;
                end
            end
        end

        else if(buffer0_rst || buffer1_rst) begin
            if (buffer0_rst == 1'b1) begin
                for(j = 0; j < ROW_NUM_2; j = j + 1) begin
                    value_buffer_2bit[0][j] <= 'b0;
                    index_buffer_2bit[0][j] <= 'b0;
                end
                for(j = 0; j < ROW_NUM_4; j = j + 1) begin
                    value_buffer_4bit[0][j] <= 'b0;
                    index_buffer_4bit[0][j] <= 'b0;
                end
            end
            if (buffer1_rst == 1'b1) begin
                for(j = 0; j < ROW_NUM_2; j = j + 1) begin
                    value_buffer_2bit[1][j] <= 'b0;
                    index_buffer_2bit[1][j] <= 'b0;
                end
                for(j = 0; j < ROW_NUM_4; j = j + 1) begin
                    value_buffer_4bit[1][j] <= 'b0;
                    index_buffer_4bit[1][j] <= 'b0;
                end
            end
        end

        else if(!WEB) begin
            if(din2_valid) begin
                value_buffer_2bit[W_sel][WADR_2bit] <= outlier_2bit;
                index_buffer_2bit[W_sel][WADR_2bit] <= outlier_index;
            end
            if(din4_valid) begin
                value_buffer_4bit[W_sel][WADR_4bit] <= outlier_4bit;
                index_buffer_4bit[W_sel][WADR_4bit] <= outlier_index;
            end
        end

    end


    //8cyc cnt define
    reg [2:0]                    cnt;
    reg                          dout_valid;
    always @(posedge clk_cim or negedge rstn) begin
        if(!rstn) begin
            cnt <= 3'b000;
            dout_valid <= 1'b0;
        end
        else if(MEB || !fp_en) begin
            cnt <= 3'b000;
            dout_valid <= 1'b0;
        end
        else if(cnt == 3'b111) begin
            cnt <= 3'b000;
            dout_valid <= 1'b1;
        end
        else if(cnt == 3'b0) begin
            if(compute_valid)
                cnt <= cnt + 1'b1;
            dout_valid <= 1'b0;
        end
        else begin
            cnt <= cnt + 1'b1;
            dout_valid <= 1'b0;
        end
    end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            dout_valid_sum <= 1'b0;
        else
            dout_valid_sum <= dout_valid; // maintain the previous value
    end

    //outlier mac (adder tree)
    localparam ATout_WIDTH_2 = MAC_WIDTH_2 + $clog2(GROUP_2);
    localparam ATout_WIDTH_4 = MAC_WIDTH_4 + $clog2(GROUP_4);

    wire signed [BUFFER_2-1:0]                            MAC_in_2bit[0:GROUP_2-1];
    wire signed [BUFFER_4-1:0]                            MAC_in_4bit[0:GROUP_4-1];
    wire [$clog2(ROW_NUM_Macro)-1:0]                      MAC_index_2bit[0:GROUP_2-1];
    wire [$clog2(ROW_NUM_Macro)-1:0]                      MAC_index_4bit[0:GROUP_4-1];
    wire signed [MAC_WIDTH_2-1:0]                         MAC_out_2bit[0:GROUP_2-1];
    wire signed [MAC_WIDTH_4-1:0]                         MAC_out_4bit[0:GROUP_4-1];

    wire signed [MAC_WIDTH_2*GROUP_2-1:0]                 Adder_tree_in_2bit;
    wire signed [MAC_WIDTH_4*GROUP_4-1:0]                 Adder_tree_in_4bit;
    wire signed [ATout_WIDTH_2-1:0]                       Adder_tree_out_2bit;
    wire signed [ATout_WIDTH_4-1:0]                       Adder_tree_out_4bit;
    generate
        for(a = 0; a < GROUP_2; a = a + 1) begin :gen_MAC_2bit
            assign MAC_in_2bit[a]    = (MEB || !fp_en) ? 'b0 : value_buffer_2bit[CIMADR_MSB][cnt*GROUP_2+a];
            assign MAC_index_2bit[a] = (MEB || !fp_en) ? 'b0 : index_buffer_2bit[CIMADR_MSB][cnt*GROUP_2+a];
            assign MAC_out_2bit[a]   = MAC_in_2bit[a] * $signed( NNIN[ MAC_index_2bit[a] ] );

            assign Adder_tree_in_2bit[MAC_WIDTH_2*a +: MAC_WIDTH_2] = MAC_out_2bit[a];
        end

        for(a = 0; a < GROUP_4; a = a + 1) begin :gen_MAC_4bit
            assign MAC_in_4bit[a]    = (MEB || !fp_en) ? 'b0 : value_buffer_4bit[CIMADR_MSB][cnt*GROUP_4+a];
            assign MAC_index_4bit[a] = (MEB || !fp_en) ? 'b0 : index_buffer_4bit[CIMADR_MSB][cnt*GROUP_4+a];
            assign MAC_out_4bit[a]   = MAC_in_4bit[a] * $signed( NNIN[ MAC_index_4bit[a] ] );

            assign Adder_tree_in_4bit[MAC_WIDTH_4*a +: MAC_WIDTH_4] = MAC_out_4bit[a];
        end
    endgenerate

    Adder_Tree#(
                  .DATA_WIDTH ( MAC_WIDTH_2              ),
                  .INPUT_NUM  ( GROUP_2                  ),
                  .STAGE_NUM  ( $clog2(GROUP_2)          )
              )u_Adder_Tree_2bit(
                  .in         ( Adder_tree_in_2bit       ),
                  .sum        ( Adder_tree_out_2bit      )
              );

    Adder_Tree#(
                  .DATA_WIDTH ( MAC_WIDTH_4              ),
                  .INPUT_NUM  ( GROUP_4                  ),
                  .STAGE_NUM  ( $clog2(GROUP_4)          )
              )u_Adder_Tree_4bit(
                  .in         ( Adder_tree_in_4bit       ),
                  .sum        ( Adder_tree_out_4bit      )
              );

    //seld_adder
    wire signed[31:0] sum_2bit;
    wire signed[31:0] sum_4bit;
    self_accumulator_firstload #(
                                   .DIN_WIDTH ( ATout_WIDTH_2              )
                               )u_self_accumulator_firstload_2bit(
                                   .clk   ( clk_cim                  ),
                                   .rstn  ( rstn                     ),
                                   .fp_en ( fp_en && !MEB && compute_valid            ),
                                   .cnt   ( cnt                      ),
                                   .din   ( Adder_tree_out_2bit      ),
                                   .sum   ( sum_2bit                 )
                               );

    self_accumulator_firstload #(
                                   .DIN_WIDTH ( ATout_WIDTH_4              )
                               )u_self_accumulator_firstload_4bit(
                                   .clk   ( clk_cim                  ),
                                   .rstn  ( rstn                     ),
                                   .fp_en ( fp_en && !MEB && compute_valid           ),
                                   .cnt   ( cnt                      ),
                                   .din   ( Adder_tree_out_4bit      ),
                                   .sum   ( sum_4bit                 )
                               );

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            outlier_sum <= 'b0;
        else if (!fp_en)
            outlier_sum <= 'b0;
        else if (dout_valid)
            outlier_sum <= sum_2bit + sum_4bit;
    end


endmodule




module self_accumulator_firstload #(
        parameter DIN_WIDTH = 32
    )(
        input              clk,     // 时钟信号
        input              rstn,    // 低有效复位
        input              fp_en,      // 使能，高电平有效
        input      [2:0]   cnt,
        input  signed [DIN_WIDTH-1:0]  din,     // 输入数据

        output reg signed [31:0]  sum      // 当前累计值
    );

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sum            <= 32'b0;
        end
        else if (fp_en) begin
            if (cnt == 'd0) begin
                sum          <= din;    // 第一次加载，不累加
            end
            else begin
                sum          <= $signed(sum) + $signed(din);      // 后续累加
            end
        end
    end

endmodule




module Adder_Tree #(
        parameter DATA_WIDTH = 10,
        parameter INPUT_NUM  = 8,
        parameter STAGE_NUM  = 3 // log2(INPUT_NUM)
    )(
        input  [DATA_WIDTH*INPUT_NUM-1:0] in,

        output [DATA_WIDTH+STAGE_NUM-1:0] sum
    );
    // 中间结果存储，每层一半数量，宽度逐层+1
    wire signed [DATA_WIDTH+STAGE_NUM-1:0] stage [0:STAGE_NUM][0:INPUT_NUM-1];

    // 第一层输入
    genvar i;
    generate
        for (i = 0; i < INPUT_NUM; i = i + 1) begin : input_assign
            assign stage[0][i] = $signed( in[i*DATA_WIDTH +: DATA_WIDTH] );
        end
    endgenerate

    // 后续每一层：i 层计算 j 个元素
    genvar s, j;
    generate
        for (s = 0; s < STAGE_NUM; s = s + 1) begin : stage_gen
            for (j = 0; j < INPUT_NUM >> (s+1); j = j + 1) begin : adder_gen
                assign stage[s+1][j] = stage[s][2*j] + stage[s][2*j+1];
            end
        end
    endgenerate

    // 最终输出为最后一层的第一个元素
    assign sum = stage[STAGE_NUM][0];

endmodule
