`timescale 1ns/1ps
module CustomDigitalOutIOCell(
    output pad,
    input o,
    input oe
);

  assign pad = oe ? o : 1'bz;
  // PBCSUD16_WDDNW_3V_X u_PAD_DOUT ( .PAD(pad), .I(o), .OEN(1'b0), .PU(1'b0), .PD(1'b0), .IE(1'b0), .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C() );
    // PBCD2RNC_X u_PAD_IO (
    //     .PAD(pad),        // 连接到外部 pad
    //     .I(o),        // 输出数据线
    //     .OEN(!oe),           // 输出使能，高电平表示禁用输出（即输入模式）
    //     .REN(1'b0),
    //     .IE(1'b0),            // 输入使能
    //     .C()          // 从 PAD 读入的值
    // );
endmodule