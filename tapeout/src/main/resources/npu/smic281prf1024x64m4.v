//----------------------------------------
/*
    Copyright (c) 2025 SMIC
    Filename   : smic281prf1024x64m4.v
    IP code    : S28HKCPHD1PRF
    Version    : V0P2A
    CreateDate : Jul 7, 2025 3:22:46 PM

    Verilog Model for High Speed One-Port SRAM
    SMIC 28 SFE Process

    Configuration: -instname smic281prf1024x64m4 
                   -words 1024 -bits 64 -mux 4 -bank 1

    Bit-Write: On
    Power-Management: On

*/

/*                                                                                 */
/*    -------------------------------------------------------------------------    */
/*                           Template Revision : 1.5.3.a                           */
/*    -------------------------------------------------------------------------    */
/*                                                                                 */
/* DISCLAIMER                                                                      */
/*                                                                                 */
/*   SMIC hereby provides the quality information to you but makes no claims,      */
/* promises or guarantees about the accuracy, completeness, or adequacy of the     */
/* information herein. The information contained herein is provided on an "AS IS"  */
/* basis without any warranty, and SMIC assumes no obligation to provide support   */
/* of any kind or otherwise maintain the information.                              */
/*   SMIC disclaims any representation that the information does not infringe any  */
/* intellectual property rights or proprietary rights of any third parties. SMIC   */
/* makes no other warranty, whether express, implied or statutory as to any        */
/* matter whatsoever, including but not limited to the accuracy or sufficiency of  */
/* any information or the merchantability and fitness for a particular purpose.    */
/* Neither SMIC nor any of its representatives shall be liable for any cause of    */
/* action incurred to connect to this service.                                     */
/*                                                                                 */
/* STATEMENT OF USE AND CONFIDENTIALITY                                            */
/*                                                                                 */
/*   The following/attached material contains confidential and proprietary         */
/* information of SMIC. This material is based upon information which SMIC         */
/* considers reliable, but SMIC neither represents nor warrants that such          */
/* information is accurate or complete, and it must not be relied upon as such.    */
/* This information was prepared for informational purposes and is for the use     */
/* by SMIC's customer only. SMIC reserves the right to make changes in the         */
/* information at any time without notice.                                         */
/*   No part of this information may be reproduced, transmitted, transcribed,      */
/* stored in a retrieval system, or translated into any human or computer          */
/* language, in any form or by any means, electronic, mechanical, magnetic,        */
/* optical, chemical, manual, or otherwise, without the prior written consent of   */
/* SMIC. Any unauthorized use or disclosure of this material is strictly           */
/* prohibited and may be unlawful. By accepting this material, the receiving       */
/* party shall be deemed to have acknowledged, accepted, and agreed to be bound    */
/* by the foregoing limitations and restrictions. Thank you.                       */
/*                                                                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                                 */
/*     - User can turn on fast functional model by option +define+FAST_FUNC        */
/*     - Fast functional model supports following path delays directives:          */
/*       + User can turn on CLK->Q delay by option +define+CKQ_DLY                 */
/*       + User can turn on SLP/SD->PUDLY_SLP/SD delay by option +define+PU_DLY    */
/*     - User can turn on error checks by option +define+xxx_CHECK_ON              */
/*     - Verilog model supports following error checks directives:                 */
/*       + ALL_CHECK_ON        : enable all checks          (default off)          */
/*       + HIGH_Z_CHECK_ON     : input pins Z               (default off)          */
/*       + CLOCK_X_CHECK_ON    : clock X                    (default off)          */
/*       + EN_X_CHECK_ON       : memory enable X            (default off)          */
/*       + ADR_X_CHECK_ON      : address bus X              (default off)          */
/*       + ADR_RANGE_CHECK_ON  : address range exceed       (default off)          */
/*       + DATA_X_CHECK_ON     : data bus X                 (default off)          */
/*       + BWEN_CHECK_ON       : bwen bus X                 (default off)          */
/*       + PM_CHECK_ON         : power mode message         (default off)          */
/*       + MEM_CHECK_ON        : memory corrupt             (default off)          */
/*       + TEST_CHECK_ON       : testpin undefault setting  (default off)          */
/*       + TIMING_CHECK_ON     : timing violation           (default off)          */
/*                                                                                 */


`timescale 1ns/1ps
`ifdef FAST_FUNC
    `ifdef CKQ_DLY
    `else
        `define CKQ_DLY #0.001
    `endif
    `ifdef PU_DLY
    `else
        `define PU_DLY #1
    `endif
