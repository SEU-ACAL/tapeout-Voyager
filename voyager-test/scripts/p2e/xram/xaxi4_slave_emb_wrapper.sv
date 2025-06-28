/*************************************************************************
	> File Name: AXI_SRAM_WRAPPER.v
	> Author: Kai Yang
	> Mail: kaiyang@x-epic.com
	> Created Time: Tue 04 Jul 2023 05:41:49 PM CST
 ************************************************************************/
`default_nettype wire

module xaxi4_slave_emb_wrapper#(
    parameter AXI_MODE          = 4,    // AXI mode: 3 = AXI3, 4 = AXI4
    parameter AXI_ID_WIDTH      = 4,
    parameter AXI_DATA_WIDTH 	= 32,
    parameter AXI_ADDR_WIDTH 	= 32,
    parameter AXI_USER_WIDTH 	= 0,
    parameter MEM_BA 	        = 0,     // base address should be aligned with memory data width and 4KB boundary
    parameter MEM_SIZE          = 2048,
    parameter FIFO_DEPTH_AW     = 16,    // AW fifo depth width 
    parameter FIFO_DEPTH_AR     = 16,    // AR fifo depth width
    parameter FIFO_DEPTH_WD     = 8,
    parameter FIFO_DEPTH_RD     = 8
) (
    /*AUTOARG*/
    input wire aclk, 
    input wire aresetn, 
    // AXI latency control from interface 
    input  [31:0]                  i_awready_delay,       // awready delay register
    input  [31:0]                  i_wready_delay,        // wready delay register
    input  [31:0]                  i_bvalid_delay,        // bvalid delay register
    input  [15:0]                  i_arready_delay,       // delay time from arvalid to arready    
    input  [15:0]                  i_ar_rvalid_delay,     // rvalid minimal delay after ar handshack

      // AXI write address channel
    input wire                           i_awvalid, 
    output logic                         o_awready, 
    input wire [AXI_ID_WIDTH-1:0]        i_awid, 
    input wire [AXI_ADDR_WIDTH-1:0]      i_awaddr, 
    input wire [7:0]                     i_awlen,    // in AXI3 mode, [7:4] should be fixed to 0
    input wire [2:0]                     i_awsize, 
    input wire [1:0]                     i_awburst, 
    input wire [1:0]                     i_awlock, 
    input wire [3:0]                     i_awcache, 
    input wire [2:0]                     i_awprot, 
    input wire [3:0]                     i_awqos, 
    input wire [3:0]                     i_awregion,
    // AXI write data channel
    input wire                           i_wvalid, 
    output logic                         o_wready, 
    input wire [AXI_ID_WIDTH-1:0]        i_wid, 
    input wire [AXI_DATA_WIDTH-1:0]      i_wdata, 
    input wire [AXI_DATA_WIDTH/8-1:0]    i_wstrb, 
    input wire                           i_wlast, 
      // AXI write response channel
    output logic                         o_bvalid, 
    input wire                           i_bready,
    output logic [AXI_ID_WIDTH-1:0]      o_bid, 
    output logic [1:0]                   o_bresp, 
       // AXI read address channel
    input wire                           i_arvalid,
    output logic                         o_arready, 
    input wire [AXI_ID_WIDTH-1:0]        i_arid, 
    input wire [AXI_ADDR_WIDTH-1:0]      i_araddr, 
    input wire [7:0]                     i_arlen,    // in AXI3 mode, [7:4] should be fixed to 0
    input wire [2:0]                     i_arsize, 
    input wire [1:0]                     i_arburst, 
    input wire [1:0]                     i_arlock, 
    input wire [3:0]                     i_arcache, 
    input wire [2:0]                     i_arprot, 
    input wire [3:0]                     i_arqos, 
    input wire [3:0]                     i_arregion, 
      // AXI read response
    output logic                         o_rvalid,
    input wire                           i_rready, 
    output logic [AXI_ID_WIDTH-1:0]      o_rid, 
    output logic [1:0]                   o_rresp, 
    output logic [AXI_DATA_WIDTH-1:0]    o_rdata, 
    output logic                         o_rlast
`ifdef XEPIC_AXI_SRAM_DEBUG
    ,
    output [1299:0] debug_group
