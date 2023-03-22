/*************************************************************
 * @ name           : master_axi_4_lite.v
 * @ description    : AXI4-lite bus interface Master
 * @ use module     : None
 * @ author         : K
 * @ chnge date     : 2023-3-18
 *************************************************************/
`ifndef MASTER_AXI_4_LITE_V
`define MASTER_AXI_4_LITE_V

module master_axi_4_lite #(
    parameter AXI_DATA_WIDTH    = 64,
    parameter AXI_ADDR_WIDTH    = 32) (
    //write
    input      wire                                w_valid, 
    input      wire [AXI_ADDR_WIDTH-1 : 0]         w_addr,
    input      wire [AXI_DATA_WIDTH-1 : 0]         w_data,
    input      wire [7 : 0]                        w_strb,
    output     wire                                w_ready,
    //read
    input      wire                                r_ready,
    input      wire [AXI_ADDR_WIDTH-1 : 0]         r_addr,
    output     wire                                r_valid,
    output     wire [AXI_DATA_WIDTH-1 : 0]         r_data,
    //Global
    input      wire                                AXI_ACLK,
    input      wire                                AXI_ARESETN,
    //AW    
    output     wire [AXI_ADDR_WIDTH-1 : 0]         AXI_AWADDR,
    output     wire [2 : 0]                        AXI_AWPROT,
    output     wire                                AXI_AWVALID,
    input      wire                                AXI_AWREADY,
    //W 
    output     wire [AXI_DATA_WIDTH-1 : 0]         AXI_WDATA,
    output     wire [(AXI_DATA_WIDTH/8)-1 : 0]     AXI_WSTRB,
    output     wire                                AXI_WVALID,
    input      wire                                AXI_WREADY,
    //BR    
    input      wire [1 : 0]                        AXI_BRESP,
    input      wire                                AXI_BVALID,
    output     wire                                AXI_BREADY,
    //AR    
    output     wire [AXI_ADDR_WIDTH-1 : 0]         AXI_ARADDR,
    output     wire                                AXI_ARVALID,
    output     wire [2 : 0]                        AXI_ARPROT,
    input      wire                                AXI_ARREADY,
    //R 
    input      wire [AXI_DATA_WIDTH-1 : 0]         AXI_RDATA,
    input      wire [1 : 0]                        AXI_RRESP,
    input      wire                                AXI_RVALID,
    output     wire                                AXI_RREADY
);
    
    //-----------------------------------------register---------------------------------------------------
    reg                                           axi_awvalid;
    reg                                           axi_wvalid;
    reg                                           axi_bready;
    reg                                           axi_arvalid;
    reg                                           axi_rready;

    assign w_ready = AXI_BVALID;
    assign r_valid = AXI_RVALID;

    assign AXI_AWADDR       = w_addr;
    assign AXI_AWPROT       = 2'b00;
    assign AXI_AWVALID      = axi_awvalid;

    assign AXI_WDATA        = w_data;
    assign AXI_WSTRB        = w_strb;
    assign AXI_WVALID       = axi_wvalid;

    assign AXI_BREADY       = axi_bready;

    assign AXI_ARADDR       = r_addr;
    assign AXI_ARVALID      = axi_arvalid;
    assign AXI_ARPROT	    = 2'b00;

    assign AXI_RREADY       = axi_rready;
    
    //--------------------------------------------FSM-Moore------------------------------------------------
    reg [2: 0] state;
    parameter [2:0]
        FSM_IDLE    = 3'b000 ,
        FSM_WVALID     = 3'b001 ,
        FSM_AWREADY = 3'b010 ,
        FSM_WREADY  = 3'b011 ,
        FSM_BVALID  = 3'b100 ,
        FSM_RREADY     = 3'b101 ,
        FSM_ARREADY  = 3'b110 ,
        FSM_ERROR   = 3'b111 ;

    always @(posedge AXI_ACLK)
    begin
        if (~AXI_ARESETN)
        begin
            state           <= FSM_IDLE;
            axi_awvalid     <= 1'b0;
            axi_wvalid      <= 1'b0;
            axi_bready      <= 1'b1;
            axi_arvalid     <= 1'b0;
            axi_rready      <= 1'b1;
        end else begin
            case(state)
                FSM_IDLE    : begin
                    if(w_valid)   begin 
                        state           <= FSM_WVALID;
                        axi_awvalid     <= 1'b1;
                        axi_wvalid      <= 1'b1;
                    end
                    else if(r_ready)   begin 
                        state           <= FSM_RREADY;
                        axi_arvalid     <= 1'b1;
                    end
                    axi_bready      <= 1'b1;
                    axi_rready      <= 1'b1;
                end

                FSM_WVALID :
                    if(AXI_AWREADY && AXI_WREADY)   begin 
                        state           <= FSM_BVALID;
                        axi_awvalid     <= 1'b0;
                        axi_wvalid      <= 1'b0;
                    end
                    else if(AXI_AWREADY)   begin 
                        state           <= FSM_AWREADY;
                        axi_awvalid     <= 1'b0;
                    end
                    else if(AXI_WREADY)   begin 
                        state           <= FSM_WREADY;
                        axi_wvalid      <= 1'b0;
                    end
    
                FSM_AWREADY  :
                    if(AXI_WREADY)   begin 
                        state           <= FSM_BVALID;
                        axi_wvalid      <= 1'b0;
                    end
    
                FSM_WREADY  :
                    if(AXI_AWREADY)   begin 
                        state           <= FSM_BVALID;
                        axi_awvalid     <= 1'b0;
                    end

                FSM_BVALID  : 
                    if(AXI_BVALID)   begin 
                        state           <= FSM_IDLE;
                        axi_bready      <= 1'b0;
                    end

                FSM_RREADY : 
                    if(AXI_ARREADY)   begin 
                        state           <= FSM_ARREADY;
                        axi_arvalid     <= 1'b0;
                    end

                FSM_ARREADY : 
                    if(AXI_RVALID)   begin 
                        state           <= FSM_IDLE;
                        axi_rready      <= 1'b0;
                    end

                default     : begin 
                    state           <= FSM_IDLE;
                    axi_awvalid     <= 1'b0;
                    axi_wvalid      <= 1'b0;
                    axi_bready      <= 1'b1;
                    axi_arvalid     <= 1'b0;
                    axi_rready      <= 1'b1;
                    end
            endcase
        end
    end
    
endmodule //master_axi_4_lite

`endif
