//==================================================================//
`define verilator
//======= would be auto replaced by voyager-code-gen.sh ============//

`timescale 1ns/1ps

`ifdef vcs
// Used to build a programmable clock divider, phase detector, etc
module ClockFlop (
    input clockIn,
    input d,
    output reg clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED

    always @(posedge clockIn)
        clockOut <= d; // This should be a blocking assignment to deterministically order clock edges

endmodule

module ClockSignalNor2 (
    input clockIn,
    input signalIn,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED
    CLKNOR2V12_140P7T35R u_clock_nor2(
        .ZN(clockOut),
        .A1(signalIn),
        .A2(clockIn)
    );
    // assign clockOut = !(signalIn || clockIn);

endmodule

module ClockInverter (
    input clockIn,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED
    CLKINV10_140P7T35R u_CLOCK_INV(
        .ZN(clockOut),
        .I(clockIn)
    );
    // assign clockOut = !clockIn;

endmodule

module ClockMux2 (
    input clocksIn_0,
    input clocksIn_1,
    input sel,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED

    // XXX be careful with this! You can get really nasty short edges if you
    // don't switch carefully
    assign clockOut = sel ? clocksIn_1 : clocksIn_0;

endmodule


module ClockOr2 (
    input clocksIn_0,
    input clocksIn_1,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED
    CLKOR2V12_140P7T35R u_clock_or2(
        .Z(clockOut),
        .A1(clocksIn_0),
        .A2(clocksIn_1)
    );
    // assign clockOut = clocksIn_0 | clocksIn_1;

endmodule

// Testbench-only stuff
`ifndef SYNTHESIS
module PeriodMonitor #(
    parameter longint minperiodps = 1000,
    parameter longint maxperiodps = 1000    // Set to 0 to ignore
) (
    input clock,
    input enable
);

`ifndef VERILATOR
    time edgetime = 1ps;
`else
    time edgetime = 1;
`endif
    longint period;

    always @(posedge clock) begin
`ifndef VERILATOR
        period = $realtime/1ps - edgetime;
        edgetime = $realtime/1ps;
`else
        period = $time - edgetime;
        edgetime = $time;
`endif
        if (period > 0) begin
            if (enable && (period < minperiodps)) begin
                $display("PeriodMonitor detected a small period of %d ps at time %0t", period, $realtime);
                $fatal;
            end
            if (enable && (maxperiodps > 0) && (period > maxperiodps)) begin
                $display("PeriodMonitor detected a large period of %d ps at time %0t", period, $realtime);
                $fatal;
            end
        end
    end

endmodule

module ClockGenerator #(
    parameter periodps = 1000
) (
    output reg clock
);

    initial begin
        clock = 1'b0;
`ifndef VERILATOR
        forever #((periodps * 1ps) / 2) clock = ~clock;
`else
        $fatal("ClockGenerator not supported in Verilator, as it does not support # delays");
`endif
    end

endmodule

`endif
`endif // vcs


`ifdef chip
// Used to build a programmable clock divider, phase detector, etc
module ClockFlop (
    input clockIn,
    input d,
    output reg clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED

    always @(posedge clockIn)
        clockOut <= d; // This should be a blocking assignment to deterministically order clock edges

endmodule

module ClockSignalNor2 (
    input clockIn,
    input signalIn,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED
    CLKNOR2V12_140P7T35R u_clock_nor2(
        .ZN(clockOut),
        .A1(signalIn),
        .A2(clockIn)
    );
    // assign clockOut = !(signalIn || clockIn);

endmodule

module ClockInverter (
    input clockIn,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED
    CLKINV10_140P7T35R u_CLOCK_INV(
        .ZN(clockOut),
        .I(clockIn)
    );
    // assign clockOut = !clockIn;

endmodule

module ClockMux2 (
    input clocksIn_0,
    input clocksIn_1,
    input sel,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED

    // XXX be careful with this! You can get really nasty short edges if you
    // don't switch carefully
    assign clockOut = sel ? clocksIn_1 : clocksIn_0;

endmodule


module ClockOr2 (
    input clocksIn_0,
    input clocksIn_1,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED
    CLKOR2V12_140P7T35R u_clock_or2(
        .Z(clockOut),
        .A1(clocksIn_0),
        .A2(clocksIn_1)
    );
    // assign clockOut = clocksIn_0 | clocksIn_1;

endmodule
`endif // chip

`ifdef verilator
// Used to build a programmable clock divider, phase detector, etc
module ClockFlop (
    input clockIn,
    input d,
    output reg clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED

    always @(posedge clockIn)
        clockOut <= d; // This should be a blocking assignment to deterministically order clock edges

endmodule

module ClockSignalNor2 (
    input clockIn,
    input signalIn,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED
    // CLKNOR2V12_140P7T35R u_clock_nor2(
    //     .ZN(clockOut),
    //     .A1(signalIn),
    //     .A2(clockIn)
    // );
    assign clockOut = !(signalIn || clockIn);

endmodule

module ClockInverter (
    input clockIn,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED
    // CLKINV10_140P7T35R u_CLOCK_INV(
    //     .ZN(clockOut),
    //     .I(clockIn)
    // );
    assign clockOut = !clockIn;

endmodule

module ClockMux2 (
    input clocksIn_0,
    input clocksIn_1,
    input sel,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED

    // XXX be careful with this! You can get really nasty short edges if you
    // don't switch carefully
    assign clockOut = sel ? clocksIn_1 : clocksIn_0;

endmodule


module ClockOr2 (
    input clocksIn_0,
    input clocksIn_1,
    output clockOut
);

    // REPLACE ME WITH A CLOCK CELL IF DESIRED

    assign clockOut = clocksIn_0 | clocksIn_1;

endmodule

// Testbench-only stuff
`ifndef SYNTHESIS
module PeriodMonitor #(
    parameter longint minperiodps = 1000,
    parameter longint maxperiodps = 1000    // Set to 0 to ignore
) (
    input clock,
    input enable
);

`ifndef VERILATOR
    time edgetime = 1ps;
`else
    time edgetime = 1;
`endif
    longint period;

    always @(posedge clock) begin
`ifndef VERILATOR
        period = $realtime/1ps - edgetime;
        edgetime = $realtime/1ps;
`else
        period = $time - edgetime;
        edgetime = $time;
`endif
        if (period > 0) begin
            if (enable && (period < minperiodps)) begin
                $display("PeriodMonitor detected a small period of %d ps at time %0t", period, $realtime);
                $fatal;
            end
            if (enable && (maxperiodps > 0) && (period > maxperiodps)) begin
                $display("PeriodMonitor detected a large period of %d ps at time %0t", period, $realtime);
                $fatal;
            end
        end
    end

endmodule

module ClockGenerator #(
    parameter periodps = 1000
) (
    output reg clock
);

    initial begin
        clock = 1'b0;
`ifndef VERILATOR
        forever #((periodps * 1ps) / 2) clock = ~clock;
`else
        $fatal("ClockGenerator not supported in Verilator, as it does not support # delays");
`endif
    end

endmodule

`endif
`endif // verilator



 