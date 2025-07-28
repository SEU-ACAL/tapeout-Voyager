module axi_bridge(
    input clk,
    input rstn,

    input [19:0] axi_awaddr,
    input [7:0]  axi_awlen,  // 8 bit
    input [2:0]  axi_awsize, // 3 bit
    input [1:0]  axi_awburst,
    input [11:0]  axi_awid,
    input        axi_awvalid,
    output reg   axi_awready,

    input [63:0] axi_wdata,
    input [7:0]  axi_wstrb,
    input        axi_wlast,
    input        axi_wvalid,
    output reg   axi_wready,

    output reg [1:0] axi_bresp,
    output [11:0]     axi_bid,
    output reg       axi_bvalid,
    input            axi_bready,

    input  [19:0] axi_araddr,
    input  [7:0]  axi_arlen,
    input  [2:0]  axi_arsize,
    input  [1:0]  axi_arburst,
    input  [11:0]  axi_arid,
    input         axi_arvalid,
    output reg    axi_arready,

    output     [63:0] axi_rdata,
    output     [11:0]  axi_rid,
    output reg [1:0]  axi_rresp,
    output reg        axi_rlast,
    output reg        axi_rvalid,
    input             axi_rready,

    // output control to npu_sys_top
    output                         sys_load_en,
    output [16:0]                  sys_load_addr,
    input  [63:0]                  sys_load_data,

    output                         sys_store_en,
    output [16:0]                  sys_store_addr,
    output [63:0]                  sys_store_data
);


reg [11:0] axi_bid_reg;
assign axi_bid = axi_bid_reg;

reg [11:0] axi_rid_reg;
assign axi_rid = axi_rid_reg;


reg axi_awv_awr_flag;
reg axi_arv_arr_flag; 


// Implement axi_awready generation

// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
// de-asserted when reset is low.

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        axi_awready <= 1'b0;
        axi_awv_awr_flag <= 1'b0;
    end
    else begin
        if (!axi_awready && axi_awvalid && ~axi_awv_awr_flag && ~axi_arv_arr_flag) begin
            axi_awready <= 1'b1;
            axi_awv_awr_flag <= 1'b1;
        end
        else if (axi_wlast && axi_wready) begin
            axi_awv_awr_flag <= 1'b0;
        end
        else begin
            axi_awready <= 1'b0;
        end
    end
end

// Implement axi_awaddr latching

// This process is used to latch the address when both 
// S_AXI_AWVALID and S_AXI_WVALID are valid. 

reg [19:0] awaddr;
reg [7:0]  awlen_cntr;
reg [1:0]  awburst;
reg [7:0]  awlen;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        awaddr <= 'b0;
        awlen_cntr <= 'b0;
        awburst <= 'b0;
        awlen   <= 'b0;
        axi_bid_reg <= 12'b0;
    end 
    else begin
        if (~axi_awready && axi_awvalid && ~axi_awv_awr_flag) begin
            awaddr <= axi_awaddr[19:0];
            awburst <= axi_awburst;
            awlen <= axi_awlen;
            awlen_cntr <= 'b0;
            axi_bid_reg <= axi_awid;
        end
        else if ((awlen_cntr <= awlen) && axi_wready && axi_wvalid) begin
            awlen_cntr <= awlen_cntr + 1'b1;
            case (awburst)
                2'b00: begin
                    awaddr <= awaddr;
                end
                2'b01: begin
                    awaddr[19:3] <= awaddr[19:3] + 1'b1;
                    awaddr[2:0]  <= 3'b0;
                end
                2'b10: begin
                    // npu system dont need wrapping burst mode
                end
                default: begin
                    awaddr[19:3] <= awaddr[19:3] + 1'b1;
                    awaddr[2:0]  <= 3'b0;
                end
            endcase
        end
    end
end

// Implement axi_wready generation

// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
// de-asserted when reset is low. 
reg axi_wlast_d;

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        axi_wready <= 1'b0;
        axi_wlast_d <= 1'b0;
    end
    else begin
        axi_wlast_d <= axi_wlast;
        //if (~axi_wready && axi_wvalid && axi_awv_awr_flag) begin
        if (~axi_wready && axi_wvalid && axi_awv_awr_flag) begin   // new!
            axi_wready <= 1'b1;
        end
        //else if (axi_wlast && axi_wready) begin
        else if (axi_wlast_d && axi_wready) begin
            axi_wready <= 1'b0;
        end
    end
end

//?????NPU??????????????

// Implement write response logic generation

// The write response and response valid signals are asserted by the slave 
// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
// This marks the acceptance of address and indicates the status of 
// write transaction.

//axi_bvalid:???д?????Ч??slave??master??д???????
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        axi_bvalid <= 1'b0;
        axi_bresp <= 2'b0;
    end
    else begin
        if (axi_awv_awr_flag && axi_wready && axi_wvalid && ~axi_bvalid && axi_wlast) begin
            axi_bvalid <= 1'b1;
            axi_bresp <= 2'b0;
            // OKAY response
        end
        else begin
            if (axi_bready && axi_bvalid)begin
                axi_bvalid <= 1'b0;
            end
        end
    end
