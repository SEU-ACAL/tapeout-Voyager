`include "defines.v"
module NPU_ctrl_small (
        input clk_w,
        input clk_cim,
        input rstn,
        input	[3:0]		MAC_INPUT_ROW,    // 代表复用当前权重的次数
        input	[3:0]		MAC_LENGTH,		  // MAX:6
        input	[3:0]		MAC_COL,		  // MAX:6
        //MAC_LENGTH	*	MAC_COL	 <= 6
        //MAC_INPUT_ROW	*	MAC_COL	 <= 16

        //from CSR
        input	[9:0]					FM_ADDR_START_S,
        input							start_en_S,
        input							fp_en_S,
		input	[$clog2(32)-1:0]		last_CIMADR_S,
		input	[64*8-1:0]				E_most_S,
        input   [1:0]                   combine_mode,
        input   [2:0]                   NNIN_sel,            


        //to memory interface 
        output 										wms_npu_load_en_pre ,
        output [$clog2(`WM_Bank_DEPTH_L)-1:0]       wms_npu_load_addr   ,
        input [`WM_WIDTH *`WM_Bank_NUM -1:0]       	wms_npu_load_data   , // 64*16 bit
        input 								       	wms_npu_load_valid  ,

        output 										fms_npu_load_en_pre ,
        output [$clog2(`FM_Bank_DEPTH)-1:0]         fms_npu_load_addr   ,
        input [`FM_WIDTH *`FM_Bank_NUM -1:0]       	fms_npu_load_data   , // 64*64 bit = 4096
        input 								       	fms_npu_load_valid  ,

        output 										obs_npu_store_en_pre,
        output [$clog2(`OB_Bank_DEPTH)-1:0]         obs_npu_store_addr  ,
        output reg signed[`OB_WIDTH *`OB_Bank_NUM -1:0]    obs_npu_store_data,

        //to npu core
        output reg                     din_valid_S,
        output reg [32*8*8*2-1:0]      NNIN_S,
        output reg [5:0]               WADR_S,
        output reg [7:0]               WEB_S,
        output reg [7:0]               MEB_S,
        output reg [64*8-1:0]          WD_E_S,
        output reg [64*8-1:0]          WD_M_S,
        output reg [7:0]               buffer1_rst_S,
        output reg [7:0]               buffer0_rst_S,
        output reg [1:0]               CIMADR_S,
        output reg [7:0]	           adder_enb_S,
        output reg [3:0]               buffer_row_addr_S,
        output wire [32*8*8-1:0]       outlier_sum_S,
        output wire                    outlier_out_valid_S,
        output wire [256*8-1:0]        data_out_S,
        output wire 				   Macro_out_valid
    );

    localparam Macro_ROW_NUM_S    = 32;
    localparam ROW_NUM_2_S        = 16;
    localparam ROW_NUM_4_S        = 4;
    localparam GROUP_ROW_NUM_S    = 32;
    localparam ROW_GROUP_NUM_S    = 1;
    localparam COL_NUM_S          = 64;
    localparam COL_GROUP_NUM_S    = 8;
    localparam WEIGHT_W_S         = 8;
    localparam BUFFER_ROW_S       = 16;

    // reg [7:0]                             MEB_S;
    // //CIM_coumpute port
	// reg 								  NNIN_S;
    // reg                                   din_valid_S;
    // reg [1:0]                             CIMADR_S;
    // reg 	                              adder_enb_S;
    // reg [3:0]                             buffer_row_addr_S;
    // //write_CIM port
    // reg [$clog2(Macro_ROW_NUM_S):0]       WADR_S;					//add
    // reg  	                              WEB_S;					//add
    // // reg [64*8-1:0]                        E_most_L;
    // reg [64*8-1:0]                        WD_E_S;
    // reg [64*8-1:0] 						  WD_M_S;
    // reg [7:0]                             buffer1_rst_S;			//add
    // reg [7:0]                             buffer0_rst_S;
    // //output
    // wire [32*8*8-1:0]                     outlier_sum_S;
    // wire                             	  outlier_out_valid_S;
    // wire [256*8-1:0]                      data_out_S;
	// wire 								  Macro_out_valid;

    reg [3:0] 			MAC_INPUT_ROW_cnt;  //0~15
    reg [3:0] 			MAC_LENGTH_cnt;     //0~15
    reg [3:0] 			MAC_COL_cnt;        //0~15

    //counter ctrl
    reg [2:0] 	bit_cyc_cnt;
    wire 		first_start;		//start singal pulse
    wire		write_ready;
    wire		cim_ready;
    wire 		ready;
	wire		last_en;

    assign first_start = (MAC_INPUT_ROW_cnt == 0) && (MAC_LENGTH_cnt == 0) && (MAC_COL_cnt == 0) && start_en_S;
    assign ready = write_ready & cim_ready; //ping-pong 计算/写入中需要等memory 1的权重写满和memory 2的权重复用结束才能开始写memory 2
	assign last_en = MAC_LENGTH_cnt == MAC_LENGTH;

    //input feature的8bit传输
    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            bit_cyc_cnt <= 0;
        else if (bit_cyc_cnt == 3'd7)
            bit_cyc_cnt <= 0;
        else if (bit_cyc_cnt == 3'd0) begin
            if ((fms_npu_load_valid) & ready)
                bit_cyc_cnt <= bit_cyc_cnt + 1'b1;
        end
        else
            bit_cyc_cnt <= bit_cyc_cnt + 1'b1;
    end

    always @(posedge clk_cim or negedge rstn) begin   //clk_cim
        if (!rstn)
            MAC_INPUT_ROW_cnt <= 0;
        else if (bit_cyc_cnt == 3'd7) begin   
            if (MAC_INPUT_ROW_cnt == MAC_INPUT_ROW)
                if(ready)
                    MAC_INPUT_ROW_cnt <= 'b0;
            else
                MAC_INPUT_ROW_cnt <= MAC_INPUT_ROW_cnt + 1'b1;
        end
    end

    // always @(posedge clk_w or negedge rstn) begin    //clk_w
    //     if (!rstn)
    //         MAC_COL_cnt <= 0; 
    //     else if ((MAC_INPUT_ROW_cnt == MAC_INPUT_ROW) & ready) begin 
    //         if (MAC_COL_cnt == MAC_COL)
    //             MAC_COL_cnt <= 'b0;
    //         else
    //             MAC_COL_cnt <= MAC_COL_cnt + 1'b1;
    //     end
    // end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            MAC_LENGTH_cnt <= 0;
        // else if (MAC_COL_cnt == MAC_COL) begin
        else if ((MAC_INPUT_ROW_cnt == MAC_INPUT_ROW) & ready) begin
            if ((MAC_LENGTH_cnt == MAC_LENGTH))
                if(ready)
                    MAC_LENGTH_cnt <= 'b0;
            else
                MAC_LENGTH_cnt <= MAC_LENGTH + 1'b1;
        end
    end


    //FM ctrl
    wire [$clog2(`FM_Bank_DEPTH)-1:0]         fms_npu_load_addr_next;

    assign fms_npu_load_en_pre		 = ((bit_cyc_cnt == 3'd7)& (MAC_INPUT_ROW_cnt < MAC_INPUT_ROW) ) | ((bit_cyc_cnt == 3'd7)&ready) | first_start;
    assign fms_npu_load_addr_next	 = FM_ADDR_START_S + MAC_LENGTH_cnt * MAC_INPUT_ROW + MAC_INPUT_ROW_cnt + 1'b1;
    assign fms_npu_load_addr		 = first_start ? FM_ADDR_START_S: fms_npu_load_addr_next;
    assign cim_ready				 = MAC_INPUT_ROW_cnt == MAC_INPUT_ROW;  // 复用结束

	
    //WML ctrl
    reg [$clog2(Macro_ROW_NUM_S)-1:0] 	wm_addr_S;
	reg 								wm_addr_S_MSB;
    always @(posedge clk_w or negedge rstn) begin
        if(!rstn)begin			
			wm_addr_S <= 'b0;
			wm_addr_S_MSB <= 1'b0;
		end
        else if(wm_addr_S == Macro_ROW_NUM_S) begin 	
            if(ready) begin
                wm_addr_S <= 'b0;
                wm_addr_S_MSB <= !wm_addr_S_MSB; //写满macro之后，换另一块ping-pong memory写
            end
		end
        else
            wm_addr_S <= wm_addr_S + 1'b1;
    end
    assign wms_npu_load_en_pre		 =  ready || wm_addr_S;
    
    assign wms_npu_load_addr		 = MAC_LENGTH_cnt * 32 + wm_addr_S;
    assign write_ready				 = (wm_addr_S == Macro_ROW_NUM_S);  // 一块memory写满

    reg               CIMADR_MSB;
    always @(posedge clk_cim or negedge rstn) begin
        if(!rstn) begin
            CIMADR_MSB <= ~WADR_S[$clog2(Macro_ROW_NUM_S)];
        end
        else if(ready) begin
            CIMADR_MSB <= ~CIMADR_MSB;
        end
    end


    //OBL ctrl
    //仅当达到最后一轮MAC长度并有有效输出时，才写入输出缓冲
    assign obs_npu_store_en_pre	 = (MAC_LENGTH_cnt == MAC_LENGTH) && Macro_out_valid;
    assign obs_npu_store_addr	 = MAC_INPUT_ROW_cnt;

    always @(*) begin
		MEB_S							 = {  8{((bit_cyc_cnt == 3'd7) & cim_ready)}  }; // =7说明8bit的feature全部传输完毕，之后延迟1周期
        {WD_E_S, WD_M_S} 				 = wms_npu_load_data;
        NNIN_S							 = fms_npu_load_data;
		din_valid_S						 = fms_npu_load_valid & ready;
        obs_npu_store_data				 = ($signed(outlier_sum_S)<<<8) + $signed(data_out_S); // outlier的位权比尾数高
		// compute_valid_S					 = MEB_S;
		CIMADR_S			 			 = {CIMADR_MSB, (fms_npu_load_valid | bit_cyc_cnt)}; 
		adder_enb_S						 = {8{!(MAC_LENGTH_cnt > 'b0)}};						//延迟一cyc
		buffer_row_addr_S				 = MAC_INPUT_ROW_cnt;

		WADR_S							 = wm_addr_S;
        WEB_S                            = { 8{!wms_npu_load_en_pre}};
		//WEB_S							 = { 8{(wm_addr_S == Macro_ROW_NUM_S) & ready} };
        
		buffer0_rst_S					 = { 8{(wm_addr_S == Macro_ROW_NUM_S) & ready} } | (buffer1_rst_S & ~adder_enb_S);
		buffer1_rst_S					 = { 8{(wm_addr_S == Macro_ROW_NUM_S) & ready} };
    end

endmodule
