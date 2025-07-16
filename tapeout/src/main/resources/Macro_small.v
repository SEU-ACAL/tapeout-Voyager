`timescale 1ns/1ps

module Macro_small #(
    parameter ROW_NUM = 32,
    parameter GROUP_ROW_NUM = 32,
    parameter ROW_GROUP_NUM = 1,
    parameter COL_NUM = 64,
    parameter COL_GROUP_NUM = 8,
    parameter WEIGHT_W = 8,
    parameter BUFFER_ROW = 16
)(
    input                          clk_cim,
    input                          clk_w,
    input                          rstn,
    input                          MEB,
    input                          WEB,
    input [$clog2(ROW_NUM):0]      WADR,
    input [$clog2(ROW_NUM):0]      CIMADR,
    input [ROW_NUM-1:0]            NNIN,
    input [COL_NUM-1:0]            WD,
    input                          REN,
    input [$clog2(COL_NUM)-1:0]    RA,
    input [5:0]                    DM,
    input                          BIST_MODE,
    input                          SCAN_MODE,
    input                          SE,
    input                          NNIN_SI,
    input                          PSUM_SI,

    input [1:0]                    din_valid,

    input                          adder_enb,
    input [3:0]                    buffer_row_addr,
    
    output [COL_NUM-1:0]           Q,
    output [255:0]                 data_out
);

    localparam PSUM_W = 4 + $clog2(ROW_NUM);

    wire [PSUM_W*2*COL_GROUP_NUM-1:0]   PSUM_4;
    // wire [COL_NUM-1:0]                  Q;

    CIML2P_64X64_DR_M2_A1  CIML2P_64X64_DR_M2_A1(
        .CLK_CIM        (clk_cim),
        .CLK_W          (clk_w), 
        .RSTN           (rstn),
        .MEB            (MEB),               
        .WEB            (WEB),               
        .WADR           (WADR),              
        .CIMADR         (CIMADR),            
        .NNIN           (NNIN),              
        .WD             (WD),                
        .REN            (REN),               
        .RA             (RA),                
        .DM             (DM),                 
        .BIST_MODE      (BIST_MODE),
        .SCAN_MODE      (SCAN_MODE),
        .SE             (SE),
        .NNIN_SI        (NNIN_SI),
        .PSUM_SI        (PSUM_SI),
        .NNIN_SO        (),
        .PSUM_SO        (),
        .PSUM           (PSUM_4),
        .Q              (Q)
    );

    wire [(PSUM_W+12)*COL_GROUP_NUM-1:0]  temp_psum;
    wire temp_psum_valid;

    psum_shift_adder #(
        .PSUM_4_W       (PSUM_W),
        .COL_GROUP_NUM  (COL_GROUP_NUM)
    ) shift_add(
        .clk            (clk_cim),
        .rstn           (rstn),
        .din_valid      (din_valid),     
        .PSUM_4         (PSUM_4),        
        .PSUM           (temp_psum),
        .dout_valid     (temp_psum_valid)
    );

    psum_self_adder #(
        .PSUM_W          (PSUM_W + 12),
        .BUFFER_ROW      (BUFFER_ROW)
    ) self_add(
        .clk             (clk_cim),
        .rstn            (rstn),
        .adder_enb       (adder_enb),
        .din_valid       (temp_psum_valid),
        .buffer_row_addr (buffer_row_addr),
        .Macro_out       (temp_psum),
        .data_out        (data_out)
    );

endmodule