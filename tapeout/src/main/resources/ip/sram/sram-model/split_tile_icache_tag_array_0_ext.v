//==================================================================//
`define verilator
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef vcs

module split_tile_icache_tag_array_0_ext(
  input  [5:0]   RW0_addr,
  input          RW0_clk,
  input  [20:0] RW0_wdata,
  output [20:0] RW0_rdata,
  input          RW0_en,
  input          RW0_wmode,
  input   RW0_wmask
);
    wire RW0_en_masked = RW0_wmode?RW0_wmode&RW0_en:RW0_en;


  // SRAM编译器生成的模块实例化
  smic281prf64x21m4 sram_inst_64x21 (
    .CLK(RW0_clk),
    .CEN(~RW0_en_masked),           // CEN是低有效的使能信号
    .WEN(~RW0_wmode),        // WEN是低有效的写使能信号
    .A(RW0_addr),
    .D(RW0_wdata),
    .Q(RW0_rdata),
    .BWEN(21'h0),       // 字节写使能，低有效
    .SD(1'b0),               // 关断模式，正常操作时为0
    .SLP(1'b0),              // 休眠模式，正常操作时为0
    .PUDLY_SD(),             // 关断延迟输出（未连接）
    .PUDLY_SLP(),            // 休眠延迟输出（未连接）
    .RT(2'b00),              // 读时序控制
    .WT(2'b00),              // 写时序控制
    .TM(1'b0)                // 测试模式
  );
// `ifdef RANDOMIZE_MEM_INIT
//   reg [31:0] _RAND_0;
// `endif // RANDOMIZE_MEM_INIT
// `ifdef RANDOMIZE_REG_INIT
//   reg [31:0] _RAND_1;
//   reg [31:0] _RAND_2;
// `endif // RANDOMIZE_REG_INIT
//   reg [20:0] ram [0:63];
//   wire  ram_RW_0_r_en;
//   wire [5:0] ram_RW_0_r_addr;
//   wire [20:0] ram_RW_0_r_data;
//   wire [20:0] ram_RW_0_w_data;
//   wire [5:0] ram_RW_0_w_addr;
//   wire  ram_RW_0_w_mask;
//   wire  ram_RW_0_w_en;
//   reg  ram_RW_0_r_en_pipe_0;
//   reg [5:0] ram_RW_0_r_addr_pipe_0;
//   assign ram_RW_0_r_en = ram_RW_0_r_en_pipe_0;
//   assign ram_RW_0_r_addr = ram_RW_0_r_addr_pipe_0;
//   assign ram_RW_0_r_data = ram[ram_RW_0_r_addr];
//   assign ram_RW_0_w_data = RW0_wdata;
//   assign ram_RW_0_w_addr = RW0_addr;
//   assign ram_RW_0_w_mask = 1'h1;
//   assign ram_RW_0_w_en = RW0_en & RW0_wmode;
//   assign RW0_rdata = ram_RW_0_r_data;
//   always @(posedge RW0_clk) begin
//     if (ram_RW_0_w_en & ram_RW_0_w_mask) begin
//       ram[ram_RW_0_w_addr] <= ram_RW_0_w_data;
//     end
//     ram_RW_0_r_en_pipe_0 <= RW0_en & ~RW0_wmode;
//     if (RW0_en & ~RW0_wmode) begin
//       ram_RW_0_r_addr_pipe_0 <= RW0_addr;
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
//   _RAND_0 = {1{`RANDOM}};
//   for (initvar = 0; initvar < 64; initvar = initvar+1)
//     ram[initvar] = _RAND_0[20:0];
// `endif // RANDOMIZE_MEM_INIT
// `ifdef RANDOMIZE_REG_INIT
//   _RAND_1 = {1{`RANDOM}};
//   ram_RW_0_r_en_pipe_0 = _RAND_1[0:0];
//   _RAND_2 = {1{`RANDOM}};
//   ram_RW_0_r_addr_pipe_0 = _RAND_2[5:0];
// `endif // RANDOMIZE_REG_INIT
//   `endif // RANDOMIZE
// end // initial
// `ifdef FIRRTL_AFTER_INITIAL
// `FIRRTL_AFTER_INITIAL
// `endif
// `endif // SYNTHESIS
endmodule
`endif
