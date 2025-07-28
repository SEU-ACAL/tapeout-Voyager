//==================================================================//
`define verilator
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef vcs

`include "arm28hkcpdpsram128x31m4.v"
module split_meta_0_ext(
  input  [6:0]  R0_addr,
  input         R0_clk,
  output [30:0] R0_data,
  input         R0_en,
  input  [6:0]  W0_addr,
  input         W0_clk,
  input  [30:0] W0_data,
  input         W0_en,
  input         W0_mask
);
   wire W0_en_masked =  W0_mask&W0_en;
   arm28hkcpdpsram128x31m4 sram_inst_128x31 (
    // Port A signals
    .CLKA(R0_clk),
    .CENA(~R0_en),          // CENA是低有效的使能信号
    .AA(R0_addr),
    .QA(R0_data),
    .WENA({31{1'b1}}),
    .GWENA(1'b1),
    
    // Port B signals
    .CLKB(W0_clk),
    .CENB(~W0_en_masked),          // CENB是低有效的使能信号
    .WENB({31{1'b0}}),       // WENB是低有效的写使能信号
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
    .TAA({7{1'b0}}),
    .TDA({31{1'b0}}),
    .TCENA(1'b1),
    .TWENA({31{1'b1}}),
    .CENYA(),
    .TGWENA(1'b0),
    .SIA(2'b0),
    .TAB({7{1'b0}}) ,
    .TDB({31{1'b0}}),
    .TCENB(1'b1),
    .TWENB({31{1'b1}}),
    .CENYB(),
    .TGWENB(1'b0),
    .SIB(2'b0),
    .RET1N(1'b1),
    .COLLDISN(1'b1)
  );

endmodule
`endif
