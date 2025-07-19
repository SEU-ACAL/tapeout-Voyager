`include "defines.v"
module NPU_ctrl_large #(
        parameter Macro_ROW_NUM_L = 256
    )(
        input clk_w,
        input clk_cim,
        input rstn,
        input NPU_AXI_SEL,

        //from CSR
        input							start_en_L,
        input							fp_en_L,
		
        input	[3:0]					MAC_INPUT_ROW,
        input	[3:0]					MAC_LENGTH,			//MAX:6
        input	[3:0]					MAC_COL,		//MAX:6
        //MAC_LENGTH	*	MAC_COL	 <= 6
        //MAC_INPUT_ROW	*	MAC_COL	 <= 16
        input	[9:0]					FM_ADDR_START_L,
        input	[7:0]					last_CIMADR_L,
        input	[64*8-1:0]				E_most_L,

        //TO NPU_large_core
        output reg [7:0]                            	MEB_L,
        //CIM_coumpute port
        output reg 								 	NNIN_L,
        output reg                                  	din_valid_L,
        output reg 	                             	compute_valid_L,
        output reg [$clog2(Macro_ROW_NUM_L):0]      	CIMADR_L,
        output reg 	                             	adder_enb_L,
        output reg [3:0]                            	buffer_row_addr_L,
        //write_CIM port
        output reg [$clog2(Macro_ROW_NUM_L):0]      	WADR_L,					//add
        output reg  	                             	WEB_L,					//add
        // reg [64*8-1:0]                    	   E_most_L;
        output reg [64*8-1:0]                       	WD_E_L,
        output reg [64*8-1:0] 						 	WD_M_L,
        output reg 	                            	buffer1_rst_L,			//add
        output reg 	                            	buffer0_rst_L,
        //output
        input [32*8*8-1:0]                    	outlier_sum_L,
        input                             	 	outlier_out_valid_L,
        input [256*8-1:0]                     	data_out_L,
        input 								 	Macro_out_valid,

        //MEM ctrl
        output 										wml_npu_load_en_pre ,
        output [$clog2(`WM_Bank_DEPTH_L)-1:0]       wml_npu_load_addr   ,
        input [`WM_WIDTH *`WM_Bank_NUM -1:0]       	wml_npu_load_data   ,
        // input 								       	wml_npu_load_valid  ,

        output 										fml_npu_load_en_pre ,
        output [$clog2(`FM_Bank_DEPTH)-1:0]         fml_npu_load_addr   ,
        input [`FM_WIDTH *`FM_Bank_NUM -1:0]       	fml_npu_load_data   ,
        // input 								       	fml_npu_load_valid  ,

        output 										obl_npu_store_en_pre,
        output [$clog2(`OB_Bank_DEPTH)-1:0]         obl_npu_store_addr  ,
        output reg signed[`OB_WIDTH *`OB_Bank_NUM -1:0]    obl_npu_store_data
    );

    reg [3:0] 								MAC_INPUT_ROW_cnt;
    reg [3:0] 								MAC_LENGTH_cnt;
    reg [3:0] 								MAC_COL_cnt;

    //counter ctrl
    reg [2:0] 								bit_cyc_cnt;
    wire 									first_start;		//start singal pulse
    wire									write_ready;
    wire									cim_ready;
    wire 									ready;
    wire									last_en;

    //FM ctrl
    wire [$clog2(`FM_Bank_DEPTH)-1:0]       fml_npu_load_addr_next;
    reg 									fml_npu_load_valid  ;
    //WML ctrl
    reg [$clog2(Macro_ROW_NUM_L)-1:0] 		wm_addr_L;
    reg 									wm_addr_L_MSB;
    reg 								    wml_npu_load_valid  ;

    assign first_start = (MAC_INPUT_ROW_cnt == 0) && (MAC_LENGTH_cnt == 0) && (MAC_COL_cnt == 0) && start_en_L;
    assign ready = write_ready&cim_ready;
    assign last_en = MAC_LENGTH_cnt == MAC_LENGTH;

    always @(posedge clk_cim or negedge rstn) begin
        if(!rstn)
            fml_npu_load_valid <= 'b0;
        else
            fml_npu_load_valid <= NPU_AXI_SEL&fml_npu_load_en_pre;
    end
    always @(posedge clk_w or negedge rstn) begin
        if(!rstn)
            wml_npu_load_valid <= 'b0;
        else
            wml_npu_load_valid <= NPU_AXI_SEL&wml_npu_load_en_pre;
    end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            bit_cyc_cnt <= 0;
        else if (bit_cyc_cnt == 3'd7)
            bit_cyc_cnt <= 0;
        else if (bit_cyc_cnt == 3'd0) begin
            if ((fml_npu_load_valid) & ready)
                bit_cyc_cnt <= bit_cyc_cnt + 1'b1;
        end
        else
            bit_cyc_cnt <= bit_cyc_cnt + 1'b1;
    end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            MAC_INPUT_ROW_cnt <= 0;
        else if (bit_cyc_cnt == 3'd7)
            if (MAC_INPUT_ROW_cnt == MAC_INPUT_ROW) begin
                if(ready)
                    MAC_INPUT_ROW_cnt <= 'b0;
            end
            else
                MAC_INPUT_ROW_cnt <= MAC_INPUT_ROW_cnt + 1'b1;
    end

    always @(posedge clk_w or negedge rstn) begin
        if (!rstn)
            MAC_COL_cnt <= 0;
        else if (MAC_INPUT_ROW_cnt == MAC_INPUT_ROW)
            if (MAC_COL_cnt == MAC_COL) begin
                if(ready)
                    MAC_COL_cnt <= 'b0;
            end
            else
                MAC_COL_cnt <= MAC_COL_cnt + 1'b1;
    end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            MAC_LENGTH_cnt <= 0;
        else if (MAC_COL_cnt == MAC_COL)
            if (MAC_LENGTH_cnt == MAC_LENGTH) begin
                if(ready)
                    MAC_LENGTH_cnt <= 'b0;
            end
            else
                MAC_LENGTH_cnt <= MAC_LENGTH + 1'b1;
    end


    //FM ctrl
    assign fml_npu_load_en_pre		 =  ((bit_cyc_cnt == 3'd7)&MAC_INPUT_ROW_cnt < MAC_INPUT_ROW) | ((bit_cyc_cnt == 3'd7)&ready) | first_start;
    assign fml_npu_load_addr_next	 = FM_ADDR_START_L + MAC_LENGTH_cnt * MAC_INPUT_ROW + MAC_INPUT_ROW_cnt + 1'b1;
    assign fml_npu_load_addr		 = first_start? FM_ADDR_START_L: fml_npu_load_addr_next;
    assign cim_ready				 = MAC_INPUT_ROW_cnt == MAC_INPUT_ROW;



    //WML ctrl
    always @(posedge clk_w or negedge rstn) begin
        if(!rstn) begin
            wm_addr_L <= 'b0;
            wm_addr_L_MSB <= 1'b0;
        end
        else if(wm_addr_L == Macro_ROW_NUM_L) begin
            if(ready) begin
                wm_addr_L <= 'b0;
                wm_addr_L_MSB <= !wm_addr_L_MSB;
            end
        end
        else
            wm_addr_L <= wm_addr_L + 1'b1;
    end
    assign wml_npu_load_en_pre		 = ready  || wm_addr_L;
    assign wml_npu_load_addr		 = (MAC_LENGTH_cnt*MAC_COL + MAC_COL_cnt)+ wm_addr_L;
    assign write_ready				 = (wm_addr_L == Macro_ROW_NUM_L);


    //OBL ctrl
    assign obl_npu_store_en_pre	 = (MAC_LENGTH_cnt == MAC_LENGTH)&&Macro_out_valid;
    assign obl_npu_store_addr	 = MAC_INPUT_ROW_cnt*MAC_INPUT_ROW + MAC_COL_cnt;

    always @(*) begin
        MEB_L							 = {  8{((bit_cyc_cnt == 3'd7)&ready)}  };			//=7之后延迟1周期
        {WD_E_L, WD_M_L} 				 = wml_npu_load_data;
        NNIN_L							 = fp_en_L? fml_npu_load_data[`FM_WIDTH *`FM_Bank_NUM/2+:`FM_WIDTH *`FM_Bank_NUM/2]
                      : fml_npu_load_data[0+:`FM_WIDTH *`FM_Bank_NUM/2];
        din_valid_L						 = fml_npu_load_valid & ready;
        obl_npu_store_data				 = ($signed(outlier_sum_L)<<<8) + $signed(data_out_L);
        compute_valid_L					 = fml_npu_load_valid;

        CIMADR_L			 			 = {MAC_INPUT_ROW_cnt[0], last_en? last_CIMADR_L: {$clog2(Macro_ROW_NUM_L){1'b1}} };//要多延迟两个周期
        adder_enb_L						 = MAC_LENGTH_cnt > 'b0;						//延迟一cyc
        buffer_row_addr_L				 = MAC_INPUT_ROW_cnt*MAC_INPUT_ROW + MAC_COL_cnt;

        WADR_L							 = wm_addr_L;
        WEB_L							 = !MAC_INPUT_ROW_cnt[0];
        buffer0_rst_L					 = !MAC_INPUT_ROW_cnt[0]&outlier_out_valid_L;
        buffer1_rst_L					 = MAC_INPUT_ROW_cnt[0]&outlier_out_valid_L;
    end

endmodule