`endif

`ifdef XEPIC_XRAM_RTL
    ,
    input  init_calib_complete,
    output write_xram,        
    output [33:0]wr_addr_xram,  //16GB, per byte address
    output [512/8-1:0]wrdata_mask_xram,  
    output [512-1:0]wrdata_xram,       
    output read_xram,         
    output [33:0]rd_addr_xram,  //16GB, per byte address
    input  [512-1:0]rddata_xram,       
    input  rddata_valid_xram, 
    output rddata_ready_xram
`endif
);

xaxi4_slave_emb #(
	.AXI_MODE               (AXI_MODE      ),
	.AXI_ID_WIDTH           (AXI_ID_WIDTH  ),
	.AXI_DATA_WIDTH         (AXI_DATA_WIDTH),
	.AXI_ADDR_WIDTH         (AXI_ADDR_WIDTH),
	.AXI_USER_WIDTH         (AXI_USER_WIDTH),
	.FIFO_DEPTH_AW          (FIFO_DEPTH_AW ),
	.FIFO_DEPTH_AR          (FIFO_DEPTH_AR ),
	.FIFO_DEPTH_WD          (FIFO_DEPTH_WD ),
	.FIFO_DEPTH_RD          (FIFO_DEPTH_RD )
) u_xaxi4_slave_emb (
	.aclk               (aclk   ),
	.aresetn            (aresetn),
	.i_awready_delay    (i_awready_delay  ),
	.i_wready_delay     (i_wready_delay   ),
	.i_bvalid_delay     (i_bvalid_delay   ),
	.i_arready_delay    (i_arready_delay  ),
	.i_ar_rvalid_delay  (i_ar_rvalid_delay),
	.i_awvalid          (i_awvalid),
	.o_awready          (o_awready),
	.i_awid             (i_awid  ),
	.i_awaddr           (i_awaddr),
	.i_awlen            (i_awlen ),
	.i_awsize           (i_awsize),
	.i_awburst          (i_awburst),
	.i_awlock           (i_awlock),
	.i_awcache          (i_awcache),
	.i_awprot           (i_awprot),
	.i_awqos            (i_awqos ),
	.i_awregion         (i_awregion),
	.i_wvalid           (i_wvalid),
	.o_wready           (o_wready),
	.i_wid              (i_wid   ),
	.i_wdata            (i_wdata ),
	.i_wstrb            (i_wstrb ),
	.i_wlast            (i_wlast ),
	.o_bvalid           (o_bvalid),
	.i_bready           (i_bready),
	.o_bid              (o_bid   ),
	.o_bresp            (o_bresp ),
	.i_arvalid          (i_arvalid),
	.o_arready          (o_arready),
	.i_arid             (i_arid   ),
	.i_araddr           (i_araddr ),
	.i_arlen            (i_arlen  ),
	.i_arsize           (i_arsize ),
	.i_arburst          (i_arburst),
	.i_arlock           (i_arlock ),
	.i_arcache          (i_arcache),
	.i_arprot           (i_arprot ),
	.i_arqos            (i_arqos  ),
	.i_arregion         (i_arregion),
	.o_rvalid           (o_rvalid),
	.i_rready           (i_rready),
	.o_rid              (o_rid  ),
	.o_rresp            (o_rresp),
	.o_rdata            (o_rdata),
	.o_rlast            (o_rlast)

`ifdef XEPIC_AXI_SRAM_DEBUG
    ,
	.debug_group            (debug_group)
`endif

`ifdef XEPIC_XRAM_RTL
    ,
	.init_calib_complete    (init_calib_complete),
	.write_xram             (write_xram         ),
	.wr_addr_xram           (wr_addr_xram       ),
	.wrdata_mask_xram       (wrdata_mask_xram   ),
	.wrdata_xram            (wrdata_xram        ),
	.read_xram              (read_xram          ),
	.rd_addr_xram           (rd_addr_xram       ),
	.rddata_xram            (rddata_xram        ),
	.rddata_valid_xram      (rddata_valid_xram  ),
	.rddata_ready_xram      (rddata_ready_xram  )
`endif
);

endmodule
