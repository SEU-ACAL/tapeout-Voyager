`timescale 1ns/1ps
module CustomDigitalGPIOCell(
    inout pad,
    output i,
    input ie,
    input o,
    input oe
);

    assign pad = oe ? o : 1'bz;
    assign i = ie ? pad : 1'b0;

    /* ie=0 oe=0,trans !!!
        ie=1 oe=1 ,recieve
    */
    // PBCD2RNC_X u_PAD_IO (
    //     .PAD(pad),        // ????? pad
    //     .I(o),        // ?????
    //     .OEN(!oe),           // ?????????????????????
    //     .REN(1'b0),
    //     .IE(!ie),            // ????
    //     .C(i)          // ? PAD ????
   // );
    // PBCD2RNC_X (PAD,IE,OEN,REN,I,C);
endmodule