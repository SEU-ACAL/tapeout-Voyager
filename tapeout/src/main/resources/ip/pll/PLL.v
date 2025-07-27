//==================================================================//
`define verilator
//======= would be auto replaced by voyager-code-gen.sh ============//

`ifdef verilator
module PLL (
    input clk0,
    input power,
    inout VSSA,
    inout VDDP,
    inout VDDB,
    inout VDDA, 
    output lock,
    input gate,
    output clk);

    assign clk = clk0;
endmodule
`endif // verilator

`ifdef vcs
module PLL (
    input clk0,
    input power,
    inout VSSA,
    inout VDDP,
    inout VDDB,
    inout VDDA, 
    output lock,
    input gate,
    output clk);

	supply0	VSSA;
	supply1	VDDP;
	supply1	VDDB;
	supply1	VDDA;
    PLL6GS28		PLL6GS28(
    .VSSA							(VSSA),
    .VDDP							(VDDP),
    .VDDB							(VDDB),
    .VDDA							(VDDA),
    .I_PLL_BYPASS_CLKDIVPD         	(1'b0                          ),
    .I_PLL_CKREF                   	(clk0                          ),
    .I_PLL_CLKDIV1                 	(3'b1                          ),
    .I_PLL_CLKDIV2                 	(3'b1                          ),
    .I_PLL_CLKDIVPD                	(1'b0                          ),
    .I_PLL_CLKPHASEPD              	(1'b0                          ),
    .I_PLL_FBDIV_FRA               	(24'h00_0000                   ),
    .I_PLL_FBDIV_INT               	(12'b10_1000                   ),
    .I_PLL_PD                      	(!power                        ),
    .I_PLL_REFDIV                  	(6'b000100                     ),
    .I_PLL_V2I_PD                  	(1'b0                          ),
    .I_PLL_FRPD                    	(1'b0                          ),
    .I_PLL_VCO_OUT_PD              	(1'b0                          ),
    .O_PLL_CLK2                    	(                           ),
    .O_PLL_CLK3                    	(                              ),
    .O_PLL_CLK4                    	(                              ),
    .O_PLL_CLK5                    	(                              ),
    .O_PLL_CLKDIV                  	(                              ),
    .O_PLL_CLKN                    	(                              ),
    .O_PLL_CLKP                    	(                              ),
    .O_PLL_CLKSSC                  	(                              ),
    .O_PLL_CLK_IN                  	(                              ),
    .O_PLL_CLK_IP                  	(                              ),
    .O_PLL_CLK_QN                  	(                              ),
    .O_PLL_CLK_QP                  	(                              ),
    .O_PLL_LOCK                    	(lock                          ),
    .O_PLL_VCO_OUT_CLK             	(clk)
    );
endmodule
`endif // vcs

`ifdef chip
module PLL (
    input clk0,
    input power,
    inout VSSA,
    inout VDDP,
    inout VDDB,
    inout VDDA, 
    output lock,
    input gate,
    output clk);

	supply0	VSSA;
	supply1	VDDP;
	supply1	VDDB;
	supply1	VDDA;
    PLL6GS28		PLL6GS28(
    .VSSA							(VSSA),
    .VDDP							(VDDP),
    .VDDB							(VDDB),
    .VDDA							(VDDA),
    .I_PLL_BYPASS_CLKDIVPD         	(1'b0                          ),
    .I_PLL_CKREF                   	(clk0                          ),
    .I_PLL_CLKDIV1                 	(3'b1                          ),
    .I_PLL_CLKDIV2                 	(3'b1                          ),
    .I_PLL_CLKDIVPD                	(1'b0                          ),
    .I_PLL_CLKPHASEPD              	(1'b0                          ),
    .I_PLL_FBDIV_FRA               	(24'h00_0000                   ),
    .I_PLL_FBDIV_INT               	(12'b10_1000                   ),
    .I_PLL_PD                      	(!power                        ),
    .I_PLL_REFDIV                  	(6'b000100                     ),
    .I_PLL_V2I_PD                  	(1'b0                          ),
    .I_PLL_FRPD                    	(1'b0                          ),
    .I_PLL_VCO_OUT_PD              	(1'b0                          ),
    .O_PLL_CLK2                    	(                           ),
    .O_PLL_CLK3                    	(                              ),
    .O_PLL_CLK4                    	(                              ),
    .O_PLL_CLK5                    	(                              ),
    .O_PLL_CLKDIV                  	(                              ),
    .O_PLL_CLKN                    	(                              ),
    .O_PLL_CLKP                    	(                              ),
    .O_PLL_CLKSSC                  	(                              ),
    .O_PLL_CLK_IN                  	(                              ),
    .O_PLL_CLK_IP                  	(                              ),
    .O_PLL_CLK_QN                  	(                              ),
    .O_PLL_CLK_QP                  	(                              ),
    .O_PLL_LOCK                    	(lock                          ),
    .O_PLL_VCO_OUT_CLK             	(clk)
    );
endmodule
`endif // chip