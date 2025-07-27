//==================================================================//
`define verilator
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef chip
module split_array_0_0_0_ext(
  input  [8:0]  R0_addr,
  input         R0_clk,
  output [63:0] R0_data,
  input         R0_en,
  input  [8:0]  W0_addr,
  input         W0_clk,
  input  [63:0] W0_data,
  input         W0_en
);
 arm28hkcpdpsram512x64m4 sram_inst_512x64 (
    // Port A signals
    .CLKA(R0_clk),
    .CENA(~R0_en),          // CENA是低有效的使能信号
    .AA(R0_addr),
    .QA(R0_data),
    .WENA({64{1'b1}}),
    .GWENA(1'b1),
    
    // Port B signals
    .CLKB(W0_clk),
    .CENB(~W0_en_masked),          // CENB是低有效的使能信号
    .WENB({64{1'b0}}),       // WENB是低有效的写使能信号
    .AB(W0_addr),
    .DB(W0_data),
    // Byte write enable signals (低有效)
    .GWENB(~W0_en_masked),      // 全局字节写使能B

    .EMAA(3'b011),
    .EMAB(3'b011),
    .EMAWA(2'b01),
    .EMAWB(2'b01),
    .EMASA(1'b0),
    .EMASB(1'b0),

    .SEA(1'b0),
    .TENA(1'b1),
    .SEB(1'b0),
    .TENB(1'b1),
    .DFTRAMBYP(1'b0),
    .TAA({9{1'b0}}),
    .TDA({64{1'b0}}),
    .TCENA(1'b1),
    .TWENA({64{1'b1}}),
    .CENYA(),
    .TGWENA(1'b0),
    .SIA(2'b0),
    .TAB({9{1'b0}}) ,
    .TDB({64{1'b0}}),
    .TCENB(1'b1),
    .TWENB({64{1'b1}}),
    .CENYB(),
    .TGWENB(1'b0),
    .SIB(2'b0),
    .RET1N(1'b1),
    .COLLDISN(1'b1)
  );
endmodule
`endif
