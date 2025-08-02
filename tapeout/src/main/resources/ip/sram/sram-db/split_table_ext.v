//==================================================================//
`define verilator
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef chip
module split_table_ext(
  // Port A (Read)
  input  [7:0]   R0_addr,
  input          R0_clk,
  output [10:0]  R0_data,
  input          R0_en,
  
  // Port B (Write)
  input  [7:0]   W0_addr,
  input          W0_clk,
  input  [10:0]  W0_data,
  input          W0_en,
  
  // Mask signals
  input          W0_mask
);
  wire W0_en_masked = W0_mask & W0_en;

  // Address decoding - using bit 7 to select between two SRAMs
  wire w_select = W0_addr[7];      // Bit 7 selects which SRAM (0 or 1)
  wire [6:0] w_addr = W0_addr[6:0]; // Bits 6:0 as internal address
  wire r_select = R0_addr[7];      // Bit 7 selects which SRAM (0 or 1)
  wire [6:0] r_addr = R0_addr[6:0]; // Bits 6:0 as internal address
  
  // Enable signals for each SRAM
  wire w_en_0 = W0_en_masked && (w_select == 1'b0);
  wire w_en_1 = W0_en_masked && (w_select == 1'b1);
  wire r_en_0 = R0_en && (r_select == 1'b0);
  wire r_en_1 = R0_en && (r_select == 1'b1);
  
  // Output data from each SRAM
  wire [10:0] R0_data_0, R0_data_1;
  
  // Mux to select which SRAM output to use
  reg r_select_reg;
  always @(posedge R0_clk) begin
    if (R0_en) r_select_reg <= r_select;
  end
  
  assign R0_data = r_select_reg ? R0_data_1 : R0_data_0;
  
  // Instantiate the two SRAMs
  arm28hkcpdpsram128x11m4 sram_inst_0 (
    // Port A signals (Read)
    .CLKA(R0_clk),
    .CENA(~r_en_0),          // CENA is active low
    .AA(r_addr),
    .QA(R0_data_0),
    .WENA({11{1'b1}}),       // Disable writes on port A
    .GWENA(1'b1),            // Disable writes on port A
    
    // Port B signals (Write)
    .CLKB(W0_clk),
    .CENB(~w_en_0),          // CENB is active low
    .WENB({11{1'b0}}),       // WENB is active low (enable all bit writes)
    .AB(w_addr),
    .DB(W0_data),
    .GWENB(~w_en_0),         // Global write enable B (active low)
    
    // Power saving and test mode settings
    .EMAA(3'b011),
    .EMAB(3'b011),
    .EMAWA(2'b01),
    .EMAWB(2'b01),
    .EMASA(1'b0),
    .EMASB(1'b0),
    
    // Test mode signals
    .SEA(1'b0),
    .TENA(1'b1),
    .SEB(1'b0),
    .TENB(1'b1),
    .DFTRAMBYP(1'b0),
    .TAA({7{1'b0}}),
    .TDA({11{1'b0}}),
    .TCENA(1'b1),
    .TWENA({11{1'b1}}),
    .CENYA(),
    .TGWENA(1'b0),
    .SIA(2'b0),
    .TAB({7{1'b0}}),
    .TDB({11{1'b0}}),
    .TCENB(1'b1),
    .TWENB({11{1'b1}}),
    .CENYB(),
    .TGWENB(1'b0),
    .SIB(2'b0),
    .RET1N(1'b1),
    .COLLDISN(1'b1)
  );
  
  arm28hkcpdpsram128x11m4 sram_inst_1 (
    // Port A signals (Read)
    .CLKA(R0_clk),
    .CENA(~r_en_1),          // CENA is active low
    .AA(r_addr),
    .QA(R0_data_1),
    .WENA({11{1'b1}}),       // Disable writes on port A
    .GWENA(1'b1),            // Disable writes on port A
    
    // Port B signals (Write)
    .CLKB(W0_clk),
    .CENB(~w_en_1),          // CENB is active low
    .WENB({11{1'b0}}),       // WENB is active low (enable all bit writes)
    .AB(w_addr),
    .DB(W0_data),
    .GWENB(~w_en_1),         // Global write enable B (active low)
    
    // Power saving and test mode settings
    .EMAA(3'b011),
    .EMAB(3'b011),
    .EMAWA(2'b01),
    .EMAWB(2'b01),
    .EMASA(1'b0),
    .EMASB(1'b0),
    
    // Test mode signals
    .SEA(1'b0),
    .TENA(1'b1),
    .SEB(1'b0),
    .TENB(1'b1),
    .DFTRAMBYP(1'b0),
    .TAA({7{1'b0}}),
    .TDA({11{1'b0}}),
    .TCENA(1'b1),
    .TWENA({11{1'b1}}),
    .CENYA(),
    .TGWENA(1'b0),
    .SIA(2'b0),
    .TAB({7{1'b0}}),
    .TDB({11{1'b0}}),
    .TCENB(1'b1),
    .TWENB({11{1'b1}}),
    .CENYB(),
    .TGWENB(1'b0),
    .SIB(2'b0),
    .RET1N(1'b1),
    .COLLDISN(1'b1)
  );

endmodule
`endif
