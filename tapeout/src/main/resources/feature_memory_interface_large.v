// `include "../gen-collateral/defines.v"
`include "../gen-collateral/defines.v"

module feature_memory_interface_large(
        input clk,
        input rstn,

        input                                 fml_load_en,
        input  [$clog2(`FM_DEPTH_L)-1:0]      fml_load_addr,
        output [`FM_WIDTH-1:0]                fml_load_data,

        input                                 fml_store_en,
        input [$clog2(`FM_DEPTH_L)-1:0]       fml_store_addr,
        input [`FM_WIDTH-1:0]                 fml_store_data,

        input                                 fml_npu_load_en,
        input  [$clog2(`FM_Bank_DEPTH_L)-1:0] fml_npu_load_addr,
        output [`FM_WIDTH *`FM_Bank_NUM_L -1:0] fml_npu_load_data

    );

    localparam BANK_SEL_W  = $clog2(`FM_Bank_NUM_L);
    localparam LOCAL_ADDR_W  = $clog2(`FM_Bank_DEPTH_L);
    localparam ADDR_WIDTH  = $clog2(`FM_DEPTH_L);

    wire [BANK_SEL_W-1:0] bank_idx;
    wire [LOCAL_ADDR_W-1:0] local_addr;

    // assign bank_idx  = fm_store_en ? fm_store_addr[ADDR_WIDTH-1 -: BANK_SEL_W] :
    //                    fm_load_en  ? fm_load_addr[ADDR_WIDTH-1 -: BANK_SEL_W]  : 'd0;
    assign bank_idx  =  fml_store_en ? fml_store_addr[0 +: BANK_SEL_W] :
           				fml_load_en  ? fml_load_addr[0 +: BANK_SEL_W]  : 'd0;

    // assign local_addr =fm_npu_load_en ? fm_npu_load_addr :
    //                    fm_store_en ? fm_store_addr[LOCAL_ADDR_W-1:0]  :
    //                    fm_load_en  ? fm_load_addr[LOCAL_ADDR_W-1:0]   : 'd0;
    assign local_addr = fml_npu_load_en ? fml_npu_load_addr :
           				fml_store_en ? fml_store_addr[LOCAL_ADDR_W-1 -:LOCAL_ADDR_W]  :
           				fml_load_en  ? fml_load_addr[LOCAL_ADDR_W-1 -:LOCAL_ADDR_W]   : 'd0;

    wire [`FM_Bank_NUM_L-1:0] cen;
    wire [`FM_Bank_NUM_L-1:0] wen;
    wire [`FM_Bank_NUM_L *`FM_WIDTH-1:0] din;
    wire [`FM_Bank_NUM_L *`FM_WIDTH-1:0] dout;


    genvar i;
    generate
        for (i = 0; i < `FM_Bank_NUM_L; i = i + 1) begin : BANK
            // assign cen[i] = ((bank_idx == i) && (fm_store_en || fm_load_en)) || fm_npu_load_en;
			assign cen[i] = ((bank_idx == i) && (fml_store_en)) || fml_load_en || fml_npu_load_en;
            assign wen[i] = (bank_idx == i) && fml_store_en && !fml_npu_load_en;
            assign din[i *`FM_WIDTH +: `FM_WIDTH] = wen[i] ? fml_store_data : 'd0;

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

    assign fml_load_data = fml_load_en ? dout[bank_idx *`FM_WIDTH +: `FM_WIDTH] : 'd0;
    assign fml_npu_load_data = fml_npu_load_en ? dout : 'd0;
endmodule
