//==================================================================//
`define verilator
//======= would be auto replaced by voyager-code-gen.sh ============//

//==================================================================//
`ifdef chip
//======= auto generated ============//

/* verilog_memcomp Version: c0.3.19-beta */
/* common_memcomp Version: c0.3.16-EAC */
/* lang compiler Version: 4.9.4-EAC Jul 12 2017 12:42:23 */
//
//       CONFIDENTIAL AND PROPRIETARY SOFTWARE OF ARM PHYSICAL IP, INC.
//      
//       Copyright (c) 1993 - 2025 ARM Physical IP, Inc.  All Rights Reserved.
//      
//       Use of this Software is subject to the terms and conditions of the
//       applicable license agreement with ARM Physical IP, Inc.
//       In addition, this Software is protected by patents, copyright law 
//       and international treaties.
//      
//       The copyright notice(s) in this Software does not indicate actual or
//       intended publication of this Software.
//
//      Verilog model for High Density Dual Port SRAM SVT MVT Compiler
//
//       Instance Name:              arm28hkcpdpsram256x4m4
//       Words:                      256
//       Bits:                       4
//       Mux:                        4
//       Drive:                      6
//       Write Mask:                 On
//       Write Thru:                 On
//       Extra Margin Adjustment:    On
//       Test Muxes                  On
//       Power Gating:               Off
//       Retention:                  On
//       Pipeline:                   Off
//       Read Disturb Test:	        Off
//       
//       Creation Date:  Sat Jul 19 16:17:05 2025
//       Version: 	r0p1
//
//      Modeling Assumptions: This model supports full gate level simulation
//          including proper x-handling and timing check behavior.  Unit
//          delay timing is included in the model. Back-annotation of SDF
//          (v3.0 or v2.1) is supported.  SDF can be created utilyzing the delay
//          calculation views provided with this generator and supported
//          delay calculators.  All buses are modeled [MSB:LSB].  All 
//          ports are padded with Verilog primitives.
//
//      Modeling Limitations: None.
//
//      Known Bugs: None.
//
//      Known Work Arounds: N/A
//
`timescale 1 ns/1 ps
`define ARM_MEM_PROP 1.000
`define ARM_MEM_RETAIN 1.000
`define ARM_MEM_PERIOD 3.000
`define ARM_MEM_WIDTH 1.000
`define ARM_MEM_SETUP 1.000
`define ARM_MEM_HOLD 0.500
`define ARM_MEM_COLLISION 3.000

