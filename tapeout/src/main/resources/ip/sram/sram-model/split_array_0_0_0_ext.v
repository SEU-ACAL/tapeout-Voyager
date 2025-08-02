//==================================================================//
`define vcs
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef vcs

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
// `ifdef RANDOMIZE_MEM_INIT
//   reg [63:0] _RAND_0;
// `endif // RANDOMIZE_MEM_INIT
// `ifdef RANDOMIZE_REG_INIT
//   reg [31:0] _RAND_1;
//   reg [31:0] _RAND_2;
// `endif // RANDOMIZE_REG_INIT
//   reg [63:0] ram [0:511];
//   wire  ram_R_0_en;
//   wire [8:0] ram_R_0_addr;
//   wire [63:0] ram_R_0_data;
//   wire [63:0] ram_W_0_data;
//   wire [8:0] ram_W_0_addr;
//   wire  ram_W_0_mask;
//   wire  ram_W_0_en;
//   reg  ram_R_0_en_pipe_0;
//   reg [8:0] ram_R_0_addr_pipe_0;
//   assign ram_R_0_en = ram_R_0_en_pipe_0;
//   assign ram_R_0_addr = ram_R_0_addr_pipe_0;
//   assign ram_R_0_data = ram[ram_R_0_addr];
//   assign ram_W_0_data = W0_data;
//   assign ram_W_0_addr = W0_addr;
//   assign ram_W_0_mask = 1'h1;
//   assign ram_W_0_en = W0_en;
//   assign R0_data = ram_R_0_data;
//   always @(posedge W0_clk) begin
//     if (ram_W_0_en & ram_W_0_mask) begin
//       ram[ram_W_0_addr] <= ram_W_0_data;
//     end
//   end
//   always @(posedge R0_clk) begin
//     ram_R_0_en_pipe_0 <= R0_en;
//     if (R0_en) begin
//       ram_R_0_addr_pipe_0 <= R0_addr;
//     end
//   end
// // Register and memory initialization
// `ifdef RANDOMIZE_GARBAGE_ASSIGN
// `define RANDOMIZE
// `endif
// `ifdef RANDOMIZE_INVALID_ASSIGN
// `define RANDOMIZE
// `endif
// `ifdef RANDOMIZE_REG_INIT
// `define RANDOMIZE
// `endif
// `ifdef RANDOMIZE_MEM_INIT
// `define RANDOMIZE
// `endif
// `ifndef RANDOM
// `define RANDOM $random
// `endif
// `ifdef RANDOMIZE_MEM_INIT
//   integer initvar;
// `endif
// `ifndef SYNTHESIS
// `ifdef FIRRTL_BEFORE_INITIAL
// `FIRRTL_BEFORE_INITIAL
// `endif
// initial begin
//   `ifdef RANDOMIZE
//     `ifdef INIT_RANDOM
//       `INIT_RANDOM
//     `endif
//     `ifndef VERILATOR
//       `ifdef RANDOMIZE_DELAY
//         #`RANDOMIZE_DELAY begin end
//       `else
//         #0.002 begin end
//       `endif
//     `endif
// `ifdef RANDOMIZE_MEM_INIT
//   _RAND_0 = {2{`RANDOM}};
//   for (initvar = 0; initvar < 512; initvar = initvar+1)
//     ram[initvar] = _RAND_0[63:0];
// `endif // RANDOMIZE_MEM_INIT
// `ifdef RANDOMIZE_REG_INIT
//   _RAND_1 = {1{`RANDOM}};
//   ram_R_0_en_pipe_0 = _RAND_1[0:0];
//   _RAND_2 = {1{`RANDOM}};
//   ram_R_0_addr_pipe_0 = _RAND_2[8:0];
// `endif // RANDOMIZE_REG_INIT
//   `endif // RANDOMIZE
// end // initial
// `ifdef FIRRTL_AFTER_INITIAL
// `FIRRTL_AFTER_INITIAL
// `endif
// `endif // SYNTHESIS
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
    .CENB(~W0_en),          // CENB是低有效的使能信号
    .WENB({64{1'b0}}),       // WENB是低有效的写使能信号
    .AB(W0_addr),
    .DB(W0_data),
    // Byte write enable signals (低有效)
    .GWENB(~W0_en),      // 全局字节写使能B

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
