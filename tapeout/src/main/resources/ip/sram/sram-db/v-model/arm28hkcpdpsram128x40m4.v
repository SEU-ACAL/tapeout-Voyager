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
//       Instance Name:              arm28hkcpdpsram128x40m4
//       Words:                      128
//       Bits:                       40
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
//       Creation Date:  Tue Jul 15 12:23:02 2025
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

module datapath_latch_arm28hkcpdpsram128x40m4 (CLK,Q_update,D_update,SE,SI,D,DFTRAMBYP,mem_path,XQ,Q);
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
endmodule // datapath_latch_arm28hkcpdpsram128x40m4

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
module arm28hkcpdpsram128x40m4 (VDDCE, VDDPE, VSSE, CENYA, WENYA, AYA, CENYB, WENYB,
    AYB, GWENYA, GWENYB, QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB,
    AB, DB, EMAA, EMAWA, EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB,
    TCENB, TWENB, TAB, TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP,
    SIB, SEB, COLLDISN);
`else
module arm28hkcpdpsram128x40m4 (CENYA, WENYA, AYA, CENYB, WENYB, AYB, GWENYA, GWENYB,
    QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA,
    EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB, TCENB, TWENB, TAB,
    TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP, SIB, SEB, COLLDISN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 40;
  parameter WORDS = 128;
  parameter MUX = 4;
  parameter MEM_WIDTH = 160; // redun block size 4, 80 on left, 80 on right
  parameter MEM_HEIGHT = 32;
  parameter WP_SIZE = 1 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENYA;
  output [39:0] WENYA;
  output [6:0] AYA;
  output  CENYB;
  output [39:0] WENYB;
  output [6:0] AYB;
  output  GWENYA;
  output  GWENYB;
  output [39:0] QA;
  output [39:0] QB;
  output [1:0] SOA;
  output [1:0] SOB;
  input  CLKA;
  input  CENA;
  input [39:0] WENA;
  input [6:0] AA;
  input [39:0] DA;
  input  CLKB;
  input  CENB;
  input [39:0] WENB;
  input [6:0] AB;
  input [39:0] DB;
  input [2:0] EMAA;
  input [1:0] EMAWA;
  input  EMASA;
  input [2:0] EMAB;
  input [1:0] EMAWB;
  input  EMASB;
  input  TENA;
  input  TCENA;
  input [39:0] TWENA;
  input [6:0] TAA;
  input [39:0] TDA;
  input  TENB;
  input  TCENB;
  input [39:0] TWENB;
  input [6:0] TAB;
  input [39:0] TDB;
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
  reg [159:0] mem [0:31];
  reg [159:0] row, row_t;
  reg LAST_CLKA;
  reg [159:0] row_mask;
  reg [159:0] new_data;
  reg [159:0] data_out;
  reg [39:0] readLatch0;
  reg [39:0] shifted_readLatch0;
  reg  read_mux_sel0_p2;
  reg [39:0] readLatch1;
  reg [39:0] shifted_readLatch1;
  reg  read_mux_sel1_p2;
  reg LAST_CLKB;
  wire [39:0] QA_int;
  reg XQA, QA_update;
  reg XDA_sh, DA_sh_update;
  wire [39:0] DA_int_bmux;
  reg [39:0] mem_path_A;
  reg [39:0] partial_mask;
  reg [39:0] partial_mask_A;
  reg [39:0] partial_corrupt_A = 40'b0;
  wire [39:0] QB_int;
  reg XQB, QB_update;
  reg XDB_sh, DB_sh_update;
  wire [39:0] DB_int_bmux;
  reg [39:0] mem_path_B;
  reg [39:0] partial_mask_B;
  reg [39:0] partial_corrupt_B = 40'b0;
  reg [39:0] writeEnable;
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
  wire [39:0] WENYA_;
  wire [6:0] AYA_;
  wire  CENYB_;
  wire [39:0] WENYB_;
  wire [6:0] AYB_;
  wire  GWENYA_;
  wire  GWENYB_;
  wire [39:0] QA_;
  wire [39:0] QB_;
  wire [1:0] SOA_;
  wire [1:0] SOB_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire [39:0] WENA_;
  reg [39:0] WENA_int;
  wire [6:0] AA_;
  reg [6:0] AA_int;
  wire [39:0] DA_;
  reg [39:0] DA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire [39:0] WENB_;
  reg [39:0] WENB_int;
  wire [6:0] AB_;
  reg [6:0] AB_int;
  wire [39:0] DB_;
  reg [39:0] DB_int;
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
  wire [39:0] TWENA_;
  reg [39:0] TWENA_int;
  wire [6:0] TAA_;
  reg [6:0] TAA_int;
  wire [39:0] TDA_;
  reg [39:0] TDA_int;
  wire  TENB_;
  reg  TENB_int;
  wire  TCENB_;
  reg  TCENB_int;
  reg  TCENB_p2;
  wire [39:0] TWENB_;
  reg [39:0] TWENB_int;
  wire [6:0] TAB_;
  reg [6:0] TAB_int;
  wire [39:0] TDB_;
  reg [39:0] TDB_int;
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
  assign WENYA[14] = WENYA_[14]; 
  assign WENYA[15] = WENYA_[15]; 
  assign WENYA[16] = WENYA_[16]; 
  assign WENYA[17] = WENYA_[17]; 
  assign WENYA[18] = WENYA_[18]; 
  assign WENYA[19] = WENYA_[19]; 
  assign WENYA[20] = WENYA_[20]; 
  assign WENYA[21] = WENYA_[21]; 
  assign WENYA[22] = WENYA_[22]; 
  assign WENYA[23] = WENYA_[23]; 
  assign WENYA[24] = WENYA_[24]; 
  assign WENYA[25] = WENYA_[25]; 
  assign WENYA[26] = WENYA_[26]; 
  assign WENYA[27] = WENYA_[27]; 
  assign WENYA[28] = WENYA_[28]; 
  assign WENYA[29] = WENYA_[29]; 
  assign WENYA[30] = WENYA_[30]; 
  assign WENYA[31] = WENYA_[31]; 
  assign WENYA[32] = WENYA_[32]; 
  assign WENYA[33] = WENYA_[33]; 
  assign WENYA[34] = WENYA_[34]; 
  assign WENYA[35] = WENYA_[35]; 
  assign WENYA[36] = WENYA_[36]; 
  assign WENYA[37] = WENYA_[37]; 
  assign WENYA[38] = WENYA_[38]; 
  assign WENYA[39] = WENYA_[39]; 
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
  assign WENYB[14] = WENYB_[14]; 
  assign WENYB[15] = WENYB_[15]; 
  assign WENYB[16] = WENYB_[16]; 
  assign WENYB[17] = WENYB_[17]; 
  assign WENYB[18] = WENYB_[18]; 
  assign WENYB[19] = WENYB_[19]; 
  assign WENYB[20] = WENYB_[20]; 
  assign WENYB[21] = WENYB_[21]; 
  assign WENYB[22] = WENYB_[22]; 
  assign WENYB[23] = WENYB_[23]; 
  assign WENYB[24] = WENYB_[24]; 
  assign WENYB[25] = WENYB_[25]; 
  assign WENYB[26] = WENYB_[26]; 
  assign WENYB[27] = WENYB_[27]; 
  assign WENYB[28] = WENYB_[28]; 
  assign WENYB[29] = WENYB_[29]; 
  assign WENYB[30] = WENYB_[30]; 
  assign WENYB[31] = WENYB_[31]; 
  assign WENYB[32] = WENYB_[32]; 
  assign WENYB[33] = WENYB_[33]; 
  assign WENYB[34] = WENYB_[34]; 
  assign WENYB[35] = WENYB_[35]; 
  assign WENYB[36] = WENYB_[36]; 
  assign WENYB[37] = WENYB_[37]; 
  assign WENYB[38] = WENYB_[38]; 
  assign WENYB[39] = WENYB_[39]; 
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
  assign QA[14] = QA_[14]; 
  assign QA[15] = QA_[15]; 
  assign QA[16] = QA_[16]; 
  assign QA[17] = QA_[17]; 
  assign QA[18] = QA_[18]; 
  assign QA[19] = QA_[19]; 
  assign QA[20] = QA_[20]; 
  assign QA[21] = QA_[21]; 
  assign QA[22] = QA_[22]; 
  assign QA[23] = QA_[23]; 
  assign QA[24] = QA_[24]; 
  assign QA[25] = QA_[25]; 
  assign QA[26] = QA_[26]; 
  assign QA[27] = QA_[27]; 
  assign QA[28] = QA_[28]; 
  assign QA[29] = QA_[29]; 
  assign QA[30] = QA_[30]; 
  assign QA[31] = QA_[31]; 
  assign QA[32] = QA_[32]; 
  assign QA[33] = QA_[33]; 
  assign QA[34] = QA_[34]; 
  assign QA[35] = QA_[35]; 
  assign QA[36] = QA_[36]; 
  assign QA[37] = QA_[37]; 
  assign QA[38] = QA_[38]; 
  assign QA[39] = QA_[39]; 
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
  assign QB[14] = QB_[14]; 
  assign QB[15] = QB_[15]; 
  assign QB[16] = QB_[16]; 
  assign QB[17] = QB_[17]; 
  assign QB[18] = QB_[18]; 
  assign QB[19] = QB_[19]; 
  assign QB[20] = QB_[20]; 
  assign QB[21] = QB_[21]; 
  assign QB[22] = QB_[22]; 
  assign QB[23] = QB_[23]; 
  assign QB[24] = QB_[24]; 
  assign QB[25] = QB_[25]; 
  assign QB[26] = QB_[26]; 
  assign QB[27] = QB_[27]; 
  assign QB[28] = QB_[28]; 
  assign QB[29] = QB_[29]; 
  assign QB[30] = QB_[30]; 
  assign QB[31] = QB_[31]; 
  assign QB[32] = QB_[32]; 
  assign QB[33] = QB_[33]; 
  assign QB[34] = QB_[34]; 
  assign QB[35] = QB_[35]; 
  assign QB[36] = QB_[36]; 
  assign QB[37] = QB_[37]; 
  assign QB[38] = QB_[38]; 
  assign QB[39] = QB_[39]; 
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
  assign WENA_[14] = WENA[14];
  assign WENA_[15] = WENA[15];
  assign WENA_[16] = WENA[16];
  assign WENA_[17] = WENA[17];
  assign WENA_[18] = WENA[18];
  assign WENA_[19] = WENA[19];
  assign WENA_[20] = WENA[20];
  assign WENA_[21] = WENA[21];
  assign WENA_[22] = WENA[22];
  assign WENA_[23] = WENA[23];
  assign WENA_[24] = WENA[24];
  assign WENA_[25] = WENA[25];
  assign WENA_[26] = WENA[26];
  assign WENA_[27] = WENA[27];
  assign WENA_[28] = WENA[28];
  assign WENA_[29] = WENA[29];
  assign WENA_[30] = WENA[30];
  assign WENA_[31] = WENA[31];
  assign WENA_[32] = WENA[32];
  assign WENA_[33] = WENA[33];
  assign WENA_[34] = WENA[34];
  assign WENA_[35] = WENA[35];
  assign WENA_[36] = WENA[36];
  assign WENA_[37] = WENA[37];
  assign WENA_[38] = WENA[38];
  assign WENA_[39] = WENA[39];
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
  assign DA_[14] = DA[14];
  assign DA_[15] = DA[15];
  assign DA_[16] = DA[16];
  assign DA_[17] = DA[17];
  assign DA_[18] = DA[18];
  assign DA_[19] = DA[19];
  assign DA_[20] = DA[20];
  assign DA_[21] = DA[21];
  assign DA_[22] = DA[22];
  assign DA_[23] = DA[23];
  assign DA_[24] = DA[24];
  assign DA_[25] = DA[25];
  assign DA_[26] = DA[26];
  assign DA_[27] = DA[27];
  assign DA_[28] = DA[28];
  assign DA_[29] = DA[29];
  assign DA_[30] = DA[30];
  assign DA_[31] = DA[31];
  assign DA_[32] = DA[32];
  assign DA_[33] = DA[33];
  assign DA_[34] = DA[34];
  assign DA_[35] = DA[35];
  assign DA_[36] = DA[36];
  assign DA_[37] = DA[37];
  assign DA_[38] = DA[38];
  assign DA_[39] = DA[39];
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
  assign WENB_[14] = WENB[14];
  assign WENB_[15] = WENB[15];
  assign WENB_[16] = WENB[16];
  assign WENB_[17] = WENB[17];
  assign WENB_[18] = WENB[18];
  assign WENB_[19] = WENB[19];
  assign WENB_[20] = WENB[20];
  assign WENB_[21] = WENB[21];
  assign WENB_[22] = WENB[22];
  assign WENB_[23] = WENB[23];
  assign WENB_[24] = WENB[24];
  assign WENB_[25] = WENB[25];
  assign WENB_[26] = WENB[26];
  assign WENB_[27] = WENB[27];
  assign WENB_[28] = WENB[28];
  assign WENB_[29] = WENB[29];
  assign WENB_[30] = WENB[30];
  assign WENB_[31] = WENB[31];
  assign WENB_[32] = WENB[32];
  assign WENB_[33] = WENB[33];
  assign WENB_[34] = WENB[34];
  assign WENB_[35] = WENB[35];
  assign WENB_[36] = WENB[36];
  assign WENB_[37] = WENB[37];
  assign WENB_[38] = WENB[38];
  assign WENB_[39] = WENB[39];
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
  assign DB_[14] = DB[14];
  assign DB_[15] = DB[15];
  assign DB_[16] = DB[16];
  assign DB_[17] = DB[17];
  assign DB_[18] = DB[18];
  assign DB_[19] = DB[19];
  assign DB_[20] = DB[20];
  assign DB_[21] = DB[21];
  assign DB_[22] = DB[22];
  assign DB_[23] = DB[23];
  assign DB_[24] = DB[24];
  assign DB_[25] = DB[25];
  assign DB_[26] = DB[26];
  assign DB_[27] = DB[27];
  assign DB_[28] = DB[28];
  assign DB_[29] = DB[29];
  assign DB_[30] = DB[30];
  assign DB_[31] = DB[31];
  assign DB_[32] = DB[32];
  assign DB_[33] = DB[33];
  assign DB_[34] = DB[34];
  assign DB_[35] = DB[35];
  assign DB_[36] = DB[36];
  assign DB_[37] = DB[37];
  assign DB_[38] = DB[38];
  assign DB_[39] = DB[39];
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
  assign TWENA_[14] = TWENA[14];
  assign TWENA_[15] = TWENA[15];
  assign TWENA_[16] = TWENA[16];
  assign TWENA_[17] = TWENA[17];
  assign TWENA_[18] = TWENA[18];
  assign TWENA_[19] = TWENA[19];
  assign TWENA_[20] = TWENA[20];
  assign TWENA_[21] = TWENA[21];
  assign TWENA_[22] = TWENA[22];
  assign TWENA_[23] = TWENA[23];
  assign TWENA_[24] = TWENA[24];
  assign TWENA_[25] = TWENA[25];
  assign TWENA_[26] = TWENA[26];
  assign TWENA_[27] = TWENA[27];
  assign TWENA_[28] = TWENA[28];
  assign TWENA_[29] = TWENA[29];
  assign TWENA_[30] = TWENA[30];
  assign TWENA_[31] = TWENA[31];
  assign TWENA_[32] = TWENA[32];
  assign TWENA_[33] = TWENA[33];
  assign TWENA_[34] = TWENA[34];
  assign TWENA_[35] = TWENA[35];
  assign TWENA_[36] = TWENA[36];
  assign TWENA_[37] = TWENA[37];
  assign TWENA_[38] = TWENA[38];
  assign TWENA_[39] = TWENA[39];
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
  assign TDA_[14] = TDA[14];
  assign TDA_[15] = TDA[15];
  assign TDA_[16] = TDA[16];
  assign TDA_[17] = TDA[17];
  assign TDA_[18] = TDA[18];
  assign TDA_[19] = TDA[19];
  assign TDA_[20] = TDA[20];
  assign TDA_[21] = TDA[21];
  assign TDA_[22] = TDA[22];
  assign TDA_[23] = TDA[23];
  assign TDA_[24] = TDA[24];
  assign TDA_[25] = TDA[25];
  assign TDA_[26] = TDA[26];
  assign TDA_[27] = TDA[27];
  assign TDA_[28] = TDA[28];
  assign TDA_[29] = TDA[29];
  assign TDA_[30] = TDA[30];
  assign TDA_[31] = TDA[31];
  assign TDA_[32] = TDA[32];
  assign TDA_[33] = TDA[33];
  assign TDA_[34] = TDA[34];
  assign TDA_[35] = TDA[35];
  assign TDA_[36] = TDA[36];
  assign TDA_[37] = TDA[37];
  assign TDA_[38] = TDA[38];
  assign TDA_[39] = TDA[39];
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
  assign TWENB_[14] = TWENB[14];
  assign TWENB_[15] = TWENB[15];
  assign TWENB_[16] = TWENB[16];
  assign TWENB_[17] = TWENB[17];
  assign TWENB_[18] = TWENB[18];
  assign TWENB_[19] = TWENB[19];
  assign TWENB_[20] = TWENB[20];
  assign TWENB_[21] = TWENB[21];
  assign TWENB_[22] = TWENB[22];
  assign TWENB_[23] = TWENB[23];
  assign TWENB_[24] = TWENB[24];
  assign TWENB_[25] = TWENB[25];
  assign TWENB_[26] = TWENB[26];
  assign TWENB_[27] = TWENB[27];
  assign TWENB_[28] = TWENB[28];
  assign TWENB_[29] = TWENB[29];
  assign TWENB_[30] = TWENB[30];
  assign TWENB_[31] = TWENB[31];
  assign TWENB_[32] = TWENB[32];
  assign TWENB_[33] = TWENB[33];
  assign TWENB_[34] = TWENB[34];
  assign TWENB_[35] = TWENB[35];
  assign TWENB_[36] = TWENB[36];
  assign TWENB_[37] = TWENB[37];
  assign TWENB_[38] = TWENB[38];
  assign TWENB_[39] = TWENB[39];
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
  assign TDB_[14] = TDB[14];
  assign TDB_[15] = TDB[15];
  assign TDB_[16] = TDB[16];
  assign TDB_[17] = TDB[17];
  assign TDB_[18] = TDB[18];
  assign TDB_[19] = TDB[19];
  assign TDB_[20] = TDB[20];
  assign TDB_[21] = TDB[21];
  assign TDB_[22] = TDB[22];
  assign TDB_[23] = TDB[23];
  assign TDB_[24] = TDB[24];
  assign TDB_[25] = TDB[25];
  assign TDB_[26] = TDB[26];
  assign TDB_[27] = TDB[27];
  assign TDB_[28] = TDB[28];
  assign TDB_[29] = TDB[29];
  assign TDB_[30] = TDB[30];
  assign TDB_[31] = TDB[31];
  assign TDB_[32] = TDB[32];
  assign TDB_[33] = TDB[33];
  assign TDB_[34] = TDB[34];
  assign TDB_[35] = TDB[35];
  assign TDB_[36] = TDB[36];
  assign TDB_[37] = TDB[37];
  assign TDB_[38] = TDB[38];
  assign TDB_[39] = TDB[39];
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
  assign `ARM_UD_DP WENYA_ = (RET1N_ | pre_charge_st) ? ({40{DFTRAMBYP_}} & (TENA_ ? WENA_ : TWENA_)) : {40{1'bx}};
  assign `ARM_UD_DP AYA_ = (RET1N_ | pre_charge_st) ? ({7{DFTRAMBYP_}} & (TENA_ ? AA_ : TAA_)) : {7{1'bx}};
  assign `ARM_UD_DP CENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? CENB_ : TCENB_)) : 1'bx;
  assign `ARM_UD_DP WENYB_ = (RET1N_ | pre_charge_st) ? ({40{DFTRAMBYP_}} & (TENB_ ? WENB_ : TWENB_)) : {40{1'bx}};
  assign `ARM_UD_DP AYB_ = (RET1N_ | pre_charge_st) ? ({7{DFTRAMBYP_}} & (TENB_ ? AB_ : TAB_)) : {7{1'bx}};
  assign `ARM_UD_DP GWENYA_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENA_ ? GWENA_ : TGWENA_)) : 1'bx;
  assign `ARM_UD_DP GWENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? GWENB_ : TGWENB_)) : 1'bx;
   `ifdef ARM_FAULT_MODELING
     arm28hkcpdpsram128x40m4_error_injection u1(.CLK(CLKA_), .Q_out(QA_), .A(AA_int), .CEN(CENA_int), .DFTRAMBYP(DFTRAMBYP_int), .SE(SEA_int), .GWEN(GWENA_int), .WEN(WENA_int), .Q_in(QA_int));
  `else
  assign `ARM_UD_SEQ QA_ = (RET1N_ | pre_charge_st) ? ((QA_int)) : {40{1'bx}};
  `endif
  assign `ARM_UD_SEQ QB_ = (RET1N_ | pre_charge_st) ? ((QB_int)) : {40{1'bx}};
  assign `ARM_UD_DP SOA_ = (RET1N_ | pre_charge_st) ? ({QA_[20], QA_[19]}) : {2{1'bx}};
  assign `ARM_UD_DP SOB_ = (RET1N_ | pre_charge_st) ? ({QB_[20], QB_[19]}) : {2{1'bx}};

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
        writeEnable = {40{1'b1}};
        row_mask =  ( {3'b000, writeEnable[39], 3'b000, writeEnable[38], 3'b000, writeEnable[37],
          3'b000, writeEnable[36], 3'b000, writeEnable[35], 3'b000, writeEnable[34],
          3'b000, writeEnable[33], 3'b000, writeEnable[32], 3'b000, writeEnable[31],
          3'b000, writeEnable[30], 3'b000, writeEnable[29], 3'b000, writeEnable[28],
          3'b000, writeEnable[27], 3'b000, writeEnable[26], 3'b000, writeEnable[25],
          3'b000, writeEnable[24], 3'b000, writeEnable[23], 3'b000, writeEnable[22],
          3'b000, writeEnable[21], 3'b000, writeEnable[20], 3'b000, writeEnable[19],
          3'b000, writeEnable[18], 3'b000, writeEnable[17], 3'b000, writeEnable[16],
          3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[39], 3'b000, wordtemp[38], 3'b000, wordtemp[37],
          3'b000, wordtemp[36], 3'b000, wordtemp[35], 3'b000, wordtemp[34], 3'b000, wordtemp[33],
          3'b000, wordtemp[32], 3'b000, wordtemp[31], 3'b000, wordtemp[30], 3'b000, wordtemp[29],
          3'b000, wordtemp[28], 3'b000, wordtemp[27], 3'b000, wordtemp[26], 3'b000, wordtemp[25],
          3'b000, wordtemp[24], 3'b000, wordtemp[23], 3'b000, wordtemp[22], 3'b000, wordtemp[21],
          3'b000, wordtemp[20], 3'b000, wordtemp[19], 3'b000, wordtemp[18], 3'b000, wordtemp[17],
          3'b000, wordtemp[16], 3'b000, wordtemp[15], 3'b000, wordtemp[14], 3'b000, wordtemp[13],
          3'b000, wordtemp[12], 3'b000, wordtemp[11], 3'b000, wordtemp[10], 3'b000, wordtemp[9],
          3'b000, wordtemp[8], 3'b000, wordtemp[7], 3'b000, wordtemp[6], 3'b000, wordtemp[5],
          3'b000, wordtemp[4], 3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
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
        writeEnable = {40{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
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
	input [6:0] load_addr;
	input [39:0] load_data;
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
        writeEnable = {40{1'b1}};
        row_mask =  ( {3'b000, writeEnable[39], 3'b000, writeEnable[38], 3'b000, writeEnable[37],
          3'b000, writeEnable[36], 3'b000, writeEnable[35], 3'b000, writeEnable[34],
          3'b000, writeEnable[33], 3'b000, writeEnable[32], 3'b000, writeEnable[31],
          3'b000, writeEnable[30], 3'b000, writeEnable[29], 3'b000, writeEnable[28],
          3'b000, writeEnable[27], 3'b000, writeEnable[26], 3'b000, writeEnable[25],
          3'b000, writeEnable[24], 3'b000, writeEnable[23], 3'b000, writeEnable[22],
          3'b000, writeEnable[21], 3'b000, writeEnable[20], 3'b000, writeEnable[19],
          3'b000, writeEnable[18], 3'b000, writeEnable[17], 3'b000, writeEnable[16],
          3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[39], 3'b000, wordtemp[38], 3'b000, wordtemp[37],
          3'b000, wordtemp[36], 3'b000, wordtemp[35], 3'b000, wordtemp[34], 3'b000, wordtemp[33],
          3'b000, wordtemp[32], 3'b000, wordtemp[31], 3'b000, wordtemp[30], 3'b000, wordtemp[29],
          3'b000, wordtemp[28], 3'b000, wordtemp[27], 3'b000, wordtemp[26], 3'b000, wordtemp[25],
          3'b000, wordtemp[24], 3'b000, wordtemp[23], 3'b000, wordtemp[22], 3'b000, wordtemp[21],
          3'b000, wordtemp[20], 3'b000, wordtemp[19], 3'b000, wordtemp[18], 3'b000, wordtemp[17],
          3'b000, wordtemp[16], 3'b000, wordtemp[15], 3'b000, wordtemp[14], 3'b000, wordtemp[13],
          3'b000, wordtemp[12], 3'b000, wordtemp[11], 3'b000, wordtemp[10], 3'b000, wordtemp[9],
          3'b000, wordtemp[8], 3'b000, wordtemp[7], 3'b000, wordtemp[6], 3'b000, wordtemp[5],
          3'b000, wordtemp[4], 3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
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
	output [39:0] dump_data;
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
        writeEnable = {40{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
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
        DA_int = {40{1'bx}};

      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 31)
        row = {160{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENA_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {40{1'bx}};
        DA_int = {40{1'bx}};
      end else
          writeEnable = ~ ( {40{GWENA_int}} | {WENA_int[39], WENA_int[38], WENA_int[37],
          WENA_int[36], WENA_int[35], WENA_int[34], WENA_int[33], WENA_int[32], WENA_int[31],
          WENA_int[30], WENA_int[29], WENA_int[28], WENA_int[27], WENA_int[26], WENA_int[25],
          WENA_int[24], WENA_int[23], WENA_int[22], WENA_int[21], WENA_int[20], WENA_int[19],
          WENA_int[18], WENA_int[17], WENA_int[16], WENA_int[15], WENA_int[14], WENA_int[13],
          WENA_int[12], WENA_int[11], WENA_int[10], WENA_int[9], WENA_int[8], WENA_int[7],
          WENA_int[6], WENA_int[5], WENA_int[4], WENA_int[3], WENA_int[2], WENA_int[1],
          WENA_int[0]});
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[39], 3'b000, writeEnable[38], 3'b000, writeEnable[37],
          3'b000, writeEnable[36], 3'b000, writeEnable[35], 3'b000, writeEnable[34],
          3'b000, writeEnable[33], 3'b000, writeEnable[32], 3'b000, writeEnable[31],
          3'b000, writeEnable[30], 3'b000, writeEnable[29], 3'b000, writeEnable[28],
          3'b000, writeEnable[27], 3'b000, writeEnable[26], 3'b000, writeEnable[25],
          3'b000, writeEnable[24], 3'b000, writeEnable[23], 3'b000, writeEnable[22],
          3'b000, writeEnable[21], 3'b000, writeEnable[20], 3'b000, writeEnable[19],
          3'b000, writeEnable[18], 3'b000, writeEnable[17], 3'b000, writeEnable[16],
          3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DA_int[39], 3'b000, DA_int[38], 3'b000, DA_int[37],
          3'b000, DA_int[36], 3'b000, DA_int[35], 3'b000, DA_int[34], 3'b000, DA_int[33],
          3'b000, DA_int[32], 3'b000, DA_int[31], 3'b000, DA_int[30], 3'b000, DA_int[29],
          3'b000, DA_int[28], 3'b000, DA_int[27], 3'b000, DA_int[26], 3'b000, DA_int[25],
          3'b000, DA_int[24], 3'b000, DA_int[23], 3'b000, DA_int[22], 3'b000, DA_int[21],
          3'b000, DA_int[20], 3'b000, DA_int[19], 3'b000, DA_int[18], 3'b000, DA_int[17],
          3'b000, DA_int[16], 3'b000, DA_int[15], 3'b000, DA_int[14], 3'b000, DA_int[13],
          3'b000, DA_int[12], 3'b000, DA_int[11], 3'b000, DA_int[10], 3'b000, DA_int[9],
          3'b000, DA_int[8], 3'b000, DA_int[7], 3'b000, DA_int[6], 3'b000, DA_int[5],
          3'b000, DA_int[4], 3'b000, DA_int[3], 3'b000, DA_int[2], 3'b000, DA_int[1],
          3'b000, DA_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEA_int === 1'b0) begin
        end else if (GWENA_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEA_int === 1'bx) begin
        	XQA = 1'b1; QA_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
      end
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QA_update = 1'b1; DA_sh_update = 1'b1;
        end else begin
          XQA = 1'b0; QA_update = 1'b1; DA_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
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
      WENA_int = {40{1'bx}};
      AA_int = {7{1'bx}};
      DA_int = {40{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {40{1'bx}};
      TAA_int = {7{1'bx}};
      TDA_int = {40{1'bx}};
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
      WENA_int = {40{1'bx}};
      AA_int = {7{1'bx}};
      DA_int = {40{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {40{1'bx}};
      TAA_int = {7{1'bx}};
      TDA_int = {40{1'bx}};
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
        AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({40{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({40{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENA_int[39], WENA_int[38], WENA_int[37], WENA_int[36],
            WENA_int[35], WENA_int[34], WENA_int[33], WENA_int[32], WENA_int[31], WENA_int[30],
            WENA_int[29], WENA_int[28], WENA_int[27], WENA_int[26], WENA_int[25], WENA_int[24],
            WENA_int[23], WENA_int[22], WENA_int[21], WENA_int[20], WENA_int[19], WENA_int[18],
            WENA_int[17], WENA_int[16], WENA_int[15], WENA_int[14], WENA_int[13], WENA_int[12],
            WENA_int[11], WENA_int[10], WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6],
            WENA_int[5], WENA_int[4], WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENB_int[39], WENB_int[38], WENB_int[37], WENB_int[36],
            WENB_int[35], WENB_int[34], WENB_int[33], WENB_int[32], WENB_int[31], WENB_int[30],
            WENB_int[29], WENB_int[28], WENB_int[27], WENB_int[26], WENB_int[25], WENB_int[24],
            WENB_int[23], WENB_int[22], WENB_int[21], WENB_int[20], WENB_int[19], WENB_int[18],
            WENB_int[17], WENB_int[16], WENB_int[15], WENB_int[14], WENB_int[13], WENB_int[12],
            WENB_int[11], WENB_int[10], WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6],
            WENB_int[5], WENB_int[4], WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
       === 1'bx)  && row_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
          DB_int = {40{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
          DA_int = {40{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
      partial_corrupt_A = 40'b0;
      QA_update = 1'b0;
      DA_sh_update = 1'b0;
      XQA = 1'b0;
    end
  end
    LAST_CLKA = CLKA_;
  end

  assign SIA_int = SEA_ ? SIA_ : {2{1'b0}};
  assign DA_int_bmux = TENA_ ? DA_ : TDA_;

  datapath_latch_arm28hkcpdpsram128x40m4 uDQA0 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[0]), .D(DA_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[0]), .XQ(XQA|partial_corrupt_A[0]), .Q(QA_int[0]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA1 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[0]), .D(DA_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[1]), .XQ(XQA|partial_corrupt_A[1]), .Q(QA_int[1]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA2 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[1]), .D(DA_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[2]), .XQ(XQA|partial_corrupt_A[2]), .Q(QA_int[2]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA3 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[2]), .D(DA_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[3]), .XQ(XQA|partial_corrupt_A[3]), .Q(QA_int[3]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA4 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[3]), .D(DA_int_bmux[4]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[4]), .XQ(XQA|partial_corrupt_A[4]), .Q(QA_int[4]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA5 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[4]), .D(DA_int_bmux[5]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[5]), .XQ(XQA|partial_corrupt_A[5]), .Q(QA_int[5]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA6 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[5]), .D(DA_int_bmux[6]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[6]), .XQ(XQA|partial_corrupt_A[6]), .Q(QA_int[6]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA7 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[6]), .D(DA_int_bmux[7]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[7]), .XQ(XQA|partial_corrupt_A[7]), .Q(QA_int[7]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA8 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[7]), .D(DA_int_bmux[8]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[8]), .XQ(XQA|partial_corrupt_A[8]), .Q(QA_int[8]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA9 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[8]), .D(DA_int_bmux[9]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[9]), .XQ(XQA|partial_corrupt_A[9]), .Q(QA_int[9]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA10 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[9]), .D(DA_int_bmux[10]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[10]), .XQ(XQA|partial_corrupt_A[10]), .Q(QA_int[10]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA11 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[10]), .D(DA_int_bmux[11]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[11]), .XQ(XQA|partial_corrupt_A[11]), .Q(QA_int[11]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA12 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[11]), .D(DA_int_bmux[12]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[12]), .XQ(XQA|partial_corrupt_A[12]), .Q(QA_int[12]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA13 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[12]), .D(DA_int_bmux[13]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[13]), .XQ(XQA|partial_corrupt_A[13]), .Q(QA_int[13]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA14 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[13]), .D(DA_int_bmux[14]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[14]), .XQ(XQA|partial_corrupt_A[14]), .Q(QA_int[14]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA15 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[14]), .D(DA_int_bmux[15]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[15]), .XQ(XQA|partial_corrupt_A[15]), .Q(QA_int[15]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA16 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[15]), .D(DA_int_bmux[16]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[16]), .XQ(XQA|partial_corrupt_A[16]), .Q(QA_int[16]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA17 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[16]), .D(DA_int_bmux[17]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[17]), .XQ(XQA|partial_corrupt_A[17]), .Q(QA_int[17]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA18 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[17]), .D(DA_int_bmux[18]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[18]), .XQ(XQA|partial_corrupt_A[18]), .Q(QA_int[18]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA19 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[18]), .D(DA_int_bmux[19]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[19]), .XQ(XQA|partial_corrupt_A[19]), .Q(QA_int[19]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA20 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[21]), .D(DA_int_bmux[20]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[20]), .XQ(XQA|partial_corrupt_A[20]), .Q(QA_int[20]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA21 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[22]), .D(DA_int_bmux[21]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[21]), .XQ(XQA|partial_corrupt_A[21]), .Q(QA_int[21]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA22 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[23]), .D(DA_int_bmux[22]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[22]), .XQ(XQA|partial_corrupt_A[22]), .Q(QA_int[22]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA23 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[24]), .D(DA_int_bmux[23]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[23]), .XQ(XQA|partial_corrupt_A[23]), .Q(QA_int[23]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA24 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[25]), .D(DA_int_bmux[24]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[24]), .XQ(XQA|partial_corrupt_A[24]), .Q(QA_int[24]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA25 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[26]), .D(DA_int_bmux[25]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[25]), .XQ(XQA|partial_corrupt_A[25]), .Q(QA_int[25]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA26 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[27]), .D(DA_int_bmux[26]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[26]), .XQ(XQA|partial_corrupt_A[26]), .Q(QA_int[26]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA27 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[28]), .D(DA_int_bmux[27]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[27]), .XQ(XQA|partial_corrupt_A[27]), .Q(QA_int[27]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA28 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[29]), .D(DA_int_bmux[28]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[28]), .XQ(XQA|partial_corrupt_A[28]), .Q(QA_int[28]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA29 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[30]), .D(DA_int_bmux[29]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[29]), .XQ(XQA|partial_corrupt_A[29]), .Q(QA_int[29]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA30 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[31]), .D(DA_int_bmux[30]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[30]), .XQ(XQA|partial_corrupt_A[30]), .Q(QA_int[30]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA31 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[32]), .D(DA_int_bmux[31]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[31]), .XQ(XQA|partial_corrupt_A[31]), .Q(QA_int[31]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA32 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[33]), .D(DA_int_bmux[32]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[32]), .XQ(XQA|partial_corrupt_A[32]), .Q(QA_int[32]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA33 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[34]), .D(DA_int_bmux[33]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[33]), .XQ(XQA|partial_corrupt_A[33]), .Q(QA_int[33]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA34 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[35]), .D(DA_int_bmux[34]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[34]), .XQ(XQA|partial_corrupt_A[34]), .Q(QA_int[34]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA35 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[36]), .D(DA_int_bmux[35]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[35]), .XQ(XQA|partial_corrupt_A[35]), .Q(QA_int[35]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA36 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[37]), .D(DA_int_bmux[36]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[36]), .XQ(XQA|partial_corrupt_A[36]), .Q(QA_int[36]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA37 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[38]), .D(DA_int_bmux[37]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[37]), .XQ(XQA|partial_corrupt_A[37]), .Q(QA_int[37]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA38 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[39]), .D(DA_int_bmux[38]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[38]), .XQ(XQA|partial_corrupt_A[38]), .Q(QA_int[38]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA39 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[1]), .D(DA_int_bmux[39]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[39]), .XQ(XQA|partial_corrupt_A[39]), .Q(QA_int[39]));



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
        DB_int = {40{1'bx}};

      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 31)
        row = {160{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENB_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {40{1'bx}};
        DB_int = {40{1'bx}};
      end else
          writeEnable = ~ ( {40{GWENB_int}} | {WENB_int[39], WENB_int[38], WENB_int[37],
          WENB_int[36], WENB_int[35], WENB_int[34], WENB_int[33], WENB_int[32], WENB_int[31],
          WENB_int[30], WENB_int[29], WENB_int[28], WENB_int[27], WENB_int[26], WENB_int[25],
          WENB_int[24], WENB_int[23], WENB_int[22], WENB_int[21], WENB_int[20], WENB_int[19],
          WENB_int[18], WENB_int[17], WENB_int[16], WENB_int[15], WENB_int[14], WENB_int[13],
          WENB_int[12], WENB_int[11], WENB_int[10], WENB_int[9], WENB_int[8], WENB_int[7],
          WENB_int[6], WENB_int[5], WENB_int[4], WENB_int[3], WENB_int[2], WENB_int[1],
          WENB_int[0]});
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[39], 3'b000, writeEnable[38], 3'b000, writeEnable[37],
          3'b000, writeEnable[36], 3'b000, writeEnable[35], 3'b000, writeEnable[34],
          3'b000, writeEnable[33], 3'b000, writeEnable[32], 3'b000, writeEnable[31],
          3'b000, writeEnable[30], 3'b000, writeEnable[29], 3'b000, writeEnable[28],
          3'b000, writeEnable[27], 3'b000, writeEnable[26], 3'b000, writeEnable[25],
          3'b000, writeEnable[24], 3'b000, writeEnable[23], 3'b000, writeEnable[22],
          3'b000, writeEnable[21], 3'b000, writeEnable[20], 3'b000, writeEnable[19],
          3'b000, writeEnable[18], 3'b000, writeEnable[17], 3'b000, writeEnable[16],
          3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DB_int[39], 3'b000, DB_int[38], 3'b000, DB_int[37],
          3'b000, DB_int[36], 3'b000, DB_int[35], 3'b000, DB_int[34], 3'b000, DB_int[33],
          3'b000, DB_int[32], 3'b000, DB_int[31], 3'b000, DB_int[30], 3'b000, DB_int[29],
          3'b000, DB_int[28], 3'b000, DB_int[27], 3'b000, DB_int[26], 3'b000, DB_int[25],
          3'b000, DB_int[24], 3'b000, DB_int[23], 3'b000, DB_int[22], 3'b000, DB_int[21],
          3'b000, DB_int[20], 3'b000, DB_int[19], 3'b000, DB_int[18], 3'b000, DB_int[17],
          3'b000, DB_int[16], 3'b000, DB_int[15], 3'b000, DB_int[14], 3'b000, DB_int[13],
          3'b000, DB_int[12], 3'b000, DB_int[11], 3'b000, DB_int[10], 3'b000, DB_int[9],
          3'b000, DB_int[8], 3'b000, DB_int[7], 3'b000, DB_int[6], 3'b000, DB_int[5],
          3'b000, DB_int[4], 3'b000, DB_int[3], 3'b000, DB_int[2], 3'b000, DB_int[1],
          3'b000, DB_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEB_int === 1'b0) begin
        end else if (GWENB_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEB_int === 1'bx) begin
        	XQB = 1'b1; QB_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
      end
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QB_update = 1'b1; DB_sh_update = 1'b1;
        end else begin
          XQB = 1'b0; QB_update = 1'b1; DB_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch1 = readLatch1;
        mem_path_B = {shifted_readLatch1[39], shifted_readLatch1[38], shifted_readLatch1[37],
          shifted_readLatch1[36], shifted_readLatch1[35], shifted_readLatch1[34], shifted_readLatch1[33],
          shifted_readLatch1[32], shifted_readLatch1[31], shifted_readLatch1[30], shifted_readLatch1[29],
          shifted_readLatch1[28], shifted_readLatch1[27], shifted_readLatch1[26], shifted_readLatch1[25],
          shifted_readLatch1[24], shifted_readLatch1[23], shifted_readLatch1[22], shifted_readLatch1[21],
          shifted_readLatch1[20], shifted_readLatch1[19], shifted_readLatch1[18], shifted_readLatch1[17],
          shifted_readLatch1[16], shifted_readLatch1[15], shifted_readLatch1[14], shifted_readLatch1[13],
          shifted_readLatch1[12], shifted_readLatch1[11], shifted_readLatch1[10], shifted_readLatch1[9],
          shifted_readLatch1[8], shifted_readLatch1[7], shifted_readLatch1[6], shifted_readLatch1[5],
          shifted_readLatch1[4], shifted_readLatch1[3], shifted_readLatch1[2], shifted_readLatch1[1],
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
      WENB_int = {40{1'bx}};
      AB_int = {7{1'bx}};
      DB_int = {40{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {40{1'bx}};
      TAB_int = {7{1'bx}};
      TDB_int = {40{1'bx}};
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
      WENB_int = {40{1'bx}};
      AB_int = {7{1'bx}};
      DB_int = {40{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {40{1'bx}};
      TAB_int = {7{1'bx}};
      TDB_int = {40{1'bx}};
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
        AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({40{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({40{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENA_int[39], WENA_int[38], WENA_int[37], WENA_int[36],
            WENA_int[35], WENA_int[34], WENA_int[33], WENA_int[32], WENA_int[31], WENA_int[30],
            WENA_int[29], WENA_int[28], WENA_int[27], WENA_int[26], WENA_int[25], WENA_int[24],
            WENA_int[23], WENA_int[22], WENA_int[21], WENA_int[20], WENA_int[19], WENA_int[18],
            WENA_int[17], WENA_int[16], WENA_int[15], WENA_int[14], WENA_int[13], WENA_int[12],
            WENA_int[11], WENA_int[10], WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6],
            WENA_int[5], WENA_int[4], WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENB_int[39], WENB_int[38], WENB_int[37], WENB_int[36],
            WENB_int[35], WENB_int[34], WENB_int[33], WENB_int[32], WENB_int[31], WENB_int[30],
            WENB_int[29], WENB_int[28], WENB_int[27], WENB_int[26], WENB_int[25], WENB_int[24],
            WENB_int[23], WENB_int[22], WENB_int[21], WENB_int[20], WENB_int[19], WENB_int[18],
            WENB_int[17], WENB_int[16], WENB_int[15], WENB_int[14], WENB_int[13], WENB_int[12],
            WENB_int[11], WENB_int[10], WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6],
            WENB_int[5], WENB_int[4], WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
       === 1'bx)  && row_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
          DA_int = {40{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
          DB_int = {40{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
      partial_corrupt_A = 40'b0;
      QB_update = 1'b0;
      DB_sh_update = 1'b0;
      XQB = 1'b0;
    end
  end
    LAST_CLKB = CLKB_;
  end

  assign SIB_int = SEB_ ? SIB_ : {2{1'b0}};
  assign DB_int_bmux = TENB_ ? DB_ : TDB_;

  datapath_latch_arm28hkcpdpsram128x40m4 uDQB0 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[0]), .D(DB_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[0]), .XQ(XQB|partial_corrupt_A[0]), .Q(QB_int[0]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB1 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[0]), .D(DB_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[1]), .XQ(XQB|partial_corrupt_A[1]), .Q(QB_int[1]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB2 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[1]), .D(DB_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[2]), .XQ(XQB|partial_corrupt_A[2]), .Q(QB_int[2]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB3 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[2]), .D(DB_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[3]), .XQ(XQB|partial_corrupt_A[3]), .Q(QB_int[3]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB4 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[3]), .D(DB_int_bmux[4]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[4]), .XQ(XQB|partial_corrupt_A[4]), .Q(QB_int[4]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB5 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[4]), .D(DB_int_bmux[5]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[5]), .XQ(XQB|partial_corrupt_A[5]), .Q(QB_int[5]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB6 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[5]), .D(DB_int_bmux[6]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[6]), .XQ(XQB|partial_corrupt_A[6]), .Q(QB_int[6]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB7 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[6]), .D(DB_int_bmux[7]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[7]), .XQ(XQB|partial_corrupt_A[7]), .Q(QB_int[7]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB8 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[7]), .D(DB_int_bmux[8]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[8]), .XQ(XQB|partial_corrupt_A[8]), .Q(QB_int[8]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB9 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[8]), .D(DB_int_bmux[9]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[9]), .XQ(XQB|partial_corrupt_A[9]), .Q(QB_int[9]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB10 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[9]), .D(DB_int_bmux[10]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[10]), .XQ(XQB|partial_corrupt_A[10]), .Q(QB_int[10]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB11 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[10]), .D(DB_int_bmux[11]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[11]), .XQ(XQB|partial_corrupt_A[11]), .Q(QB_int[11]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB12 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[11]), .D(DB_int_bmux[12]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[12]), .XQ(XQB|partial_corrupt_A[12]), .Q(QB_int[12]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB13 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[12]), .D(DB_int_bmux[13]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[13]), .XQ(XQB|partial_corrupt_A[13]), .Q(QB_int[13]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB14 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[13]), .D(DB_int_bmux[14]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[14]), .XQ(XQB|partial_corrupt_A[14]), .Q(QB_int[14]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB15 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[14]), .D(DB_int_bmux[15]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[15]), .XQ(XQB|partial_corrupt_A[15]), .Q(QB_int[15]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB16 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[15]), .D(DB_int_bmux[16]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[16]), .XQ(XQB|partial_corrupt_A[16]), .Q(QB_int[16]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB17 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[16]), .D(DB_int_bmux[17]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[17]), .XQ(XQB|partial_corrupt_A[17]), .Q(QB_int[17]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB18 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[17]), .D(DB_int_bmux[18]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[18]), .XQ(XQB|partial_corrupt_A[18]), .Q(QB_int[18]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB19 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[18]), .D(DB_int_bmux[19]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[19]), .XQ(XQB|partial_corrupt_A[19]), .Q(QB_int[19]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB20 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[21]), .D(DB_int_bmux[20]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[20]), .XQ(XQB|partial_corrupt_A[20]), .Q(QB_int[20]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB21 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[22]), .D(DB_int_bmux[21]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[21]), .XQ(XQB|partial_corrupt_A[21]), .Q(QB_int[21]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB22 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[23]), .D(DB_int_bmux[22]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[22]), .XQ(XQB|partial_corrupt_A[22]), .Q(QB_int[22]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB23 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[24]), .D(DB_int_bmux[23]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[23]), .XQ(XQB|partial_corrupt_A[23]), .Q(QB_int[23]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB24 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[25]), .D(DB_int_bmux[24]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[24]), .XQ(XQB|partial_corrupt_A[24]), .Q(QB_int[24]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB25 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[26]), .D(DB_int_bmux[25]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[25]), .XQ(XQB|partial_corrupt_A[25]), .Q(QB_int[25]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB26 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[27]), .D(DB_int_bmux[26]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[26]), .XQ(XQB|partial_corrupt_A[26]), .Q(QB_int[26]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB27 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[28]), .D(DB_int_bmux[27]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[27]), .XQ(XQB|partial_corrupt_A[27]), .Q(QB_int[27]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB28 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[29]), .D(DB_int_bmux[28]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[28]), .XQ(XQB|partial_corrupt_A[28]), .Q(QB_int[28]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB29 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[30]), .D(DB_int_bmux[29]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[29]), .XQ(XQB|partial_corrupt_A[29]), .Q(QB_int[29]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB30 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[31]), .D(DB_int_bmux[30]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[30]), .XQ(XQB|partial_corrupt_A[30]), .Q(QB_int[30]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB31 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[32]), .D(DB_int_bmux[31]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[31]), .XQ(XQB|partial_corrupt_A[31]), .Q(QB_int[31]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB32 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[33]), .D(DB_int_bmux[32]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[32]), .XQ(XQB|partial_corrupt_A[32]), .Q(QB_int[32]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB33 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[34]), .D(DB_int_bmux[33]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[33]), .XQ(XQB|partial_corrupt_A[33]), .Q(QB_int[33]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB34 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[35]), .D(DB_int_bmux[34]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[34]), .XQ(XQB|partial_corrupt_A[34]), .Q(QB_int[34]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB35 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[36]), .D(DB_int_bmux[35]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[35]), .XQ(XQB|partial_corrupt_A[35]), .Q(QB_int[35]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB36 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[37]), .D(DB_int_bmux[36]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[36]), .XQ(XQB|partial_corrupt_A[36]), .Q(QB_int[36]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB37 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[38]), .D(DB_int_bmux[37]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[37]), .XQ(XQB|partial_corrupt_A[37]), .Q(QB_int[37]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB38 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[39]), .D(DB_int_bmux[38]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[38]), .XQ(XQB|partial_corrupt_A[38]), .Q(QB_int[38]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB39 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[1]), .D(DB_int_bmux[39]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[39]), .XQ(XQB|partial_corrupt_A[39]), .Q(QB_int[39]));


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
    input [39:0] wena;
    input [39:0] wenb;
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
    input [39:0] wena;
    input [39:0] wenb;
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
module arm28hkcpdpsram128x40m4 (VDDCE, VDDPE, VSSE, CENYA, WENYA, AYA, CENYB, WENYB,
    AYB, GWENYA, GWENYB, QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB,
    AB, DB, EMAA, EMAWA, EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB,
    TCENB, TWENB, TAB, TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP,
    SIB, SEB, COLLDISN);
`else
module arm28hkcpdpsram128x40m4 (CENYA, WENYA, AYA, CENYB, WENYB, AYB, GWENYA, GWENYB,
    QA, QB, SOA, SOB, CLKA, CENA, WENA, AA, DA, CLKB, CENB, WENB, AB, DB, EMAA, EMAWA,
    EMASA, EMAB, EMAWB, EMASB, TENA, TCENA, TWENA, TAA, TDA, TENB, TCENB, TWENB, TAB,
    TDB, GWENA, GWENB, TGWENA, TGWENB, RET1N, SIA, SEA, DFTRAMBYP, SIB, SEB, COLLDISN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 40;
  parameter WORDS = 128;
  parameter MUX = 4;
  parameter MEM_WIDTH = 160; // redun block size 4, 80 on left, 80 on right
  parameter MEM_HEIGHT = 32;
  parameter WP_SIZE = 1 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENYA;
  output [39:0] WENYA;
  output [6:0] AYA;
  output  CENYB;
  output [39:0] WENYB;
  output [6:0] AYB;
  output  GWENYA;
  output  GWENYB;
  output [39:0] QA;
  output [39:0] QB;
  output [1:0] SOA;
  output [1:0] SOB;
  input  CLKA;
  input  CENA;
  input [39:0] WENA;
  input [6:0] AA;
  input [39:0] DA;
  input  CLKB;
  input  CENB;
  input [39:0] WENB;
  input [6:0] AB;
  input [39:0] DB;
  input [2:0] EMAA;
  input [1:0] EMAWA;
  input  EMASA;
  input [2:0] EMAB;
  input [1:0] EMAWB;
  input  EMASB;
  input  TENA;
  input  TCENA;
  input [39:0] TWENA;
  input [6:0] TAA;
  input [39:0] TDA;
  input  TENB;
  input  TCENB;
  input [39:0] TWENB;
  input [6:0] TAB;
  input [39:0] TDB;
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
  reg [159:0] mem [0:31];
  reg [159:0] row, row_t;
  reg LAST_CLKA;
  reg [159:0] row_mask;
  reg [159:0] new_data;
  reg [159:0] data_out;
  reg [39:0] readLatch0;
  reg [39:0] shifted_readLatch0;
  reg  read_mux_sel0_p2;
  reg [39:0] readLatch1;
  reg [39:0] shifted_readLatch1;
  reg  read_mux_sel1_p2;
  reg LAST_CLKB;
  wire [39:0] QA_int;
  reg XQA, QA_update;
  reg XDA_sh, DA_sh_update;
  wire [39:0] DA_int_bmux;
  reg [39:0] mem_path_A;
  reg [39:0] partial_mask;
  reg [39:0] partial_mask_A;
  reg [39:0] partial_corrupt_A = 40'b0;
  wire [39:0] QB_int;
  reg XQB, QB_update;
  reg XDB_sh, DB_sh_update;
  wire [39:0] DB_int_bmux;
  reg [39:0] mem_path_B;
  reg [39:0] partial_mask_B;
  reg [39:0] partial_corrupt_B = 40'b0;
  reg [39:0] writeEnable;
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

  reg NOT_CENA, NOT_WENA39, NOT_WENA38, NOT_WENA37, NOT_WENA36, NOT_WENA35, NOT_WENA34;
  reg NOT_WENA33, NOT_WENA32, NOT_WENA31, NOT_WENA30, NOT_WENA29, NOT_WENA28, NOT_WENA27;
  reg NOT_WENA26, NOT_WENA25, NOT_WENA24, NOT_WENA23, NOT_WENA22, NOT_WENA21, NOT_WENA20;
  reg NOT_WENA19, NOT_WENA18, NOT_WENA17, NOT_WENA16, NOT_WENA15, NOT_WENA14, NOT_WENA13;
  reg NOT_WENA12, NOT_WENA11, NOT_WENA10, NOT_WENA9, NOT_WENA8, NOT_WENA7, NOT_WENA6;
  reg NOT_WENA5, NOT_WENA4, NOT_WENA3, NOT_WENA2, NOT_WENA1, NOT_WENA0, NOT_AA6, NOT_AA5;
  reg NOT_AA4, NOT_AA3, NOT_AA2, NOT_AA1, NOT_AA0, NOT_DA39, NOT_DA38, NOT_DA37, NOT_DA36;
  reg NOT_DA35, NOT_DA34, NOT_DA33, NOT_DA32, NOT_DA31, NOT_DA30, NOT_DA29, NOT_DA28;
  reg NOT_DA27, NOT_DA26, NOT_DA25, NOT_DA24, NOT_DA23, NOT_DA22, NOT_DA21, NOT_DA20;
  reg NOT_DA19, NOT_DA18, NOT_DA17, NOT_DA16, NOT_DA15, NOT_DA14, NOT_DA13, NOT_DA12;
  reg NOT_DA11, NOT_DA10, NOT_DA9, NOT_DA8, NOT_DA7, NOT_DA6, NOT_DA5, NOT_DA4, NOT_DA3;
  reg NOT_DA2, NOT_DA1, NOT_DA0, NOT_CENB, NOT_WENB39, NOT_WENB38, NOT_WENB37, NOT_WENB36;
  reg NOT_WENB35, NOT_WENB34, NOT_WENB33, NOT_WENB32, NOT_WENB31, NOT_WENB30, NOT_WENB29;
  reg NOT_WENB28, NOT_WENB27, NOT_WENB26, NOT_WENB25, NOT_WENB24, NOT_WENB23, NOT_WENB22;
  reg NOT_WENB21, NOT_WENB20, NOT_WENB19, NOT_WENB18, NOT_WENB17, NOT_WENB16, NOT_WENB15;
  reg NOT_WENB14, NOT_WENB13, NOT_WENB12, NOT_WENB11, NOT_WENB10, NOT_WENB9, NOT_WENB8;
  reg NOT_WENB7, NOT_WENB6, NOT_WENB5, NOT_WENB4, NOT_WENB3, NOT_WENB2, NOT_WENB1;
  reg NOT_WENB0, NOT_AB6, NOT_AB5, NOT_AB4, NOT_AB3, NOT_AB2, NOT_AB1, NOT_AB0, NOT_DB39;
  reg NOT_DB38, NOT_DB37, NOT_DB36, NOT_DB35, NOT_DB34, NOT_DB33, NOT_DB32, NOT_DB31;
  reg NOT_DB30, NOT_DB29, NOT_DB28, NOT_DB27, NOT_DB26, NOT_DB25, NOT_DB24, NOT_DB23;
  reg NOT_DB22, NOT_DB21, NOT_DB20, NOT_DB19, NOT_DB18, NOT_DB17, NOT_DB16, NOT_DB15;
  reg NOT_DB14, NOT_DB13, NOT_DB12, NOT_DB11, NOT_DB10, NOT_DB9, NOT_DB8, NOT_DB7;
  reg NOT_DB6, NOT_DB5, NOT_DB4, NOT_DB3, NOT_DB2, NOT_DB1, NOT_DB0, NOT_EMAA2, NOT_EMAA1;
  reg NOT_EMAA0, NOT_EMAWA1, NOT_EMAWA0, NOT_EMASA, NOT_EMAB2, NOT_EMAB1, NOT_EMAB0;
  reg NOT_EMAWB1, NOT_EMAWB0, NOT_EMASB, NOT_TENA, NOT_TCENA, NOT_TWENA39, NOT_TWENA38;
  reg NOT_TWENA37, NOT_TWENA36, NOT_TWENA35, NOT_TWENA34, NOT_TWENA33, NOT_TWENA32;
  reg NOT_TWENA31, NOT_TWENA30, NOT_TWENA29, NOT_TWENA28, NOT_TWENA27, NOT_TWENA26;
  reg NOT_TWENA25, NOT_TWENA24, NOT_TWENA23, NOT_TWENA22, NOT_TWENA21, NOT_TWENA20;
  reg NOT_TWENA19, NOT_TWENA18, NOT_TWENA17, NOT_TWENA16, NOT_TWENA15, NOT_TWENA14;
  reg NOT_TWENA13, NOT_TWENA12, NOT_TWENA11, NOT_TWENA10, NOT_TWENA9, NOT_TWENA8, NOT_TWENA7;
  reg NOT_TWENA6, NOT_TWENA5, NOT_TWENA4, NOT_TWENA3, NOT_TWENA2, NOT_TWENA1, NOT_TWENA0;
  reg NOT_TAA6, NOT_TAA5, NOT_TAA4, NOT_TAA3, NOT_TAA2, NOT_TAA1, NOT_TAA0, NOT_TDA39;
  reg NOT_TDA38, NOT_TDA37, NOT_TDA36, NOT_TDA35, NOT_TDA34, NOT_TDA33, NOT_TDA32;
  reg NOT_TDA31, NOT_TDA30, NOT_TDA29, NOT_TDA28, NOT_TDA27, NOT_TDA26, NOT_TDA25;
  reg NOT_TDA24, NOT_TDA23, NOT_TDA22, NOT_TDA21, NOT_TDA20, NOT_TDA19, NOT_TDA18;
  reg NOT_TDA17, NOT_TDA16, NOT_TDA15, NOT_TDA14, NOT_TDA13, NOT_TDA12, NOT_TDA11;
  reg NOT_TDA10, NOT_TDA9, NOT_TDA8, NOT_TDA7, NOT_TDA6, NOT_TDA5, NOT_TDA4, NOT_TDA3;
  reg NOT_TDA2, NOT_TDA1, NOT_TDA0, NOT_TENB, NOT_TCENB, NOT_TWENB39, NOT_TWENB38;
  reg NOT_TWENB37, NOT_TWENB36, NOT_TWENB35, NOT_TWENB34, NOT_TWENB33, NOT_TWENB32;
  reg NOT_TWENB31, NOT_TWENB30, NOT_TWENB29, NOT_TWENB28, NOT_TWENB27, NOT_TWENB26;
  reg NOT_TWENB25, NOT_TWENB24, NOT_TWENB23, NOT_TWENB22, NOT_TWENB21, NOT_TWENB20;
  reg NOT_TWENB19, NOT_TWENB18, NOT_TWENB17, NOT_TWENB16, NOT_TWENB15, NOT_TWENB14;
  reg NOT_TWENB13, NOT_TWENB12, NOT_TWENB11, NOT_TWENB10, NOT_TWENB9, NOT_TWENB8, NOT_TWENB7;
  reg NOT_TWENB6, NOT_TWENB5, NOT_TWENB4, NOT_TWENB3, NOT_TWENB2, NOT_TWENB1, NOT_TWENB0;
  reg NOT_TAB6, NOT_TAB5, NOT_TAB4, NOT_TAB3, NOT_TAB2, NOT_TAB1, NOT_TAB0, NOT_TDB39;
  reg NOT_TDB38, NOT_TDB37, NOT_TDB36, NOT_TDB35, NOT_TDB34, NOT_TDB33, NOT_TDB32;
  reg NOT_TDB31, NOT_TDB30, NOT_TDB29, NOT_TDB28, NOT_TDB27, NOT_TDB26, NOT_TDB25;
  reg NOT_TDB24, NOT_TDB23, NOT_TDB22, NOT_TDB21, NOT_TDB20, NOT_TDB19, NOT_TDB18;
  reg NOT_TDB17, NOT_TDB16, NOT_TDB15, NOT_TDB14, NOT_TDB13, NOT_TDB12, NOT_TDB11;
  reg NOT_TDB10, NOT_TDB9, NOT_TDB8, NOT_TDB7, NOT_TDB6, NOT_TDB5, NOT_TDB4, NOT_TDB3;
  reg NOT_TDB2, NOT_TDB1, NOT_TDB0, NOT_GWENA, NOT_GWENB, NOT_TGWENA, NOT_TGWENB, NOT_SIA1;
  reg NOT_SIA0, NOT_SEA, NOT_DFTRAMBYP_CLKB, NOT_DFTRAMBYP_CLKA, NOT_RET1N, NOT_SIB1;
  reg NOT_SIB0, NOT_SEB, NOT_COLLDISN;
  reg NOT_CLKA_PER, NOT_CLKA_MINH, NOT_CLKA_MINL, NOT_CONTA, NOT_CLKB_PER, NOT_CLKB_MINH;
  reg NOT_CLKB_MINL, NOT_CONTB;
  reg clk0_int;
  reg clk1_int;

  wire  CENYA_;
  wire [39:0] WENYA_;
  wire [6:0] AYA_;
  wire  CENYB_;
  wire [39:0] WENYB_;
  wire [6:0] AYB_;
  wire  GWENYA_;
  wire  GWENYB_;
  wire [39:0] QA_;
  wire [39:0] QB_;
  wire [1:0] SOA_;
  wire [1:0] SOB_;
 wire  CLKA_;
  wire  CENA_;
  reg  CENA_int;
  reg  CENA_p2;
  wire [39:0] WENA_;
  reg [39:0] WENA_int;
  wire [6:0] AA_;
  reg [6:0] AA_int;
  wire [39:0] DA_;
  reg [39:0] DA_int;
 wire  CLKB_;
  wire  CENB_;
  reg  CENB_int;
  reg  CENB_p2;
  wire [39:0] WENB_;
  reg [39:0] WENB_int;
  wire [6:0] AB_;
  reg [6:0] AB_int;
  wire [39:0] DB_;
  reg [39:0] DB_int;
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
  wire [39:0] TWENA_;
  reg [39:0] TWENA_int;
  wire [6:0] TAA_;
  reg [6:0] TAA_int;
  wire [39:0] TDA_;
  reg [39:0] TDA_int;
  wire  TENB_;
  reg  TENB_int;
  wire  TCENB_;
  reg  TCENB_int;
  reg  TCENB_p2;
  wire [39:0] TWENB_;
  reg [39:0] TWENB_int;
  wire [6:0] TAB_;
  reg [6:0] TAB_int;
  wire [39:0] TDB_;
  reg [39:0] TDB_int;
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
  buf B15(WENYA[14], WENYA_[14]);
  buf B16(WENYA[15], WENYA_[15]);
  buf B17(WENYA[16], WENYA_[16]);
  buf B18(WENYA[17], WENYA_[17]);
  buf B19(WENYA[18], WENYA_[18]);
  buf B20(WENYA[19], WENYA_[19]);
  buf B21(WENYA[20], WENYA_[20]);
  buf B22(WENYA[21], WENYA_[21]);
  buf B23(WENYA[22], WENYA_[22]);
  buf B24(WENYA[23], WENYA_[23]);
  buf B25(WENYA[24], WENYA_[24]);
  buf B26(WENYA[25], WENYA_[25]);
  buf B27(WENYA[26], WENYA_[26]);
  buf B28(WENYA[27], WENYA_[27]);
  buf B29(WENYA[28], WENYA_[28]);
  buf B30(WENYA[29], WENYA_[29]);
  buf B31(WENYA[30], WENYA_[30]);
  buf B32(WENYA[31], WENYA_[31]);
  buf B33(WENYA[32], WENYA_[32]);
  buf B34(WENYA[33], WENYA_[33]);
  buf B35(WENYA[34], WENYA_[34]);
  buf B36(WENYA[35], WENYA_[35]);
  buf B37(WENYA[36], WENYA_[36]);
  buf B38(WENYA[37], WENYA_[37]);
  buf B39(WENYA[38], WENYA_[38]);
  buf B40(WENYA[39], WENYA_[39]);
  buf B41(AYA[0], AYA_[0]);
  buf B42(AYA[1], AYA_[1]);
  buf B43(AYA[2], AYA_[2]);
  buf B44(AYA[3], AYA_[3]);
  buf B45(AYA[4], AYA_[4]);
  buf B46(AYA[5], AYA_[5]);
  buf B47(AYA[6], AYA_[6]);
  buf B48(CENYB, CENYB_);
  buf B49(WENYB[0], WENYB_[0]);
  buf B50(WENYB[1], WENYB_[1]);
  buf B51(WENYB[2], WENYB_[2]);
  buf B52(WENYB[3], WENYB_[3]);
  buf B53(WENYB[4], WENYB_[4]);
  buf B54(WENYB[5], WENYB_[5]);
  buf B55(WENYB[6], WENYB_[6]);
  buf B56(WENYB[7], WENYB_[7]);
  buf B57(WENYB[8], WENYB_[8]);
  buf B58(WENYB[9], WENYB_[9]);
  buf B59(WENYB[10], WENYB_[10]);
  buf B60(WENYB[11], WENYB_[11]);
  buf B61(WENYB[12], WENYB_[12]);
  buf B62(WENYB[13], WENYB_[13]);
  buf B63(WENYB[14], WENYB_[14]);
  buf B64(WENYB[15], WENYB_[15]);
  buf B65(WENYB[16], WENYB_[16]);
  buf B66(WENYB[17], WENYB_[17]);
  buf B67(WENYB[18], WENYB_[18]);
  buf B68(WENYB[19], WENYB_[19]);
  buf B69(WENYB[20], WENYB_[20]);
  buf B70(WENYB[21], WENYB_[21]);
  buf B71(WENYB[22], WENYB_[22]);
  buf B72(WENYB[23], WENYB_[23]);
  buf B73(WENYB[24], WENYB_[24]);
  buf B74(WENYB[25], WENYB_[25]);
  buf B75(WENYB[26], WENYB_[26]);
  buf B76(WENYB[27], WENYB_[27]);
  buf B77(WENYB[28], WENYB_[28]);
  buf B78(WENYB[29], WENYB_[29]);
  buf B79(WENYB[30], WENYB_[30]);
  buf B80(WENYB[31], WENYB_[31]);
  buf B81(WENYB[32], WENYB_[32]);
  buf B82(WENYB[33], WENYB_[33]);
  buf B83(WENYB[34], WENYB_[34]);
  buf B84(WENYB[35], WENYB_[35]);
  buf B85(WENYB[36], WENYB_[36]);
  buf B86(WENYB[37], WENYB_[37]);
  buf B87(WENYB[38], WENYB_[38]);
  buf B88(WENYB[39], WENYB_[39]);
  buf B89(AYB[0], AYB_[0]);
  buf B90(AYB[1], AYB_[1]);
  buf B91(AYB[2], AYB_[2]);
  buf B92(AYB[3], AYB_[3]);
  buf B93(AYB[4], AYB_[4]);
  buf B94(AYB[5], AYB_[5]);
  buf B95(AYB[6], AYB_[6]);
  buf B96(GWENYA, GWENYA_);
  buf B97(GWENYB, GWENYB_);
  buf B98(QA[0], QA_[0]);
  buf B99(QA[1], QA_[1]);
  buf B100(QA[2], QA_[2]);
  buf B101(QA[3], QA_[3]);
  buf B102(QA[4], QA_[4]);
  buf B103(QA[5], QA_[5]);
  buf B104(QA[6], QA_[6]);
  buf B105(QA[7], QA_[7]);
  buf B106(QA[8], QA_[8]);
  buf B107(QA[9], QA_[9]);
  buf B108(QA[10], QA_[10]);
  buf B109(QA[11], QA_[11]);
  buf B110(QA[12], QA_[12]);
  buf B111(QA[13], QA_[13]);
  buf B112(QA[14], QA_[14]);
  buf B113(QA[15], QA_[15]);
  buf B114(QA[16], QA_[16]);
  buf B115(QA[17], QA_[17]);
  buf B116(QA[18], QA_[18]);
  buf B117(QA[19], QA_[19]);
  buf B118(QA[20], QA_[20]);
  buf B119(QA[21], QA_[21]);
  buf B120(QA[22], QA_[22]);
  buf B121(QA[23], QA_[23]);
  buf B122(QA[24], QA_[24]);
  buf B123(QA[25], QA_[25]);
  buf B124(QA[26], QA_[26]);
  buf B125(QA[27], QA_[27]);
  buf B126(QA[28], QA_[28]);
  buf B127(QA[29], QA_[29]);
  buf B128(QA[30], QA_[30]);
  buf B129(QA[31], QA_[31]);
  buf B130(QA[32], QA_[32]);
  buf B131(QA[33], QA_[33]);
  buf B132(QA[34], QA_[34]);
  buf B133(QA[35], QA_[35]);
  buf B134(QA[36], QA_[36]);
  buf B135(QA[37], QA_[37]);
  buf B136(QA[38], QA_[38]);
  buf B137(QA[39], QA_[39]);
  buf B138(QB[0], QB_[0]);
  buf B139(QB[1], QB_[1]);
  buf B140(QB[2], QB_[2]);
  buf B141(QB[3], QB_[3]);
  buf B142(QB[4], QB_[4]);
  buf B143(QB[5], QB_[5]);
  buf B144(QB[6], QB_[6]);
  buf B145(QB[7], QB_[7]);
  buf B146(QB[8], QB_[8]);
  buf B147(QB[9], QB_[9]);
  buf B148(QB[10], QB_[10]);
  buf B149(QB[11], QB_[11]);
  buf B150(QB[12], QB_[12]);
  buf B151(QB[13], QB_[13]);
  buf B152(QB[14], QB_[14]);
  buf B153(QB[15], QB_[15]);
  buf B154(QB[16], QB_[16]);
  buf B155(QB[17], QB_[17]);
  buf B156(QB[18], QB_[18]);
  buf B157(QB[19], QB_[19]);
  buf B158(QB[20], QB_[20]);
  buf B159(QB[21], QB_[21]);
  buf B160(QB[22], QB_[22]);
  buf B161(QB[23], QB_[23]);
  buf B162(QB[24], QB_[24]);
  buf B163(QB[25], QB_[25]);
  buf B164(QB[26], QB_[26]);
  buf B165(QB[27], QB_[27]);
  buf B166(QB[28], QB_[28]);
  buf B167(QB[29], QB_[29]);
  buf B168(QB[30], QB_[30]);
  buf B169(QB[31], QB_[31]);
  buf B170(QB[32], QB_[32]);
  buf B171(QB[33], QB_[33]);
  buf B172(QB[34], QB_[34]);
  buf B173(QB[35], QB_[35]);
  buf B174(QB[36], QB_[36]);
  buf B175(QB[37], QB_[37]);
  buf B176(QB[38], QB_[38]);
  buf B177(QB[39], QB_[39]);
  buf B178(SOA[0], SOA_[0]);
  buf B179(SOA[1], SOA_[1]);
  buf B180(SOB[0], SOB_[0]);
  buf B181(SOB[1], SOB_[1]);
  buf B182(CLKA_, CLKA);
  buf B183(CENA_, CENA);
  buf B184(WENA_[0], WENA[0]);
  buf B185(WENA_[1], WENA[1]);
  buf B186(WENA_[2], WENA[2]);
  buf B187(WENA_[3], WENA[3]);
  buf B188(WENA_[4], WENA[4]);
  buf B189(WENA_[5], WENA[5]);
  buf B190(WENA_[6], WENA[6]);
  buf B191(WENA_[7], WENA[7]);
  buf B192(WENA_[8], WENA[8]);
  buf B193(WENA_[9], WENA[9]);
  buf B194(WENA_[10], WENA[10]);
  buf B195(WENA_[11], WENA[11]);
  buf B196(WENA_[12], WENA[12]);
  buf B197(WENA_[13], WENA[13]);
  buf B198(WENA_[14], WENA[14]);
  buf B199(WENA_[15], WENA[15]);
  buf B200(WENA_[16], WENA[16]);
  buf B201(WENA_[17], WENA[17]);
  buf B202(WENA_[18], WENA[18]);
  buf B203(WENA_[19], WENA[19]);
  buf B204(WENA_[20], WENA[20]);
  buf B205(WENA_[21], WENA[21]);
  buf B206(WENA_[22], WENA[22]);
  buf B207(WENA_[23], WENA[23]);
  buf B208(WENA_[24], WENA[24]);
  buf B209(WENA_[25], WENA[25]);
  buf B210(WENA_[26], WENA[26]);
  buf B211(WENA_[27], WENA[27]);
  buf B212(WENA_[28], WENA[28]);
  buf B213(WENA_[29], WENA[29]);
  buf B214(WENA_[30], WENA[30]);
  buf B215(WENA_[31], WENA[31]);
  buf B216(WENA_[32], WENA[32]);
  buf B217(WENA_[33], WENA[33]);
  buf B218(WENA_[34], WENA[34]);
  buf B219(WENA_[35], WENA[35]);
  buf B220(WENA_[36], WENA[36]);
  buf B221(WENA_[37], WENA[37]);
  buf B222(WENA_[38], WENA[38]);
  buf B223(WENA_[39], WENA[39]);
  buf B224(AA_[0], AA[0]);
  buf B225(AA_[1], AA[1]);
  buf B226(AA_[2], AA[2]);
  buf B227(AA_[3], AA[3]);
  buf B228(AA_[4], AA[4]);
  buf B229(AA_[5], AA[5]);
  buf B230(AA_[6], AA[6]);
  buf B231(DA_[0], DA[0]);
  buf B232(DA_[1], DA[1]);
  buf B233(DA_[2], DA[2]);
  buf B234(DA_[3], DA[3]);
  buf B235(DA_[4], DA[4]);
  buf B236(DA_[5], DA[5]);
  buf B237(DA_[6], DA[6]);
  buf B238(DA_[7], DA[7]);
  buf B239(DA_[8], DA[8]);
  buf B240(DA_[9], DA[9]);
  buf B241(DA_[10], DA[10]);
  buf B242(DA_[11], DA[11]);
  buf B243(DA_[12], DA[12]);
  buf B244(DA_[13], DA[13]);
  buf B245(DA_[14], DA[14]);
  buf B246(DA_[15], DA[15]);
  buf B247(DA_[16], DA[16]);
  buf B248(DA_[17], DA[17]);
  buf B249(DA_[18], DA[18]);
  buf B250(DA_[19], DA[19]);
  buf B251(DA_[20], DA[20]);
  buf B252(DA_[21], DA[21]);
  buf B253(DA_[22], DA[22]);
  buf B254(DA_[23], DA[23]);
  buf B255(DA_[24], DA[24]);
  buf B256(DA_[25], DA[25]);
  buf B257(DA_[26], DA[26]);
  buf B258(DA_[27], DA[27]);
  buf B259(DA_[28], DA[28]);
  buf B260(DA_[29], DA[29]);
  buf B261(DA_[30], DA[30]);
  buf B262(DA_[31], DA[31]);
  buf B263(DA_[32], DA[32]);
  buf B264(DA_[33], DA[33]);
  buf B265(DA_[34], DA[34]);
  buf B266(DA_[35], DA[35]);
  buf B267(DA_[36], DA[36]);
  buf B268(DA_[37], DA[37]);
  buf B269(DA_[38], DA[38]);
  buf B270(DA_[39], DA[39]);
  buf B271(CLKB_, CLKB);
  buf B272(CENB_, CENB);
  buf B273(WENB_[0], WENB[0]);
  buf B274(WENB_[1], WENB[1]);
  buf B275(WENB_[2], WENB[2]);
  buf B276(WENB_[3], WENB[3]);
  buf B277(WENB_[4], WENB[4]);
  buf B278(WENB_[5], WENB[5]);
  buf B279(WENB_[6], WENB[6]);
  buf B280(WENB_[7], WENB[7]);
  buf B281(WENB_[8], WENB[8]);
  buf B282(WENB_[9], WENB[9]);
  buf B283(WENB_[10], WENB[10]);
  buf B284(WENB_[11], WENB[11]);
  buf B285(WENB_[12], WENB[12]);
  buf B286(WENB_[13], WENB[13]);
  buf B287(WENB_[14], WENB[14]);
  buf B288(WENB_[15], WENB[15]);
  buf B289(WENB_[16], WENB[16]);
  buf B290(WENB_[17], WENB[17]);
  buf B291(WENB_[18], WENB[18]);
  buf B292(WENB_[19], WENB[19]);
  buf B293(WENB_[20], WENB[20]);
  buf B294(WENB_[21], WENB[21]);
  buf B295(WENB_[22], WENB[22]);
  buf B296(WENB_[23], WENB[23]);
  buf B297(WENB_[24], WENB[24]);
  buf B298(WENB_[25], WENB[25]);
  buf B299(WENB_[26], WENB[26]);
  buf B300(WENB_[27], WENB[27]);
  buf B301(WENB_[28], WENB[28]);
  buf B302(WENB_[29], WENB[29]);
  buf B303(WENB_[30], WENB[30]);
  buf B304(WENB_[31], WENB[31]);
  buf B305(WENB_[32], WENB[32]);
  buf B306(WENB_[33], WENB[33]);
  buf B307(WENB_[34], WENB[34]);
  buf B308(WENB_[35], WENB[35]);
  buf B309(WENB_[36], WENB[36]);
  buf B310(WENB_[37], WENB[37]);
  buf B311(WENB_[38], WENB[38]);
  buf B312(WENB_[39], WENB[39]);
  buf B313(AB_[0], AB[0]);
  buf B314(AB_[1], AB[1]);
  buf B315(AB_[2], AB[2]);
  buf B316(AB_[3], AB[3]);
  buf B317(AB_[4], AB[4]);
  buf B318(AB_[5], AB[5]);
  buf B319(AB_[6], AB[6]);
  buf B320(DB_[0], DB[0]);
  buf B321(DB_[1], DB[1]);
  buf B322(DB_[2], DB[2]);
  buf B323(DB_[3], DB[3]);
  buf B324(DB_[4], DB[4]);
  buf B325(DB_[5], DB[5]);
  buf B326(DB_[6], DB[6]);
  buf B327(DB_[7], DB[7]);
  buf B328(DB_[8], DB[8]);
  buf B329(DB_[9], DB[9]);
  buf B330(DB_[10], DB[10]);
  buf B331(DB_[11], DB[11]);
  buf B332(DB_[12], DB[12]);
  buf B333(DB_[13], DB[13]);
  buf B334(DB_[14], DB[14]);
  buf B335(DB_[15], DB[15]);
  buf B336(DB_[16], DB[16]);
  buf B337(DB_[17], DB[17]);
  buf B338(DB_[18], DB[18]);
  buf B339(DB_[19], DB[19]);
  buf B340(DB_[20], DB[20]);
  buf B341(DB_[21], DB[21]);
  buf B342(DB_[22], DB[22]);
  buf B343(DB_[23], DB[23]);
  buf B344(DB_[24], DB[24]);
  buf B345(DB_[25], DB[25]);
  buf B346(DB_[26], DB[26]);
  buf B347(DB_[27], DB[27]);
  buf B348(DB_[28], DB[28]);
  buf B349(DB_[29], DB[29]);
  buf B350(DB_[30], DB[30]);
  buf B351(DB_[31], DB[31]);
  buf B352(DB_[32], DB[32]);
  buf B353(DB_[33], DB[33]);
  buf B354(DB_[34], DB[34]);
  buf B355(DB_[35], DB[35]);
  buf B356(DB_[36], DB[36]);
  buf B357(DB_[37], DB[37]);
  buf B358(DB_[38], DB[38]);
  buf B359(DB_[39], DB[39]);
  buf B360(EMAA_[0], EMAA[0]);
  buf B361(EMAA_[1], EMAA[1]);
  buf B362(EMAA_[2], EMAA[2]);
  buf B363(EMAWA_[0], EMAWA[0]);
  buf B364(EMAWA_[1], EMAWA[1]);
  buf B365(EMASA_, EMASA);
  buf B366(EMAB_[0], EMAB[0]);
  buf B367(EMAB_[1], EMAB[1]);
  buf B368(EMAB_[2], EMAB[2]);
  buf B369(EMAWB_[0], EMAWB[0]);
  buf B370(EMAWB_[1], EMAWB[1]);
  buf B371(EMASB_, EMASB);
  buf B372(TENA_, TENA);
  buf B373(TCENA_, TCENA);
  buf B374(TWENA_[0], TWENA[0]);
  buf B375(TWENA_[1], TWENA[1]);
  buf B376(TWENA_[2], TWENA[2]);
  buf B377(TWENA_[3], TWENA[3]);
  buf B378(TWENA_[4], TWENA[4]);
  buf B379(TWENA_[5], TWENA[5]);
  buf B380(TWENA_[6], TWENA[6]);
  buf B381(TWENA_[7], TWENA[7]);
  buf B382(TWENA_[8], TWENA[8]);
  buf B383(TWENA_[9], TWENA[9]);
  buf B384(TWENA_[10], TWENA[10]);
  buf B385(TWENA_[11], TWENA[11]);
  buf B386(TWENA_[12], TWENA[12]);
  buf B387(TWENA_[13], TWENA[13]);
  buf B388(TWENA_[14], TWENA[14]);
  buf B389(TWENA_[15], TWENA[15]);
  buf B390(TWENA_[16], TWENA[16]);
  buf B391(TWENA_[17], TWENA[17]);
  buf B392(TWENA_[18], TWENA[18]);
  buf B393(TWENA_[19], TWENA[19]);
  buf B394(TWENA_[20], TWENA[20]);
  buf B395(TWENA_[21], TWENA[21]);
  buf B396(TWENA_[22], TWENA[22]);
  buf B397(TWENA_[23], TWENA[23]);
  buf B398(TWENA_[24], TWENA[24]);
  buf B399(TWENA_[25], TWENA[25]);
  buf B400(TWENA_[26], TWENA[26]);
  buf B401(TWENA_[27], TWENA[27]);
  buf B402(TWENA_[28], TWENA[28]);
  buf B403(TWENA_[29], TWENA[29]);
  buf B404(TWENA_[30], TWENA[30]);
  buf B405(TWENA_[31], TWENA[31]);
  buf B406(TWENA_[32], TWENA[32]);
  buf B407(TWENA_[33], TWENA[33]);
  buf B408(TWENA_[34], TWENA[34]);
  buf B409(TWENA_[35], TWENA[35]);
  buf B410(TWENA_[36], TWENA[36]);
  buf B411(TWENA_[37], TWENA[37]);
  buf B412(TWENA_[38], TWENA[38]);
  buf B413(TWENA_[39], TWENA[39]);
  buf B414(TAA_[0], TAA[0]);
  buf B415(TAA_[1], TAA[1]);
  buf B416(TAA_[2], TAA[2]);
  buf B417(TAA_[3], TAA[3]);
  buf B418(TAA_[4], TAA[4]);
  buf B419(TAA_[5], TAA[5]);
  buf B420(TAA_[6], TAA[6]);
  buf B421(TDA_[0], TDA[0]);
  buf B422(TDA_[1], TDA[1]);
  buf B423(TDA_[2], TDA[2]);
  buf B424(TDA_[3], TDA[3]);
  buf B425(TDA_[4], TDA[4]);
  buf B426(TDA_[5], TDA[5]);
  buf B427(TDA_[6], TDA[6]);
  buf B428(TDA_[7], TDA[7]);
  buf B429(TDA_[8], TDA[8]);
  buf B430(TDA_[9], TDA[9]);
  buf B431(TDA_[10], TDA[10]);
  buf B432(TDA_[11], TDA[11]);
  buf B433(TDA_[12], TDA[12]);
  buf B434(TDA_[13], TDA[13]);
  buf B435(TDA_[14], TDA[14]);
  buf B436(TDA_[15], TDA[15]);
  buf B437(TDA_[16], TDA[16]);
  buf B438(TDA_[17], TDA[17]);
  buf B439(TDA_[18], TDA[18]);
  buf B440(TDA_[19], TDA[19]);
  buf B441(TDA_[20], TDA[20]);
  buf B442(TDA_[21], TDA[21]);
  buf B443(TDA_[22], TDA[22]);
  buf B444(TDA_[23], TDA[23]);
  buf B445(TDA_[24], TDA[24]);
  buf B446(TDA_[25], TDA[25]);
  buf B447(TDA_[26], TDA[26]);
  buf B448(TDA_[27], TDA[27]);
  buf B449(TDA_[28], TDA[28]);
  buf B450(TDA_[29], TDA[29]);
  buf B451(TDA_[30], TDA[30]);
  buf B452(TDA_[31], TDA[31]);
  buf B453(TDA_[32], TDA[32]);
  buf B454(TDA_[33], TDA[33]);
  buf B455(TDA_[34], TDA[34]);
  buf B456(TDA_[35], TDA[35]);
  buf B457(TDA_[36], TDA[36]);
  buf B458(TDA_[37], TDA[37]);
  buf B459(TDA_[38], TDA[38]);
  buf B460(TDA_[39], TDA[39]);
  buf B461(TENB_, TENB);
  buf B462(TCENB_, TCENB);
  buf B463(TWENB_[0], TWENB[0]);
  buf B464(TWENB_[1], TWENB[1]);
  buf B465(TWENB_[2], TWENB[2]);
  buf B466(TWENB_[3], TWENB[3]);
  buf B467(TWENB_[4], TWENB[4]);
  buf B468(TWENB_[5], TWENB[5]);
  buf B469(TWENB_[6], TWENB[6]);
  buf B470(TWENB_[7], TWENB[7]);
  buf B471(TWENB_[8], TWENB[8]);
  buf B472(TWENB_[9], TWENB[9]);
  buf B473(TWENB_[10], TWENB[10]);
  buf B474(TWENB_[11], TWENB[11]);
  buf B475(TWENB_[12], TWENB[12]);
  buf B476(TWENB_[13], TWENB[13]);
  buf B477(TWENB_[14], TWENB[14]);
  buf B478(TWENB_[15], TWENB[15]);
  buf B479(TWENB_[16], TWENB[16]);
  buf B480(TWENB_[17], TWENB[17]);
  buf B481(TWENB_[18], TWENB[18]);
  buf B482(TWENB_[19], TWENB[19]);
  buf B483(TWENB_[20], TWENB[20]);
  buf B484(TWENB_[21], TWENB[21]);
  buf B485(TWENB_[22], TWENB[22]);
  buf B486(TWENB_[23], TWENB[23]);
  buf B487(TWENB_[24], TWENB[24]);
  buf B488(TWENB_[25], TWENB[25]);
  buf B489(TWENB_[26], TWENB[26]);
  buf B490(TWENB_[27], TWENB[27]);
  buf B491(TWENB_[28], TWENB[28]);
  buf B492(TWENB_[29], TWENB[29]);
  buf B493(TWENB_[30], TWENB[30]);
  buf B494(TWENB_[31], TWENB[31]);
  buf B495(TWENB_[32], TWENB[32]);
  buf B496(TWENB_[33], TWENB[33]);
  buf B497(TWENB_[34], TWENB[34]);
  buf B498(TWENB_[35], TWENB[35]);
  buf B499(TWENB_[36], TWENB[36]);
  buf B500(TWENB_[37], TWENB[37]);
  buf B501(TWENB_[38], TWENB[38]);
  buf B502(TWENB_[39], TWENB[39]);
  buf B503(TAB_[0], TAB[0]);
  buf B504(TAB_[1], TAB[1]);
  buf B505(TAB_[2], TAB[2]);
  buf B506(TAB_[3], TAB[3]);
  buf B507(TAB_[4], TAB[4]);
  buf B508(TAB_[5], TAB[5]);
  buf B509(TAB_[6], TAB[6]);
  buf B510(TDB_[0], TDB[0]);
  buf B511(TDB_[1], TDB[1]);
  buf B512(TDB_[2], TDB[2]);
  buf B513(TDB_[3], TDB[3]);
  buf B514(TDB_[4], TDB[4]);
  buf B515(TDB_[5], TDB[5]);
  buf B516(TDB_[6], TDB[6]);
  buf B517(TDB_[7], TDB[7]);
  buf B518(TDB_[8], TDB[8]);
  buf B519(TDB_[9], TDB[9]);
  buf B520(TDB_[10], TDB[10]);
  buf B521(TDB_[11], TDB[11]);
  buf B522(TDB_[12], TDB[12]);
  buf B523(TDB_[13], TDB[13]);
  buf B524(TDB_[14], TDB[14]);
  buf B525(TDB_[15], TDB[15]);
  buf B526(TDB_[16], TDB[16]);
  buf B527(TDB_[17], TDB[17]);
  buf B528(TDB_[18], TDB[18]);
  buf B529(TDB_[19], TDB[19]);
  buf B530(TDB_[20], TDB[20]);
  buf B531(TDB_[21], TDB[21]);
  buf B532(TDB_[22], TDB[22]);
  buf B533(TDB_[23], TDB[23]);
  buf B534(TDB_[24], TDB[24]);
  buf B535(TDB_[25], TDB[25]);
  buf B536(TDB_[26], TDB[26]);
  buf B537(TDB_[27], TDB[27]);
  buf B538(TDB_[28], TDB[28]);
  buf B539(TDB_[29], TDB[29]);
  buf B540(TDB_[30], TDB[30]);
  buf B541(TDB_[31], TDB[31]);
  buf B542(TDB_[32], TDB[32]);
  buf B543(TDB_[33], TDB[33]);
  buf B544(TDB_[34], TDB[34]);
  buf B545(TDB_[35], TDB[35]);
  buf B546(TDB_[36], TDB[36]);
  buf B547(TDB_[37], TDB[37]);
  buf B548(TDB_[38], TDB[38]);
  buf B549(TDB_[39], TDB[39]);
  buf B550(GWENA_, GWENA);
  buf B551(GWENB_, GWENB);
  buf B552(TGWENA_, TGWENA);
  buf B553(TGWENB_, TGWENB);
  buf B554(RET1N_, RET1N);
  buf B555(SIA_[0], SIA[0]);
  buf B556(SIA_[1], SIA[1]);
  buf B557(SEA_, SEA);
  buf B558(DFTRAMBYP_, DFTRAMBYP);
  buf B559(SIB_[0], SIB[0]);
  buf B560(SIB_[1], SIB[1]);
  buf B561(SEB_, SEB);
  buf B562(COLLDISN_, COLLDISN);

  assign CENYA_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENA_ ? CENA_ : TCENA_)) : 1'bx;
  assign WENYA_ = (RET1N_ | pre_charge_st) ? ({40{DFTRAMBYP_}} & (TENA_ ? WENA_ : TWENA_)) : {40{1'bx}};
  assign AYA_ = (RET1N_ | pre_charge_st) ? ({7{DFTRAMBYP_}} & (TENA_ ? AA_ : TAA_)) : {7{1'bx}};
  assign CENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? CENB_ : TCENB_)) : 1'bx;
  assign WENYB_ = (RET1N_ | pre_charge_st) ? ({40{DFTRAMBYP_}} & (TENB_ ? WENB_ : TWENB_)) : {40{1'bx}};
  assign AYB_ = (RET1N_ | pre_charge_st) ? ({7{DFTRAMBYP_}} & (TENB_ ? AB_ : TAB_)) : {7{1'bx}};
  assign GWENYA_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENA_ ? GWENA_ : TGWENA_)) : 1'bx;
  assign GWENYB_ = (RET1N_ | pre_charge_st) ? (DFTRAMBYP_ & (TENB_ ? GWENB_ : TGWENB_)) : 1'bx;
   `ifdef ARM_FAULT_MODELING
     arm28hkcpdpsram128x40m4_error_injection u1(.CLK(CLKA_), .Q_out(QA_), .A(AA_int), .CEN(CENA_int), .DFTRAMBYP(DFTRAMBYP_int), .SE(SEA_int), .GWEN(GWENA_int), .WEN(WENA_int), .Q_in(QA_int));
  `else
  assign QA_ = (RET1N_ | pre_charge_st) ? ((QA_int)) : {40{1'bx}};
  `endif
  assign QB_ = (RET1N_ | pre_charge_st) ? ((QB_int)) : {40{1'bx}};
  assign SOA_ = (RET1N_ | pre_charge_st) ? ({QA_[20], QA_[19]}) : {2{1'bx}};
  assign SOB_ = (RET1N_ | pre_charge_st) ? ({QB_[20], QB_[19]}) : {2{1'bx}};

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
        writeEnable = {40{1'b1}};
        row_mask =  ( {3'b000, writeEnable[39], 3'b000, writeEnable[38], 3'b000, writeEnable[37],
          3'b000, writeEnable[36], 3'b000, writeEnable[35], 3'b000, writeEnable[34],
          3'b000, writeEnable[33], 3'b000, writeEnable[32], 3'b000, writeEnable[31],
          3'b000, writeEnable[30], 3'b000, writeEnable[29], 3'b000, writeEnable[28],
          3'b000, writeEnable[27], 3'b000, writeEnable[26], 3'b000, writeEnable[25],
          3'b000, writeEnable[24], 3'b000, writeEnable[23], 3'b000, writeEnable[22],
          3'b000, writeEnable[21], 3'b000, writeEnable[20], 3'b000, writeEnable[19],
          3'b000, writeEnable[18], 3'b000, writeEnable[17], 3'b000, writeEnable[16],
          3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[39], 3'b000, wordtemp[38], 3'b000, wordtemp[37],
          3'b000, wordtemp[36], 3'b000, wordtemp[35], 3'b000, wordtemp[34], 3'b000, wordtemp[33],
          3'b000, wordtemp[32], 3'b000, wordtemp[31], 3'b000, wordtemp[30], 3'b000, wordtemp[29],
          3'b000, wordtemp[28], 3'b000, wordtemp[27], 3'b000, wordtemp[26], 3'b000, wordtemp[25],
          3'b000, wordtemp[24], 3'b000, wordtemp[23], 3'b000, wordtemp[22], 3'b000, wordtemp[21],
          3'b000, wordtemp[20], 3'b000, wordtemp[19], 3'b000, wordtemp[18], 3'b000, wordtemp[17],
          3'b000, wordtemp[16], 3'b000, wordtemp[15], 3'b000, wordtemp[14], 3'b000, wordtemp[13],
          3'b000, wordtemp[12], 3'b000, wordtemp[11], 3'b000, wordtemp[10], 3'b000, wordtemp[9],
          3'b000, wordtemp[8], 3'b000, wordtemp[7], 3'b000, wordtemp[6], 3'b000, wordtemp[5],
          3'b000, wordtemp[4], 3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
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
        writeEnable = {40{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
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
	input [6:0] load_addr;
	input [39:0] load_data;
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
        writeEnable = {40{1'b1}};
        row_mask =  ( {3'b000, writeEnable[39], 3'b000, writeEnable[38], 3'b000, writeEnable[37],
          3'b000, writeEnable[36], 3'b000, writeEnable[35], 3'b000, writeEnable[34],
          3'b000, writeEnable[33], 3'b000, writeEnable[32], 3'b000, writeEnable[31],
          3'b000, writeEnable[30], 3'b000, writeEnable[29], 3'b000, writeEnable[28],
          3'b000, writeEnable[27], 3'b000, writeEnable[26], 3'b000, writeEnable[25],
          3'b000, writeEnable[24], 3'b000, writeEnable[23], 3'b000, writeEnable[22],
          3'b000, writeEnable[21], 3'b000, writeEnable[20], 3'b000, writeEnable[19],
          3'b000, writeEnable[18], 3'b000, writeEnable[17], 3'b000, writeEnable[16],
          3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[39], 3'b000, wordtemp[38], 3'b000, wordtemp[37],
          3'b000, wordtemp[36], 3'b000, wordtemp[35], 3'b000, wordtemp[34], 3'b000, wordtemp[33],
          3'b000, wordtemp[32], 3'b000, wordtemp[31], 3'b000, wordtemp[30], 3'b000, wordtemp[29],
          3'b000, wordtemp[28], 3'b000, wordtemp[27], 3'b000, wordtemp[26], 3'b000, wordtemp[25],
          3'b000, wordtemp[24], 3'b000, wordtemp[23], 3'b000, wordtemp[22], 3'b000, wordtemp[21],
          3'b000, wordtemp[20], 3'b000, wordtemp[19], 3'b000, wordtemp[18], 3'b000, wordtemp[17],
          3'b000, wordtemp[16], 3'b000, wordtemp[15], 3'b000, wordtemp[14], 3'b000, wordtemp[13],
          3'b000, wordtemp[12], 3'b000, wordtemp[11], 3'b000, wordtemp[10], 3'b000, wordtemp[9],
          3'b000, wordtemp[8], 3'b000, wordtemp[7], 3'b000, wordtemp[6], 3'b000, wordtemp[5],
          3'b000, wordtemp[4], 3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
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
	output [39:0] dump_data;
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
        writeEnable = {40{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
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
        DA_int = {40{1'bx}};

      mux_address = (AA_int & 2'b11);
      row_address = (AA_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 31)
        row = {160{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENA_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {40{1'bx}};
        DA_int = {40{1'bx}};
      end else
          writeEnable = ~ ( {40{GWENA_int}} | {WENA_int[39], WENA_int[38], WENA_int[37],
          WENA_int[36], WENA_int[35], WENA_int[34], WENA_int[33], WENA_int[32], WENA_int[31],
          WENA_int[30], WENA_int[29], WENA_int[28], WENA_int[27], WENA_int[26], WENA_int[25],
          WENA_int[24], WENA_int[23], WENA_int[22], WENA_int[21], WENA_int[20], WENA_int[19],
          WENA_int[18], WENA_int[17], WENA_int[16], WENA_int[15], WENA_int[14], WENA_int[13],
          WENA_int[12], WENA_int[11], WENA_int[10], WENA_int[9], WENA_int[8], WENA_int[7],
          WENA_int[6], WENA_int[5], WENA_int[4], WENA_int[3], WENA_int[2], WENA_int[1],
          WENA_int[0]});
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[39], 3'b000, writeEnable[38], 3'b000, writeEnable[37],
          3'b000, writeEnable[36], 3'b000, writeEnable[35], 3'b000, writeEnable[34],
          3'b000, writeEnable[33], 3'b000, writeEnable[32], 3'b000, writeEnable[31],
          3'b000, writeEnable[30], 3'b000, writeEnable[29], 3'b000, writeEnable[28],
          3'b000, writeEnable[27], 3'b000, writeEnable[26], 3'b000, writeEnable[25],
          3'b000, writeEnable[24], 3'b000, writeEnable[23], 3'b000, writeEnable[22],
          3'b000, writeEnable[21], 3'b000, writeEnable[20], 3'b000, writeEnable[19],
          3'b000, writeEnable[18], 3'b000, writeEnable[17], 3'b000, writeEnable[16],
          3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DA_int[39], 3'b000, DA_int[38], 3'b000, DA_int[37],
          3'b000, DA_int[36], 3'b000, DA_int[35], 3'b000, DA_int[34], 3'b000, DA_int[33],
          3'b000, DA_int[32], 3'b000, DA_int[31], 3'b000, DA_int[30], 3'b000, DA_int[29],
          3'b000, DA_int[28], 3'b000, DA_int[27], 3'b000, DA_int[26], 3'b000, DA_int[25],
          3'b000, DA_int[24], 3'b000, DA_int[23], 3'b000, DA_int[22], 3'b000, DA_int[21],
          3'b000, DA_int[20], 3'b000, DA_int[19], 3'b000, DA_int[18], 3'b000, DA_int[17],
          3'b000, DA_int[16], 3'b000, DA_int[15], 3'b000, DA_int[14], 3'b000, DA_int[13],
          3'b000, DA_int[12], 3'b000, DA_int[11], 3'b000, DA_int[10], 3'b000, DA_int[9],
          3'b000, DA_int[8], 3'b000, DA_int[7], 3'b000, DA_int[6], 3'b000, DA_int[5],
          3'b000, DA_int[4], 3'b000, DA_int[3], 3'b000, DA_int[2], 3'b000, DA_int[1],
          3'b000, DA_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEA_int === 1'b0) begin
        end else if (GWENA_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEA_int === 1'bx) begin
        	XQA = 1'b1; QA_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
      end
      if (GWENA_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QA_update = 1'b1; DA_sh_update = 1'b1;
        end else begin
          XQA = 1'b0; QA_update = 1'b1; DA_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
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
      WENA_int = {40{1'bx}};
      AA_int = {7{1'bx}};
      DA_int = {40{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {40{1'bx}};
      TAA_int = {7{1'bx}};
      TDA_int = {40{1'bx}};
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
      WENA_int = {40{1'bx}};
      AA_int = {7{1'bx}};
      DA_int = {40{1'bx}};
      EMAA_int = {3{1'bx}};
      EMAWA_int = {2{1'bx}};
      EMASA_int = 1'bx;
      TENA_int = 1'bx;
      TCENA_int = 1'bx;
      TWENA_int = {40{1'bx}};
      TAA_int = {7{1'bx}};
      TDA_int = {40{1'bx}};
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
        AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({40{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({40{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENA_int[39], WENA_int[38], WENA_int[37], WENA_int[36],
            WENA_int[35], WENA_int[34], WENA_int[33], WENA_int[32], WENA_int[31], WENA_int[30],
            WENA_int[29], WENA_int[28], WENA_int[27], WENA_int[26], WENA_int[25], WENA_int[24],
            WENA_int[23], WENA_int[22], WENA_int[21], WENA_int[20], WENA_int[19], WENA_int[18],
            WENA_int[17], WENA_int[16], WENA_int[15], WENA_int[14], WENA_int[13], WENA_int[12],
            WENA_int[11], WENA_int[10], WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6],
            WENA_int[5], WENA_int[4], WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          readWriteA;
          partial_mask = ~{WENB_int[39], WENB_int[38], WENB_int[37], WENB_int[36],
            WENB_int[35], WENB_int[34], WENB_int[33], WENB_int[32], WENB_int[31], WENB_int[30],
            WENB_int[29], WENB_int[28], WENB_int[27], WENB_int[26], WENB_int[25], WENB_int[24],
            WENB_int[23], WENB_int[22], WENB_int[21], WENB_int[20], WENB_int[19], WENB_int[18],
            WENB_int[17], WENB_int[16], WENB_int[15], WENB_int[14], WENB_int[13], WENB_int[12],
            WENB_int[11], WENB_int[10], WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6],
            WENB_int[5], WENB_int[4], WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
       === 1'bx)  && row_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
          DB_int = {40{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
          DA_int = {40{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
      partial_corrupt_A = 40'b0;
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
      DA_int = {40{1'bx}};
    end
      failedWrite(0);
    end else if (TENA_int === 1'bx) begin
      if(((CENA_ === 1'b1 & TCENA_ === 1'b1) & DFTRAMBYP_int === 1'b0) | (DFTRAMBYP_int === 1'b1 & SEA_int === 1'b1)) begin
      end else begin
        XQA = 1'b1; QA_update = 1'b1;
    if (clk0_int === 1'bx || CENA_int === 1'bx) begin
      DA_int = {40{1'bx}};
    end
      if (DFTRAMBYP_int === 1'b0) begin
          failedWrite(0);
      end
      end
    end else if (CENA_int === 1'b0 && (^AA_int) === 1'bx && DFTRAMBYP_int === 1'b0) begin
        failedWrite(0);
        XQA = 1'b1; QA_update = 1'b1;
    end else if  (cont_flag0_int === 1'bx && COLLDISN_int === 1'b1 &&  (CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1) && DFTRAMBYP_ !== 1'b1) 
     && row_contention(TENB_ ? AB_ : TAB_, AA_int, ({40{GWENA_int}}|WENA_int), TENB_ ? ({40{GWENB_}}|WENB_) : ({40{TGWENB_}}|TWENB_))) begin
      cont_flag0_int = 1'b0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, write A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
     	WENA_int =  (({40{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
 		WENB_int =  (({40{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          partial_mask = ~{WENA_int[39], WENA_int[38], WENA_int[37], WENA_int[36],
            WENA_int[35], WENA_int[34], WENA_int[33], WENA_int[32], WENA_int[31], WENA_int[30],
            WENA_int[29], WENA_int[28], WENA_int[27], WENA_int[26], WENA_int[25], WENA_int[24],
            WENA_int[23], WENA_int[22], WENA_int[21], WENA_int[20], WENA_int[19], WENA_int[18],
            WENA_int[17], WENA_int[16], WENA_int[15], WENA_int[14], WENA_int[13], WENA_int[12],
            WENA_int[11], WENA_int[10], WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6],
            WENA_int[5], WENA_int[4], WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          partial_mask = ~{WENB_int[39], WENB_int[38], WENB_int[37], WENB_int[36],
            WENB_int[35], WENB_int[34], WENB_int[33], WENB_int[32], WENB_int[31], WENB_int[30],
            WENB_int[29], WENB_int[28], WENB_int[27], WENB_int[26], WENB_int[25], WENB_int[24],
            WENB_int[23], WENB_int[22], WENB_int[21], WENB_int[20], WENB_int[19], WENB_int[18],
            WENB_int[17], WENB_int[16], WENB_int[15], WENB_int[14], WENB_int[13], WENB_int[12],
            WENB_int[11], WENB_int[10], WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6],
            WENB_int[5], WENB_int[4], WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
     || COLLDISN_int === 1'bx) && row_contention(TENB_ ? AB_ : TAB_, AA_int, ({40{GWENA_int}}|WENA_int), TENB_ ? ({40{GWENB_}}|WENB_) : ({40{TGWENB_}}|TWENB_))) 
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
          DB_int = {40{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
          DA_int = {40{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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

  datapath_latch_arm28hkcpdpsram128x40m4 uDQA0 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[0]), .D(DA_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[0]), .XQ(XQA|partial_corrupt_A[0]), .Q(QA_int[0]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA1 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[0]), .D(DA_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[1]), .XQ(XQA|partial_corrupt_A[1]), .Q(QA_int[1]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA2 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[1]), .D(DA_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[2]), .XQ(XQA|partial_corrupt_A[2]), .Q(QA_int[2]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA3 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[2]), .D(DA_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[3]), .XQ(XQA|partial_corrupt_A[3]), .Q(QA_int[3]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA4 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[3]), .D(DA_int_bmux[4]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[4]), .XQ(XQA|partial_corrupt_A[4]), .Q(QA_int[4]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA5 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[4]), .D(DA_int_bmux[5]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[5]), .XQ(XQA|partial_corrupt_A[5]), .Q(QA_int[5]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA6 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[5]), .D(DA_int_bmux[6]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[6]), .XQ(XQA|partial_corrupt_A[6]), .Q(QA_int[6]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA7 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[6]), .D(DA_int_bmux[7]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[7]), .XQ(XQA|partial_corrupt_A[7]), .Q(QA_int[7]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA8 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[7]), .D(DA_int_bmux[8]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[8]), .XQ(XQA|partial_corrupt_A[8]), .Q(QA_int[8]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA9 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[8]), .D(DA_int_bmux[9]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[9]), .XQ(XQA|partial_corrupt_A[9]), .Q(QA_int[9]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA10 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[9]), .D(DA_int_bmux[10]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[10]), .XQ(XQA|partial_corrupt_A[10]), .Q(QA_int[10]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA11 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[10]), .D(DA_int_bmux[11]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[11]), .XQ(XQA|partial_corrupt_A[11]), .Q(QA_int[11]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA12 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[11]), .D(DA_int_bmux[12]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[12]), .XQ(XQA|partial_corrupt_A[12]), .Q(QA_int[12]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA13 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[12]), .D(DA_int_bmux[13]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[13]), .XQ(XQA|partial_corrupt_A[13]), .Q(QA_int[13]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA14 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[13]), .D(DA_int_bmux[14]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[14]), .XQ(XQA|partial_corrupt_A[14]), .Q(QA_int[14]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA15 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[14]), .D(DA_int_bmux[15]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[15]), .XQ(XQA|partial_corrupt_A[15]), .Q(QA_int[15]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA16 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[15]), .D(DA_int_bmux[16]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[16]), .XQ(XQA|partial_corrupt_A[16]), .Q(QA_int[16]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA17 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[16]), .D(DA_int_bmux[17]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[17]), .XQ(XQA|partial_corrupt_A[17]), .Q(QA_int[17]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA18 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[17]), .D(DA_int_bmux[18]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[18]), .XQ(XQA|partial_corrupt_A[18]), .Q(QA_int[18]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA19 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[18]), .D(DA_int_bmux[19]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[19]), .XQ(XQA|partial_corrupt_A[19]), .Q(QA_int[19]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA20 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[21]), .D(DA_int_bmux[20]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[20]), .XQ(XQA|partial_corrupt_A[20]), .Q(QA_int[20]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA21 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[22]), .D(DA_int_bmux[21]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[21]), .XQ(XQA|partial_corrupt_A[21]), .Q(QA_int[21]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA22 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[23]), .D(DA_int_bmux[22]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[22]), .XQ(XQA|partial_corrupt_A[22]), .Q(QA_int[22]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA23 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[24]), .D(DA_int_bmux[23]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[23]), .XQ(XQA|partial_corrupt_A[23]), .Q(QA_int[23]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA24 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[25]), .D(DA_int_bmux[24]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[24]), .XQ(XQA|partial_corrupt_A[24]), .Q(QA_int[24]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA25 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[26]), .D(DA_int_bmux[25]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[25]), .XQ(XQA|partial_corrupt_A[25]), .Q(QA_int[25]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA26 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[27]), .D(DA_int_bmux[26]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[26]), .XQ(XQA|partial_corrupt_A[26]), .Q(QA_int[26]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA27 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[28]), .D(DA_int_bmux[27]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[27]), .XQ(XQA|partial_corrupt_A[27]), .Q(QA_int[27]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA28 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[29]), .D(DA_int_bmux[28]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[28]), .XQ(XQA|partial_corrupt_A[28]), .Q(QA_int[28]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA29 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[30]), .D(DA_int_bmux[29]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[29]), .XQ(XQA|partial_corrupt_A[29]), .Q(QA_int[29]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA30 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[31]), .D(DA_int_bmux[30]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[30]), .XQ(XQA|partial_corrupt_A[30]), .Q(QA_int[30]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA31 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[32]), .D(DA_int_bmux[31]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[31]), .XQ(XQA|partial_corrupt_A[31]), .Q(QA_int[31]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA32 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[33]), .D(DA_int_bmux[32]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[32]), .XQ(XQA|partial_corrupt_A[32]), .Q(QA_int[32]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA33 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[34]), .D(DA_int_bmux[33]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[33]), .XQ(XQA|partial_corrupt_A[33]), .Q(QA_int[33]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA34 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[35]), .D(DA_int_bmux[34]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[34]), .XQ(XQA|partial_corrupt_A[34]), .Q(QA_int[34]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA35 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[36]), .D(DA_int_bmux[35]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[35]), .XQ(XQA|partial_corrupt_A[35]), .Q(QA_int[35]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA36 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[37]), .D(DA_int_bmux[36]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[36]), .XQ(XQA|partial_corrupt_A[36]), .Q(QA_int[36]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA37 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[38]), .D(DA_int_bmux[37]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[37]), .XQ(XQA|partial_corrupt_A[37]), .Q(QA_int[37]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA38 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(QA_int[39]), .D(DA_int_bmux[38]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[38]), .XQ(XQA|partial_corrupt_A[38]), .Q(QA_int[38]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQA39 (.CLK(CLKA), .Q_update(QA_update), .D_update(DA_sh_update), .SE(SEA_), .SI(SIA_int[1]), .D(DA_int_bmux[39]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_A[39]), .XQ(XQA|partial_corrupt_A[39]), .Q(QA_int[39]));



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
        DB_int = {40{1'bx}};

      mux_address = (AB_int & 2'b11);
      row_address = (AB_int >> 2);
      if (DFTRAMBYP_int !== 1'b1) begin
      if (row_address > 31)
        row = {160{1'bx}};
      else
        row = mem[row_address];
      end
      if( (isBitX(GWENB_int) && DFTRAMBYP_int!==1) || isBitX(DFTRAMBYP_int) ) begin
        writeEnable = {40{1'bx}};
        DB_int = {40{1'bx}};
      end else
          writeEnable = ~ ( {40{GWENB_int}} | {WENB_int[39], WENB_int[38], WENB_int[37],
          WENB_int[36], WENB_int[35], WENB_int[34], WENB_int[33], WENB_int[32], WENB_int[31],
          WENB_int[30], WENB_int[29], WENB_int[28], WENB_int[27], WENB_int[26], WENB_int[25],
          WENB_int[24], WENB_int[23], WENB_int[22], WENB_int[21], WENB_int[20], WENB_int[19],
          WENB_int[18], WENB_int[17], WENB_int[16], WENB_int[15], WENB_int[14], WENB_int[13],
          WENB_int[12], WENB_int[11], WENB_int[10], WENB_int[9], WENB_int[8], WENB_int[7],
          WENB_int[6], WENB_int[5], WENB_int[4], WENB_int[3], WENB_int[2], WENB_int[1],
          WENB_int[0]});
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1 || DFTRAMBYP_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[39], 3'b000, writeEnable[38], 3'b000, writeEnable[37],
          3'b000, writeEnable[36], 3'b000, writeEnable[35], 3'b000, writeEnable[34],
          3'b000, writeEnable[33], 3'b000, writeEnable[32], 3'b000, writeEnable[31],
          3'b000, writeEnable[30], 3'b000, writeEnable[29], 3'b000, writeEnable[28],
          3'b000, writeEnable[27], 3'b000, writeEnable[26], 3'b000, writeEnable[25],
          3'b000, writeEnable[24], 3'b000, writeEnable[23], 3'b000, writeEnable[22],
          3'b000, writeEnable[21], 3'b000, writeEnable[20], 3'b000, writeEnable[19],
          3'b000, writeEnable[18], 3'b000, writeEnable[17], 3'b000, writeEnable[16],
          3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, DB_int[39], 3'b000, DB_int[38], 3'b000, DB_int[37],
          3'b000, DB_int[36], 3'b000, DB_int[35], 3'b000, DB_int[34], 3'b000, DB_int[33],
          3'b000, DB_int[32], 3'b000, DB_int[31], 3'b000, DB_int[30], 3'b000, DB_int[29],
          3'b000, DB_int[28], 3'b000, DB_int[27], 3'b000, DB_int[26], 3'b000, DB_int[25],
          3'b000, DB_int[24], 3'b000, DB_int[23], 3'b000, DB_int[22], 3'b000, DB_int[21],
          3'b000, DB_int[20], 3'b000, DB_int[19], 3'b000, DB_int[18], 3'b000, DB_int[17],
          3'b000, DB_int[16], 3'b000, DB_int[15], 3'b000, DB_int[14], 3'b000, DB_int[13],
          3'b000, DB_int[12], 3'b000, DB_int[11], 3'b000, DB_int[10], 3'b000, DB_int[9],
          3'b000, DB_int[8], 3'b000, DB_int[7], 3'b000, DB_int[6], 3'b000, DB_int[5],
          3'b000, DB_int[4], 3'b000, DB_int[3], 3'b000, DB_int[2], 3'b000, DB_int[1],
          3'b000, DB_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (DFTRAMBYP_int === 1'b1 && SEB_int === 1'b0) begin
        end else if (GWENB_int !== 1'b1 && DFTRAMBYP_int === 1'b1 && SEB_int === 1'bx) begin
        	XQB = 1'b1; QB_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[156], data_out[152], data_out[148], data_out[144], data_out[140],
          data_out[136], data_out[132], data_out[128], data_out[124], data_out[120],
          data_out[116], data_out[112], data_out[108], data_out[104], data_out[100],
          data_out[96], data_out[92], data_out[88], data_out[84], data_out[80], data_out[76],
          data_out[72], data_out[68], data_out[64], data_out[60], data_out[56], data_out[52],
          data_out[48], data_out[44], data_out[40], data_out[36], data_out[32], data_out[28],
          data_out[24], data_out[20], data_out[16], data_out[12], data_out[8], data_out[4],
          data_out[0]};
      end
      if (GWENB_int !== 1'b1 || DFTRAMBYP_int === 1'b1) begin
        if (WRITE_WRITE_CONTENTION) begin
          partial_corrupt_A = ~WENA_int & ~WENB_int; QB_update = 1'b1; DB_sh_update = 1'b1;
        end else begin
          XQB = 1'b0; QB_update = 1'b1; DB_sh_update = 1'b1;
        end
      end else begin
        shifted_readLatch1 = readLatch1;
        mem_path_B = {shifted_readLatch1[39], shifted_readLatch1[38], shifted_readLatch1[37],
          shifted_readLatch1[36], shifted_readLatch1[35], shifted_readLatch1[34], shifted_readLatch1[33],
          shifted_readLatch1[32], shifted_readLatch1[31], shifted_readLatch1[30], shifted_readLatch1[29],
          shifted_readLatch1[28], shifted_readLatch1[27], shifted_readLatch1[26], shifted_readLatch1[25],
          shifted_readLatch1[24], shifted_readLatch1[23], shifted_readLatch1[22], shifted_readLatch1[21],
          shifted_readLatch1[20], shifted_readLatch1[19], shifted_readLatch1[18], shifted_readLatch1[17],
          shifted_readLatch1[16], shifted_readLatch1[15], shifted_readLatch1[14], shifted_readLatch1[13],
          shifted_readLatch1[12], shifted_readLatch1[11], shifted_readLatch1[10], shifted_readLatch1[9],
          shifted_readLatch1[8], shifted_readLatch1[7], shifted_readLatch1[6], shifted_readLatch1[5],
          shifted_readLatch1[4], shifted_readLatch1[3], shifted_readLatch1[2], shifted_readLatch1[1],
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
      WENB_int = {40{1'bx}};
      AB_int = {7{1'bx}};
      DB_int = {40{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {40{1'bx}};
      TAB_int = {7{1'bx}};
      TDB_int = {40{1'bx}};
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
      WENB_int = {40{1'bx}};
      AB_int = {7{1'bx}};
      DB_int = {40{1'bx}};
      EMAB_int = {3{1'bx}};
      EMAWB_int = {2{1'bx}};
      EMASB_int = 1'bx;
      TENB_int = 1'bx;
      TCENB_int = 1'bx;
      TWENB_int = {40{1'bx}};
      TAB_int = {7{1'bx}};
      TDB_int = {40{1'bx}};
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
        AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
  	WENA_int =  (({40{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
  	WENB_int =  (({40{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENA_int[39], WENA_int[38], WENA_int[37], WENA_int[36],
            WENA_int[35], WENA_int[34], WENA_int[33], WENA_int[32], WENA_int[31], WENA_int[30],
            WENA_int[29], WENA_int[28], WENA_int[27], WENA_int[26], WENA_int[25], WENA_int[24],
            WENA_int[23], WENA_int[22], WENA_int[21], WENA_int[20], WENA_int[19], WENA_int[18],
            WENA_int[17], WENA_int[16], WENA_int[15], WENA_int[14], WENA_int[13], WENA_int[12],
            WENA_int[11], WENA_int[10], WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6],
            WENA_int[5], WENA_int[4], WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          readWriteB;
          partial_mask = ~{WENB_int[39], WENB_int[38], WENB_int[37], WENB_int[36],
            WENB_int[35], WENB_int[34], WENB_int[33], WENB_int[32], WENB_int[31], WENB_int[30],
            WENB_int[29], WENB_int[28], WENB_int[27], WENB_int[26], WENB_int[25], WENB_int[24],
            WENB_int[23], WENB_int[22], WENB_int[21], WENB_int[20], WENB_int[19], WENB_int[18],
            WENB_int[17], WENB_int[16], WENB_int[15], WENB_int[14], WENB_int[13], WENB_int[12],
            WENB_int[11], WENB_int[10], WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6],
            WENB_int[5], WENB_int[4], WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
       === 1'bx)  && row_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
          DA_int = {40{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
          DB_int = {40{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
      partial_corrupt_A = 40'b0;
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
      DB_int = {40{1'bx}};
    end
      failedWrite(1);
    end else if (TENB_int === 1'bx) begin
      if(((CENB_ === 1'b1 & TCENB_ === 1'b1) & DFTRAMBYP_int === 1'b0) | (DFTRAMBYP_int === 1'b1 & SEB_int === 1'b1)) begin
      end else begin
        XQB = 1'b1; QB_update = 1'b1;
    if (clk1_int === 1'bx || CENB_int === 1'bx) begin
      DB_int = {40{1'bx}};
    end
      if (DFTRAMBYP_int === 1'b0) begin
          failedWrite(1);
      end
      end
    end else if (CENB_int === 1'b0 && (^AB_int) === 1'bx && DFTRAMBYP_int === 1'b0) begin
        failedWrite(1);
        XQB = 1'b1; QB_update = 1'b1;
    end else if  (cont_flag1_int === 1'bx && COLLDISN_int === 1'b1 &&  (CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1) && DFTRAMBYP_ !== 1'b1) 
     && row_contention(TENA_ ? AA_ : TAA_, AB_int, ({40{GWENB_int}}|WENB_int), TENA_ ? ({40{GWENA_}}|WENA_) : ({40{TGWENA_}}|TWENA_))) begin
      cont_flag1_int = 1'b0;
        if (col_contention(AA_int, AB_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (GWENA_int !== 1'b1 && GWENB_int !== 1'b1) begin
	      if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          WRITE_WRITE_CONTENTION = 1;
          partial_mask_A = ~WENA_int & ~WENB_int;
          $display("%s contention: write B partially, write A partially in %m at %0t",ASSERT_PREFIX, $time);
          DA_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DA_int);
     	WENA_int =  (({40{1'bx}} & partial_mask_A) | WENA_int) ;
          readWriteA;
          DB_int = ({40{1'bx}} & partial_mask_A) | (~partial_mask_A & DB_int);
 		WENB_int =  (({40{1'bx}} & partial_mask_A) | WENB_int) ;
          readWriteB;
          WRITE_WRITE_CONTENTION = 0;
	      end
        end else if (GWENA_int !== 1'b1 && (& WENA_int) !== 1'b1) begin
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENA_int) == 1'b1) begin
          $display("%s contention: write A partially, read B partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteA;
          partial_mask = ~{WENA_int[39], WENA_int[38], WENA_int[37], WENA_int[36],
            WENA_int[35], WENA_int[34], WENA_int[33], WENA_int[32], WENA_int[31], WENA_int[30],
            WENA_int[29], WENA_int[28], WENA_int[27], WENA_int[26], WENA_int[25], WENA_int[24],
            WENA_int[23], WENA_int[22], WENA_int[21], WENA_int[20], WENA_int[19], WENA_int[18],
            WENA_int[17], WENA_int[16], WENA_int[15], WENA_int[14], WENA_int[13], WENA_int[12],
            WENA_int[11], WENA_int[10], WENA_int[9], WENA_int[8], WENA_int[7], WENA_int[6],
            WENA_int[5], WENA_int[4], WENA_int[3], WENA_int[2], WENA_int[1], WENA_int[0]};
        mem_path_B = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_B);
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
		if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
         if((|WENB_int) == 1'b1) begin
          $display("%s contention: write B partially, read A partially in %m at %0t",ASSERT_PREFIX, $time);
          ROW_CC = 1;
          COL_CC = 1;
          READ_WRITE = 1;
          readWriteB;
          partial_mask = ~{WENB_int[39], WENB_int[38], WENB_int[37], WENB_int[36],
            WENB_int[35], WENB_int[34], WENB_int[33], WENB_int[32], WENB_int[31], WENB_int[30],
            WENB_int[29], WENB_int[28], WENB_int[27], WENB_int[26], WENB_int[25], WENB_int[24],
            WENB_int[23], WENB_int[22], WENB_int[21], WENB_int[20], WENB_int[19], WENB_int[18],
            WENB_int[17], WENB_int[16], WENB_int[15], WENB_int[14], WENB_int[13], WENB_int[12],
            WENB_int[11], WENB_int[10], WENB_int[9], WENB_int[8], WENB_int[7], WENB_int[6],
            WENB_int[5], WENB_int[4], WENB_int[3], WENB_int[2], WENB_int[1], WENB_int[0]};
        mem_path_A = (partial_mask & {40{1'bx}}) | (~partial_mask & mem_path_A);
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
        if (!is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
     || COLLDISN_int === 1'bx) && row_contention(TENA_ ? AA_ : TAA_, AB_int, ({40{GWENB_int}}|WENB_int), TENA_ ? ({40{GWENA_}}|WENA_) : ({40{TGWENA_}}|TWENA_))) 
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
          DA_int = {40{1'bx}};
          readWriteA;
        XQA = 1'b1; QA_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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
          DB_int = {40{1'bx}};
          readWriteB;
        XQB = 1'b1; QB_update = 1'b1;
        end else if (is_contention(AA_int, AB_int, ({40{GWENA_int}}|WENA_int), ({40{GWENB_int}}|WENB_int))) begin
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

  datapath_latch_arm28hkcpdpsram128x40m4 uDQB0 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[0]), .D(DB_int_bmux[0]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[0]), .XQ(XQB|partial_corrupt_A[0]), .Q(QB_int[0]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB1 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[0]), .D(DB_int_bmux[1]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[1]), .XQ(XQB|partial_corrupt_A[1]), .Q(QB_int[1]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB2 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[1]), .D(DB_int_bmux[2]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[2]), .XQ(XQB|partial_corrupt_A[2]), .Q(QB_int[2]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB3 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[2]), .D(DB_int_bmux[3]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[3]), .XQ(XQB|partial_corrupt_A[3]), .Q(QB_int[3]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB4 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[3]), .D(DB_int_bmux[4]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[4]), .XQ(XQB|partial_corrupt_A[4]), .Q(QB_int[4]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB5 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[4]), .D(DB_int_bmux[5]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[5]), .XQ(XQB|partial_corrupt_A[5]), .Q(QB_int[5]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB6 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[5]), .D(DB_int_bmux[6]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[6]), .XQ(XQB|partial_corrupt_A[6]), .Q(QB_int[6]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB7 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[6]), .D(DB_int_bmux[7]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[7]), .XQ(XQB|partial_corrupt_A[7]), .Q(QB_int[7]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB8 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[7]), .D(DB_int_bmux[8]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[8]), .XQ(XQB|partial_corrupt_A[8]), .Q(QB_int[8]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB9 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[8]), .D(DB_int_bmux[9]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[9]), .XQ(XQB|partial_corrupt_A[9]), .Q(QB_int[9]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB10 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[9]), .D(DB_int_bmux[10]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[10]), .XQ(XQB|partial_corrupt_A[10]), .Q(QB_int[10]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB11 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[10]), .D(DB_int_bmux[11]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[11]), .XQ(XQB|partial_corrupt_A[11]), .Q(QB_int[11]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB12 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[11]), .D(DB_int_bmux[12]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[12]), .XQ(XQB|partial_corrupt_A[12]), .Q(QB_int[12]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB13 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[12]), .D(DB_int_bmux[13]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[13]), .XQ(XQB|partial_corrupt_A[13]), .Q(QB_int[13]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB14 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[13]), .D(DB_int_bmux[14]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[14]), .XQ(XQB|partial_corrupt_A[14]), .Q(QB_int[14]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB15 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[14]), .D(DB_int_bmux[15]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[15]), .XQ(XQB|partial_corrupt_A[15]), .Q(QB_int[15]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB16 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[15]), .D(DB_int_bmux[16]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[16]), .XQ(XQB|partial_corrupt_A[16]), .Q(QB_int[16]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB17 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[16]), .D(DB_int_bmux[17]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[17]), .XQ(XQB|partial_corrupt_A[17]), .Q(QB_int[17]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB18 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[17]), .D(DB_int_bmux[18]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[18]), .XQ(XQB|partial_corrupt_A[18]), .Q(QB_int[18]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB19 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[18]), .D(DB_int_bmux[19]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[19]), .XQ(XQB|partial_corrupt_A[19]), .Q(QB_int[19]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB20 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[21]), .D(DB_int_bmux[20]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[20]), .XQ(XQB|partial_corrupt_A[20]), .Q(QB_int[20]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB21 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[22]), .D(DB_int_bmux[21]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[21]), .XQ(XQB|partial_corrupt_A[21]), .Q(QB_int[21]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB22 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[23]), .D(DB_int_bmux[22]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[22]), .XQ(XQB|partial_corrupt_A[22]), .Q(QB_int[22]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB23 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[24]), .D(DB_int_bmux[23]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[23]), .XQ(XQB|partial_corrupt_A[23]), .Q(QB_int[23]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB24 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[25]), .D(DB_int_bmux[24]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[24]), .XQ(XQB|partial_corrupt_A[24]), .Q(QB_int[24]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB25 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[26]), .D(DB_int_bmux[25]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[25]), .XQ(XQB|partial_corrupt_A[25]), .Q(QB_int[25]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB26 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[27]), .D(DB_int_bmux[26]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[26]), .XQ(XQB|partial_corrupt_A[26]), .Q(QB_int[26]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB27 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[28]), .D(DB_int_bmux[27]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[27]), .XQ(XQB|partial_corrupt_A[27]), .Q(QB_int[27]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB28 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[29]), .D(DB_int_bmux[28]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[28]), .XQ(XQB|partial_corrupt_A[28]), .Q(QB_int[28]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB29 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[30]), .D(DB_int_bmux[29]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[29]), .XQ(XQB|partial_corrupt_A[29]), .Q(QB_int[29]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB30 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[31]), .D(DB_int_bmux[30]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[30]), .XQ(XQB|partial_corrupt_A[30]), .Q(QB_int[30]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB31 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[32]), .D(DB_int_bmux[31]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[31]), .XQ(XQB|partial_corrupt_A[31]), .Q(QB_int[31]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB32 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[33]), .D(DB_int_bmux[32]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[32]), .XQ(XQB|partial_corrupt_A[32]), .Q(QB_int[32]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB33 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[34]), .D(DB_int_bmux[33]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[33]), .XQ(XQB|partial_corrupt_A[33]), .Q(QB_int[33]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB34 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[35]), .D(DB_int_bmux[34]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[34]), .XQ(XQB|partial_corrupt_A[34]), .Q(QB_int[34]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB35 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[36]), .D(DB_int_bmux[35]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[35]), .XQ(XQB|partial_corrupt_A[35]), .Q(QB_int[35]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB36 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[37]), .D(DB_int_bmux[36]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[36]), .XQ(XQB|partial_corrupt_A[36]), .Q(QB_int[36]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB37 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[38]), .D(DB_int_bmux[37]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[37]), .XQ(XQB|partial_corrupt_A[37]), .Q(QB_int[37]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB38 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(QB_int[39]), .D(DB_int_bmux[38]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[38]), .XQ(XQB|partial_corrupt_A[38]), .Q(QB_int[38]));
  datapath_latch_arm28hkcpdpsram128x40m4 uDQB39 (.CLK(CLKB), .Q_update(QB_update), .D_update(DB_sh_update), .SE(SEB_), .SI(SIB_int[1]), .D(DB_int_bmux[39]), .DFTRAMBYP(DFTRAMBYP_), .mem_path(mem_path_B[39]), .XQ(XQB|partial_corrupt_A[39]), .Q(QB_int[39]));


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
    input [39:0] wena;
    input [39:0] wenb;
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
    input [39:0] wena;
    input [39:0] wenb;
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

   wire contA_flag = (CENA_int !== 1'b1 && ((TENB_ ? CENB_ : TCENB_) !== 1'b1)) && ((COLLDISN_int === 1'b1 && is_contention(TENB_ ? AB_ : TAB_, AA_int, TENB_ ? ({40{GWENB_}}|WENB_) : ({40{TGWENB_}}|TWENB_), ({40{GWENA_int}}|WENA_int))) ||
              ((COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENB_ ? AB_ : TAB_, AA_int, TENB_ ? ({40{GWENB_}}|WENB_) : ({40{TGWENB_}}|TWENB_), ({40{GWENA_int}}|WENA_int))));
   wire contB_flag = (CENB_int !== 1'b1 && ((TENA_ ? CENA_ : TCENA_) !== 1'b1)) && ((COLLDISN_int === 1'b1 && is_contention(TENA_ ? AA_ : TAA_, AB_int, TENA_ ? ({40{GWENA_}}|WENA_) : ({40{TGWENA_}}|TWENA_), ({40{GWENB_int}}|WENB_int))) ||
              ((COLLDISN_int === 1'b0 || COLLDISN_int === 1'bx) && row_contention(TENA_ ? AA_ : TAA_, AB_int, TENA_ ? ({40{GWENA_}}|WENA_) : ({40{TGWENA_}}|TWENA_), ({40{GWENB_int}}|WENB_int))));

  always @ NOT_CENA begin
    CENA_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA39 begin
    WENA_int[39] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA38 begin
    WENA_int[38] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA37 begin
    WENA_int[37] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA36 begin
    WENA_int[36] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA35 begin
    WENA_int[35] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA34 begin
    WENA_int[34] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA33 begin
    WENA_int[33] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA32 begin
    WENA_int[32] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA31 begin
    WENA_int[31] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA30 begin
    WENA_int[30] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA29 begin
    WENA_int[29] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA28 begin
    WENA_int[28] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA27 begin
    WENA_int[27] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA26 begin
    WENA_int[26] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA25 begin
    WENA_int[25] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA24 begin
    WENA_int[24] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA23 begin
    WENA_int[23] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA22 begin
    WENA_int[22] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA21 begin
    WENA_int[21] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA20 begin
    WENA_int[20] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA19 begin
    WENA_int[19] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA18 begin
    WENA_int[18] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA17 begin
    WENA_int[17] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA16 begin
    WENA_int[16] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA15 begin
    WENA_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_WENA14 begin
    WENA_int[14] = 1'bx;
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
  always @ NOT_DA39 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[39] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA38 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[38] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA37 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[37] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA36 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[36] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA35 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[35] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA34 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[34] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA33 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[33] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA32 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[32] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA31 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[31] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA30 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[30] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA29 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[29] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA28 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[28] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA27 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[27] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA26 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[26] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA25 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[25] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA24 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[24] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA23 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[23] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA22 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[22] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA21 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[21] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA20 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[20] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA19 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[19] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA18 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[18] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA17 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[17] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA16 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[16] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA15 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_DA14 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[14] = 1'bx;
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
  always @ NOT_WENB39 begin
    WENB_int[39] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB38 begin
    WENB_int[38] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB37 begin
    WENB_int[37] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB36 begin
    WENB_int[36] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB35 begin
    WENB_int[35] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB34 begin
    WENB_int[34] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB33 begin
    WENB_int[33] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB32 begin
    WENB_int[32] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB31 begin
    WENB_int[31] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB30 begin
    WENB_int[30] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB29 begin
    WENB_int[29] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB28 begin
    WENB_int[28] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB27 begin
    WENB_int[27] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB26 begin
    WENB_int[26] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB25 begin
    WENB_int[25] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB24 begin
    WENB_int[24] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB23 begin
    WENB_int[23] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB22 begin
    WENB_int[22] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB21 begin
    WENB_int[21] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB20 begin
    WENB_int[20] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB19 begin
    WENB_int[19] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB18 begin
    WENB_int[18] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB17 begin
    WENB_int[17] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB16 begin
    WENB_int[16] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB15 begin
    WENB_int[15] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_WENB14 begin
    WENB_int[14] = 1'bx;
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
  always @ NOT_DB39 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[39] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB38 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[38] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB37 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[37] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB36 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[36] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB35 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[35] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB34 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[34] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB33 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[33] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB32 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[32] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB31 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[31] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB30 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[30] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB29 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[29] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB28 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[28] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB27 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[27] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB26 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[26] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB25 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[25] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB24 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[24] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB23 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[23] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB22 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[22] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB21 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[21] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB20 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[20] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB19 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[19] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB18 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[18] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB17 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[17] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB16 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[16] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB15 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[15] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_DB14 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[14] = 1'bx;
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
  always @ NOT_TWENA39 begin
    WENA_int[39] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA38 begin
    WENA_int[38] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA37 begin
    WENA_int[37] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA36 begin
    WENA_int[36] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA35 begin
    WENA_int[35] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA34 begin
    WENA_int[34] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA33 begin
    WENA_int[33] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA32 begin
    WENA_int[32] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA31 begin
    WENA_int[31] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA30 begin
    WENA_int[30] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA29 begin
    WENA_int[29] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA28 begin
    WENA_int[28] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA27 begin
    WENA_int[27] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA26 begin
    WENA_int[26] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA25 begin
    WENA_int[25] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA24 begin
    WENA_int[24] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA23 begin
    WENA_int[23] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA22 begin
    WENA_int[22] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA21 begin
    WENA_int[21] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA20 begin
    WENA_int[20] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA19 begin
    WENA_int[19] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA18 begin
    WENA_int[18] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA17 begin
    WENA_int[17] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA16 begin
    WENA_int[16] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA15 begin
    WENA_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TWENA14 begin
    WENA_int[14] = 1'bx;
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
  always @ NOT_TDA39 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[39] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA38 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[38] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA37 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[37] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA36 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[36] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA35 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[35] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA34 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[34] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA33 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[33] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA32 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[32] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA31 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[31] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA30 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[30] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA29 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[29] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA28 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[28] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA27 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[27] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA26 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[26] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA25 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[25] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA24 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[24] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA23 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[23] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA22 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[22] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA21 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[21] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA20 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[20] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA19 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[19] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA18 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[18] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA17 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[17] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA16 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[16] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA15 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TDA14 begin
        XQA = 1'b1; QA_update = 1'b1;
    DA_int[14] = 1'bx;
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
  always @ NOT_TWENB39 begin
    WENB_int[39] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB38 begin
    WENB_int[38] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB37 begin
    WENB_int[37] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB36 begin
    WENB_int[36] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB35 begin
    WENB_int[35] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB34 begin
    WENB_int[34] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB33 begin
    WENB_int[33] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB32 begin
    WENB_int[32] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB31 begin
    WENB_int[31] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB30 begin
    WENB_int[30] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB29 begin
    WENB_int[29] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB28 begin
    WENB_int[28] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB27 begin
    WENB_int[27] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB26 begin
    WENB_int[26] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB25 begin
    WENB_int[25] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB24 begin
    WENB_int[24] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB23 begin
    WENB_int[23] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB22 begin
    WENB_int[22] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB21 begin
    WENB_int[21] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB20 begin
    WENB_int[20] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB19 begin
    WENB_int[19] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB18 begin
    WENB_int[18] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB17 begin
    WENB_int[17] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB16 begin
    WENB_int[16] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB15 begin
    WENB_int[15] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TWENB14 begin
    WENB_int[14] = 1'bx;
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
  always @ NOT_TDB39 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[39] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB38 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[38] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB37 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[37] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB36 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[36] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB35 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[35] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB34 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[34] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB33 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[33] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB32 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[32] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB31 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[31] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB30 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[30] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB29 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[29] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB28 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[28] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB27 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[27] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB26 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[26] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB25 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[25] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB24 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[24] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB23 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[23] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB22 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[22] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB21 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[21] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB20 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[20] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB19 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[19] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB18 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[18] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB17 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[17] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB16 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[16] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB15 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[15] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_TDB14 begin
        XQB = 1'b1; QB_update = 1'b1;
    DB_int[14] = 1'bx;
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
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA39eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA38eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA37eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA36eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA35eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA34eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA33eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA32eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA31eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA30eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA29eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA28eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA27eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA26eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA25eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA24eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA23eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA22eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA21eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA20eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA19eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA18eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA17eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA16eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA15eq0aGWENAeq0cpcp;
  wire RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA14eq0aGWENAeq0cpcp;
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
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB39eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB38eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB37eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB36eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB35eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB34eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB33eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB32eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB31eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB30eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB29eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB28eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB27eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB26eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB25eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB24eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB23eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB22eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB21eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB20eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB19eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB18eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB17eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB16eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB15eq0aGWENBeq0cpcp;
  wire RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB14eq0aGWENBeq0cpcp;
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
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA39eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA38eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA37eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA36eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA35eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA34eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA33eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA32eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA31eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA30eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA29eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA28eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA27eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA26eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA25eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA24eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA23eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA22eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA21eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA20eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA19eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA18eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA17eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA16eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA15eq0aTGWENAeq0cpcp;
  wire RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA14eq0aTGWENAeq0cpcp;
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
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB39eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB38eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB37eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB36eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB35eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB34eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB33eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB32eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB31eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB30eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB29eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB28eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB27eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB26eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB25eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB24eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB23eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB22eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB21eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB20eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB19eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB18eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB17eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB16eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB15eq0aTGWENBeq0cpcp;
  wire RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB14eq0aTGWENBeq0cpcp;
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
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA39eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[39]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA38eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[38]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA37eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[37]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA36eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[36]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA35eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[35]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA34eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[34]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA33eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[33]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA32eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[32]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA31eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[31]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA30eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[30]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA29eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[29]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA28eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[28]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA27eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[27]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA26eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[26]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA25eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[25]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA24eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[24]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA23eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[23]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA22eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[22]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA21eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[21]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA20eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[20]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA19eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[19]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA18eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[18]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA17eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[17]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA16eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[16]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA15eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[15]&&!GWENA));
  assign RET1Neq1aTENAeq1aopopDFTRAMBYPeq1aSEAeq0cpoopCENAeq0aDFTRAMBYPeq0aWENA14eq0aGWENAeq0cpcp = 
  RET1N&&TENA&&((DFTRAMBYP&&!SEA)||(!CENA&&!DFTRAMBYP&&!WENA[14]&&!GWENA));
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
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB39eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[39]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB38eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[38]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB37eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[37]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB36eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[36]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB35eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[35]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB34eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[34]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB33eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[33]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB32eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[32]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB31eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[31]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB30eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[30]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB29eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[29]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB28eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[28]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB27eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[27]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB26eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[26]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB25eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[25]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB24eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[24]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB23eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[23]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB22eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[22]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB21eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[21]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB20eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[20]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB19eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[19]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB18eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[18]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB17eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[17]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB16eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[16]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB15eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[15]&&!GWENB));
  assign RET1Neq1aTENBeq1aopopDFTRAMBYPeq1aSEBeq0cpoopCENBeq0aDFTRAMBYPeq0aWENB14eq0aGWENBeq0cpcp = 
  RET1N&&TENB&&((DFTRAMBYP&&!SEB)||(!CENB&&!DFTRAMBYP&&!WENB[14]&&!GWENB));
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
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA39eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[39]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA38eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[38]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA37eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[37]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA36eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[36]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA35eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[35]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA34eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[34]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA33eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[33]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA32eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[32]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA31eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[31]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA30eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[30]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA29eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[29]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA28eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[28]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA27eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[27]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA26eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[26]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA25eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[25]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA24eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[24]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA23eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[23]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA22eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[22]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA21eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[21]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA20eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[20]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA19eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[19]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA18eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[18]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA17eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[17]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA16eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[16]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA15eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[15]&&!TGWENA));
  assign RET1Neq1aTENAeq0aopopDFTRAMBYPeq1aSEAeq0cpoopTCENAeq0aDFTRAMBYPeq0aTWENA14eq0aTGWENAeq0cpcp = 
  RET1N&&!TENA&&((DFTRAMBYP&&!SEA)||(!TCENA&&!DFTRAMBYP&&!TWENA[14]&&!TGWENA));
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
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB39eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[39]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB38eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[38]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB37eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[37]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB36eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[36]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB35eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[35]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB34eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[34]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB33eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[33]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB32eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[32]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB31eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[31]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB30eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[30]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB29eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[29]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB28eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[28]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB27eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[27]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB26eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[26]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB25eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[25]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB24eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[24]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB23eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[23]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB22eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[22]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB21eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[21]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB20eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[20]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB19eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[19]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB18eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[18]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB17eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[17]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB16eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[16]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB15eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[15]&&!TGWENB));
  assign RET1Neq1aTENBeq0aopopDFTRAMBYPeq1aSEBeq0cpoopTCENBeq0aDFTRAMBYPeq0aTWENB14eq0aTGWENBeq0cpcp = 
  RET1N&&!TENB&&((DFTRAMBYP&&!SEB)||(!TCENB&&!DFTRAMBYP&&!TWENB[14]&&!TGWENB));
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
module arm28hkcpdpsram128x40m4_error_injection (Q_out, Q_in, CLK, A, CEN, DFTRAMBYP, SE, WEN, GWEN);
   output [39:0] Q_out;
   input [39:0] Q_in;
   input CLK;
   input [6:0] A;
   input CEN;
   input DFTRAMBYP;
   input SE;
   input [39:0] WEN;
   input GWEN;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter NO_RED_FAULT = 2'd0;
   reg [39:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [17:0] fault_table [31:0];
   reg [17:0] fault_entry;
initial
begin
   `ifdef DUT
      `define pre_pend_path TB.DUT_inst.CHIP
   `else
       `define pre_pend_path TB.CHIP
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST.u1.add_fault(7'd2,6'd6,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
      input [6:0] address;
      input [5:0] bitPlace;
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
            fault_entry[10:5] = bitPlace;
            fault_entry[17:11] = address;
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
   inout [39:0] q_int;
   input [1:0] fault_type;
   input [5:0] bitLoc;
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
   output [39:0] Q_output;
   reg list_complete;
   integer i;
   reg [4:0] row_address;
   reg [1:0] column_address;
   reg [5:0] bitPlace;
   reg [1:0] fault_type;
   reg [1:0] red_fault;
   reg valid;
   reg [4:0] msb_bit_calc;
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
               if (bitPlace < 20)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 20 )
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
