module CIML2P_64X64_DR_M2_A1 //ciml_macro
(
    CLK_CIM,
    CLK_W,
    RSTN,
    MEB,                // macro enable, active low

    WEB,                // write enable, active low
    WADR,               // memory write addr, MSB is buffer index
    CIMADR,             // CIM Index, MSB is buffer index
    NNIN,               // CIM mode: input data

    WD,                // MEM mode: write data
    
    REN,                // repair enable
    RA,                 // repair address
    
    DM,                 
    
    BIST_MODE,
    SCAN_MODE,

    SE,
    NNIN_SI,
    PSUM_SI,
    
    NNIN_SO,
    PSUM_SO,
    PSUM,
    Q                   // read out data
);

parameter ROW_NUM = 32;
parameter GROUP_ROW_NUM = 32;   //ONE GOURP is 32 rows
parameter GROUP_NUM = 1;        //GROUP_NUM * GROUP_ROW_NUM = ROW_NUM

parameter  COL_NUM = 64;
parameter  COL_GROUP_NUM = 8;   //8 column group
parameter  WEIGHT_W = 8;        //WEIGHT_W * COL_GROUP_NUM = COL_NUM

localparam PSUM_W = 4 + $clog2(ROW_NUM);
localparam MAC_W = 16 + $clog2(ROW_NUM);
localparam PSUM_GROUP_W = 4+$clog2(GROUP_ROW_NUM);

input                                       CLK_CIM;
input                                       CLK_W;
input                                       RSTN;
input                                       MEB;                // macro enable, active low
input                                       WEB;                // write enable, active low
input       [$clog2(ROW_NUM):0]             WADR;               // memory write addr, MSB is buffer index
input       [$clog2(ROW_NUM):0]             CIMADR;             // memory write addr, MSB is buffer index
input       [ROW_NUM-1:0]                   NNIN;               // IM mode: input data
input       [COL_NUM-1:0]                   WD;                // MEM mode: write data

input                                       REN;                // repair enable
input       [$clog2(COL_NUM)-1:0]           RA;                 // repair address

input       [5:0]                           DM;                 

input                                       BIST_MODE;
input                                       SCAN_MODE;

input                                       SE;
input                                       NNIN_SI;
input                                       PSUM_SI;

output                                      NNIN_SO;
output                                      PSUM_SO;

output      [PSUM_W*2*COL_GROUP_NUM-1:0]    PSUM;
output      [COL_NUM-1:0]                   Q;                  // read out data


ciml_mac #(.ROW_NUM(ROW_NUM), .GROUP_ROW_NUM(GROUP_ROW_NUM), .GROUP_NUM(GROUP_NUM), 
            .COL_NUM(COL_NUM), .COL_GROUP_NUM(COL_GROUP_NUM), .WEIGHT_W(WEIGHT_W)) 
u_ciml_mac(
    .CLK_CIM        (CLK_CIM),
    .CLK_W          (CLK_W), 
    .RSTN           (RSTN),
    .MEB            (MEB),                // macro enable, active low
    .WEB            (WEB),                // write enable, active low
    .WADR           (WADR),               // memory write addr, MSB is buffer index
    .CIMADR         (CIMADR),             // CIM Index, MSB is buffer index
    .NNIN           (NNIN),               // CIM mode: input data
    .WD             (WD),                // MEM mode: write data
    
    .REN            (REN),                // repair enable
    .RA             (RA),                 // repair address
    
    .DM             (DM),                 
    
    .BIST_MODE      (BIST_MODE),
    .SCAN_MODE      (SCAN_MODE),
    
    .SE             (SE),
    .NNIN_SI        (NNIN_SI),
    .PSUM_SI        (PSUM_SI),
    
    .NNIN_SO        (NNIN_SO),
    .PSUM_SO        (PSUM_SO),

    .PSUM           (PSUM),
    .Q              (Q)
);

endmodule
