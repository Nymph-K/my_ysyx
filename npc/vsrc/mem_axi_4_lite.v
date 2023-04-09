/*************************************************************
 * @ name           : mem_axi_4_lite.v
 * @ description    : Mem using AXI4-lite bus interface
 * @ use module     : None
 * @ author         : K
 * @ date modified  : 2023-3-18
 *************************************************************/
`ifndef MEM_AXI_4_LITE_V
`define MEM_AXI_4_LITE_V

/*
 *    .----.    .----.    .----.    .----.
 *    |    |    |    |    |    |    |    |
 *----'    '----'    '----'    '----'    '
 *
 *  AW,W        BR
 */

module mem_axi_4_lite #(
    parameter AXI_DATA_WIDTH    = 64,
    parameter AXI_ADDR_WIDTH    = 32) (
    //Global
    input       wire                                AXI_ACLK,
    input       wire                                AXI_ARESETN,
    //AW    
    input       wire [AXI_ADDR_WIDTH-1 : 0]         AXI_AWADDR,
    input       wire [2 : 0]                        AXI_AWPROT,
    input       wire                                AXI_AWVALID,
    output      wire                                AXI_AWREADY,
    //W 
    input       wire [AXI_DATA_WIDTH-1 : 0]         AXI_WDATA,
    input       wire [(AXI_DATA_WIDTH/8)-1 : 0]     AXI_WSTRB,
    input       wire                                AXI_WVALID,
    output      wire                                AXI_WREADY,
    //BR    
    output      wire [1 : 0]                        AXI_BRESP,
    output      wire                                AXI_BVALID,
    input       wire                                AXI_BREADY,
    //AR    
    input       wire [AXI_ADDR_WIDTH-1 : 0]         AXI_ARADDR,
    input       wire                                AXI_ARVALID,
    input       wire [2 : 0]                        AXI_ARPROT,
    output      wire                                AXI_ARREADY,
    //R 
    output      wire [AXI_DATA_WIDTH-1 : 0]         AXI_RDATA,
    output      wire [1 : 0]                        AXI_RRESP,
    output      wire                                AXI_RVALID,
    input       wire                                AXI_RREADY
);
    
    //-----------------------------------------register---------------------------------------------------
    reg [AXI_ADDR_WIDTH-1 : 0] 					    axi_awaddr;
    reg  											axi_awready;
    reg  											axi_wready;
    reg [AXI_DATA_WIDTH-1 : 0] 					    axi_wdata;
    reg [(AXI_DATA_WIDTH/8)-1 : 0]                  axi_wstrb;
    //reg [1 : 0] 									axi_bresp;
    reg  											axi_bvalid;
    reg [AXI_ADDR_WIDTH-1 : 0] 					    axi_araddr;
    reg  											axi_arready;
    reg [AXI_DATA_WIDTH-1 : 0] 					    axi_rdata;
    //reg [1 : 0] 									axi_rresp;
    reg  											axi_rvalid;
    
    localparam  RESP_OKAY   = 2'b00,
                RESP_EXOKAY = 2'b00,
                RESP_SLVERR = 2'b00,
                RESP_DECERR = 2'b00;

    assign AXI_AWREADY      = axi_awready;
    assign AXI_WREADY	    = axi_wready;
    assign AXI_BRESP	    = RESP_OKAY;
    assign AXI_BVALID	    = axi_bvalid;
    assign AXI_ARREADY      = axi_arready;
    assign AXI_RDATA	    = axi_rdata;
    assign AXI_RRESP	    = RESP_OKAY;
    assign AXI_RVALID	    = axi_rvalid;
    
    //--------------------------------------------FSM-Moore------------------------------------------------
    reg [2: 0] axi_rstate;
    reg [2: 0] axi_wstate;
    
    localparam  FSM_IDLE    = 3'b000 ,
                FSM_AWVALID = 3'b001 ,
                FSM_WVALID  = 3'b010 ,
                FSM_BVALID  = 3'b011 ,
                FSM_ARVALID = 3'b100 ,
                FSM_ERROR   = 3'b111 ;

