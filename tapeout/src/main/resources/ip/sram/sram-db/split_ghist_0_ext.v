//==================================================================//
`define verilator
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef chip


module split_ghist_0_ext(
  // Port A (Read)
  input  [4:0]   R0_addr,
  input          R0_clk,
  output [23:0] R0_data,
  input          R0_en,
  
  // Port B (Write)
  input  [4:0]   W0_addr,
  input          W0_clk,
  input  [23:0] W0_data,
  input          W0_en
);
  wire W0_en_masked = W0_en;
  wire [5:0] r_addr = {1'b0,R0_addr};
  wire [5:0] w_addr = {1'b0,W0_addr};
  wire [71:0] w_data = {48'b0,W0_data};
  wire[71:0] r_data;
  assign R0_data = r_data[23:0];
  // 双端口SRAM编译器生成的模块实例化
  arm28hkcpdpsram64x72m4 sram_inst_64x72 (
    // Port A signals
    .CLKA(R0_clk),
    .CENA(~R0_en),          // CENA是低有效的使能信号
    .AA(r_addr),
    .QA(r_data),
    .WENA({72{1'b1}}),
    .GWENA(1'b1),
    
    // Port B signals
    .CLKB(W0_clk),
    .CENB(~W0_en_masked),          // CENB是低有效的使能信号
    .WENB({72{1'b0}}),       // WENB是低有效的写使能信号
    .AB(w_addr),
    .DB(w_data),
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
    .TAA({6{1'b0}}),
    .TDA({72{1'b0}}),
    .TCENA(1'b1),
    .TWENA({72{1'b1}}),
    .CENYA(),
    .TGWENA(1'b0),
    .SIA(2'b0),
    .TAB({6{1'b0}}) ,
    .TDB({72{1'b0}}),
    .TCENB(1'b1),
    .TWENB({72{1'b1}}),
    .CENYB(),
    .TGWENB(1'b0),
    .SIB(2'b0),
    .RET1N(1'b1),
    .COLLDISN(1'b1)
  );

endmodule
`endif
