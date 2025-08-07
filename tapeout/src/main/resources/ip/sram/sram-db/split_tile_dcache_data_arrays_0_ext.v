//==================================================================//
`define vcs
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef chip

module split_tile_dcache_data_arrays_0_ext(
  input  [6:0] RW0_addr,
  input        RW0_clk,
  input  [7:0] RW0_wdata,
  output [7:0] RW0_rdata,
  input        RW0_en,
  input        RW0_wmode,
  input        RW0_wmask
);

  wire RW0_en_masked =  RW0_wmode ? RW0_wmask&RW0_en : RW0_en;


  // SRAM编译器生成的模块实例化
  smic281prf128x8m4 sram_inst_128x8 (
    .CLK(RW0_clk),
    .CEN(~RW0_en_masked),           // CEN是低有效的使能信号
    .WEN(~(RW0_wmode)),  // WEN是低有效的写使能信号A
    .A(RW0_en?RW0_addr:7'b0),
    .D(RW0_wdata),
    .Q(RW0_rdata),
    .BWEN({8'h0}),         // 使用RW0_wmask控制写使能
    .SD(1'b0),                      // 关断模式，正常操作时为0
    .SLP(1'b0),                     // 休眠模式，正常操作时为0
    .PUDLY_SD(),                    // 关断延迟输出（未连接）
    .PUDLY_SLP(),                   // 休眠延迟输出（未连接）
    .RT(2'b00),                     // 读时序控制
    .WT(2'b00),                     // 写时序控制
    .TM(1'b0)                       // 测试模式
  );
// `ifdef RANDOMIZE_MEM_INIT
//   reg [31:0] _RAND_0;
// `endif // RANDOMIZE_MEM_INIT
// `ifdef RANDOMIZE_REG_INIT
//   reg [31:0] _RAND_1;
//   reg [31:0] _RAND_2;
// `endif // RANDOMIZE_REG_INIT
//   reg [7:0] ram [0:127];
//   wire  ram_RW_0_r_en;
//   wire [6:0] ram_RW_0_r_addr;
//   wire [7:0] ram_RW_0_r_data;
//   wire [7:0] ram_RW_0_w_data;
//   wire [6:0] ram_RW_0_w_addr;
//   wire  ram_RW_0_w_mask;
//   wire  ram_RW_0_w_en;
//   reg  ram_RW_0_r_en_pipe_0;
//   reg [6:0] ram_RW_0_r_addr_pipe_0;
//   assign ram_RW_0_r_en = ram_RW_0_r_en_pipe_0;
//   assign ram_RW_0_r_addr = ram_RW_0_r_addr_pipe_0;
//   assign ram_RW_0_r_data = ram[ram_RW_0_r_addr];
//   assign ram_RW_0_w_data = RW0_wdata;
//   assign ram_RW_0_w_addr = RW0_addr;
//   assign ram_RW_0_w_mask = RW0_wmask;
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
//   for (initvar = 0; initvar < 128; initvar = initvar+1)
//     ram[initvar] = _RAND_0[7:0];
// `endif // RANDOMIZE_MEM_INIT
// `ifdef RANDOMIZE_REG_INIT
//   _RAND_1 = {1{`RANDOM}};
//   ram_RW_0_r_en_pipe_0 = _RAND_1[0:0];
//   _RAND_2 = {1{`RANDOM}};
//   ram_RW_0_r_addr_pipe_0 = _RAND_2[6:0];
// `endif // RANDOMIZE_REG_INIT
//   `endif // RANDOMIZE
// end // initial
// `ifdef FIRRTL_AFTER_INITIAL
// `FIRRTL_AFTER_INITIAL
// `endif
// `endif // SYNTHESIS
endmodule
`endif
