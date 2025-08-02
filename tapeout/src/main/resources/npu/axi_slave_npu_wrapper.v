module axi_slave_npu_wrapper(
        input               clk,
        input               rstn,

        input      [19:0]   axi_awaddr,
        input      [7:0]    axi_awlen,      // 8 bit
        input      [2:0]    axi_awsize,     // 3 bit
        input      [1:0]    axi_awburst,
        input      [1:0]   axi_awid,
        input               axi_awvalid,
        output              axi_awready,

        input      [63:0]   axi_wdata,
        input      [7:0]    axi_wstrb,
        input               axi_wlast,
        input               axi_wvalid,
        output              axi_wready,

        output     [1:0]    axi_bresp,
        output     [1:0]   axi_bid,
        output              axi_bvalid,
        input               axi_bready,

        input      [19:0]   axi_araddr,
        input      [7:0]    axi_arlen,
        input      [2:0]    axi_arsize,
        input      [1:0]    axi_arburst,
        input      [1:0]   axi_arid,
        input               axi_arvalid,
        output              axi_arready,

        output     [63:0]   axi_rdata,
        output     [1:0]   axi_rid,
        output     [1:0]    axi_rresp,
        output              axi_rlast,
        output              axi_rvalid,
        input               axi_rready,

        // PAD input port
        input               clk_FPGA_w,
        input               clk_FPGA_cim,
        input               rstn_FPGA,
        input               PLL_CLK_SEL,        // 0:original , 1:PLL_CLK
        input               TEST_MODE,          // 0:CPU      , 1:TEST_MODE
        // input            load_store_OEN,      // 0:load     , 1:store in PAD port

        // PAD output port
        output              FPGA_sys_load_data_vld,

        // PAD port reuse
        input               FPGA_sys_load_en,
        input      [16:0]   FPGA_sys_load_addr,
        output     [63:0]   FPGA_sys_load_data,

        input               FPGA_sys_store_en,
        input      [16:0]   FPGA_sys_store_addr,
        input      [63:0]   FPGA_sys_store_data,

        // on-chip input port
        // TO PLL
        input               clk_PLL_w,
        input               clk_PLL_cim
    );

    wire         sys_load_en;
    wire [16:0]  sys_load_addr;
    wire [63:0]  sys_load_data;
    wire         sys_load_data_vld;
    wire         sys_store_en;
    wire [16:0]  sys_store_addr;
    wire [63:0]  sys_store_data;

    wire         AXI_sys_load_en;
    wire [16:0]  AXI_sys_load_addr;
    wire [63:0]  AXI_sys_load_data;
    wire         AXI_sys_store_en;
    wire [16:0]  AXI_sys_store_addr;
    wire [63:0]  AXI_sys_store_data;

    wire         clk_w;
    wire         clk_cim;
    wire         clk_CSR;
    wire         rstn_NPU;
    wire         NPU_AXI_SEL;

    wire [19:0]  axi_awaddr_ofst;
    wire [19:0]  axi_araddr_ofst;

    assign axi_awaddr_ofst = {axi_awaddr[19:16] - 3'b101, axi_awaddr[15:0]};
    assign axi_araddr_ofst = {axi_araddr[19:16] - 3'b101, axi_araddr[15:0]};



    // axi transfer
    axi_bridge axi_bridge_inst (
                   .clk              ( clk           ),
                   .rstn             ( rstn              ),
                   .axi_awaddr       ( axi_awaddr_ofst ),
                   .axi_awlen        ( axi_awlen         ),
                   .axi_awsize       ( axi_awsize        ),
                   .axi_awburst      ( axi_awburst       ),
                   .axi_awid         ( axi_awid          ),
                   .axi_awvalid      ( axi_awvalid       ),
                   .axi_awready      ( axi_awready       ),
                   .axi_wdata        ( axi_wdata         ),
                   .axi_wstrb        ( axi_wstrb         ),
                   .axi_wlast        ( axi_wlast         ),
                   .axi_wvalid       ( axi_wvalid        ),
                   .axi_wready       ( axi_wready        ),
                   .axi_bresp        ( axi_bresp         ),
                   .axi_bid          ( axi_bid           ),
                   .axi_bvalid       ( axi_bvalid        ),
                   .axi_bready       ( axi_bready        ),
                   .axi_araddr       ( axi_araddr_ofst ),
                   .axi_arlen        ( axi_arlen         ),
                   .axi_arsize       ( axi_arsize        ),
                   .axi_arburst      ( axi_arburst       ),
                   .axi_arid         ( axi_arid          ),
                   .axi_arvalid      ( axi_arvalid       ),
                   .axi_arready      ( axi_arready       ),
                   .axi_rdata        ( axi_rdata         ),
                   .axi_rid          ( axi_rid           ),
                   .axi_rresp        ( axi_rresp         ),
                   .axi_rlast        ( axi_rlast         ),
                   .axi_rvalid       ( axi_rvalid        ),
                   .axi_rready       ( axi_rready        ),
                   .sys_load_en      ( AXI_sys_load_en   ),
                   .sys_load_addr    ( AXI_sys_load_addr ),
                   .sys_load_data    ( AXI_sys_load_data ),
                   .sys_store_en     ( AXI_sys_store_en  ),
                   .sys_store_addr   ( AXI_sys_store_addr),
                   .sys_store_data   ( AXI_sys_store_data)
               );


    sys_top sys_top_inst (
                .clk_w               ( clk_w               ),
                .clk_cim             ( clk_cim             ),
                .clk_CSR             ( clk_CSR             ),
                .rstn                ( rstn_NPU             ),
                .sys_load_en         ( sys_load_en          ),
                .sys_load_addr       ( sys_load_addr        ),
                .sys_load_data       ( sys_load_data        ),
                .sys_load_data_vld   ( sys_load_data_vld    ),
                .sys_store_en        ( sys_store_en         ),
                .sys_store_addr      ( sys_store_addr       ),
                .sys_store_data      ( sys_store_data       ),

                .NPU_AXI_SEL         ( NPU_AXI_SEL          )
            );



    TEST_MODE_bridge u_TEST_MODE_bridge(
                         .clk_FPGA_w          		( clk_FPGA_w          ),
                         .clk_FPGA_cim        		( clk_FPGA_cim        ),
                         .rstn_FPGA           		( rstn_FPGA			),
                         .PLL_CLK_SEL         		( PLL_CLK_SEL         ),
                         .TEST_MODE           		( TEST_MODE           ),
                         .FPGA_sys_load_en    		( FPGA_sys_load_en    ),
                         .FPGA_sys_load_addr  		( FPGA_sys_load_addr  ),
                         .FPGA_sys_load_data  		( FPGA_sys_load_data  ),
                         .FPGA_sys_load_data_vld    ( FPGA_sys_load_data_vld   ),
                         .FPGA_sys_store_en   		( FPGA_sys_store_en   ),
                         .FPGA_sys_store_addr 		( FPGA_sys_store_addr ),
                         .FPGA_sys_store_data 		( FPGA_sys_store_data ),
                         .clk_PLL_w           		( clk_PLL_w           ),			//no PLL***
                         .clk_PLL_cim         		( clk_PLL_cim         ),			//no PLL***
                         .clk_AXI             		( clk            		),
                         .rstn_AXI			  		( rstn					),
                         .AXI_sys_load_en     		( AXI_sys_load_en     ),
                         .AXI_sys_load_addr   		( AXI_sys_load_addr   ),
                         .AXI_sys_load_data   		( AXI_sys_load_data   ),
                         .AXI_sys_store_en    		( AXI_sys_store_en    ),
                         .AXI_sys_store_addr  		( AXI_sys_store_addr  ),
                         .AXI_sys_store_data  		( AXI_sys_store_data  ),
                         .NPU_AXI_SEL         		( NPU_AXI_SEL         ),
                         .clk_w               		( clk_w               ),
                         .clk_cim             		( clk_cim             ),
                         .clk_CSR                   ( clk_CSR             ),
                         .rstn_NPU            		( rstn_NPU				),
                         .sys_load_en         		( sys_load_en         ),
                         .sys_load_addr       		( sys_load_addr       ),
                         .sys_load_data       		( sys_load_data       ),
                         .sys_load_data_vld   		( sys_load_data_vld   ),
                         .sys_store_en        		( sys_store_en        ),
                         .sys_store_addr      		( sys_store_addr      ),
                         .sys_store_data      		( sys_store_data      )
                     );


endmodule
