module ciml_mac //cimd_macro
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

parameter ROW_NUM = 256;
parameter GROUP_ROW_NUM = 32;   //ONE GOURP is 32 rows
parameter GROUP_NUM = 8;        //GROUP_NUM * GROUP_ROW_NUM = ROW_NUM

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

//output      [MAC_W*COL_GROUP_NUM-1:0]     MAC;                // CIM result
//output                                    SRDY;           	// CIM result ready

input                                       SE;
input                                       NNIN_SI;
input                                       PSUM_SI;

output										NNIN_SO;
output										PSUM_SO;

output   	[PSUM_W*2*COL_GROUP_NUM-1:0]    PSUM;
output      [COL_NUM-1:0]                   Q;                  // read out data


reg     [COL_NUM-1 : 0]                 mem0[0 : ROW_NUM-1];
reg     [COL_NUM-1 : 0]                 mem1[0 : ROW_NUM-1];

reg     [PSUM_W-1 : 0]                  psum_h[0 : COL_GROUP_NUM-1];
reg     [PSUM_W-1 : 0]                  psum_l[0 : COL_GROUP_NUM-1];
reg     [PSUM_GROUP_W*GROUP_NUM-1 :0]   psum_h_g[0 : COL_GROUP_NUM-1];  
reg     [PSUM_GROUP_W*GROUP_NUM-1 :0]   psum_l_g[0 : COL_GROUP_NUM-1];  

wire    [4*ROW_NUM-1:0]                 weight_h[0 : COL_GROUP_NUM-1];
wire    [4*ROW_NUM-1:0]                 weight_l[0 : COL_GROUP_NUM-1];

wire                                    buffer_valid;
reg                                     buffer_valid_d1;
reg                                     CIMADR_MSB_d1;
wire                                    CIMADR_MSB;

reg                                     buffer_valid_reset;

wire     clk_cim_gated;
wire     clk_w_gated;

reg     [COL_NUM : 0]                   new_1_mem0[0 : ROW_NUM-1];
reg     [COL_NUM : 0]                   new_1_mem1[0 : ROW_NUM-1];
reg     [COL_NUM-1 : 0]                 new_2_mem0[0 : ROW_NUM-1];
reg     [COL_NUM-1 : 0]                 new_2_mem1[0 : ROW_NUM-1];
reg     [COL_NUM-1 : 0]                 q_temp;

integer lzc;
initial begin
	for (lzc=0;lzc<ROW_NUM;lzc=lzc+1) begin
		mem0[lzc] = -1;
		mem1[lzc] = 0;
	end
end

assign Q = q_temp;

always @(posedge CLK_CIM or negedge RSTN)        
    if(!RSTN)
        buffer_valid_reset <= 1'b0;
    else if (!MEB)
        buffer_valid_reset <= 1'b1;


reg RE;
always @(*)
    if (!CLK_CIM)
        RE = ~MEB;
assign clk_cim_gated = CLK_CIM & RE;

reg wen;
always @(*)
    if (!CLK_W)
        wen = ~WEB;
assign clk_w_gated = CLK_W & wen;

always @(posedge clk_w_gated)
    if (!WEB && !SCAN_MODE && !REN) begin
      if (WADR[$clog2(ROW_NUM)]) 
          mem1[WADR[$clog2(ROW_NUM)-1 : 0]] <= WD;
      else 
          mem0[WADR[$clog2(ROW_NUM)-1 : 0]] <= WD;
    end

//column repair write
always @(posedge clk_w_gated)
  if (!WEB && !SCAN_MODE && REN && (RA < COL_NUM)) begin
    if (RA > 0) begin
      if (WADR[$clog2(ROW_NUM)])
        new_1_mem1[WADR[$clog2(ROW_NUM)-1 : 0]][0] <= WD[0];
      else 
        new_1_mem0[WADR[$clog2(ROW_NUM)-1 : 0]][0] <= WD[0];
    end
  end

genvar a;

generate
for (a=1; a<COL_NUM; a=a+1) begin
always @(posedge clk_w_gated)
  if (!WEB && !SCAN_MODE && REN && (RA < COL_NUM)) begin
    if (RA > a) begin
      if (WADR[$clog2(ROW_NUM)])
          new_1_mem1[WADR[$clog2(ROW_NUM)-1 : 0]][a] <= WD[a];
      else 
          new_1_mem0[WADR[$clog2(ROW_NUM)-1 : 0]][a] <= WD[a];
    end
    else begin
      if (WADR[$clog2(ROW_NUM)])
          new_1_mem1[WADR[$clog2(ROW_NUM)-1 : 0]][a] <= WD[a-1];
      else 
          new_1_mem0[WADR[$clog2(ROW_NUM)-1 : 0]][a] <= WD[a-1];
    end
  end
