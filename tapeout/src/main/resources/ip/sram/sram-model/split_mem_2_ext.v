//==================================================================//
`define chip
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef vcs

module split_mem_2_ext(

  input  [9:0]   RW0_addr,
  input          RW0_clk,
  input  [7:0] RW0_wdata,
  output [7:0] RW0_rdata,
  input          RW0_en,
  input          RW0_wmode,
  input         RW0_wmask
);
 wire RW0_en_masked = RW0_en;
        smic281prf1024x8m4 sram_inst (
                .CLK(RW0_clk),
                .CEN(~RW0_en_masked),           // CEN是低有效的使能信号
                .WEN(~RW0_wmode),            // WEN是低有效的写使能信号
                .A(RW0_addr),               // 统一使用低8位地址
                .D(RW0_wdata),               // 写数据
                .Q(RW0_rdata),           // 读数据
                .BWEN(8'h0),                 // 字节写使能，低有效
                .SD(1'b0),                   // 关断模式，正常操作时为0
                .SLP(1'b0),                  // 休眠模式，正常操作时为0
                .PUDLY_SD(),                 // 关断延迟输出（未连接）
                .PUDLY_SLP(),                // 休眠延迟输出（未连接）
                .RT(2'b00),                  // 读时序控制
                .WT(2'b00),                  // 写时序控制
                .TM(1'b0)                    // 测试模式
            );


endmodule
`endif
