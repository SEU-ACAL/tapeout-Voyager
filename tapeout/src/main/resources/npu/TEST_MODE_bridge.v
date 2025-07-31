module TEST_MODE_bridge (
        //PAD input port
        input 				clk_FPGA_w,
        input 				clk_FPGA_cim,
        input 				rstn_FPGA,
        input  		 		PLL_CLK_SEL,					//0:original , 1:PLL_CLK
        input 				TEST_MODE,						//0:CPU  	 , 1:TEST_MODE
        // input				load_store_OEN,				//0:load 	 , 1:store			in PAD port
		//PAD output port
		output 				FPGA_sys_load_data_vld,
        //PAD port reuse
        input        	  	FPGA_sys_load_en,
        input  [16:0]	  	FPGA_sys_load_addr,
        output [63:0]  		FPGA_sys_load_data,

        input        	  	FPGA_sys_store_en,
        input  [16:0]	  	FPGA_sys_store_addr,
        input  [63:0]	  	FPGA_sys_store_data,

        //on-chip input port
        //TO PLL
        input 				clk_PLL_w,
        input 				clk_PLL_cim,
        //TO_AXI_bridge
        input 				clk_AXI,
		input				rstn_AXI,
        input        	  	AXI_sys_load_en,
        input  [16:0]	  	AXI_sys_load_addr,
        output [63:0]  		AXI_sys_load_data,

        input        	  	AXI_sys_store_en,
        input  [16:0]	  	AXI_sys_store_addr,
        input  [63:0]	  	AXI_sys_store_data,

        //TO_csr_ctrl
        input        	  	NPU_AXI_SEL,					//0:AXI use SRAM , 1:NPU use SRAM
        //To sys_top
        output reg			clk_w,
        output reg			clk_cim,
        output reg          clk_CSR,                        
        output 				rstn_NPU,

        output          	sys_load_en,
        output  [16:0]  	sys_load_addr,
        input   [63:0]  	sys_load_data,
		input				sys_load_data_vld,

        output          	sys_store_en,
        output  [16:0]  	sys_store_addr,
        output  [63:0]  	sys_store_data
    );

    assign rstn_NPU					 = ( TEST_MODE ) ? rstn_FPGA   			: rstn_AXI; // NPU reset is same as FPGA reset

    assign sys_load_en				 = ( TEST_MODE ) ? FPGA_sys_load_en	 	: AXI_sys_load_en;
    assign sys_load_addr			 = ( TEST_MODE ) ? FPGA_sys_load_addr	: AXI_sys_load_addr;
    assign FPGA_sys_load_data		 = ( TEST_MODE ) ? sys_load_data		: 'b0;
	assign FPGA_sys_load_data_vld	 = ( TEST_MODE ) ? sys_load_data_vld	: 'b0;
    assign AXI_sys_load_data		 = ( TEST_MODE ) ? 'b0					: sys_load_data;

    assign sys_store_en				 = ( TEST_MODE ) ? FPGA_sys_store_en   	: AXI_sys_store_en;
    assign sys_store_addr			 = ( TEST_MODE ) ? FPGA_sys_store_addr 	: AXI_sys_store_addr;
    assign sys_store_data			 = ( TEST_MODE ) ? FPGA_sys_store_data 	: AXI_sys_store_data;

	wire reset_async;
	assign reset_async				 = ( TEST_MODE ) ? !rstn_FPGA   		: !rstn_AXI;
    clk_selector u_clk_selector (
                     .clk_FPGA_w    ( clk_FPGA_w   ),
                     .clk_FPGA_cim  ( clk_FPGA_cim ),
                     .clk_PLL_w     ( clk_PLL_w    ),
                     .clk_PLL_cim   ( clk_PLL_cim  ),
                     .clk_AXI       ( clk_AXI      ),
                     .TEST_MODE     ( TEST_MODE    ),
                     .NPU_AXI_SEL   ( NPU_AXI_SEL  ),
                     .PLL_CLK_SEL   ( PLL_CLK_SEL  ),
					 .reset_async	( reset_async  ),
                     .clk_w         ( clk_w        ),
                     .clk_cim       ( clk_cim      ),
                     .clk_CSR       ( clk_CSR      )
                 );

endmodule


// module clk_selector (
//         input 				clk_FPGA_w,
//         input 				clk_FPGA_cim,
//         input 				clk_PLL_w,
//         input 				clk_PLL_cim,
//         input 				clk_AXI,
//         input 				TEST_MODE,						//0:CPU  	 , 1:TEST_MODE
//         input 				NPU_AXI_SEL,					//0:AXI use SRAM , 1:NPU use SRAM
//         input 				PLL_CLK_SEL,					//0:original , 1:PLL_CLK

//         output reg			clk_w,
//         output reg			clk_cim
//     );
//     always @(*) begin
//         if (TEST_MODE) begin
//             if (NPU_AXI_SEL) begin
//                 if (PLL_CLK_SEL) begin		//TEST_MODE		NPU		PLL_CLK
//                     clk_w		 = clk_PLL_w;
//                     clk_cim		 = clk_PLL_cim;
//                 end
//                 else begin					//TEST_MODE		NPU		FPGA_CLK
//                     clk_w		 = clk_FPGA_w;
//                     clk_cim		 = clk_FPGA_cim;
//                 end
//             end
//             else begin						//TEST_MODE		AXI		FPGA_CLK
//                 clk_w		 = clk_FPGA_w;
//                 clk_cim		 = clk_FPGA_w;
//             end
//         end


//         else begin
//             if (NPU_AXI_SEL) begin
//                 if (PLL_CLK_SEL) begin		//CPU			NPU		PLL_CLK
//                     clk_w		 = clk_PLL_w;
//                     clk_cim		 = clk_PLL_cim;
//                 end
//                 else begin					//CPU			NPU		FPGA_CLK
//                     clk_w		 = clk_FPGA_w;
//                     clk_cim		 = clk_FPGA_cim;
//                 end
//             end
//             else begin						//CPU			AXI		FPGA_CLK
//                 clk_w		 = clk_AXI;
//                 clk_cim		 = clk_AXI;
//             end
//         end

//     end

// endmodule
