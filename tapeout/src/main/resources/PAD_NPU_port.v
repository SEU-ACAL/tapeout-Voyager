module PAD_NPU_port (
        //Receiver PAD port
        input 				PAD_clk_FPGA_w,
        input 				PAD_clk_FPGA_cim,
        input 				PAD_rstn_FPGA,
        input  		 		PAD_PLL_CLK_SEL,
        input 				PAD_TEST_MODE,
        input				PAD_ls_OEN,							//0:load 	 , 1:store
        input        	  	PAD_FPGA_sys_en,
        input  [19:0]	  	PAD_FPGA_sys_addr,

        //Transmitter PAD port
		output				PAD_dout_valid,
        //Dual direction PAD port
        inout  [63:0]  		PAD_FPGA_sys_data,

        //TO sys_top
		input 				dout_valid,				//还没加总线valid信号
        output 				clk_FPGA_w,
        output 				clk_FPGA_cim,
        output 				rstn_FPGA,
        output  		 	PLL_CLK_SEL,
        output 				TEST_MODE,
        // output				ls_OEN,
        output        	  	FPGA_sys_load_en,
        output  [19:0]	  	FPGA_sys_load_addr,
        input  [63:0]		FPGA_sys_load_data,

        output        	  	FPGA_sys_store_en,
        output  [19:0]	  	FPGA_sys_store_addr,
        output [63:0]		FPGA_sys_store_data
    );

    wire				ls_OEN;
    wire        	  	FPGA_sys_en;
    wire  [19:0] 	  	FPGA_sys_addr;

    assign FPGA_sys_load_en		 = !ls_OEN? FPGA_sys_en 	 : 'b0;
    assign FPGA_sys_store_en	 =  ls_OEN? FPGA_sys_en 	 : 'b0;
    assign FPGA_sys_load_addr	 = !ls_OEN? FPGA_sys_addr	 : 'b0;
    assign FPGA_sys_store_addr	 =  ls_OEN? FPGA_sys_addr	 : 'b0;

    PBCSUD16_WDDNW_3V_X u_PAD_clk_FPGA_w( .PAD(PAD_clk_FPGA_w), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
                                          .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(clk_FPGA_w) );

    PBCSUD16_WDDNW_3V_X u_PAD_clk_FPGA_cim(	.PAD(PAD_clk_FPGA_cim), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
                                            .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(clk_FPGA_cim) );

    PBCSUD16_WDDNW_3V_X u_PAD_rstn_FPGA(.PAD(PAD_rstn_FPGA), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
                                    	.ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(rstn_FPGA) );

    PBCSUD16_WDDNW_3V_X u_PAD_PLL_CLK_SEL( .PAD(PAD_PLL_CLK_SEL), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
                                           .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(PLL_CLK_SEL) );

    PBCSUD16_WDDNW_3V_X u_PAD_TEST_MODE	( .PAD(PAD_TEST_MODE), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
                                          .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(TEST_MODE) );

    PBCSUD16_WDDNW_3V_X u_PAD_ls_OEN( .PAD(PAD_ls_OEN), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
                                      .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(ls_OEN) );

    PBCSUD16_WDDNW_3V_X u_PAD_FPGA_sys_en( .PAD(PAD_FPGA_sys_en), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
                                           .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(FPGA_sys_en) );

    genvar i;
    generate
        for (i = 0; i < 20; i = i + 1) begin : gen_FPGA_sys_addr
            PBCSUD16_WDDNW_3V_X u_PAD_FPGA_sys_addr(   .PAD(PAD_FPGA_sys_addr[i]), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
                                .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(FPGA_sys_addr[i]) );
        end
    endgenerate

    PBCSUD16_WDDNW_3V_X u_PAD_dout_valid(	.PAD(PAD_dout_valid), .I(dout_valid), .OEN(1'b0), .PU(1'b0), .PD(1'b0), .IE(1'b0),
                                        	.ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C() );

    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_FPGA_sys_data
            PBCSUD16_WDDNW_3V_X u_PAD_FPGA_sys_data(   .PAD(PAD_FPGA_sys_data[i]), .I(FPGA_sys_load_data[i]), .OEN(ls_OEN), .PU(1'b0), .PD(1'b0), .IE(ls_OEN),
                                .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(FPGA_sys_store_data[i]) );
        end
    endgenerate

endmodule
