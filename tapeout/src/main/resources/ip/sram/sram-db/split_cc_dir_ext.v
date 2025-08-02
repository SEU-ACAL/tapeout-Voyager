//==================================================================//
`define verilator
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef chip
module split_cc_dir_ext(
  input  [5:0]  RW0_addr,
  input         RW0_clk,
  input  [23:0] RW0_wdata,
  output [23:0] RW0_rdata,
  input         RW0_en,
  input         RW0_wmode,
  input         RW0_wmask
);
    wire RW0_en_masked =  RW0_wmode ? RW0_wmask&RW0_en : RW0_en;
    wire [7:0] rdata [0:2]; // 更清晰的声明方式
    wire [7:0] wdata [0:2];
    
    // 确保位顺序一致
    assign wdata[0] = RW0_wdata[7:0];
    assign wdata[1] = RW0_wdata[15:8];
    assign wdata[2] = RW0_wdata[23:16];
    
    // 确保连接顺序与赋值顺序一致
    assign RW0_rdata = {rdata[2], rdata[1], rdata[0]};
    
    genvar i;
    // 例化3个SRAM模块
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_sram_inst
            smic281prf64x8m4 sram_inst (
                .CLK(RW0_clk),
                .CEN(~RW0_en_masked),
                .WEN(~RW0_wmode),
                .A(RW0_addr),
                .D(wdata[i]),
                .Q(rdata[i]),
                .BWEN(8'h0),
                .SD(1'b0),
                .SLP(1'b0),
                .PUDLY_SD(),
                .PUDLY_SLP(),
                .RT(2'b00),
                .WT(2'b00),
                .TM(1'b0)
            );
        end
    endgenerate
endmodule
`endif
