`timescale 1ns / 1ps

module NNIN_pre_align #(
        parameter Macro_ROW_NUM = 256
    )(
        input                               fp_en,
        input [Macro_ROW_NUM*8-1:0]         NNIN_E_all,
        input [Macro_ROW_NUM*8-1:0]         NNIN_M_all,

        output [Macro_ROW_NUM*8-1:0]        NNIN_data,
		output [7:0]                        E_max
    );

    reg [7:0]								NNIN_E;
    reg [7:0]								NNIN_M;

    // wire [7:0]                              E_max;

    reg [7:0]								delta_E;                // 8bit, 正数
    reg [8:0]								NNIN_M_sup1;            // 9bit, NNIN_M补1后的, 为了不损失精度用9bit
    reg [8:0]								NNIN_M_sup1_bu;         // 9bit, NNIN_M_bu1的补码

    reg [Macro_ROW_NUM*8-1:0]				NNIN_M_shifted;

    wire [Macro_ROW_NUM*8-1:0]         		NNIN_E_all_w;
    wire [Macro_ROW_NUM*8-1:0]         		NNIN_M_all_w;

    assign NNIN_E_all_w = fp_en? NNIN_E_all: 'b0;
    assign NNIN_M_all_w = fp_en? NNIN_M_all: 'b0;

    integer i;
    always @(*) begin
        for(i=0; i<Macro_ROW_NUM; i=i+1) begin
            NNIN_E = NNIN_E_all_w[i*8+:8];
            NNIN_M = NNIN_M_all_w[i*8+:8];

            delta_E = E_max - NNIN_E;
            NNIN_M_sup1 = {NNIN_M[7],1'b1,NNIN_M[6:0]};
            NNIN_M_sup1_bu = (!NNIN_M[7]) ? (NNIN_M_sup1) : ({1'b1,~NNIN_M_sup1[7:0]} + 9'b1);

            case(delta_E)
                8'd0:
                    NNIN_M_shifted[i*8+:8] = {NNIN_M[7],NNIN_M_sup1_bu[7:1]};
                8'd1:
                    NNIN_M_shifted[i*8+:8] = {{(8'd2){NNIN_M[7]}},NNIN_M_sup1_bu[7:2]};
                8'd2:
                    NNIN_M_shifted[i*8+:8] = {{(8'd3){NNIN_M[7]}},NNIN_M_sup1_bu[7:3]};
                8'd3:
                    NNIN_M_shifted[i*8+:8] = {{(8'd4){NNIN_M[7]}},NNIN_M_sup1_bu[7:4]};
                8'd4:
                    NNIN_M_shifted[i*8+:8] = {{(8'd5){NNIN_M[7]}},NNIN_M_sup1_bu[7:5]};
                8'd5:
                    NNIN_M_shifted[i*8+:8] = {{(8'd6){NNIN_M[7]}},NNIN_M_sup1_bu[7:6]};
                8'd6:
                    NNIN_M_shifted[i*8+:8] = {{(8'd7){NNIN_M[7]}},NNIN_M_sup1_bu[7]};
                default:
                    NNIN_M_shifted[i*8+:8] = 8'b0;
            endcase
        end
    end

    assign NNIN_data = fp_en ? NNIN_M_shifted : NNIN_M_all;

    DW_minmax #(
                  .width      (8              ),
                  .num_inputs (Macro_ROW_NUM  )
              ) u_DW_minmax (
                  .a          (NNIN_E_all     ),
                  .tc         (1'b0           ),         // E无符号
                  .min_max    (1'b1           ),         // 找max
                  .value      (E_max          ),
                  .index      (               )
              );

endmodule
