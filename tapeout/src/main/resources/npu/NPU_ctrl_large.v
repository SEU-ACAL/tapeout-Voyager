// `include "../0-RTL/AXI_SLAVE/defines.v"
`include "../gen-collateral/defines.v"

module NPU_ctrl_large #(
        parameter Macro_ROW_NUM_L = 256
    )(
        input  clk_w,
        input  clk_cim,
        input  rstn,
        input  NPU_AXI_SEL,

        // from CSR
        // shared
        input                      start_en_L,				//start singal pulse，外部脉冲，仅脉冲一次，标志启动
        input                      fp_en_L,
        // private
        input      [4:0]           MAC_INPUT_ROW,
        input      [4:0]           MAC_LENGTH,
        input      [9:0]           FM_ADDR_START_L,
        input      [7:0]           last_CIMADR_L,
        input      [64*4*6-1:0]    E_most_L,
        // add CSR
        input      [3:0]           CSR_MEB_L,

        // TO NPU_large_core
        output reg                                  din_valid_L,
        output reg [Macro_ROW_NUM_L*8-1:0]          NNIN_E_L,
        output reg [Macro_ROW_NUM_L*8-1:0]          NNIN_M_L,
        output reg [$clog2(Macro_ROW_NUM_L):0]      WADR_L,
        output reg [3:0]                            WEB_L,
        output reg [3:0]                            MEB_L,
        output reg [64*4-1:0]                       WD_E_L,
        output reg [64*4-1:0]                       WD_M_L,
        output reg [$clog2(Macro_ROW_NUM_L):0]      CIMADR_L,
        output reg [3:0]                            buffer_row_addr_L,
        output reg                                  buffer1_rst_L,      // add
        output reg                                  buffer0_rst_L,
        output reg                                  adder_enb_L,
        output reg                                  compute_valid_L,
		output reg [64*4-1:0]    					E_most_L_core,

        // output
        // input  [32*8*4-1:0]                         outlier_sum_L,
        // input                                       outlier_out_valid_L,
        input  [256*4-1:0]                          data_out_L,
        input                                       Macro_out_valid,

        // MEM ctrl
        output                                      wml_npu_load_en_pre,
        output [$clog2(`WM_Bank_DEPTH_L)-1:0]       wml_npu_load_addr,
        input  [`WM_WIDTH *`WM_Bank_NUM -1:0]       wml_npu_load_data,

        output                                      fml_npu_load_en_pre,
        output [$clog2(`FM_Bank_DEPTH_L)-1:0]       fml_npu_load_addr,
        input  [`FM_WIDTH *`FM_Bank_NUM_L -1:0]     fml_npu_load_data,

        output                                      obl_npu_store_en_pre,
        output reg[$clog2(`OB_Bank_DEPTH)-1:0]      obl_npu_store_addr,
        output signed[`OB_WIDTH *`OB_Bank_NUM -1:0] obl_npu_store_data
    );

    //counter ctrl
    reg [2:0] 								bit_cyc_cnt;
    reg [4:0] 								MAC_INPUT_ROW_cnt;
    reg [4:0] 								MAC_LENGTH_cnt;
    reg [4:0] 								WRITE_LENGTH_cnt;

    //辅助信号定义
    wire 									st_cim_pl;
    reg 									st_cim;				//辅助信号，用于产生开始计算脉冲
    reg 									st_cim_d1;
    wire 									first_start;		//start singal pulse，外部脉冲，仅脉冲一次，标志计算启动
    reg 									first_start_d;
    reg										first_end;

    wire 									st_write_pl;
    reg										st_write;			//辅助信号，用于产生开始write cim脉冲
    reg 									st_write_d1;
    wire									last_en;			//标志MAC_LENGTH_cnt == MAC_LENGTH，表示这一次算完后所有的计算都完成了
    wire 									last_en_write;
    wire 									write_cim_en;

    wire									cim_ready;
    reg								 		cim_ready_d1;
    wire									cim_ready_cdc;
    wire									write_ready;
    reg										write_ready_d1;
    reg										write_ready_d2;
    wire									write_ready_cdc;

    wire 									NNIN_mux;			//此信号会影响fms_npu_load_addr和fms_npu_load_data,INT8mode下，存NNIN_E_L和NNIN_M_L的BANK交替加载,都用来存储feature
    // reg 									NNIN_mux_d;
    wire 									WD_mux;				//此信号会影响wms_npu_load_addr和wms_npu_load_data,INT8mode下，存WD_E_L和WD_M_L的BANK交替加载,都用来存储weight
    reg 									WD_mux_d;

    reg 									CIMADR_L_MSB;
    reg 									CIMADR_L_MSB_d1;
    wire[$clog2(Macro_ROW_NUM_L)-1:0] 		CIMADR_L_LSB;
    reg 									WADR_L_MSB;
    reg [$clog2(Macro_ROW_NUM_L)-1:0]		WADR_L_LSB;
	reg [$clog2(Macro_ROW_NUM_L)-1:0]		WADR_L_LSB_d1;

    //FM ctrl
    wire [$clog2(`FM_Bank_DEPTH_L)-1:0]     fml_npu_load_addr_next;
    reg 									fml_npu_load_valid  ;
    //WML ctrl
    // reg										wm_addr_L_MSB;		//同NNIN_mux，WD_mux作用一样，存INT8mode下，WADR_L的BANK交替加载
    reg [$clog2(Macro_ROW_NUM_L)-1:0] 		wm_addr_L;				//上述功能修改至此，直接增加1bit位宽//7.24不增加位宽了，直接/2就是wm的地址
    reg [$clog2(`WM_Bank_DEPTH_L):0]      	wml_npu_load_addr_reg;
    reg 								    wml_npu_load_valid  ;


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
            bit_cyc_cnt <= 'd0;
        else if (bit_cyc_cnt == 'd7) begin
            if(MAC_INPUT_ROW_cnt == MAC_INPUT_ROW) begin
                if( (write_ready_cdc | first_end) & !last_en )							//input_row算完了，bit_cyc算完，写cim ready，计数器归零
                    bit_cyc_cnt <= 'd0;
            end
            else
                bit_cyc_cnt <= 'd0;
        end
        else begin
            if(st_cim_d1)
                bit_cyc_cnt <= bit_cyc_cnt + 1'b1;
        end
    end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            MAC_INPUT_ROW_cnt <= 'd0;
        else if (bit_cyc_cnt == 3'd7) begin
            if (MAC_INPUT_ROW_cnt == MAC_INPUT_ROW) begin
                if( (write_ready_cdc | first_end) & !last_en )								//第一次算完不需要write_ready_cdc，直接归零，MAC_LENGTH_cnt == 'd0即为第一次算完
                    MAC_INPUT_ROW_cnt <= 'd0;
            end
            else
                MAC_INPUT_ROW_cnt <= MAC_INPUT_ROW_cnt + 1'b1;
        end
    end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            MAC_LENGTH_cnt <= 'd0;
        else if (cim_ready & (write_ready_cdc|first_end) & !last_en)
            MAC_LENGTH_cnt <= MAC_LENGTH_cnt + 1'b1;
    end


    //FM ctrl
    wire [4:0]     FA_offset;

    assign FA_offset = fp_en_L?	 MAC_LENGTH_cnt * (MAC_INPUT_ROW+1'b1) + MAC_INPUT_ROW_cnt+ 1'b1
           :   					(MAC_LENGTH_cnt * (MAC_INPUT_ROW+1'b1) + MAC_INPUT_ROW_cnt+ 1'b1)>>1;													//INT8 mode下，两周期地址一变
    assign fml_npu_load_en_pre		 = (bit_cyc_cnt == 3'd7 | first_start | cim_ready&write_ready_cdc) && (MAC_INPUT_ROW_cnt < MAC_INPUT_ROW||MAC_LENGTH_cnt < MAC_LENGTH);		//三种情况：1）input_row没算完  2）第一次启动  3）input_row算完了，write_ready_cdc和cim_ready都为1
    assign fml_npu_load_addr_next	 = FM_ADDR_START_L + FA_offset;
    assign fml_npu_load_addr		 = first_start? FM_ADDR_START_L: fml_npu_load_addr_next;
    assign cim_ready				 = (bit_cyc_cnt == 3'd7) && (MAC_INPUT_ROW_cnt == MAC_INPUT_ROW);



    //WML ctrl
    always @(posedge clk_w or negedge rstn) begin
        if(!rstn)
            wm_addr_L <= 'b0;
        else if( wm_addr_L == Macro_ROW_NUM_L-1) begin
            if(cim_ready_cdc && !last_en_write)
                wm_addr_L <= wm_addr_L + 1'b1;
        end
        else begin
            if(st_write)							//在clk_cim时钟域拉高后恒为1，所以跨时钟域没关系
                wm_addr_L <= wm_addr_L + 1'b1;
        end
    end
    always @(posedge clk_w or negedge rstn) begin
        if(!rstn)
            WRITE_LENGTH_cnt <= 'b0;
        else if(wm_addr_L == Macro_ROW_NUM_L-1 && cim_ready_cdc && !last_en_write)
            WRITE_LENGTH_cnt <= WRITE_LENGTH_cnt + 1'b1;
    end
    always @(posedge clk_w or negedge rstn) begin
        if(!rstn)
            wml_npu_load_addr_reg <= 'b0;
        else if( wm_addr_L == Macro_ROW_NUM_L-1) begin
            if(cim_ready_cdc && !last_en_write)
                wml_npu_load_addr_reg <= wml_npu_load_addr_reg + 1'b1;
        end
        else begin
            if(st_write)							//在clk_cim时钟域拉高后恒为1，所以跨时钟域没关系
                wml_npu_load_addr_reg <= wml_npu_load_addr_reg + 1'b1;
        end
    end
    assign wml_npu_load_en_pre	 = (!(WADR_L_LSB==wm_addr_L) | st_write_pl) && st_write;
    assign wml_npu_load_addr	 = fp_en_L ? wml_npu_load_addr_reg[9:0] : wml_npu_load_addr_reg[10:1];			//两种模式下选择wml的地址，INT8mode下，两周期选一次地址
    assign write_ready			 = wm_addr_L == Macro_ROW_NUM_L-1;

    //OBL ctrl
    assign obl_npu_store_en_pre	 = Macro_out_valid;						//每一次INT8xINT8都存下来，存中间结果方便测试
    assign obl_npu_store_data	 = data_out_L;
    always @(posedge clk_cim or negedge rstn) begin						//cim时钟域
        if (!rstn)
            obl_npu_store_addr <= 'd0;
        else begin
            if(Macro_out_valid)
                obl_npu_store_addr <= obl_npu_store_addr + 1'b1;		//obl结果有延迟，NPU出结果,已经在下一周期，需要打拍保持住
        end
    end
    // assign obl_npu_store_addr	 = MAC_LENGTH_cnt*(MAC_INPUT_ROW+1'b1) + MAC_INPUT_ROW_cnt;		//obl结果有延迟，NPU出结果,已经在下一周期，需要打拍保持住


    //*********************************Macro ctrl port*************************************//
    assign CIMADR_L_LSB = !(cim_ready&cim_ready_d1)? (last_en? last_CIMADR_L: 8'hff) : 'd0;
    always @(*) begin
        NNIN_E_L			= fp_en_L	? fml_npu_load_data[`FM_WIDTH *`FM_Bank_NUM_L/2	+:`FM_WIDTH *`FM_Bank_NUM_L/2]: 'b0;
        NNIN_M_L			= NNIN_mux	? fml_npu_load_data[`FM_WIDTH *`FM_Bank_NUM_L/2 +:`FM_WIDTH *`FM_Bank_NUM_L/2]: fml_npu_load_data[0 +:`FM_WIDTH *`FM_Bank_NUM_L/2];
        WD_E_L				= fp_en_L	? wml_npu_load_data[`WM_WIDTH *`WM_Bank_NUM/2   +:`WM_WIDTH *`WM_Bank_NUM/2]  : 'b0;
        WD_M_L				= WD_mux	? wml_npu_load_data[`WM_WIDTH *`WM_Bank_NUM/2   +:`WM_WIDTH *`WM_Bank_NUM/2]  : wml_npu_load_data[0 +:`WM_WIDTH *`WM_Bank_NUM/2];
        din_valid_L			= !fml_npu_load_en_pre&fml_npu_load_valid;
        compute_valid_L		= fp_en_L	? din_valid_L : 'b0;

        CIMADR_L			= {CIMADR_L_MSB, CIMADR_L_LSB };				//高bit反转后需要延迟一周期在开始计算，cdl行为与行为及模型不一样,后续再说
        adder_enb_L			= MAC_LENGTH_cnt == 'b0;						//cyc有延迟**********此处采用macro内采样
        buffer_row_addr_L	= MAC_INPUT_ROW_cnt;							//cyc有延迟**********此处采用macro内采样

        WADR_L				= {WADR_L_MSB, WADR_L_LSB};
        WEB_L				= {4{!wml_npu_load_valid}} | CSR_MEB_L;			//写完没算完要关闭,通过利用写完没算完wml_npu_load_en不使能，wml_npu_load_valid无效
        buffer0_rst_L		= !CIMADR_L_MSB&!CIMADR_L_MSB_d1&cim_ready;
        buffer1_rst_L		= CIMADR_L_MSB&CIMADR_L_MSB_d1&cim_ready;
		E_most_L_core		= E_most_L[64*4*MAC_LENGTH_cnt +:64*4];
    end

    //设置CSR_MEB目的是：当计算到矩阵乘边缘时，不一定所有的CIM都需要使用  //MEB初始赋值后不变，CIM计算用CIMADR操作，write CIM不受该信号控制
    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            MEB_L <= 4'hf;
        else begin
            if(start_en_L)
                MEB_L <= CSR_MEB_L;
        end
    end
    //INPUT_ROW算完之后就翻转，初始值为0
    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            CIMADR_L_MSB <= 'd0;
        else begin
            if(cim_ready&!cim_ready_d1)
                CIMADR_L_MSB <= !CIMADR_L_MSB;
        end
    end
    // CIMADR_L_MSB 打一拍
    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            CIMADR_L_MSB_d1 <= 'd0;
        else begin
            if(bit_cyc_cnt == 'd0)
                CIMADR_L_MSB_d1 <= CIMADR_L_MSB;
        end
    end
    // WADR_L_LSB 是 wm_addr_L 的延迟一周期
    always @(posedge clk_w or negedge rstn) begin
        if (!rstn)
            WADR_L_LSB <= 'd0;
        else
            WADR_L_LSB <= wm_addr_L;
    end
    // WADR_L_LSB_d1 是 WADR_L_LSB 打一拍
    always @(posedge clk_w or negedge rstn) begin
        if (!rstn)
            WADR_L_LSB_d1 <= 'd0;
        else
            WADR_L_LSB_d1 <= WADR_L_LSB;
    end
    //WADR_MSB存满之后就翻转，初始值为0
    always @(posedge clk_w or negedge rstn) begin
        if (!rstn)
            WADR_L_MSB <= 'd0;
        else begin
            if(WADR_L_LSB == Macro_ROW_NUM_L-1 && !(WADR_L_LSB_d1 == Macro_ROW_NUM_L-1) && !last_en_write)
                WADR_L_MSB <= !WADR_L_MSB;
        end
    end

    //*********************************辅助信号*************************************//
    assign first_start	 = (MAC_INPUT_ROW_cnt == 0) && (MAC_LENGTH_cnt == 0) && st_cim_pl;			//start singal pulse，外部脉冲，仅脉冲一次，标志启动
    assign last_en		 = MAC_LENGTH_cnt == MAC_LENGTH;											//标志这一次算完后所有的计算都完成了
    assign last_en_write = WRITE_LENGTH_cnt == (MAC_LENGTH>'d2 ? MAC_LENGTH-'d2 : 1'b0);			//标志这一次写完后所有的写操作都完成了
    assign write_cim_en  = MAC_LENGTH>'d1 ? 1'b1: 1'b0;

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            first_start_d <= 1'b0;
        else
            first_start_d <= first_start;
    end

    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            first_end <= 1'b0;
        else begin
            if(cim_ready & (MAC_LENGTH_cnt == 0))
                first_end <= 1'b1;		//第一次算完后，first_end拉高
            else
                first_end <= 1'b0;		//第二次开始后，first_end归0
        end
    end

    //起始信号产生
    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn) begin
            st_cim    <= 1'b0;
            st_cim_d1 <= 1'b0;
        end
        else begin
            if(start_en_L)				//被采样信号保持恒1，不会出问题
                st_cim    <= 1'b1;      // 对原始信号采样,恒1的逻辑，作用于计数器的第一次0 - 1转换
            st_cim_d1 <= st_cim;          // 对原始信号打一拍
        end
    end
    always @(posedge clk_w or negedge rstn) begin
        if (!rstn) begin
            st_write    <= 1'b0;
            st_write_d1 <= 1'b0;
        end
        else begin
            if(cim_ready & (MAC_LENGTH_cnt == 0) & write_cim_en)		//这里采样会不会有问题，被采样信号仅一周期
                st_write    <= 1'b1;
            st_write_d1 <= st_write;
        end
    end
    assign st_cim_pl = st_cim & ~st_cim_d1;  // 检测上升沿，生成1周期脉冲,此时两个信号都从CSR域转换到cim域，仅产生1周期，作用于fm和wm的第一次load使能
    assign st_write_pl = st_write & ~st_write_d1;





    // NNIN_mux 打拍，用 clk_cim      // WD_mux 打拍，用 clk_w 		//和SRAM地址一样，需要打拍模拟SRAM输出延迟
    // always @(posedge clk_cim or negedge rstn) begin
    //     if (!rstn)
    //         NNIN_mux_d <= 1'b0;
    //     else
    //         NNIN_mux_d <= MAC_INPUT_ROW_cnt[0];
    // end
    always @(posedge clk_w or negedge rstn) begin
        if (!rstn)
            WD_mux_d <= 1'b0;
        else
            WD_mux_d <= fp_en_L ? 1'b0 : wm_addr_L[0];
    end
    assign NNIN_mux = fp_en_L ? 1'b0 : MAC_INPUT_ROW_cnt[0];				//fe_en_L为1时, 浮点模式，mux恒0
    assign WD_mux = fp_en_L ? 1'b0 : WD_mux_d;





    //cim_ready打两拍做CDC
    always @(posedge clk_cim or negedge rstn) begin
        if (!rstn)
            cim_ready_d1 <= 1'b0;
        else
            cim_ready_d1 <= cim_ready;
    end
    //write_ready打两拍做CDC
    always @(posedge clk_w or negedge rstn) begin
        if (!rstn) begin
            write_ready_d1 <= 1'b0;
            write_ready_d2 <= 1'b0;
        end
        else begin
            write_ready_d1 <= write_ready;
            write_ready_d2 <= write_ready_d1;
        end
    end
    assign cim_ready_cdc = cim_ready_d1 | cim_ready;
    assign write_ready_cdc = write_ready_d2 | write_ready_d1 | write_ready;


endmodule


//1.算完清零逻辑				直接AXI写rstn得了
//2.CIMADR_MSB/WADR_MSB翻转打拍逻辑（cdl与行为及模型不符合）