end
endgenerate

always @(posedge clk_w_gated)
  if (!WEB && !SCAN_MODE && REN && (RA < COL_NUM)) begin
    if (WADR[$clog2(ROW_NUM)])
      new_1_mem1[WADR[$clog2(ROW_NUM)-1 : 0]][COL_NUM] <= WD[COL_NUM-1];
    else 
      new_1_mem0[WADR[$clog2(ROW_NUM)-1 : 0]][COL_NUM] <= WD[COL_NUM-1];
  end

genvar b;

generate
for (b=0; b<ROW_NUM; b=b+1) begin
always @(*)
  if (REN == 1'b1) begin
    if (RA > 0) begin
      new_2_mem1[b][0] = new_1_mem1[b][0];
      new_2_mem0[b][0] = new_1_mem0[b][0];
    end
  end
end
endgenerate

genvar c, d;

generate
for (c=0; c<ROW_NUM; c=c+1) begin
for (d=1; d<COL_NUM; d=d+1) begin
always @(*)
  if (REN == 1'b1) begin
    if (RA > d) begin
      new_2_mem1[c][d] = new_1_mem1[c][d];
      new_2_mem0[c][d] = new_1_mem0[c][d];
    end
    else if (RA < d) begin
      new_2_mem1[c][d-1] = new_1_mem1[c][d];
      new_2_mem0[c][d-1] = new_1_mem0[c][d];
    end
  end
end
end
endgenerate

genvar e;

generate
for (e=0; e<ROW_NUM; e=e+1) begin
always @(*) begin
  if (REN == 1'b1) begin
    new_2_mem1[e][COL_NUM-1] = new_1_mem1[e][COL_NUM];
    new_2_mem0[e][COL_NUM-1] = new_1_mem0[e][COL_NUM];
  end
end
end
endgenerate

//column repair write end

always @(posedge clk_cim_gated)
  if (!MEB && BIST_MODE && !SCAN_MODE && !REN) begin
    if (CIMADR[$clog2(ROW_NUM)]) 
        q_temp <= mem1[CIMADR[$clog2(ROW_NUM)-1 : 0]];
    else 
        q_temp <= mem0[CIMADR[$clog2(ROW_NUM)-1 : 0]];
  end

//column repair read
always @(posedge clk_cim_gated)
  if (!MEB && BIST_MODE && !SCAN_MODE && REN) begin
    if (CIMADR[$clog2(ROW_NUM)]) 
      q_temp <= new_2_mem1[CIMADR[$clog2(ROW_NUM)-1 : 0]];
    else 
      q_temp <= new_2_mem0[CIMADR[$clog2(ROW_NUM)-1 : 0]];
  end
//column repair read end

assign CIMADR_MSB = CIMADR[$clog2(ROW_NUM)];
always @(posedge clk_cim_gated)
    if (!MEB && !SCAN_MODE && !BIST_MODE)
        CIMADR_MSB_d1 <= CIMADR_MSB;

assign  buffer_valid =  (CIMADR_MSB_d1 == CIMADR_MSB) & buffer_valid_reset;

always @(posedge clk_cim_gated)
    if (!MEB && !SCAN_MODE && !BIST_MODE)
        buffer_valid_d1 <= buffer_valid;

genvar i, j, k;
generate
    for (k=0; k<COL_GROUP_NUM; k=k+1) begin : col_group
        for (j=0; j< ROW_NUM; j=j+1) begin: weight_hl
              assign weight_h[k][4*(j+1)-1 -: 4] = REN ? (CIMADR_MSB ? new_2_mem1[j][(k+1)*WEIGHT_W-1 -: 4] : new_2_mem0[j][(k+1)*WEIGHT_W-1 -: 4]) : (CIMADR_MSB ? mem1[j][(k+1)*WEIGHT_W-1 -: 4] : mem0[j][(k+1)*WEIGHT_W-1 -: 4]);
              assign weight_l[k][4*(j+1)-1 -: 4] = REN ? (CIMADR_MSB ? new_2_mem1[j][(k+1)*WEIGHT_W-4-1 -: 4] : new_2_mem0[j][(k+1)*WEIGHT_W-4-1 -: 4]) : (CIMADR_MSB ? mem1[j][(k+1)*WEIGHT_W-4-1 -: 4] : mem0[j][(k+1)*WEIGHT_W-4-1 -: 4]);
        end

        for (i=0; i<GROUP_NUM; i=i+1) begin: psum_g
            always @(posedge clk_cim_gated) 
                if (!MEB && buffer_valid && !SCAN_MODE && !BIST_MODE) begin
                    psum_l_g[k][(i+1)*PSUM_GROUP_W-1 -: PSUM_GROUP_W] <= (CIMADR[i]) ? 
                        sum64_u(NNIN[(i+1)*GROUP_ROW_NUM-1 -: GROUP_ROW_NUM], weight_l[k][4*GROUP_ROW_NUM*(i+1)-1 -: 4*GROUP_ROW_NUM]) : 0;
                    psum_h_g[k][(i+1)*PSUM_GROUP_W-1 -: PSUM_GROUP_W] <= (CIMADR[i]) ? 
                        sum64_s(NNIN[(i+1)*GROUP_ROW_NUM-1 -: GROUP_ROW_NUM], weight_h[k][4*GROUP_ROW_NUM*(i+1)-1 -: 4*GROUP_ROW_NUM]) : 0;
                end
        end

        always @(posedge clk_cim_gated) 
            if (!MEB && buffer_valid_d1 && !SCAN_MODE && !BIST_MODE) begin
                psum_h[k] <= sumn_s(psum_h_g[k]);
                psum_l[k] <= sumn_u(psum_l_g[k]);
            end

        assign PSUM[(k+1)*2*PSUM_W-1 -: PSUM_W] = psum_h[k];
        assign PSUM[(k+1)*2*PSUM_W-1 - PSUM_W -: PSUM_W] = psum_l[k];
        
        
        //ciml_accu #(.ROW_NUM(ROW_NUM),.PSUM_W(PSUM_W),.MAC_W(MAC_W)) u_ciml_accu(
        //    .CLK            (CLK_CIM),
        //    .RSTN           (RSTN),
        //    .MEB            (MEB),
        //    .SIGN_MODE      (SIGN_MODE),
        //    .CIMADR_MSB     (CIMADR_MSB),
        //    .PSUM1          (psum_h[k]),                    // partial sum of 4 msb
        //    .PSUM2          (psum_l[k]),                    // partial sum of 4 lsb
        //    .MAC_RES        (MAC[(k+1)*MAC_W-1 -: MAC_W]),  // result
        //    .SRDY           (srdy_tmp[k])                   // output ready signal 
        //);
    end
endgenerate

function [PSUM_GROUP_W-1:0] sum64_u;
	input [1*GROUP_ROW_NUM-1:0]    data;
    input [4*GROUP_ROW_NUM-1:0]    weight;
    integer i;
begin
    sum64_u = 0;
    for (i=0; i<GROUP_ROW_NUM; i=i+1)
        sum64_u = sum64_u + (data[i] ? weight[(i+1)*4-1 -: 4] : 4'd0);
end
endfunction

function signed [PSUM_GROUP_W-1:0] sum64_s;
	input           [1*GROUP_ROW_NUM-1:0]  data;
    input           [4*GROUP_ROW_NUM-1:0]  weight;
    integer i;
begin
    sum64_s = 0;
    for (i=0; i<GROUP_ROW_NUM; i=i+1)
        sum64_s = sum64_s + (data[i] ? $signed({{$clog2(GROUP_ROW_NUM){weight[(i+1)*4-1]}}, weight[(i+1)*4-1 -: 4]}) : {PSUM_GROUP_W{1'b0}});
end
endfunction

function signed [PSUM_W-1:0] sumn_s;
    input signed [PSUM_GROUP_W*GROUP_NUM-1:0] data;
    integer i;
begin   
    sumn_s = 0;
    for (i=0; i<GROUP_NUM; i=i+1)
        sumn_s = sumn_s + $signed(data[(i+1)*PSUM_GROUP_W-1 -: PSUM_GROUP_W]);
end
endfunction

function [PSUM_W-1:0] sumn_u;
    input [PSUM_GROUP_W*GROUP_NUM-1:0] data;
    integer i;
begin   
    sumn_u = 0;
    for (i=0; i<GROUP_NUM; i=i+1)
        sumn_u = sumn_u + data[(i+1)*PSUM_GROUP_W-1 -: PSUM_GROUP_W];
end
endfunction


endmodule
