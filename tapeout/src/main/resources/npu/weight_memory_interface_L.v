`include "defines.v"
// `include "../0-RTL/AXI_SLAVE/defines.v"

module weight_memory_interface_L(
        input clk,
        input rstn,

        input                                   wm_load_en,
        input  [$clog2(`WM_DEPTH_L)-1:0]        wm_load_addr,
        output [`WM_WIDTH-1:0]                  wm_load_data,

        input                                   wm_store_en,
        input [$clog2(`WM_DEPTH_L)-1:0]         wm_store_addr,
        input [`WM_WIDTH-1:0]                   wm_store_data,

        input                                   wm_npu_load_en,
        input  [$clog2(`WM_Bank_DEPTH_L)-1:0]   wm_npu_load_addr,
        output [`WM_WIDTH *`WM_Bank_NUM -1:0]   wm_npu_load_data,
        input                                   NPU_AXI_SEL
    );

    localparam BANK_SEL_W  = $clog2(`WM_Bank_NUM);
    localparam LOCAL_ADDR_W  = $clog2(`WM_Bank_DEPTH_L);
    localparam ADDR_WIDTH  = $clog2(`WM_DEPTH_L);

    wire [BANK_SEL_W-1:0] bank_idx;
    wire [LOCAL_ADDR_W-1:0] local_addr;

    assign bank_idx  = wm_store_en ? wm_store_addr[ADDR_WIDTH-1 -: BANK_SEL_W] :
           wm_load_en  ? wm_load_addr[ADDR_WIDTH-1 -: BANK_SEL_W]  : 'd0;


    assign local_addr =wm_npu_load_en ? wm_npu_load_addr :
           wm_store_en ? wm_store_addr[LOCAL_ADDR_W-1:0]  :
           wm_load_en  ? wm_load_addr[LOCAL_ADDR_W-1:0]   : 'd0;

    wire [`WM_Bank_NUM-1:0] cen;
    wire [`WM_Bank_NUM-1:0] wen;
    wire [`WM_Bank_NUM *`WM_WIDTH-1:0] din;
    wire [`WM_Bank_NUM *`WM_WIDTH-1:0] dout;


    genvar i;
    generate
        for (i = 0; i < `WM_Bank_NUM; i = i + 1) begin : BANK
            assign cen[i] = ((bank_idx == i) && (wm_store_en || wm_load_en)) || wm_npu_load_en;
            assign wen[i] = (bank_idx == i) && wm_store_en && !wm_npu_load_en;
            assign din[i *`WM_WIDTH +: `WM_WIDTH] = wen[i] ? wm_store_data : 'd0;

			smic281prf1024x64m4
				smic281prf1024x64m4_inst (
					.CLK       ( clk           ),
					.CEN       ( !cen[i]       ),
					.WEN       ( !wen[i]       ),
					.A         ( local_addr    ),
					.D         ( din[i *`WM_WIDTH +: `WM_WIDTH] ),
					.Q         ( dout[i *`WM_WIDTH +: `WM_WIDTH]),
					.BWEN      ( 64'd0           ),
					.SD        ( 1'b0          ),
					.SLP       ( 1'b0          ),
					.PUDLY_SD  (               ),
					.PUDLY_SLP (               ),
					.RT        ( 2'b00         ),
					.WT        ( 2'b00         ),
					.TM        ( 1'b0          )
				);
        end
    endgenerate

    reg [BANK_SEL_W-1:0]bank_idx_d;
    always @(posedge clk or negedge rstn) begin
        if(~rstn)
            bank_idx_d <= 'b0;
        else begin
            if( |cen )
                bank_idx_d <= bank_idx;
        end
    end

    assign wm_load_data = !NPU_AXI_SEL ? dout[bank_idx_d *`WM_WIDTH +: `WM_WIDTH] : 'd0;
    assign wm_npu_load_data = NPU_AXI_SEL ? dout : 'd0;
endmodule
