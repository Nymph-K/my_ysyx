/*************************************************************
 * @ name           : attributer_axi_4_lite.v
 * @ description    : Attributer AXI4-lite bus
 * @ use module     : None
 * @ author         : K
 * @ chnge date     : 2023-3-31
 *************************************************************/
`ifndef ATTRIBUTER_AXI_4_LITE_V
`define ATTRIBUTER_AXI_4_LITE_V

// A > B

module attributer_axi_4_lite #(
    parameter AXI_DATA_WIDTH    = 64,
    parameter AXI_ADDR_WIDTH    = 32) (
    //Global
    input       wire                                AXI_ACLK,
    input       wire                                AXI_ARESETN,

    //AW    
    input       wire [AXI_ADDR_WIDTH-1 : 0]         A_AXI_AWADDR,
    input       wire [2 : 0]                        A_AXI_AWPROT,
    input       wire                                A_AXI_AWVALID,
    output      reg                                 A_AXI_AWREADY,
    //W 
    input       wire [AXI_DATA_WIDTH-1 : 0]         A_AXI_WDATA,
    input       wire [(AXI_DATA_WIDTH/8)-1 : 0]     A_AXI_WSTRB,
    input       wire                                A_AXI_WVALID,
    output      reg                                 A_AXI_WREADY,
    //BR    
    output      reg  [1 : 0]                        A_AXI_BRESP,
    output      reg                                 A_AXI_BVALID,
    input       wire                                A_AXI_BREADY,
    //AR    
    input       wire [AXI_ADDR_WIDTH-1 : 0]         A_AXI_ARADDR,
    input       wire                                A_AXI_ARVALID,
    input       wire [2 : 0]                        A_AXI_ARPROT,
    output      reg                                 A_AXI_ARREADY,
    //R 
    output      reg  [AXI_DATA_WIDTH-1 : 0]         A_AXI_RDATA,
    output      reg  [1 : 0]                        A_AXI_RRESP,
    output      reg                                 A_AXI_RVALID,
    input       wire                                A_AXI_RREADY,

    //AW    
    input       wire [AXI_ADDR_WIDTH-1 : 0]         B_AXI_AWADDR,
    input       wire [2 : 0]                        B_AXI_AWPROT,
    input       wire                                B_AXI_AWVALID,
    output      reg                                 B_AXI_AWREADY,
    //W 
    input       wire [AXI_DATA_WIDTH-1 : 0]         B_AXI_WDATA,
    input       wire [(AXI_DATA_WIDTH/8)-1 : 0]     B_AXI_WSTRB,
    input       wire                                B_AXI_WVALID,
    output      reg                                 B_AXI_WREADY,
    //BR    
    output      reg  [1 : 0]                        B_AXI_BRESP,
    output      reg                                 B_AXI_BVALID,
    input       wire                                B_AXI_BREADY,
    //AR    
    input       wire [AXI_ADDR_WIDTH-1 : 0]         B_AXI_ARADDR,
    input       wire                                B_AXI_ARVALID,
    input       wire [2 : 0]                        B_AXI_ARPROT,
    output      reg                                 B_AXI_ARREADY,
    //R 
    output      reg  [AXI_DATA_WIDTH-1 : 0]         B_AXI_RDATA,
    output      reg  [1 : 0]                        B_AXI_RRESP,
    output      reg                                 B_AXI_RVALID,
    input       wire                                B_AXI_RREADY,

    //AW    
    output      reg  [AXI_ADDR_WIDTH-1 : 0]         O_AXI_AWADDR,
    output      reg  [2 : 0]                        O_AXI_AWPROT,
    output      reg                                 O_AXI_AWVALID,
    input       wire                                O_AXI_AWREADY,
    //W 
    output      reg  [AXI_DATA_WIDTH-1 : 0]         O_AXI_WDATA,
    output      reg  [(AXI_DATA_WIDTH/8)-1 : 0]     O_AXI_WSTRB,
    output      reg                                 O_AXI_WVALID,
    input       wire                                O_AXI_WREADY,
    //BR    
    input       wire [1 : 0]                        O_AXI_BRESP,
    input       wire                                O_AXI_BVALID,
    output      reg                                 O_AXI_BREADY,
    //AR    
    output      reg  [AXI_ADDR_WIDTH-1 : 0]         O_AXI_ARADDR,
    output      reg                                 O_AXI_ARVALID,
    output      reg  [2 : 0]                        O_AXI_ARPROT,
    input       wire                                O_AXI_ARREADY,
    //R 
    input       wire [AXI_DATA_WIDTH-1 : 0]         O_AXI_RDATA,
    input       wire [1 : 0]                        O_AXI_RRESP,
    input       wire                                O_AXI_RVALID,
    output      reg                                 O_AXI_RREADY
);
    
    reg [2:0] atb_wstate;
    reg [2:0] atb_rstate;
    
    wire a_axi_w = A_AXI_AWVALID | A_AXI_WVALID;
    wire a_axi_r = A_AXI_ARVALID;
    wire b_axi_w = B_AXI_AWVALID | B_AXI_WVALID;
    wire b_axi_r = B_AXI_ARVALID;

    localparam  FSM_IDLE    = 3'b000 ,
                FSM_AW      = 3'b001 ,
                FSM_BW      = 3'b010 ,
                FSM_AR      = 3'b011 ,
                FSM_BR      = 3'b100 ;

    //--------------------------------attributer write fsm-------------------------------------------
    always @(posedge AXI_ACLK) begin
        if (~AXI_ARESETN) begin
            atb_wstate <= FSM_IDLE;
        end else begin
            case (atb_wstate)
                FSM_IDLE: begin
                    if (a_axi_w) begin
                        atb_wstate <= FSM_AW;
                    end else if (b_axi_w) begin
                        atb_wstate <= FSM_BW;
                    end
                end
                FSM_AW: begin
                    if (A_AXI_BVALID && A_AXI_BREADY) begin
                        atb_wstate <= FSM_IDLE;
                    end
                end
                FSM_BW: begin
                    if (B_AXI_BVALID && B_AXI_BREADY) begin
                        atb_wstate <= FSM_IDLE;
                    end
                end
                default: atb_wstate <= FSM_IDLE;
            endcase
        end
    end

    //--------------------------------attributer write output-------------------------------------------
    always @(*) begin
        case (atb_wstate)
            FSM_IDLE: begin
                if (b_axi_w && !a_axi_w) begin
                    O_AXI_AWADDR    = B_AXI_AWADDR;
                    O_AXI_AWPROT    = B_AXI_AWPROT;
                    O_AXI_AWVALID   = B_AXI_AWVALID;
                    B_AXI_AWREADY   = O_AXI_AWREADY;
                    // A_AXI_AWREADY   = 0;

                    O_AXI_WDATA     = B_AXI_WDATA;
                    O_AXI_WSTRB     = B_AXI_WSTRB;
                    O_AXI_WVALID    = B_AXI_WVALID;
                    B_AXI_WREADY    = O_AXI_WREADY;
                    // A_AXI_WREADY    = 0;

                    B_AXI_BRESP     = O_AXI_BRESP;
                    B_AXI_BVALID    = O_AXI_BVALID;
                    // A_AXI_BRESP     = 0;
                    A_AXI_BVALID    = 0;
                    O_AXI_BREADY    = B_AXI_BREADY;
                end else begin
                    O_AXI_AWADDR    = A_AXI_AWADDR;
                    O_AXI_AWPROT    = A_AXI_AWPROT;
                    O_AXI_AWVALID   = A_AXI_AWVALID;
                    A_AXI_AWREADY   = O_AXI_AWREADY;
                    // B_AXI_AWREADY   = 0;

                    O_AXI_WDATA     = A_AXI_WDATA;
                    O_AXI_WSTRB     = A_AXI_WSTRB;
                    O_AXI_WVALID    = A_AXI_WVALID;
                    A_AXI_WREADY    = O_AXI_WREADY;
                    // B_AXI_WREADY    = 0;

                    A_AXI_BRESP     = O_AXI_BRESP;
                    A_AXI_BVALID    = O_AXI_BVALID;
                    // B_AXI_BRESP     = 0;
                    B_AXI_BVALID    = 0;
                    O_AXI_BREADY    = A_AXI_BREADY;
                end
            end
            FSM_AW: begin
                    O_AXI_AWADDR    = A_AXI_AWADDR;
                    O_AXI_AWPROT    = A_AXI_AWPROT;
                    O_AXI_AWVALID   = A_AXI_AWVALID;
                    A_AXI_AWREADY   = O_AXI_AWREADY;
                    // B_AXI_AWREADY   = 0;

                    O_AXI_WDATA     = A_AXI_WDATA;
                    O_AXI_WSTRB     = A_AXI_WSTRB;
                    O_AXI_WVALID    = A_AXI_WVALID;
                    A_AXI_WREADY    = O_AXI_WREADY;
                    // B_AXI_WREADY    = 0;

                    A_AXI_BRESP     = O_AXI_BRESP;
                    A_AXI_BVALID    = O_AXI_BVALID;
                    // B_AXI_BRESP     = 0;
                    B_AXI_BVALID    = 0;
                    O_AXI_BREADY    = A_AXI_BREADY;
            end
            FSM_BW: begin
                    O_AXI_AWADDR    = B_AXI_AWADDR;
                    O_AXI_AWPROT    = B_AXI_AWPROT;
                    O_AXI_AWVALID   = B_AXI_AWVALID;
                    B_AXI_AWREADY   = O_AXI_AWREADY;
                    // A_AXI_AWREADY   = 0;

                    O_AXI_WDATA     = B_AXI_WDATA;
                    O_AXI_WSTRB     = B_AXI_WSTRB;
                    O_AXI_WVALID    = B_AXI_WVALID;
                    B_AXI_WREADY    = O_AXI_WREADY;
                    // A_AXI_WREADY    = 0;

                    B_AXI_BRESP     = O_AXI_BRESP;
                    B_AXI_BVALID    = O_AXI_BVALID;
                    // A_AXI_BRESP     = 0;
                    A_AXI_BVALID    = 0;
                    O_AXI_BREADY    = B_AXI_BREADY;
            end

            default: begin
                if (b_axi_w && !a_axi_w) begin
                    O_AXI_AWADDR    = B_AXI_AWADDR;
                    O_AXI_AWPROT    = B_AXI_AWPROT;
                    O_AXI_AWVALID   = B_AXI_AWVALID;
                    B_AXI_AWREADY   = O_AXI_AWREADY;
                    // A_AXI_AWREADY   = 0;

                    O_AXI_WDATA     = B_AXI_WDATA;
                    O_AXI_WSTRB     = B_AXI_WSTRB;
                    O_AXI_WVALID    = B_AXI_WVALID;
                    B_AXI_WREADY    = O_AXI_WREADY;
                    // A_AXI_WREADY    = 0;

                    B_AXI_BRESP     = O_AXI_BRESP;
                    B_AXI_BVALID    = O_AXI_BVALID;
                    // A_AXI_BRESP     = 0;
                    A_AXI_BVALID    = 0;
                    O_AXI_BREADY    = B_AXI_BREADY;
                end else begin
                    O_AXI_AWADDR    = A_AXI_AWADDR;
                    O_AXI_AWPROT    = A_AXI_AWPROT;
                    O_AXI_AWVALID   = A_AXI_AWVALID;
                    A_AXI_AWREADY   = O_AXI_AWREADY;
                    // B_AXI_AWREADY   = 0;

                    O_AXI_WDATA     = A_AXI_WDATA;
                    O_AXI_WSTRB     = A_AXI_WSTRB;
                    O_AXI_WVALID    = A_AXI_WVALID;
                    A_AXI_WREADY    = O_AXI_WREADY;
                    // B_AXI_WREADY    = 0;

                    A_AXI_BRESP     = O_AXI_BRESP;
                    A_AXI_BVALID    = O_AXI_BVALID;
                    // B_AXI_BRESP     = 0;
                    B_AXI_BVALID    = 0;
                    O_AXI_BREADY    = A_AXI_BREADY;
                end
            end
        endcase
    end
    
    //--------------------------------attributer read fsm-------------------------------------------
    always @(posedge AXI_ACLK) begin
        if (~AXI_ARESETN) begin
            atb_rstate <= FSM_IDLE;
        end else begin
            case (atb_rstate)
                FSM_IDLE: begin
                    if (a_axi_r) begin
                        atb_rstate <= FSM_AR;
                    end else if (b_axi_r) begin
                        atb_rstate <= FSM_BR;
                    end
                end
                FSM_AR: begin
                    if (A_AXI_RVALID && A_AXI_RREADY) begin
                        atb_rstate <= FSM_IDLE;
                    end
                end
                FSM_BR: begin
                    if (B_AXI_RVALID && B_AXI_RREADY) begin
                        atb_rstate <= FSM_IDLE;
                    end
                end
                default: atb_rstate <= FSM_IDLE;
            endcase
        end
    end
    
    //--------------------------------attributer read output-------------------------------------------
    always @(*) begin
        case (atb_rstate)
            FSM_IDLE: begin
                if (b_axi_r && !a_axi_r) begin
                    O_AXI_ARADDR    = B_AXI_ARADDR;
                    O_AXI_ARVALID   = B_AXI_ARVALID;
                    O_AXI_ARPROT    = B_AXI_ARPROT;
                    B_AXI_ARREADY   = O_AXI_ARREADY;
                    // A_AXI_ARREADY   = 0;
                    
                    //B_AXI_RDATA     = O_AXI_RDATA;
                    B_AXI_RRESP     = O_AXI_RRESP;
                    B_AXI_RVALID    = O_AXI_RVALID;
                    // A_AXI_RDATA     = 0;
                    // A_AXI_RRESP     = 0;
                    A_AXI_RVALID    = 0;
                    O_AXI_RREADY    = B_AXI_RREADY;
                end else begin
                    O_AXI_ARADDR    = A_AXI_ARADDR;
                    O_AXI_ARVALID   = A_AXI_ARVALID;
                    O_AXI_ARPROT    = A_AXI_ARPROT;
                    A_AXI_ARREADY   = O_AXI_ARREADY;
                    // B_AXI_ARREADY   = 0;
                    
                    //A_AXI_RDATA     = O_AXI_RDATA;
                    A_AXI_RRESP     = O_AXI_RRESP;
                    A_AXI_RVALID    = O_AXI_RVALID;
                    // B_AXI_RDATA     = 0;
                    // B_AXI_RRESP     = 0;
                    B_AXI_RVALID    = 0;
                    O_AXI_RREADY    = A_AXI_RREADY;
                end
            end
            FSM_AR: begin
                    O_AXI_ARADDR    = A_AXI_ARADDR;
                    O_AXI_ARVALID   = A_AXI_ARVALID;
                    O_AXI_ARPROT    = A_AXI_ARPROT;
                    A_AXI_ARREADY   = O_AXI_ARREADY;
                    // B_AXI_ARREADY   = 0;
                    
                    A_AXI_RDATA     = O_AXI_RDATA;
                    A_AXI_RRESP     = O_AXI_RRESP;
                    A_AXI_RVALID    = O_AXI_RVALID;
                    // B_AXI_RDATA     = 0;
                    // B_AXI_RRESP     = 0;
                    B_AXI_RVALID    = 0;
                    O_AXI_RREADY    = A_AXI_RREADY;
            end
            FSM_BR: begin
                    O_AXI_ARADDR    = B_AXI_ARADDR;
                    O_AXI_ARVALID   = B_AXI_ARVALID;
                    O_AXI_ARPROT    = B_AXI_ARPROT;
                    B_AXI_ARREADY   = O_AXI_ARREADY;
                    // A_AXI_ARREADY   = 0;
                    
                    B_AXI_RDATA     = O_AXI_RDATA;
                    B_AXI_RRESP     = O_AXI_RRESP;
                    B_AXI_RVALID    = O_AXI_RVALID;
                    // A_AXI_RDATA     = 0;
                    // A_AXI_RRESP     = 0;
                    A_AXI_RVALID    = 0;
                    O_AXI_RREADY    = B_AXI_RREADY;
            end

            default: begin
                if (b_axi_r && !a_axi_r) begin
                    O_AXI_ARADDR    = B_AXI_ARADDR;
                    O_AXI_ARVALID   = B_AXI_ARVALID;
                    O_AXI_ARPROT    = B_AXI_ARPROT;
                    B_AXI_ARREADY   = O_AXI_ARREADY;
                    // A_AXI_ARREADY   = 0;
                    
                    //B_AXI_RDATA     = O_AXI_RDATA;
                    B_AXI_RRESP     = O_AXI_RRESP;
                    B_AXI_RVALID    = O_AXI_RVALID;
                    // A_AXI_RDATA     = 0;
                    // A_AXI_RRESP     = 0;
                    A_AXI_RVALID    = 0;
                    O_AXI_RREADY    = B_AXI_RREADY;
                end else begin
                    O_AXI_ARADDR    = A_AXI_ARADDR;
                    O_AXI_ARVALID   = A_AXI_ARVALID;
                    O_AXI_ARPROT    = A_AXI_ARPROT;
                    A_AXI_ARREADY   = O_AXI_ARREADY;
                    // B_AXI_ARREADY   = 0;
                    
                    //A_AXI_RDATA     = O_AXI_RDATA;
                    A_AXI_RRESP     = O_AXI_RRESP;
                    A_AXI_RVALID    = O_AXI_RVALID;
                    // B_AXI_RDATA     = 0;
                    // B_AXI_RRESP     = 0;
                    B_AXI_RVALID    = 0;
                    O_AXI_RREADY    = A_AXI_RREADY;
                end
            end
        endcase
    end

endmodule //attributer_axi_4_lite

`endif