module datapath_latch_arm28hkcpdpsram256x4m4 (CLK,Q_update,D_update,SE,SI,D,DFTRAMBYP,mem_path,XQ,Q);
	input CLK,Q_update,D_update,SE,SI,D,DFTRAMBYP,mem_path,XQ;
	output Q;

	reg    D_int;
	reg    Q;

   //  Model PHI2 portion
   always @(CLK or SE or SI or D) begin
      if (CLK === 1'b0) begin
         if (SE===1'b1)
           D_int=SI;
         else if (SE===1'bx)
           D_int=1'bx;
         else
           D_int=D;
      end
   end

   // model output side of RAM latch
   always @(posedge Q_update or posedge D_update or mem_path or posedge XQ) begin
      #0;
      if (XQ===1'b0) begin
         if (DFTRAMBYP===1'b1 || D_update == 1'b1)
           Q=D_int;
         else
           Q=mem_path;
      end
      else
        Q=1'bx;
   end
endmodule // datapath_latch_arm28hkcpdpsram256x4m4

// If ARM_UD_MODEL is defined at Simulator Command Line, it Selects the Fast Functional Model
`ifdef ARM_UD_MODEL

// Following parameter Values can be overridden at Simulator Command Line.

// ARM_UD_DP Defines the delay through Data Paths, for Memory Models it represents BIST MUX output delays.
`ifdef ARM_UD_DP
`else
`define ARM_UD_DP #0.001
`endif
// ARM_UD_CP Defines the delay through Clock Path Cells, for Memory Models it is not used.
`ifdef ARM_UD_CP
`else
`define ARM_UD_CP
`endif
// ARM_UD_SEQ Defines the delay through the Memory, for Memory Models it is used for CLK->Q delays.
`ifdef ARM_UD_SEQ
`else
`define ARM_UD_SEQ #0.01
`endif

`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module arm28hkcpdpsram256x4m4 (VDDCE, VDDPE, VSSE, CENYA, WENYA, AYA, CENYB, WENYB,
    AYB, GWENYA, GWENYB, QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB,
    AB, DB, EMAA, EMAWA, EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB,
    TCENB, TWENB, TAB, TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP,
    SIB, SEB, COLLDISN);
`else
module arm28hkcpdpsram256x4m4 (CENYA, WENYA, AYA, CENYB, WENYB, AYB, GWENYA, GWENYB,
    QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA,
    EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB, TCENB, TWENB, TAB,
    TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP, SIB, SEB, COLLDISN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 4;
  parameter WORDS = 256;
  parameter MUX = 4;
  parameter MEM_WIDTH = 16; // redun block size 4, 8 on left, 8 on right
  parameter MEM_HEIGHT = 64;
  parameter WP_SIZE = 1 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENYA;
  output [3:0] WENYA;
  output [7:0] AYA;
  output  CENYB;
  output [3:0] WENYB;
  output [7:0] AYB;
  output  GWENYA;
  output  GWENYB;
  output [3:0] QA;
  output [3:0] QB;
  output [1:0] SOA;
  output [1:0] SOB;
  input  CLKA;
  input  CENA;
  input [3:0] WENA;
  input [7:0] AA;
  input [3:0] DA;
  input  CLKB;
  input  CENB;
  input [3:0] WENB;
  input [7:0] AB;
  input [3:0] DB;
  input [2:0] EMAA;
  input [1:0] EMAWA;
  input  EMASA;
  input [2:0] EMAB;
  input [1:0] EMAWB;
  input  EMASB;
  input  TENA;
  input  TCENA;
  input [3:0] TWENA;
  input [7:0] TAA;
  input [3:0] TDA;
  input  TENB;
  input  TCENB;
  input [3:0] TWENB;
  input [7:0] TAB;
  input [3:0] TDB;
  input  GWENA;
  input  GWENB;
  input  TGWENA;
  input  TGWENB;
  input  RET1N;
  input [1:0] SIA;
  input  SEA;
  input  DFTRAMBYP;
  input [1:0] SIB;
  input  SEB;
  input  COLLDISN;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

  reg pre_charge_st;
  reg pre_charge_st_a;
  reg pre_charge_st_b;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [15:0] mem [0:63];
  reg [15:0] row, row_t;
  reg LAST_CLKA;
  reg [15:0] row_mask;
  reg [15:0] new_data;
  reg [15:0] data_out;
  reg [3:0] readLatch0;
  reg [3:0] shifted_readLatch0;
  reg  read_mux_sel0_p2;
  reg [3:0] readLatch1;
  reg [3:0] shifted_readLatch1;
  reg  read_mux_sel1_p2;
  reg LAST_CLKB;
  wire [3:0] QA_int;
  reg XQA, QA_update;
  reg XDA_sh, DA_sh_update;
  wire [3:0] DA_int_bmux;
  reg [3:0] mem_path_A;
  reg [3:0] partial_mask;
  reg [3:0] partial_mask_A;
  reg [3:0] partial_corrupt_A = 4'b0;
  wire [3:0] QB_int;
  reg XQB, QB_update;
  reg XDB_sh, DB_sh_update;
  wire [3:0] DB_int_bmux;
  reg [3:0] mem_path_B;
  reg [3:0] partial_mask_B;
  reg [3:0] partial_corrupt_B = 4'b0;
  reg [3:0] writeEnable;
  real previous_CLKA;
  real previous_CLKB;
  initial previous_CLKA = 0;
  initial previous_CLKB = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg WRITE_WRITE_CONTENTION=0;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;
  reg clk0_int;
  reg clk1_int;

  wire  CENYA_;
  wire [3:0] WENYA_;
  wire [7:0] AYA_;
  wire  CENYB_;
  wire [3:0] WENYB_;
  wire [7:0] AYB_;
  wire  GWENYA_;
  wire  GWENYB_;
  wire [3:0] QA_;
  wire [3:0] QB_;
  wire [1:0] SOA_;
  wire [1:0] SOB_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire [3:0] WENA_;
  reg [3:0] WENA_int;
  wire [7:0] AA_;
  reg [7:0] AA_int;
  wire [3:0] DA_;
  reg [3:0] DA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire [3:0] WENB_;
  reg [3:0] WENB_int;
  wire [7:0] AB_;
  reg [7:0] AB_int;
  wire [3:0] DB_;
  reg [3:0] DB_int;
  wire [2:0] EMAA_;
  reg [2:0] EMAA_int;
  wire [1:0] EMAWA_;
  reg [1:0] EMAWA_int;
  wire  EMASA_;
  reg  EMASA_int;
  wire [2:0] EMAB_;
  reg [2:0] EMAB_int;
  wire [1:0] EMAWB_;
  reg [1:0] EMAWB_int;
  wire  EMASB_;
  reg  EMASB_int;
  wire  TENA_;
  reg  TENA_int;
  wire  TCENA_;
  reg  TCENA_int;
  reg  TCENA_p2;
  wire [3:0] TWENA_;
  reg [3:0] TWENA_int;
  wire [7:0] TAA_;
  reg [7:0] TAA_int;
  wire [3:0] TDA_;
  reg [3:0] TDA_int;
  wire  TENB_;
  reg  TENB_int;
  wire  TCENB_;
  reg  TCENB_int;
  reg  TCENB_p2;
  wire [3:0] TWENB_;
  reg [3:0] TWENB_int;
  wire [7:0] TAB_;
  reg [7:0] TAB_int;
  wire [3:0] TDB_;
  reg [3:0] TDB_int;
  wire  GWENA_;
  reg  GWENA_int;
  wire  GWENB_;
  reg  GWENB_int;
  wire  TGWENA_;
  reg  TGWENA_int;
  wire  TGWENB_;
  reg  TGWENB_int;
  wire  RET1N_;
  reg  RET1N_int;
  wire [1:0] SIA_;
  wire [1:0] SIA_int;
  wire  SEA_;
  reg  SEA_int;
  wire  DFTRAMBYP_;
  reg  DFTRAMBYP_int;
  reg  DFTRAMBYP_p2;
  wire [1:0] SIB_;
  wire [1:0] SIB_int;
  wire  SEB_;
  reg  SEB_int;
  wire  COLLDISN_;
  reg  COLLDISN_int;

  assign CENYA = CENYA_; 
  assign WENYA[0] = WENYA_[0]; 
  assign WENYA[1] = WENYA_[1]; 
  assign WENYA[2] = WENYA_[2]; 
  assign WENYA[3] = WENYA_[3]; 
  assign AYA[0] = AYA_[0]; 
  assign AYA[1] = AYA_[1]; 
  assign AYA[2] = AYA_[2]; 
  assign AYA[3] = AYA_[3]; 
  assign AYA[4] = AYA_[4]; 
  assign AYA[5] = AYA_[5]; 
  assign AYA[6] = AYA_[6]; 
  assign AYA[7] = AYA_[7]; 
  assign CENYB = CENYB_; 
  assign WENYB[0] = WENYB_[0]; 
  assign WENYB[1] = WENYB_[1]; 
  assign WENYB[2] = WENYB_[2]; 
  assign WENYB[3] = WENYB_[3]; 
  assign AYB[0] = AYB_[0]; 
  assign AYB[1] = AYB_[1]; 
  assign AYB[2] = AYB_[2]; 
  assign AYB[3] = AYB_[3]; 
  assign AYB[4] = AYB_[4]; 
  assign AYB[5] = AYB_[5]; 
  assign AYB[6] = AYB_[6]; 
  assign AYB[7] = AYB_[7]; 
  assign GWENYA = GWENYA_; 
  assign GWENYB = GWENYB_; 
  assign QA[0] = QA_[0]; 
  assign QA[1] = QA_[1]; 
  assign QA[2] = QA_[2]; 
  assign QA[3] = QA_[3]; 
  assign QB[0] = QB_[0]; 
  assign QB[1] = QB_[1]; 
  assign QB[2] = QB_[2]; 
  assign QB[3] = QB_[3]; 
  assign SOA[0] = SOA_[0]; 
  assign SOA[1] = SOA_[1]; 
  assign SOB[0] = SOB_[0]; 
  assign SOB[1] = SOB_[1]; 
  assign CLKA_ = CLKA;
  assign CENA_ = CENA;
  assign WENA_[0] = WENA[0];
  assign WENA_[1] = WENA[1];
  assign WENA_[2] = WENA[2];
  assign WENA_[3] = WENA[3];
  assign AA_[0] = AA[0];
  assign AA_[1] = AA[1];
  assign AA_[2] = AA[2];
  assign AA_[3] = AA[3];
  assign AA_[4] = AA[4];
  assign AA_[5] = AA[5];
  assign AA_[6] = AA[6];
  assign AA_[7] = AA[7];
  assign DA_[0] = DA[0];
  assign DA_[1] = DA[1];
  assign DA_[2] = DA[2];
  assign DA_[3] = DA[3];
  assign CLKB_ = CLKB;
  assign CENB_ = CENB;
  assign WENB_[0] = WENB[0];
  assign WENB_[1] = WENB[1];
  assign WENB_[2] = WENB[2];
  assign WENB_[3] = WENB[3];
  assign AB_[0] = AB[0];
  assign AB_[1] = AB[1];
  assign AB_[2] = AB[2];
  assign AB_[3] = AB[3];
  assign AB_[4] = AB[4];
  assign AB_[5] = AB[5];
  assign AB_[6] = AB[6];
  assign AB_[7] = AB[7];
  assign DB_[0] = DB[0];
  assign DB_[1] = DB[1];
  assign DB_[2] = DB[2];
  assign DB_[3] = DB[3];
  assign EMAA_[0] = EMAA[0];
  assign EMAA_[1] = EMAA[1];
  assign EMAA_[2] = EMAA[2];
  assign EMAWA_[0] = EMAWA[0];
  assign EMAWA_[1] = EMAWA[1];
  assign EMASA_ = EMASA;
  assign EMAB_[0] = EMAB[0];
  assign EMAB_[1] = EMAB[1];
  assign EMAB_[2] = EMAB[2];
  assign EMAWB_[0] = EMAWB[0];
  assign EMAWB_[1] = EMAWB[1];
  assign EMASB_ = EMASB;
  assign TENA_ = TENA;
  assign TCENA_ = TCENA;
  assign TWENA_[0] = TWENA[0];
  assign TWENA_[1] = TWENA[1];
  assign TWENA_[2] = TWENA[2];
  assign TWENA_[3] = TWENA[3];
  assign TAA_[0] = TAA[0];
  assign TAA_[1] = TAA[1];
  assign TAA_[2] = TAA[2];
  assign TAA_[3] = TAA[3];
  assign TAA_[4] = TAA[4];
  assign TAA_[5] = TAA[5];
  assign TAA_[6] = TAA[6];
  assign TAA_[7] = TAA[7];
  assign TDA_[0] = TDA[0];
  assign TDA_[1] = TDA[1];
  assign TDA_[2] = TDA[2];
  assign TDA_[3] = TDA[3];
  assign TENB_ = TENB;
  assign TCENB_ = TCENB;
  assign TWENB_[0] = TWENB[0];
  assign TWENB_[1] = TWENB[1];
  assign TWENB_[2] = TWENB[2];
  assign TWENB_[3] = TWENB[3];
  assign TAB_[0] = TAB[0];
  assign TAB_[1] = TAB[1];
  assign TAB_[2] = TAB[2];
  assign TAB_[3] = TAB[3];
  assign TAB_[4] = TAB[4];
  assign TAB_[5] = TAB[5];
  assign TAB_[6] = TAB[6];
  assign TAB_[7] = TAB[7];
  assign TDB_[0] = TDB[0];
  assign TDB_[1] = TDB[1];
  assign TDB_[2] = TDB[2];
  assign TDB_[3] = TDB[3];
  assign GWENA_ = GWENA;
  assign GWENB_ = GWENB;
  assign TGWENA_ = TGWENA;
  assign TGWENB_ = TGWENB;
  assign RET1N_ = RET1N;
  assign SIA_[0] = SIA[0];
  assign SIA_[1] = SIA[1];
  assign SEA_ = SEA;
  assign DFTRAMBYP_ = DFTRAMBYP;
  assign SIB_[0] = SIB[0];
  assign SIB_[1] = SIB[1];
  assign SEB_ = SEB;
  assign COLLDISN_ = COLLDISN;

  assign `ARM_UD_DP CENYA_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENA_ ? CENA_ : TCENA_)) : 1'bx;
  assign `ARM_UD_DP WENYA_ = (RET1N_ | pre_charge_st) ? ({4{DFTRAMBYP_}} & (TENA_ ? WENA_ : TWENA_)) : {4{1'bx}};
  assign `ARM_UD_DP AYA_ = (RET1N_ | pre_charge_st) ? ({8{DFTRAMBYP_}} & (TENA_ ? AA_ : TAA_)) : {8{1'bx}};
  assign `ARM_UD_DP CENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? CENB_ : TCENB_)) : 1'bx;
  assign `ARM_UD_DP WENYB_ = (RET1N_ | pre_charge_st) ? ({4{DFTRAMBYP_}} & (TENB_ ? WENB_ : TWENB_)) : {4{1'bx}};
  assign `ARM_UD_DP AYB_ = (RET1N_ | pre_charge_st) ? ({8{DFTRAMBYP_}} & (TENB_ ? AB_ : TAB_)) : {8{1'bx}};
  assign `ARM_UD_DP GWENYA_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENA_ ? GWENA_ : TGWENA_)) : 1'bx;
  assign `ARM_UD_DP GWENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? GWENB_ : TGWENB_)) : 1'bx;
   `ifdef ARM_FAULT_MODELING
     arm28hkcpdpsram256x4m4_error_injection u1(.CLK(CLKA_), .Q_out(QA_), .A(AA_int), .CEN(CENA_int), .DFTRAMBYP(DFTRAMBYP_int), .SE(SEA_int), .GWEN(GWENA_int), .WEN(WENA_int), .Q_in(QA_int));
  `else
  assign `ARM_UD_SEQ QA_ = (RET1N_ | pre_charge_st) ? ((QA_int)) : {4{1'bx}};
  `endif
  assign `ARM_UD_SEQ QB_ = (RET1N_ | pre_charge_st) ? ((QB_int)) : {4{1'bx}};
  assign `ARM_UD_DP SOA_ = (RET1N_ | pre_charge_st) ? ({QA_[2], QA_[1]}) : {2{1'bx}};
  assign `ARM_UD_DP SOB_ = (RET1N_ | pre_charge_st) ? ({QB_[2], QB_[1]}) : {2{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial begin
    #0;
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
  end
`endif
  always @ (EMAA_) begin
  	if(EMAA_ < 3) 
   	$display("Warning: Set Value for EMAA doesn't match Default value 3 in %m at %0t", $time);
  end
  always @ (EMAWA_) begin
  	if(EMAWA_ < 1) 
   	$display("Warning: Set Value for EMAWA doesn't match Default value 1 in %m at %0t", $time);
  end
  always @ (EMASA_) begin
  	if(EMASA_ < 0) 
   	$display("Warning: Set Value for EMASA doesn't match Default value 0 in %m at %0t", $time);
  end
  always @ (EMAB_) begin
  	if(EMAB_ < 3) 
   	$display("Warning: Set Value for EMAB doesn't match Default value 3 in %m at %0t", $time);
  end
  always @ (EMAWB_) begin
  	if(EMAWB_ < 1) 
   	$display("Warning: Set Value for EMAWB doesn't match Default value 1 in %m at %0t", $time);
  end
  always @ (EMASB_) begin
  	if(EMASB_ < 0) 
   	$display("Warning: Set Value for EMASB doesn't match Default value 0 in %m at %0t", $time);
  end

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval===1'bx || bitval===1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction

  function isBit1;
    input bitval;
    begin
      isBit1 = ( bitval===1'b1 ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
	$readmemb(filename, memld);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {4{1'b1}};
        row_mask =  ( {3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1],
          3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
          3'b000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {4{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	XQA = 1'b0; QA_update = 1'b1;
   	$fdisplay(dump_file_desc, "%b", mem_path_A);
  end
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [7:0] load_addr;
	input [3:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
`endif
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {4{1'b1}};
        row_mask =  ( {3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1],
          3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
          3'b000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  endtask

task dumpaddr;
	output [3:0] dump_data;
	input [7:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {4{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	XQA = 1'b0; QA_update = 1'b1;
   	dump_data = mem_path_A;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask


  task readWriteA;
  begin
    if (GWENA_int !== 1'b1 && DFTRAMBYP_int=== 1'b0 && SEA_int === 1'bx) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (DFTRAMBYP_int=== 1'b0 && SEA_int === 1'b1) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int === 1'b0 && (CENA_int === 1'b0 || DFTRAMBYP_int === 1'b1)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(EMAA_int & isBit1(DFTRAMBYP_int)), (EMAWA_int & isBit1(DFTRAMBYP_int)), (EMASA_int & isBit1(DFTRAMBYP_int))} === 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if (^{(CENA_int & !isBit1(DFTRAMBYP_int)), EMAA_int, EMAWA_int, EMASA_int, RET1N_int} === 1'bx) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if ((AA_int >= WORDS) && (CENA_int === 1'b0) && DFTRAMBYP_int === 1'b0) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if (CENA_int === 1'b0 && (^AA_int) === 1'bx && DFTRAMBYP_int === 1'b0) begin
     if (GWENA_int !== 1)
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (CENA_int === 1'b0 || DFTRAMBYP_int === 1'b1) begin
      if(isBitX(DFTRAMBYP_int) || isBitX(SEA_int))
        DA_int = {4{1'bx}};

      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 63)
        row = {16{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENA_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {4{1'bx}};
        DA_int = {4{1'bx}};
      end else
          writeEnable = ~ ( {4{GWENA_int}} | {WENA_int[3], WENA_int[2], WENA_int[1],
          WENA_int[0]});
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1],
          3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DA_int[3], 3'b000, DA_int[2], 3'b000, DA_int[1], 3'b000, DA_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEA_int === 1'b0) begin
        end else if (GWENA_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEA_int === 1'bx) begin
        	XQA = 1'b1; QA_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[12], data_out[8], data_out[4], data_out[0]};
      end
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QA_update = 1'b1; DA_sh_update = 1'b1;
        end else begin
          XQA = 1'b0; QA_update = 1'b1; DA_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	XQA = 1'b0; QA_update = 1'b1;
      end
      if( isBitX(GWENA_int) && DFTRAMBYP_int !== 1'b1) begin
        XQA = 1'b1; QA_update = 1'b1;
      end
      if( isBitX(DFTRAMBYP_int) ) begin
        XQA = 1'b1; QA_update = 1'b1;
      end
      if( isBitX(SEA_int) && DFTRAMBYP_int === 1'b1 ) begin
        XQA = 1'b1; QA_update = 1'b1;
      end
    end
  end
  endtask
  always @ (CENA_ or TCENA_ or TENA_ or DFTRAMBYP_ or CLKA_) begin
  	if(CLKA_ == 1'b0) begin
  		CENA_p2 = CENA_;
  		TCENA_p2 = TCENA_;
  		DFTRAMBYP_p2 = DFTRAMBYP_;
  	end
  end

`ifdef POWER_PINS
  always @ (posedge VDDCE or negedge VDDCE) begin
      if (VDDCE != 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDCE should be powered down after VDDPE, Illegal power down sequencing in %m at %0t", $time);
       end
        $display("In PowerDown Mode in %m at %0t", $time);
        failedWrite(0);
      end
      if (VDDCE == 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDPE should be powered up after VDDCE in %m at %0t", $time);
        $display("Illegal power up sequencing in %m at %0t", $time);
       end
        failedWrite(0);
      end
  end
`endif
`ifdef POWER_PINS
  always @ (RET1N_ or VDDPE or VDDCE) begin
`else     
  always @ RET1N_ begin
`endif
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && RET1N_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_a == 1'b1 && (CENA_ === 1'bx || TCENA_ === 1'bx || DFTRAMBYP_ === 1'bx || CLKA_ === 1'bx)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`endif
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0 || DFTRAMBYP_p2 === 1'b1)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0 || DFTRAMBYP_p2 === 1'b1)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end
`ifdef POWER_PINS
    if (RET1N_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_a = 1;
      pre_charge_st = 1;
    end else if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (RET1N_ == 1'b0) begin
`endif
        XQA = 1'b1; QA_update = 1'b1;
      CENA_int = 1'bx;
      WENA_int = {4{1'bx}};
      AA_int = {8{1'bx}};
      DA_int = {4{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {4{1'bx}};
      TAA_int = {8{1'bx}};
      TDA_int = {4{1'bx}};
      GWENA_int = 1'bx;
      TGWENA_int = 1'bx;
      RET1N_int = 1'bx;
      SEA_int = 1'bx;
      DFTRAMBYP_int = 1'bx;
      COLLDISN_int = 1'bx;
`ifdef POWER_PINS
    end else if (RET1N_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_a == 1'b1) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
        XQA = 1'b1; QA_update = 1'b1;
      CENA_int = 1'bx;
      WENA_int = {4{1'bx}};
      AA_int = {8{1'bx}};
      DA_int = {4{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {4{1'bx}};
      TAA_int = {8{1'bx}};
      TDA_int = {4{1'bx}};
      GWENA_int = 1'bx;
      TGWENA_int = 1'bx;
      RET1N_int = 1'bx;
      SEA_int = 1'bx;
      DFTRAMBYP_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
    #0;
        QA_update = 1'b0;
  end


  always @ CLKA_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
`ifdef POWER_PINS
  if (RET1N_ == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((CLKA_ === 1'bx || CLKA_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if ((CLKA_ === 1'b1 || CLKA_ === 1'b0) && LAST_CLKA === 1'bx) begin
       DA_sh_update = 1'b0;  XDA_sh = 1'b0;
       XQA = 1'b0; QA_update = 1'b0; 
    end else if (CLKA_ === 1'b1 && LAST_CLKA === 1'b0) begin
      SEA_int = SEA_;
      DFTRAMBYP_int = DFTRAMBYP_;
      CENA_int = TENA_ ? CENA_ : TCENA_;
      EMAA_int = EMAA_;
      EMAWA_int = EMAWA_;
      EMASA_int = EMASA_;
      TENA_int = TENA_;
      TWENA_int = TWENA_;
      RET1N_int = RET1N_;
      COLLDISN_int = COLLDISN_;
      if (DFTRAMBYP_=== 1'b1 || CENA_int != 1'b1) begin
        WENA_int = TENA_ ? WENA_ : TWENA_;
        AA_int = TENA_ ? AA_ : TAA_;
        DA_int = TENA_ ? DA_ : TDA_;
        TCENA_int = TCENA_;
        TAA_int = TAA_;
        TDA_int = TDA_;
        GWENA_int = TENA_ ? GWENA_ : TGWENA_;
        TGWENA_int = TGWENA_;
        DFTRAMBYP_int = DFTRAMBYP_;
      end
      clk0_int = 1'b0;
      if (DFTRAMBYP_=== 1'b1 && SEA_ === 1'b1) begin
        XQA = 1'b0; QA_update = 1'b1;
      end else begin
      CENA_int = TENA_ ? CENA_ : TCENA_;
      EMAA_int = EMAA_;
      EMAWA_int = EMAWA_;
      EMASA_int = EMASA_;
      TENA_int = TENA_;
      TWENA_int = TWENA_;
      RET1N_int = RET1N_;
      COLLDISN_int = COLLDISN_;
      if (DFTRAMBYP_=== 1'b1 || CENA_int != 1'b1) begin
        WENA_int = TENA_ ? WENA_ : TWENA_;
        AA_int = TENA_ ? AA_ : TAA_;
        DA_int = TENA_ ? DA_ : TDA_;
        TCENA_int = TCENA_;
        TAA_int = TAA_;
        TDA_int = TDA_;
        GWENA_int = TENA_ ? GWENA_ : TGWENA_;
        TGWENA_int = TGWENA_;
        DFTRAMBYP_int = DFTRAMBYP_;
      end
      clk0_int = 1'b0;
      if (CENA_int === 1'b0) previous_CLKA = $realtime;
    readWriteA;
      end
    #0;
      if (((previous_CLKA == previous_CLKB)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1 && DFTRAMBYP_ !== 1'b1) && COLLDISN_int === 1'b1 && row_contention(AA_int,
        AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({4{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({4{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_B);
        #0;
        QB_update = 1'b0;
        #0;
        QB_update = 1'b1;
         end else begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQB = 1'b1; QB_update = 1'b1;
		end
         end
        end else if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_A);
        #0;
        QA_update = 1'b0;
        #0;
        QA_update = 1'b1;
         end else begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
		end
         end
        end else begin
          readWriteB;
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          readWriteB;
          readWriteA;
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1 && GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && !(GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
      end else if (((previous_CLKA == previous_CLKB)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1 && DFTRAMBYP_ !== 1'b1) && (COLLDISN_int === 1'b0 || COLLDISN_int 
       === 1'bx)  && row_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DB_int = {4{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        XQB = 1'b1; QB_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DA_int = {4{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        XQA = 1'b1; QA_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKA_ === 1'b0 && LAST_CLKA === 1'b1) begin
      partial_corrupt_A = 4'b0;
      QA_update = 1'b0;
      DA_sh_update = 1'b0;
      XQA = 1'b0;
    end
  end
    LAST_CLKA = CLKA_;
  end

  assign SIA_int = SEA_ ? SIA_ : {2{1'b0}};
  assign DA_int_bmux = TENA_ ? DA_ : TDA_;

  datapath_latch_arm28hkcpdpsram256x4m4 uDQA0 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[0]), .D(DA_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[0]), .XQ(XQA|partial_corrupt_A[0]), .Q(QA_int[0]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQA1 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[0]), .D(DA_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[1]), .XQ(XQA|partial_corrupt_A[1]), .Q(QA_int[1]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQA2 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[3]), .D(DA_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[2]), .XQ(XQA|partial_corrupt_A[2]), .Q(QA_int[2]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQA3 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[1]), .D(DA_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[3]), .XQ(XQA|partial_corrupt_A[3]), .Q(QA_int[3]));



  task readWriteB;
  begin
    if (GWENB_int !== 1'b1 && DFTRAMBYP_int=== 1'b0 && SEB_int === 1'bx) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (DFTRAMBYP_int=== 1'b0 && SEB_int === 1'b1) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (RET1N_int === 1'b0 && (CENB_int === 1'b0 || DFTRAMBYP_int === 1'b1)) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(EMAB_int & isBit1(DFTRAMBYP_int)), (EMAWB_int & isBit1(DFTRAMBYP_int)), (EMASB_int & isBit1(DFTRAMBYP_int))} === 1'bx) begin
        XQB = 1'b1; QB_update = 1'b1;
    end else if (^{(CENB_int & !isBit1(DFTRAMBYP_int)), EMAB_int, EMAWB_int, EMASB_int, RET1N_int} === 1'bx) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if ((AB_int >= WORDS) && (CENB_int === 1'b0) && DFTRAMBYP_int === 1'b0) begin
        XQB = 1'b1; QB_update = 1'b1;
    end else if (CENB_int === 1'b0 && (^AB_int) === 1'bx && DFTRAMBYP_int === 1'b0) begin
     if (GWENB_int !== 1)
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (CENB_int === 1'b0 || DFTRAMBYP_int === 1'b1) begin
      if(isBitX(DFTRAMBYP_int) || isBitX(SEB_int))
        DB_int = {4{1'bx}};

      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 63)
        row = {16{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENB_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {4{1'bx}};
        DB_int = {4{1'bx}};
      end else
          writeEnable = ~ ( {4{GWENB_int}} | {WENB_int[3], WENB_int[2], WENB_int[1],
          WENB_int[0]});
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1],
          3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DB_int[3], 3'b000, DB_int[2], 3'b000, DB_int[1], 3'b000, DB_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEB_int === 1'b0) begin
        end else if (GWENB_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEB_int === 1'bx) begin
        	XQB = 1'b1; QB_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[12], data_out[8], data_out[4], data_out[0]};
      end
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QB_update = 1'b1; DB_sh_update = 1'b1;
        end else begin
          XQB = 1'b0; QB_update = 1'b1; DB_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch1 = readLatch1;
        mem_path_B = {shifted_readLatch1[3], shifted_readLatch1[2], shifted_readLatch1[1],
          shifted_readLatch1[0]};
        	XQB = 1'b0; QB_update = 1'b1;
      end
      if( isBitX(GWENB_int) && DFTRAMBYP_int !== 1'b1) begin
        XQB = 1'b1; QB_update = 1'b1;
      end
      if( isBitX(DFTRAMBYP_int) ) begin
        XQB = 1'b1; QB_update = 1'b1;
      end
      if( isBitX(SEB_int) && DFTRAMBYP_int === 1'b1 ) begin
        XQB = 1'b1; QB_update = 1'b1;
      end
    end
  end
  endtask
  always @ (CENB_ or TCENB_ or TENB_ or DFTRAMBYP_ or CLKB_) begin
  	if(CLKB_ == 1'b0) begin
  		CENB_p2 = CENB_;
  		TCENB_p2 = TCENB_;
  		DFTRAMBYP_p2 = DFTRAMBYP_;
  	end
  end

`ifdef POWER_PINS
  always @ (RET1N_ or VDDPE or VDDCE) begin
`else     
  always @ RET1N_ begin
`endif
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && RET1N_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_b == 1'b1 && (CENB_ === 1'bx || TCENB_ === 1'bx || DFTRAMBYP_ === 1'bx || CLKB_ === 1'bx)) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`endif
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0 || DFTRAMBYP_p2 === 1'b1)) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0 || DFTRAMBYP_p2 === 1'b1)) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end
`ifdef POWER_PINS
    if (RET1N_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_b = 1;
      pre_charge_st = 1;
    end else if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(1);
      end
`else     
    if (RET1N_ == 1'b0) begin
`endif
        XQB = 1'b1; QB_update = 1'b1;
      CENB_int = 1'bx;
      WENB_int = {4{1'bx}};
      AB_int = {8{1'bx}};
      DB_int = {4{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {4{1'bx}};
      TAB_int = {8{1'bx}};
      TDB_int = {4{1'bx}};
      GWENB_int = 1'bx;
      TGWENB_int = 1'bx;
      RET1N_int = 1'bx;
      SEB_int = 1'bx;
      COLLDISN_int = 1'bx;
`ifdef POWER_PINS
    end else if (RET1N_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_b == 1'b1) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
        XQB = 1'b1; QB_update = 1'b1;
      CENB_int = 1'bx;
      WENB_int = {4{1'bx}};
      AB_int = {8{1'bx}};
      DB_int = {4{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {4{1'bx}};
      TAB_int = {8{1'bx}};
      TDB_int = {4{1'bx}};
      GWENB_int = 1'bx;
      TGWENB_int = 1'bx;
      RET1N_int = 1'bx;
      SEB_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
    #0;
        QB_update = 1'b0;
  end


  always @ CLKB_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
`ifdef POWER_PINS
  if (RET1N_ == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((CLKB_ === 1'bx || CLKB_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if ((CLKB_ === 1'b1 || CLKB_ === 1'b0) && LAST_CLKB === 1'bx) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
       XQB = 1'b0; QB_update = 1'b0; 
    end else if (CLKB_ === 1'b1 && LAST_CLKB === 1'b0) begin
      DFTRAMBYP_int = DFTRAMBYP_;
      SEB_int = SEB_;
      CENB_int = TENB_ ? CENB_ : TCENB_;
      EMAB_int = EMAB_;
      EMAWB_int = EMAWB_;
      EMASB_int = EMASB_;
      TENB_int = TENB_;
      TWENB_int = TWENB_;
      RET1N_int = RET1N_;
      COLLDISN_int = COLLDISN_;
      if (DFTRAMBYP_=== 1'b1 || CENB_int != 1'b1) begin
        WENB_int = TENB_ ? WENB_ : TWENB_;
        AB_int = TENB_ ? AB_ : TAB_;
        DB_int = TENB_ ? DB_ : TDB_;
        TCENB_int = TCENB_;
        TAB_int = TAB_;
        TDB_int = TDB_;
        GWENB_int = TENB_ ? GWENB_ : TGWENB_;
        TGWENB_int = TGWENB_;
      end
      clk1_int = 1'b0;
      if (DFTRAMBYP_=== 1'b1 && SEB_ === 1'b1) begin
        XQB = 1'b0; QB_update = 1'b1;
      end else begin
      CENB_int = TENB_ ? CENB_ : TCENB_;
      EMAB_int = EMAB_;
      EMAWB_int = EMAWB_;
      EMASB_int = EMASB_;
      TENB_int = TENB_;
      TWENB_int = TWENB_;
      RET1N_int = RET1N_;
      COLLDISN_int = COLLDISN_;
      if (DFTRAMBYP_=== 1'b1 || CENB_int != 1'b1) begin
        WENB_int = TENB_ ? WENB_ : TWENB_;
        AB_int = TENB_ ? AB_ : TAB_;
        DB_int = TENB_ ? DB_ : TDB_;
        TCENB_int = TCENB_;
        TAB_int = TAB_;
        TDB_int = TDB_;
        GWENB_int = TENB_ ? GWENB_ : TGWENB_;
        TGWENB_int = TGWENB_;
      end
      clk1_int = 1'b0;
      if (CENB_int === 1'b0) previous_CLKB = $realtime;
    readWriteB;
      end
    #0;
      if (((previous_CLKA == previous_CLKB)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1 && DFTRAMBYP_ !== 1'b1) && COLLDISN_int === 1'b1 && row_contention(AA_int,
        AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({4{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({4{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_B);
        #0;
        QB_update = 1'b0;
        #0;
        QB_update = 1'b1;
         end else begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQB = 1'b1; QB_update = 1'b1;
		end
         end
        end else if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_A);
        #0;
        QA_update = 1'b0;
        #0;
        QA_update = 1'b1;
         end else begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
		end
         end
        end else begin
          readWriteA;
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          readWriteA;
          readWriteB;
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1 && GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && !(GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
      end else if (((previous_CLKA == previous_CLKB)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1 && DFTRAMBYP_ !== 1'b1) && (COLLDISN_int === 1'b0 || COLLDISN_int 
       === 1'bx)  && row_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DA_int = {4{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        XQA = 1'b1; QA_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DB_int = {4{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        XQB = 1'b1; QB_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKB_ === 1'b0 && LAST_CLKB === 1'b1) begin
      partial_corrupt_A = 4'b0;
      QB_update = 1'b0;
      DB_sh_update = 1'b0;
      XQB = 1'b0;
    end
  end
    LAST_CLKB = CLKB_;
  end

  assign SIB_int = SEB_ ? SIB_ : {2{1'b0}};
  assign DB_int_bmux = TENB_ ? DB_ : TDB_;

  datapath_latch_arm28hkcpdpsram256x4m4 uDQB0 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[0]), .D(DB_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[0]), .XQ(XQB|partial_corrupt_A[0]), .Q(QB_int[0]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQB1 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[0]), .D(DB_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[1]), .XQ(XQB|partial_corrupt_A[1]), .Q(QB_int[1]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQB2 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[3]), .D(DB_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[2]), .XQ(XQB|partial_corrupt_A[2]), .Q(QB_int[2]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQB3 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[1]), .D(DB_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[3]), .XQ(XQB|partial_corrupt_A[3]), .Q(QB_int[3]));


// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
 always @ (VDDCE or VDDPE or VSSE) begin
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
 end
`endif

  function row_contention;
    input [7:0] aa;
    input [7:0] ab;
    input [3:0] wena;
    input [3:0] wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) === 1'b1 && (& wenb) === 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[7:2] == ab[7:2]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [7:0] aa;
    input [7:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [7:0] aa;
    input [7:0] ab;
    input [3:0] wena;
    input [3:0] wenb;
    reg result;
  begin
    if ((& wena) === 1'b1 && (& wenb) === 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction


endmodule
`endcelldefine
`else
`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module arm28hkcpdpsram256x4m4 (VDDCE, VDDPE, VSSE, CENYA, WENYA, AYA, CENYB, WENYB,
    AYB, GWENYA, GWENYB, QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB,
    AB, DB, EMAA, EMAWA, EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB,
    TCENB, TWENB, TAB, TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP,
    SIB, SEB, COLLDISN);
`else
module arm28hkcpdpsram256x4m4 (CENYA, WENYA, AYA, CENYB, WENYB, AYB, GWENYA, GWENYB,
    QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA,
    EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB, TCENB, TWENB, TAB,
    TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP, SIB, SEB, COLLDISN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 4;
  parameter WORDS = 256;
  parameter MUX = 4;
  parameter MEM_WIDTH = 16; // redun block size 4, 8 on left, 8 on right
  parameter MEM_HEIGHT = 64;
  parameter WP_SIZE = 1 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENYA;
  output [3:0] WENYA;
  output [7:0] AYA;
  output  CENYB;
  output [3:0] WENYB;
  output [7:0] AYB;
  output  GWENYA;
  output  GWENYB;
  output [3:0] QA;
  output [3:0] QB;
  output [1:0] SOA;
  output [1:0] SOB;
  input  CLKA;
  input  CENA;
  input [3:0] WENA;
  input [7:0] AA;
  input [3:0] DA;
  input  CLKB;
  input  CENB;
  input [3:0] WENB;
  input [7:0] AB;
  input [3:0] DB;
  input [2:0] EMAA;
  input [1:0] EMAWA;
  input  EMASA;
  input [2:0] EMAB;
  input [1:0] EMAWB;
  input  EMASB;
  input  TENA;
  input  TCENA;
  input [3:0] TWENA;
  input [7:0] TAA;
  input [3:0] TDA;
  input  TENB;
  input  TCENB;
  input [3:0] TWENB;
  input [7:0] TAB;
  input [3:0] TDB;
  input  GWENA;
  input  GWENB;
  input  TGWENA;
  input  TGWENB;
  input  RET1N;
  input [1:0] SIA;
  input  SEA;
  input  DFTRAMBYP;
  input [1:0] SIB;
  input  SEB;
  input  COLLDISN;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

  reg pre_charge_st;
  reg pre_charge_st_a;
  reg pre_charge_st_b;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [15:0] mem [0:63];
  reg [15:0] row, row_t;
  reg LAST_CLKA;
  reg [15:0] row_mask;
  reg [15:0] new_data;
  reg [15:0] data_out;
  reg [3:0] readLatch0;
  reg [3:0] shifted_readLatch0;
  reg  read_mux_sel0_p2;
  reg [3:0] readLatch1;
  reg [3:0] shifted_readLatch1;
  reg  read_mux_sel1_p2;
  reg LAST_CLKB;
  wire [3:0] QA_int;
  reg XQA, QA_update;
  reg XDA_sh, DA_sh_update;
  wire [3:0] DA_int_bmux;
  reg [3:0] mem_path_A;
  reg [3:0] partial_mask;
  reg [3:0] partial_mask_A;
  reg [3:0] partial_corrupt_A = 4'b0;
  wire [3:0] QB_int;
  reg XQB, QB_update;
  reg XDB_sh, DB_sh_update;
  wire [3:0] DB_int_bmux;
  reg [3:0] mem_path_B;
  reg [3:0] partial_mask_B;
  reg [3:0] partial_corrupt_B = 4'b0;
  reg [3:0] writeEnable;
  real previous_CLKA;
  real previous_CLKB;
  initial previous_CLKA = 0;
  initial previous_CLKB = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg WRITE_WRITE_CONTENTION=0;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;

  reg NOT_CENA, NOT_WENA3, NOT_WENA2, NOT_WENA1, NOT_WENA0, NOT_AA7, NOT_AA6, NOT_AA5;
  reg NOT_AA4, NOT_AA3, NOT_AA2, NOT_AA1, NOT_AA0, NOT_DA3, NOT_DA2, NOT_DA1, NOT_DA0;
  reg NOT_CENB, NOT_WENB3, NOT_WENB2, NOT_WENB1, NOT_WENB0, NOT_AB7, NOT_AB6, NOT_AB5;
  reg NOT_AB4, NOT_AB3, NOT_AB2, NOT_AB1, NOT_AB0, NOT_DB3, NOT_DB2, NOT_DB1, NOT_DB0;
  reg NOT_EMAA2, NOT_EMAA1, NOT_EMAA0, NOT_EMAWA1, NOT_EMAWA0, NOT_EMASA, NOT_EMAB2;
  reg NOT_EMAB1, NOT_EMAB0, NOT_EMAWB1, NOT_EMAWB0, NOT_EMASB, NOT_TENA, NOT_TCENA;
  reg NOT_TWENA3, NOT_TWENA2, NOT_TWENA1, NOT_TWENA0, NOT_TAA7, NOT_TAA6, NOT_TAA5;
  reg NOT_TAA4, NOT_TAA3, NOT_TAA2, NOT_TAA1, NOT_TAA0, NOT_TDA3, NOT_TDA2, NOT_TDA1;
  reg NOT_TDA0, NOT_TENB, NOT_TCENB, NOT_TWENB3, NOT_TWENB2, NOT_TWENB1, NOT_TWENB0;
  reg NOT_TAB7, NOT_TAB6, NOT_TAB5, NOT_TAB4, NOT_TAB3, NOT_TAB2, NOT_TAB1, NOT_TAB0;
  reg NOT_TDB3, NOT_TDB2, NOT_TDB1, NOT_TDB0, NOT_GWENA, NOT_GWENB, NOT_TGWENA, NOT_TGWENB;
  reg NOT_SIA1, NOT_SIA0, NOT_SEA, NOT_DFTRAMBYP_CLKB, NOT_DFTRAMBYP_CLKA, NOT_RET1N;
  reg NOT_SIB1, NOT_SIB0, NOT_SEB, NOT_COLLDISN;
  reg NOT_CLKA_PER, NOT_CLKA_MINH, NOT_CLKA_MINL, NOT_CONTA, NOT_CLKB_PER, NOT_CLKB_MINH;
  reg NOT_CLKB_MINL, NOT_CONTB;
  reg clk0_int;
  reg clk1_int;

  wire  CENYA_;
  wire [3:0] WENYA_;
  wire [7:0] AYA_;
  wire  CENYB_;
  wire [3:0] WENYB_;
  wire [7:0] AYB_;
  wire  GWENYA_;
  wire  GWENYB_;
  wire [3:0] QA_;
  wire [3:0] QB_;
  wire [1:0] SOA_;
  wire [1:0] SOB_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire [3:0] WENA_;
  reg [3:0] WENA_int;
  wire [7:0] AA_;
  reg [7:0] AA_int;
  wire [3:0] DA_;
  reg [3:0] DA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire [3:0] WENB_;
  reg [3:0] WENB_int;
  wire [7:0] AB_;
  reg [7:0] AB_int;
  wire [3:0] DB_;
  reg [3:0] DB_int;
  wire [2:0] EMAA_;
  reg [2:0] EMAA_int;
  wire [1:0] EMAWA_;
  reg [1:0] EMAWA_int;
  wire  EMASA_;
  reg  EMASA_int;
  wire [2:0] EMAB_;
  reg [2:0] EMAB_int;
  wire [1:0] EMAWB_;
  reg [1:0] EMAWB_int;
  wire  EMASB_;
  reg  EMASB_int;
  wire  TENA_;
  reg  TENA_int;
  wire  TCENA_;
  reg  TCENA_int;
  reg  TCENA_p2;
  wire [3:0] TWENA_;
  reg [3:0] TWENA_int;
  wire [7:0] TAA_;
  reg [7:0] TAA_int;
  wire [3:0] TDA_;
  reg [3:0] TDA_int;
  wire  TENB_;
  reg  TENB_int;
  wire  TCENB_;
  reg  TCENB_int;
  reg  TCENB_p2;
  wire [3:0] TWENB_;
  reg [3:0] TWENB_int;
  wire [7:0] TAB_;
  reg [7:0] TAB_int;
  wire [3:0] TDB_;
  reg [3:0] TDB_int;
  wire  GWENA_;
  reg  GWENA_int;
  wire  GWENB_;
  reg  GWENB_int;
  wire  TGWENA_;
  reg  TGWENA_int;
  wire  TGWENB_;
  reg  TGWENB_int;
  wire  RET1N_;
  reg  RET1N_int;
  wire [1:0] SIA_;
  wire [1:0] SIA_int;
  wire  SEA_;
  reg  SEA_int;
  wire  DFTRAMBYP_;
  reg  DFTRAMBYP_int;
  reg  DFTRAMBYP_p2;
  wire [1:0] SIB_;
  wire [1:0] SIB_int;
  wire  SEB_;
  reg  SEB_int;
  wire  COLLDISN_;
  reg  COLLDISN_int;

  buf B0(CENYA, CENYA_);
  buf B1(WENYA[0], WENYA_[0]);
  buf B2(WENYA[1], WENYA_[1]);
  buf B3(WENYA[2], WENYA_[2]);
  buf B4(WENYA[3], WENYA_[3]);
  buf B5(AYA[0], AYA_[0]);
  buf B6(AYA[1], AYA_[1]);
  buf B7(AYA[2], AYA_[2]);
  buf B8(AYA[3], AYA_[3]);
  buf B9(AYA[4], AYA_[4]);
  buf B10(AYA[5], AYA_[5]);
  buf B11(AYA[6], AYA_[6]);
  buf B12(AYA[7], AYA_[7]);
  buf B13(CENYB, CENYB_);
  buf B14(WENYB[0], WENYB_[0]);
  buf B15(WENYB[1], WENYB_[1]);
  buf B16(WENYB[2], WENYB_[2]);
  buf B17(WENYB[3], WENYB_[3]);
  buf B18(AYB[0], AYB_[0]);
  buf B19(AYB[1], AYB_[1]);
  buf B20(AYB[2], AYB_[2]);
  buf B21(AYB[3], AYB_[3]);
  buf B22(AYB[4], AYB_[4]);
  buf B23(AYB[5], AYB_[5]);
  buf B24(AYB[6], AYB_[6]);
  buf B25(AYB[7], AYB_[7]);
  buf B26(GWENYA, GWENYA_);
  buf B27(GWENYB, GWENYB_);
  buf B28(QA[0], QA_[0]);
  buf B29(QA[1], QA_[1]);
  buf B30(QA[2], QA_[2]);
  buf B31(QA[3], QA_[3]);
  buf B32(QB[0], QB_[0]);
  buf B33(QB[1], QB_[1]);
  buf B34(QB[2], QB_[2]);
  buf B35(QB[3], QB_[3]);
  buf B36(SOA[0], SOA_[0]);
  buf B37(SOA[1], SOA_[1]);
  buf B38(SOB[0], SOB_[0]);
  buf B39(SOB[1], SOB_[1]);
  buf B40(CLKA_, CLKA);
  buf B41(CENA_, CENA);
  buf B42(WENA_[0], WENA[0]);
  buf B43(WENA_[1], WENA[1]);
  buf B44(WENA_[2], WENA[2]);
  buf B45(WENA_[3], WENA[3]);
  buf B46(AA_[0], AA[0]);
  buf B47(AA_[1], AA[1]);
  buf B48(AA_[2], AA[2]);
  buf B49(AA_[3], AA[3]);
  buf B50(AA_[4], AA[4]);
  buf B51(AA_[5], AA[5]);
  buf B52(AA_[6], AA[6]);
  buf B53(AA_[7], AA[7]);
  buf B54(DA_[0], DA[0]);
  buf B55(DA_[1], DA[1]);
  buf B56(DA_[2], DA[2]);
  buf B57(DA_[3], DA[3]);
  buf B58(CLKB_, CLKB);
  buf B59(CENB_, CENB);
  buf B60(WENB_[0], WENB[0]);
  buf B61(WENB_[1], WENB[1]);
  buf B62(WENB_[2], WENB[2]);
  buf B63(WENB_[3], WENB[3]);
  buf B64(AB_[0], AB[0]);
  buf B65(AB_[1], AB[1]);
  buf B66(AB_[2], AB[2]);
  buf B67(AB_[3], AB[3]);
  buf B68(AB_[4], AB[4]);
  buf B69(AB_[5], AB[5]);
  buf B70(AB_[6], AB[6]);
  buf B71(AB_[7], AB[7]);
  buf B72(DB_[0], DB[0]);
  buf B73(DB_[1], DB[1]);
  buf B74(DB_[2], DB[2]);
  buf B75(DB_[3], DB[3]);
  buf B76(EMAA_[0], EMAA[0]);
  buf B77(EMAA_[1], EMAA[1]);
  buf B78(EMAA_[2], EMAA[2]);
  buf B79(EMAWA_[0], EMAWA[0]);
  buf B80(EMAWA_[1], EMAWA[1]);
  buf B81(EMASA_, EMASA);
  buf B82(EMAB_[0], EMAB[0]);
  buf B83(EMAB_[1], EMAB[1]);
  buf B84(EMAB_[2], EMAB[2]);
  buf B85(EMAWB_[0], EMAWB[0]);
  buf B86(EMAWB_[1], EMAWB[1]);
  buf B87(EMASB_, EMASB);
  buf B88(TENA_, TENA);
  buf B89(TCENA_, TCENA);
  buf B90(TWENA_[0], TWENA[0]);
  buf B91(TWENA_[1], TWENA[1]);
  buf B92(TWENA_[2], TWENA[2]);
  buf B93(TWENA_[3], TWENA[3]);
  buf B94(TAA_[0], TAA[0]);
  buf B95(TAA_[1], TAA[1]);
  buf B96(TAA_[2], TAA[2]);
  buf B97(TAA_[3], TAA[3]);
  buf B98(TAA_[4], TAA[4]);
  buf B99(TAA_[5], TAA[5]);
  buf B100(TAA_[6], TAA[6]);
  buf B101(TAA_[7], TAA[7]);
  buf B102(TDA_[0], TDA[0]);
  buf B103(TDA_[1], TDA[1]);
  buf B104(TDA_[2], TDA[2]);
  buf B105(TDA_[3], TDA[3]);
  buf B106(TENB_, TENB);
  buf B107(TCENB_, TCENB);
  buf B108(TWENB_[0], TWENB[0]);
  buf B109(TWENB_[1], TWENB[1]);
  buf B110(TWENB_[2], TWENB[2]);
  buf B111(TWENB_[3], TWENB[3]);
  buf B112(TAB_[0], TAB[0]);
  buf B113(TAB_[1], TAB[1]);
  buf B114(TAB_[2], TAB[2]);
  buf B115(TAB_[3], TAB[3]);
  buf B116(TAB_[4], TAB[4]);
  buf B117(TAB_[5], TAB[5]);
  buf B118(TAB_[6], TAB[6]);
  buf B119(TAB_[7], TAB[7]);
  buf B120(TDB_[0], TDB[0]);
  buf B121(TDB_[1], TDB[1]);
  buf B122(TDB_[2], TDB[2]);
  buf B123(TDB_[3], TDB[3]);
  buf B124(GWENA_, GWENA);
  buf B125(GWENB_, GWENB);
  buf B126(TGWENA_, TGWENA);
  buf B127(TGWENB_, TGWENB);
  buf B128(RET1N_, RET1N);
  buf B129(SIA_[0], SIA[0]);
  buf B130(SIA_[1], SIA[1]);
  buf B131(SEA_, SEA);
  buf B132(DFTRAMBYP_, DFTRAMBYP);
  buf B133(SIB_[0], SIB[0]);
  buf B134(SIB_[1], SIB[1]);
  buf B135(SEB_, SEB);
  buf B136(COLLDISN_, COLLDISN);

  assign CENYA_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENA_ ? CENA_ : TCENA_)) : 1'bx;
  assign WENYA_ = (RET1N_ | pre_charge_st) ? ({4{DFTRAMBYP_}} & (TENA_ ? WENA_ : TWENA_)) : {4{1'bx}};
  assign AYA_ = (RET1N_ | pre_charge_st) ? ({8{DFTRAMBYP_}} & (TENA_ ? AA_ : TAA_)) : {8{1'bx}};
  assign CENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? CENB_ : TCENB_)) : 1'bx;
  assign WENYB_ = (RET1N_ | pre_charge_st) ? ({4{DFTRAMBYP_}} & (TENB_ ? WENB_ : TWENB_)) : {4{1'bx}};
  assign AYB_ = (RET1N_ | pre_charge_st) ? ({8{DFTRAMBYP_}} & (TENB_ ? AB_ : TAB_)) : {8{1'bx}};
  assign GWENYA_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENA_ ? GWENA_ : TGWENA_)) : 1'bx;
  assign GWENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? GWENB_ : TGWENB_)) : 1'bx;
   `ifdef ARM_FAULT_MODELING
     arm28hkcpdpsram256x4m4_error_injection u1(.CLK(CLKA_), .Q_out(QA_), .A(AA_int), .CEN(CENA_int), .DFTRAMBYP(DFTRAMBYP_int), .SE(SEA_int), .GWEN(GWENA_int), .WEN(WENA_int), .Q_in(QA_int));
  `else
  assign QA_ = (RET1N_ | pre_charge_st) ? ((QA_int)) : {4{1'bx}};
  `endif
  assign QB_ = (RET1N_ | pre_charge_st) ? ((QB_int)) : {4{1'bx}};
  assign SOA_ = (RET1N_ | pre_charge_st) ? ({QA_[2], QA_[1]}) : {2{1'bx}};
  assign SOB_ = (RET1N_ | pre_charge_st) ? ({QB_[2], QB_[1]}) : {2{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial begin
    #0;
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
  end
`endif
  always @ (EMAA_) begin
  	if(EMAA_ < 3) 
   	$display("Warning: Set Value for EMAA doesn't match Default value 3 in %m at %0t", $time);
  end
  always @ (EMAWA_) begin
  	if(EMAWA_ < 1) 
   	$display("Warning: Set Value for EMAWA doesn't match Default value 1 in %m at %0t", $time);
  end
  always @ (EMASA_) begin
  	if(EMASA_ < 0) 
   	$display("Warning: Set Value for EMASA doesn't match Default value 0 in %m at %0t", $time);
  end
  always @ (EMAB_) begin
  	if(EMAB_ < 3) 
   	$display("Warning: Set Value for EMAB doesn't match Default value 3 in %m at %0t", $time);
  end
  always @ (EMAWB_) begin
  	if(EMAWB_ < 1) 
   	$display("Warning: Set Value for EMAWB doesn't match Default value 1 in %m at %0t", $time);
  end
  always @ (EMASB_) begin
  	if(EMASB_ < 0) 
   	$display("Warning: Set Value for EMASB doesn't match Default value 0 in %m at %0t", $time);
  end

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval===1'bx || bitval===1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction

  function isBit1;
    input bitval;
    begin
      isBit1 = ( bitval===1'b1 ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
	$readmemb(filename, memld);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {4{1'b1}};
        row_mask =  ( {3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1],
          3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
          3'b000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {4{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	XQA = 1'b0; QA_update = 1'b1;
   	$fdisplay(dump_file_desc, "%b", mem_path_A);
  end
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [7:0] load_addr;
	input [3:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
`endif
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {4{1'b1}};
        row_mask =  ( {3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1],
          3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
          3'b000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  endtask

task dumpaddr;
	output [3:0] dump_data;
	input [7:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [7:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {4{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	XQA = 1'b0; QA_update = 1'b1;
   	dump_data = mem_path_A;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask


  task readWriteA;
  begin
    if (GWENA_int !== 1'b1 && DFTRAMBYP_int=== 1'b0 && SEA_int === 1'bx) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (DFTRAMBYP_int=== 1'b0 && SEA_int === 1'b1) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int === 1'b0 && (CENA_int === 1'b0 || DFTRAMBYP_int === 1'b1)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(EMAA_int & isBit1(DFTRAMBYP_int)), (EMAWA_int & isBit1(DFTRAMBYP_int)), (EMASA_int & isBit1(DFTRAMBYP_int))} === 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if (^{(CENA_int & !isBit1(DFTRAMBYP_int)), EMAA_int, EMAWA_int, EMASA_int, RET1N_int} === 1'bx) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if ((AA_int >= WORDS) && (CENA_int === 1'b0) && DFTRAMBYP_int === 1'b0) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if (CENA_int === 1'b0 && (^AA_int) === 1'bx && DFTRAMBYP_int === 1'b0) begin
     if (GWENA_int !== 1)
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (CENA_int === 1'b0 || DFTRAMBYP_int === 1'b1) begin
      if(isBitX(DFTRAMBYP_int) || isBitX(SEA_int))
        DA_int = {4{1'bx}};

      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 63)
        row = {16{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENA_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {4{1'bx}};
        DA_int = {4{1'bx}};
      end else
          writeEnable = ~ ( {4{GWENA_int}} | {WENA_int[3], WENA_int[2], WENA_int[1],
          WENA_int[0]});
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1],
          3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DA_int[3], 3'b000, DA_int[2], 3'b000, DA_int[1], 3'b000, DA_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEA_int === 1'b0) begin
        end else if (GWENA_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEA_int === 1'bx) begin
        	XQA = 1'b1; QA_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[12], data_out[8], data_out[4], data_out[0]};
      end
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QA_update = 1'b1; DA_sh_update = 1'b1;
        end else begin
          XQA = 1'b0; QA_update = 1'b1; DA_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	XQA = 1'b0; QA_update = 1'b1;
      end
      if( isBitX(GWENA_int) && DFTRAMBYP_int !== 1'b1) begin
        XQA = 1'b1; QA_update = 1'b1;
      end
      if( isBitX(DFTRAMBYP_int) ) begin
        XQA = 1'b1; QA_update = 1'b1;
      end
      if( isBitX(SEA_int) && DFTRAMBYP_int === 1'b1 ) begin
        XQA = 1'b1; QA_update = 1'b1;
      end
    end
  end
  endtask
  always @ (CENA_ or TCENA_ or TENA_ or DFTRAMBYP_ or CLKA_) begin
  	if(CLKA_ == 1'b0) begin
  		CENA_p2 = CENA_;
  		TCENA_p2 = TCENA_;
  		DFTRAMBYP_p2 = DFTRAMBYP_;
  	end
  end

`ifdef POWER_PINS
  always @ (posedge VDDCE or negedge VDDCE) begin
      if (VDDCE != 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDCE should be powered down after VDDPE, Illegal power down sequencing in %m at %0t", $time);
       end
        $display("In PowerDown Mode in %m at %0t", $time);
        failedWrite(0);
      end
      if (VDDCE == 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDPE should be powered up after VDDCE in %m at %0t", $time);
        $display("Illegal power up sequencing in %m at %0t", $time);
       end
        failedWrite(0);
      end
  end
`endif
`ifdef POWER_PINS
  always @ (RET1N_ or VDDPE or VDDCE) begin
`else     
  always @ RET1N_ begin
`endif
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && RET1N_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_a == 1'b1 && (CENA_ === 1'bx || TCENA_ === 1'bx || DFTRAMBYP_ === 1'bx || CLKA_ === 1'bx)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`endif
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0 || DFTRAMBYP_p2 === 1'b1)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENA_p2 === 1'b0 || TCENA_p2 === 1'b0 || DFTRAMBYP_p2 === 1'b1)) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end
`ifdef POWER_PINS
    if (RET1N_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_a = 1;
      pre_charge_st = 1;
    end else if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (RET1N_ == 1'b0) begin
`endif
        XQA = 1'b1; QA_update = 1'b1;
      CENA_int = 1'bx;
      WENA_int = {4{1'bx}};
      AA_int = {8{1'bx}};
      DA_int = {4{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {4{1'bx}};
      TAA_int = {8{1'bx}};
      TDA_int = {4{1'bx}};
      GWENA_int = 1'bx;
      TGWENA_int = 1'bx;
      RET1N_int = 1'bx;
      SEA_int = 1'bx;
      DFTRAMBYP_int = 1'bx;
      COLLDISN_int = 1'bx;
`ifdef POWER_PINS
    end else if (RET1N_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_a == 1'b1) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
        XQA = 1'b1; QA_update = 1'b1;
      CENA_int = 1'bx;
      WENA_int = {4{1'bx}};
      AA_int = {8{1'bx}};
      DA_int = {4{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {4{1'bx}};
      TAA_int = {8{1'bx}};
      TDA_int = {4{1'bx}};
      GWENA_int = 1'bx;
      TGWENA_int = 1'bx;
      RET1N_int = 1'bx;
      SEA_int = 1'bx;
      DFTRAMBYP_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
    #0;
        QA_update = 1'b0;
  end


  always @ CLKA_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
`ifdef POWER_PINS
  if (RET1N_ == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((CLKA_ === 1'bx || CLKA_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if ((CLKA_ === 1'b1 || CLKA_ === 1'b0) && LAST_CLKA === 1'bx) begin
       DA_sh_update = 1'b0;  XDA_sh = 1'b0;
       XQA = 1'b0; QA_update = 1'b0; 
    end else if (CLKA_ === 1'b1 && LAST_CLKA === 1'b0) begin
      SEA_int = SEA_;
      DFTRAMBYP_int = DFTRAMBYP_;
      CENA_int = TENA_ ? CENA_ : TCENA_;
      EMAA_int = EMAA_;
      EMAWA_int = EMAWA_;
      EMASA_int = EMASA_;
      TENA_int = TENA_;
      TWENA_int = TWENA_;
      RET1N_int = RET1N_;
      COLLDISN_int = COLLDISN_;
      if (DFTRAMBYP_=== 1'b1 || CENA_int != 1'b1) begin
        WENA_int = TENA_ ? WENA_ : TWENA_;
        AA_int = TENA_ ? AA_ : TAA_;
        DA_int = TENA_ ? DA_ : TDA_;
        TCENA_int = TCENA_;
        TAA_int = TAA_;
        TDA_int = TDA_;
        GWENA_int = TENA_ ? GWENA_ : TGWENA_;
        TGWENA_int = TGWENA_;
        DFTRAMBYP_int = DFTRAMBYP_;
      end
      clk0_int = 1'b0;
      if (DFTRAMBYP_=== 1'b1 && SEA_ === 1'b1) begin
        XQA = 1'b0; QA_update = 1'b1;
      end else begin
      CENA_int = TENA_ ? CENA_ : TCENA_;
      EMAA_int = EMAA_;
      EMAWA_int = EMAWA_;
      EMASA_int = EMASA_;
      TENA_int = TENA_;
      TWENA_int = TWENA_;
      RET1N_int = RET1N_;
      COLLDISN_int = COLLDISN_;
      if (DFTRAMBYP_=== 1'b1 || CENA_int != 1'b1) begin
        WENA_int = TENA_ ? WENA_ : TWENA_;
        AA_int = TENA_ ? AA_ : TAA_;
        DA_int = TENA_ ? DA_ : TDA_;
        TCENA_int = TCENA_;
        TAA_int = TAA_;
        TDA_int = TDA_;
        GWENA_int = TENA_ ? GWENA_ : TGWENA_;
        TGWENA_int = TGWENA_;
        DFTRAMBYP_int = DFTRAMBYP_;
      end
      clk0_int = 1'b0;
      if (CENA_int === 1'b0) previous_CLKA = $realtime;
    readWriteA;
      end
    #0;
      if (((previous_CLKA == previous_CLKB)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1 && DFTRAMBYP_ !== 1'b1) && COLLDISN_int === 1'b1 && row_contention(AA_int,
        AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({4{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({4{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_B);
        #0;
        QB_update = 1'b0;
        #0;
        QB_update = 1'b1;
         end else begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQB = 1'b1; QB_update = 1'b1;
		end
         end
        end else if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_A);
        #0;
        QA_update = 1'b0;
        #0;
        QA_update = 1'b1;
         end else begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
		end
         end
        end else begin
          readWriteB;
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          readWriteB;
          readWriteA;
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1 && GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && !(GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
      end else if (((previous_CLKA == previous_CLKB)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1 && DFTRAMBYP_ !== 1'b1) && (COLLDISN_int === 1'b0 || COLLDISN_int 
       === 1'bx)  && row_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DB_int = {4{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        XQB = 1'b1; QB_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DA_int = {4{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        XQA = 1'b1; QA_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKA_ === 1'b0 && LAST_CLKA === 1'b1) begin
      partial_corrupt_A = 4'b0;
      QA_update = 1'b0;
      DA_sh_update = 1'b0;
      XQA = 1'b0;
    end
  end
    LAST_CLKA = CLKA_;
  end

  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if ((EMAA_int[0] === 1'bx & DFTRAMBYP_int === 1'b1) || (EMAA_int[1] === 1'bx & DFTRAMBYP_int === 1'b1) || 
      (EMAA_int[2] === 1'bx & DFTRAMBYP_int === 1'b1) || (EMASA_int === 1'bx & DFTRAMBYP_int === 1'b1) || 
      (EMAWA_int[0] === 1'bx & DFTRAMBYP_int === 1'b1) || (EMAWA_int[1] === 1'bx & DFTRAMBYP_int === 1'b1)
      ) begin
        XQA = 1'b1; QA_update = 1'b1;
    end else if ((CENA_int === 1'bx & DFTRAMBYP_int === 1'b0) || EMAA_int[0] === 1'bx || 
      EMAA_int[1] === 1'bx || EMAA_int[2] === 1'bx || EMASA_int === 1'bx || EMAWA_int[0] === 1'bx || 
      EMAWA_int[1] === 1'bx || RET1N_int === 1'bx || clk0_int === 1'bx) begin
        XQA = 1'b1; QA_update = 1'b1;
    if (clk0_int === 1'bx || CENA_int === 1'bx) begin
      DA_int = {4{1'bx}};
    end
      failedWrite(0);
    end else if (TENA_int === 1'bx) begin
      if(((CENA_ === 1'b1 & TCENA_ === 1'b1) & DFTRAMBYP_int === 1'b0) | (DFTRAMBYP_int === 1'b1 & SEA_int === 1'b1)) begin
      end else begin
        XQA = 1'b1; QA_update = 1'b1;
    if (clk0_int === 1'bx || CENA_int === 1'bx) begin
      DA_int = {4{1'bx}};
    end
      if (DFTRAMBYP_int === 1'b0) begin
          failedWrite(0);
      end
      end
    end else if (CENA_int === 1'b0 && (^AA_int) === 1'bx && DFTRAMBYP_int === 1'b0) begin
        failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if  (cont_flag0_int === 1'bx && COLLDISN_int === 1'b1 &&  (CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1) && DFTRAMBYP_ !== 1'b1) 
     && row_contention(TENB_ ? AB_ : TAB_, AA_int, ({4{GWENA_int}}|WENA_int), TENB_ ? ({4{GWENB_}}|WENB_) : ({4{TGWENB_}}|TWENB_))) begin
      cont_flag0_int = 1'b0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, write A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
     	WENA_int =  (({4{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
 		WENB_int =  (({4{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          partial_mask = ~{WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_B);
        #0;
        QB_update = 1'b0;
        #0;
        QB_update = 1'b1;
         end else begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQB = 1'b1; QB_update = 1'b1;
		end
         end
        end else if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          partial_mask = ~{WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_A);
        #0;
        QA_update = 1'b0;
        #0;
        QA_update = 1'b1;
         end else begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
		end
         end
        end else begin
          readWriteB;
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          readWriteB;
          readWriteA;
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1 && GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && !(GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
    end else if  ((CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1) && DFTRAMBYP_ !== 1'b1) && cont_flag0_int === 1'bx && (COLLDISN_int === 1'b0 
     || COLLDISN_int === 1'bx) && row_contention(TENB_ ? AB_ : TAB_, AA_int, ({4{GWENA_int}}|WENA_int), TENB_ ? ({4{GWENB_}}|WENB_) : ({4{TGWENB_}}|TWENB_))) 
     begin
      cont_flag0_int = 1'b0;
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DB_int = {4{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        XQB = 1'b1; QB_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DA_int = {4{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        XQA = 1'b1; QA_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
    end else begin
      #0;#0;
      readWriteA;
   end
      #0;#0;#0;
        XQA = 1'b0; QA_update = 1'b0;
    globalNotifier0 = 1'b0;
  end

  assign SIA_int = SEA_ ? SIA_ : {2{1'b0}};
  assign DA_int_bmux = TENA_ ? DA_ : TDA_;

  datapath_latch_arm28hkcpdpsram256x4m4 uDQA0 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[0]), .D(DA_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[0]), .XQ(XQA|partial_corrupt_A[0]), .Q(QA_int[0]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQA1 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[0]), .D(DA_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[1]), .XQ(XQA|partial_corrupt_A[1]), .Q(QA_int[1]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQA2 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[3]), .D(DA_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[2]), .XQ(XQA|partial_corrupt_A[2]), .Q(QA_int[2]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQA3 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[1]), .D(DA_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[3]), .XQ(XQA|partial_corrupt_A[3]), .Q(QA_int[3]));



  task readWriteB;
  begin
    if (GWENB_int !== 1'b1 && DFTRAMBYP_int=== 1'b0 && SEB_int === 1'bx) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (DFTRAMBYP_int=== 1'b0 && SEB_int === 1'b1) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (RET1N_int === 1'bx || RET1N_int === 1'bz) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (RET1N_int === 1'b0 && (CENB_int === 1'b0 || DFTRAMBYP_int === 1'b1)) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (RET1N_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(EMAB_int & isBit1(DFTRAMBYP_int)), (EMAWB_int & isBit1(DFTRAMBYP_int)), (EMASB_int & isBit1(DFTRAMBYP_int))} === 1'bx) begin
        XQB = 1'b1; QB_update = 1'b1;
    end else if (^{(CENB_int & !isBit1(DFTRAMBYP_int)), EMAB_int, EMAWB_int, EMASB_int, RET1N_int} === 1'bx) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if ((AB_int >= WORDS) && (CENB_int === 1'b0) && DFTRAMBYP_int === 1'b0) begin
        XQB = 1'b1; QB_update = 1'b1;
    end else if (CENB_int === 1'b0 && (^AB_int) === 1'bx && DFTRAMBYP_int === 1'b0) begin
     if (GWENB_int !== 1)
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (CENB_int === 1'b0 || DFTRAMBYP_int === 1'b1) begin
      if(isBitX(DFTRAMBYP_int) || isBitX(SEB_int))
        DB_int = {4{1'bx}};

      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 63)
        row = {16{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENB_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {4{1'bx}};
        DB_int = {4{1'bx}};
      end else
          writeEnable = ~ ( {4{GWENB_int}} | {WENB_int[3], WENB_int[2], WENB_int[1],
          WENB_int[0]});
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1],
          3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DB_int[3], 3'b000, DB_int[2], 3'b000, DB_int[1], 3'b000, DB_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEB_int === 1'b0) begin
        end else if (GWENB_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEB_int === 1'bx) begin
        	XQB = 1'b1; QB_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[12], data_out[8], data_out[4], data_out[0]};
      end
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QB_update = 1'b1; DB_sh_update = 1'b1;
        end else begin
          XQB = 1'b0; QB_update = 1'b1; DB_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch1 = readLatch1;
        mem_path_B = {shifted_readLatch1[3], shifted_readLatch1[2], shifted_readLatch1[1],
          shifted_readLatch1[0]};
        	XQB = 1'b0; QB_update = 1'b1;
      end
      if( isBitX(GWENB_int) && DFTRAMBYP_int !== 1'b1) begin
        XQB = 1'b1; QB_update = 1'b1;
      end
      if( isBitX(DFTRAMBYP_int) ) begin
        XQB = 1'b1; QB_update = 1'b1;
      end
      if( isBitX(SEB_int) && DFTRAMBYP_int === 1'b1 ) begin
        XQB = 1'b1; QB_update = 1'b1;
      end
    end
  end
  endtask
  always @ (CENB_ or TCENB_ or TENB_ or DFTRAMBYP_ or CLKB_) begin
  	if(CLKB_ == 1'b0) begin
  		CENB_p2 = CENB_;
  		TCENB_p2 = TCENB_;
  		DFTRAMBYP_p2 = DFTRAMBYP_;
  	end
  end

`ifdef POWER_PINS
  always @ (RET1N_ or VDDPE or VDDCE) begin
`else     
  always @ RET1N_ begin
`endif
`ifdef POWER_PINS
    if (RET1N_ == 1'b1 && RET1N_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_b == 1'b1 && (CENB_ === 1'bx || TCENB_ === 1'bx || DFTRAMBYP_ === 1'bx || CLKB_ === 1'bx)) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`endif
    if (RET1N_ === 1'bx || RET1N_ === 1'bz) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (RET1N_ === 1'b0 && RET1N_int === 1'b1 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0 || DFTRAMBYP_p2 === 1'b1)) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if (RET1N_ === 1'b1 && RET1N_int === 1'b0 && (CENB_p2 === 1'b0 || TCENB_p2 === 1'b0 || DFTRAMBYP_p2 === 1'b1)) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end
`ifdef POWER_PINS
    if (RET1N_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_b = 1;
      pre_charge_st = 1;
    end else if (RET1N_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(1);
      end
`else     
    if (RET1N_ == 1'b0) begin
`endif
        XQB = 1'b1; QB_update = 1'b1;
      CENB_int = 1'bx;
      WENB_int = {4{1'bx}};
      AB_int = {8{1'bx}};
      DB_int = {4{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {4{1'bx}};
      TAB_int = {8{1'bx}};
      TDB_int = {4{1'bx}};
      GWENB_int = 1'bx;
      TGWENB_int = 1'bx;
      RET1N_int = 1'bx;
      SEB_int = 1'bx;
      COLLDISN_int = 1'bx;
`ifdef POWER_PINS
    end else if (RET1N_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_b == 1'b1) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
        XQB = 1'b1; QB_update = 1'b1;
      CENB_int = 1'bx;
      WENB_int = {4{1'bx}};
      AB_int = {8{1'bx}};
      DB_int = {4{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {4{1'bx}};
      TAB_int = {8{1'bx}};
      TDB_int = {4{1'bx}};
      GWENB_int = 1'bx;
      TGWENB_int = 1'bx;
      RET1N_int = 1'bx;
      SEB_int = 1'bx;
      COLLDISN_int = 1'bx;
    end
    RET1N_int = RET1N_;
    #0;
        QB_update = 1'b0;
  end


  always @ CLKB_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
`ifdef POWER_PINS
  if (RET1N_ == 1'b0) begin
`else     
  if (RET1N_ == 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((CLKB_ === 1'bx || CLKB_ === 1'bz) && RET1N_ !== 1'b0) begin
      failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if ((CLKB_ === 1'b1 || CLKB_ === 1'b0) && LAST_CLKB === 1'bx) begin
       DB_sh_update = 1'b0;  XDB_sh = 1'b0;
       XQB = 1'b0; QB_update = 1'b0; 
    end else if (CLKB_ === 1'b1 && LAST_CLKB === 1'b0) begin
      DFTRAMBYP_int = DFTRAMBYP_;
      SEB_int = SEB_;
      CENB_int = TENB_ ? CENB_ : TCENB_;
      EMAB_int = EMAB_;
      EMAWB_int = EMAWB_;
      EMASB_int = EMASB_;
      TENB_int = TENB_;
      TWENB_int = TWENB_;
      RET1N_int = RET1N_;
      COLLDISN_int = COLLDISN_;
      if (DFTRAMBYP_=== 1'b1 || CENB_int != 1'b1) begin
        WENB_int = TENB_ ? WENB_ : TWENB_;
        AB_int = TENB_ ? AB_ : TAB_;
        DB_int = TENB_ ? DB_ : TDB_;
        TCENB_int = TCENB_;
        TAB_int = TAB_;
        TDB_int = TDB_;
        GWENB_int = TENB_ ? GWENB_ : TGWENB_;
        TGWENB_int = TGWENB_;
      end
      clk1_int = 1'b0;
      if (DFTRAMBYP_=== 1'b1 && SEB_ === 1'b1) begin
        XQB = 1'b0; QB_update = 1'b1;
      end else begin
      CENB_int = TENB_ ? CENB_ : TCENB_;
      EMAB_int = EMAB_;
      EMAWB_int = EMAWB_;
      EMASB_int = EMASB_;
      TENB_int = TENB_;
      TWENB_int = TWENB_;
      RET1N_int = RET1N_;
      COLLDISN_int = COLLDISN_;
      if (DFTRAMBYP_=== 1'b1 || CENB_int != 1'b1) begin
        WENB_int = TENB_ ? WENB_ : TWENB_;
        AB_int = TENB_ ? AB_ : TAB_;
        DB_int = TENB_ ? DB_ : TDB_;
        TCENB_int = TCENB_;
        TAB_int = TAB_;
        TDB_int = TDB_;
        GWENB_int = TENB_ ? GWENB_ : TGWENB_;
        TGWENB_int = TGWENB_;
      end
      clk1_int = 1'b0;
      if (CENB_int === 1'b0) previous_CLKB = $realtime;
    readWriteB;
      end
    #0;
      if (((previous_CLKA == previous_CLKB)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1 && DFTRAMBYP_ !== 1'b1) && COLLDISN_int === 1'b1 && row_contention(AA_int,
        AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({4{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({4{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_B);
        #0;
        QB_update = 1'b0;
        #0;
        QB_update = 1'b1;
         end else begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQB = 1'b1; QB_update = 1'b1;
		end
         end
        end else if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_A);
        #0;
        QA_update = 1'b0;
        #0;
        QA_update = 1'b1;
         end else begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
		end
         end
        end else begin
          readWriteA;
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          readWriteA;
          readWriteB;
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1 && GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && !(GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
      end else if (((previous_CLKA == previous_CLKB)) && (CENA_int !== 1'b1 && CENB_int !== 1'b1 && DFTRAMBYP_ !== 1'b1) && (COLLDISN_int === 1'b0 || COLLDISN_int 
       === 1'bx)  && row_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DA_int = {4{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        XQA = 1'b1; QA_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DB_int = {4{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        XQB = 1'b1; QB_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (CLKB_ === 1'b0 && LAST_CLKB === 1'b1) begin
      partial_corrupt_A = 4'b0;
      QB_update = 1'b0;
      DB_sh_update = 1'b0;
      XQB = 1'b0;
    end
  end
    LAST_CLKB = CLKB_;
  end

  reg globalNotifier1;
  initial globalNotifier1 = 1'b0;

  always @ globalNotifier1 begin
    if ($realtime == 0) begin
    end else if ((EMAB_int[0] === 1'bx & DFTRAMBYP_int === 1'b1) || (EMAB_int[1] === 1'bx & DFTRAMBYP_int === 1'b1) || 
      (EMAB_int[2] === 1'bx & DFTRAMBYP_int === 1'b1) || (EMASB_int === 1'bx & DFTRAMBYP_int === 1'b1) || 
      (EMAWB_int[0] === 1'bx & DFTRAMBYP_int === 1'b1) || (EMAWB_int[1] === 1'bx & DFTRAMBYP_int === 1'b1)
      ) begin
        XQB = 1'b1; QB_update = 1'b1;
    end else if ((CENB_int === 1'bx & DFTRAMBYP_int === 1'b0) || EMAB_int[0] === 1'bx || 
      EMAB_int[1] === 1'bx || EMAB_int[2] === 1'bx || EMASB_int === 1'bx || EMAWB_int[0] === 1'bx || 
      EMAWB_int[1] === 1'bx || RET1N_int === 1'bx || clk1_int === 1'bx) begin
        XQB = 1'b1; QB_update = 1'b1;
    if (clk1_int === 1'bx || CENB_int === 1'bx) begin
      DB_int = {4{1'bx}};
    end
      failedWrite(1);
    end else if (TENB_int === 1'bx) begin
      if(((CENB_ === 1'b1 & TCENB_ === 1'b1) & DFTRAMBYP_int === 1'b0) | (DFTRAMBYP_int === 1'b1 & SEB_int === 1'b1)) begin
      end else begin
        XQB = 1'b1; QB_update = 1'b1;
    if (clk1_int === 1'bx || CENB_int === 1'bx) begin
      DB_int = {4{1'bx}};
    end
      if (DFTRAMBYP_int === 1'b0) begin
          failedWrite(1);
      end
      end
    end else if (CENB_int === 1'b0 && (^AB_int) === 1'bx && DFTRAMBYP_int === 1'b0) begin
        failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if  (cont_flag1_int === 1'bx && COLLDISN_int === 1'b1 &&  (CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1) && DFTRAMBYP_ !== 1'b1) 
     && row_contention(TENA_ ? AA_ : TAA_, AB_int, ({4{GWENB_int}}|WENB_int), TENA_ ? ({4{GWENA_}}|WENA_) : ({4{TGWENA_}}|TWENA_))) begin
      cont_flag1_int = 1'b0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, write A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
     	WENA_int =  (({4{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({4{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
 		WENB_int =  (({4{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          partial_mask = ~{WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_B);
        #0;
        QB_update = 1'b0;
        #0;
        QB_update = 1'b1;
         end else begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQB = 1'b1; QB_update = 1'b1;
		end
         end
        end else if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          partial_mask = ~{WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {4{1'bx}}) | (~partial_mask & mem_path_A);
        #0;
        QA_update = 1'b0;
        #0;
        QA_update = 1'b1;
         end else begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        XQA = 1'b1; QA_update = 1'b1;
		end
         end
        end else begin
          readWriteA;
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          readWriteA;
          readWriteB;
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1 && GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) && !(GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
    end else if  ((CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1) && DFTRAMBYP_ !== 1'b1) && cont_flag1_int === 1'bx && (COLLDISN_int === 1'b0 
     || COLLDISN_int === 1'bx) && row_contention(TENA_ ? AA_ : TAA_, AB_int, ({4{GWENB_int}}|WENB_int), TENA_ ? ({4{GWENA_}}|WENA_) : ({4{TGWENA_}}|TWENA_))) 
     begin
      cont_flag1_int = 1'b0;
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
        if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          DA_int = {4{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        XQA = 1'b1; QA_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (GWENB_int !== 1'b1 && (& WENB_int) !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          DB_int = {4{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({4{GWENA_int}}|WENA_int), ({4{GWENB_int}}|WENB_int))) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        XQB = 1'b1; QB_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
    end else begin
      #0;#0;
      readWriteB;
   end
      #0;#0;#0;
        XQB = 1'b0; QB_update = 1'b0;
    globalNotifier1 = 1'b0;
  end

  assign SIB_int = SEB_ ? SIB_ : {2{1'b0}};
  assign DB_int_bmux = TENB_ ? DB_ : TDB_;

  datapath_latch_arm28hkcpdpsram256x4m4 uDQB0 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[0]), .D(DB_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[0]), .XQ(XQB|partial_corrupt_A[0]), .Q(QB_int[0]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQB1 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[0]), .D(DB_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[1]), .XQ(XQB|partial_corrupt_A[1]), .Q(QB_int[1]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQB2 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[3]), .D(DB_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[2]), .XQ(XQB|partial_corrupt_A[2]), .Q(QB_int[2]));
  datapath_latch_arm28hkcpdpsram256x4m4 uDQB3 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[1]), .D(DB_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[3]), .XQ(XQB|partial_corrupt_A[3]), .Q(QB_int[3]));


// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
 always @ (VDDCE or VDDPE or VSSE) begin
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
 end
`endif

  function row_contention;
    input [7:0] aa;
    input [7:0] ab;
    input [3:0] wena;
    input [3:0] wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) === 1'b1 && (& wenb) === 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[7:2] == ab[7:2]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [7:0] aa;
    input [7:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [7:0] aa;
    input [7:0] ab;
    input [3:0] wena;
    input [3:0] wenb;
    reg result;
  begin
    if ((& wena) === 1'b1 && (& wenb) === 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction

   wire contA_flag = (CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1)) && ((COLLDISN_int === 1'b1 && is_contention(TENB_ ? AB_ : TAB_, AA_int, TENB_ ? ({4{GWENB_}}|WENB_) : ({4{TGWENB_}}|TWENB_), ({4{GWENA_int}}|WENA_int))) ||
              ((COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENB_ ? AB_ : TAB_, AA_int, TENB_ ? ({4{GWENB_}}|WENB_) : ({4{TGWENB_}}|TWENB_), ({4{GWENA_int}}|WENA_int))));
   wire contB_flag = (CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1)) && ((COLLDISN_int === 1'b1 && is_contention(TENA_ ? AA_ : TAA_, AB_int, TENA_ ? ({4{GWENA_}}|WENA_) : ({4{TGWENA_}}|TWENA_), ({4{GWENB_int}}|WENB_int))) ||
              ((COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENA_ ? AA_ : TAA_, AB_int, TENA_ ? ({4{GWENA_}}|WENA_) : ({4{TGWENA_}}|TWENA_), ({4{GWENB_int}}|WENB_int))));

  always @ NOT_CENA begin
    CENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA3 begin
    WENA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA2 begin
    WENA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA1 begin
    WENA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA0 begin
    WENA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA7 begin
    AA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA6 begin
    AA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA5 begin
    AA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA4 begin
    AA_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA3 begin
    AA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA2 begin
    AA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA1 begin
    AA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_AA0 begin
    AA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA3 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA2 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA1 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA0 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CENB begin
    CENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB3 begin
    WENB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB2 begin
    WENB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB1 begin
    WENB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB0 begin
    WENB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB7 begin
    AB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB6 begin
    AB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB5 begin
    AB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB4 begin
    AB_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB3 begin
    AB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB2 begin
    AB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB1 begin
    AB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_AB0 begin
    AB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB3 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB2 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB1 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB0 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAA2 begin
    EMAA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAA1 begin
    EMAA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAA0 begin
    EMAA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAWA1 begin
    EMAWA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAWA0 begin
    EMAWA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMASA begin
    EMASA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMAB2 begin
    EMAB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAB1 begin
    EMAB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAB0 begin
    EMAB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAWB1 begin
    EMAWB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMAWB0 begin
    EMAWB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_EMASB begin
    EMASB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TENA begin
    TENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TCENA begin
    CENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA3 begin
    WENA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA2 begin
    WENA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA1 begin
    WENA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA0 begin
    WENA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA7 begin
    AA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA6 begin
    AA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA5 begin
    AA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA4 begin
    AA_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA3 begin
    AA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA2 begin
    AA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA1 begin
    AA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TAA0 begin
    AA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA3 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA2 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA1 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA0 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TENB begin
    TENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TCENB begin
    CENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB3 begin
    WENB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB2 begin
    WENB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB1 begin
    WENB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB0 begin
    WENB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB7 begin
    AB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB6 begin
    AB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB5 begin
    AB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB4 begin
    AB_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB3 begin
    AB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB2 begin
    AB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB1 begin
    AB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TAB0 begin
    AB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB3 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB2 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB1 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB0 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_GWENA begin
    GWENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_GWENB begin
    GWENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TGWENA begin
    GWENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TGWENB begin
    GWENB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_SIA1 begin
        XQA = 1'b1; QA_update = 1'b1;
  end
  always @ NOT_SIA0 begin
        XQA = 1'b1; QA_update = 1'b1;
  end
  always @ NOT_SEA begin
        XQA = 1'b1; QA_update = 1'b1;
    SEA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DFTRAMBYP_CLKB begin
    DFTRAMBYP_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DFTRAMBYP_CLKA begin
    DFTRAMBYP_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_RET1N begin
    RET1N_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_SIB1 begin
        XQB = 1'b1; QB_update = 1'b1;
  end
  always @ NOT_SIB0 begin
        XQB = 1'b1; QB_update = 1'b1;
  end
  always @ NOT_SEB begin
        XQB = 1'b1; QB_update = 1'b1;
    SEB_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_COLLDISN begin
    COLLDISN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end

  always @ NOT_CLKA_PER begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_MINH begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKA_MINL begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CONTA begin
    cont_flag0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLKB_PER begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_MINH begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CLKB_MINL begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CONTB begin
    cont_flag1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end


  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1;
  wire contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA3eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA2eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA1eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA0eq0aGWENAeq0cpcp;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq0;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq1;
  wire RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1;
  wire contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB3eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB2eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB1eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB0eq0aGWENBeq0cpcp;
  wire RET1Neq1aopopopTENAeq1aCENAeq0aDFTRAMBYPeq0cpoopTENAeq0aTCENAeq0aDFTRAMBYPeq0cpcpoDFTRAMBYPeq1cp;
  wire RET1Neq1aopopopTENBeq1aCENBeq0aDFTRAMBYPeq0cpoopTENBeq0aTCENBeq0aDFTRAMBYPeq0cpcpoDFTRAMBYPeq1cp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA3eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA2eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA1eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA0eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB3eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB2eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB1eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB0eq0aTGWENBeq0cpcp;

  wire RET1Neq1aTENAeq1, RET1Neq1aTENAeq1aCENAeq0aCOLLDISNeq0, RET1Neq1aTENAeq1aCENAeq0aCOLLDISNeq1;
  wire RET1Neq1aTENBeq1, RET1Neq1aTENBeq1aCENBeq0aCOLLDISNeq0, RET1Neq1aTENBeq1aCENBeq0aCOLLDISNeq1;
  wire RET1Neq1aTENAeq0, RET1Neq1aTENAeq0aTCENAeq0aCOLLDISNeq0, RET1Neq1aTENAeq0aTCENAeq0aCOLLDISNeq1;
  wire RET1Neq1aTENBeq0, RET1Neq1aTENBeq0aTCENBeq0aCOLLDISNeq0, RET1Neq1aTENBeq0aTCENBeq0aCOLLDISNeq1;
  wire RET1Neq1aTENAeq1aCENAeq0, RET1Neq1aTENBeq1aCENBeq0, RET1Neq1aTENAeq0aTCENAeq0;
  wire RET1Neq1aTENBeq0aTCENBeq0, RET1Neq1aSEAeq1, RET1Neq1aSEBeq1, RET1Neq1, RET1Neq1aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcp;
  wire RET1Neq1aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcp;

  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0]&&!EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0]&&EMASA;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcpcpoDFTRAMBYPeq1cpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1aEMASAeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENA&&!CENA)||(!TENA&&!TCENA)))||DFTRAMBYP)&&EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0]&&EMASA;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&GWENA)||(!TENA&&!TCENA&&TGWENA))&&!EMAA[2]&&!EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&GWENA)||(!TENA&&!TCENA&&TGWENA))&&!EMAA[2]&&!EMAA[1]&&EMAA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&GWENA)||(!TENA&&!TCENA&&TGWENA))&&!EMAA[2]&&EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&GWENA)||(!TENA&&!TCENA&&TGWENA))&&!EMAA[2]&&EMAA[1]&&EMAA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&GWENA)||(!TENA&&!TCENA&&TGWENA))&&EMAA[2]&&!EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&GWENA)||(!TENA&&!TCENA&&TGWENA))&&EMAA[2]&&!EMAA[1]&&EMAA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&GWENA)||(!TENA&&!TCENA&&TGWENA))&&EMAA[2]&&EMAA[1]&&!EMAA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq1cpoopTENAeq0aTCENAeq0aTGWENAeq1cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&GWENA)||(!TENA&&!TCENA&&TGWENA))&&EMAA[2]&&EMAA[1]&&EMAA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq0aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq0aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq0aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&!EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq0aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&EMAA[1]&&EMAA[0]&&!EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&!EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq0aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&!EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq0aEMAWA1eq1aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&!EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq0aEMAA0eq1aEMAWA1eq1aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&!EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq0aEMAWA1eq1aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&EMAA[1]&&!EMAA[0]&&EMAWA[1]&&EMAWA[0] && contA_flag;
  assign contA_RET1Neq1aDFTRAMBYPeq0aopopTENAeq1aCENAeq0aGWENAeq0cpoopTENAeq0aTCENAeq0aTGWENAeq0cpcpaEMAA2eq1aEMAA1eq1aEMAA0eq1aEMAWA1eq1aEMAWA0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENA&&!CENA&&!GWENA)||(!TENA&&!TCENA&&!TGWENA))&&EMAA[2]&&EMAA[1]&&EMAA[0]&&EMAWA[1]&&EMAWA[0] && contA_flag;
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA3eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[3]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA2eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[2]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA1eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[1]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA0eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[0]&&!GWENA));
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq0 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0]&&!EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0]&&EMASB;
  assign RET1Neq1aopopDFTRAMBYPeq0aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcpcpoDFTRAMBYPeq1cpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1aEMASBeq1 = 
  RET1N&&((!DFTRAMBYP&&((TENB&&!CENB)||(!TENB&&!TCENB)))||DFTRAMBYP)&&EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0]&&EMASB;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&GWENB)||(!TENB&&!TCENB&&TGWENB))&&!EMAB[2]&&!EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&GWENB)||(!TENB&&!TCENB&&TGWENB))&&!EMAB[2]&&!EMAB[1]&&EMAB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&GWENB)||(!TENB&&!TCENB&&TGWENB))&&!EMAB[2]&&EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&GWENB)||(!TENB&&!TCENB&&TGWENB))&&!EMAB[2]&&EMAB[1]&&EMAB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&GWENB)||(!TENB&&!TCENB&&TGWENB))&&EMAB[2]&&!EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&GWENB)||(!TENB&&!TCENB&&TGWENB))&&EMAB[2]&&!EMAB[1]&&EMAB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&GWENB)||(!TENB&&!TCENB&&TGWENB))&&EMAB[2]&&EMAB[1]&&!EMAB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq1cpoopTENBeq0aTCENBeq0aTGWENBeq1cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&GWENB)||(!TENB&&!TCENB&&TGWENB))&&EMAB[2]&&EMAB[1]&&EMAB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq0aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq0aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq0aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&!EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq0aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&EMAB[1]&&EMAB[0]&&!EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq0 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&!EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq0aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&!EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq0aEMAWB1eq1aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&!EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq0aEMAB0eq1aEMAWB1eq1aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&!EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq0aEMAWB1eq1aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&EMAB[1]&&!EMAB[0]&&EMAWB[1]&&EMAWB[0] && contB_flag;
  assign contB_RET1Neq1aDFTRAMBYPeq0aopopTENBeq1aCENBeq0aGWENBeq0cpoopTENBeq0aTCENBeq0aTGWENBeq0cpcpaEMAB2eq1aEMAB1eq1aEMAB0eq1aEMAWB1eq1aEMAWB0eq1 = 
  RET1N&&!DFTRAMBYP&&((TENB&&!CENB&&!GWENB)||(!TENB&&!TCENB&&!TGWENB))&&EMAB[2]&&EMAB[1]&&EMAB[0]&&EMAWB[1]&&EMAWB[0] && contB_flag;
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB3eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[3]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB2eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[2]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB1eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[1]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB0eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[0]&&!GWENB));
  assign RET1Neq1aopopopTENAeq1aCENAeq0aDFTRAMBYPeq0cpoopTENAeq0aTCENAeq0aDFTRAMBYPeq0cpcpoDFTRAMBYPeq1cp = 
  RET1N&&(((TENA&&!CENA&&!DFTRAMBYP)||(!TENA&&!TCENA&&!DFTRAMBYP))||DFTRAMBYP);
  assign RET1Neq1aopopopTENBeq1aCENBeq0aDFTRAMBYPeq0cpoopTENBeq0aTCENBeq0aDFTRAMBYPeq0cpcpoDFTRAMBYPeq1cp = 
  RET1N&&(((TENB&&!CENB&&!DFTRAMBYP)||(!TENB&&!TCENB&&!DFTRAMBYP))||DFTRAMBYP);
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA3eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[3]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA2eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[2]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA1eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[1]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA0eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[0]&&!TGWENA));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB3eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[3]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB2eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[2]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB1eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[1]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB0eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[0]&&!TGWENB));

  assign RET1Neq1aTENAeq1aCENAeq0aCOLLDISNeq0 = RET1N&&TENA&&!CENA&&!COLLDISN;
  assign RET1Neq1aTENAeq1aCENAeq0aCOLLDISNeq1 = RET1N&&TENA&&!CENA&&COLLDISN;
  assign RET1Neq1aTENBeq1aCENBeq0aCOLLDISNeq0 = RET1N&&TENB&&!CENB&&!COLLDISN;
  assign RET1Neq1aTENBeq1aCENBeq0aCOLLDISNeq1 = RET1N&&TENB&&!CENB&&COLLDISN;
  assign RET1Neq1aTENAeq0aTCENAeq0aCOLLDISNeq0 = RET1N&&!TENA&&!TCENA&&!COLLDISN;
  assign RET1Neq1aTENAeq0aTCENAeq0aCOLLDISNeq1 = RET1N&&!TENA&&!TCENA&&COLLDISN;
  assign RET1Neq1aTENBeq0aTCENBeq0aCOLLDISNeq0 = RET1N&&!TENB&&!TCENB&&!COLLDISN;
  assign RET1Neq1aTENBeq0aTCENBeq0aCOLLDISNeq1 = RET1N&&!TENB&&!TCENB&&COLLDISN;
  assign RET1Neq1aopopTENAeq1aCENAeq0cpoopTENAeq0aTCENAeq0cpcp = RET1N&&((TENA&&!CENA)||(!TENA&&!TCENA));
  assign RET1Neq1aopopTENBeq1aCENBeq0cpoopTENBeq0aTCENBeq0cpcp = RET1N&&((TENB&&!CENB)||(!TENB&&!TCENB));

  assign RET1Neq1aTENAeq1aCENAeq0 = RET1N&&TENA&&!CENA;
  assign RET1Neq1aTENBeq1aCENBeq0 = RET1N&&TENB&&!CENB;
  assign RET1Neq1aTENAeq0aTCENAeq0 = RET1N&&!TENA&&!TCENA;
  assign RET1Neq1aTENBeq0aTCENBeq0 = RET1N&&!TENB&&!TCENB;

  assign RET1Neq1aTENAeq1 = RET1N&&TENA;
  assign RET1Neq1aTENBeq1 = RET1N&&TENB;
  assign RET1Neq1aTENAeq0 = RET1N&&!TENA;
  assign RET1Neq1aTENBeq0 = RET1N&&!TENB;
  assign RET1Neq1aSEAeq1 = RET1N&&SEA;
  assign RET1Neq1aSEBeq1 = RET1N&&SEB;
  assign RET1Neq1 = RET1N;endmodule
`endcelldefine
`endif
`timescale 1ns/1ps
module arm28hkcpdpsram256x4m4_error_injection (Q_out, Q_in, CLK, A, CEN, DFTRAMBYP, SE, WEN, GWEN);
   output [3:0] Q_out;
   input [3:0] Q_in;
   input CLK;
   input [7:0] A;
   input CEN;
   input DFTRAMBYP;
   input SE;
   input [3:0] WEN;
   input GWEN;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter NO_RED_FAULT = 2'd0;
   reg [3:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [14:0] fault_table [63:0];
   reg [14:0] fault_entry;
initial
begin
   `ifdef DUT
      `define pre_pend_path TB.DUT_inst.CHIP
   `else
       `define pre_pend_path TB.CHIP
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST.u1.add_fault(8'd163,2'd2,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
      input [7:0] address;
      input [1:0] bitPlace;
      input [1:0] fault_type;
      input [1:0] red_fault;
 
      integer i;
      reg done;
   begin
      done = 1'b0;
      i = 0;
      while ((!done) && i < 63)
      begin
         fault_entry = fault_table[i];
         if (fault_entry[0] === 1'b0 || fault_entry[0] === 1'bx)
         begin
            fault_entry[0] = 1'b1;
            fault_entry[2:1] = red_fault;
            fault_entry[4:3] = fault_type;
            fault_entry[6:5] = bitPlace;
            fault_entry[14:7] = address;
            fault_table[i] = fault_entry;
            done = 1'b1;
         end
         i = i+1;
      end
   end
   endtask
//This task removes all fault entries injected by user
task remove_all_faults;
   integer i;
begin
   for (i = 0; i < 64; i=i+1)
   begin
      fault_entry = fault_table[i];
      fault_entry[0] = 1'b0;
      fault_table[i] = fault_entry;
   end
end
endtask
task bit_error;
// This task is used to inject error in memory and should be called
// only from current module.
//
// This task injects error depending upon fault type to particular bit
// of the output
   inout [3:0] q_int;
   input [1:0] fault_type;
   input [1:0] bitLoc;
begin
   if (fault_type === 2'd0)
      q_int[bitLoc] = 1'b0;
   else if (fault_type === 2'd1)
      q_int[bitLoc] = 1'b1;
   else
      q_int[bitLoc] = ~q_int[bitLoc];
end
endtask
task error_injection_on_output;
// This function goes through error injection table for every
// read cycle and corrupts Q output if fault for the particular
// address is present in fault table
//
// If fault is redundant column is detected, this task corrupts
// Q output in read cycle
//
// If fault is repaired using repair bus, this task does not
// courrpt Q output in read cycle
//
   output [3:0] Q_output;
   reg list_complete;
   integer i;
   reg [5:0] row_address;
   reg [1:0] column_address;
   reg [1:0] bitPlace;
   reg [1:0] fault_type;
   reg [1:0] red_fault;
   reg valid;
   reg [0:0] msb_bit_calc;
begin
   entry_found = 1'b0;
   list_complete = 1'b0;
   i = 0;
   Q_output = Q_in;
   while(!list_complete)
   begin
      fault_entry = fault_table[i];
      {row_address, column_address, bitPlace, fault_type, red_fault, valid} = fault_entry;
      i = i + 1;
      if (valid == 1'b1)
      begin
         if (red_fault === NO_RED_FAULT)
         begin
            if (row_address == A[7:2] && column_address == A[1:0])
            begin
               if (bitPlace < 2)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 2 )
                  bit_error(Q_output,fault_type, bitPlace);
            end
         end
      end
      else
         list_complete = 1'b1;
      end
   end
   endtask
   always @ (Q_in or CLK or A or CEN or WEN or GWEN)
   begin
   if (CEN === 1'b0 && DFTRAMBYP === 1'b0 && SE === 1'b0)
      error_injection_on_output(Q_out);
   else
      Q_out = Q_in;
   end
endmodule

//==================================================================//
`endif // vcs
//======= auto generated ============//