import "DPI-C" function void paddr_read(input longint raddr, output longint mem_r_data);
import "DPI-C" function void paddr_write(input longint waddr, input longint mem_w_data, input byte wmask);

    //--------------------------------axi read fsm-------------------------------------------
    always @(posedge AXI_ACLK)
    begin
        if (~AXI_ARESETN)
        begin
            axi_rstate      <= FSM_IDLE;
            axi_araddr      <= 0;
            axi_rdata        = 0;
            axi_arready     <= 1'b1;
            axi_rvalid      <= 1'b0;
        end else begin
            case(axi_rstate)
                FSM_IDLE    : 
                    if(AXI_ARVALID)   begin 
                        axi_rstate      <= FSM_ARVALID;
                        axi_arready     <= 1'b0;
                        axi_araddr      <= AXI_ARADDR;
                        axi_rvalid      <= 1'b1;
                        paddr_read({32'b0, AXI_ARADDR}, axi_rdata);
                    end

                FSM_ARVALID : 
                    if(AXI_RREADY)   begin 
                        axi_rstate      <= FSM_IDLE;
                        axi_arready     <= 1'b1;
                        axi_rvalid      <= 1'b0;
                    end

                default     : begin 
                        axi_rstate      <= FSM_IDLE;
                        axi_araddr      <= 0;
                        axi_arready     <= 1'b1;
                        axi_rvalid      <= 1'b0;
                    end
            endcase
        end
    end
    
    //--------------------------------axi write fsm-------------------------------------------
    always @(posedge AXI_ACLK)
    begin
        if (~AXI_ARESETN)
        begin
            axi_wstate      <= FSM_IDLE;
            axi_awready     <= 1'b1;
            axi_awaddr      <= 0;
            axi_wready      <= 1'b1;
            axi_wdata       <= 0;
            axi_wstrb       <= 0;
            axi_bvalid      <= 1'b0;
        end else begin
            case(axi_wstate)
                FSM_IDLE    : 
                    if(AXI_AWVALID && AXI_WVALID)   begin 
                        axi_wstate      <= FSM_BVALID;
                        axi_bvalid      <= 1'b1;
                        axi_awready     <= 1'b0;
                        axi_awaddr      <= AXI_AWADDR;
                        axi_wready      <= 1'b0;
                        axi_wdata       <= AXI_WDATA;
                        axi_wstrb       <= AXI_WSTRB;
                        paddr_write({32'b0, AXI_AWADDR}, AXI_WDATA, AXI_WSTRB);
                    end
                    else if(AXI_AWVALID)   begin 
                        axi_wstate      <= FSM_AWVALID;
                        axi_awready     <= 1'b0;
                        axi_awaddr      <= AXI_AWADDR;
                    end
                    else if(AXI_WVALID)   begin 
                        axi_wstate      <= FSM_WVALID;
                        axi_wready      <= 1'b0;
                        axi_wdata       <= AXI_WDATA;
                        axi_wstrb       <= AXI_WSTRB;
                    end
    
                FSM_AWVALID :
                    if(AXI_WVALID)   begin 
                        axi_wstate      <= FSM_BVALID;
                        axi_bvalid      <= 1'b1;
                        axi_wready      <= 1'b0;
                        axi_wdata       <= AXI_WDATA;
                        axi_wstrb       <= AXI_WSTRB;
                        paddr_write({32'b0, axi_awaddr}, AXI_WDATA, AXI_WSTRB);
                    end
    
                FSM_WVALID  :
                    if(AXI_AWVALID)   begin 
                        axi_wstate      <= FSM_BVALID;
                        axi_bvalid      <= 1'b1;
                        axi_awready     <= 1'b0;
                        axi_awaddr      <= AXI_AWADDR;
                        paddr_write({32'b0, AXI_AWADDR}, axi_wdata, axi_wstrb);
                    end
    
                FSM_BVALID  : 
                    if(AXI_BREADY)   begin 
                        axi_wstate      <= FSM_IDLE;
                        axi_bvalid      <= 1'b0;
                        axi_awready     <= 1'b1;
                        axi_wready      <= 1'b1;
                    end

                default     : begin 
                        axi_wstate      <= FSM_IDLE;
                        axi_awready     <= 1'b1;
                        axi_awaddr      <= 0;
                        axi_wready      <= 1'b1;
                        axi_wdata       <= 0;
                        axi_bvalid      <= 1'b0;
                    end
            endcase
        end
    end
    
endmodule //mem_axi_4_lite

`endif
