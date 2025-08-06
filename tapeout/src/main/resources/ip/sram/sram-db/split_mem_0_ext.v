//==================================================================//
`define chip
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef chip


module split_mem_0_ext (
  input  [8:0]   RW0_addr,
  input          RW0_clk,
  input  [7:0] RW0_wdata,
  output [7:0] RW0_rdata,
  input          RW0_en,
  input          RW0_wmode,
  input         RW0_wmask
);
   wire RW0_en_masked =  RW0_wmode ? RW0_wmask&RW0_en : RW0_en;

    logic [1:0] sram_select;    // 选择哪个SRAM (0-3)
    logic [7:0] sram_addr;      // SRAM内部地址
    
    assign sram_select = RW0_addr[8];  // 高2位选择SRAM
    assign sram_addr   = RW0_addr[7:0];  // 低8位作为内部地址

    // 每个SRAM的信号
    logic [1:0] sram_en;        // 每个SRAM的使能信号
    logic [7:0] sram_rdata [2]; // 每个SRAM的读数据

    // 使能信号解码：只有被选中的SRAM才使能
    genvar i;
    generate
        for (i = 0; i < 2; i++) begin : gen_sram_enable
            assign sram_en[i] = RW0_en_masked && (sram_select == i[1:0]);
        end
    endgenerate

    // 例化4个SRAM模块
    generate
        for (i = 0; i < 2; i++) begin : gen_sram_inst
            smic281prf256x8m4 sram_inst (
                .CLK(RW0_clk),
                .CEN(~sram_en[i]),           // CEN是低有效的使能信号
                .WEN(~RW0_wmode),            // WEN是低有效的写使能信号
                .A(sram_addr),               // 统一使用低8位地址
                .D(RW0_wdata),               // 写数据
                .Q(sram_rdata[i]),           // 读数据
                .BWEN(8'h0),                 // 字节写使能，低有效
                .SD(1'b0),                   // 关断模式，正常操作时为0
                .SLP(1'b0),                  // 休眠模式，正常操作时为0
                .PUDLY_SD(),                 // 关断延迟输出（未连接）
                .PUDLY_SLP(),                // 休眠延迟输出（未连接）
                .RT(2'b00),                  // 读时序控制
                .WT(2'b00),                  // 写时序控制
                .TM(1'b0)                    // 测试模式
            );
        end
    endgenerate

    // 读数据选择：根据地址选择对应SRAM的输出
    assign RW0_rdata = sram_rdata[sram_select];  

    // 可选：添加断言检查地址范围
    // synthesis translate_off
    // initial begin
    //     assert (RW0_addr < 256) else $error("Address out of range: %d", RW0_addr);
    // end
    // synthesis translate_on

endmodule
`endif
