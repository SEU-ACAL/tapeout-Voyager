//==================================================================//
`define vcs
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef chip
module split_mem_ext(
  input  [6:0]   R0_addr,
  input          R0_clk,
  output [129:0] R0_data,
  input          R0_en,
  input  [6:0]   W0_addr,
  input          W0_clk,
  input  [129:0] W0_data,
  input          W0_en
);

  // 内部信号声明
  wire [64:0] R0_data_low, R0_data_high;
  wire [64:0] W0_data_low, W0_data_high;
  
  // 数据位宽分割
  assign W0_data_low  = W0_data[64:0];     // 低65位
  assign W0_data_high = W0_data[129:65];   // 高65位
  
  // 读数据拼接
  assign R0_data = {R0_data_high, R0_data_low};

  // 第一个 SRAM 实例 - 存储低65位数据 (bit [64:0])
  arm28hkcpdpsram128x65m4 sram_inst_low (
    // Port A signals (Read Only)
    .CLKA(R0_clk),
    .CENA(~R0_en),              // CENA是低有效的使能信号
    .AA(R0_addr),               // 读地址
    .QA(R0_data_low),           // 读数据输出 - 低65位
    .WENA({65{1'b1}}),          // 端口A写使能全部禁用（高电平禁用写）
    .GWENA(1'b1),               // 端口A全局写使能禁用
    
    // Port B signals (Write Only) 
    .CLKB(W0_clk),
    .CENB(~W0_en),              // CENB是低有效的使能信号
    .WENB({65{1'b0}}),          // 端口B写使能全部启用（低电平启用写）
    .AB(W0_addr),               // 写地址
    .DB(W0_data_low),           // 写数据输入 - 低65位
    .GWENB(1'b0),               // 端口B全局写使能启用（低电平启用）

    // 配置参数
    .EMAA(3'b011),
    .EMAB(3'b011), 
    .EMAWA(2'b01),
    .EMAWB(2'b01),
    .EMASA(1'b0),
    .EMASB(1'b0),

    // 测试和调试信号
    .SEA(1'b0),
    .TENA(1'b1),
    .SEB(1'b0), 
    .TENB(1'b1),
    .DFTRAMBYP(1'b0),
    .TAA({7{1'b0}}),
    .TDA({65{1'b0}}),
    .TCENA(1'b1),
    .TWENA({65{1'b1}}),
    .CENYA(),
    .TGWENA(1'b1),              // 端口A测试模式下也禁用写
    .SIA(2'b0),
    .TAB({7{1'b0}}),
    .TDB({65{1'b0}}),
    .TCENB(1'b1),
    .TWENB({65{1'b0}}),         // 端口B测试模式下启用写
    .CENYB(),
    .TGWENB(1'b0),              // 端口B测试模式下启用写
    .SIB(2'b0),
    .RET1N(1'b1),
    .COLLDISN(1'b1)
  );

  // 第二个 SRAM 实例 - 存储高65位数据 (bit [129:65])
  arm28hkcpdpsram128x65m4 sram_inst_high (
    // Port A signals (Read Only)
    .CLKA(R0_clk),
    .CENA(~R0_en),              // CENA是低有效的使能信号
    .AA(R0_addr),               // 读地址
    .QA(R0_data_high),          // 读数据输出 - 高65位
    .WENA({65{1'b1}}),          // 端口A写使能全部禁用（高电平禁用写）
    .GWENA(1'b1),               // 端口A全局写使能禁用
    
    // Port B signals (Write Only) 
    .CLKB(W0_clk),
    .CENB(~W0_en),              // CENB是低有效的使能信号
    .WENB({65{1'b0}}),          // 端口B写使能全部启用（低电平启用写）
    .AB(W0_addr),               // 写地址
    .DB(W0_data_high),          // 写数据输入 - 高65位
    .GWENB(1'b0),               // 端口B全局写使能启用（低电平启用）

    // 配置参数
    .EMAA(3'b011),
    .EMAB(3'b011), 
    .EMAWA(2'b01),
    .EMAWB(2'b01),
    .EMASA(1'b0),
    .EMASB(1'b0),

    // 测试和调试信号
    .SEA(1'b0),
    .TENA(1'b1),
    .SEB(1'b0), 
    .TENB(1'b1),
    .DFTRAMBYP(1'b0),
    .TAA({7{1'b0}}),
    .TDA({65{1'b0}}),
    .TCENA(1'b1),
    .TWENA({65{1'b1}}),
    .CENYA(),
    .TGWENA(1'b1),              // 端口A测试模式下也禁用写
    .SIA(2'b0),
    .TAB({7{1'b0}}),
    .TDB({65{1'b0}}),
    .TCENB(1'b1),
    .TWENB({65{1'b0}}),         // 端口B测试模式下启用写
    .CENYB(),
    .TGWENB(1'b0),              // 端口B测试模式下启用写
    .SIB(2'b0),
    .RET1N(1'b1),
    .COLLDISN(1'b1)
  );
endmodule
`endif
