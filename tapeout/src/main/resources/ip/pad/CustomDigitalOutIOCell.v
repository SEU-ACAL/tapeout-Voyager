//==================================================================//
`define vcs
//======= would be auto replaced by voyager-code-gen.sh ============//

`timescale 1ns/1ps

`ifdef vcs
// `include "../gen-collateral/SPC28NHKCPD18RNP.v"
module CustomDigitalOutIOCell(
    output pad,
    input o,
    input oe
);

  PBCD2RNC_X u_PAD_IO (
      .PAD(pad),        // 连接到外部 pad
      .I(o),        // 输出数据线
      .OEN(!oe),           // 输出使能，高电平表示禁用输出（即输入模式）
      .REN(1'b0),
      .IE(1'b0),            // 输入使能
      .C()          // 从 PAD 读入的值
  );
endmodule
`endif // vcs

`ifdef chip
module CustomDigitalOutIOCell(
    output pad,
    input o,
    input oe
);

  PBCD2RNC_X u_PAD_IO (
      .PAD(pad),        // 连接到外部 pad
      .I(o),        // 输出数据线
      .OEN(!oe),           // 输出使能，高电平表示禁用输出（即输入模式）
      .REN(1'b0),
      .IE(1'b0),            // 输入使能
      .C()          // 从 PAD 读入的值
  );
endmodule
`endif // chip

`ifdef verilator
module CustomDigitalOutIOCell(
    output pad,
    input o,
    input oe
);
  assign pad = oe ? o : 1'bz;

endmodule
`endif // verilator
