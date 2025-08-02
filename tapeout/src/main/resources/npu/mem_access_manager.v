// `include "../0-RTL/AXI_SLAVE/defines.v"
`include "../gen-collateral/defines.v"

module mem_access_manager(
        input clk,
        input rstn,

        input         sys_load_en      ,
        input  [16:0] sys_load_addr    ,
        output [63:0] sys_load_data    ,
		output        sys_load_data_vld,

        input         sys_store_en  ,
        input  [16:0] sys_store_addr,
        input  [63:0] sys_store_data,



        // weight memory large access port
        output                                 wml_load_en,
        output [$clog2(`WM_DEPTH_L)-1:0]       wml_load_addr,
        input  [`WM_WIDTH-1:0]                 wml_load_data,
        output                                 wml_store_en,
        output [$clog2(`WM_DEPTH_L)-1:0]       wml_store_addr,
        output [`WM_WIDTH-1:0]                 wml_store_data,

        // weight memory small access port
        output                                 wms_load_en,
        output [$clog2(`WM_DEPTH_S)-1:0]       wms_load_addr,
        input  [`WM_WIDTH-1:0]                 wms_load_data,
        output                                 wms_store_en,
        output [$clog2(`WM_DEPTH_S)-1:0]       wms_store_addr,
        output [`WM_WIDTH-1:0]                 wms_store_data,

        // output buffer large access port
        output                                 obl_load_en,
        output [$clog2(`OB_DEPTH)-1:0]         obl_load_addr,
        input  [`OB_WIDTH-1:0]                 obl_load_data,
        output                                 obl_store_en,
        output [$clog2(`OB_DEPTH)-1:0]         obl_store_addr,
        output [`OB_WIDTH-1:0]                 obl_store_data,

        // output buffer small access port
        output                                 obs_load_en,
        output [$clog2(`OB_DEPTH)-1:0]         obs_load_addr,
        input  [`OB_WIDTH-1:0]                 obs_load_data,
        output                                 obs_store_en,
        output [$clog2(`OB_DEPTH)-1:0]         obs_store_addr,
        output [`OB_WIDTH-1:0]                 obs_store_data,
        //null


        // feature memory large access port
        output                                 fml_load_en,
        output [$clog2(`FM_DEPTH_L)-1:0]       fml_load_addr,
        input  [`FM_WIDTH-1:0]                 fml_load_data,
        output                                 fml_store_en,
        output [$clog2(`FM_DEPTH_L)-1:0]       fml_store_addr,
        output [`FM_WIDTH-1:0]                 fml_store_data,

        // feature memory small access port
        output                                 fms_load_en,
        output [$clog2(`FM_DEPTH_S)-1:0]       fms_load_addr,
        input  [`FM_WIDTH-1:0]                 fms_load_data,
        output                                 fms_store_en,
        output [$clog2(`FM_DEPTH_S)-1:0]       fms_store_addr,
        output [`FM_WIDTH-1:0]                 fms_store_data,

        ///////////////////////////////////////////////////////
        // cim memory small access port
        output                                 npul_store_en,
        output [$clog2(`CIM_DEPTH_L)-1:0]      npul_store_addr,
        output [`CIM_WIDTH-1:0]                npul_store_data,
        output                                 npus_store_en,
        output [$clog2(`CIM_DEPTH_S)-1:0]      npus_store_addr,
        output [`CIM_WIDTH-1:0]                npus_store_data,

        // exponent memory
        output                                 exp_load_en,
        output [$clog2(`EXP_DEPTH)-1:0]        exp_load_addr,
        input  [`EXP_WIDTH-1:0]                exp_load_data,
        output                                 exp_store_en,
        output [$clog2(`EXP_DEPTH)-1:0]        exp_store_addr,
        output [`EXP_WIDTH-1:0]                exp_store_data,
        ///////////////////////////////////////////////////////


        // configuration status registers access port
        output                                 csr_load_en,
        output [$clog2(`CSR_DEPTH)-1:0]        csr_load_addr,
        input  [`CSR_WIDTH-1:0]                csr_load_data,
        output                                 csr_store_en,
        output [$clog2(`CSR_DEPTH)-1:0]        csr_store_addr,
        output [`CSR_WIDTH-1:0]                csr_store_data

    );

    //byte address
    localparam WML_Size = `WM_DEPTH_L;
    localparam WMS_Size = `WM_DEPTH_S;

    localparam OBL_Size = `OB_DEPTH;
    localparam OBS_Size = `OB_DEPTH;

    localparam FML_Size = `FM_DEPTH_L;
    localparam FMS_Size = `FM_DEPTH_S;

    localparam CSR_Size = `CSR_DEPTH;
    ////////////////////////////////
    localparam NPUL_Size = `CIM_DEPTH_L;  // 4096
    localparam NPUS_Size = `CIM_DEPTH_S;  // 512

    localparam EXP_Size  = `EXP_DEPTH;    // 64
    ////////////////////////////////

    localparam WML_Addr_Offset     = 'd0;
    localparam WMS_Addr_Offset     = WML_Addr_Offset    +    WML_Size;
    localparam OBL_Addr_Offset     = WMS_Addr_Offset    +    WMS_Size;
    localparam OBS_Addr_Offset     = OBL_Addr_Offset    +    OBL_Size;
    localparam FML_Addr_Offset     = OBS_Addr_Offset    +    OBS_Size;
    localparam FMS_Addr_Offset     = FML_Addr_Offset    +    FML_Size;
    //////////////////////////////////////////////////////////////////
    localparam NPUL_Addr_Offset    = FMS_Addr_Offset    +    FMS_Size + `offset;
    localparam NPUS_Addr_Offset    = NPUL_Addr_Offset   +    NPUL_Size;
    localparam EXP_Addr_Offset     = NPUS_Addr_Offset   +    NPUS_Size;
    localparam CSR_Addr_Offset     = EXP_Addr_Offset   +    EXP_Size;
    // localparam CSR_Addr_Offset     = FMS_Addr_Offset    +    FMS_Size;
    //////////////////////////////////////////////////////////////////


    localparam WML_Addr_Start = WML_Addr_Offset;
    localparam WML_Addr_End   = WML_Addr_Offset + WML_Size - 1'b1;

    localparam WMS_Addr_Start = WMS_Addr_Offset;
    localparam WMS_Addr_End   = WMS_Addr_Offset + WMS_Size - 1'b1;

    localparam OBL_Addr_Start = OBL_Addr_Offset;
    localparam OBL_Addr_End   = OBL_Addr_Offset + OBL_Size - 1'b1;

    localparam OBS_Addr_Start = OBS_Addr_Offset;
    localparam OBS_Addr_End   = OBS_Addr_Offset + OBS_Size - 1'b1;

    localparam FML_Addr_Start = FML_Addr_Offset;
    localparam FML_Addr_End   = FML_Addr_Offset + FML_Size - 1'b1;

    localparam FMS_Addr_Start = FMS_Addr_Offset;
    localparam FMS_Addr_End   = FMS_Addr_Offset + FMS_Size - 1'b1;

    ///////////////////////////////////////////
    localparam NPUL_Addr_Start = NPUL_Addr_Offset;
    localparam NPUL_Addr_End   = NPUL_Addr_Offset + NPUL_Size - 1'b1;

    localparam NPUS_Addr_Start = NPUS_Addr_Offset;
    localparam NPUS_Addr_End   = NPUS_Addr_Offset + NPUS_Size - 1'b1;

    localparam EXP_Addr_Start  = EXP_Addr_Offset;
    localparam EXP_Addr_End    = EXP_Addr_Offset + EXP_Size - 1'b1;
    ///////////////////////////////////////////

    localparam CSR_Addr_Start = CSR_Addr_Offset;
    localparam CSR_Addr_End   = CSR_Addr_Offset + CSR_Size - 1'b1;

    wire is_load_wml_addr   ;
    wire is_load_wms_addr   ;
    wire is_load_obl_addr   ;
    wire is_load_obs_addr   ;
    wire is_load_fml_addr   ;
    wire is_load_fms_addr   ;
    wire is_load_csr_addr   ;
    //**************************7.18添加 exp_load
    wire is_load_exp_addr	;

    wire is_store_wml_addr  ;
    wire is_store_wms_addr  ;
    wire is_store_obl_addr  ;
    wire is_store_obs_addr  ;
    wire is_store_fml_addr  ;
    wire is_store_fms_addr  ;

    /////////////////////////
    wire is_store_npul_addr ;
    wire is_store_npus_addr ;
    wire is_store_exp_addr;
    /////////////////////////
    wire is_store_csr_addr  ;



    assign is_load_wml_addr     = (sys_load_addr >= WML_Addr_Start)  && (sys_load_addr <= WML_Addr_End);
    assign is_load_wms_addr     = (sys_load_addr >= WMS_Addr_Start)  && (sys_load_addr <= WMS_Addr_End);
    assign is_load_obl_addr     = (sys_load_addr >= OBL_Addr_Start)  && (sys_load_addr <= OBL_Addr_End);
    assign is_load_obs_addr     = (sys_load_addr >= OBS_Addr_Start)  && (sys_load_addr <= OBS_Addr_End);
    assign is_load_fml_addr     = (sys_load_addr >= FML_Addr_Start)  && (sys_load_addr <= FML_Addr_End);
    assign is_load_fms_addr     = (sys_load_addr >= FMS_Addr_Start)  && (sys_load_addr <= FMS_Addr_End);
    assign is_load_csr_addr     = (sys_load_addr >= CSR_Addr_Start)  && (sys_load_addr <= CSR_Addr_End);
    //******************************************************************************************************7.18添加 exp_load
    assign is_load_exp_addr     = (sys_load_addr >= EXP_Addr_Start)  && (sys_load_addr <= EXP_Addr_End);

    assign is_store_wml_addr    = (sys_store_addr >= WML_Addr_Start)  && (sys_store_addr <= WML_Addr_End);
    assign is_store_wms_addr    = (sys_store_addr >= WMS_Addr_Start)  && (sys_store_addr <= WMS_Addr_End);
    assign is_store_obl_addr    = (sys_store_addr >= OBL_Addr_Start)  && (sys_store_addr <= OBL_Addr_End);
    assign is_store_obs_addr    = (sys_store_addr >= OBS_Addr_Start)  && (sys_store_addr <= OBS_Addr_End);
    assign is_store_fml_addr    = (sys_store_addr >= FML_Addr_Start)  && (sys_store_addr <= FML_Addr_End);
    assign is_store_fms_addr    = (sys_store_addr >= FMS_Addr_Start)  && (sys_store_addr <= FMS_Addr_End);
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    assign is_store_npul_addr   = (sys_store_addr >= NPUL_Addr_Start) && (sys_store_addr <= NPUL_Addr_End);
    assign is_store_npus_addr   = (sys_store_addr >= NPUS_Addr_Start) && (sys_store_addr <= NPUS_Addr_End);
    assign is_store_exp_addr    = (sys_store_addr >= EXP_Addr_Start)  && (sys_store_addr <= EXP_Addr_End);
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    assign is_store_csr_addr    = (sys_store_addr >= CSR_Addr_Start)  && (sys_store_addr <= CSR_Addr_End);


    assign wml_load_en    = sys_load_en && is_load_wml_addr;
    assign wml_load_addr  = wml_load_en  ? (sys_load_addr - WML_Addr_Start) : 'd0;
    assign wml_store_en   = sys_store_en && is_store_wml_addr;
    assign wml_store_addr = wml_store_en ? (sys_store_addr - WML_Addr_Start): 'd0;
    assign wml_store_data = wml_store_en ? sys_store_data : 'd0;

    assign wms_load_en    = sys_load_en && is_load_wms_addr;
    assign wms_load_addr  = wms_load_en  ? (sys_load_addr - WMS_Addr_Start) : 'd0;
    assign wms_store_en   = sys_store_en && is_store_wms_addr;
    assign wms_store_addr = wms_store_en ? (sys_store_addr - WMS_Addr_Start): 'd0;
    assign wms_store_data = wms_store_en ? sys_store_data : 'd0;

    assign obl_load_en    = sys_load_en && is_load_obl_addr;
    assign obl_load_addr  = obl_load_en  ? (sys_load_addr - OBL_Addr_Start) : 'd0;
    assign obl_store_en   = sys_store_en && is_store_obl_addr;
    assign obl_store_addr = obl_store_en ? (sys_store_addr - OBL_Addr_Start): 'd0;
    assign obl_store_data = obl_store_en ? sys_store_data : 'd0;

    assign obs_load_en    = sys_load_en && is_load_obs_addr;
    assign obs_load_addr  = obs_load_en  ? (sys_load_addr - OBS_Addr_Start) : 'd0;
    assign obs_store_en   = sys_store_en && is_store_obs_addr;
    assign obs_store_addr = obs_store_en ? (sys_store_addr - OBS_Addr_Start): 'd0;
    assign obs_store_data = obs_store_en ? sys_store_data : 'd0;

    assign fml_load_en    = sys_load_en && is_load_fml_addr;
    assign fml_load_addr  = fml_load_en  ? (sys_load_addr - FML_Addr_Start) : 'd0;
    assign fml_store_en   = sys_store_en && is_store_fml_addr;
    assign fml_store_addr = fml_store_en ? (sys_store_addr - FML_Addr_Start): 'd0;
    assign fml_store_data = fml_store_en ? sys_store_data : 'd0;

    assign fms_load_en    = sys_load_en && is_load_fms_addr;
    assign fms_load_addr  = fms_load_en  ? (sys_load_addr - FMS_Addr_Start) : 'd0;
    assign fms_store_en   = sys_store_en && is_store_fms_addr;
    assign fms_store_addr = fms_store_en ? (sys_store_addr - FMS_Addr_Start): 'd0;
    assign fms_store_data = fms_store_en ? sys_store_data : 'd0;

    ///////////////////////////////////////////////////////////
    assign npul_store_en   = sys_store_en && is_store_npul_addr;
    assign npul_store_addr = npul_store_en ? (sys_store_addr - NPUL_Addr_Start) : 'd0;
    assign npul_store_data = npul_store_en ? sys_store_data : 'd0;
    assign npus_store_en   = sys_store_en && is_store_npus_addr;
    assign npus_store_addr = npus_store_en ? (sys_store_addr - NPUS_Addr_Start) : 'd0;
    assign npus_store_data = npus_store_en ? sys_store_data : 'd0;
    //*********************************************************************************7.18添加 exp_load
    assign exp_load_en     = sys_load_en  && is_load_exp_addr;
    assign exp_load_addr   = exp_load_en  ? (sys_load_addr - EXP_Addr_Start) : 'd0;
    assign exp_store_en    = sys_store_en && is_store_exp_addr;
    assign exp_store_addr  = exp_store_en  ? (sys_store_addr - EXP_Addr_Start) : 'd0;
    assign exp_store_data  = exp_store_en  ? sys_store_data : 'd0;
    ///////////////////////////////////////////////////////////


    assign csr_load_en    = sys_load_en && is_load_csr_addr;
    assign csr_load_addr  = csr_load_en  ? (sys_load_addr - CSR_Addr_Start) : 'd0;
    assign csr_store_en   = sys_store_en && is_store_csr_addr;
    assign csr_store_addr = csr_store_en ? (sys_store_addr - CSR_Addr_Start) : 'd0;
    assign csr_store_data = csr_store_en ? sys_store_data : 'd0;

    reg wml_load_en_d1;
    reg wms_load_en_d1;
    reg obl_load_en_d1;
    reg obs_load_en_d1;
    reg fml_load_en_d1;
    reg fms_load_en_d1;
    reg csr_load_en_d1;
    reg exp_load_en_d1;

    wire is_load_en;
    assign is_load_en = wml_load_en || wms_load_en || obl_load_en || obs_load_en ||fml_load_en || fms_load_en || csr_load_en || exp_load_en;
    always @(posedge clk or negedge rstn)
        if(~rstn) begin
            wml_load_en_d1 <='b0;
            wms_load_en_d1 <='b0;
            obl_load_en_d1 <='b0;
            obs_load_en_d1 <='b0;
            fml_load_en_d1 <='b0;
            fms_load_en_d1 <='b0;
            csr_load_en_d1 <='b0;
            exp_load_en_d1 <='b0;
        end
        else if(is_load_en) begin
            wml_load_en_d1  <= wml_load_en;
            wms_load_en_d1  <= wms_load_en;
            obl_load_en_d1  <= obl_load_en;
            obs_load_en_d1  <= obs_load_en;
            fml_load_en_d1  <= fml_load_en;
            fms_load_en_d1  <= fms_load_en;
            csr_load_en_d1  <= csr_load_en;
            exp_load_en_d1  <= exp_load_en;
        end

    assign sys_load_data =  ( {64{wml_load_en_d1}}  &  wml_load_data )  |
           					( {64{wms_load_en_d1}}  &  wms_load_data )  |
           					( {64{obl_load_en_d1}}  &  obl_load_data )  |
           					( {64{obs_load_en_d1}}  &  obs_load_data )  |
           					( {64{fml_load_en_d1}}  &  fml_load_data )  |
           					( {64{fms_load_en_d1}}  &  fms_load_data )  |
           					( {64{csr_load_en_d1}}  &  csr_load_data )  |
           					( {64{exp_load_en_d1}}  &  exp_load_data )  ;

	assign sys_load_data_vld =  wml_load_en_d1 ||
    							wms_load_en_d1 ||
    							obl_load_en_d1 ||
    							obs_load_en_d1 ||
    							fml_load_en_d1 ||
    							fms_load_en_d1 ||
    							csr_load_en_d1 ||
    							exp_load_en_d1 ;


endmodule
