`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/06/17 19:38:57
// Design Name:
// Module Name: psum_self_adder
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module psum_self_adder #(
        parameter PSUM_W = 21,      // Width of the Macro PSUM output
        parameter BUFFER_ROW = 16   // row bum of the output buffer
    )(
        input                   clk,
        input                   rstn,                    // Active low reset signal
        input                   adder_enb,               // Active low reset signal
        input                   din_valid,
        input [3:0]             buffer_row_addr,         // Address for the output buffer
        input [PSUM_W*8-1:0]    Macro_out,     // Input Macro output values

        output reg[255:0]          data_out,            // Output value
        output reg 				Macro_out_valid
    );

    reg                       din_valid_d0;
    reg [3:0]                 buffer_row_addr_reg;

    reg signed [PSUM_W-1:0]          Macro_out_reg [0:7];                   // Split Macro_out into 8 parts
    reg [31:0]                self_buffer [0:7][0:BUFFER_ROW-1];         // output buffer 8x16x32bit

    wire signed[PSUM_W-1:0]   adder_din_a [0:7];         //adder input Macro_out
    reg  signed[31:0]         adder_din_b [0:7];            //adder input buffer read out
    wire signed[31:0]         self_adder_out [0:7];         //adder output

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            buffer_row_addr_reg    <= 'b0;
            din_valid_d0           <= 'b0;
            Macro_out_valid			<= 'b0;
        end
        else begin
            buffer_row_addr_reg    <= buffer_row_addr; // Update buffer row address
            din_valid_d0           <= din_valid; // Shift register for din_valid
            Macro_out_valid		<= din_valid_d0; // Indicate that Macro_out is valid when din_valid is high
        end
    end

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_Macro_out_w    // Split Macro_out into 8 parts
            always @(posedge clk or negedge rstn) begin
                if(!rstn)
                    Macro_out_reg[i] <= 'b0;
                else if (din_valid)
                    Macro_out_reg[i] <= Macro_out[i*PSUM_W+:PSUM_W];
            end
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_adder_out
            //   assign adder_din_a[i] = adder_enb ? 'b0 : Macro_out_reg[i];
            assign adder_din_a[i] = Macro_out_reg[i];
            // assign adder_din_b[i] = (adder_enb | !din_valid_d0) ? adder_din_b[i] : self_buffer[i][buffer_row_addr_reg];
            always @(posedge clk or negedge rstn) begin
                if(!rstn)
                    adder_din_b[i] <= 'b0; // Initialize adder input buffer read out to zero
                else if (din_valid) begin
                    adder_din_b[i] <= adder_enb? 'b0: self_buffer[i][buffer_row_addr];
                end
            end
            assign self_adder_out[i] = adder_din_a[i] + adder_din_b[i];
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_data_out    // Split Macro_out into 8 parts
            // assign data_out[i*32+:32] = self_buffer[i][buffer_row_addr_reg];
            always @(posedge clk or negedge rstn) begin
                if (!rstn)
                    data_out[i*32+:32] <= 'b0; // Initialize output data to zero
                else if (din_valid_d0)
                    data_out[i*32+:32] <= self_buffer[i][buffer_row_addr_reg];
            end
        end
    endgenerate

    integer j,k;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            for ( j = 0; j < BUFFER_ROW; j = j + 1)
                for ( k = 0; k < 8; k = k + 1)
                    self_buffer[k][j] <= 'b0; // Initialize the output buffer to zero
        else
            if(din_valid_d0)
                for ( k = 0; k < 8; k = k + 1)
                    self_buffer[k][buffer_row_addr_reg] <= adder_enb ? { {(32-PSUM_W){Macro_out_reg[k][PSUM_W-1]}}, Macro_out_reg[k]}: self_adder_out[k];  //符号位扩展
    end


endmodule