end

// Implement axi_arready generation

// axi_arready is asserted for one S_AXI_ACLK clock cycle when
// S_AXI_ARVALID is asserted. axi_awready is 
// de-asserted when reset (active low) is asserted. 
// The read address is also latched when S_AXI_ARVALID is 
// asserted. axi_araddr is reset to zero on reset assertion.
reg [19:0] araddr;
reg [7:0]  arlen_cntr;
reg [7:0]  arlen;
reg [1:0]  arburst;



always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        axi_arready <= 1'b0;
        axi_arv_arr_flag <= 1'b0;
    end
    else begin    
        if (~axi_arready && axi_arvalid && ~axi_awv_awr_flag && ~axi_arv_arr_flag) begin
            axi_arready <= 1'b1;
            axi_arv_arr_flag <= 1'b1;
        end
        else if (axi_rvalid && axi_rready && arlen_cntr == arlen) begin
        // preparing to accept next address after current read completion
            axi_arv_arr_flag  <= 1'b0;
        end
        else begin
            axi_arready <= 1'b0;
        end
    end 
end       

// Implement axi_araddr latching

//This process is used to latch the address when both 
//S_AXI_ARVALID and S_AXI_RVALID are valid. 
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        araddr <= 'b0;
        arlen_cntr <= 'b0;
        arburst <= 'b0;
        arlen <= 'b0;
        axi_rlast <= 'b0;
        axi_rid_reg <= 12'b0;
    end
    else begin
        if(~axi_arready && axi_arvalid && ~axi_arv_arr_flag) begin
            araddr <= axi_araddr;
            arburst <= axi_arburst;
            arlen <= axi_arlen;
            axi_rid_reg <= axi_arid;
            arlen_cntr <= 'b0;
            axi_rlast <= 'b0;
        end
        // 目前的问题是axi ready不来，就不能让下??个mem访存，因此需要增加一个fifo
        else if ((arlen_cntr <= arlen) && axi_rvalid && axi_rready) begin
            arlen_cntr <= arlen_cntr + 1'b1;
            axi_rlast <= 1'b0;
            case (arburst)
                2'b00: begin
                    araddr <= araddr;
                end
                2'b01: begin
                    araddr[19:3] <= araddr[19:3] + 1'b1;
                    araddr[1:0]  <= 2'b0;
                end
                2'b10: begin
                    // npu dont need wrapping burst mode
                end
                default: begin
                    araddr[19:3] <= araddr[19:3] + 1'b1;
                    araddr[2:0]  <= 3'b0;
                end
            endcase
        end
        else if ((arlen_cntr==arlen) && ~axi_rlast && axi_arv_arr_flag) begin
            axi_rlast <= 1'b1;
        end 
        else if(axi_rready) begin  // 说明读到了rlast信号
            axi_rlast <= 1'b0;
        end
    end
end
// Implement axi_arvalid generation

// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
// data are available on the axi_rdata bus at this instance. The 
// assertion of axi_rvalid marks the validity of read data on the 
// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
// is deasserted on reset (active low). axi_rresp and axi_rdata are 
// cleared to zero on reset (active low). 


always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        axi_rvalid <= 'b0;
        axi_rresp  <= 'b0;
    end
    else begin
        if (axi_arv_arr_flag && ~axi_rvalid) begin
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b0;
            // "OKAY" respones
        end
        else if (axi_rvalid && axi_rready && (arlen_cntr >= arlen)) begin
            axi_rvalid <= 1'b0;
        end
    end
end



assign sys_store_en = axi_wvalid && axi_wready;
assign sys_store_addr = awaddr[3+:17];
assign sys_store_data = axi_wdata;

//一直拉高？要不要用边沿触发
//assign sys_load_en = axi_arv_arr_flag && ~axi_rvalid;

//reg sys_load_en_d;
//reg sys_load_en_d1;

//reg [11:0] araddr_d;
//always @(posedge clk) begin
//    if (!rstn) begin
//        sys_load_en_d <= 1'b0;
//        sys_load_en_d1 <= 1'b0;
//        araddr_d      <=  'd0;
//   end else begin 
//        sys_load_en_d <= axi_arv_arr_flag && axi_rvalid;
//        sys_load_en_d1 <= sys_load_en_d;
//        araddr_d <= araddr[3+:13];
//    end
//end
//
//assign sys_load_en = sys_load_en_d1; 
//assign sys_load_addr = araddr_d;


//assign sys_load_en = axi_arv_arr_flag && axi_rvalid;
assign sys_load_en = axi_rready && axi_rvalid;
assign sys_load_addr = araddr[3+:17];
assign axi_rdata = sys_load_data;

// reg [63:0] axi_rdata_reg;
// always @(posedge clk) begin
//     if (sys_load_en)
//         axi_rdata_reg <= sys_load_data;  // 在下一拍更新给 axi
// end

// assign axi_rdata = axi_rdata_reg;


endmodule
