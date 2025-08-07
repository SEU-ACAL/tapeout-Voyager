//==================================================================//
`define verilator
//======= would be auto replaced by voyager-code-gen.sh ============//

`timescale 1ns/1ps

`ifdef vcs
// `include "../gen-collateral/SPC28NHKCPD18RNP.v"
module CustomDigitalInIOCell(
    input pad,
    output i,
    input ie
);

    /* ie=0 oe=0,trans !!!
        ie=1 oe=1 ,recieve
    */
    PBCD2RNC_X u_PAD_IO (
        .PAD(pad),        // 连接到外部 pad
        .I(),        // 输出数据线
        .OEN(1'b1),           // 输出使能，高电平表示禁用输出（即输入模式）
        .REN(1'b0),
        .IE(ie),            // 输入使能
        .C(i)          // 从 PAD 读入的值
    );
    // PBCD2RNC_X (PAD,IE,OEN,REN,I,C);

endmodule
`endif // vcs


`ifdef chip
module CustomDigitalInIOCell(
    input pad,
    output i,
    input ie
);

    /* ie=0 oe=0,trans !!!
        ie=1 oe=1 ,recieve
    */
    PBCD2RNC_X u_PAD_IO (
        .PAD(pad),        // 连接到外部 pad
        .I(),        // 输出数据线
        .OEN(1'b1),           // 输出使能，高电平表示禁用输出（即输入模式）
        .REN(1'b0),
        .IE(ie),            // 输入使能
        .C(i)          // 从 PAD 读入的值
    );
    // PBCD2RNC_X (PAD,IE,OEN,REN,I,C);

endmodule
`endif // chip

`ifdef verilator
module CustomDigitalInIOCell(
    input pad,
    output i,
    input ie
);

    // assign pad = oe ? o : 1'bz;
    assign i = ie ? pad : 1'b0;

endmodule
`endif // verilator
