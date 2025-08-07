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
//       Instance Name:              arm28hkcpdpsram128x14m4
//       Words:                      128
//       Bits:                       14
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
//       Creation Date:  Tue Jul 15 12:09:44 2025
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

module datapath_latch_arm28hkcpdpsram128x14m4 (CLK,Q_update,D_update,SE,SI,D,DFTRAMBYP,mem_path,XQ,Q);
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
endmodule // datapath_latch_arm28hkcpdpsram128x14m4

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
module arm28hkcpdpsram128x14m4 (VDDCE, VDDPE, VSSE, CENYA, WENYA, AYA, CENYB, WENYB,
    AYB, GWENYA, GWENYB, QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB,
    AB, DB, EMAA, EMAWA, EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB,
    TCENB, TWENB, TAB, TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP,
    SIB, SEB, COLLDISN);
`else
module arm28hkcpdpsram128x14m4 (CENYA, WENYA, AYA, CENYB, WENYB, AYB, GWENYA, GWENYB,
    QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA,
    EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB, TCENB, TWENB, TAB,
    TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP, SIB, SEB, COLLDISN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 14;
  parameter WORDS = 128;
  parameter MUX = 4;
  parameter MEM_WIDTH = 56; // redun block size 4, 28 on left, 28 on right
  parameter MEM_HEIGHT = 32;
  parameter WP_SIZE = 1 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENYA;
  output [13:0] WENYA;
  output [6:0] AYA;
  output  CENYB;
  output [13:0] WENYB;
  output [6:0] AYB;
  output  GWENYA;
  output  GWENYB;
  output [13:0] QA;
  output [13:0] QB;
  output [1:0] SOA;
  output [1:0] SOB;
  input  CLKA;
  input  CENA;
  input [13:0] WENA;
  input [6:0] AA;
  input [13:0] DA;
  input  CLKB;
  input  CENB;
  input [13:0] WENB;
  input [6:0] AB;
  input [13:0] DB;
  input [2:0] EMAA;
  input [1:0] EMAWA;
  input  EMASA;
  input [2:0] EMAB;
  input [1:0] EMAWB;
  input  EMASB;
  input  TENA;
  input  TCENA;
  input [13:0] TWENA;
  input [6:0] TAA;
  input [13:0] TDA;
  input  TENB;
  input  TCENB;
  input [13:0] TWENB;
  input [6:0] TAB;
  input [13:0] TDB;
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
  reg [55:0] mem [0:31];
  reg [55:0] row, row_t;
  reg LAST_CLKA;
  reg [55:0] row_mask;
  reg [55:0] new_data;
  reg [55:0] data_out;
  reg [13:0] readLatch0;
  reg [13:0] shifted_readLatch0;
  reg  read_mux_sel0_p2;
  reg [13:0] readLatch1;
  reg [13:0] shifted_readLatch1;
  reg  read_mux_sel1_p2;
  reg LAST_CLKB;
  wire [13:0] QA_int;
  reg XQA, QA_update;
  reg XDA_sh, DA_sh_update;
  wire [13:0] DA_int_bmux;
  reg [13:0] mem_path_A;
  reg [13:0] partial_mask;
  reg [13:0] partial_mask_A;
  reg [13:0] partial_corrupt_A = 14'b0;
  wire [13:0] QB_int;
  reg XQB, QB_update;
  reg XDB_sh, DB_sh_update;
  wire [13:0] DB_int_bmux;
  reg [13:0] mem_path_B;
  reg [13:0] partial_mask_B;
  reg [13:0] partial_corrupt_B = 14'b0;
  reg [13:0] writeEnable;
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
  wire [13:0] WENYA_;
  wire [6:0] AYA_;
  wire  CENYB_;
  wire [13:0] WENYB_;
  wire [6:0] AYB_;
  wire  GWENYA_;
  wire  GWENYB_;
  wire [13:0] QA_;
  wire [13:0] QB_;
  wire [1:0] SOA_;
  wire [1:0] SOB_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire [13:0] WENA_;
  reg [13:0] WENA_int;
  wire [6:0] AA_;
  reg [6:0] AA_int;
  wire [13:0] DA_;
  reg [13:0] DA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire [13:0] WENB_;
  reg [13:0] WENB_int;
  wire [6:0] AB_;
  reg [6:0] AB_int;
  wire [13:0] DB_;
  reg [13:0] DB_int;
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
  wire [13:0] TWENA_;
  reg [13:0] TWENA_int;
  wire [6:0] TAA_;
  reg [6:0] TAA_int;
  wire [13:0] TDA_;
  reg [13:0] TDA_int;
  wire  TENB_;
  reg  TENB_int;
  wire  TCENB_;
  reg  TCENB_int;
  reg  TCENB_p2;
  wire [13:0] TWENB_;
  reg [13:0] TWENB_int;
  wire [6:0] TAB_;
  reg [6:0] TAB_int;
  wire [13:0] TDB_;
  reg [13:0] TDB_int;
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
  assign WENYA[4] = WENYA_[4]; 
  assign WENYA[5] = WENYA_[5]; 
  assign WENYA[6] = WENYA_[6]; 
  assign WENYA[7] = WENYA_[7]; 
  assign WENYA[8] = WENYA_[8]; 
  assign WENYA[9] = WENYA_[9]; 
  assign WENYA[10] = WENYA_[10]; 
  assign WENYA[11] = WENYA_[11]; 
  assign WENYA[12] = WENYA_[12]; 
  assign WENYA[13] = WENYA_[13]; 
  assign AYA[0] = AYA_[0]; 
  assign AYA[1] = AYA_[1]; 
  assign AYA[2] = AYA_[2]; 
  assign AYA[3] = AYA_[3]; 
  assign AYA[4] = AYA_[4]; 
  assign AYA[5] = AYA_[5]; 
  assign AYA[6] = AYA_[6]; 
  assign CENYB = CENYB_; 
  assign WENYB[0] = WENYB_[0]; 
  assign WENYB[1] = WENYB_[1]; 
  assign WENYB[2] = WENYB_[2]; 
  assign WENYB[3] = WENYB_[3]; 
  assign WENYB[4] = WENYB_[4]; 
  assign WENYB[5] = WENYB_[5]; 
  assign WENYB[6] = WENYB_[6]; 
  assign WENYB[7] = WENYB_[7]; 
  assign WENYB[8] = WENYB_[8]; 
  assign WENYB[9] = WENYB_[9]; 
  assign WENYB[10] = WENYB_[10]; 
  assign WENYB[11] = WENYB_[11]; 
  assign WENYB[12] = WENYB_[12]; 
  assign WENYB[13] = WENYB_[13]; 
  assign AYB[0] = AYB_[0]; 
  assign AYB[1] = AYB_[1]; 
  assign AYB[2] = AYB_[2]; 
  assign AYB[3] = AYB_[3]; 
  assign AYB[4] = AYB_[4]; 
  assign AYB[5] = AYB_[5]; 
  assign AYB[6] = AYB_[6]; 
  assign GWENYA = GWENYA_; 
  assign GWENYB = GWENYB_; 
  assign QA[0] = QA_[0]; 
  assign QA[1] = QA_[1]; 
  assign QA[2] = QA_[2]; 
  assign QA[3] = QA_[3]; 
  assign QA[4] = QA_[4]; 
  assign QA[5] = QA_[5]; 
  assign QA[6] = QA_[6]; 
  assign QA[7] = QA_[7]; 
  assign QA[8] = QA_[8]; 
  assign QA[9] = QA_[9]; 
  assign QA[10] = QA_[10]; 
  assign QA[11] = QA_[11]; 
  assign QA[12] = QA_[12]; 
  assign QA[13] = QA_[13]; 
  assign QB[0] = QB_[0]; 
  assign QB[1] = QB_[1]; 
  assign QB[2] = QB_[2]; 
  assign QB[3] = QB_[3]; 
  assign QB[4] = QB_[4]; 
  assign QB[5] = QB_[5]; 
  assign QB[6] = QB_[6]; 
  assign QB[7] = QB_[7]; 
  assign QB[8] = QB_[8]; 
  assign QB[9] = QB_[9]; 
  assign QB[10] = QB_[10]; 
  assign QB[11] = QB_[11]; 
  assign QB[12] = QB_[12]; 
  assign QB[13] = QB_[13]; 
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
  assign WENA_[4] = WENA[4];
  assign WENA_[5] = WENA[5];
  assign WENA_[6] = WENA[6];
  assign WENA_[7] = WENA[7];
  assign WENA_[8] = WENA[8];
  assign WENA_[9] = WENA[9];
  assign WENA_[10] = WENA[10];
  assign WENA_[11] = WENA[11];
  assign WENA_[12] = WENA[12];
  assign WENA_[13] = WENA[13];
  assign AA_[0] = AA[0];
  assign AA_[1] = AA[1];
  assign AA_[2] = AA[2];
  assign AA_[3] = AA[3];
  assign AA_[4] = AA[4];
  assign AA_[5] = AA[5];
  assign AA_[6] = AA[6];
  assign DA_[0] = DA[0];
  assign DA_[1] = DA[1];
  assign DA_[2] = DA[2];
  assign DA_[3] = DA[3];
  assign DA_[4] = DA[4];
  assign DA_[5] = DA[5];
  assign DA_[6] = DA[6];
  assign DA_[7] = DA[7];
  assign DA_[8] = DA[8];
  assign DA_[9] = DA[9];
  assign DA_[10] = DA[10];
  assign DA_[11] = DA[11];
  assign DA_[12] = DA[12];
  assign DA_[13] = DA[13];
  assign CLKB_ = CLKB;
  assign CENB_ = CENB;
  assign WENB_[0] = WENB[0];
  assign WENB_[1] = WENB[1];
  assign WENB_[2] = WENB[2];
  assign WENB_[3] = WENB[3];
  assign WENB_[4] = WENB[4];
  assign WENB_[5] = WENB[5];
  assign WENB_[6] = WENB[6];
  assign WENB_[7] = WENB[7];
  assign WENB_[8] = WENB[8];
  assign WENB_[9] = WENB[9];
  assign WENB_[10] = WENB[10];
  assign WENB_[11] = WENB[11];
  assign WENB_[12] = WENB[12];
  assign WENB_[13] = WENB[13];
  assign AB_[0] = AB[0];
  assign AB_[1] = AB[1];
  assign AB_[2] = AB[2];
  assign AB_[3] = AB[3];
  assign AB_[4] = AB[4];
  assign AB_[5] = AB[5];
  assign AB_[6] = AB[6];
  assign DB_[0] = DB[0];
  assign DB_[1] = DB[1];
  assign DB_[2] = DB[2];
  assign DB_[3] = DB[3];
  assign DB_[4] = DB[4];
  assign DB_[5] = DB[5];
  assign DB_[6] = DB[6];
  assign DB_[7] = DB[7];
  assign DB_[8] = DB[8];
  assign DB_[9] = DB[9];
  assign DB_[10] = DB[10];
  assign DB_[11] = DB[11];
  assign DB_[12] = DB[12];
  assign DB_[13] = DB[13];
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
  assign TWENA_[4] = TWENA[4];
  assign TWENA_[5] = TWENA[5];
  assign TWENA_[6] = TWENA[6];
  assign TWENA_[7] = TWENA[7];
  assign TWENA_[8] = TWENA[8];
  assign TWENA_[9] = TWENA[9];
  assign TWENA_[10] = TWENA[10];
  assign TWENA_[11] = TWENA[11];
  assign TWENA_[12] = TWENA[12];
  assign TWENA_[13] = TWENA[13];
  assign TAA_[0] = TAA[0];
  assign TAA_[1] = TAA[1];
  assign TAA_[2] = TAA[2];
  assign TAA_[3] = TAA[3];
  assign TAA_[4] = TAA[4];
  assign TAA_[5] = TAA[5];
  assign TAA_[6] = TAA[6];
  assign TDA_[0] = TDA[0];
  assign TDA_[1] = TDA[1];
  assign TDA_[2] = TDA[2];
  assign TDA_[3] = TDA[3];
  assign TDA_[4] = TDA[4];
  assign TDA_[5] = TDA[5];
  assign TDA_[6] = TDA[6];
  assign TDA_[7] = TDA[7];
  assign TDA_[8] = TDA[8];
  assign TDA_[9] = TDA[9];
  assign TDA_[10] = TDA[10];
  assign TDA_[11] = TDA[11];
  assign TDA_[12] = TDA[12];
  assign TDA_[13] = TDA[13];
  assign TENB_ = TENB;
  assign TCENB_ = TCENB;
  assign TWENB_[0] = TWENB[0];
  assign TWENB_[1] = TWENB[1];
  assign TWENB_[2] = TWENB[2];
  assign TWENB_[3] = TWENB[3];
  assign TWENB_[4] = TWENB[4];
  assign TWENB_[5] = TWENB[5];
  assign TWENB_[6] = TWENB[6];
  assign TWENB_[7] = TWENB[7];
  assign TWENB_[8] = TWENB[8];
  assign TWENB_[9] = TWENB[9];
  assign TWENB_[10] = TWENB[10];
  assign TWENB_[11] = TWENB[11];
  assign TWENB_[12] = TWENB[12];
  assign TWENB_[13] = TWENB[13];
  assign TAB_[0] = TAB[0];
  assign TAB_[1] = TAB[1];
  assign TAB_[2] = TAB[2];
  assign TAB_[3] = TAB[3];
  assign TAB_[4] = TAB[4];
  assign TAB_[5] = TAB[5];
  assign TAB_[6] = TAB[6];
  assign TDB_[0] = TDB[0];
  assign TDB_[1] = TDB[1];
  assign TDB_[2] = TDB[2];
  assign TDB_[3] = TDB[3];
  assign TDB_[4] = TDB[4];
  assign TDB_[5] = TDB[5];
  assign TDB_[6] = TDB[6];
  assign TDB_[7] = TDB[7];
  assign TDB_[8] = TDB[8];
  assign TDB_[9] = TDB[9];
  assign TDB_[10] = TDB[10];
  assign TDB_[11] = TDB[11];
  assign TDB_[12] = TDB[12];
  assign TDB_[13] = TDB[13];
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
  assign `ARM_UD_DP WENYA_ = (RET1N_ | pre_charge_st) ? ({14{DFTRAMBYP_}} & (TENA_ ? WENA_ : TWENA_)) : {14{1'bx}};
  assign `ARM_UD_DP AYA_ = (RET1N_ | pre_charge_st) ? ({7{DFTRAMBYP_}} & (TENA_ ? AA_ : TAA_)) : {7{1'bx}};
  assign `ARM_UD_DP CENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? CENB_ : TCENB_)) : 1'bx;
  assign `ARM_UD_DP WENYB_ = (RET1N_ | pre_charge_st) ? ({14{DFTRAMBYP_}} & (TENB_ ? WENB_ : TWENB_)) : {14{1'bx}};
  assign `ARM_UD_DP AYB_ = (RET1N_ | pre_charge_st) ? ({7{DFTRAMBYP_}} & (TENB_ ? AB_ : TAB_)) : {7{1'bx}};
  assign `ARM_UD_DP GWENYA_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENA_ ? GWENA_ : TGWENA_)) : 1'bx;
  assign `ARM_UD_DP GWENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? GWENB_ : TGWENB_)) : 1'bx;
   `ifdef ARM_FAULT_MODELING
     arm28hkcpdpsram128x14m4_error_injection u1(.CLK(CLKA_), .Q_out(QA_), .A(AA_int), .CEN(CENA_int), .DFTRAMBYP(DFTRAMBYP_int), .SE(SEA_int), .GWEN(GWENA_int), .WEN(WENA_int), .Q_in(QA_int));
  `else
  assign `ARM_UD_SEQ QA_ = (RET1N_ | pre_charge_st) ? ((QA_int)) : {14{1'bx}};
  `endif
  assign `ARM_UD_SEQ QB_ = (RET1N_ | pre_charge_st) ? ((QB_int)) : {14{1'bx}};
  assign `ARM_UD_DP SOA_ = (RET1N_ | pre_charge_st) ? ({QA_[7], QA_[6]}) : {2{1'bx}};
  assign `ARM_UD_DP SOB_ = (RET1N_ | pre_charge_st) ? ({QB_[7], QB_[6]}) : {2{1'bx}};

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
	reg [6:0] Atemp;
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
        writeEnable = {14{1'b1}};
        row_mask =  ( {3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[13], 3'b000, wordtemp[12], 3'b000, wordtemp[11],
          3'b000, wordtemp[10], 3'b000, wordtemp[9], 3'b000, wordtemp[8], 3'b000, wordtemp[7],
          3'b000, wordtemp[6], 3'b000, wordtemp[5], 3'b000, wordtemp[4], 3'b000, wordtemp[3],
          3'b000, wordtemp[2], 3'b000, wordtemp[1], 3'b000, wordtemp[0]} << mux_address);
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
	reg [6:0] Atemp;
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
        writeEnable = {14{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
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
	input [6:0] load_addr;
	input [13:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
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
        writeEnable = {14{1'b1}};
        row_mask =  ( {3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[13], 3'b000, wordtemp[12], 3'b000, wordtemp[11],
          3'b000, wordtemp[10], 3'b000, wordtemp[9], 3'b000, wordtemp[8], 3'b000, wordtemp[7],
          3'b000, wordtemp[6], 3'b000, wordtemp[5], 3'b000, wordtemp[4], 3'b000, wordtemp[3],
          3'b000, wordtemp[2], 3'b000, wordtemp[1], 3'b000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  endtask

task dumpaddr;
	output [13:0] dump_data;
	input [6:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {14{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
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
        DA_int = {14{1'bx}};

      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 31)
        row = {56{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENA_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {14{1'bx}};
        DA_int = {14{1'bx}};
      end else
          writeEnable = ~ ( {14{GWENA_int}} | {WENA_int[13], WENA_int[12], WENA_int[11],
          WENA_int[10], WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6], WENA_int[5],
          WENA_int[4], WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]});
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DA_int[13], 3'b000, DA_int[12], 3'b000, DA_int[11],
          3'b000, DA_int[10], 3'b000, DA_int[9], 3'b000, DA_int[8], 3'b000, DA_int[7],
          3'b000, DA_int[6], 3'b000, DA_int[5], 3'b000, DA_int[4], 3'b000, DA_int[3],
          3'b000, DA_int[2], 3'b000, DA_int[1], 3'b000, DA_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEA_int === 1'b0) begin
        end else if (GWENA_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEA_int === 1'bx) begin
        	XQA = 1'b1; QA_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
      end
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QA_update = 1'b1; DA_sh_update = 1'b1;
        end else begin
          XQA = 1'b0; QA_update = 1'b1; DA_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
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
      WENA_int = {14{1'bx}};
      AA_int = {7{1'bx}};
      DA_int = {14{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {14{1'bx}};
      TAA_int = {7{1'bx}};
      TDA_int = {14{1'bx}};
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
      WENA_int = {14{1'bx}};
      AA_int = {7{1'bx}};
      DA_int = {14{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {14{1'bx}};
      TAA_int = {7{1'bx}};
      TDA_int = {14{1'bx}};
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
        AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({14{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({14{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENA_int[13], WENA_int[12], WENA_int[11], WENA_int[10],
            WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6], WENA_int[5], WENA_int[4],
            WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENB_int[13], WENB_int[12], WENB_int[11], WENB_int[10],
            WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6], WENB_int[5], WENB_int[4],
            WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
       === 1'bx)  && row_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
          DB_int = {14{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
          DA_int = {14{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
      partial_corrupt_A = 14'b0;
      QA_update = 1'b0;
      DA_sh_update = 1'b0;
      XQA = 1'b0;
    end
  end
    LAST_CLKA = CLKA_;
  end

  assign SIA_int = SEA_ ? SIA_ : {2{1'b0}};
  assign DA_int_bmux = TENA_ ? DA_ : TDA_;

  datapath_latch_arm28hkcpdpsram128x14m4 uDQA0 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[0]), .D(DA_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[0]), .XQ(XQA|partial_corrupt_A[0]), .Q(QA_int[0]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA1 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[0]), .D(DA_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[1]), .XQ(XQA|partial_corrupt_A[1]), .Q(QA_int[1]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA2 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[1]), .D(DA_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[2]), .XQ(XQA|partial_corrupt_A[2]), .Q(QA_int[2]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA3 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[2]), .D(DA_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[3]), .XQ(XQA|partial_corrupt_A[3]), .Q(QA_int[3]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA4 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[3]), .D(DA_int_bmux[4]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[4]), .XQ(XQA|partial_corrupt_A[4]), .Q(QA_int[4]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA5 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[4]), .D(DA_int_bmux[5]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[5]), .XQ(XQA|partial_corrupt_A[5]), .Q(QA_int[5]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA6 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[5]), .D(DA_int_bmux[6]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[6]), .XQ(XQA|partial_corrupt_A[6]), .Q(QA_int[6]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA7 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[8]), .D(DA_int_bmux[7]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[7]), .XQ(XQA|partial_corrupt_A[7]), .Q(QA_int[7]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA8 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[9]), .D(DA_int_bmux[8]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[8]), .XQ(XQA|partial_corrupt_A[8]), .Q(QA_int[8]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA9 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[10]), .D(DA_int_bmux[9]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[9]), .XQ(XQA|partial_corrupt_A[9]), .Q(QA_int[9]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA10 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[11]), .D(DA_int_bmux[10]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[10]), .XQ(XQA|partial_corrupt_A[10]), .Q(QA_int[10]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA11 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[12]), .D(DA_int_bmux[11]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[11]), .XQ(XQA|partial_corrupt_A[11]), .Q(QA_int[11]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA12 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[13]), .D(DA_int_bmux[12]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[12]), .XQ(XQA|partial_corrupt_A[12]), .Q(QA_int[12]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA13 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[1]), .D(DA_int_bmux[13]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[13]), .XQ(XQA|partial_corrupt_A[13]), .Q(QA_int[13]));



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
        DB_int = {14{1'bx}};

      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 31)
        row = {56{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENB_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {14{1'bx}};
        DB_int = {14{1'bx}};
      end else
          writeEnable = ~ ( {14{GWENB_int}} | {WENB_int[13], WENB_int[12], WENB_int[11],
          WENB_int[10], WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6], WENB_int[5],
          WENB_int[4], WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]});
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DB_int[13], 3'b000, DB_int[12], 3'b000, DB_int[11],
          3'b000, DB_int[10], 3'b000, DB_int[9], 3'b000, DB_int[8], 3'b000, DB_int[7],
          3'b000, DB_int[6], 3'b000, DB_int[5], 3'b000, DB_int[4], 3'b000, DB_int[3],
          3'b000, DB_int[2], 3'b000, DB_int[1], 3'b000, DB_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEB_int === 1'b0) begin
        end else if (GWENB_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEB_int === 1'bx) begin
        	XQB = 1'b1; QB_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
      end
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QB_update = 1'b1; DB_sh_update = 1'b1;
        end else begin
          XQB = 1'b0; QB_update = 1'b1; DB_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch1 = readLatch1;
        mem_path_B = {shifted_readLatch1[13], shifted_readLatch1[12], shifted_readLatch1[11],
          shifted_readLatch1[10], shifted_readLatch1[9], shifted_readLatch1[8], shifted_readLatch1[7],
          shifted_readLatch1[6], shifted_readLatch1[5], shifted_readLatch1[4], shifted_readLatch1[3],
          shifted_readLatch1[2], shifted_readLatch1[1], shifted_readLatch1[0]};
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
      WENB_int = {14{1'bx}};
      AB_int = {7{1'bx}};
      DB_int = {14{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {14{1'bx}};
      TAB_int = {7{1'bx}};
      TDB_int = {14{1'bx}};
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
      WENB_int = {14{1'bx}};
      AB_int = {7{1'bx}};
      DB_int = {14{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {14{1'bx}};
      TAB_int = {7{1'bx}};
      TDB_int = {14{1'bx}};
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
        AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({14{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({14{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENA_int[13], WENA_int[12], WENA_int[11], WENA_int[10],
            WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6], WENA_int[5], WENA_int[4],
            WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENB_int[13], WENB_int[12], WENB_int[11], WENB_int[10],
            WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6], WENB_int[5], WENB_int[4],
            WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
       === 1'bx)  && row_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
          DA_int = {14{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
          DB_int = {14{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
      partial_corrupt_A = 14'b0;
      QB_update = 1'b0;
      DB_sh_update = 1'b0;
      XQB = 1'b0;
    end
  end
    LAST_CLKB = CLKB_;
  end

  assign SIB_int = SEB_ ? SIB_ : {2{1'b0}};
  assign DB_int_bmux = TENB_ ? DB_ : TDB_;

  datapath_latch_arm28hkcpdpsram128x14m4 uDQB0 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[0]), .D(DB_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[0]), .XQ(XQB|partial_corrupt_A[0]), .Q(QB_int[0]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB1 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[0]), .D(DB_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[1]), .XQ(XQB|partial_corrupt_A[1]), .Q(QB_int[1]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB2 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[1]), .D(DB_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[2]), .XQ(XQB|partial_corrupt_A[2]), .Q(QB_int[2]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB3 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[2]), .D(DB_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[3]), .XQ(XQB|partial_corrupt_A[3]), .Q(QB_int[3]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB4 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[3]), .D(DB_int_bmux[4]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[4]), .XQ(XQB|partial_corrupt_A[4]), .Q(QB_int[4]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB5 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[4]), .D(DB_int_bmux[5]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[5]), .XQ(XQB|partial_corrupt_A[5]), .Q(QB_int[5]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB6 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[5]), .D(DB_int_bmux[6]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[6]), .XQ(XQB|partial_corrupt_A[6]), .Q(QB_int[6]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB7 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[8]), .D(DB_int_bmux[7]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[7]), .XQ(XQB|partial_corrupt_A[7]), .Q(QB_int[7]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB8 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[9]), .D(DB_int_bmux[8]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[8]), .XQ(XQB|partial_corrupt_A[8]), .Q(QB_int[8]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB9 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[10]), .D(DB_int_bmux[9]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[9]), .XQ(XQB|partial_corrupt_A[9]), .Q(QB_int[9]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB10 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[11]), .D(DB_int_bmux[10]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[10]), .XQ(XQB|partial_corrupt_A[10]), .Q(QB_int[10]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB11 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[12]), .D(DB_int_bmux[11]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[11]), .XQ(XQB|partial_corrupt_A[11]), .Q(QB_int[11]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB12 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[13]), .D(DB_int_bmux[12]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[12]), .XQ(XQB|partial_corrupt_A[12]), .Q(QB_int[12]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB13 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[1]), .D(DB_int_bmux[13]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[13]), .XQ(XQB|partial_corrupt_A[13]), .Q(QB_int[13]));


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
    input [6:0] aa;
    input [6:0] ab;
    input [13:0] wena;
    input [13:0] wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) === 1'b1 && (& wenb) === 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[6:2] == ab[6:2]) begin
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
    input [6:0] aa;
    input [6:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [6:0] aa;
    input [6:0] ab;
    input [13:0] wena;
    input [13:0] wenb;
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
module arm28hkcpdpsram128x14m4 (VDDCE, VDDPE, VSSE, CENYA, WENYA, AYA, CENYB, WENYB,
    AYB, GWENYA, GWENYB, QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB,
    AB, DB, EMAA, EMAWA, EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB,
    TCENB, TWENB, TAB, TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP,
    SIB, SEB, COLLDISN);
`else
module arm28hkcpdpsram128x14m4 (CENYA, WENYA, AYA, CENYB, WENYB, AYB, GWENYA, GWENYB,
    QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA,
    EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB, TCENB, TWENB, TAB,
    TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP, SIB, SEB, COLLDISN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 14;
  parameter WORDS = 128;
  parameter MUX = 4;
  parameter MEM_WIDTH = 56; // redun block size 4, 28 on left, 28 on right
  parameter MEM_HEIGHT = 32;
  parameter WP_SIZE = 1 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENYA;
  output [13:0] WENYA;
  output [6:0] AYA;
  output  CENYB;
  output [13:0] WENYB;
  output [6:0] AYB;
  output  GWENYA;
  output  GWENYB;
  output [13:0] QA;
  output [13:0] QB;
  output [1:0] SOA;
  output [1:0] SOB;
  input  CLKA;
  input  CENA;
  input [13:0] WENA;
  input [6:0] AA;
  input [13:0] DA;
  input  CLKB;
  input  CENB;
  input [13:0] WENB;
  input [6:0] AB;
  input [13:0] DB;
  input [2:0] EMAA;
  input [1:0] EMAWA;
  input  EMASA;
  input [2:0] EMAB;
  input [1:0] EMAWB;
  input  EMASB;
  input  TENA;
  input  TCENA;
  input [13:0] TWENA;
  input [6:0] TAA;
  input [13:0] TDA;
  input  TENB;
  input  TCENB;
  input [13:0] TWENB;
  input [6:0] TAB;
  input [13:0] TDB;
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
  reg [55:0] mem [0:31];
  reg [55:0] row, row_t;
  reg LAST_CLKA;
  reg [55:0] row_mask;
  reg [55:0] new_data;
  reg [55:0] data_out;
  reg [13:0] readLatch0;
  reg [13:0] shifted_readLatch0;
  reg  read_mux_sel0_p2;
  reg [13:0] readLatch1;
  reg [13:0] shifted_readLatch1;
  reg  read_mux_sel1_p2;
  reg LAST_CLKB;
  wire [13:0] QA_int;
  reg XQA, QA_update;
  reg XDA_sh, DA_sh_update;
  wire [13:0] DA_int_bmux;
  reg [13:0] mem_path_A;
  reg [13:0] partial_mask;
  reg [13:0] partial_mask_A;
  reg [13:0] partial_corrupt_A = 14'b0;
  wire [13:0] QB_int;
  reg XQB, QB_update;
  reg XDB_sh, DB_sh_update;
  wire [13:0] DB_int_bmux;
  reg [13:0] mem_path_B;
  reg [13:0] partial_mask_B;
  reg [13:0] partial_corrupt_B = 14'b0;
  reg [13:0] writeEnable;
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

  reg NOT_CENA, NOT_WENA13, NOT_WENA12, NOT_WENA11, NOT_WENA10, NOT_WENA9, NOT_WENA8;
  reg NOT_WENA7, NOT_WENA6, NOT_WENA5, NOT_WENA4, NOT_WENA3, NOT_WENA2, NOT_WENA1;
  reg NOT_WENA0, NOT_AA6, NOT_AA5, NOT_AA4, NOT_AA3, NOT_AA2, NOT_AA1, NOT_AA0, NOT_DA13;
  reg NOT_DA12, NOT_DA11, NOT_DA10, NOT_DA9, NOT_DA8, NOT_DA7, NOT_DA6, NOT_DA5, NOT_DA4;
  reg NOT_DA3, NOT_DA2, NOT_DA1, NOT_DA0, NOT_CENB, NOT_WENB13, NOT_WENB12, NOT_WENB11;
  reg NOT_WENB10, NOT_WENB9, NOT_WENB8, NOT_WENB7, NOT_WENB6, NOT_WENB5, NOT_WENB4;
  reg NOT_WENB3, NOT_WENB2, NOT_WENB1, NOT_WENB0, NOT_AB6, NOT_AB5, NOT_AB4, NOT_AB3;
  reg NOT_AB2, NOT_AB1, NOT_AB0, NOT_DB13, NOT_DB12, NOT_DB11, NOT_DB10, NOT_DB9, NOT_DB8;
  reg NOT_DB7, NOT_DB6, NOT_DB5, NOT_DB4, NOT_DB3, NOT_DB2, NOT_DB1, NOT_DB0, NOT_EMAA2;
  reg NOT_EMAA1, NOT_EMAA0, NOT_EMAWA1, NOT_EMAWA0, NOT_EMASA, NOT_EMAB2, NOT_EMAB1;
  reg NOT_EMAB0, NOT_EMAWB1, NOT_EMAWB0, NOT_EMASB, NOT_TENA, NOT_TCENA, NOT_TWENA13;
  reg NOT_TWENA12, NOT_TWENA11, NOT_TWENA10, NOT_TWENA9, NOT_TWENA8, NOT_TWENA7, NOT_TWENA6;
  reg NOT_TWENA5, NOT_TWENA4, NOT_TWENA3, NOT_TWENA2, NOT_TWENA1, NOT_TWENA0, NOT_TAA6;
  reg NOT_TAA5, NOT_TAA4, NOT_TAA3, NOT_TAA2, NOT_TAA1, NOT_TAA0, NOT_TDA13, NOT_TDA12;
  reg NOT_TDA11, NOT_TDA10, NOT_TDA9, NOT_TDA8, NOT_TDA7, NOT_TDA6, NOT_TDA5, NOT_TDA4;
  reg NOT_TDA3, NOT_TDA2, NOT_TDA1, NOT_TDA0, NOT_TENB, NOT_TCENB, NOT_TWENB13, NOT_TWENB12;
  reg NOT_TWENB11, NOT_TWENB10, NOT_TWENB9, NOT_TWENB8, NOT_TWENB7, NOT_TWENB6, NOT_TWENB5;
  reg NOT_TWENB4, NOT_TWENB3, NOT_TWENB2, NOT_TWENB1, NOT_TWENB0, NOT_TAB6, NOT_TAB5;
  reg NOT_TAB4, NOT_TAB3, NOT_TAB2, NOT_TAB1, NOT_TAB0, NOT_TDB13, NOT_TDB12, NOT_TDB11;
  reg NOT_TDB10, NOT_TDB9, NOT_TDB8, NOT_TDB7, NOT_TDB6, NOT_TDB5, NOT_TDB4, NOT_TDB3;
  reg NOT_TDB2, NOT_TDB1, NOT_TDB0, NOT_GWENA, NOT_GWENB, NOT_TGWENA, NOT_TGWENB, NOT_SIA1;
  reg NOT_SIA0, NOT_SEA, NOT_DFTRAMBYP_CLKB, NOT_DFTRAMBYP_CLKA, NOT_RET1N, NOT_SIB1;
  reg NOT_SIB0, NOT_SEB, NOT_COLLDISN;
  reg NOT_CLKA_PER, NOT_CLKA_MINH, NOT_CLKA_MINL, NOT_CONTA, NOT_CLKB_PER, NOT_CLKB_MINH;
  reg NOT_CLKB_MINL, NOT_CONTB;
  reg clk0_int;
  reg clk1_int;

  wire  CENYA_;
  wire [13:0] WENYA_;
  wire [6:0] AYA_;
  wire  CENYB_;
  wire [13:0] WENYB_;
  wire [6:0] AYB_;
  wire  GWENYA_;
  wire  GWENYB_;
  wire [13:0] QA_;
  wire [13:0] QB_;
  wire [1:0] SOA_;
  wire [1:0] SOB_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire [13:0] WENA_;
  reg [13:0] WENA_int;
  wire [6:0] AA_;
  reg [6:0] AA_int;
  wire [13:0] DA_;
  reg [13:0] DA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire [13:0] WENB_;
  reg [13:0] WENB_int;
  wire [6:0] AB_;
  reg [6:0] AB_int;
  wire [13:0] DB_;
  reg [13:0] DB_int;
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
  wire [13:0] TWENA_;
  reg [13:0] TWENA_int;
  wire [6:0] TAA_;
  reg [6:0] TAA_int;
  wire [13:0] TDA_;
  reg [13:0] TDA_int;
  wire  TENB_;
  reg  TENB_int;
  wire  TCENB_;
  reg  TCENB_int;
  reg  TCENB_p2;
  wire [13:0] TWENB_;
  reg [13:0] TWENB_int;
  wire [6:0] TAB_;
  reg [6:0] TAB_int;
  wire [13:0] TDB_;
  reg [13:0] TDB_int;
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
  buf B5(WENYA[4], WENYA_[4]);
  buf B6(WENYA[5], WENYA_[5]);
  buf B7(WENYA[6], WENYA_[6]);
  buf B8(WENYA[7], WENYA_[7]);
  buf B9(WENYA[8], WENYA_[8]);
  buf B10(WENYA[9], WENYA_[9]);
  buf B11(WENYA[10], WENYA_[10]);
  buf B12(WENYA[11], WENYA_[11]);
  buf B13(WENYA[12], WENYA_[12]);
  buf B14(WENYA[13], WENYA_[13]);
  buf B15(AYA[0], AYA_[0]);
  buf B16(AYA[1], AYA_[1]);
  buf B17(AYA[2], AYA_[2]);
  buf B18(AYA[3], AYA_[3]);
  buf B19(AYA[4], AYA_[4]);
  buf B20(AYA[5], AYA_[5]);
  buf B21(AYA[6], AYA_[6]);
  buf B22(CENYB, CENYB_);
  buf B23(WENYB[0], WENYB_[0]);
  buf B24(WENYB[1], WENYB_[1]);
  buf B25(WENYB[2], WENYB_[2]);
  buf B26(WENYB[3], WENYB_[3]);
  buf B27(WENYB[4], WENYB_[4]);
  buf B28(WENYB[5], WENYB_[5]);
  buf B29(WENYB[6], WENYB_[6]);
  buf B30(WENYB[7], WENYB_[7]);
  buf B31(WENYB[8], WENYB_[8]);
  buf B32(WENYB[9], WENYB_[9]);
  buf B33(WENYB[10], WENYB_[10]);
  buf B34(WENYB[11], WENYB_[11]);
  buf B35(WENYB[12], WENYB_[12]);
  buf B36(WENYB[13], WENYB_[13]);
  buf B37(AYB[0], AYB_[0]);
  buf B38(AYB[1], AYB_[1]);
  buf B39(AYB[2], AYB_[2]);
  buf B40(AYB[3], AYB_[3]);
  buf B41(AYB[4], AYB_[4]);
  buf B42(AYB[5], AYB_[5]);
  buf B43(AYB[6], AYB_[6]);
  buf B44(GWENYA, GWENYA_);
  buf B45(GWENYB, GWENYB_);
  buf B46(QA[0], QA_[0]);
  buf B47(QA[1], QA_[1]);
  buf B48(QA[2], QA_[2]);
  buf B49(QA[3], QA_[3]);
  buf B50(QA[4], QA_[4]);
  buf B51(QA[5], QA_[5]);
  buf B52(QA[6], QA_[6]);
  buf B53(QA[7], QA_[7]);
  buf B54(QA[8], QA_[8]);
  buf B55(QA[9], QA_[9]);
  buf B56(QA[10], QA_[10]);
  buf B57(QA[11], QA_[11]);
  buf B58(QA[12], QA_[12]);
  buf B59(QA[13], QA_[13]);
  buf B60(QB[0], QB_[0]);
  buf B61(QB[1], QB_[1]);
  buf B62(QB[2], QB_[2]);
  buf B63(QB[3], QB_[3]);
  buf B64(QB[4], QB_[4]);
  buf B65(QB[5], QB_[5]);
  buf B66(QB[6], QB_[6]);
  buf B67(QB[7], QB_[7]);
  buf B68(QB[8], QB_[8]);
  buf B69(QB[9], QB_[9]);
  buf B70(QB[10], QB_[10]);
  buf B71(QB[11], QB_[11]);
  buf B72(QB[12], QB_[12]);
  buf B73(QB[13], QB_[13]);
  buf B74(SOA[0], SOA_[0]);
  buf B75(SOA[1], SOA_[1]);
  buf B76(SOB[0], SOB_[0]);
  buf B77(SOB[1], SOB_[1]);
  buf B78(CLKA_, CLKA);
  buf B79(CENA_, CENA);
  buf B80(WENA_[0], WENA[0]);
  buf B81(WENA_[1], WENA[1]);
  buf B82(WENA_[2], WENA[2]);
  buf B83(WENA_[3], WENA[3]);
  buf B84(WENA_[4], WENA[4]);
  buf B85(WENA_[5], WENA[5]);
  buf B86(WENA_[6], WENA[6]);
  buf B87(WENA_[7], WENA[7]);
  buf B88(WENA_[8], WENA[8]);
  buf B89(WENA_[9], WENA[9]);
  buf B90(WENA_[10], WENA[10]);
  buf B91(WENA_[11], WENA[11]);
  buf B92(WENA_[12], WENA[12]);
  buf B93(WENA_[13], WENA[13]);
  buf B94(AA_[0], AA[0]);
  buf B95(AA_[1], AA[1]);
  buf B96(AA_[2], AA[2]);
  buf B97(AA_[3], AA[3]);
  buf B98(AA_[4], AA[4]);
  buf B99(AA_[5], AA[5]);
  buf B100(AA_[6], AA[6]);
  buf B101(DA_[0], DA[0]);
  buf B102(DA_[1], DA[1]);
  buf B103(DA_[2], DA[2]);
  buf B104(DA_[3], DA[3]);
  buf B105(DA_[4], DA[4]);
  buf B106(DA_[5], DA[5]);
  buf B107(DA_[6], DA[6]);
  buf B108(DA_[7], DA[7]);
  buf B109(DA_[8], DA[8]);
  buf B110(DA_[9], DA[9]);
  buf B111(DA_[10], DA[10]);
  buf B112(DA_[11], DA[11]);
  buf B113(DA_[12], DA[12]);
  buf B114(DA_[13], DA[13]);
  buf B115(CLKB_, CLKB);
  buf B116(CENB_, CENB);
  buf B117(WENB_[0], WENB[0]);
  buf B118(WENB_[1], WENB[1]);
  buf B119(WENB_[2], WENB[2]);
  buf B120(WENB_[3], WENB[3]);
  buf B121(WENB_[4], WENB[4]);
  buf B122(WENB_[5], WENB[5]);
  buf B123(WENB_[6], WENB[6]);
  buf B124(WENB_[7], WENB[7]);
  buf B125(WENB_[8], WENB[8]);
  buf B126(WENB_[9], WENB[9]);
  buf B127(WENB_[10], WENB[10]);
  buf B128(WENB_[11], WENB[11]);
  buf B129(WENB_[12], WENB[12]);
  buf B130(WENB_[13], WENB[13]);
  buf B131(AB_[0], AB[0]);
  buf B132(AB_[1], AB[1]);
  buf B133(AB_[2], AB[2]);
  buf B134(AB_[3], AB[3]);
  buf B135(AB_[4], AB[4]);
  buf B136(AB_[5], AB[5]);
  buf B137(AB_[6], AB[6]);
  buf B138(DB_[0], DB[0]);
  buf B139(DB_[1], DB[1]);
  buf B140(DB_[2], DB[2]);
  buf B141(DB_[3], DB[3]);
  buf B142(DB_[4], DB[4]);
  buf B143(DB_[5], DB[5]);
  buf B144(DB_[6], DB[6]);
  buf B145(DB_[7], DB[7]);
  buf B146(DB_[8], DB[8]);
  buf B147(DB_[9], DB[9]);
  buf B148(DB_[10], DB[10]);
  buf B149(DB_[11], DB[11]);
  buf B150(DB_[12], DB[12]);
  buf B151(DB_[13], DB[13]);
  buf B152(EMAA_[0], EMAA[0]);
  buf B153(EMAA_[1], EMAA[1]);
  buf B154(EMAA_[2], EMAA[2]);
  buf B155(EMAWA_[0], EMAWA[0]);
  buf B156(EMAWA_[1], EMAWA[1]);
  buf B157(EMASA_, EMASA);
  buf B158(EMAB_[0], EMAB[0]);
  buf B159(EMAB_[1], EMAB[1]);
  buf B160(EMAB_[2], EMAB[2]);
  buf B161(EMAWB_[0], EMAWB[0]);
  buf B162(EMAWB_[1], EMAWB[1]);
  buf B163(EMASB_, EMASB);
  buf B164(TENA_, TENA);
  buf B165(TCENA_, TCENA);
  buf B166(TWENA_[0], TWENA[0]);
  buf B167(TWENA_[1], TWENA[1]);
  buf B168(TWENA_[2], TWENA[2]);
  buf B169(TWENA_[3], TWENA[3]);
  buf B170(TWENA_[4], TWENA[4]);
  buf B171(TWENA_[5], TWENA[5]);
  buf B172(TWENA_[6], TWENA[6]);
  buf B173(TWENA_[7], TWENA[7]);
  buf B174(TWENA_[8], TWENA[8]);
  buf B175(TWENA_[9], TWENA[9]);
  buf B176(TWENA_[10], TWENA[10]);
  buf B177(TWENA_[11], TWENA[11]);
  buf B178(TWENA_[12], TWENA[12]);
  buf B179(TWENA_[13], TWENA[13]);
  buf B180(TAA_[0], TAA[0]);
  buf B181(TAA_[1], TAA[1]);
  buf B182(TAA_[2], TAA[2]);
  buf B183(TAA_[3], TAA[3]);
  buf B184(TAA_[4], TAA[4]);
  buf B185(TAA_[5], TAA[5]);
  buf B186(TAA_[6], TAA[6]);
  buf B187(TDA_[0], TDA[0]);
  buf B188(TDA_[1], TDA[1]);
  buf B189(TDA_[2], TDA[2]);
  buf B190(TDA_[3], TDA[3]);
  buf B191(TDA_[4], TDA[4]);
  buf B192(TDA_[5], TDA[5]);
  buf B193(TDA_[6], TDA[6]);
  buf B194(TDA_[7], TDA[7]);
  buf B195(TDA_[8], TDA[8]);
  buf B196(TDA_[9], TDA[9]);
  buf B197(TDA_[10], TDA[10]);
  buf B198(TDA_[11], TDA[11]);
  buf B199(TDA_[12], TDA[12]);
  buf B200(TDA_[13], TDA[13]);
  buf B201(TENB_, TENB);
  buf B202(TCENB_, TCENB);
  buf B203(TWENB_[0], TWENB[0]);
  buf B204(TWENB_[1], TWENB[1]);
  buf B205(TWENB_[2], TWENB[2]);
  buf B206(TWENB_[3], TWENB[3]);
  buf B207(TWENB_[4], TWENB[4]);
  buf B208(TWENB_[5], TWENB[5]);
  buf B209(TWENB_[6], TWENB[6]);
  buf B210(TWENB_[7], TWENB[7]);
  buf B211(TWENB_[8], TWENB[8]);
  buf B212(TWENB_[9], TWENB[9]);
  buf B213(TWENB_[10], TWENB[10]);
  buf B214(TWENB_[11], TWENB[11]);
  buf B215(TWENB_[12], TWENB[12]);
  buf B216(TWENB_[13], TWENB[13]);
  buf B217(TAB_[0], TAB[0]);
  buf B218(TAB_[1], TAB[1]);
  buf B219(TAB_[2], TAB[2]);
  buf B220(TAB_[3], TAB[3]);
  buf B221(TAB_[4], TAB[4]);
  buf B222(TAB_[5], TAB[5]);
  buf B223(TAB_[6], TAB[6]);
  buf B224(TDB_[0], TDB[0]);
  buf B225(TDB_[1], TDB[1]);
  buf B226(TDB_[2], TDB[2]);
  buf B227(TDB_[3], TDB[3]);
  buf B228(TDB_[4], TDB[4]);
  buf B229(TDB_[5], TDB[5]);
  buf B230(TDB_[6], TDB[6]);
  buf B231(TDB_[7], TDB[7]);
  buf B232(TDB_[8], TDB[8]);
  buf B233(TDB_[9], TDB[9]);
  buf B234(TDB_[10], TDB[10]);
  buf B235(TDB_[11], TDB[11]);
  buf B236(TDB_[12], TDB[12]);
  buf B237(TDB_[13], TDB[13]);
  buf B238(GWENA_, GWENA);
  buf B239(GWENB_, GWENB);
  buf B240(TGWENA_, TGWENA);
  buf B241(TGWENB_, TGWENB);
  buf B242(RET1N_, RET1N);
  buf B243(SIA_[0], SIA[0]);
  buf B244(SIA_[1], SIA[1]);
  buf B245(SEA_, SEA);
  buf B246(DFTRAMBYP_, DFTRAMBYP);
  buf B247(SIB_[0], SIB[0]);
  buf B248(SIB_[1], SIB[1]);
  buf B249(SEB_, SEB);
  buf B250(COLLDISN_, COLLDISN);

  assign CENYA_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENA_ ? CENA_ : TCENA_)) : 1'bx;
  assign WENYA_ = (RET1N_ | pre_charge_st) ? ({14{DFTRAMBYP_}} & (TENA_ ? WENA_ : TWENA_)) : {14{1'bx}};
  assign AYA_ = (RET1N_ | pre_charge_st) ? ({7{DFTRAMBYP_}} & (TENA_ ? AA_ : TAA_)) : {7{1'bx}};
  assign CENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? CENB_ : TCENB_)) : 1'bx;
  assign WENYB_ = (RET1N_ | pre_charge_st) ? ({14{DFTRAMBYP_}} & (TENB_ ? WENB_ : TWENB_)) : {14{1'bx}};
  assign AYB_ = (RET1N_ | pre_charge_st) ? ({7{DFTRAMBYP_}} & (TENB_ ? AB_ : TAB_)) : {7{1'bx}};
  assign GWENYA_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENA_ ? GWENA_ : TGWENA_)) : 1'bx;
  assign GWENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? GWENB_ : TGWENB_)) : 1'bx;
   `ifdef ARM_FAULT_MODELING
     arm28hkcpdpsram128x14m4_error_injection u1(.CLK(CLKA_), .Q_out(QA_), .A(AA_int), .CEN(CENA_int), .DFTRAMBYP(DFTRAMBYP_int), .SE(SEA_int), .GWEN(GWENA_int), .WEN(WENA_int), .Q_in(QA_int));
  `else
  assign QA_ = (RET1N_ | pre_charge_st) ? ((QA_int)) : {14{1'bx}};
  `endif
  assign QB_ = (RET1N_ | pre_charge_st) ? ((QB_int)) : {14{1'bx}};
  assign SOA_ = (RET1N_ | pre_charge_st) ? ({QA_[7], QA_[6]}) : {2{1'bx}};
  assign SOB_ = (RET1N_ | pre_charge_st) ? ({QB_[7], QB_[6]}) : {2{1'bx}};

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
	reg [6:0] Atemp;
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
        writeEnable = {14{1'b1}};
        row_mask =  ( {3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[13], 3'b000, wordtemp[12], 3'b000, wordtemp[11],
          3'b000, wordtemp[10], 3'b000, wordtemp[9], 3'b000, wordtemp[8], 3'b000, wordtemp[7],
          3'b000, wordtemp[6], 3'b000, wordtemp[5], 3'b000, wordtemp[4], 3'b000, wordtemp[3],
          3'b000, wordtemp[2], 3'b000, wordtemp[1], 3'b000, wordtemp[0]} << mux_address);
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
	reg [6:0] Atemp;
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
        writeEnable = {14{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
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
	input [6:0] load_addr;
	input [13:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
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
        writeEnable = {14{1'b1}};
        row_mask =  ( {3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[13], 3'b000, wordtemp[12], 3'b000, wordtemp[11],
          3'b000, wordtemp[10], 3'b000, wordtemp[9], 3'b000, wordtemp[8], 3'b000, wordtemp[7],
          3'b000, wordtemp[6], 3'b000, wordtemp[5], 3'b000, wordtemp[4], 3'b000, wordtemp[3],
          3'b000, wordtemp[2], 3'b000, wordtemp[1], 3'b000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  endtask

task dumpaddr;
	output [13:0] dump_data;
	input [6:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (CENA_ === 1'b1 && CENB_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {14{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
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
        DA_int = {14{1'bx}};

      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 31)
        row = {56{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENA_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {14{1'bx}};
        DA_int = {14{1'bx}};
      end else
          writeEnable = ~ ( {14{GWENA_int}} | {WENA_int[13], WENA_int[12], WENA_int[11],
          WENA_int[10], WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6], WENA_int[5],
          WENA_int[4], WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]});
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DA_int[13], 3'b000, DA_int[12], 3'b000, DA_int[11],
          3'b000, DA_int[10], 3'b000, DA_int[9], 3'b000, DA_int[8], 3'b000, DA_int[7],
          3'b000, DA_int[6], 3'b000, DA_int[5], 3'b000, DA_int[4], 3'b000, DA_int[3],
          3'b000, DA_int[2], 3'b000, DA_int[1], 3'b000, DA_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEA_int === 1'b0) begin
        end else if (GWENA_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEA_int === 1'bx) begin
        	XQA = 1'b1; QA_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
      end
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QA_update = 1'b1; DA_sh_update = 1'b1;
        end else begin
          XQA = 1'b0; QA_update = 1'b1; DA_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
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
      WENA_int = {14{1'bx}};
      AA_int = {7{1'bx}};
      DA_int = {14{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {14{1'bx}};
      TAA_int = {7{1'bx}};
      TDA_int = {14{1'bx}};
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
      WENA_int = {14{1'bx}};
      AA_int = {7{1'bx}};
      DA_int = {14{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {14{1'bx}};
      TAA_int = {7{1'bx}};
      TDA_int = {14{1'bx}};
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
        AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({14{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({14{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENA_int[13], WENA_int[12], WENA_int[11], WENA_int[10],
            WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6], WENA_int[5], WENA_int[4],
            WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENB_int[13], WENB_int[12], WENB_int[11], WENB_int[10],
            WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6], WENB_int[5], WENB_int[4],
            WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
       === 1'bx)  && row_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
          DB_int = {14{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
          DA_int = {14{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
      partial_corrupt_A = 14'b0;
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
      DA_int = {14{1'bx}};
    end
      failedWrite(0);
    end else if (TENA_int === 1'bx) begin
      if(((CENA_ === 1'b1 & TCENA_ === 1'b1) & DFTRAMBYP_int === 1'b0) | (DFTRAMBYP_int === 1'b1 & SEA_int === 1'b1)) begin
      end else begin
        XQA = 1'b1; QA_update = 1'b1;
    if (clk0_int === 1'bx || CENA_int === 1'bx) begin
      DA_int = {14{1'bx}};
    end
      if (DFTRAMBYP_int === 1'b0) begin
          failedWrite(0);
      end
      end
    end else if (CENA_int === 1'b0 && (^AA_int) === 1'bx && DFTRAMBYP_int === 1'b0) begin
        failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if  (cont_flag0_int === 1'bx && COLLDISN_int === 1'b1 &&  (CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1) && DFTRAMBYP_ !== 1'b1) 
     && row_contention(TENB_ ? AB_ : TAB_, AA_int, ({14{GWENA_int}}|WENA_int), TENB_ ? ({14{GWENB_}}|WENB_) : ({14{TGWENB_}}|TWENB_))) begin
      cont_flag0_int = 1'b0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, write A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
     	WENA_int =  (({14{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
 		WENB_int =  (({14{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          partial_mask = ~{WENA_int[13], WENA_int[12], WENA_int[11], WENA_int[10],
            WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6], WENA_int[5], WENA_int[4],
            WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          partial_mask = ~{WENB_int[13], WENB_int[12], WENB_int[11], WENB_int[10],
            WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6], WENB_int[5], WENB_int[4],
            WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
     || COLLDISN_int === 1'bx) && row_contention(TENB_ ? AB_ : TAB_, AA_int, ({14{GWENA_int}}|WENA_int), TENB_ ? ({14{GWENB_}}|WENB_) : ({14{TGWENB_}}|TWENB_))) 
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
          DB_int = {14{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
          DA_int = {14{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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

  datapath_latch_arm28hkcpdpsram128x14m4 uDQA0 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[0]), .D(DA_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[0]), .XQ(XQA|partial_corrupt_A[0]), .Q(QA_int[0]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA1 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[0]), .D(DA_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[1]), .XQ(XQA|partial_corrupt_A[1]), .Q(QA_int[1]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA2 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[1]), .D(DA_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[2]), .XQ(XQA|partial_corrupt_A[2]), .Q(QA_int[2]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA3 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[2]), .D(DA_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[3]), .XQ(XQA|partial_corrupt_A[3]), .Q(QA_int[3]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA4 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[3]), .D(DA_int_bmux[4]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[4]), .XQ(XQA|partial_corrupt_A[4]), .Q(QA_int[4]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA5 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[4]), .D(DA_int_bmux[5]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[5]), .XQ(XQA|partial_corrupt_A[5]), .Q(QA_int[5]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA6 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[5]), .D(DA_int_bmux[6]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[6]), .XQ(XQA|partial_corrupt_A[6]), .Q(QA_int[6]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA7 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[8]), .D(DA_int_bmux[7]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[7]), .XQ(XQA|partial_corrupt_A[7]), .Q(QA_int[7]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA8 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[9]), .D(DA_int_bmux[8]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[8]), .XQ(XQA|partial_corrupt_A[8]), .Q(QA_int[8]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA9 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[10]), .D(DA_int_bmux[9]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[9]), .XQ(XQA|partial_corrupt_A[9]), .Q(QA_int[9]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA10 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[11]), .D(DA_int_bmux[10]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[10]), .XQ(XQA|partial_corrupt_A[10]), .Q(QA_int[10]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA11 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[12]), .D(DA_int_bmux[11]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[11]), .XQ(XQA|partial_corrupt_A[11]), .Q(QA_int[11]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA12 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[13]), .D(DA_int_bmux[12]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[12]), .XQ(XQA|partial_corrupt_A[12]), .Q(QA_int[12]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQA13 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[1]), .D(DA_int_bmux[13]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[13]), .XQ(XQA|partial_corrupt_A[13]), .Q(QA_int[13]));



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
        DB_int = {14{1'bx}};

      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 31)
        row = {56{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENB_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {14{1'bx}};
        DB_int = {14{1'bx}};
      end else
          writeEnable = ~ ( {14{GWENB_int}} | {WENB_int[13], WENB_int[12], WENB_int[11],
          WENB_int[10], WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6], WENB_int[5],
          WENB_int[4], WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]});
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[13], 3'b000, writeEnable[12], 3'b000, writeEnable[11],
          3'b000, writeEnable[10], 3'b000, writeEnable[9], 3'b000, writeEnable[8],
          3'b000, writeEnable[7], 3'b000, writeEnable[6], 3'b000, writeEnable[5], 3'b000, writeEnable[4],
          3'b000, writeEnable[3], 3'b000, writeEnable[2], 3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DB_int[13], 3'b000, DB_int[12], 3'b000, DB_int[11],
          3'b000, DB_int[10], 3'b000, DB_int[9], 3'b000, DB_int[8], 3'b000, DB_int[7],
          3'b000, DB_int[6], 3'b000, DB_int[5], 3'b000, DB_int[4], 3'b000, DB_int[3],
          3'b000, DB_int[2], 3'b000, DB_int[1], 3'b000, DB_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEB_int === 1'b0) begin
        end else if (GWENB_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEB_int === 1'bx) begin
        	XQB = 1'b1; QB_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[52], data_out[48], data_out[44], data_out[40], data_out[36],
          data_out[32], data_out[28], data_out[24], data_out[20], data_out[16], data_out[12],
          data_out[8], data_out[4], data_out[0]};
      end
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QB_update = 1'b1; DB_sh_update = 1'b1;
        end else begin
          XQB = 1'b0; QB_update = 1'b1; DB_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch1 = readLatch1;
        mem_path_B = {shifted_readLatch1[13], shifted_readLatch1[12], shifted_readLatch1[11],
          shifted_readLatch1[10], shifted_readLatch1[9], shifted_readLatch1[8], shifted_readLatch1[7],
          shifted_readLatch1[6], shifted_readLatch1[5], shifted_readLatch1[4], shifted_readLatch1[3],
          shifted_readLatch1[2], shifted_readLatch1[1], shifted_readLatch1[0]};
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
      WENB_int = {14{1'bx}};
      AB_int = {7{1'bx}};
      DB_int = {14{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {14{1'bx}};
      TAB_int = {7{1'bx}};
      TDB_int = {14{1'bx}};
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
      WENB_int = {14{1'bx}};
      AB_int = {7{1'bx}};
      DB_int = {14{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {14{1'bx}};
      TAB_int = {7{1'bx}};
      TDB_int = {14{1'bx}};
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
        AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({14{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({14{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENA_int[13], WENA_int[12], WENA_int[11], WENA_int[10],
            WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6], WENA_int[5], WENA_int[4],
            WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENB_int[13], WENB_int[12], WENB_int[11], WENB_int[10],
            WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6], WENB_int[5], WENB_int[4],
            WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
       === 1'bx)  && row_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
          DA_int = {14{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
          DB_int = {14{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
      partial_corrupt_A = 14'b0;
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
      DB_int = {14{1'bx}};
    end
      failedWrite(1);
    end else if (TENB_int === 1'bx) begin
      if(((CENB_ === 1'b1 & TCENB_ === 1'b1) & DFTRAMBYP_int === 1'b0) | (DFTRAMBYP_int === 1'b1 & SEB_int === 1'b1)) begin
      end else begin
        XQB = 1'b1; QB_update = 1'b1;
    if (clk1_int === 1'bx || CENB_int === 1'bx) begin
      DB_int = {14{1'bx}};
    end
      if (DFTRAMBYP_int === 1'b0) begin
          failedWrite(1);
      end
      end
    end else if (CENB_int === 1'b0 && (^AB_int) === 1'bx && DFTRAMBYP_int === 1'b0) begin
        failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if  (cont_flag1_int === 1'bx && COLLDISN_int === 1'b1 &&  (CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1) && DFTRAMBYP_ !== 1'b1) 
     && row_contention(TENA_ ? AA_ : TAA_, AB_int, ({14{GWENB_int}}|WENB_int), TENA_ ? ({14{GWENA_}}|WENA_) : ({14{TGWENA_}}|TWENA_))) begin
      cont_flag1_int = 1'b0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, write A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
     	WENA_int =  (({14{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({14{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
 		WENB_int =  (({14{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          partial_mask = ~{WENA_int[13], WENA_int[12], WENA_int[11], WENA_int[10],
            WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6], WENA_int[5], WENA_int[4],
            WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          partial_mask = ~{WENB_int[13], WENB_int[12], WENB_int[11], WENB_int[10],
            WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6], WENB_int[5], WENB_int[4],
            WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {14{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
     || COLLDISN_int === 1'bx) && row_contention(TENA_ ? AA_ : TAA_, AB_int, ({14{GWENB_int}}|WENB_int), TENA_ ? ({14{GWENA_}}|WENA_) : ({14{TGWENA_}}|TWENA_))) 
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
          DA_int = {14{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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
          DB_int = {14{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({14{GWENA_int}}|WENA_int), ({14{GWENB_int}}|WENB_int))) begin
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

  datapath_latch_arm28hkcpdpsram128x14m4 uDQB0 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[0]), .D(DB_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[0]), .XQ(XQB|partial_corrupt_A[0]), .Q(QB_int[0]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB1 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[0]), .D(DB_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[1]), .XQ(XQB|partial_corrupt_A[1]), .Q(QB_int[1]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB2 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[1]), .D(DB_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[2]), .XQ(XQB|partial_corrupt_A[2]), .Q(QB_int[2]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB3 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[2]), .D(DB_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[3]), .XQ(XQB|partial_corrupt_A[3]), .Q(QB_int[3]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB4 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[3]), .D(DB_int_bmux[4]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[4]), .XQ(XQB|partial_corrupt_A[4]), .Q(QB_int[4]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB5 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[4]), .D(DB_int_bmux[5]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[5]), .XQ(XQB|partial_corrupt_A[5]), .Q(QB_int[5]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB6 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[5]), .D(DB_int_bmux[6]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[6]), .XQ(XQB|partial_corrupt_A[6]), .Q(QB_int[6]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB7 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[8]), .D(DB_int_bmux[7]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[7]), .XQ(XQB|partial_corrupt_A[7]), .Q(QB_int[7]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB8 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[9]), .D(DB_int_bmux[8]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[8]), .XQ(XQB|partial_corrupt_A[8]), .Q(QB_int[8]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB9 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[10]), .D(DB_int_bmux[9]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[9]), .XQ(XQB|partial_corrupt_A[9]), .Q(QB_int[9]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB10 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[11]), .D(DB_int_bmux[10]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[10]), .XQ(XQB|partial_corrupt_A[10]), .Q(QB_int[10]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB11 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[12]), .D(DB_int_bmux[11]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[11]), .XQ(XQB|partial_corrupt_A[11]), .Q(QB_int[11]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB12 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[13]), .D(DB_int_bmux[12]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[12]), .XQ(XQB|partial_corrupt_A[12]), .Q(QB_int[12]));
  datapath_latch_arm28hkcpdpsram128x14m4 uDQB13 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[1]), .D(DB_int_bmux[13]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[13]), .XQ(XQB|partial_corrupt_A[13]), .Q(QB_int[13]));


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
    input [6:0] aa;
    input [6:0] ab;
    input [13:0] wena;
    input [13:0] wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) === 1'b1 && (& wenb) === 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[6:2] == ab[6:2]) begin
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
    input [6:0] aa;
    input [6:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [6:0] aa;
    input [6:0] ab;
    input [13:0] wena;
    input [13:0] wenb;
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

   wire contA_flag = (CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1)) && ((COLLDISN_int === 1'b1 && is_contention(TENB_ ? AB_ : TAB_, AA_int, TENB_ ? ({14{GWENB_}}|WENB_) : ({14{TGWENB_}}|TWENB_), ({14{GWENA_int}}|WENA_int))) ||
              ((COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENB_ ? AB_ : TAB_, AA_int, TENB_ ? ({14{GWENB_}}|WENB_) : ({14{TGWENB_}}|TWENB_), ({14{GWENA_int}}|WENA_int))));
   wire contB_flag = (CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1)) && ((COLLDISN_int === 1'b1 && is_contention(TENA_ ? AA_ : TAA_, AB_int, TENA_ ? ({14{GWENA_}}|WENA_) : ({14{TGWENA_}}|TWENA_), ({14{GWENB_int}}|WENB_int))) ||
              ((COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENA_ ? AA_ : TAA_, AB_int, TENA_ ? ({14{GWENA_}}|WENA_) : ({14{TGWENA_}}|TWENA_), ({14{GWENB_int}}|WENB_int))));

  always @ NOT_CENA begin
    CENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA13 begin
    WENA_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA12 begin
    WENA_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA11 begin
    WENA_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA10 begin
    WENA_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA9 begin
    WENA_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA8 begin
    WENA_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA7 begin
    WENA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA6 begin
    WENA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA5 begin
    WENA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA4 begin
    WENA_int[4] = 1'bx;
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
  always @ NOT_DA13 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA12 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA11 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA10 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA9 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA8 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA7 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA6 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA5 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA4 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[4] = 1'bx;
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
  always @ NOT_WENB13 begin
    WENB_int[13] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB12 begin
    WENB_int[12] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB11 begin
    WENB_int[11] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB10 begin
    WENB_int[10] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB9 begin
    WENB_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB8 begin
    WENB_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB7 begin
    WENB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB6 begin
    WENB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB5 begin
    WENB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB4 begin
    WENB_int[4] = 1'bx;
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
  always @ NOT_DB13 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[13] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB12 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[12] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB11 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[11] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB10 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[10] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB9 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB8 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB7 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB6 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB5 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB4 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[4] = 1'bx;
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
  always @ NOT_TWENA13 begin
    WENA_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA12 begin
    WENA_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA11 begin
    WENA_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA10 begin
    WENA_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA9 begin
    WENA_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA8 begin
    WENA_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA7 begin
    WENA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA6 begin
    WENA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA5 begin
    WENA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA4 begin
    WENA_int[4] = 1'bx;
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
  always @ NOT_TDA13 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA12 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA11 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA10 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA9 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA8 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA7 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA6 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA5 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA4 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[4] = 1'bx;
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
  always @ NOT_TWENB13 begin
    WENB_int[13] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB12 begin
    WENB_int[12] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB11 begin
    WENB_int[11] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB10 begin
    WENB_int[10] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB9 begin
    WENB_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB8 begin
    WENB_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB7 begin
    WENB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB6 begin
    WENB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB5 begin
    WENB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB4 begin
    WENB_int[4] = 1'bx;
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
  always @ NOT_TDB13 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[13] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB12 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[12] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB11 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[11] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB10 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[10] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB9 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB8 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB7 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB6 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB5 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB4 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[4] = 1'bx;
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
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA13eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA12eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA11eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA10eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA9eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA8eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA7eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA6eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA5eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA4eq0aGWENAeq0cpcp;
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
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB13eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB12eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB11eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB10eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB9eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB8eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB7eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB6eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB5eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB4eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB3eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB2eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB1eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB0eq0aGWENBeq0cpcp;
  wire RET1Neq1aopopopTENAeq1aCENAeq0aDFTRAMBYPeq0cpoopTENAeq0aTCENAeq0aDFTRAMBYPeq0cpcpoDFTRAMBYPeq1cp;
  wire RET1Neq1aopopopTENBeq1aCENBeq0aDFTRAMBYPeq0cpoopTENBeq0aTCENBeq0aDFTRAMBYPeq0cpcpoDFTRAMBYPeq1cp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA13eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA12eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA11eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA10eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA9eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA8eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA7eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA6eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA5eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA4eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA3eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA2eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA1eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA0eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB13eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB12eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB11eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB10eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB9eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB8eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB7eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB6eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB5eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB4eq0aTGWENBeq0cpcp;
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
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA13eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[13]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA12eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[12]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA11eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[11]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA10eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[10]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA9eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[9]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA8eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[8]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA7eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[7]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA6eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[6]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA5eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[5]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA4eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[4]&&!GWENA));
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
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB13eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[13]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB12eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[12]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB11eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[11]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB10eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[10]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB9eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[9]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB8eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[8]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB7eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[7]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB6eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[6]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB5eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[5]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB4eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[4]&&!GWENB));
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
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA13eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[13]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA12eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[12]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA11eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[11]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA10eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[10]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA9eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[9]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA8eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[8]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA7eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[7]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA6eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[6]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA5eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[5]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA4eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[4]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA3eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[3]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA2eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[2]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA1eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[1]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA0eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[0]&&!TGWENA));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB13eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[13]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB12eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[12]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB11eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[11]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB10eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[10]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB9eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[9]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB8eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[8]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB7eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[7]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB6eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[6]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB5eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[5]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB4eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[4]&&!TGWENB));
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
module arm28hkcpdpsram128x14m4_error_injection (Q_out, Q_in, CLK, A, CEN, DFTRAMBYP, SE, WEN, GWEN);
   output [13:0] Q_out;
   input [13:0] Q_in;
   input CLK;
   input [6:0] A;
   input CEN;
   input DFTRAMBYP;
   input SE;
   input [13:0] WEN;
   input GWEN;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter NO_RED_FAULT = 2'd0;
   reg [13:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [15:0] fault_table [31:0];
   reg [15:0] fault_entry;
initial
begin
   `ifdef DUT
      `define pre_pend_path TB.DUT_inst.CHIP
   `else
       `define pre_pend_path TB.CHIP
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST.u1.add_fault(7'd2,4'd4,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
      input [6:0] address;
      input [3:0] bitPlace;
      input [1:0] fault_type;
      input [1:0] red_fault;
 
      integer i;
      reg done;
   begin
      done = 1'b0;
      i = 0;
      while ((!done) && i < 31)
      begin
         fault_entry = fault_table[i];
         if (fault_entry[0] === 1'b0 || fault_entry[0] === 1'bx)
         begin
            fault_entry[0] = 1'b1;
            fault_entry[2:1] = red_fault;
            fault_entry[4:3] = fault_type;
            fault_entry[8:5] = bitPlace;
            fault_entry[15:9] = address;
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
   for (i = 0; i < 32; i=i+1)
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
   inout [13:0] q_int;
   input [1:0] fault_type;
   input [3:0] bitLoc;
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
   output [13:0] Q_output;
   reg list_complete;
   integer i;
   reg [4:0] row_address;
   reg [1:0] column_address;
   reg [3:0] bitPlace;
   reg [1:0] fault_type;
   reg [1:0] red_fault;
   reg valid;
   reg [2:0] msb_bit_calc;
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
            if (row_address == A[6:2] && column_address == A[1:0])
            begin
               if (bitPlace < 7)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 7 )
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
