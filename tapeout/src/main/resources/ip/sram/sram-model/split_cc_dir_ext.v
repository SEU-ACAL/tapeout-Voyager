//==================================================================//
`define chip
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef vcs

module split_cc_dir_ext(
  input  [5:0]  RW0_addr,
  input         RW0_clk,
  input  [26:0] RW0_wdata,
  output [26:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode,
  input         RW0_wmask
);
    wire RW0_en_masked =  RW0_wmode ? RW0_wmask&RW0_en : RW0_en;

    smic281prf64x27m4 sram_inst (
        .CLK(RW0_clk),
        .CEN(~RW0_en_masked),
        .WEN(~RW0_wmode),
        .A(RW0_addr),
        .D(RW0_wdata),
        .Q(RW0_rdata),
        .BWEN(27'h0),
        .SD(1'b0),
        .SLP(1'b0),
        .PUDLY_SD(),
        .PUDLY_SLP(),
        .RT(2'b00),
        .WT(2'b00),
        .TM(1'b0)
    );

endmodule
`endif
