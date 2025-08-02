// `include "../0-RTL/AXI_SLAVE/defines.v"
`include "../gen-collateral/defines.v"

module NPU_top (
		input                  		clk_w,
		input                  		clk_cim,
		input                  		rstn,
		// from csr_ctrl
		input                  		NPU_AXI_SEL,
		// from CSR
		input                  		start_en,
		input                  		fp_en,
		input						ctrl_rstn,
		// large
		input      [4:0]       		MAC_INPUT_ROW_L,
		input      [4:0]       		MAC_LENGTH_L,         // MAX:6
		input      [9:0]       		FM_ADDR_START_L,
		input      [3:0]       		CSR_MEB_L,
		input      [7:0]       		last_CIMADR_L,
		input      [64*4*6-1:0]		E_most_L,
		// small
		input      [4:0]       		MAC_INPUT_ROW_S,
		input      [4:0]       		MAC_LENGTH_S,         // MAX:6
		input      [9:0]       		FM_ADDR_START_S,
		input      [3:0]       		CSR_MEB_S,
		input      [64*4*6-1:0]  	E_most_S,

		input [`EXP_DEPTH*`EXP_WIDTH-1:0]  WD_E_all,

        //to_CIM_mem_interface
        //from AXI
        //large
        input                                       CIM_L_store_en,
        input [$clog2(`CIM_DEPTH_L)-1:0]            CIM_L_store_addr,
        input [`CIM_WIDTH-1:0]                      CIM_L_store_data,
        //small
        input                                       CIM_S_store_en,
        input [$clog2(`CIM_DEPTH_S)-1:0]            CIM_S_store_addr,
        input [`CIM_WIDTH-1:0]                      CIM_S_store_data,

        //to SRAM_mem_interface
        output 										wml_npu_load_en_pre ,
        output [$clog2(`WM_Bank_DEPTH_L)-1:0]       wml_npu_load_addr   ,
        input [`WM_WIDTH *`WM_Bank_NUM -1:0]       	wml_npu_load_data   ,

        output 										fml_npu_load_en_pre ,
        output [$clog2(`FM_Bank_DEPTH_L)-1:0]       fml_npu_load_addr   ,
        input [`FM_WIDTH *`FM_Bank_NUM_L -1:0]      fml_npu_load_data   ,

        output 										obl_npu_store_en_pre,
        output [$clog2(`OB_Bank_DEPTH)-1:0]         obl_npu_store_addr  ,
        output [`OB_WIDTH *`OB_Bank_NUM -1:0]    	obl_npu_store_data  ,

        output 										wms_npu_load_en_pre ,
        output [$clog2(`WM_Bank_DEPTH_S)-1:0]       wms_npu_load_addr   ,
        input [`WM_WIDTH *`WM_Bank_NUM -1:0]       	wms_npu_load_data   ,

        output 										fms_npu_load_en_pre ,
        output [$clog2(`FM_Bank_DEPTH_S)-1:0]       fms_npu_load_addr   ,
        input [`FM_WIDTH *`FM_Bank_NUM_S -1:0]      fms_npu_load_data   ,

        output 										obs_npu_store_en_pre,
        output [$clog2(`OB_Bank_DEPTH)-1:0]         obs_npu_store_addr  ,
        output [`OB_WIDTH *`OB_Bank_NUM -1:0]    	obs_npu_store_data
    );
    localparam Macro_ROW_NUM_L    = 256;
    localparam ROW_NUM_2_L        = 32;
    localparam ROW_NUM_4_L        = 16;
    localparam GROUP_ROW_NUM_L    = 32;
    localparam ROW_GROUP_NUM_L    = 8;
    localparam COL_NUM_L          = 64;
    localparam COL_GROUP_NUM_L    = 8;
    localparam WEIGHT_W_L         = 8;
    localparam BUFFER_ROW_L       = 16;

    localparam Macro_ROW_NUM_S    = 32;
    localparam ROW_NUM_2_S        = 16;
    localparam ROW_NUM_4_S        = 4;
    localparam GROUP_ROW_NUM_S    = 32;
    localparam ROW_GROUP_NUM_S    = 1;
    localparam COL_NUM_S          = 64;
    localparam COL_GROUP_NUM_S    = 8;
    localparam WEIGHT_W_S         = 8;
    localparam BUFFER_ROW_S       = 16;

    //CIM_mem_interface_large signals
    wire                   					AXI_din_valid_L;
    wire [Macro_ROW_NUM_L*8-1:0] 			AXI_NNIN_E_L;
    wire [Macro_ROW_NUM_L*8-1:0] 			AXI_NNIN_M_L;
    wire [$clog2(Macro_ROW_NUM_L):0] 		AXI_WADR_L;
    wire [3:0]	            				AXI_WEB_L;
    wire [3:0]            					AXI_MEB_L;
    wire [63:0]       						AXI_WD_E_L;
    wire [63:0]       						AXI_WD_M_L;
    wire 	            					AXI_buffer0_rst_L;
    wire 	            					AXI_buffer1_rst_L;
    wire 	            					AXI_compute_valid_L;
    wire [$clog2(Macro_ROW_NUM_L):0] 		AXI_CIMADR_L;
    wire 	             					AXI_adder_enb_L;
    wire [3:0]             					AXI_buffer_row_addr_L;

    // NPU_core_large signals
    //input
    wire [3:0]                            	MEB_L;
    //CIM_coumpute port
    wire [Macro_ROW_NUM_L*8-1:0]			NNIN_E_L;
    wire [Macro_ROW_NUM_L*8-1:0]		 	NNIN_M_L;
    wire                                  	din_valid_L;
    wire 	                             	compute_valid_L;
    wire [$clog2(Macro_ROW_NUM_L):0]      	CIMADR_L;
    wire 	                             	adder_enb_L;
    wire [3:0]                            	buffer_row_addr_L;
    //write_CIM port
    wire [$clog2(Macro_ROW_NUM_L):0]      	WADR_L;
    wire [3:0] 	                            WEB_L;
    wire [64*4-1:0]                       	WD_E_L;			//from CSR
    wire [64*4-1:0] 						WD_M_L;
    wire 	                            	buffer1_rst_L;
    wire 	                            	buffer0_rst_L;
    //output
    wire [256*4-1:0]                     	data_out_L;
    wire 								 	Macro_out_valid_L;

	wire [64*4-1:0]                    	    E_most_L_core;
    // NPU_ctrl_large signals
    wire                   					NPU_din_valid_L;
    wire [Macro_ROW_NUM_L*8-1:0] 			NPU_NNIN_E_L;
    wire [Macro_ROW_NUM_L*8-1:0] 			NPU_NNIN_M_L;
    wire [$clog2(Macro_ROW_NUM_L):0] 		NPU_WADR_L;
    wire [3:0]            					NPU_WEB_L;
    wire [3:0]            					NPU_MEB_L;
	wire [64*4-1:0]       					NPU_WD_E_L;
    wire [64*4-1:0]       					NPU_WD_M_L;
    wire 	            					NPU_buffer0_rst_L;
    wire 	            					NPU_buffer1_rst_L;
    wire 	            					NPU_compute_valid_L;
    wire [$clog2(Macro_ROW_NUM_L):0] 		NPU_CIMADR_L;
    wire 	             					NPU_adder_enb_L;
    wire [3:0]             					NPU_buffer_row_addr_L;




    // CIM_memory_interface_small signals
    wire                                   AXI_din_valid_S;
    wire [Macro_ROW_NUM_S*8-1:0]           AXI_NNIN_E_S;
    wire [Macro_ROW_NUM_S*8-1:0]           AXI_NNIN_M_S;
    wire [$clog2(Macro_ROW_NUM_S):0]       AXI_WADR_S;
    wire [3:0]                             AXI_WEB_S;
    wire [3:0]                             AXI_MEB_S;
    wire [64-1:0]                          AXI_WD_E_S;
    wire [64-1:0]                          AXI_WD_M_S;
    wire 	                               AXI_buffer0_rst_S;
    wire 	                               AXI_buffer1_rst_S;
    wire [1:0]                             AXI_CIMADR_S;
    wire 	                               AXI_adder_enb_S;
    wire [3:0]                             AXI_buffer_row_addr_S;

    // NPU_core_small signals
    // input
    wire                                   din_valid_S;
    wire [Macro_ROW_NUM_S*8-1:0]           NNIN_E_S;
    wire [Macro_ROW_NUM_S*8-1:0]           NNIN_M_S;
    wire [$clog2(Macro_ROW_NUM_S):0]       WADR_S;
    wire [3:0]                             WEB_S;
    wire [3:0]                             MEB_S;
    wire [64*4-1:0]                        WD_E_S;
    wire [64*4-1:0]                        WD_M_S;
    wire 	                               buffer0_rst_S;
    wire 	                               buffer1_rst_S;
    wire [1:0]                             CIMADR_S;
    wire 	                               adder_enb_S;
    wire [3:0]                             buffer_row_addr_S;
    // output
    wire [256*4-1:0]                       data_out_S;
    wire                                   Macro_out_valid_S;

	wire [64*4-1:0]                    	   E_most_S_core;
    // NPU_ctrl_small signals
    wire                                   NPU_din_valid_S;
    wire [Macro_ROW_NUM_S*8-1:0]           NPU_NNIN_E_S;
    wire [Macro_ROW_NUM_S*8-1:0]           NPU_NNIN_M_S;
    wire [$clog2(Macro_ROW_NUM_S):0]       NPU_WADR_S;
    wire [3:0]                             NPU_WEB_S;
    wire [3:0]                             NPU_MEB_S;
    // wire [64*8-1:0]                        NPU_E_most_S;
    wire [64*4-1:0]                        NPU_WD_E_S;
    wire [64*4-1:0]                        NPU_WD_M_S;
    wire 	                               NPU_buffer0_rst_S;
    wire 	                               NPU_buffer1_rst_S;
    wire [1:0]                             NPU_CIMADR_S;
    wire 	                               NPU_adder_enb_S;
    wire [3:0]                             NPU_buffer_row_addr_S;



    //large singal SEL
    // MEB
    assign MEB_L               = NPU_AXI_SEL ? NPU_MEB_L               : AXI_MEB_L;
    // CIM_compute port
    assign NNIN_E_L            = NPU_AXI_SEL ? NPU_NNIN_E_L            : AXI_NNIN_E_L;
    assign NNIN_M_L            = NPU_AXI_SEL ? NPU_NNIN_M_L            : AXI_NNIN_M_L;
    assign din_valid_L         = NPU_AXI_SEL ? NPU_din_valid_L         : AXI_din_valid_L;
    assign compute_valid_L     = NPU_AXI_SEL ? NPU_compute_valid_L     : AXI_compute_valid_L;
    assign CIMADR_L            = NPU_AXI_SEL ? NPU_CIMADR_L            : AXI_CIMADR_L;
    assign adder_enb_L         = NPU_AXI_SEL ? NPU_adder_enb_L         : AXI_adder_enb_L;
    assign buffer_row_addr_L   = NPU_AXI_SEL ? NPU_buffer_row_addr_L   : AXI_buffer_row_addr_L;
    // write_CIM port
    assign WADR_L              = NPU_AXI_SEL ? NPU_WADR_L              : AXI_WADR_L;
    assign WEB_L               = NPU_AXI_SEL ? NPU_WEB_L               : AXI_WEB_L;
    assign WD_E_L              = NPU_AXI_SEL ? NPU_WD_E_L              : {4{AXI_WD_E_L}};
    assign WD_M_L              = NPU_AXI_SEL ? NPU_WD_M_L              : {4{AXI_WD_M_L}};
    assign buffer0_rst_L       = NPU_AXI_SEL ? NPU_buffer0_rst_L       : AXI_buffer0_rst_L;
    assign buffer1_rst_L       = NPU_AXI_SEL ? NPU_buffer1_rst_L       : AXI_buffer1_rst_L;

    //small singal SEL
    assign din_valid_S         = NPU_AXI_SEL ? NPU_din_valid_S        : AXI_din_valid_S;
    assign NNIN_E_S            = NPU_AXI_SEL ? NPU_NNIN_E_S           : AXI_NNIN_E_S;
    assign NNIN_M_S            = NPU_AXI_SEL ? NPU_NNIN_M_S           : AXI_NNIN_M_S;
    assign WADR_S              = NPU_AXI_SEL ? NPU_WADR_S             : AXI_WADR_S;
    assign WEB_S               = NPU_AXI_SEL ? NPU_WEB_S              : AXI_WEB_S;
    assign MEB_S               = NPU_AXI_SEL ? NPU_MEB_S              : AXI_MEB_S;
    assign WD_E_S              = NPU_AXI_SEL ? NPU_WD_E_S             : {4{AXI_WD_E_S}};
    assign WD_M_S              = NPU_AXI_SEL ? NPU_WD_M_S             : {4{AXI_WD_M_S}};
    assign buffer0_rst_S       = NPU_AXI_SEL ? NPU_buffer0_rst_S      : AXI_buffer0_rst_S;
    assign buffer1_rst_S       = NPU_AXI_SEL ? NPU_buffer1_rst_S      : AXI_buffer1_rst_S;
    assign CIMADR_S            = NPU_AXI_SEL ? NPU_CIMADR_S           : AXI_CIMADR_S;
    assign adder_enb_S         = NPU_AXI_SEL ? NPU_adder_enb_S        : AXI_adder_enb_S;
    assign buffer_row_addr_S   = NPU_AXI_SEL ? NPU_buffer_row_addr_S  : AXI_buffer_row_addr_S;


	//CIM_large_memory_interface instantiation
	CIM_memory_interface_large #(
		.Macro_ROW_NUM           ( Macro_ROW_NUM_L           )
	) u_CIM_memory_interface_large (
		.clk                     ( clk_w                     ),
		.rstn                    ( rstn                      ),
		.CIM_store_en            ( CIM_L_store_en            ),
		.CIM_store_addr          ( CIM_L_store_addr          ),
		.CIM_store_data          ( CIM_L_store_data          ),
		.exp_data                ( WD_E_all                  ),
		.fp_en                   ( fp_en                     ),
		.AXI_din_valid_L         ( AXI_din_valid_L           ),
		.AXI_NNIN_E_L            ( AXI_NNIN_E_L              ),
		.AXI_NNIN_M_L            ( AXI_NNIN_M_L              ),
		.AXI_WADR_L              ( AXI_WADR_L                ),
		.AXI_WEB_L               ( AXI_WEB_L                 ),
		.AXI_MEB_L               ( AXI_MEB_L                 ),
		.AXI_WD_E_L              ( AXI_WD_E_L                ),
		.AXI_WD_M_L              ( AXI_WD_M_L                ),
		.AXI_buffer0_rst_L       ( AXI_buffer0_rst_L         ),
		.AXI_buffer1_rst_L       ( AXI_buffer1_rst_L         ),
		.AXI_compute_valid_L     ( AXI_compute_valid_L        ),
		.AXI_CIMADR_L            ( AXI_CIMADR_L              ),
		.AXI_adder_enb_L         ( AXI_adder_enb_L           ),
		.AXI_buffer_row_addr_L   ( AXI_buffer_row_addr_L     )
	);

	// NPU_core_large instantiation
	NPU_core_large #(
		.Macro_ROW_NUM           ( Macro_ROW_NUM_L           ),
		.ROW_NUM_2               ( ROW_NUM_2_L               ),
		.ROW_NUM_4               ( ROW_NUM_4_L               ),
		.GROUP_ROW_NUM           ( GROUP_ROW_NUM_L           ),
		.ROW_GROUP_NUM           ( ROW_GROUP_NUM_L           ),
		.COL_NUM                 ( COL_NUM_L                 ),
		.COL_GROUP_NUM           ( COL_GROUP_NUM_L           ),
		.WEIGHT_W                ( WEIGHT_W_L                ),
		.BUFFER_ROW              ( BUFFER_ROW_L              )
	) u_NPU_core_large (
		.clk_w                   ( clk_w                     ),
		.clk_cim                 ( clk_cim                   ),
		.rstn                    ( rstn                      ),
		.din_valid               ( din_valid_L               ),
		.NNIN_E                  ( NNIN_E_L                  ),
		.NNIN_M                  ( NNIN_M_L                  ),
		.WADR                    ( WADR_L                    ),
		.WEB                     ( WEB_L                     ),
		.MEB                     ( MEB_L                     ),
		.fp_en                   ( fp_en                     ),
		.E_most                  ( E_most_L_core             ),
		.WD_E                    ( WD_E_L                    ),
		.WD_M                    ( WD_M_L                    ),
		.buffer0_rst             ( buffer0_rst_L|!ctrl_rstn  ),
		.buffer1_rst             ( buffer1_rst_L|!ctrl_rstn  ),
		.compute_valid           ( compute_valid_L           ),
		.CIMADR                  ( CIMADR_L                  ),
		.adder_enb               ( adder_enb_L               ),
		.buffer_row_addr         ( buffer_row_addr_L         ),
		.data_out                ( data_out_L                ),
		.Macro_out_valid         ( Macro_out_valid_L         )
	);

	NPU_ctrl_large #(
		.Macro_ROW_NUM_L         ( Macro_ROW_NUM_L           	)
	) u_NPU_ctrl_large (
		.clk_w                   ( clk_w                     	),
		.clk_cim                 ( clk_cim                   	),
		.rstn                    ( rstn&ctrl_rstn            	),
		.NPU_AXI_SEL             ( NPU_AXI_SEL               	),
		.start_en_L              ( start_en                  	),
		.fp_en_L                 ( fp_en                     	),
		.MAC_INPUT_ROW           ( MAC_INPUT_ROW_L           	),
		.MAC_LENGTH              ( MAC_LENGTH_L              	),
		.FM_ADDR_START_L         ( FM_ADDR_START_L           	),
		.CSR_MEB_L               ( CSR_MEB_L                 	),
		.last_CIMADR_L           ( last_CIMADR_L             	),
		.E_most_L                ( E_most_L		             	),

		.MEB_L                   ( NPU_MEB_L                 	),
		.NNIN_E_L                ( NPU_NNIN_E_L              	),
		.NNIN_M_L                ( NPU_NNIN_M_L              	),
		.din_valid_L             ( NPU_din_valid_L           	),
		.compute_valid_L         ( NPU_compute_valid_L       	),
		.CIMADR_L                ( NPU_CIMADR_L              	),
		.adder_enb_L             ( NPU_adder_enb_L           	),
		.buffer_row_addr_L       ( NPU_buffer_row_addr_L     	),
		.WADR_L                  ( NPU_WADR_L                	),
		.WEB_L                   ( NPU_WEB_L                 	),
		.WD_E_L                  ( NPU_WD_E_L                	),
		.WD_M_L                  ( NPU_WD_M_L                	),
		.buffer1_rst_L           ( NPU_buffer1_rst_L            ),
		.buffer0_rst_L           ( NPU_buffer0_rst_L            ),
		.E_most_L_core		     ( E_most_L_core             	),
		.data_out_L              ( data_out_L                	),
		.Macro_out_valid         ( Macro_out_valid_L         	),
		.wml_npu_load_en_pre     ( wml_npu_load_en_pre       	),
		.wml_npu_load_addr       ( wml_npu_load_addr         	),
		.wml_npu_load_data       ( wml_npu_load_data         	),
		.fml_npu_load_en_pre     ( fml_npu_load_en_pre       	),
		.fml_npu_load_addr       ( fml_npu_load_addr         	),
		.fml_npu_load_data       ( fml_npu_load_data         	),
		.obl_npu_store_en_pre    ( obl_npu_store_en_pre      	),
		.obl_npu_store_addr      ( obl_npu_store_addr        	),
		.obl_npu_store_data      ( obl_npu_store_data        	)
	);



    //CIM_memory_interface_small inst
	CIM_memory_interface_small #(
		.Macro_ROW_NUM         ( Macro_ROW_NUM_S )
	) u_CIM_memory_interface_small (
		.clk                   ( clk_w                   ),
		.rstn                  ( rstn                    ),

		.CIM_store_en          ( CIM_S_store_en          ),
		.CIM_store_addr        ( CIM_S_store_addr        ),
		.CIM_store_data        ( CIM_S_store_data        ),
		.exp_data              ( WD_E_all                ),
		.fp_en                 ( fp_en                   ),

		.AXI_din_valid_S       ( AXI_din_valid_S         ),
		.AXI_NNIN_E_S          ( AXI_NNIN_E_S            ),
		.AXI_NNIN_M_S          ( AXI_NNIN_M_S            ),

		.AXI_WADR_S            ( AXI_WADR_S              ),
		.AXI_WEB_S             ( AXI_WEB_S               ),
		.AXI_MEB_S             ( AXI_MEB_S               ),

		.AXI_WD_E_S            ( AXI_WD_E_S              ),
		.AXI_WD_M_S            ( AXI_WD_M_S              ),
		.AXI_buffer0_rst_S     ( AXI_buffer0_rst_S       ),
		.AXI_buffer1_rst_S     ( AXI_buffer1_rst_S       ),

		.AXI_CIMADR_S          ( AXI_CIMADR_S            ),
		.AXI_adder_enb_S       ( AXI_adder_enb_S         ),
		.AXI_buffer_row_addr_S ( AXI_buffer_row_addr_S   )
	);


    // NPU_core_small instantiation
	NPU_core_small #(
	   .Macro_ROW_NUM      ( Macro_ROW_NUM_S      ),
	   .ROW_NUM_2          ( ROW_NUM_2_S          ),
	   .ROW_NUM_4          ( ROW_NUM_4_S          ),
	   .GROUP_ROW_NUM      ( GROUP_ROW_NUM_S      ),
	   .ROW_GROUP_NUM      ( ROW_GROUP_NUM_S      ),
	   .COL_NUM            ( COL_NUM_S            ),
	   .COL_GROUP_NUM      ( COL_GROUP_NUM_S      ),
	   .WEIGHT_W           ( WEIGHT_W_S           ),
	   .BUFFER_ROW         ( BUFFER_ROW_S         )
				   ) u_NPU_core_small (
					   .clk_cim            ( clk_cim              		),
					   .clk_w              ( clk_w                		),
					   .rstn               ( rstn                 		),
					   .din_valid          ( din_valid_S          		),
					   .NNIN_E             ( NNIN_E_S             		),
					   .NNIN_M             ( NNIN_M_S             		),
					   .WADR               ( WADR_S               		),
					   .WEB                ( WEB_S                		),
					   .MEB                ( MEB_S                		),
					   .fp_en              ( fp_en                		),
					   .E_most             ( E_most_S_core        		),
					   .WD_E               ( WD_E_S               		),
					   .WD_M               ( WD_M_S               		),
					   .buffer0_rst        ( buffer0_rst_S|!ctrl_rstn 	),
					   .buffer1_rst        ( buffer1_rst_S|!ctrl_rstn 	),
					   .CIMADR             ( CIMADR_S             		),
					   .adder_enb          ( adder_enb_S          		),
					   .buffer_row_addr    ( buffer_row_addr_S    		),
					   .data_out           ( data_out_S           		),
					   .Macro_out_valid    ( Macro_out_valid_S    		)
				   );

	NPU_ctrl_small #(
		.Macro_ROW_NUM_S( Macro_ROW_NUM_S )
	) u_NPU_ctrl_small (
			.clk_w                        ( clk_w                    ),
			.clk_cim                      ( clk_cim                  ),
			.rstn                         ( rstn&ctrl_rstn           ),
			// from CSR
			.NPU_AXI_SEL	              ( NPU_AXI_SEL              ),
			.MAC_INPUT_ROW                ( MAC_INPUT_ROW_S          ),
			.MAC_LENGTH                   ( MAC_LENGTH_S             ),
			.FM_ADDR_START_S              ( FM_ADDR_START_S          ),
			.CSR_MEB_S                    ( CSR_MEB_S                ),
			.start_en_S                   ( start_en                 ),
			.fp_en_S                      ( fp_en                    ),
			.E_most_S                     ( E_most_S                 ),

			// to memory interface
			.wms_npu_load_en_pre          ( wms_npu_load_en_pre      ),
			.wms_npu_load_addr            ( wms_npu_load_addr        ),
			.wms_npu_load_data            ( wms_npu_load_data        ),
			.fms_npu_load_en_pre          ( fms_npu_load_en_pre      ),
			.fms_npu_load_addr            ( fms_npu_load_addr        ),
			.fms_npu_load_data            ( fms_npu_load_data        ),
			.obs_npu_store_en_pre         ( obs_npu_store_en_pre     ),
			.obs_npu_store_addr           ( obs_npu_store_addr       ),
			.obs_npu_store_data           ( obs_npu_store_data       ),
			// to npu core
			.din_valid_S                  ( NPU_din_valid_S          ),
			.NNIN_E_S                     ( NPU_NNIN_E_S             ),
			.NNIN_M_S                     ( NPU_NNIN_M_S             ),
			.WADR_S                       ( NPU_WADR_S               ),
			.WEB_S                        ( NPU_WEB_S                ),
			.MEB_S                        ( NPU_MEB_S                ),
			.WD_E_S                       ( NPU_WD_E_S               ),
			.WD_M_S                       ( NPU_WD_M_S               ),
			.buffer1_rst_S                ( NPU_buffer1_rst_S        ),
			.buffer0_rst_S                ( NPU_buffer0_rst_S        ),
			.CIMADR_S                     ( NPU_CIMADR_S             ),
			.adder_enb_S                  ( NPU_adder_enb_S          ),
			.E_most_S_core                ( E_most_S_core            ),
			.buffer_row_addr_S            ( NPU_buffer_row_addr_S    ),
			.data_out_S                   ( data_out_S               ),
			.Macro_out_valid              ( Macro_out_valid_S        )
		);
endmodule