`endif

`celldefine
module smic281prf1024x64m4(
`ifdef POWER_PINS
    VDD,
    VSS,
`endif
    CLK,
    CEN,
    WEN,
    A,
    D,
    Q,
    BWEN,
    SD,
    SLP,
    PUDLY_SD,
    PUDLY_SLP,
    RT,
    WT,
    TM
    );

  //////////////////////////////////////////////
  // PARAMETERS
  //////////////////////////////////////////////
  parameter WORDS        = 1024;  // words
  parameter A_WIDTH      = 10;  // address bits
  parameter D_WIDTH      = 64;  // data bits
  parameter MUX          = 4;  // mux
  parameter MEM_WIDTH    = 256; 
  parameter MEM_HEIGHT   = 256;
  parameter MEM_WIDTH_X  = {MEM_WIDTH{1'bx}};
  parameter D_WIDTH_X    = {D_WIDTH{1'bx}};
  parameter D_WIDTH_0    = {D_WIDTH{1'b0}};

  parameter RT_DEF       = 2'b00;
  parameter WT_DEF       = 2'b00;
  parameter TM_DEF       = 1'b0;


  //////////////////////////////////////////////
  // Inputs/Outputs
  input                      CLK;        
  input                      CEN;        
  input                      WEN;        
  input  [A_WIDTH-1:0]       A;          
  input  [D_WIDTH-1:0]       D;          
  input  [D_WIDTH-1:0]       BWEN;       
  input                      SD;         
  input                      SLP;        
  input  [1:0]               RT;         
  input  [1:0]               WT;         
  input                      TM;         
  output  [D_WIDTH-1:0]       Q;          
  output                      PUDLY_SD;   
  output                      PUDLY_SLP;  
`ifdef POWER_PINS
  inout                      VDD;        
  inout                      VSS;        
`endif

  // Wires
  // buffers for inputs/outputs
  wire                      CLK_buf;    
  wire                      CEN_buf;    
  wire                      WEN_buf;    
  wire  [A_WIDTH-1:0]       A_buf;      
  wire  [D_WIDTH-1:0]       D_buf;      
  wire  [D_WIDTH-1:0]       BWEN_buf;   
  wire                      SD_buf;     
  wire                      SLP_buf;    
  wire  [1:0]               RT_buf;     
  wire  [1:0]               WT_buf;     
  wire                      TM_buf;     
  wire  [D_WIDTH-1:0]       Q_buf;      
  wire                      PUDLY_SD_buf;
  wire                      PUDLY_SLP_buf;
`ifdef POWER_PINS
  wire                      VDD_buf;    
  wire                      VSS_buf;    
`endif
  wire  [D_WIDTH-1:0]       Q_out;      
  wire                      PUDLY_SD_out;
  wire                      PUDLY_SLP_out;
  wire                      pm_flag;
  wire                      nf_inputs_z;
  wire                      nf_inputs_01;
  wire                      nf_testpins_01;
  wire                      nf_testpins_def;
  wire                      changing_flag;
  wire                      clk_changing_flag;

  // Registers
  // register for inputs/outputs
  reg                      CLK_int;    
  reg                      CEN_int;    
  reg                      WEN_int;    
  reg  [A_WIDTH-1:0]       A_int;      
  reg  [D_WIDTH-1:0]       D_int;      
  reg  [D_WIDTH-1:0]       BWEN_int;   
  reg                      SD_int;     
  reg                      SLP_int;    
  reg  [1:0]               RT_int;     
  reg  [1:0]               WT_int;     
  reg                      TM_int;     
  reg  [D_WIDTH-1:0]       Q_int;      
  reg                      PUDLY_SD_int;
  reg                      PUDLY_SLP_int;
  reg                      CEN_in;     
  reg                      WEN_in;     
  reg  [A_WIDTH-1:0]       A_in;       
  reg  [D_WIDTH-1:0]       D_in;       
  reg  [D_WIDTH-1:0]       BWEN_in;    
  reg  [MEM_WIDTH-1:0]     MEM_ARRAY[MEM_HEIGHT-1:0];
  reg  [MEM_WIDTH-1:0]     mem_latch;
  reg                      q_x_ind;
  reg                      q_0_ind;
  reg                      q_out_ind;
  reg  [D_WIDTH-1:0]       q_out;
  reg                      A_vld_flag;

  // register for error check
  reg                      error_check_on;
  reg                      high_z_check_on;
  reg                      clock_x_check_on;
  reg                      en_x_check_on;
  reg                      adr_x_check_on;
  reg                      adr_range_check_on;
  reg                      data_x_check_on;
  reg                      bwen_x_check_on;
  reg                      pm_check_on;
  reg                      mem_check_on;
  reg                      test_check_on;
  reg                      timing_check_on;

  assign CLK_buf      = CLK;        
  assign CEN_buf      = CEN;        
  assign WEN_buf      = WEN;        
  assign A_buf        = A;          
  assign D_buf        = D;          
  assign BWEN_buf     = BWEN;       
  assign SD_buf       = SD;         
  assign SLP_buf      = SLP;        
  assign RT_buf       = RT;         
  assign WT_buf       = WT;         
  assign TM_buf       = TM;         
`ifdef POWER_PINS
  assign VDD_buf      = VDD;        
  assign VSS_buf      = VSS;        
`endif

  integer row_address;
  integer col_address;

  initial row_address = 0;
  initial col_address = 0;


`ifdef INIT_MEM_1
  integer i;
  initial begin
      for (i=0; i < MEM_HEIGHT; i=i+1) begin
          MEM_ARRAY[i] = {MEM_WIDTH{1'b1}};
      end 
  end
`endif

  task x_memory;
  integer i;
  begin
      if ($realtime != 0 && (mem_check_on || error_check_on)) $display("Time %t (MD): Entire memory invalidated in module %m", $realtime);
      for (i=0; i < MEM_HEIGHT; i=i+1) begin
          MEM_ARRAY[i] = MEM_WIDTH_X;
      end 
  end
  endtask

  task q_x_ram_x;
  begin
      q_x_ind = 1'b1;   
      x_memory;
  end
  endtask
  
  task q_0_ram_x;
  begin
      q_0_ind = 1'b1;   
      x_memory;
  end
  endtask

  task check_A;
  begin
      if (A_in > WORDS-1) begin 
          A_vld_flag = 1'b0;
          if ($realtime != 0 && (adr_range_check_on || error_check_on)) $display("Time %t (MD): Error! Detect address over valid range in module %m. Operation Failure !!!", $realtime);
      end    
      else begin
          A_vld_flag = 1'b1;
      end
  end
  endtask


  task update_int;
  begin
      CLK_int      = CLK_buf;    
      CEN_int      = CEN_buf;    
      WEN_int      = WEN_buf;    
      A_int        = A_buf;      
      D_int        = D_buf;      
      BWEN_int     = BWEN_buf;   
      SD_int       = SD_buf;     
      SLP_int      = SLP_buf;    
      RT_int       = RT_buf;     
      WT_int       = WT_buf;     
      TM_int       = TM_buf;     
  end
  endtask

  function [D_WIDTH-1:0] mem_rd_rslt;
  input   [A_WIDTH-1:0]   addr_rd;
  input   [MEM_WIDTH-1:0] mem_latch;
  begin
      mem_rd_rslt = {mem_latch[252], mem_latch[248], mem_latch[244], 
          mem_latch[240], mem_latch[236], mem_latch[232], mem_latch[228], mem_latch[224], mem_latch[220], 
          mem_latch[216], mem_latch[212], mem_latch[208], mem_latch[204], mem_latch[200], mem_latch[196], 
          mem_latch[192], mem_latch[188], mem_latch[184], mem_latch[180], mem_latch[176], mem_latch[172], 
          mem_latch[168], mem_latch[164], mem_latch[160], mem_latch[156], mem_latch[152], mem_latch[148], 
          mem_latch[144], mem_latch[140], mem_latch[136], mem_latch[132], mem_latch[128], mem_latch[124], 
          mem_latch[120], mem_latch[116], mem_latch[112], mem_latch[108], mem_latch[104], mem_latch[100], 
          mem_latch[96], mem_latch[92], mem_latch[88], mem_latch[84], mem_latch[80], mem_latch[76], 
          mem_latch[72], mem_latch[68], mem_latch[64], mem_latch[60], mem_latch[56], mem_latch[52], 
          mem_latch[48], mem_latch[44], mem_latch[40], mem_latch[36], mem_latch[32], mem_latch[28], 
          mem_latch[24], mem_latch[20], mem_latch[16], mem_latch[12], mem_latch[8], mem_latch[4], mem_latch[0]};      
  end    
  endfunction 

  function [MEM_WIDTH-1:0] mem_wr_rslt;
  input   [A_WIDTH-1:0]        addr_wr;
  input   [D_WIDTH-1:0]        data_wr;
  input   [D_WIDTH-1:0]        mask_wr;
  reg     [D_WIDTH-1:0]        data_mem;
  reg     [D_WIDTH-1:0]        data_real;
  reg     [MEM_WIDTH-1:0]      mem_latch;  
  reg     [MEM_WIDTH-1:0]      data_old;  
  reg     [MEM_WIDTH-1:0]      data_new;
  reg     [MEM_WIDTH-1:0]      pos;
  integer place_high, place_low;
  integer num;
  begin
      mem_latch = MEM_ARRAY[row_address] >> col_address;
      data_mem = mem_rd_rslt(addr_wr, mem_latch);
      data_real = ((data_mem & mask_wr) | (data_wr & ~mask_wr)) ^ (mask_wr ^ mask_wr);
      data_new = {3'b000, data_real[63], 3'b000, data_real[62], 3'b000, data_real[61], 3'b000, data_real[60], 
          3'b000, data_real[59], 3'b000, data_real[58], 3'b000, data_real[57], 3'b000, data_real[56], 3'b000, data_real[55], 3'b000, data_real[54], 
          3'b000, data_real[53], 3'b000, data_real[52], 3'b000, data_real[51], 3'b000, data_real[50], 3'b000, data_real[49], 3'b000, data_real[48], 
          3'b000, data_real[47], 3'b000, data_real[46], 3'b000, data_real[45], 3'b000, data_real[44], 3'b000, data_real[43], 3'b000, data_real[42], 
          3'b000, data_real[41], 3'b000, data_real[40], 3'b000, data_real[39], 3'b000, data_real[38], 3'b000, data_real[37], 3'b000, data_real[36], 
          3'b000, data_real[35], 3'b000, data_real[34], 3'b000, data_real[33], 3'b000, data_real[32], 3'b000, data_real[31], 3'b000, data_real[30], 
          3'b000, data_real[29], 3'b000, data_real[28], 3'b000, data_real[27], 3'b000, data_real[26], 3'b000, data_real[25], 3'b000, data_real[24], 
          3'b000, data_real[23], 3'b000, data_real[22], 3'b000, data_real[21], 3'b000, data_real[20], 3'b000, data_real[19], 3'b000, data_real[18], 
          3'b000, data_real[17], 3'b000, data_real[16], 3'b000, data_real[15], 3'b000, data_real[14], 3'b000, data_real[13], 3'b000, data_real[12], 
          3'b000, data_real[11], 3'b000, data_real[10], 3'b000, data_real[9], 3'b000, data_real[8], 3'b000, data_real[7], 3'b000, data_real[6], 
          3'b000, data_real[5], 3'b000, data_real[4], 3'b000, data_real[3], 3'b000, data_real[2], 3'b000, data_real[1], 3'b000, data_real[0]} << col_address;
      pos = 256'b0001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001 << col_address;
      data_old = MEM_ARRAY[row_address];
      mem_wr_rslt = data_new & pos | data_old & ~pos;
  end        
  endfunction 


  task rdwr_oneport;
  begin
      if (CEN_in === 1'bx) begin
          if ($realtime != 0 && (en_x_check_on || error_check_on)) $display("Error! CEN is X in module %m. Failure!!!", $realtime);
          q_x_ram_x;
      end
      else if (CEN_in === 1'b1) begin
      end
      else if (WEN_in === 1'bx) begin
          if ($realtime != 0 && (en_x_check_on || error_check_on)) $display("Error! WEN is X in module %m. Failure!!!", $realtime);
          q_x_ram_x;
      end
      else if (WEN_in === 1'b1) begin  // read
          if (^A_in === 1'bx) begin
              if ($realtime != 0 && (adr_x_check_on || error_check_on)) $display("Error! A is X in module %m when reading. Failure!!!", $realtime);
              q_x_ind = 1'b1;
          end
          else begin
              q_out_ind = 1'b1;
	          mem_latch = MEM_ARRAY[row_address] >> col_address;
              check_A;
              if (A_vld_flag == 1'b1) begin
                  q_out = mem_rd_rslt(A_in, mem_latch);
              end    
              else begin
                  q_out = D_WIDTH_X; 
              end
          end
      end
      else begin
          if (^A_in === 1'bx) begin
              if ($realtime != 0 && (adr_x_check_on || error_check_on)) $display("Error! A is X in module %m when writing. Failure!!!", $realtime);
              x_memory; 
          end
          else begin
              if (^BWEN_in === 1'bx)
                  if ($realtime != 0 && (bwen_x_check_on || error_check_on)) $display("Error! BWEN is X in module %m when writing. Failure!!!", $realtime);
              if (^D_in === 1'bx)
                  if ($realtime != 0 && (data_x_check_on || error_check_on)) $display("Error! D is X in module %m when writing. Failure!!!", $realtime);
              check_A;              
              if (A_vld_flag == 1'b1) begin
                  MEM_ARRAY[row_address] = mem_wr_rslt(A_in, D_in, BWEN_in);
              end
          end
      end
  end
  endtask

  initial begin
    q_0_ind        = 1'b0;
    q_x_ind        = 1'b0;
    q_out_ind      = 1'b0;
    A_vld_flag     = 1'b1;
    CLK_int      = 1'b0;
    CEN_int      = 1'b0;
    WEN_int      = 1'b0;
    A_int        = {A_WIDTH{1'b0}};
    D_int        = {D_WIDTH{1'b0}};
    BWEN_int     = {D_WIDTH{1'b0}};
    SD_int       = 1'b0;
    SLP_int      = 1'b0;
    CEN_in       = 1'b0;
    WEN_in       = 1'b0;
    A_in         = {A_WIDTH{1'b0}};
    D_in         = {D_WIDTH{1'b0}};
    BWEN_in      = {D_WIDTH{1'b0}};
    RT_int       = RT_DEF;     
    WT_int       = WT_DEF;     
    TM_int       = TM_DEF;     
  end

  initial begin
    error_check_on      = 1'b0;
    high_z_check_on     = 1'b0;
    clock_x_check_on    = 1'b0;
    en_x_check_on       = 1'b0;
    adr_x_check_on      = 1'b0;
    adr_range_check_on  = 1'b0;
    data_x_check_on     = 1'b0;
    bwen_x_check_on     = 1'b0;
    pm_check_on         = 1'b0;
    mem_check_on        = 1'b0;
    test_check_on       = 1'b0;
    timing_check_on     = 1'b0;
`ifdef ALL_CHECK_ON
    error_check_on      = 1'b1;
`endif
`ifdef HIGH_Z_CHECK_ON
    high_z_check_on     = 1'b1;
`endif
`ifdef CLOCK_X_CHECK_ON
    clock_x_check_on    = 1'b1;
`endif
`ifdef EN_X_CHECK_ON
    en_x_check_on       = 1'b1;
`endif
`ifdef ADR_X_CHECK_ON
    adr_x_check_on      = 1'b1;
`endif
`ifdef DATA_X_CHECK_ON
    data_x_check_on     = 1'b1;
`endif
`ifdef BWEN_CHECK_ON
    bwen_x_check_on     = 1'b1;
`endif
`ifdef PM_CHECK_ON
    pm_check_on         = 1'b1;
`endif
`ifdef MEM_CHECK_ON
    mem_check_on        = 1'b1;
`endif
`ifdef ADR_RANGE_CHECK_ON 
    adr_range_check_on  = 1'b1;
`endif
`ifdef TEST_CHECK_ON
    test_check_on       = 1'b1;
`endif
`ifdef TIMING_CHECK_ON
    timing_check_on     = 1'b1;
`endif
  end

  //////////////////////////////////////////////
  // Main
  //////////////////////////////////////////////
`ifdef POWER_PINS
  assign pm_flag = (VDD === 1'b1 && VSS === 1'b0) ? (SD_buf !== SD_int || SLP_buf !== SLP_int) : 1'b0;
`else
  assign pm_flag = (SD_buf !== SD_int) || (SLP_buf !== SLP_int);
`endif
  assign nf_inputs_z = (CLK_buf === 1'bz) || (CEN_buf === 1'bz) || (WEN_buf === 1'bz) || (A_buf[0] === 1'bz) || (A_buf[1] === 1'bz) || 
                (A_buf[2] === 1'bz) || (A_buf[3] === 1'bz) || (A_buf[4] === 1'bz) || (A_buf[5] === 1'bz) || (A_buf[6] === 1'bz) || 
                (A_buf[7] === 1'bz) || (A_buf[8] === 1'bz) || (A_buf[9] === 1'bz) || (D_buf[0] === 1'bz) || (D_buf[1] === 1'bz) || 
                (D_buf[2] === 1'bz) || (D_buf[3] === 1'bz) || (D_buf[4] === 1'bz) || (D_buf[5] === 1'bz) || (D_buf[6] === 1'bz) || 
                (D_buf[7] === 1'bz) || (D_buf[8] === 1'bz) || (D_buf[9] === 1'bz) || (D_buf[10] === 1'bz) || (D_buf[11] === 1'bz) || 
                (D_buf[12] === 1'bz) || (D_buf[13] === 1'bz) || (D_buf[14] === 1'bz) || (D_buf[15] === 1'bz) || (D_buf[16] === 1'bz) || 
                (D_buf[17] === 1'bz) || (D_buf[18] === 1'bz) || (D_buf[19] === 1'bz) || (D_buf[20] === 1'bz) || (D_buf[21] === 1'bz) || 
                (D_buf[22] === 1'bz) || (D_buf[23] === 1'bz) || (D_buf[24] === 1'bz) || (D_buf[25] === 1'bz) || (D_buf[26] === 1'bz) || 
                (D_buf[27] === 1'bz) || (D_buf[28] === 1'bz) || (D_buf[29] === 1'bz) || (D_buf[30] === 1'bz) || (D_buf[31] === 1'bz) || 
                (D_buf[32] === 1'bz) || (D_buf[33] === 1'bz) || (D_buf[34] === 1'bz) || (D_buf[35] === 1'bz) || (D_buf[36] === 1'bz) || 
                (D_buf[37] === 1'bz) || (D_buf[38] === 1'bz) || (D_buf[39] === 1'bz) || (D_buf[40] === 1'bz) || (D_buf[41] === 1'bz) || 
                (D_buf[42] === 1'bz) || (D_buf[43] === 1'bz) || (D_buf[44] === 1'bz) || (D_buf[45] === 1'bz) || (D_buf[46] === 1'bz) || 
                (D_buf[47] === 1'bz) || (D_buf[48] === 1'bz) || (D_buf[49] === 1'bz) || (D_buf[50] === 1'bz) || (D_buf[51] === 1'bz) || 
                (D_buf[52] === 1'bz) || (D_buf[53] === 1'bz) || (D_buf[54] === 1'bz) || (D_buf[55] === 1'bz) || (D_buf[56] === 1'bz) || 
                (D_buf[57] === 1'bz) || (D_buf[58] === 1'bz) || (D_buf[59] === 1'bz) || (D_buf[60] === 1'bz) || (D_buf[61] === 1'bz) || 
                (D_buf[62] === 1'bz) || (D_buf[63] === 1'bz) || (BWEN_buf[0] === 1'bz) || (BWEN_buf[1] === 1'bz) || (BWEN_buf[2] === 1'bz) || 
                (BWEN_buf[3] === 1'bz) || (BWEN_buf[4] === 1'bz) || (BWEN_buf[5] === 1'bz) || (BWEN_buf[6] === 1'bz) || (BWEN_buf[7] === 1'bz) || 
                (BWEN_buf[8] === 1'bz) || (BWEN_buf[9] === 1'bz) || (BWEN_buf[10] === 1'bz) || (BWEN_buf[11] === 1'bz) || (BWEN_buf[12] === 1'bz) || 
                (BWEN_buf[13] === 1'bz) || (BWEN_buf[14] === 1'bz) || (BWEN_buf[15] === 1'bz) || (BWEN_buf[16] === 1'bz) || (BWEN_buf[17] === 1'bz) || 
                (BWEN_buf[18] === 1'bz) || (BWEN_buf[19] === 1'bz) || (BWEN_buf[20] === 1'bz) || (BWEN_buf[21] === 1'bz) || (BWEN_buf[22] === 1'bz) || 
                (BWEN_buf[23] === 1'bz) || (BWEN_buf[24] === 1'bz) || (BWEN_buf[25] === 1'bz) || (BWEN_buf[26] === 1'bz) || (BWEN_buf[27] === 1'bz) || 
                (BWEN_buf[28] === 1'bz) || (BWEN_buf[29] === 1'bz) || (BWEN_buf[30] === 1'bz) || (BWEN_buf[31] === 1'bz) || (BWEN_buf[32] === 1'bz) || 
                (BWEN_buf[33] === 1'bz) || (BWEN_buf[34] === 1'bz) || (BWEN_buf[35] === 1'bz) || (BWEN_buf[36] === 1'bz) || (BWEN_buf[37] === 1'bz) || 
                (BWEN_buf[38] === 1'bz) || (BWEN_buf[39] === 1'bz) || (BWEN_buf[40] === 1'bz) || (BWEN_buf[41] === 1'bz) || (BWEN_buf[42] === 1'bz) || 
                (BWEN_buf[43] === 1'bz) || (BWEN_buf[44] === 1'bz) || (BWEN_buf[45] === 1'bz) || (BWEN_buf[46] === 1'bz) || (BWEN_buf[47] === 1'bz) || 
                (BWEN_buf[48] === 1'bz) || (BWEN_buf[49] === 1'bz) || (BWEN_buf[50] === 1'bz) || (BWEN_buf[51] === 1'bz) || (BWEN_buf[52] === 1'bz) || 
                (BWEN_buf[53] === 1'bz) || (BWEN_buf[54] === 1'bz) || (BWEN_buf[55] === 1'bz) || (BWEN_buf[56] === 1'bz) || (BWEN_buf[57] === 1'bz) || 
                (BWEN_buf[58] === 1'bz) || (BWEN_buf[59] === 1'bz) || (BWEN_buf[60] === 1'bz) || (BWEN_buf[61] === 1'bz) || (BWEN_buf[62] === 1'bz) || 
                (BWEN_buf[63] === 1'bz) || 1'b0;
  assign nf_inputs_01 = (^CLK_buf !== 1'bx) && (^CEN_buf !== 1'bx) && (^WEN_buf !== 1'bx) && (^A_buf !== 1'bx) && (^D_buf !== 1'bx) && 
                (^BWEN_buf !== 1'bx) && 1'b1;
  assign nf_testpins_01 = (^RT_buf !== 1'bx) && (^WT_buf !== 1'bx) && (^TM_buf !== 1'bx) && 1'b1;
  assign nf_testpins_def = (RT_buf === RT_DEF) && (WT_buf === WT_DEF) && (TM_buf === TM_DEF) && 1'b1;
`ifdef POWER_PINS
  assign changing_flag = (VDD === 1'b1 && VSS === 1'b0) ? ((CLK_int !== CLK_buf) || (CEN_int !== CEN_buf) || (WEN_int !== WEN_buf) || (A_int !== A_buf) || (D_int !== D_buf) || 
                (BWEN_int !== BWEN_buf) || (RT_int !== RT_buf) || (WT_int !== WT_buf) || (TM_int !== TM_buf) || 1'b0) : 1'b0;
`else
  assign changing_flag = (CLK_int !== CLK_buf) || (CEN_int !== CEN_buf) || (WEN_int !== WEN_buf) || (A_int !== A_buf) || (D_int !== D_buf) || 
                (BWEN_int !== BWEN_buf) || (RT_int !== RT_buf) || (WT_int !== WT_buf) || (TM_int !== TM_buf) || 1'b0;
`endif
  assign clk_changing_flag = (CLK_int !== CLK_buf);

  always @(RT_buf) begin
`ifdef POWER_PINS
    if (VDD_buf === 1'b1 && VSS_buf === 1'b0) begin
`endif
      if(SD_buf == 1'b0 && SLP_buf == 1'b0) begin
        if(RT_buf !== RT_DEF) 
            if ($realtime != 0 && (test_check_on || error_check_on))
                $display("Time %t (MD): Warning: Pin RT must be set to %b\n\tFor more information, please contact IP owner.", $time, RT_DEF);  
      end
`ifdef POWER_PINS
    end
`endif
  end

  always @(WT_buf) begin
`ifdef POWER_PINS
    if (VDD_buf === 1'b1 && VSS_buf === 1'b0) begin
`endif
      if(SD_buf == 1'b0 && SLP_buf == 1'b0) begin
        if(WT_buf !== WT_DEF) 
            if ($realtime != 0 && (test_check_on || error_check_on))
                $display("Time %t (MD): Warning: Pin WT must be set to %b\n\tFor more information, please contact IP owner.", $time, WT_DEF);  
      end
`ifdef POWER_PINS
    end
`endif
  end

  always @(TM_buf) begin
`ifdef POWER_PINS
    if (VDD_buf === 1'b1 && VSS_buf === 1'b0) begin
`endif
      if(SD_buf == 1'b0 && SLP_buf == 1'b0) begin
        if(TM_buf !== TM_DEF) 
            if ($realtime != 0 && (test_check_on || error_check_on))
                $display("Time %t (MD): Warning: Pin TM must be set to %b\n\tFor more information, please contact IP owner.", $time, TM_DEF);  
      end
`ifdef POWER_PINS
    end
`endif
  end





`ifdef POWER_PINS
  always @(VDD_buf or VSS_buf) begin
      if (VDD_buf !== 1'b1 || VSS_buf !== 1'b0) begin
          q_x_ram_x;
          if (VDD_buf === 1'bx || VDD_buf === 1'bz) begin
              if ($realtime != 0) 
                  $display("Time %t (MD): Error: Unknown value for VDD in %m", $realtime);
          end
          else if (VDD_buf !== 1'b1) begin
              if ($realtime != 0) 
                  $display("Time %t (MD): Error: VDD = %b is invalid in %m.", $realtime, VDD_buf);
          end
          if (VSS_buf === 1'bx || VSS_buf === 1'bz) begin
              if ($realtime != 0) 
                  $display("Time %t (MD): Error: Unknown value for VSS in %m", $realtime);
          end
          else if (VSS_buf !== 1'b0) begin
              if ($realtime != 0) 
                  $display("Time %t (MD): Error: VSS = %b is invalid in %m.", $realtime, VSS_buf);
          end
      end
  end
`endif

  event normal_function;

  always @(posedge pm_flag or posedge changing_flag) begin
      #0;
`ifdef POWER_PINS
    if (VDD_buf === 1'b1 && VSS_buf === 1'b0) begin
`endif
      if (SD_buf !== SD_int) begin
          if(SD_buf === 1'bx || SD_buf === 1'bz) begin
              if ($realtime != 0 && (pm_check_on || error_check_on))
                  $display("Error! Time %t (MD): SD is changing to X/Z in module %m.", $realtime);
              q_x_ram_x;
          end
          else if (SLP_buf === 1'b0 && SD_buf === 1'b1 && SD_int === 1'b0 && clk_changing_flag == 1'b0 && 
                   nf_testpins_def == 1'b1 && nf_inputs_01 == 1'b1) begin
              if ($realtime != 0 && (pm_check_on || error_check_on))
                  $display("Time %t (MD): Enter the Shut Down mode now in module %m.", $realtime);
              q_0_ram_x;
          end
          else if (SLP_buf === 1'b0 && SD_buf === 1'b0 && SD_int === 1'b1 && clk_changing_flag == 1'b0 && 
                   nf_testpins_def == 1'b1 && nf_inputs_01 == 1'b1) begin
              if ($realtime != 0 && (pm_check_on || error_check_on))
                  $display("Time %t (MD): Exit the Shut Down mode now in module %m.", $realtime);
              q_x_ram_x;
          end
          else if (SLP_buf !== SLP_int) begin
              if ($realtime != 0 && (pm_check_on || error_check_on))
                  $display("Error! Time %t (MD): SLP is changing when SD is changing in module %m. Failure!!!", $realtime);
              q_x_ram_x;
          end    
          else begin
              if ($realtime != 0 && (pm_check_on || error_check_on))
                  $display("Error! Time %t (MD): The conditions are not suitable when SD is changing in module %m. Failure!!!", $realtime);
              q_x_ram_x;
          end
          update_int;
          mem_latch = MEM_WIDTH_X;
      end    
      else if (SLP_buf !== SLP_int) begin
          if (SD_buf === 1'b1 && SLP_buf !== 1'bx && SLP_buf !== 1'bz) begin
          end // keep
          else if (SLP_buf === 1'bx || SLP_buf === 1'bz) begin
              if ($realtime != 0 && (pm_check_on || error_check_on)) 
                  $display("Time %t (MD): Error! SLP is changing to X/Z in module %m. Failure!!!", $realtime);
              q_x_ram_x;
          end          
          else if (SD_buf === 1'b0 && SLP_buf === 1'b1 && SLP_int === 1'b0 && clk_changing_flag == 1'b0 && 
                   nf_testpins_def == 1'b1 && nf_inputs_01 == 1'b1) begin
              if ($realtime != 0 && (pm_check_on || error_check_on))
                  $display("Time %t (MD): Enter the Deep Sleep mode now in module %m.", $realtime);
              q_0_ind = 1'b1;
          end     
          else if (SD_buf === 1'b0 && SLP_buf === 1'b0 && SLP_int === 1'b1 && clk_changing_flag == 1'b0 && 
                   nf_testpins_def == 1'b1 && nf_inputs_01 == 1'b1) begin
              if ($realtime != 0 && (pm_check_on || error_check_on))
                  $display("Time %t (MD): Exit the Deep Sleep mode now in module %m.", $realtime);
              q_x_ind = 1'b1;
          end    
          else begin
              if ($realtime != 0 && (pm_check_on || error_check_on))
                  $display("Error! Time %t (MD): The conditions are not suitable when SLP is changing in module %m. Failure!!!", $realtime);
              q_x_ram_x;
          end
          update_int;
          mem_latch = MEM_WIDTH_X;
      end    
      else if (SD_buf === 1'bx || SD_buf === 1'bz) begin
          if ($realtime != 0 && (pm_check_on || error_check_on))
              $display("Error! Time %t (MD): SD is X or Z when input_pins is changing in module %m. Failure!!!", $realtime);
          update_int;
      end
      else if (SD_buf === 1'b1) begin
          update_int;
      end
      else if (SLP_buf === 1'bx || SLP_buf === 1'bz) begin  // SD = 0
          q_x_ram_x;
          if ($realtime != 0 && (pm_check_on || error_check_on))
              $display("Error! Time %t (MD): SLP is X or Z when input_pins is changing and SD is low in module %m. Failure!!!", $realtime);
          update_int;
      end
      else if (SLP_buf === 1'b1) begin   // SD = 0
          update_int;
      end
      else begin
          ->normal_function;
      end
`ifdef POWER_PINS
    end
`endif
  end

  always @(normal_function) begin
      if (nf_testpins_def != 1'b1) begin  // SD = SLP = 0
          if ($realtime != 0 && (test_check_on || error_check_on))
              $display("Error! Time %t (MD): nf_testpins is not default setting during Normal Function Mode in module %m. Failure!!!", $realtime);
          q_x_ram_x;
      end
      else if (nf_inputs_z == 1'b1) begin  // SD = SLP = 0
          if ($realtime != 0 && (high_z_check_on || error_check_on))
              $display("Error! Time %t (MD): Input pins(CLK/CEN/WEN/BWEN/A/D) High-Z is not allowed in module %m!. Failure!!!", $realtime);
          q_x_ram_x;
      end
      else if (CLK_buf === 1'bx) begin
          if ($realtime != 0 && (clock_x_check_on || error_check_on))
              $display("Error! Time %t (MD): CLK is X during Normal Function Mode in module %m. Failure!!!", $realtime);
          q_x_ram_x;
      end
      else begin
          q_out = Q_int;
          if (CLK_buf === 1'b1 && CLK_int === 1'b0) begin  // posedge
              CEN_in = CEN_buf;
              WEN_in = WEN_buf;
              BWEN_in = BWEN_buf;
              A_in = A_buf;
              D_in = D_buf;
                  col_address = A_in & 2'b11;
                  row_address = A_in >> 2;
                  rdwr_oneport;
          end
      end
      update_int;
  end

  always @(*) begin
`ifdef POWER_PINS
    if (VDD_buf === 1'b1 && VSS_buf === 1'b0) begin
`endif
      if (q_x_ind == 1'b1) begin
          Q_int = D_WIDTH_X;
          q_x_ind = 1'b0; 
      end
      else if (q_0_ind == 1'b1) begin
          Q_int = D_WIDTH_0;
          q_0_ind = 1'b0;
      end
      else if (q_out_ind == 1'b1) begin
          Q_int = q_out;
          q_out_ind = 1'b0;
      end
`ifdef POWER_PINS
    end
`endif
  end

  assign Q_out = Q_int;

`ifdef FAST_FUNC
  assign `CKQ_DLY Q_buf = Q_out;
  assign `PU_DLY PUDLY_SLP_buf = SLP_buf;
  assign `PU_DLY PUDLY_SD_buf = SD_buf;
`else
  assign Q_buf = Q_out;
  assign PUDLY_SLP_buf = SLP_buf;
  assign PUDLY_SD_buf = SD_buf;
`endif
`ifdef POWER_PINS
  assign Q = (VDD_buf === 1'b1 && VSS_buf === 1'b0) ? Q_buf : D_WIDTH_X;
  assign PUDLY_SLP = (VDD_buf === 1'b1 && VSS_buf === 1'b0) ? PUDLY_SLP_buf : 1'bx;
  assign PUDLY_SD = (VDD_buf === 1'b1 && VSS_buf === 1'b0) ? PUDLY_SD_buf : 1'bx;
`else
  assign Q = Q_buf;  
  assign PUDLY_SLP = PUDLY_SLP_buf;  
  assign PUDLY_SD = PUDLY_SD_buf;  
`endif

  // Violation processors
`ifdef  FAST_FUNC
`else
  reg           CLK_peri_noti;
  reg           CLK_l_noti;
  reg           CLK_h_noti;
  reg           CEN_noti;   
  reg           WEN_noti;   
  reg           A_noti;     
  reg           D_noti;     
  reg           BWEN_noti;  
  reg           SD_noti;    
  reg           SLP_noti;   
  reg           RT_noti;    
  reg           WT_noti;    
  reg           TM_noti;    

  always @(CLK_peri_noti) begin
      q_x_ram_x;
      if ($realtime != 0 && (timing_check_on || error_check_on)) 
          $display("Time %t (MD): Error! The period of CLK is violated in module %m.", $realtime);
  end
  
  always @(CLK_l_noti) begin
      q_x_ram_x;
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! The low width of CLK is violated in module %m.", $realtime);
  end
  
  always @(CLK_h_noti) begin
      q_x_ram_x;
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! The high width of CLK is violated in module %m.", $realtime);
  end
  
  always @(CEN_noti) begin
      q_x_ram_x;
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! CEN is timing violated(setup/hold) in module %m.", $realtime);
  end
  
  always @(WEN_noti) begin
      q_x_ram_x;
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! WEN is timing violated(setup/hold) in module %m.", $realtime);
  end
  
  always @(BWEN_noti) begin
      check_A;
      if (A_vld_flag == 1'b1) 
          MEM_ARRAY[row_address] = mem_wr_rslt(A_in, D_in, D_WIDTH_X);
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! BWEN is timing violated(setup/hold) in module %m.", $realtime);
  end
    
  always @(A_noti) begin
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! A is timing violated(setup/hold) during reading or writing in module %m.", $realtime);
      if (WEN_buf === 1'b1) 
        q_x_ind = 1'b1;
      else    
        x_memory;
  end
  
  always @(D_noti) begin
      check_A;
      if (A_vld_flag == 1'b1) begin
          MEM_ARRAY[row_address] = mem_wr_rslt(A_in, D_WIDTH_X, BWEN_in);
      end
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! D is timing violated(setup/hold) during memory write in module %m.", $realtime);
  end
  

  always @(SD_noti) begin
      q_x_ram_x;
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! SD is timing violated(setup/hold) in module %m.", $realtime);
  end
  
  always @(SLP_noti) begin
      q_x_ram_x;
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! SLP is timing violated(setup/hold) in module %m.", $realtime);
  end
  
  always @(RT_noti) begin
      q_x_ram_x;
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! RT is timing violated(setup/hold) in module %m.", $realtime);
  end
  
  always @(WT_noti) begin
      q_x_ram_x;
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! WT is timing violated(setup/hold) in module %m.", $realtime);
  end
  
  always @(TM_noti) begin
      q_x_ram_x;
      if ($realtime != 0 && (timing_check_on || error_check_on))
          $display("Time %t (MD): Error! TM is timing violated(setup/hold) in module %m.", $realtime);
  end
  


    wire   Nsd;
    assign Nsd = !SD;
    wire   Nslp;
    assign Nslp = !SLP;
    wire   NcenAwenANslpANsd;
    assign NcenAwenANslpANsd = !CEN && WEN && !SLP && !SD;
    wire   NcenANslpANsd;
    assign NcenANslpANsd = !CEN && !SLP && !SD;
    wire   NslpANsd;
    assign NslpANsd = !SLP && !SD;
    wire   NcenANwenANslpANsd;
    assign NcenANwenANslpANsd = !CEN && !WEN && !SLP && !SD;
    wire   CLK_tmp;
    assign CLK_tmp = ^CLK;
    wire   CEN_tmp;
    assign CEN_tmp = ^CEN;
    wire   WEN_tmp;
    assign WEN_tmp = ^WEN;
    wire   [9:0] A_tmp;
    assign A_tmp[0] = ^A[0];
    assign A_tmp[1] = ^A[1];
    assign A_tmp[2] = ^A[2];
    assign A_tmp[3] = ^A[3];
    assign A_tmp[4] = ^A[4];
    assign A_tmp[5] = ^A[5];
    assign A_tmp[6] = ^A[6];
    assign A_tmp[7] = ^A[7];
    assign A_tmp[8] = ^A[8];
    assign A_tmp[9] = ^A[9];
    wire   [63:0] D_tmp;
    assign D_tmp[0] = ^D[0];
    assign D_tmp[1] = ^D[1];
    assign D_tmp[2] = ^D[2];
    assign D_tmp[3] = ^D[3];
    assign D_tmp[4] = ^D[4];
    assign D_tmp[5] = ^D[5];
    assign D_tmp[6] = ^D[6];
    assign D_tmp[7] = ^D[7];
    assign D_tmp[8] = ^D[8];
    assign D_tmp[9] = ^D[9];
    assign D_tmp[10] = ^D[10];
    assign D_tmp[11] = ^D[11];
    assign D_tmp[12] = ^D[12];
    assign D_tmp[13] = ^D[13];
    assign D_tmp[14] = ^D[14];
    assign D_tmp[15] = ^D[15];
    assign D_tmp[16] = ^D[16];
    assign D_tmp[17] = ^D[17];
    assign D_tmp[18] = ^D[18];
    assign D_tmp[19] = ^D[19];
    assign D_tmp[20] = ^D[20];
    assign D_tmp[21] = ^D[21];
    assign D_tmp[22] = ^D[22];
    assign D_tmp[23] = ^D[23];
    assign D_tmp[24] = ^D[24];
    assign D_tmp[25] = ^D[25];
    assign D_tmp[26] = ^D[26];
    assign D_tmp[27] = ^D[27];
    assign D_tmp[28] = ^D[28];
    assign D_tmp[29] = ^D[29];
    assign D_tmp[30] = ^D[30];
    assign D_tmp[31] = ^D[31];
    assign D_tmp[32] = ^D[32];
    assign D_tmp[33] = ^D[33];
    assign D_tmp[34] = ^D[34];
    assign D_tmp[35] = ^D[35];
    assign D_tmp[36] = ^D[36];
    assign D_tmp[37] = ^D[37];
    assign D_tmp[38] = ^D[38];
    assign D_tmp[39] = ^D[39];
    assign D_tmp[40] = ^D[40];
    assign D_tmp[41] = ^D[41];
    assign D_tmp[42] = ^D[42];
    assign D_tmp[43] = ^D[43];
    assign D_tmp[44] = ^D[44];
    assign D_tmp[45] = ^D[45];
    assign D_tmp[46] = ^D[46];
    assign D_tmp[47] = ^D[47];
    assign D_tmp[48] = ^D[48];
    assign D_tmp[49] = ^D[49];
    assign D_tmp[50] = ^D[50];
    assign D_tmp[51] = ^D[51];
    assign D_tmp[52] = ^D[52];
    assign D_tmp[53] = ^D[53];
    assign D_tmp[54] = ^D[54];
    assign D_tmp[55] = ^D[55];
    assign D_tmp[56] = ^D[56];
    assign D_tmp[57] = ^D[57];
    assign D_tmp[58] = ^D[58];
    assign D_tmp[59] = ^D[59];
    assign D_tmp[60] = ^D[60];
    assign D_tmp[61] = ^D[61];
    assign D_tmp[62] = ^D[62];
    assign D_tmp[63] = ^D[63];
    wire   [63:0] BWEN_tmp;
    assign BWEN_tmp[0] = ^BWEN[0];
    assign BWEN_tmp[1] = ^BWEN[1];
    assign BWEN_tmp[2] = ^BWEN[2];
    assign BWEN_tmp[3] = ^BWEN[3];
    assign BWEN_tmp[4] = ^BWEN[4];
    assign BWEN_tmp[5] = ^BWEN[5];
    assign BWEN_tmp[6] = ^BWEN[6];
    assign BWEN_tmp[7] = ^BWEN[7];
    assign BWEN_tmp[8] = ^BWEN[8];
    assign BWEN_tmp[9] = ^BWEN[9];
    assign BWEN_tmp[10] = ^BWEN[10];
    assign BWEN_tmp[11] = ^BWEN[11];
    assign BWEN_tmp[12] = ^BWEN[12];
    assign BWEN_tmp[13] = ^BWEN[13];
    assign BWEN_tmp[14] = ^BWEN[14];
    assign BWEN_tmp[15] = ^BWEN[15];
    assign BWEN_tmp[16] = ^BWEN[16];
    assign BWEN_tmp[17] = ^BWEN[17];
    assign BWEN_tmp[18] = ^BWEN[18];
    assign BWEN_tmp[19] = ^BWEN[19];
    assign BWEN_tmp[20] = ^BWEN[20];
    assign BWEN_tmp[21] = ^BWEN[21];
    assign BWEN_tmp[22] = ^BWEN[22];
    assign BWEN_tmp[23] = ^BWEN[23];
    assign BWEN_tmp[24] = ^BWEN[24];
    assign BWEN_tmp[25] = ^BWEN[25];
    assign BWEN_tmp[26] = ^BWEN[26];
    assign BWEN_tmp[27] = ^BWEN[27];
    assign BWEN_tmp[28] = ^BWEN[28];
    assign BWEN_tmp[29] = ^BWEN[29];
    assign BWEN_tmp[30] = ^BWEN[30];
    assign BWEN_tmp[31] = ^BWEN[31];
    assign BWEN_tmp[32] = ^BWEN[32];
    assign BWEN_tmp[33] = ^BWEN[33];
    assign BWEN_tmp[34] = ^BWEN[34];
    assign BWEN_tmp[35] = ^BWEN[35];
    assign BWEN_tmp[36] = ^BWEN[36];
    assign BWEN_tmp[37] = ^BWEN[37];
    assign BWEN_tmp[38] = ^BWEN[38];
    assign BWEN_tmp[39] = ^BWEN[39];
    assign BWEN_tmp[40] = ^BWEN[40];
    assign BWEN_tmp[41] = ^BWEN[41];
    assign BWEN_tmp[42] = ^BWEN[42];
    assign BWEN_tmp[43] = ^BWEN[43];
    assign BWEN_tmp[44] = ^BWEN[44];
    assign BWEN_tmp[45] = ^BWEN[45];
    assign BWEN_tmp[46] = ^BWEN[46];
    assign BWEN_tmp[47] = ^BWEN[47];
    assign BWEN_tmp[48] = ^BWEN[48];
    assign BWEN_tmp[49] = ^BWEN[49];
    assign BWEN_tmp[50] = ^BWEN[50];
    assign BWEN_tmp[51] = ^BWEN[51];
    assign BWEN_tmp[52] = ^BWEN[52];
    assign BWEN_tmp[53] = ^BWEN[53];
    assign BWEN_tmp[54] = ^BWEN[54];
    assign BWEN_tmp[55] = ^BWEN[55];
    assign BWEN_tmp[56] = ^BWEN[56];
    assign BWEN_tmp[57] = ^BWEN[57];
    assign BWEN_tmp[58] = ^BWEN[58];
    assign BWEN_tmp[59] = ^BWEN[59];
    assign BWEN_tmp[60] = ^BWEN[60];
    assign BWEN_tmp[61] = ^BWEN[61];
    assign BWEN_tmp[62] = ^BWEN[62];
    assign BWEN_tmp[63] = ^BWEN[63];

  specify
    specparam
      tckq_r = 1.0,
      tckq_f = 1.0,
      tckqh_r = 0.5,
      tckqh_f = 0.5,
      tcyc = 3.0,
      tckh = 1.0,
      tckl = 1.0,
      tcs_r = 0.2,
      tch_r = 0.2,
      tcs_f = 0.1,
      tch_f = 0.1,
      tws_r = 0.2,
      twh_r = 0.2,
      tws_f = 0.1,
      twh_f = 0.1,
      tas_r = 0.2,
      tah_r = 0.2,
      tas_f = 0.1,
      tah_f = 0.1,
      tds_r = 0.2,
      tdh_r = 0.2,
      tds_f = 0.1,
      tdh_f = 0.1,
      tslpq = 0.5,
      tslpqh = 0.001,
      tslpwkqh = 0.001,
      tsdq = 0.5,
      tsdqh = 0.001,
      tsdwkqh = 0.001,
      tslp2pudelay = 2,
      tslpwk2pudelay = 2,
      tsd2pudelay = 2,
      tsdwk2pudelay = 2,
      tslplh = 0.5,
      tslpx = 3.144699558,
      tslpwk = 0.5,
      txslp = 0.002,
      tsdlh = 0.5,
      tsdx = 3.144699558,
      tsdwk = 0.5,
      txsd = 0.002,
      tbws_r = 0.2,
      tbwh_r = 0.2,
      tbws_f = 0.1,
      tbwh_f = 0.1,
      ttests_r = 0.5,
      ttesth_r = 0.5,
      ttests_f = 0.5,
      ttesth_f = 0.5;

    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[0]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[1]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[2]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[3]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[4]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[5]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[6]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[7]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[8]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[9]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[10]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[11]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[12]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[13]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[14]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[15]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[16]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[17]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[18]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[19]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[20]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[21]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[22]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[23]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[24]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[25]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[26]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[27]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[28]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[29]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[30]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[31]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[32]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[33]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[34]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[35]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[36]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[37]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[38]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[39]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[40]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[41]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[42]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[43]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[44]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[45]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[46]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[47]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[48]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[49]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[50]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[51]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[52]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[53]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[54]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[55]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[56]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[57]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[58]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[59]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[60]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[61]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[62]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (NcenAwenANslpANsd)
      (posedge CLK => (Q[63]:1'bx)) = (tckq_r, tckq_f, tckqh_r, tckq_r, tckqh_f, tckq_f);
    if (Nsd)
      (posedge SLP => (Q[0]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[1]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[2]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[3]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[4]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[5]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[6]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[7]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[8]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[9]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[10]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[11]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[12]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[13]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[14]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[15]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[16]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[17]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[18]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[19]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[20]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[21]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[22]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[23]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[24]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[25]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[26]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[27]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[28]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[29]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[30]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[31]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[32]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[33]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[34]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[35]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[36]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[37]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[38]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[39]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[40]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[41]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[42]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[43]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[44]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[45]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[46]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[47]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[48]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[49]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[50]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[51]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[52]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[53]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[54]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[55]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[56]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[57]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[58]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[59]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[60]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[61]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[62]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (posedge SLP => (Q[63]:1'bx)) = (tslpq, tslpq, tslpqh, tslpq, tslpqh, tslpq);
    if (Nsd)
      (negedge SLP => (Q[0]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[1]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[2]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[3]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[4]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[5]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[6]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[7]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[8]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[9]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[10]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[11]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[12]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[13]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[14]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[15]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[16]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[17]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[18]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[19]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[20]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[21]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[22]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[23]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[24]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[25]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[26]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[27]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[28]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[29]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[30]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[31]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[32]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[33]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[34]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[35]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[36]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[37]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[38]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[39]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[40]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[41]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[42]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[43]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[44]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[45]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[46]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[47]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[48]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[49]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[50]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[51]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[52]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[53]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[54]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[55]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[56]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[57]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[58]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[59]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[60]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[61]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[62]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nsd)
      (negedge SLP => (Q[63]:1'bx)) = (tslpwkqh, tslpwkqh);
    if (Nslp)
      (posedge SD => (Q[0]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[1]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[2]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[3]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[4]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[5]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[6]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[7]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[8]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[9]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[10]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[11]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[12]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[13]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[14]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[15]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[16]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[17]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[18]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[19]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[20]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[21]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[22]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[23]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[24]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[25]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[26]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[27]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[28]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[29]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[30]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[31]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[32]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[33]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[34]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[35]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[36]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[37]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[38]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[39]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[40]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[41]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[42]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[43]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[44]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[45]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[46]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[47]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[48]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[49]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[50]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[51]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[52]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[53]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[54]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[55]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[56]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[57]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[58]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[59]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[60]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[61]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[62]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (posedge SD => (Q[63]:1'bx)) = (tsdq, tsdq, tsdqh, tsdq, tsdqh, tsdq);
    if (Nslp)
      (negedge SD => (Q[0]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[1]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[2]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[3]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[4]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[5]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[6]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[7]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[8]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[9]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[10]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[11]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[12]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[13]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[14]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[15]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[16]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[17]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[18]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[19]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[20]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[21]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[22]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[23]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[24]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[25]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[26]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[27]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[28]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[29]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[30]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[31]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[32]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[33]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[34]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[35]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[36]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[37]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[38]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[39]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[40]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[41]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[42]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[43]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[44]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[45]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[46]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[47]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[48]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[49]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[50]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[51]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[52]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[53]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[54]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[55]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[56]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[57]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[58]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[59]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[60]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[61]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[62]:1'bx)) = (tsdwkqh, tsdwkqh);
    if (Nslp)
      (negedge SD => (Q[63]:1'bx)) = (tsdwkqh, tsdwkqh);
    (SLP => (PUDLY_SLP:1'bx)) = (tslp2pudelay, tslpwk2pudelay);
    (SD => (PUDLY_SD:1'bx)) = (tsd2pudelay, tsdwk2pudelay);
    $period(posedge CLK &&& NcenANslpANsd, tcyc, CLK_peri_noti);
    $period(negedge CLK &&& NcenANslpANsd, tcyc, CLK_peri_noti);
    $width(posedge CLK &&& NcenANslpANsd, tckh, 0, CLK_h_noti);
    $width(negedge CLK &&& NcenANslpANsd, tckl, 0, CLK_l_noti);
    $setuphold(posedge CLK &&& NslpANsd, posedge CEN, tcs_r,tch_r, CEN_noti);
    $setuphold(posedge CLK &&& NslpANsd, negedge CEN, tcs_f,tch_f, CEN_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge WEN, tws_r,twh_r, WEN_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge WEN, tws_f,twh_f, WEN_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge A[0], tas_r,tah_r, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge A[0], tas_f,tah_f, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge A[1], tas_r,tah_r, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge A[1], tas_f,tah_f, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge A[2], tas_r,tah_r, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge A[2], tas_f,tah_f, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge A[3], tas_r,tah_r, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge A[3], tas_f,tah_f, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge A[4], tas_r,tah_r, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge A[4], tas_f,tah_f, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge A[5], tas_r,tah_r, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge A[5], tas_f,tah_f, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge A[6], tas_r,tah_r, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge A[6], tas_f,tah_f, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge A[7], tas_r,tah_r, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge A[7], tas_f,tah_f, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge A[8], tas_r,tah_r, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge A[8], tas_f,tah_f, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge A[9], tas_r,tah_r, A_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge A[9], tas_f,tah_f, A_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[0], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[0], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[1], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[1], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[2], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[2], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[3], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[3], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[4], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[4], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[5], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[5], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[6], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[6], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[7], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[7], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[8], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[8], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[9], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[9], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[10], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[10], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[11], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[11], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[12], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[12], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[13], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[13], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[14], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[14], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[15], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[15], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[16], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[16], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[17], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[17], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[18], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[18], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[19], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[19], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[20], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[20], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[21], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[21], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[22], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[22], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[23], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[23], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[24], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[24], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[25], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[25], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[26], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[26], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[27], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[27], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[28], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[28], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[29], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[29], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[30], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[30], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[31], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[31], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[32], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[32], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[33], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[33], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[34], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[34], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[35], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[35], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[36], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[36], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[37], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[37], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[38], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[38], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[39], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[39], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[40], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[40], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[41], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[41], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[42], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[42], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[43], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[43], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[44], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[44], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[45], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[45], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[46], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[46], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[47], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[47], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[48], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[48], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[49], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[49], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[50], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[50], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[51], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[51], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[52], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[52], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[53], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[53], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[54], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[54], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[55], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[55], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[56], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[56], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[57], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[57], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[58], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[58], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[59], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[59], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[60], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[60], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[61], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[61], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[62], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[62], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge D[63], tds_r,tdh_r, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge D[63], tds_f,tdh_f, D_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[0], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[0], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[1], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[1], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[2], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[2], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[3], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[3], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[4], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[4], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[5], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[5], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[6], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[6], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[7], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[7], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[8], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[8], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[9], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[9], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[10], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[10], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[11], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[11], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[12], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[12], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[13], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[13], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[14], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[14], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[15], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[15], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[16], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[16], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[17], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[17], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[18], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[18], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[19], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[19], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[20], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[20], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[21], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[21], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[22], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[22], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[23], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[23], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[24], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[24], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[25], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[25], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[26], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[26], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[27], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[27], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[28], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[28], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[29], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[29], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[30], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[30], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[31], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[31], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[32], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[32], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[33], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[33], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[34], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[34], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[35], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[35], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[36], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[36], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[37], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[37], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[38], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[38], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[39], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[39], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[40], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[40], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[41], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[41], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[42], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[42], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[43], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[43], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[44], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[44], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[45], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[45], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[46], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[46], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[47], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[47], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[48], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[48], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[49], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[49], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[50], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[50], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[51], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[51], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[52], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[52], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[53], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[53], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[54], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[54], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[55], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[55], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[56], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[56], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[57], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[57], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[58], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[58], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[59], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[59], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[60], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[60], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[61], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[61], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[62], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[62], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, posedge BWEN[63], tbws_r,tbwh_r, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANwenANslpANsd, negedge BWEN[63], tbws_f,tbwh_f, BWEN_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge RT[0], ttests_r,ttesth_r, RT_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge RT[0], ttests_f,ttesth_f, RT_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge RT[1], ttests_r,ttesth_r, RT_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge RT[1], ttests_f,ttesth_f, RT_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge WT[0], ttests_r,ttesth_r, WT_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge WT[0], ttests_f,ttesth_f, WT_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge WT[1], ttests_r,ttesth_r, WT_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge WT[1], ttests_f,ttesth_f, WT_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, posedge TM, ttests_r,ttesth_r, TM_noti);
    $setuphold(posedge CLK &&& NcenANslpANsd, negedge TM, ttests_f,ttesth_f, TM_noti);
    $removal(posedge SLP, posedge CLK &&& Nsd, tslplh, SLP_noti);
    $hold(posedge SLP &&& Nsd, posedge CLK, tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, negedge CLK, tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] CLK_tmp, tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] CEN_tmp, tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] WEN_tmp, tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] A_tmp[0], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] A_tmp[1], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] A_tmp[2], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] A_tmp[3], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] A_tmp[4], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] A_tmp[5], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] A_tmp[6], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] A_tmp[7], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] A_tmp[8], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] A_tmp[9], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[0], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[1], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[2], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[3], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[4], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[5], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[6], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[7], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[8], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[9], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[10], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[11], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[12], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[13], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[14], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[15], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[16], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[17], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[18], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[19], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[20], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[21], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[22], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[23], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[24], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[25], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[26], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[27], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[28], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[29], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[30], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[31], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[32], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[33], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[34], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[35], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[36], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[37], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[38], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[39], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[40], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[41], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[42], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[43], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[44], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[45], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[46], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[47], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[48], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[49], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[50], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[51], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[52], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[53], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[54], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[55], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[56], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[57], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[58], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[59], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[60], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[61], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[62], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] D_tmp[63], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[0], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[1], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[2], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[3], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[4], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[5], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[6], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[7], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[8], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[9], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[10], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[11], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[12], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[13], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[14], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[15], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[16], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[17], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[18], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[19], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[20], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[21], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[22], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[23], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[24], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[25], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[26], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[27], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[28], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[29], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[30], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[31], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[32], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[33], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[34], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[35], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[36], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[37], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[38], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[39], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[40], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[41], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[42], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[43], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[44], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[45], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[46], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[47], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[48], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[49], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[50], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[51], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[52], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[53], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[54], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[55], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[56], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[57], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[58], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[59], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[60], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[61], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[62], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, edge [0x, 1x] BWEN_tmp[63], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, posedge RT[0], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, negedge RT[0], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, posedge RT[1], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, negedge RT[1], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, posedge WT[0], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, negedge WT[0], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, posedge WT[1], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, negedge WT[1], tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, posedge TM, tslpx, SLP_noti);
    $hold(posedge SLP &&& Nsd, negedge TM, tslpx, SLP_noti);
    $recovery(negedge SLP, posedge CLK &&& Nsd, tslpwk, SLP_noti);
    $hold(posedge CLK &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(negedge CLK &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] CLK_tmp &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] CEN_tmp &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] WEN_tmp &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] A_tmp[0] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] A_tmp[1] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] A_tmp[2] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] A_tmp[3] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] A_tmp[4] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] A_tmp[5] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] A_tmp[6] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] A_tmp[7] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] A_tmp[8] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] A_tmp[9] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[0] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[1] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[2] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[3] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[4] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[5] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[6] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[7] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[8] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[9] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[10] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[11] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[12] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[13] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[14] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[15] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[16] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[17] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[18] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[19] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[20] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[21] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[22] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[23] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[24] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[25] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[26] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[27] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[28] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[29] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[30] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[31] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[32] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[33] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[34] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[35] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[36] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[37] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[38] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[39] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[40] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[41] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[42] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[43] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[44] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[45] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[46] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[47] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[48] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[49] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[50] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[51] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[52] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[53] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[54] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[55] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[56] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[57] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[58] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[59] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[60] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[61] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[62] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] D_tmp[63] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[0] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[1] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[2] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[3] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[4] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[5] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[6] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[7] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[8] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[9] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[10] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[11] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[12] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[13] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[14] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[15] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[16] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[17] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[18] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[19] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[20] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[21] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[22] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[23] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[24] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[25] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[26] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[27] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[28] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[29] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[30] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[31] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[32] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[33] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[34] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[35] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[36] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[37] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[38] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[39] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[40] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[41] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[42] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[43] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[44] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[45] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[46] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[47] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[48] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[49] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[50] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[51] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[52] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[53] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[54] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[55] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[56] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[57] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[58] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[59] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[60] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[61] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[62] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(edge [x0, x1] BWEN_tmp[63] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(posedge RT[0] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(negedge RT[0] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(posedge RT[1] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(negedge RT[1] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(posedge WT[0] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(negedge WT[0] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(posedge WT[1] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(negedge WT[1] &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(posedge TM &&& Nsd, negedge SLP, txslp, SLP_noti);
    $hold(negedge TM &&& Nsd, negedge SLP, txslp, SLP_noti);
    $removal(posedge SD, posedge CLK &&& Nslp, tsdlh, SD_noti);
    $hold(posedge SD &&& Nslp, posedge SLP, tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, posedge CLK, tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, negedge CLK, tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] CLK_tmp, tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] CEN_tmp, tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] WEN_tmp, tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] A_tmp[0], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] A_tmp[1], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] A_tmp[2], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] A_tmp[3], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] A_tmp[4], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] A_tmp[5], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] A_tmp[6], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] A_tmp[7], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] A_tmp[8], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] A_tmp[9], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[0], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[1], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[2], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[3], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[4], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[5], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[6], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[7], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[8], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[9], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[10], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[11], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[12], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[13], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[14], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[15], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[16], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[17], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[18], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[19], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[20], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[21], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[22], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[23], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[24], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[25], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[26], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[27], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[28], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[29], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[30], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[31], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[32], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[33], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[34], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[35], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[36], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[37], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[38], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[39], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[40], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[41], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[42], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[43], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[44], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[45], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[46], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[47], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[48], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[49], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[50], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[51], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[52], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[53], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[54], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[55], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[56], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[57], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[58], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[59], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[60], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[61], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[62], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] D_tmp[63], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[0], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[1], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[2], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[3], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[4], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[5], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[6], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[7], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[8], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[9], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[10], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[11], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[12], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[13], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[14], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[15], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[16], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[17], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[18], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[19], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[20], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[21], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[22], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[23], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[24], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[25], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[26], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[27], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[28], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[29], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[30], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[31], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[32], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[33], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[34], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[35], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[36], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[37], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[38], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[39], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[40], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[41], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[42], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[43], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[44], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[45], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[46], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[47], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[48], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[49], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[50], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[51], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[52], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[53], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[54], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[55], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[56], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[57], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[58], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[59], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[60], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[61], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[62], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, edge [0x, 1x] BWEN_tmp[63], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, posedge RT[0], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, negedge RT[0], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, posedge RT[1], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, negedge RT[1], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, posedge WT[0], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, negedge WT[0], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, posedge WT[1], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, negedge WT[1], tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, posedge TM, tsdx, SD_noti);
    $hold(posedge SD &&& Nslp, negedge TM, tsdx, SD_noti);
    $recovery(negedge SD, posedge CLK &&& Nslp, tsdwk, SD_noti);
    $setup(negedge SLP, negedge SD, txsd, SD_noti);
    $hold(posedge CLK, negedge SD &&& Nslp, txsd, SD_noti);
    $hold(negedge CLK, negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] CLK_tmp, negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] CEN_tmp, negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] WEN_tmp, negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] A_tmp[0], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] A_tmp[1], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] A_tmp[2], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] A_tmp[3], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] A_tmp[4], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] A_tmp[5], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] A_tmp[6], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] A_tmp[7], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] A_tmp[8], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] A_tmp[9], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[0], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[1], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[2], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[3], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[4], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[5], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[6], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[7], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[8], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[9], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[10], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[11], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[12], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[13], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[14], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[15], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[16], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[17], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[18], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[19], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[20], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[21], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[22], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[23], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[24], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[25], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[26], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[27], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[28], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[29], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[30], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[31], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[32], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[33], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[34], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[35], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[36], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[37], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[38], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[39], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[40], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[41], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[42], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[43], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[44], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[45], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[46], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[47], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[48], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[49], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[50], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[51], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[52], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[53], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[54], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[55], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[56], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[57], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[58], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[59], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[60], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[61], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[62], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] D_tmp[63], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[0], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[1], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[2], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[3], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[4], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[5], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[6], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[7], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[8], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[9], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[10], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[11], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[12], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[13], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[14], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[15], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[16], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[17], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[18], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[19], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[20], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[21], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[22], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[23], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[24], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[25], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[26], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[27], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[28], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[29], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[30], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[31], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[32], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[33], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[34], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[35], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[36], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[37], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[38], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[39], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[40], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[41], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[42], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[43], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[44], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[45], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[46], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[47], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[48], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[49], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[50], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[51], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[52], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[53], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[54], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[55], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[56], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[57], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[58], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[59], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[60], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[61], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[62], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(edge [x0, x1] BWEN_tmp[63], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(posedge RT[0], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(negedge RT[0], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(posedge RT[1], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(negedge RT[1], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(posedge WT[0], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(negedge WT[0], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(posedge WT[1], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(negedge WT[1], negedge SD &&& Nslp, txsd, SD_noti);
    $hold(posedge TM, negedge SD &&& Nslp, txsd, SD_noti);
    $hold(negedge TM, negedge SD &&& Nslp, txsd, SD_noti);
  endspecify
`endif
endmodule
`endcelldefine
