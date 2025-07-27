//********************************************************************************//
//**********            (C) Copyright 2018 SMIC Inc.                    **********//
//**********                SMIC Verilog Models                         **********//
//********************************************************************************//
//       FileName   : SPC28NHKCPD18RNP.v                                        //
//       Function   : Verilog Models (zero timing)                                //
//       Version    : V0p2                                                        //
//       Author     : Cherry_Chen                                                 //
//       CreateDate : Dec-22-2018                                                 //
//********************************************************************************//
////////////////////////////////////////////////////////////////////////////////////
//DISCLAIMER                                                                      //
//                                                                                //
//   SMIC hereby provides the quality information to you but makes no claims,     //
// promises or guarantees about the accuracy, completeness, or adequacy of the    //
// information herein. The information contained herein is provided on an "AS IS" //
// basis without any warranty, and SMIC assumes no obligation to provide support  //
// of any kind or otherwise maintain the information.                             //
//   SMIC disclaims any representation that the information does not infringe any //
// intellectual property rights or proprietary rights of any third parties.SMIC   //
// makes no other warranty, whether express, implied or statutory as to any       //
// matter whatsoever,including but not limited to the accuracy or sufficiency of  //
// any information or the merchantability and fitness for a particular purpose.   //
// Neither SMIC nor any of its representatives shall be liable for any cause of   //
// action incurpd to connect to this service.                                     //
//                                                                                //
// STATEMENT OF USE AND CONFIDENTIALITY                                           //
//                                                                                //
//   The following/attached material contains confidential and proprietary        //
// information of SMIC. This material is based upon information which SMIC        //
// considers reliable, but SMIC neither represents nor warrants that such         //
// information is accurate or complete, and it must not be relied upon as such.   //
// This information was prepapd for informational purposes and is for the use     //
// by SMIC's customer only. SMIC reserves the right to make changes in the        //
// information at any time without notice.                                        //
//   No part of this information may be reproduced, transmitted, transcribed,     //
// stopd in a retrieval system, or translated into any human or computer          //
// language, in any form or by any means, electronic, mechanical, magnetic,       //
// optical, chemical, manual, or otherwise, without the prior written consent of  //
// SMIC. Any unauthorized use or disclosure of this material is strictly          //
// prohibited and may be unlawful. By accepting this material, the receiving      //
// party shall be deemed to have acknowledged, accepted, and agreed to be bound   //
// by the foregoing limitations and restrictions. Thank you.                      //
////////////////////////////////////////////////////////////////////////////////////


// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pb4scud12rnc_x.v
// Description          : 3-state bi-direction I/O pads with controlled driving strength level(2/4/8/12mA),
//                        slew rate, Schmitt trigger and pull-down, pull-up resistor
//                        Place for chip x-orientation
//
//
`ifndef verilator
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PB4SCUD12RNC_X (PAD,OEN,PU,PD,I,IE,ST,DS0,DS1,C);

output  C;
input   OEN,PU,PD,I,ST,DS0,DS1,IE;
inout   PAD;

  supply1 my1;
  supply0 my0;
  bufif0  (PAD_buf, I, OEN);
  pmos    (PAD,PAD_buf,my0);
  bufif1     (C_buf,PAD,IE);
  pmos       (C_buf,my0,IE);
  pmos       (C,C_buf,my0);
  rnmos   #0.01 (PAD_buf,my1,PU);
  rnmos   #0.01 (PAD_buf,my0,PD);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 if(ST===1'b0) (PAD => C) = (0,0);
 if(ST===1'b1) (PAD => C) = (0,0);
 ifnone (PAD => C) = (0,0);

 if(DS0 === 1'b0 && DS1 === 1'b0) (I => PAD) = (0,0);
 if(DS0 === 1'b0 && DS1 === 1'b1) (I => PAD) = (0,0);
 if(DS0 === 1'b1 && DS1 === 1'b0) (I => PAD) = (0,0);
 if(DS0 === 1'b1 && DS1 === 1'b1) (I => PAD) = (0,0);

 ifnone (I => PAD) = (0,0);

 if(DS0 === 1'b0 && DS1 === 1'b0) (OEN => PAD) = (0,0,0,0,0,0);
 if(DS0 === 1'b0 && DS1 === 1'b1) (OEN => PAD) = (0,0,0,0,0,0);
 if(DS0 === 1'b1 && DS1 === 1'b0) (OEN => PAD) = (0,0,0,0,0,0);
 if(DS0 === 1'b1 && DS1 === 1'b1) (OEN => PAD) = (0,0,0,0,0,0);

 ifnone (OEN => PAD) = (0,0,0,0,0,0);

 if(ST===1'b0) (IE => C) = (0,0);
 if(ST===1'b1) (IE => C) = (0,0);
 ifnone (IE  => C) = (0,0);

endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2018 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pb4scud12rnc_y.v
// Description          : 3-state bi-direction I/O pads with controlled driving strength level(2/4/8/12mA),
//                        slew rate, Schmitt trigger and pull-down, pull-up resistor
//                        Place for chip y-orientation
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PB4SCUD12RNC_Y (PAD,OEN,PU,PD,I,IE,ST,DS0,DS1,C);

output  C;
input   OEN,PU,PD,I,ST,DS0,DS1,IE;
inout   PAD;

  supply1 my1;
  supply0 my0;
  bufif0  (PAD_buf, I, OEN);
  pmos    (PAD,PAD_buf,my0);
  bufif1     (C_buf,PAD,IE);
  pmos       (C_buf,my0,IE);
  pmos       (C,C_buf,my0);
  rnmos   #0.01 (PAD_buf,my1,PU);
  rnmos   #0.01 (PAD_buf,my0,PD);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 if(ST===1'b0) (PAD => C) = (0,0);
 if(ST===1'b1) (PAD => C) = (0,0);
 ifnone (PAD => C) = (0,0);

 if(DS0 === 1'b0 && DS1 === 1'b0) (I => PAD) = (0,0);
 if(DS0 === 1'b0 && DS1 === 1'b1) (I => PAD) = (0,0);
 if(DS0 === 1'b1 && DS1 === 1'b0) (I => PAD) = (0,0);
 if(DS0 === 1'b1 && DS1 === 1'b1) (I => PAD) = (0,0);

 ifnone (I => PAD) = (0,0);

 if(DS0 === 1'b0 && DS1 === 1'b0) (OEN => PAD) = (0,0,0,0,0,0);
 if(DS0 === 1'b0 && DS1 === 1'b1) (OEN => PAD) = (0,0,0,0,0,0);
 if(DS0 === 1'b1 && DS1 === 1'b0) (OEN => PAD) = (0,0,0,0,0,0);
 if(DS0 === 1'b1 && DS1 === 1'b1) (OEN => PAD) = (0,0,0,0,0,0);

 ifnone (OEN => PAD) = (0,0,0,0,0,0);

 if(ST===1'b0) (IE => C) = (0,0);
 if(ST===1'b1) (IE => C) = (0,0);
 ifnone (IE  => C) = (0,0);

endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd12rnc_x.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD12RNC_X (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end


`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd12rnc_y.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD12RNC_Y (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end


`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd16rnc_x.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD16RNC_X (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end


`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd16rnc_y.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD16RNC_Y (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end


`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd2rnc_x.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown 
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD2RNC_X (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults



// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd2rnc_y.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown 
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD2RNC_Y (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults



// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd4rnc_x.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD4RNC_X (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd4rnc_y.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD4RNC_Y (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd8rnc_x.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD8RNC_X (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end


`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd8rnc_y.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD8RNC_Y (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end


`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu12rnc_x.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU12RNC_X (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu12rnc_y.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU12RNC_Y (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu16rnc_x.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU16RNC_X (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 

 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu16rnc_y.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU16RNC_Y (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 

 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu2rnc_x.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup 
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU2RNC_X (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 

 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu2rnc_y.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup 
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU2RNC_Y (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 

 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu4rnc_x.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU4RNC_X (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 

 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu4rnc_y.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU4RNC_Y (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 

 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu8rnc_x.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU8RNC_X (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu8rnc_y.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU8RNC_Y (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs12rnc_x.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS12RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);
  
  always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs12rnc_y.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS12RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);
  
  always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs16rnc_x.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS16RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);
  
  always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs16rnc_y.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS16RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);
  
  always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs2rnc_x.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS2RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);
  
  always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs2rnc_y.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS2RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);
  
  always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs4rnc_x.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS4RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);
  
  always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs4rnc_y.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS4RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);
  
  always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs8rnc_x.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS8RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);
  
  always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs8rnc_y.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS8RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);
  
  always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
 
// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd12rnc_x.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD12RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd12rnc_y.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD12RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd16rnc_x.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD16RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd16rnc_y.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD16RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd2rnc_x.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD2RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults



// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd2rnc_y.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD2RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults



// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd4rnc_x.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD4RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd4rnc_y.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD4RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd8rnc_x.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD8RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd8rnc_y.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD8RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu12rnc_x.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU12RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu12rnc_y.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU12RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu16rnc_x.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU16RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu16rnc_y.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU16RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu2rnc_x.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU2RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu2rnc_y.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU2RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu4rnc_x.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU4RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu4rnc_y.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU4RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu8rnc_x.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//                        place for chip x-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU8RNC_X (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu8rnc_y.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//                        place for chip y-orientation
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU8RNC_Y (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify

 (OEN  => PAD) = (0,0,0,0,0,0);
 (IE  => C) = (0,0);
 (PAD   +=> C) = (0,0);
 (I   +=> PAD) = (0,0);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1canprnc_x.v
// Description          : Analog power PAD within digital power domain 
//                        (for core power/ground supplies, not to be connected with signal)
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1CANPRNC_X (SVDD1CANP);

   inout SVDD1CANP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1canprnc_y.v
// Description          : Analog power PAD within digital power domain 
//                        (for core power/ground supplies, not to be connected with signal)
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1CANPRNC_Y (SVDD1CANP);

   inout SVDD1CANP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1rnc_x.v
// Description          : VDD Power Pad for I/O Pre-driver & Core
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1RNC_X (VDD);

   inout VDD;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine




// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1rnc_y.v
// Description          : VDD Power Pad for I/O Pre-driver & Core
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1RNC_Y (VDD);

   inout VDD;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd2pudcrnc_x.v
// Description          : VDD Power Pad for I/O Post-driver; also generates FP and FPB signals
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD2PUDCRNC_X ();



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd2pudcrnc_y.v
// Description          : VDD Power Pad for I/O Post-driver; also generates FP and FPB signals
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD2PUDCRNC_Y ();



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd2rnc_x.v
// Description          : VDD Power Pad for I/O Post-driver
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD2RNC_X ();



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine



// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd2rnc_y.v
// Description          : VDD Power Pad for I/O Post-driver
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD2RNC_Y ();



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1canprnc_x.v
// Description          : Analog ground PAD within digital power domain 
//                        (for core power/ground supplies, not to be connected with signal)
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1CANPRNC_X (SVSS1CANP);

   inout SVSS1CANP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1canprnc_y.v
// Description          : Analog ground PAD within digital power domain 
//                        (for core power/ground supplies, not to be connected with signal)
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1CANPRNC_Y (SVSS1CANP);

   inout SVSS1CANP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1rnc_x.v
// Description          : VSS Ground Pad for I/O Pre-driver & Core
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1RNC_X (VSS);

   inout VSS;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1rnc_y.v
// Description          : VSS Ground Pad for I/O Pre-driver & Core
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1RNC_Y (VSS);

   inout VSS;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss2rnc_x.v
// Description          : VSS Ground Pad for I/O Post-driver
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS2RNC_X ();



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss2rnc_y.v
// Description          : VSS Ground Pad for I/O Post-driver
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS2RNC_Y ();



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss3rnc_x.v
// Description          : VSS Ground pad for all(I/O pre-driver, post-driver &core) 
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3RNC_X (VSS);

   inout VSS;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss3rnc_y.v
// Description          : VSS Ground pad for all(I/O pre-driver, post-driver &core) 
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3RNC_Y (VSS);

   inout VSS;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : clampcrnc_x.v
// Description          : ESD core clamp cell for core device
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module CLAMPCRNC_X (VDD_CP,VSS_CP);

   inout VDD_CP;
   inout VSS_CP;



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : clampcrnc_y.v
// Description          : ESD core clamp cell for core device
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module CLAMPCRNC_Y (VDD_CP,VSS_CP);

   inout VDD_CP;
   inout VSS_CP;



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : clampiornc.v
// Description          : ESD IO clamp cell for 1.8V device
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module CLAMPIORNC (VDDIO_CP,VSSIO_CP);

   inout VDDIO_CP;
   inout VSSIO_CP;



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : p1diode8rnc.v
// Description          : Power-Cut Cell for High Voltage Drop for difference voltage level between digital and analog, 
//                        but it only includes two single diodes of opposite polarity connected in parallel 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module P1DIODE8RNC (VSS1,VSS2);

inout VSS1;
inout VSS2;



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pana2aprnc_x.v
// Description          : Analog IO pad for high frequency application within analog domain(IO voltage)
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PANA2APRNC_X (PAD);
inout PAD;




`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pana2aprnc_y.v
// Description          : Analog IO pad for high frequency application within analog domain(IO voltage)
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PANA2APRNC_Y (PAD);
inout PAD;




`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pana2caprnc_x.v
// Description          : Analog IO pad for high frequency application within analog domain(core voltage)
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PANA2CAPRNC_X (PAD);
inout PAD;




`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pana2caprnc_y.v
// Description          : Analog IO pad for high frequency application within analog domain(core voltage) 
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PANA2CAPRNC_Y (PAD);
inout PAD;




`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pdiode8srnc.v
// Description          : Power-Cut Cell for High Voltage Drop for difference voltage level between digital and analog, but shorts ground 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PDIODE8SRNC ();



`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1aprnc_x.v
// Description          : Analog power PAD (Not for core voltage power/ground supplies which are connected to internal core voltage circuitry)
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1APRNC_X (SVDD1AP);

   inout SVDD1AP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1aprnc_y.v
// Description          : Analog power PAD (Not for core voltage power/ground supplies which are connected to internal core voltage circuitry)
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1APRNC_Y (SVDD1AP);

   inout SVDD1AP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1caprnc_x.v
// Description          : Analog power PAD (for core power/ground supplies, not to be connected with signal)
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1CAPRNC_X (SVDD1CAP);

   inout SVDD1CAP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1caprnc_y.v
// Description          : Analog power PAD (for core power/ground supplies, not to be connected with signal)
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1CAPRNC_Y (SVDD1CAP);

   inout SVDD1CAP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd3aprnc_x.v
// Description          : Analog power PAD (NOT for core voltage power/ground supplies which are connected to internal core voltage circuitry) 
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD3APRNC_X (SAVDD);

   inout SAVDD;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd3aprnc_y.v
// Description          : Analog power PAD (NOT for core voltage power/ground supplies which are connected to internal core voltage circuitry) 
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD3APRNC_Y (SAVDD);

   inout SAVDD;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd3caprnc_x.v
// Description          : Analog power PAD (for core power/ground supplies, not to be connected with signal)
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD3CAPRNC_X (SAVDD);

   inout SAVDD;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd3caprnc_y.v
// Description          : Analog power PAD (for core power/ground supplies, not to be connected with signal)
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD3CAPRNC_Y (SAVDD);

   inout SAVDD;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1aprnc_x.v
// Description          : Analog ground PAD (Not for core voltage power/ground supplies which are connected to internal core voltage circuitry)
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1APRNC_X (SVSS1AP);

   inout SVSS1AP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1aprnc_y.v
// Description          : Analog ground PAD (Not for core voltage power/ground supplies which are connected to internal core voltage circuitry)
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1APRNC_Y (SVSS1AP);

   inout SVSS1AP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1caprnc_x.v
// Description          : Analog ground PAD (for core power/ground supplies)
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1CAPRNC_X (SVSS1CAP);

   inout SVSS1CAP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1caprnc_y.v
// Description          : Analog ground PAD (for core power/ground supplies)
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1CAPRNC_Y (SVSS1CAP);

   inout SVSS1CAP;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss3aprnc_x.v
// Description          : Analog ground PAD (NOT for core voltage power/ground supplies which are connected to internal core voltage circuitry) 
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3APRNC_X (SAVSS);

   inout SAVSS;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss3aprnc_y.v
// Description          : Analog ground PAD (NOT for core voltage power/ground supplies which are connected to internal core voltage circuitry) 
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3APRNC_Y (SAVSS);

   inout SAVSS;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss3caprnc_x.v
// Description          : Analog ground PAD (for core power/ground supplies)
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3CAPRNC_X (SAVSS);

   inout SAVSS;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss3caprnc_y.v
// Description          : Analog ground PAD (for core power/ground supplies)
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3CAPRNC_Y (SAVSS);

   inout SAVSS;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss4caprnc_x.v
// Description          : Digital VSS ground pad within analog power domain for core supply 
//                        place for chip x-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS4CAPRNC_X (VSS);

   inout VSS;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2018 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss4caprnc_y.v
// Description          : Digital VSS ground pad within analog power domain for core supply 
//                        place for chip y-orientation
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS4CAPRNC_Y (VSS);

   inout VSS;


`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


`endif // verilator
