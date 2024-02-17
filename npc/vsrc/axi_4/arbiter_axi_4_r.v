// master 0 > master 1
module arbiter_axi_4_r #(
    parameter AXI_DATA_WIDTH = 64,
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8,
    parameter AXI_ID_WIDTH   = 4,
    parameter AXI_USER_WIDTH = 1
) (
    input                               clk,
    input                               rst,
    //master0 AR         
    input       [    AXI_ID_WIDTH-1:0]  M0_AXI_ARID,
    input       [  AXI_ADDR_WIDTH-1:0]  M0_AXI_ARADDR,
    input       [                 7:0]  M0_AXI_ARLEN,
    input       [                 2:0]  M0_AXI_ARSIZE,
    input       [                 1:0]  M0_AXI_ARBURST,
    input                               M0_AXI_ARLOCK,
    input       [                 3:0]  M0_AXI_ARCACHE,
    input       [                 2:0]  M0_AXI_ARPROT,
    input       [                 3:0]  M0_AXI_ARQOS,
    input       [                 3:0]  M0_AXI_ARREGION,
    input       [  AXI_USER_WIDTH-1:0]  M0_AXI_ARUSER,
    input                               M0_AXI_ARVALID,
    output reg                          M0_AXI_ARREADY,
    //master0 R      
    output reg  [    AXI_ID_WIDTH-1:0]  M0_AXI_RID,
    output reg  [  AXI_DATA_WIDTH-1:0]  M0_AXI_RDATA,
    output reg  [                 1:0]  M0_AXI_RRESP,
    output reg                          M0_AXI_RLAST,
    output reg  [  AXI_USER_WIDTH-1:0]  M0_AXI_RUSER,
    output reg                          M0_AXI_RVALID,
    input                               M0_AXI_RREADY,
    //master1 AR         
    input       [    AXI_ID_WIDTH-1:0]  M1_AXI_ARID,
    input       [  AXI_ADDR_WIDTH-1:0]  M1_AXI_ARADDR,
    input       [                 7:0]  M1_AXI_ARLEN,
    input       [                 2:0]  M1_AXI_ARSIZE,
    input       [                 1:0]  M1_AXI_ARBURST,
    input                               M1_AXI_ARLOCK,
    input       [                 3:0]  M1_AXI_ARCACHE,
    input       [                 2:0]  M1_AXI_ARPROT,
    input       [                 3:0]  M1_AXI_ARQOS,
    input       [                 3:0]  M1_AXI_ARREGION,
    input       [  AXI_USER_WIDTH-1:0]  M1_AXI_ARUSER,
    input                               M1_AXI_ARVALID,
    output reg                          M1_AXI_ARREADY,
    //master1 R      
    output reg  [    AXI_ID_WIDTH-1:0]  M1_AXI_RID,
    output reg  [  AXI_DATA_WIDTH-1:0]  M1_AXI_RDATA,
    output reg  [                 1:0]  M1_AXI_RRESP,
    output reg                          M1_AXI_RLAST,
    output reg  [  AXI_USER_WIDTH-1:0]  M1_AXI_RUSER,
    output reg                          M1_AXI_RVALID,
    input                               M1_AXI_RREADY,
    //slave AR         
    output reg [    AXI_ID_WIDTH-1:0]   S_AXI_ARID,
    output reg [  AXI_ADDR_WIDTH-1:0]   S_AXI_ARADDR,
    output reg [                 7:0]   S_AXI_ARLEN,
    output reg [                 2:0]   S_AXI_ARSIZE,
    output reg [                 1:0]   S_AXI_ARBURST,
    output reg                          S_AXI_ARLOCK,
    output reg [                 3:0]   S_AXI_ARCACHE,
    output reg [                 2:0]   S_AXI_ARPROT,
    output reg [                 3:0]   S_AXI_ARQOS,
    output reg [                 3:0]   S_AXI_ARREGION,
    output reg [  AXI_USER_WIDTH-1:0]   S_AXI_ARUSER,
    output reg                          S_AXI_ARVALID,
    input                               S_AXI_ARREADY,
    //slave R      
    input      [    AXI_ID_WIDTH-1:0]   S_AXI_RID,
    input      [  AXI_DATA_WIDTH-1:0]   S_AXI_RDATA,
    input      [                 1:0]   S_AXI_RRESP,
    input                               S_AXI_RLAST,
    input      [  AXI_USER_WIDTH-1:0]   S_AXI_RUSER,
    input                               S_AXI_RVALID,
    output reg                          S_AXI_RREADY
);

    wire [1:0] axi_req;
    reg  [1:0] axi_grant;

    assign axi_req[0] = M0_AXI_ARVALID;
    assign axi_req[1] = M1_AXI_ARVALID;

    always @(posedge clk) begin
        if(rst) begin
            axi_grant   <= 2'b00;
        end else begin
            case (axi_grant)
                2'b00: begin
                    axi_grant <= axi_req & -axi_req;
                end
                
                2'b01: begin
                    if (M0_AXI_RVALID & M0_AXI_RLAST & M0_AXI_RREADY) begin // read over
                        axi_grant <= axi_req & -axi_req;
                    end
                end

                2'b10: begin
                    if (M1_AXI_RVALID & M1_AXI_RLAST & M1_AXI_RREADY) begin // read over
                        axi_grant <= axi_req & -axi_req;
                    end
                end

                default: begin
                    axi_grant   <= 2'b00;
                end
            endcase
        end
    end

    always @(*) begin
        case (axi_grant)
            2'b00: begin
                M0_AXI_ARREADY  = 0;
                M0_AXI_RID      = 0;
                M0_AXI_RDATA    = 0;
                M0_AXI_RRESP    = 0;
                M0_AXI_RLAST    = 0;
                M0_AXI_RUSER    = 0;
                M0_AXI_RVALID   = 0;

                M1_AXI_ARREADY  = 0;
                M1_AXI_RID      = 0;
                M1_AXI_RDATA    = 0;
                M1_AXI_RRESP    = 0;
                M1_AXI_RLAST    = 0;
                M1_AXI_RUSER    = 0;
                M1_AXI_RVALID   = 0;

                S_AXI_ARID      = 0;
                S_AXI_ARADDR    = 0;
                S_AXI_ARLEN     = 0;
                S_AXI_ARSIZE    = 0;
                S_AXI_ARBURST   = 0;
                S_AXI_ARLOCK    = 0;
                S_AXI_ARCACHE   = 0;
                S_AXI_ARPROT    = 0;
                S_AXI_ARQOS     = 0;
                S_AXI_ARREGION  = 0;
                S_AXI_ARUSER    = 0;
                S_AXI_ARVALID   = 0;
                S_AXI_RREADY    = 0;
            end
            
            2'b01: begin
                M0_AXI_ARREADY  = S_AXI_ARREADY;
                M0_AXI_RID      = S_AXI_RID   ;
                M0_AXI_RDATA    = S_AXI_RDATA ;
                M0_AXI_RRESP    = S_AXI_RRESP ;
                M0_AXI_RLAST    = S_AXI_RLAST ;
                M0_AXI_RUSER    = S_AXI_RUSER ;
                M0_AXI_RVALID   = S_AXI_RVALID;

                M1_AXI_ARREADY  = 0;
                M1_AXI_RID      = 0;
                M1_AXI_RDATA    = 0;
                M1_AXI_RRESP    = 0;
                M1_AXI_RLAST    = 0;
                M1_AXI_RUSER    = 0;
                M1_AXI_RVALID   = 0;

                S_AXI_ARID      = M0_AXI_ARID    ;
                S_AXI_ARADDR    = M0_AXI_ARADDR  ;
                S_AXI_ARLEN     = M0_AXI_ARLEN   ;
                S_AXI_ARSIZE    = M0_AXI_ARSIZE  ;
                S_AXI_ARBURST   = M0_AXI_ARBURST ;
                S_AXI_ARLOCK    = M0_AXI_ARLOCK  ;
                S_AXI_ARCACHE   = M0_AXI_ARCACHE ;
                S_AXI_ARPROT    = M0_AXI_ARPROT  ;
                S_AXI_ARQOS     = M0_AXI_ARQOS   ;
                S_AXI_ARREGION  = M0_AXI_ARREGION;
                S_AXI_ARUSER    = M0_AXI_ARUSER  ;
                S_AXI_ARVALID   = M0_AXI_ARVALID ;
                S_AXI_RREADY    = M0_AXI_RREADY  ;
            end
            
            2'b10: begin
                M0_AXI_ARREADY  = 0;
                M0_AXI_RID      = 0;
                M0_AXI_RDATA    = 0;
                M0_AXI_RRESP    = 0;
                M0_AXI_RLAST    = 0;
                M0_AXI_RUSER    = 0;
                M0_AXI_RVALID   = 0;

                M1_AXI_ARREADY  = S_AXI_ARREADY;
                M1_AXI_RID      = S_AXI_RID   ;
                M1_AXI_RDATA    = S_AXI_RDATA ;
                M1_AXI_RRESP    = S_AXI_RRESP ;
                M1_AXI_RLAST    = S_AXI_RLAST ;
                M1_AXI_RUSER    = S_AXI_RUSER ;
                M1_AXI_RVALID   = S_AXI_RVALID;

                S_AXI_ARID      = M1_AXI_ARID    ;
                S_AXI_ARADDR    = M1_AXI_ARADDR  ;
                S_AXI_ARLEN     = M1_AXI_ARLEN   ;
                S_AXI_ARSIZE    = M1_AXI_ARSIZE  ;
                S_AXI_ARBURST   = M1_AXI_ARBURST ;
                S_AXI_ARLOCK    = M1_AXI_ARLOCK  ;
                S_AXI_ARCACHE   = M1_AXI_ARCACHE ;
                S_AXI_ARPROT    = M1_AXI_ARPROT  ;
                S_AXI_ARQOS     = M1_AXI_ARQOS   ;
                S_AXI_ARREGION  = M1_AXI_ARREGION;
                S_AXI_ARUSER    = M1_AXI_ARUSER  ;
                S_AXI_ARVALID   = M1_AXI_ARVALID ;
                S_AXI_RREADY    = M1_AXI_RREADY  ;
            end
            
            default: begin
                M0_AXI_ARREADY  = 0;
                M0_AXI_RID      = 0;
                M0_AXI_RDATA    = 0;
                M0_AXI_RRESP    = 0;
                M0_AXI_RLAST    = 0;
                M0_AXI_RUSER    = 0;
                M0_AXI_RVALID   = 0;

                M1_AXI_ARREADY  = 0;
                M1_AXI_RID      = 0;
                M1_AXI_RDATA    = 0;
                M1_AXI_RRESP    = 0;
                M1_AXI_RLAST    = 0;
                M1_AXI_RUSER    = 0;
                M1_AXI_RVALID   = 0;

                S_AXI_ARID      = 0;
                S_AXI_ARADDR    = 0;
                S_AXI_ARLEN     = 0;
                S_AXI_ARSIZE    = 0;
                S_AXI_ARBURST   = 0;
                S_AXI_ARLOCK    = 0;
                S_AXI_ARCACHE   = 0;
                S_AXI_ARPROT    = 0;
                S_AXI_ARQOS     = 0;
                S_AXI_ARREGION  = 0;
                S_AXI_ARUSER    = 0;
                S_AXI_ARVALID   = 0;
                S_AXI_RREADY    = 0;
            end
        endcase
    end
    
endmodule