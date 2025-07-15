`include "../gen-collateral/defines.v"

module feature_memory_interface(
    input clk,
    input rstn,

    input                                 fm_load_en, 
    input  [$clog2(`FM_DEPTH)-1:0]        fm_load_addr,
    output [`FM_WIDTH-1:0]                fm_load_data,
    
    input                                 fm_store_en,
    input [$clog2(`FM_DEPTH)-1:0]         fm_store_addr,
    input [`FM_WIDTH-1:0]                 fm_store_data,

    input                                 fm_npu_load_en, 
    input  [$clog2(`FM_Bank_DEPTH)-1:0]   fm_npu_load_addr,
    output [`FM_WIDTH *`FM_Bank_NUM -1:0] fm_npu_load_data   

);

localparam BANK_SEL_W  = $clog2(`FM_Bank_NUM);
localparam LOCAL_ADDR_W  = $clog2(`FM_Bank_DEPTH);
localparam ADDR_WIDTH  = $clog2(`FM_DEPTH);

wire [BANK_SEL_W-1:0] bank_idx;     
wire [LOCAL_ADDR_W-1:0] local_addr;  

assign bank_idx  = fm_store_en ? fm_store_addr[ADDR_WIDTH-1 -: BANK_SEL_W] :
                   fm_load_en  ? fm_load_addr[ADDR_WIDTH-1 -: BANK_SEL_W]  : 'd0;


assign local_addr =fm_npu_load_en ? fm_npu_load_addr :
                   fm_store_en ? fm_store_addr[LOCAL_ADDR_W-1:0]  :
                   fm_load_en  ? fm_load_addr[LOCAL_ADDR_W-1:0]   : 'd0;

wire [`FM_Bank_NUM-1:0] cen;
wire [`FM_Bank_NUM-1:0] wen;
wire [`FM_Bank_NUM *`FM_WIDTH-1:0] din;
wire [`FM_Bank_NUM *`FM_WIDTH-1:0] dout;


genvar i;
generate
    for (i = 0; i < `FM_Bank_NUM; i = i + 1) begin : BANK
        assign cen[i] = ((bank_idx == i) && (fm_store_en || fm_load_en)) || fm_npu_load_en;
        assign wen[i] = (bank_idx == i) && fm_store_en && !fm_npu_load_en;
        assign din[i *`FM_WIDTH +: `FM_WIDTH] = wen[i] ? fm_store_data : 'd0;

        smic281prf64x64m4  
        smic281prf64x64m4_inst (
            .CLK(clk),  
            .CEN(!cen[i]),
            .WEN(!wen[i]),
            .A(local_addr),
            .D(din[i *`FM_WIDTH +: `FM_WIDTH]),
            .Q(dout[i *`FM_WIDTH +: `FM_WIDTH]),
            .BWEN('d0),
            .SD(1'b0),
            .SLP(1'b0),
            .PUDLY_SD(),
            .PUDLY_SLP(),
            .RT(2'b00),
            .WT(2'b00),
            .TM(1'b0)
        );
    end
endgenerate

assign fm_load_data = fm_load_en ? dout[bank_idx *`FM_WIDTH +: `FM_WIDTH] : 'd0;
assign fm_npu_load_data = fm_npu_load_en ? dout : 'd0;   
endmodule
