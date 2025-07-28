module PAD_NPU_port (
        //Receiver PAD port					//OEN				0:load 	 , 1:store
        // input 				PAD_clk_FPGA_w,
        // input 				PAD_clk_FPGA_cim,
        input 				PAD_rstn_FPGA,
        input  		 		PAD_PLL_CLK_SEL,
        input 				PAD_TEST_MODE,

        input [1:0]			PAD_ISA,
        //Transmitter PAD port
        output				PAD_dout_valid,
        //Dual direction PAD port
        inout  [31:0]  		PAD_data,

        //TO sys_top
        // output 				clk_FPGA_w,
        // output 				clk_FPGA_cim,
        output 				rstn_FPGA,
        output  		 	PLL_CLK_SEL,
        output 				TEST_MODE,

        input 				FPGA_sys_load_data_vld,				//还没加总线valid信号
        output        	  	FPGA_sys_load_en,
        output [16:0]	  	FPGA_sys_load_addr,
        input  [63:0]		FPGA_sys_load_data,

        output        	  	FPGA_sys_store_en,
        output [16:0]	  	FPGA_sys_store_addr,
        output [63:0]		FPGA_sys_store_data
    );
    wire  [1:0] ISA;
    wire 		ls_OEN;
    wire 		dout_valid;
    wire [31:0] PAD_load_data;
    wire [31:0] PAD_store_data;

    // PBCD2RNC_X u_PAD_clk_FPGA_w     ( .PAD(PAD_clk_FPGA_w),    .I(1'b0),        .OEN(1'b1), .IE(1'b1), .REN(1'b0), .C(clk_FPGA_w) );
    // PBCD2RNC_X u_PAD_clk_FPGA_cim   ( .PAD(PAD_clk_FPGA_cim),  .I(1'b0),        .OEN(1'b1), .IE(1'b1), .REN(1'b0), .C(clk_FPGA_cim) );
    PBCD2RNC_X u_PAD_rstn_FPGA      ( .PAD(PAD_rstn_FPGA),     .I(1'b0),        .OEN(1'b1), .IE(1'b1), .REN(1'b0), .C(rstn_FPGA) );
    PBCD2RNC_X u_PAD_PLL_CLK_SEL    ( .PAD(PAD_PLL_CLK_SEL),   .I(1'b0),        .OEN(1'b1), .IE(1'b1), .REN(1'b0), .C(PLL_CLK_SEL) );
    PBCD2RNC_X u_PAD_TEST_MODE      ( .PAD(PAD_TEST_MODE),     .I(1'b0),        .OEN(1'b1), .IE(1'b1), .REN(1'b0), .C(TEST_MODE) );

    PBCD2RNC_X u_PAD_dout_valid     ( .PAD(PAD_dout_valid),    .I(dout_valid),  .OEN(1'b0), .IE(1'b0), .REN(1'b0), .C() );

    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_FPGA_sys_addr
            PBCD2RNC_X u_PAD_FPGA_sys_addr ( .PAD(PAD_ISA[i]), .I(1'b0), .OEN(1'b1), .IE(1'b1), .REN(1'b0), .C(ISA[i]) );
        end
    endgenerate

    generate
        for (i = 0; i < 32; i = i + 1) begin : gen_FPGA_sys_data
            PBCD2RNC_X u_PAD_FPGA_sys_data ( .PAD(PAD_data[i]), .I(PAD_load_data[i]), .OEN(ls_OEN), .IE(ls_OEN), .REN(1'b0), .C(PAD_store_data[i]) );
        end
    endgenerate

    PAD2sys_top u_PAD2sys_top(
                    .clk_w                  ( clk_FPGA_w             ),
                    .rstn                   ( rstn_FPGA              ),
                    .ISA                    ( ISA                    ),
                    .ls_oen                 ( ls_OEN                 ),
                    .dout_valid             ( dout_valid             ),
                    .PAD_load_data          ( PAD_load_data          ),
                    .PAD_store_data         ( PAD_store_data         ),
                    .FPGA_sys_load_data_vld ( FPGA_sys_load_data_vld ),
                    .FPGA_sys_load_en       ( FPGA_sys_load_en       ),
                    .FPGA_sys_load_addr     ( FPGA_sys_load_addr     ),
                    .FPGA_sys_load_data     ( FPGA_sys_load_data     ),
                    .FPGA_sys_store_en      ( FPGA_sys_store_en      ),
                    .FPGA_sys_store_addr    ( FPGA_sys_store_addr    ),
                    .FPGA_sys_store_data    ( FPGA_sys_store_data    )
                );


endmodule



module PAD2sys_top (
        input				clk_w,
        input				rstn,
        input   [1:0] 		ISA,
        output				ls_oen,					//OEN				0:load 	 , 1:store
        output reg			dout_valid,
        output [31:0] 		PAD_load_data,
        input  [31:0] 		PAD_store_data,

        input  				FPGA_sys_load_data_vld,
        output reg       	FPGA_sys_load_en,
        output reg[16:0]	FPGA_sys_load_addr,
        input 	  [63:0]	FPGA_sys_load_data,

        output reg        	FPGA_sys_store_en,
        output reg[16:0]	FPGA_sys_store_addr,
        output reg[63:0]	FPGA_sys_store_data
    );
    wire 			CSR_SEL;		//0:CSR		 , 1:DATA
    wire 			mux_bit;		//0:LSB		 , 1:MSB

    reg				REB;			//0:load 	 , 1:store
    reg [16:0]		base_addr;
    reg [13:0]		burst_len;

    reg [13:0]		addr_cnt;
    wire[16:0]		sys_addr;

    reg FPGA_sys_load_en_d1;

    assign CSR_SEL 	= ISA[1];
    assign mux_bit 	= ISA[0];
    assign sys_addr = base_addr + burst_len;

    assign ls_oen	= REB;

    //CSR logic
    always @(posedge clk_w or negedge rstn) begin
        if(!rstn) begin
            REB			 <= 'd0;
            base_addr	 <= 'd0;
            burst_len	 <= 'd0;
        end
        else if(!CSR_SEL && mux_bit) begin
            REB			 <= PAD_store_data[31+: 1];
            base_addr	 <= PAD_store_data[14+:17];
            burst_len	 <= PAD_store_data[0 +:13];
        end
    end

    //store logic
    always @(posedge clk_w or negedge rstn) begin
        if(!rstn) begin
            FPGA_sys_store_en	 <= 'd0;
            FPGA_sys_store_addr	 <= 'd0;
            FPGA_sys_store_data	 <= 'd0;
        end
        else if(CSR_SEL) begin
            if(!mux_bit) begin
                FPGA_sys_store_en			 <= 'd0;
                // FPGA_sys_store_addr			 <= sys_addr;
                FPGA_sys_store_data[0 +:32]	 <= PAD_store_data;
            end
            else begin
                FPGA_sys_store_en			 <= 'd1;
                FPGA_sys_store_addr			 <= sys_addr;
                FPGA_sys_store_data[32+:32]	 <= PAD_store_data;
            end
        end
    end

    //load logic
    assign PAD_load_data = mux_bit? FPGA_sys_load_data[32+:32]: FPGA_sys_load_data[0 +:32];
    always @(posedge clk_w or negedge rstn) begin
        if(!rstn) begin
            dout_valid			<= 'b0;
            FPGA_sys_load_en	<= 'b0;
            FPGA_sys_load_addr	<= 'b0;
        end
        else if(CSR_SEL) begin
            if(!mux_bit) begin
                dout_valid			<= FPGA_sys_load_en_d1;
                FPGA_sys_load_en	<= 'b1;
                FPGA_sys_load_addr	<= sys_addr;
            end
            else begin
                dout_valid			<= FPGA_sys_load_en;
                FPGA_sys_load_en	<= 'b0;
                // FPGA_sys_load_addr	<= 'b0;
            end
        end
    end

    //addr_cnt logic
    always @(posedge clk_w or negedge rstn) begin
        if(!rstn)
            addr_cnt <= 'b0;
        else if(!CSR_SEL && mux_bit)
            addr_cnt <= 'b0;
        else if(CSR_SEL && mux_bit)
            addr_cnt <= addr_cnt + 1'b1;
    end

    always @(posedge clk_w or negedge rstn) begin
        if (!rstn) begin
            FPGA_sys_load_en_d1 <= 1'b0;
        end
        else begin
            FPGA_sys_load_en_d1 <= FPGA_sys_load_en;
        end
    end
endmodule




// PBCSUD16_WDDNW_3V_X u_PAD_clk_FPGA_w( .PAD(PAD_clk_FPGA_w), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
//                                       .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(clk_FPGA_w) );

// PBCSUD16_WDDNW_3V_X u_PAD_clk_FPGA_cim(	.PAD(PAD_clk_FPGA_cim), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
//                                         .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(clk_FPGA_cim) );

// PBCSUD16_WDDNW_3V_X u_PAD_rstn_FPGA( .PAD(PAD_rstn_FPGA), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
//                                      .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(rstn_FPGA) );

// PBCSUD16_WDDNW_3V_X u_PAD_PLL_CLK_SEL( .PAD(PAD_PLL_CLK_SEL), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
//                                        .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(PLL_CLK_SEL) );

// PBCSUD16_WDDNW_3V_X u_PAD_TEST_MODE	( .PAD(PAD_TEST_MODE), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
//                                       .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(TEST_MODE) );

// genvar i;
// generate
//     for (i = 0; i < 2; i = i + 1) begin : gen_FPGA_sys_addr
//         PBCSUD16_WDDNW_3V_X
//             u_PAD_FPGA_sys_addr( .PAD(PAD_ISA[i]), .I(1'b0), .OEN(1'b1), .PU(1'b0), .PD(1'b0), .IE(1'b1),
//                                  .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(ISA[i]) );
//     end
// endgenerate

// PBCSUD16_WDDNW_3V_X u_PAD_dout_valid( .PAD(PAD_dout_valid), .I(dout_valid), .OEN(1'b0), .PU(1'b0), .PD(1'b0), .IE(1'b0),
//                                       .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C() );

// generate
//     for (i = 0; i < 32; i = i + 1) begin : gen_FPGA_sys_data
//         PBCSUD16_WDDNW_3V_X
//             u_PAD_FPGA_sys_data( .PAD(PAD_data[i]), .I(PAD_load_data[i]), .OEN(ls_OEN), .PU(1'b0), .PD(1'b0), .IE(ls_OEN),
//                                  .ST(1'b0), .DS0(1'b0), .DS1(1'b0), .DS2(1'b0), .DS3(1'b0), .C(PAD_store_data[i]) );
//     end
// endgenerate
