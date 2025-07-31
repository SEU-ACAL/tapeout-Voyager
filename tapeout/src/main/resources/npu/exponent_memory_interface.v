// `include "../0-RTL/AXI_SLAVE/defines.v"
`include "../gen-collateral/defines.v"

module exponent_memory_interface(
        input                                   clk,
        input                                   rstn,
        input                                   exp_store_en,
        input  [$clog2(`EXP_DEPTH)-1:0]         exp_store_addr,
        input  [`EXP_WIDTH-1:0]                 exp_store_data,
        input                                   exp_load_en,
        input  [$clog2(`EXP_DEPTH)-1:0]         exp_load_addr,
        output  reg[`EXP_WIDTH-1:0]             exp_load_data,

        output [`EXP_DEPTH*`EXP_WIDTH-1:0]  data
    );

    reg [`EXP_WIDTH-1:0]       mem [0:`EXP_DEPTH-1];

    integer i;
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            for(i=0; i<`EXP_DEPTH; i=i+1)
                mem[i] <= 'd0;
        end
        else if(exp_store_en) begin
            mem[exp_store_addr] <= exp_store_data;
        end
    end

	    always @(posedge clk or negedge rstn) begin
        if (~rstn)
            exp_load_data <= 'b0;
        else if ( exp_load_en )
            exp_load_data <= mem[exp_load_addr];
    end

    genvar k;
    generate
        for(k = 0; k < `EXP_DEPTH; k = k + 1) begin
            assign data[k*`EXP_WIDTH +: `EXP_WIDTH] = mem[k];
        end
    endgenerate

endmodule
