package voyager_tapeout.custom
import chisel3._
import chisel3.util._
import chipyard.iobinders._
import freechips.rocketchip.prci._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.tilelink._
import chipyard.iocell._
import chipyard.clocking._
import chisel3.experimental.Analog
// abstract class GenericIOCell  {
//   val impl: String
//   val moduleName = this.getClass.getSimpleName
//   setInline(s"$moduleName.v", impl);
// }

class CustomAnalogIOCell extends  BlackBox with HasBlackBoxResource with AnalogIOCell {
  val io = IO(new AnalogIOCellBundle)
  lazy val impl = s"""
`timescale 1ns/1ps
module GenericAnalogIOCell(
    inout pad,
    inout core
);

    assign core = 1'bz;
    assign pad = core;

endmodule"""
}

class CustomDigitalGPIOCell extends BlackBox with HasBlackBoxResource with DigitalGPIOCell {
  val io = IO(new DigitalGPIOCellBundle)
    addResource("ip/pad/CustomDigitalGPIOCell.v")
    addResource("ip/pad/SPC28NHKCPD18RNP.v")
}

// class CustomDigitalInIOCell extends BlackBox with HasBlackBoxResource with DigitalInIOCell {
//   val io = IO(new DigitalInIOCellBundle)
//   lazy val impl = s"""
// `timescale 1ns/1ps
// module GenericDigitalInIOCell(
//     input pad,
//     output i,
//     input ie
// );

//   assign i = ie ? pad : 1'b0;
//   // PBCSUD16_WDDNW_3V_X u_PAD_CLK_CIM ( .PAD(pad), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1), .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(i) );
// endmodule"""
// }

class CustomDigitalOutIOCell extends BlackBox with HasBlackBoxResource with DigitalOutIOCell {
  val io = IO(new DigitalOutIOCellBundle)
    addResource("ip/pad/CustomDigitalOutIOCell.v")
    addResource("ip/pad/SPC28NHKCPD18RNP.v")
}
class CustomDigitalInIOCell extends BlackBox with HasBlackBoxResource with DigitalInIOCell {
  val io = IO(new DigitalInIOCellBundle)
    addResource("ip/pad/CustomDigitalInIOCell.v")
    addResource("ip/pad/SPC28NHKCPD18RNP.v")
}