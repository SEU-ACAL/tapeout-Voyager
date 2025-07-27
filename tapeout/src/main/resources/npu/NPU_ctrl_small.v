// `include "../gen-collateral/defines.v"
`include "../gen-collateral/defines.v"

module NPU_ctrl_small (
        input clk_w,
        input clk_cim,
        input rstn,
        input	[3:0]		MAC_INPUT_ROW,    // 代表复用当前权重的次数
        input	[3:0]		MAC_LENGTH,		  // MAX:6

        //from CSR
        input	[9:0]					FM_ADDR_START_S,
        input							start_en_S,
        input							fp_en_S,
        input	[64*4-1:0]				E_most_S,



        //to memory interface
        output 										wms_npu_load_en_pre ,
        output [$clog2(`WM_Bank_DEPTH_S)-1:0]       wms_npu_load_addr   ,
        input [`WM_WIDTH *`WM_Bank_NUM -1:0]       	wms_npu_load_data   , // 64*16 bit
        //input 								       	wms_npu_load_valid  ,

        output 										fms_npu_load_en_pre ,
        output [$clog2(`FM_Bank_DEPTH_S)-1:0]       fms_npu_load_addr   ,
        input [`FM_WIDTH *`FM_Bank_NUM_S -1:0]       	fms_npu_load_data   , // 64*64 bit = 4096
        //input 								       	fms_npu_load_valid  ,

        output 										obs_npu_store_en_pre,
        output [$clog2(`OB_Bank_DEPTH)-1:0]         obs_npu_store_addr  ,
        output  signed[`OB_WIDTH *`OB_Bank_NUM -1:0]    obs_npu_store_data,

        //to npu core
        output reg                     din_valid_S,
        output reg [32*8-1:0]          NNIN_E_S,
		output reg [32*8-1:0]          NNIN_M_S,
        output reg [5:0]               WADR_S,
        output reg [3:0]               WEB_S,
        output reg [3:0]               MEB_S,
        output reg [64*4-1:0]          WD_E_S,
        output reg [64*4-1:0]          WD_M_S,
        output reg 		               buffer1_rst_S,
        output reg 		               buffer0_rst_S,
        output reg [1:0]               CIMADR_S,
        output reg 			           adder_enb_S,
        output reg [3:0]               buffer_row_addr_S,
        input wire [32*8*4-1:0]        outlier_sum_S,
        input wire 		               outlier_out_valid_S,
        input wire [256*4-1:0]         data_out_S,
        input wire 		 	           Macro_out_valid_S
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

	reg wms_npu_load_valid;
	reg fms_npu_load_valid;

    assign first_start = (MAC_INPUT_ROW_cnt == 0) && (MAC_LENGTH_cnt == 0) && (MAC_COL_cnt == 0) && start_en_S;
    assign ready = write_ready & cim_ready; //ping-pong 计算/写入中需要等memory 1的权重写满和memory 2的权重复用结束才能开始写memory 2
    assign last_en = MAC_LENGTH_cnt == MAC_LENGTH;

	always @(posedge clk_w or negedge rstn) begin
    	if (!rstn) begin
        	wms_npu_load_valid <= 1'b0;
        	fms_npu_load_valid <= 1'b0;
    	end 
		else begin
        	wms_npu_load_valid <= wms_npu_load_en_pre;
        	fms_npu_load_valid <= fms_npu_load_en_pre;
    	end
	end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            bit_cyc_cnt <= 'd0;
        else if (bit_cyc_cnt == 3'd7)
            bit_cyc_cnt <= 'd0;
        else if (bit_cyc_cnt == 3'd0)
            bit_cyc_cnt <= bit_cyc_cnt + 1'b1;
        else
            bit_cyc_cnt <= bit_cyc_cnt + 1'b1;
    end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            MAC_INPUT_ROW_cnt <= 'd0;
        else if (bit_cyc_cnt == 3'd7)
            if (MAC_INPUT_ROW_cnt == MAC_INPUT_ROW-1) begin
                // if(ready)
                MAC_INPUT_ROW_cnt <= 'd0;
            end
            else
                MAC_INPUT_ROW_cnt <= MAC_INPUT_ROW_cnt + 1'b1;
    end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            MAC_LENGTH_cnt <= 'd0;
        else if (bit_cyc_cnt == 3'd7 && MAC_INPUT_ROW_cnt == MAC_INPUT_ROW-1)
            if (MAC_LENGTH_cnt == MAC_LENGTH) begin
                // if(ready)
                MAC_LENGTH_cnt <= 'd0;
            end
            else
                MAC_LENGTH_cnt <= MAC_LENGTH + 1'b1;
    end


    //FM ctrl
    wire [$clog2(`FM_Bank_DEPTH_S)-1:0]         fms_npu_load_addr_next;

    assign fms_npu_load_en_pre		 = ((bit_cyc_cnt == 3'd7)& (MAC_INPUT_ROW_cnt < MAC_INPUT_ROW) ) | ((bit_cyc_cnt == 3'd7)&ready) | first_start;
    assign fms_npu_load_addr_next	 = FM_ADDR_START_S + MAC_LENGTH_cnt * MAC_INPUT_ROW + MAC_INPUT_ROW_cnt + 1'b1;
    assign fms_npu_load_addr		 = first_start ? FM_ADDR_START_S: fms_npu_load_addr_next;
    assign cim_ready				 = MAC_INPUT_ROW_cnt == MAC_INPUT_ROW;  // 复用结束


    //WML ctrl
    reg [$clog2(Macro_ROW_NUM_S)-1:0] 	wm_addr_S;
    reg 								wm_addr_S_MSB;
	always @(posedge clk_w or negedge rstn) begin
		if(!rstn) begin
			wm_addr_S <= 'b0;
			wm_addr_S_MSB <= 1'b0;
		end
		else if(wm_addr_S == Macro_ROW_NUM_S-1) begin
			wm_addr_S <= wm_addr_S + 1'b1;
			wm_addr_S_MSB <= !wm_addr_S_MSB;
		end
	end
    assign wms_npu_load_en_pre		 =  ready || wm_addr_S;

    assign wms_npu_load_addr		 = MAC_LENGTH_cnt * 32 + wm_addr_S;
    assign write_ready				 = (wm_addr_S == Macro_ROW_NUM_S-1);  // 一块memory写满

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
    assign obs_npu_store_en_pre	 = (MAC_LENGTH_cnt == MAC_LENGTH) && Macro_out_valid_S;
    assign obs_npu_store_addr	 = MAC_INPUT_ROW_cnt;
    genvar i;
    generate
		for (i = 0; i < 32; i = i + 1) begin : gen_obs_add
            wire signed [31:0] sum_in_1 = outlier_sum_S[i*32 +: 32];
            wire signed [31:0] sum_in_2 = data_out_S[i*32 +: 32];
            wire signed [31:0] sum_res = (sum_in_1 <<< 8) + sum_in_2;

            assign obs_npu_store_data[i*32 +: 32] = sum_res;
        end
    endgenerate

    always @(*) begin
        MEB_S				= {  4{((bit_cyc_cnt == 3'd7) & cim_ready)}  }; // =7说明8bit的feature全部传输完毕，之后延迟1周期
        {WD_E_S, WD_M_S} 	= wms_npu_load_data;
        NNIN_E_S			= fms_npu_load_data[`FM_WIDTH *`FM_Bank_NUM_S/2	+:`FM_WIDTH *`FM_Bank_NUM_S/2];
        NNIN_M_S			= fms_npu_load_data[0							+:`FM_WIDTH *`FM_Bank_NUM_S/2];
        din_valid_S			= fms_npu_load_valid & ready;
        //************************************************************//
        //有问题，需要后面修改
        // obs_npu_store_data				 = ($signed(outlier_sum_S)<<<8) + $signed(data_out_S); // outlier的位权比尾数高
        //************************************************************//
        CIMADR_S			= 'b0;
        adder_enb_S			= {{!(MAC_LENGTH_cnt > 'b0)}};						//延迟一cyc
        buffer_row_addr_S	= MAC_INPUT_ROW_cnt;
        WADR_S				= wm_addr_S;
        WEB_S               = { 4{!wms_npu_load_en_pre}};
        buffer0_rst_S		= { {(wm_addr_S == Macro_ROW_NUM_S) & ready} } | (buffer1_rst_S & ~adder_enb_S);
        buffer1_rst_S		= { {(wm_addr_S == Macro_ROW_NUM_S) & ready} };
    end


endmodule
