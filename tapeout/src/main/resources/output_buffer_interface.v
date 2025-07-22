`include "defines.v"
// `include "../0-RTL/AXI_SLAVE/defines.v"

module output_buffer_interface(
        input clk,
        input rstn,

        input                                    ob_load_en,
        input  [$clog2(`OB_DEPTH)-1:0]           ob_load_addr,
        output [`OB_WIDTH-1:0]                   ob_load_data,

        input                                    ob_store_en,
        input  [$clog2(`OB_DEPTH)-1:0]           ob_store_addr,
        input [`OB_WIDTH-1:0]                    ob_store_data,

        input                                    ob_npu_store_en,
        input  [$clog2(`OB_Bank_DEPTH)-1:0]          ob_npu_store_addr,
        input [`OB_WIDTH *`OB_Bank_NUM -1:0]     ob_npu_store_data

    );

    localparam BANK_SEL_W  = $clog2(`OB_Bank_NUM);
    localparam LOCAL_ADDR_W  = $clog2(`OB_Bank_DEPTH);
    localparam ADDR_WIDTH  = $clog2(`OB_DEPTH);

    wire [BANK_SEL_W-1:0] bank_idx;
    wire [LOCAL_ADDR_W-1:0] local_addr;

    assign bank_idx =   ob_store_en ? ob_store_addr[ADDR_WIDTH-1 -: BANK_SEL_W] :
           ob_load_en  ? ob_load_addr[ADDR_WIDTH-1 -: BANK_SEL_W]  : 'd0;


    assign local_addr = ob_npu_store_en ? ob_npu_store_addr :
           ob_store_en     ? ob_store_addr[LOCAL_ADDR_W-1:0] :
           ob_load_en      ? ob_load_addr[LOCAL_ADDR_W-1:0]            : 'd0;

    wire [`OB_Bank_NUM-1:0] cen;
    wire [`OB_Bank_NUM-1:0] wen;
    wire [`OB_Bank_NUM *`OB_WIDTH-1:0] din;
    wire [`OB_Bank_NUM *`OB_WIDTH-1:0] dout;


    genvar i;
    generate
        for (i = 0; i < `OB_Bank_NUM; i = i + 1) begin : BANK
            assign cen[i] = ((bank_idx == i) && (ob_store_en || ob_load_en)) || ob_npu_store_en;
            assign wen[i] = ((bank_idx == i) && ob_store_en) || ob_npu_store_en;
            assign din[i *`OB_WIDTH +: `OB_WIDTH] = ((bank_idx == i) && ob_store_en) ? ob_store_data :
                   ob_npu_store_en ? ob_npu_store_data[i *`OB_WIDTH +: `OB_WIDTH] : 'd0;

            smic281prf64x64m4
                smic281prf64x64m4_inst (
                    .CLK(clk),
                    .CEN(!cen[i]),
                    .WEN(!wen[i]),
                    .A(local_addr),
                    .D(din[i *`OB_WIDTH +: `OB_WIDTH]),
                    .Q(dout[i *`OB_WIDTH +: `OB_WIDTH]),
                    .BWEN(64'd0),
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


    reg [BANK_SEL_W-1:0]bank_idx_d;
    always @(posedge clk or negedge rstn) begin
        if(~rstn)
            bank_idx_d <= 'b0;
        else
            bank_idx_d <= bank_idx;
    end


    // assign ob_load_data = ob_load_en ? dout[bank_idx *`OB_WIDTH +: `OB_WIDTH] : 'd0;
    assign ob_load_data = dout[bank_idx_d *`OB_WIDTH +: `OB_WIDTH];

	
endmodule
