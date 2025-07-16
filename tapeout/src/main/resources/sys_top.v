`include "../gen-collateral/defines.v"

module sys_top(
        input clk_w,
        input clk_cim,
        input rstn,

        // ahb port interface
        input          sys_load_en,
        input  [19:0]  sys_load_addr,
        output [63:0]  sys_load_data,

        input          sys_store_en,
        input  [19:0]  sys_store_addr,
        input  [63:0]  sys_store_data,

        output         NPU_AXI_SEL
    );


    //to all_mem_inerface
    wire                                      wml_load_en        ;
    wire [$clog2(`WM_DEPTH_L)-1:0]            wml_load_addr      ;
    wire [`WM_WIDTH-1:0]                      wml_load_data      ;
    wire                                      wml_store_en       ;
    wire [$clog2(`WM_DEPTH_L)-1:0]            wml_store_addr     ;
    wire [`WM_WIDTH-1:0]                      wml_store_data     ;

    wire                                      wms_load_en        ;
    wire [$clog2(`WM_DEPTH_S)-1:0]            wms_load_addr      ;
    wire [`WM_WIDTH-1:0]                      wms_load_data      ;
    wire                                      wms_store_en       ;
    wire [$clog2(`WM_DEPTH_S)-1:0]            wms_store_addr     ;
    wire [`WM_WIDTH-1:0]                      wms_store_data     ;

    wire                                      fml_load_en        ;
    wire [$clog2(`FM_DEPTH)-1:0]              fml_load_addr      ;
    wire [`FM_WIDTH-1:0]                      fml_load_data      ;
    wire                                      fml_store_en       ;
    wire [$clog2(`FM_DEPTH)-1:0]              fml_store_addr     ;
    wire [`FM_WIDTH-1:0]                      fml_store_data     ;

    wire                                      fms_load_en        ;
    wire [$clog2(`FM_DEPTH)-1:0]              fms_load_addr      ;
    wire [`FM_WIDTH-1:0]                      fms_load_data      ;
    wire                                      fms_store_en       ;
    wire [$clog2(`FM_DEPTH)-1:0]              fms_store_addr     ;
    wire [`FM_WIDTH-1:0]                      fms_store_data     ;

    wire                                      obl_load_en        ;
    wire [$clog2(`OB_DEPTH)-1:0]              obl_load_addr      ;
    wire [`OB_WIDTH-1:0]                      obl_load_data      ;
    wire                                      obl_store_en       ;
    wire [$clog2(`OB_DEPTH)-1:0]              obl_store_addr     ;
    wire [`OB_WIDTH-1:0]                      obl_store_data     ;

    wire                                      obs_load_en        ;
    wire [$clog2(`OB_DEPTH)-1:0]              obs_load_addr      ;
    wire [`OB_WIDTH-1:0]                      obs_load_data      ;
    wire                                      obs_store_en       ;
    wire [$clog2(`OB_DEPTH)-1:0]              obs_store_addr     ;
    wire [`OB_WIDTH-1:0]                      obs_store_data     ;

    wire                                      wml_npu_load_en    ;
    wire [$clog2(`WM_Bank_DEPTH_L)-1:0]       wml_npu_load_addr  ;
    wire [`WM_WIDTH *`WM_Bank_NUM -1:0]       wml_npu_load_data  ;

    wire                                      wms_npu_load_en    ;
    wire [$clog2(`WM_Bank_DEPTH_S)-1:0]       wms_npu_load_addr  ;
    wire [`WM_WIDTH *`WM_Bank_NUM -1:0]       wms_npu_load_data  ;

    wire                                      fml_npu_load_en    ;
    wire [$clog2(`FM_Bank_DEPTH)-1:0]         fml_npu_load_addr  ;
    wire [`FM_WIDTH *`FM_Bank_NUM -1:0]       fml_npu_load_data  ;

    wire                                      fms_npu_load_en    ;
    wire [$clog2(`FM_Bank_DEPTH)-1:0]         fms_npu_load_addr  ;
    wire [`FM_WIDTH *`FM_Bank_NUM -1:0]       fms_npu_load_data  ;

    wire                                      obl_npu_store_en   ;
    wire [$clog2(`OB_Bank_DEPTH)-1:0]         obl_npu_store_addr ;
    wire [`OB_WIDTH *`OB_Bank_NUM -1:0]       obl_npu_store_data ;

    wire                                      obs_npu_store_en   ;
    wire [$clog2(`OB_Bank_DEPTH)-1:0]         obs_npu_store_addr ;
    wire [`OB_WIDTH *`OB_Bank_NUM -1:0]       obs_npu_store_data ;

    wire                                   	  csr_load_en;
    wire [$clog2(`CSR_DEPTH)-1:0]          	  csr_load_addr;
    wire [`CSR_WIDTH-1:0]                  	  csr_load_data;
    wire                                   	  csr_store_en;
    wire [$clog2(`CSR_DEPTH)-1:0]          	  csr_store_addr;
    wire [`CSR_WIDTH-1:0]                  	  csr_store_data;

    //from MA&NPU_top
    wire  	wml_load_en_pre    ;
    wire  	wms_load_en_pre    ;
    wire  	obl_load_en_pre    ;
    wire  	obs_load_en_pre    ;
    wire  	fml_load_en_pre    ;
    wire  	fms_load_en_pre    ;

    wire  	wml_store_en_pre   ;
    wire  	wms_store_en_pre   ;
    wire  	obl_store_en_pre   ;
    wire  	obs_store_en_pre   ;
    wire  	fml_store_en_pre   ;
    wire  	fms_store_en_pre   ;

    wire  	wml_npu_load_en_pre ;		//add NPU module*****
    wire  	wms_npu_load_en_pre ;
    wire  	fml_npu_load_en_pre ;
    wire  	fms_npu_load_en_pre ;
    wire  	obl_npu_store_en_pre;
    wire  	obs_npu_store_en_pre;

    //****************TEST
    wire [`CSR_WIDTH*`CSR_DEPTH-1:0]                  	TEST_reg;



    assign wml_load_en		 = !NPU_AXI_SEL && wml_load_en_pre;
    assign wms_load_en		 = !NPU_AXI_SEL && wms_load_en_pre;

    assign wml_store_en		 = !NPU_AXI_SEL && wml_store_en_pre;
    assign wms_store_en		 = !NPU_AXI_SEL && wms_store_en_pre;

    assign wml_npu_load_en	 =  NPU_AXI_SEL && wml_npu_load_en_pre;
    assign wms_npu_load_en	 =  NPU_AXI_SEL && wms_npu_load_en_pre;

    assign fml_load_en		 = !NPU_AXI_SEL && fml_load_en_pre;
    assign fms_load_en		 = !NPU_AXI_SEL && fms_load_en_pre;

    assign fml_store_en		 = !NPU_AXI_SEL && fml_store_en_pre;
    assign fms_store_en		 = !NPU_AXI_SEL && fms_store_en_pre;

    assign fml_npu_load_en	 =  NPU_AXI_SEL && fml_npu_load_en_pre;
    assign fms_npu_load_en	 =  NPU_AXI_SEL && fms_npu_load_en_pre;

    assign obl_load_en		 = !NPU_AXI_SEL && obl_load_en_pre;
    assign obs_load_en		 = !NPU_AXI_SEL && obs_load_en_pre;

    assign obl_npu_store_en	 =  NPU_AXI_SEL && obl_npu_store_en_pre;
    assign obs_npu_store_en	 =  NPU_AXI_SEL && obs_npu_store_en_pre;


    weight_memory_interface_L
        weight_memory_interface_L_inst (
            .clk                ( clk_w               ),
            .rstn               ( rstn                ),
            .wm_load_en         ( wml_load_en         ),
            .wm_load_addr       ( wml_load_addr       ),
            .wm_load_data       ( wml_load_data       ),
            .wm_store_en        ( wml_store_en        ),
            .wm_store_addr      ( wml_store_addr      ),
            .wm_store_data      ( wml_store_data      ),
            .wm_npu_load_en     ( wml_npu_load_en     ),
            .wm_npu_load_addr   ( wml_npu_load_addr   ),
            .wm_npu_load_data   ( wml_npu_load_data   )
        );

    weight_memory_interface_S
        weight_memory_interface_S_inst (
            .clk                ( clk_w               ),
            .rstn               ( rstn                ),
            .wm_load_en         ( wms_load_en         ),
            .wm_load_addr       ( wms_load_addr       ),
            .wm_load_data       ( wms_load_data       ),
            .wm_store_en        ( wms_store_en        ),
            .wm_store_addr      ( wms_store_addr      ),
            .wm_store_data      ( wms_store_data      ),
            .wm_npu_load_en     ( wms_npu_load_en     ),
            .wm_npu_load_addr   ( wms_npu_load_addr   ),
            .wm_npu_load_data   ( wms_npu_load_data   )
        );

    output_buffer_interface
        output_buffer_interface_L_inst (
            .clk                ( clk_w               ),
            .rstn               ( rstn                ),
            .ob_load_en         ( obl_load_en         ),
            .ob_load_addr       ( obl_load_addr       ),
            .ob_load_data       ( obl_load_data       ),
            .ob_store_en        ( obl_store_en        ),
            .ob_store_addr      ( obl_store_addr      ),
            .ob_store_data      ( obl_store_data      ),
            .ob_npu_store_en    ( obl_npu_store_en    ),
            .ob_npu_store_addr  ( obl_npu_store_addr  ),
            .ob_npu_store_data  ( obl_npu_store_data  )
        );

    output_buffer_interface
        output_buffer_interface_S_inst (
            .clk                ( clk_w               ),
            .rstn               ( rstn                ),
            .ob_load_en         ( obs_load_en         ),
            .ob_load_addr       ( obs_load_addr       ),
            .ob_load_data       ( obs_load_data       ),
            .ob_store_en        ( obs_store_en        ),
            .ob_store_addr      ( obs_store_addr      ),
            .ob_store_data      ( obs_store_data      ),
            .ob_npu_store_en    ( obs_npu_store_en    ),
            .ob_npu_store_addr  ( obs_npu_store_addr  ),
            .ob_npu_store_data  ( obs_npu_store_data  )
        );

    feature_memory_interface
        feature_memory_interface_L_inst (
            .clk                ( clk_w               ),
            .rstn               ( rstn                ),
            .fm_load_en         ( fml_load_en         ),
            .fm_load_addr       ( fml_load_addr       ),
            .fm_load_data       ( fml_load_data       ),
            .fm_store_en        ( fml_store_en        ),
            .fm_store_addr      ( fml_store_addr      ),
            .fm_store_data      ( fml_store_data      ),
            .fm_npu_load_en     ( fml_npu_load_en     ),
            .fm_npu_load_addr   ( fml_npu_load_addr   ),
            .fm_npu_load_data   ( fml_npu_load_data   )
        );

    feature_memory_interface
        feature_memory_interface_S_inst (
            .clk                ( clk_w               ),
            .rstn               ( rstn                ),
            .fm_load_en         ( fms_load_en         ),
            .fm_load_addr       ( fms_load_addr       ),
            .fm_load_data       ( fms_load_data       ),
            .fm_store_en        ( fms_store_en        ),
            .fm_store_addr      ( fms_store_addr      ),
            .fm_store_data      ( fms_store_data      ),
            .fm_npu_load_en     ( fms_npu_load_en     ),
            .fm_npu_load_addr   ( fms_npu_load_addr   ),
            .fm_npu_load_data   ( fms_npu_load_data   )
        );


    csr_ctrl_memory_interface
        csr_ctrl_memory_interface_inst (
            .clk                ( clk_w               ),
            .rstn               ( rstn                ),
            .csr_load_en        ( csr_load_en         ),
            .csr_load_addr      ( csr_load_addr       ),
            .csr_load_data      ( csr_load_data       ),
            .csr_store_en       ( csr_store_en        ),
            .csr_store_addr     ( csr_store_addr      ),
            .csr_store_data     ( csr_store_data      ),
            .NPU_AXI_SEL        ( NPU_AXI_SEL         ),

            //***********TEST
            .TEST_reg        ( TEST_reg          )
        );

    // mem_access_manager instance
    mem_access_manager mem_access_manager_inst (
                           .clk              ( clk_w             ),
                           .rstn             ( rstn              ),
                           .sys_load_en      ( sys_load_en       ),
                           .sys_load_addr    ( sys_load_addr     ),
                           .sys_load_data    ( sys_load_data     ),
                           .sys_store_en     ( sys_store_en      ),
                           .sys_store_addr   ( sys_store_addr    ),
                           .sys_store_data   ( sys_store_data    ),
                           .wml_load_en      ( wml_load_en_pre   ),
                           .wml_load_addr    ( wml_load_addr     ),
                           .wml_load_data    ( wml_load_data     ),
                           .wml_store_en     ( wml_store_en_pre  ),
                           .wml_store_addr   ( wml_store_addr    ),
                           .wml_store_data   ( wml_store_data    ),
                           .wms_load_en      ( wms_load_en_pre   ),
                           .wms_load_addr    ( wms_load_addr     ),
                           .wms_load_data    ( wms_load_data     ),
                           .wms_store_en     ( wms_store_en_pre  ),
                           .wms_store_addr   ( wms_store_addr    ),
                           .wms_store_data   ( wms_store_data    ),
                           .obl_load_en      ( obl_load_en_pre   ),
                           .obl_load_addr    ( obl_load_addr     ),
                           .obl_load_data    ( obl_load_data     ),
                           .obl_store_en     ( obl_store_en_pre  ),
                           .obl_store_addr   ( obl_store_addr    ),
                           .obl_store_data   ( obl_store_data    ),
                           .obs_load_en      ( obs_load_en_pre   ),
                           .obs_load_addr    ( obs_load_addr     ),
                           .obs_load_data    ( obs_load_data     ),
                           .obs_store_en     ( obs_store_en_pre  ),
                           .obs_store_addr   ( obs_store_addr    ),
                           .obs_store_data   ( obs_store_data    ),
                           .fml_load_en      ( fml_load_en_pre   ),
                           .fml_load_addr    ( fml_load_addr     ),
                           .fml_load_data    ( fml_load_data     ),
                           .fml_store_en     ( fml_store_en_pre  ),
                           .fml_store_addr   ( fml_store_addr    ),
                           .fml_store_data   ( fml_store_data    ),
                           .fms_load_en      ( fms_load_en_pre   ),
                           .fms_load_addr    ( fms_load_addr     ),
                           .fms_load_data    ( fms_load_data     ),
                           .fms_store_en     ( fms_store_en_pre  ),
                           .fms_store_addr   ( fms_store_addr    ),
                           .fms_store_data   ( fms_store_data    ),
                           .csr_load_en      ( csr_load_en       ),
                           .csr_load_data    ( csr_load_data     ),
                           .csr_store_en     ( csr_store_en      ),
                           .csr_store_data   ( csr_store_data    )
                       );

    // NPU_top instance
    NPU_top NPU_top_inst(
                .clk_w                ( clk_w                ),
                .clk_cim              ( clk_cim              ),
                .rstn                 ( rstn                 ),
                .NPU_AXI_SEL          ( NPU_AXI_SEL          ),
                .wml_npu_load_en_pre  ( wml_npu_load_en_pre  ),
                .wml_npu_load_addr    ( wml_npu_load_addr    ),
                .wml_npu_load_data    ( wml_npu_load_data    ),
                .fml_npu_load_en_pre  ( fml_npu_load_en_pre  ),
                .fml_npu_load_addr    ( fml_npu_load_addr    ),
                .fml_npu_load_data    ( fml_npu_load_data    ),
                .obl_npu_store_en_pre ( obl_npu_store_en_pre ),
                .obl_npu_store_addr   ( obl_npu_store_addr   ),
                .obl_npu_store_data   ( obl_npu_store_data   ),
                .wms_npu_load_en_pre  ( wms_npu_load_en_pre  ),
                .wms_npu_load_addr    ( wms_npu_load_addr    ),
                .wms_npu_load_data    ( wms_npu_load_data    ),
                .fms_npu_load_en_pre  ( fms_npu_load_en_pre  ),
                .fms_npu_load_addr    ( fms_npu_load_addr    ),
                .fms_npu_load_data    ( fms_npu_load_data    ),
                .obs_npu_store_en_pre ( obs_npu_store_en_pre ),
                .obs_npu_store_addr   ( obs_npu_store_addr   ),
                .obs_npu_store_data   ( obs_npu_store_data   ),
                .TEST_reg             ( TEST_reg             )
            );


endmodule
