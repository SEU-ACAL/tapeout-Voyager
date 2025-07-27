module clk_selector (
    input  clk_FPGA_w,
    input  clk_FPGA_cim,
    input  clk_PLL_w,
    input  clk_PLL_cim,
    input  clk_AXI,
    input  TEST_MODE,
    input  NPU_AXI_SEL,
    input  PLL_CLK_SEL,
	input  reset_async,
    output clk_w,
    output clk_cim
);

    // clk_w 路径
    wire clk_w_after_test_mode;
    wire clk_w_after_npu_sel;

    // 1、TEST_MODE
    ClockMutexMux mux_test_mode_w (
        .io_clocksIn_0(clk_AXI),          // CPU模式：clk_AXI
        .io_clocksIn_1(clk_FPGA_w),       // TEST模式：clk_FPGA_w
        .io_clockOut(clk_w_after_test_mode),
        .io_resetAsync(reset_async),
        .io_sel(TEST_MODE)
    );

    // 2、NPU_AXI_SEL
    ClockMutexMux mux_npu_sel_w (
        .io_clocksIn_0(clk_w_after_test_mode), // AXI模式：上一级输出
        .io_clocksIn_1(clk_FPGA_w),            // NPU模式：clk_FPGA_w
        .io_clockOut(clk_w_after_npu_sel),
        .io_resetAsync(reset_async),
        .io_sel(NPU_AXI_SEL)
    );

    // 3、PLL_CLK_SEL 选择
    ClockMutexMux mux_pll_sel_w (
        .io_clocksIn_0(clk_w_after_npu_sel), // FPGA时钟：上一级输出
        .io_clocksIn_1(clk_PLL_w),           // PLL时钟：clk_PLL_w
        .io_clockOut(clk_w),
        .io_resetAsync(reset_async),
        .io_sel(PLL_CLK_SEL & NPU_AXI_SEL)   // 仅NPU模式下允许切PLL
    );

    // clk_cim 路径
    wire clk_cim_after_test_mode;
    wire clk_cim_after_npu_sel;

    // 1、TEST_MODE
    ClockMutexMux mux_test_mode_cim (
        .io_clocksIn_0(clk_AXI),            // CPU模式：clk_AXI
        .io_clocksIn_1(clk_FPGA_w),         // TEST模式：clk_FPGA_w
        .io_clockOut(clk_cim_after_test_mode),
        .io_resetAsync(reset_async),
        .io_sel(TEST_MODE & ~NPU_AXI_SEL)  // 仅在TEST+AXI模式选clk_FPGA_w
    );

    // 2、NPU_AXI_SEL
    ClockMutexMux mux_npu_sel_cim (
        .io_clocksIn_0(clk_cim_after_test_mode), // AXI模式：上一级输出
        .io_clocksIn_1(clk_FPGA_cim),            // NPU模式：clk_FPGA_cim
        .io_clockOut(clk_cim_after_npu_sel),
        .io_resetAsync(reset_async),
        .io_sel(NPU_AXI_SEL)
    );

    // 3、PLL_CLK_SEL
    ClockMutexMux mux_pll_sel_cim (
        .io_clocksIn_0(clk_cim_after_npu_sel), // FPGA时钟：上一级输出
        .io_clocksIn_1(clk_PLL_cim),           // PLL时钟：clk_PLL_cim
        .io_clockOut(clk_cim),
        .io_resetAsync(reset_async),
        .io_sel(PLL_CLK_SEL & NPU_AXI_SEL)     // 仅NPU模式下允许切PLL
    );

endmodule