`include "../gen-collateral/defines.v"

module NPU_top (
        input 				clk_w,
        input 				clk_cim,
        input 				rstn,
        //from csr_ctrl
        input         		NPU_AXI_SEL,
        //to_CIM_mem_interface
        // input                            			CIM_store_en,
        // input [$clog2(`CIM_DEPTH):0]	 			CIM_store_addr,
        // input [`CIM_WIDTH-1:0]        	 			CIM_store_data,
        //to SRAM_mem_interface
        output 										wml_npu_load_en_pre ,
        output [$clog2(`WM_Bank_DEPTH_L)-1:0]       wml_npu_load_addr   ,
        input [`WM_WIDTH *`WM_Bank_NUM -1:0]       	wml_npu_load_data   ,

        output 										fml_npu_load_en_pre ,
        output [$clog2(`FM_Bank_DEPTH)-1:0]         fml_npu_load_addr   ,
        input [`FM_WIDTH *`FM_Bank_NUM -1:0]       	fml_npu_load_data   ,

        output 										obl_npu_store_en_pre,
        output [$clog2(`OB_Bank_DEPTH)-1:0]         obl_npu_store_addr  ,
        output reg[`OB_WIDTH *`OB_Bank_NUM -1:0]    obl_npu_store_data  ,

        output 										wms_npu_load_en_pre ,
        output [$clog2(`WM_Bank_DEPTH_S)-1:0]       wms_npu_load_addr   ,
        input [`WM_WIDTH *`WM_Bank_NUM -1:0]       	wms_npu_load_data   ,

        output 										fms_npu_load_en_pre ,
        output [$clog2(`FM_Bank_DEPTH)-1:0]         fms_npu_load_addr   ,
        input [`FM_WIDTH *`FM_Bank_NUM -1:0]       	fms_npu_load_data   ,

        output 										obs_npu_store_en_pre,
        output [$clog2(`OB_Bank_DEPTH)-1:0]         obs_npu_store_addr  ,
        output reg[`OB_WIDTH *`OB_Bank_NUM -1:0]    obs_npu_store_data	,

        //********************TEST
        input [`CSR_WIDTH*`CSR_DEPTH-1:0]			TEST_reg
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
    // NPU_core_large signals
    //input
    reg                                   din_valid_L;
    reg [Macro_ROW_NUM_L*8-1:0]           NNIN_L;
    reg [$clog2(Macro_ROW_NUM_L):0]       WADR_L;
    reg [7:0]                             WEB_L;
    reg [7:0]                             MEB_L;
    reg                                   fp_en_L;
    reg [64*8-1:0]                        E_most_L;
    reg [64*8-1:0]                        WD_E_L;
    reg [64*8-1:0]                        WD_M_L;
    reg [7:0]                             buffer0_rst_L;
    reg [7:0]                             buffer1_rst_L;
    reg [7:0]                             compute_valid_L;
    reg [$clog2(Macro_ROW_NUM_L):0]       CIMADR_L;
    reg                                   sign_bit_L;
    reg [7:0]                             adder_enb_L;
    reg [3:0]                             buffer_row_addr_L;
    //output
    wire [32*8*8-1:0]                     outlier_sum_L;
    wire [7:0]                            dout_valid_L;
    wire [256*8-1:0]                      data_out_L;
    wire                                  CIM_compute_ready_L;
    localparam Macro_ROW_NUM_S    = 32;
    localparam ROW_NUM_2_S        = 16;
    localparam ROW_NUM_4_S        = 4;
    localparam GROUP_ROW_NUM_S    = 32;
    localparam ROW_GROUP_NUM_S    = 1;
    localparam COL_NUM_S          = 64;
    localparam COL_GROUP_NUM_S    = 8;
    localparam WEIGHT_W_S         = 8;
    localparam BUFFER_ROW_S       = 16;
    // NPU_core_small signals
    // input
    reg                                   din_valid_S;
    reg [Macro_ROW_NUM_S*8*8-1:0]         NNIN_all_S;
    reg [1:0]                             combine_mode_S;
    reg [2:0]                             NNIN_sel_S;
    reg [$clog2(Macro_ROW_NUM_S):0]       WADR_S;
    reg [7:0]                             WEB_S;
    reg [7:0]                             MEB_S;
    reg                                   fp_en_S;
    reg [64*8-1:0]                        E_most_S;
    reg [64*8-1:0]                        WD_E_S;
    reg [64*8-1:0]                        WD_M_S;
    reg [7:0]                             buffer0_rst_S;
    reg [7:0]                             buffer1_rst_S;
    reg [7:0]                             compute_valid_S;
    reg [8*Macro_ROW_NUM_S-1:0]           full_NNIN_S;
    reg [1:0]                             CIMADR_S;
    reg                                   sign_bit_S;
    reg [7:0]                             adder_enb_S;
    reg [3:0]                             buffer_row_addr_S;
    // output
    wire [15*8*8-1:0]                     outlier_sum_S;
    wire [7:0]                            dout_valid_S;
    wire [256*8-1:0]                      data_out_S;
    wire                                  CIM_store_ready_S;



    //********************TEST
    always @(*) begin
        {WD_E_L, WD_M_L} = wml_npu_load_data;
        NNIN_L = fml_npu_load_data;
        obl_npu_store_data = outlier_sum_L + data_out_L;
        {WD_E_S, WD_M_S} = wms_npu_load_data;
        full_NNIN_S = fms_npu_load_data;
        obs_npu_store_data = outlier_sum_S+data_out_S;
    end
	// 随机分配 TEST_reg 的输出到这些信号
	always @(*) begin
		din_valid_L         = TEST_reg[0];
		WADR_L              = TEST_reg[8 +: $clog2(Macro_ROW_NUM_L)+1];
		WEB_L               = TEST_reg[16 +: 8];
		MEB_L               = TEST_reg[24 +: 8];
		fp_en_L             = TEST_reg[32];
		E_most_L            = TEST_reg[40 +: 64*8];
		buffer0_rst_L       = TEST_reg[552 +: 8];
		buffer1_rst_L       = TEST_reg[560 +: 8];
		compute_valid_L     = TEST_reg[568 +: 8];
		CIMADR_L            = TEST_reg[576 +: $clog2(Macro_ROW_NUM_L)+1];
		sign_bit_L          = TEST_reg[584];
		adder_enb_L         = TEST_reg[592 +: 8];
		buffer_row_addr_L   = TEST_reg[600 +: 4];

		din_valid_S         = TEST_reg[608];
		NNIN_all_S          = TEST_reg[616 +: Macro_ROW_NUM_S*8*8];
		combine_mode_S      = TEST_reg[1816 +: 2];
		NNIN_sel_S          = TEST_reg[1818 +: 3];
		WADR_S              = TEST_reg[1821 +: $clog2(Macro_ROW_NUM_S)+1];
		WEB_S               = TEST_reg[1829 +: 8];
		MEB_S               = TEST_reg[1837 +: 8];
		fp_en_S             = TEST_reg[1845];
		E_most_S            = TEST_reg[1846 +: 64*8];
		buffer0_rst_S       = TEST_reg[2358 +: 8];
		buffer1_rst_S       = TEST_reg[2366 +: 8];
		compute_valid_S     = TEST_reg[2374 +: 8];
		CIMADR_S            = TEST_reg[2382 +: 2];
		sign_bit_S          = TEST_reg[2384];
		adder_enb_S         = TEST_reg[2385 +: 8];
		buffer_row_addr_S   = TEST_reg[2393 +: 4];
	end
    //********************TEST












    // NPU_core_large instantiation
    NPU_core_large #(
                       .Macro_ROW_NUM   ( Macro_ROW_NUM_L   ),
                       .ROW_NUM_2       ( ROW_NUM_2_L       ),
                       .ROW_NUM_4       ( ROW_NUM_4_L       ),
                       .GROUP_ROW_NUM   ( GROUP_ROW_NUM_L   ),
                       .ROW_GROUP_NUM   ( ROW_GROUP_NUM_L   ),
                       .COL_NUM         ( COL_NUM_L         ),
                       .COL_GROUP_NUM   ( COL_GROUP_NUM_L   ),
                       .WEIGHT_W        ( WEIGHT_W_L        ),
                       .BUFFER_ROW      ( BUFFER_ROW_L      )
                   ) u_NPU_core_large (
                       .clk_w             ( clk_w             ),
                       .clk_cim           ( clk_cim           ),
                       .rstn              ( rstn              ),
                       .din_valid         ( din_valid_L         ),
                       .NNIN              ( NNIN_L              ),
                       .WADR              ( WADR_L              ),
                       .WEB               ( WEB_L               ),
                       .MEB               ( MEB_L               ),
                       .fp_en             ( fp_en_L             ),
                       .E_most            ( E_most_L            ),
                       .WD_E              ( WD_E_L              ),
                       .WD_M              ( WD_M_L              ),
                       .buffer0_rst       ( buffer0_rst_L       ),
                       .buffer1_rst       ( buffer1_rst_L       ),
                       .compute_valid     ( compute_valid_L     ),
                       .CIMADR            ( CIMADR_L            ),
                       .sign_bit          ( sign_bit_L          ),
                       .adder_enb         ( adder_enb_L         ),
                       .buffer_row_addr   ( buffer_row_addr_L   ),
                       .outlier_sum       ( outlier_sum_L       ),
                       .dout_valid        ( dout_valid_L        ),
                       .data_out          ( data_out_L          ),
                       .CIM_compute_ready ( CIM_compute_ready_L )
                   );

    // NPU_core_small instantiation
    NPU_core_small #(
                       .Macro_ROW_NUM   ( Macro_ROW_NUM_S   ),
                       .ROW_NUM_2       ( ROW_NUM_2_S       ),
                       .ROW_NUM_4       ( ROW_NUM_4_S       ),
                       .GROUP_ROW_NUM   ( GROUP_ROW_NUM_S   ),
                       .ROW_GROUP_NUM   ( ROW_GROUP_NUM_S   ),
                       .COL_NUM         ( COL_NUM_S         ),
                       .COL_GROUP_NUM   ( COL_GROUP_NUM_S   ),
                       .WEIGHT_W        ( WEIGHT_W_S        ),
                       .BUFFER_ROW      ( BUFFER_ROW_S      )
                   ) u_NPU_core_small (
                       .clk_cim         ( clk_cim          ),
                       .clk_w           ( clk_w            ),
                       .rstn            ( rstn             ),
                       .din_valid       ( din_valid_S      ),
                       .NNIN_all        ( NNIN_all_S       ),
                       .combine_mode    ( combine_mode_S   ),
                       .NNIN_sel        ( NNIN_sel_S       ),
                       .WADR            ( WADR_S           ),
                       .WEB             ( WEB_S            ),
                       .MEB             ( MEB_S            ),
                       .fp_en           ( fp_en_S          ),
                       .E_most          ( E_most_S         ),
                       .WD_E            ( WD_E_S           ),
                       .WD_M            ( WD_M_S           ),
                       .buffer0_rst     ( buffer0_rst_S    ),
                       .buffer1_rst     ( buffer1_rst_S    ),
                       .compute_valid   ( compute_valid_S  ),
                       .full_NNIN       ( full_NNIN_S      ),
                       .CIMADR          ( CIMADR_S         ),
                       .sign_bit        ( sign_bit_S       ),
                       .adder_enb       ( adder_enb_S      ),
                       .buffer_row_addr ( buffer_row_addr_S),
                       .outlier_sum     ( outlier_sum_S    ),
                       .dout_valid      ( dout_valid_S     ),
                       .data_out        ( data_out_S       ),
                       .CIM_store_ready ( CIM_store_ready_S )
                   );
endmodule
