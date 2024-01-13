/*************************************************************
 * @ name           : slave_axi_4.v
 * @ description    : 
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-4-21
*************************************************************/
`ifndef S_AXI_4_INST_V
`define S_AXI_4_INST_V

module slave_axi_4_inst #(
    parameter AXI_DATA_WIDTH = 64,
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8,
    parameter AXI_ID_WIDTH   = 4,
    parameter AXI_USER_WIDTH = 1
) (
    input                               clk,
    input                               rst,

    //AW
    input  [    AXI_ID_WIDTH-1:0]       S_AXI_AWID,
    input  [  AXI_ADDR_WIDTH-1:0]       S_AXI_AWADDR,
    input  [                 7:0]       S_AXI_AWLEN,
    input  [                 2:0]       S_AXI_AWSIZE,
    input  [                 1:0]       S_AXI_AWBURST,
    input                               S_AXI_AWLOCK,
    input  [                 3:0]       S_AXI_AWCACHE,
    input  [                 2:0]       S_AXI_AWPROT,
    input  [                 3:0]       S_AXI_AWQOS,
    input  [                 3:0]       S_AXI_AWREGION,
    input  [  AXI_USER_WIDTH-1:0]       S_AXI_AWUSER,
    input                               S_AXI_AWVALID,
    output                              S_AXI_AWREADY,
    //W 
    input  [  AXI_DATA_WIDTH-1:0]       S_AXI_WDATA,
    input  [  AXI_STRB_WIDTH-1:0]       S_AXI_WSTRB,
    input                               S_AXI_WLAST,
    input  [  AXI_USER_WIDTH-1:0]       S_AXI_WUSER,
    input                               S_AXI_WVALID,
    output                              S_AXI_WREADY,
    //BR            
    output [    AXI_ID_WIDTH-1:0]       S_AXI_BID,
    output [                 1:0]       S_AXI_BRESP,
    output [  AXI_USER_WIDTH-1:0]       S_AXI_BUSER,
    output                              S_AXI_BVALID,
    input                               S_AXI_BREADY,
    //AR         
    input  [    AXI_ID_WIDTH-1:0]       S_AXI_ARID,
    input  [  AXI_ADDR_WIDTH-1:0]       S_AXI_ARADDR,
    input  [                 7:0]       S_AXI_ARLEN,
    input  [                 2:0]       S_AXI_ARSIZE,
    input  [                 1:0]       S_AXI_ARBURST,
    input                               S_AXI_ARLOCK,
    input  [                 3:0]       S_AXI_ARCACHE,
    input  [                 2:0]       S_AXI_ARPROT,
    input  [                 3:0]       S_AXI_ARQOS,
    input  [                 3:0]       S_AXI_ARREGION,
    input  [  AXI_USER_WIDTH-1:0]       S_AXI_ARUSER,
    input                               S_AXI_ARVALID,
    output                              S_AXI_ARREADY,
    //R      
    output [    AXI_ID_WIDTH-1:0]       S_AXI_RID,
    output [  AXI_DATA_WIDTH-1:0]       S_AXI_RDATA,
    output [                 1:0]       S_AXI_RRESP,
    output                              S_AXI_RLAST,
    output [  AXI_USER_WIDTH-1:0]       S_AXI_RUSER,
    output                              S_AXI_RVALID,
    input                               S_AXI_RREADY
);

    //-----------------------------------------register---------------------------------------------------
    //AW
    reg    [  AXI_ADDR_WIDTH-1:0]       axi_awaddr;
    reg    [                 7:0]       axi_awlen;
    reg    [                 2:0]       axi_awsize;
    reg    [                 1:0]       axi_awburst;
    reg                                 axi_awready;
    //W
    reg    [  AXI_DATA_WIDTH-1:0]       axi_wdata;
    reg    [  AXI_STRB_WIDTH-1:0]       axi_wstrb;
    reg                                 axi_wlast;
    reg                                 axi_wready;
    //BR
    reg                                 axi_bvalid;
    //AR
    reg    [  AXI_ADDR_WIDTH-1:0]       axi_araddr;
    reg    [                 7:0]       axi_arlen;
    reg    [                 2:0]       axi_arsize;
    reg    [                 1:0]       axi_arburst;
    reg                                 axi_arready;
    //R
    reg    [  AXI_DATA_WIDTH-1:0]       axi_rdata;
    reg                                 axi_rlast;
    reg                                 axi_rvalid;

    //AW
    assign  S_AXI_AWREADY       =   axi_awready;
    //W
    assign  S_AXI_WREADY        =   axi_wready;
    //BR
    assign  S_AXI_BID           =   0;          // meaningless
    assign  S_AXI_BRESP         =   2'b00;      // OKAY
    assign  S_AXI_BUSER         =   0;          // meaningless
    assign  S_AXI_BVALID        =   axi_bvalid;
    //AR
    assign  S_AXI_ARREADY       =   axi_arready;
    //R
    assign  S_AXI_RID           =   0;          // meaningless
    assign  S_AXI_RDATA         =   axi_rdata;
    assign  S_AXI_RRESP         =   2'b00;      // OKAY
    assign  S_AXI_RLAST         =   axi_rlast;
    assign  S_AXI_RUSER         =   0;          // meaningless
    assign  S_AXI_RVALID        =   axi_rvalid;
    
    //-------------------------------------------- Write FSM-Moore ------------------------------------------------
    parameter [2:0]
        FSM_IDLE        =   3'b000 ,    // idle
        FSM_W           =   3'b001 ,    // write
        FSM_AW          =   3'b010 ,    // addr write
        FSM_MW          =   3'b011 ,    // multi write
        FSM_BR          =   3'b100 ;    // BR

    reg  [2 : 0] w_state;
    reg  [7 : 0] w_cnt;

    wire [  AXI_ADDR_WIDTH-1:0] W_Start_Address       = S_AXI_AWADDR;
    wire [  AXI_ADDR_WIDTH-1:0] W_Number_Bytes        = 1 << S_AXI_AWSIZE;
    wire [  AXI_ADDR_WIDTH-1:0] W_Burst_Length        = {{(AXI_ADDR_WIDTH - 8){1'b0}}, S_AXI_AWLEN} + 1;
    wire [  AXI_ADDR_WIDTH-1:0] W_Total_Bytes         = W_Burst_Length << S_AXI_AWSIZE;
    
    reg  [  AXI_ADDR_WIDTH-1:0] W_Number_Bytes_R      ;
    reg  [  AXI_ADDR_WIDTH-1:0] W_Aligned_Address     ;
    reg  [  AXI_ADDR_WIDTH-1:0] W_Address_N           ;
    reg  [  AXI_ADDR_WIDTH-1:0] W_Lower_Wrap_Boundary ;
    reg  [  AXI_ADDR_WIDTH-1:0] W_Upper_Wrap_Boundary ;

import "DPI-C" function void inst_fetch(input longint raddr, output longint mem_r_data);
import "DPI-C" function void paddr_write(input longint waddr, input longint mem_w_data, input byte wmask);

    always @(posedge clk) begin
        if (rst) begin
            w_state         <= FSM_IDLE;
            w_cnt           <= 8'b0;
            axi_awready     <= 1'b1;
            axi_wready      <= 1'b1;
            axi_bvalid      <= 1'b0;
        end else begin
            case(w_state)
                FSM_IDLE    : begin
                    if (S_AXI_AWVALID & S_AXI_WVALID) begin
                        if (S_AXI_AWLEN == 8'b0 & S_AXI_WLAST == 1'b1) begin
                            w_state         <= FSM_BR;
                            axi_bvalid      <= 1'b1;
                            axi_wready      <= 1'b0;
                        end else begin
                            w_state         <= FSM_MW;
                            axi_wready      <= 1'b1;
                        end
                        axi_awaddr      <= S_AXI_AWADDR;
                        axi_awlen       <= S_AXI_AWLEN;
                        axi_awsize      <= S_AXI_AWSIZE;
                        axi_awburst     <= S_AXI_AWBURST;
                        axi_awready     <= 1'b0;
                        
                        W_Aligned_Address     <= W_Start_Address & ~(W_Number_Bytes - 1);
                        case (S_AXI_AWBURST)
                            2'b00: begin    // FIXED
                                W_Address_N     <= (W_Start_Address & ~(W_Number_Bytes - 1));
                            end 
                            2'b01: begin    // INCR
                                W_Address_N     <= (W_Start_Address & ~(W_Number_Bytes - 1)) + W_Number_Bytes_R;
                            end 
                            2'b10: begin    // WRAP
                                W_Address_N     <= ((W_Start_Address & ~(W_Number_Bytes - 1)) + W_Number_Bytes_R >= ((W_Start_Address & ~(W_Total_Bytes - 1)) + W_Total_Bytes)) ? (W_Start_Address & ~(W_Total_Bytes - 1)) : (W_Start_Address & ~(W_Number_Bytes - 1)) + W_Number_Bytes_R;
                            end 
                            default: begin  // Reserved
                                W_Address_N     <= (W_Start_Address & ~(W_Number_Bytes - 1));
                            end 
                        endcase
                        W_Lower_Wrap_Boundary <= W_Start_Address & ~(W_Total_Bytes - 1);
                        W_Upper_Wrap_Boundary <= (W_Start_Address & ~(W_Total_Bytes - 1)) + W_Total_Bytes;
                        W_Number_Bytes_R      <= W_Number_Bytes;

                        axi_wdata       <= S_AXI_WDATA;
                        axi_wstrb       <= S_AXI_WSTRB;
                        axi_wlast       <= S_AXI_WLAST;
                        
                        w_cnt           <= w_cnt + 8'b1;
                        paddr_write({32'b0, W_Start_Address & ~(W_Number_Bytes - 1)}, S_AXI_WDATA, S_AXI_WSTRB);
                        //$display("Write: addr = %X, size = %d, strb = %X, data = %X\n", (W_Start_Address & ~(W_Number_Bytes - 1)), S_AXI_AWSIZE, S_AXI_WSTRB, S_AXI_WDATA);

                    end else if (S_AXI_AWVALID) begin
                        w_state         <= FSM_MW;
                        axi_awaddr      <= S_AXI_AWADDR;
                        axi_awlen       <= S_AXI_AWLEN;
                        axi_awsize      <= S_AXI_AWSIZE;
                        axi_awburst     <= S_AXI_AWBURST;
                        axi_awready     <= 1'b0;
                        
                        W_Aligned_Address     <= W_Start_Address & ~(W_Number_Bytes - 1);
                        W_Address_N           <= W_Start_Address & ~(W_Number_Bytes - 1);
                        W_Lower_Wrap_Boundary <= W_Start_Address & ~(W_Total_Bytes - 1);
                        W_Upper_Wrap_Boundary <= W_Start_Address & ~(W_Total_Bytes - 1) + W_Total_Bytes;
                        W_Number_Bytes_R      <= W_Number_Bytes;
                    end else if (S_AXI_WVALID) begin
                        w_state         <= FSM_AW;
                        axi_wdata       <= S_AXI_WDATA;
                        axi_wstrb       <= S_AXI_WSTRB;
                        axi_wlast       <= S_AXI_WLAST;
                        axi_wready      <= 1'b1;
                    end
                end

                FSM_MW      : begin
                    if (S_AXI_WVALID) begin
                        if (axi_awlen == w_cnt & S_AXI_WLAST == 1'b1) begin
                            w_state         <= FSM_BR;
                            axi_bvalid      <= 1'b1;
                            axi_wready      <= 1'b0;
                        end else begin
                            w_state         <= FSM_MW;
                            axi_bvalid      <= 1'b0;
                            axi_wready      <= 1'b1;
                        end
                        axi_wdata       <= S_AXI_WDATA;
                        axi_wstrb       <= S_AXI_WSTRB;
                        axi_wlast       <= S_AXI_WLAST;

                        case (axi_awburst)
                            2'b00: begin    // FIXED
                                W_Address_N     <= W_Address_N;
                            end 
                            2'b01: begin    // INCR
                                W_Address_N     <= W_Address_N + W_Number_Bytes_R;
                            end 
                            2'b10: begin    // WRAP
                                W_Address_N     <= (W_Address_N + W_Number_Bytes_R >= W_Upper_Wrap_Boundary) ? W_Lower_Wrap_Boundary : W_Address_N + W_Number_Bytes_R;
                            end 
                            default: begin  // Reserved
                                W_Address_N     <= W_Address_N;
                            end 
                        endcase
                        w_cnt           <= w_cnt + 8'b1;
                        paddr_write({32'b0, W_Address_N}, S_AXI_WDATA, S_AXI_WSTRB);
                        //$display("Write: addr = %X, size = %d, strb = %X, data = %X\n", W_Address_N, axi_awsize, S_AXI_WSTRB, S_AXI_WDATA);
                    end
                end

                FSM_AW      : begin
                    if (S_AXI_AWVALID) begin
                        if (axi_awlen == w_cnt & axi_wlast == 1'b1) begin
                            w_state         <= FSM_BR;
                            axi_bvalid      <= 1'b1;
                            axi_wready      <= 1'b0;
                        end else begin
                            w_state         <= FSM_MW;
                            axi_wready      <= 1'b1;
                        end
                        axi_awaddr      <= S_AXI_AWADDR;
                        axi_awlen       <= S_AXI_AWLEN;
                        axi_awsize      <= S_AXI_AWSIZE;
                        axi_awburst     <= S_AXI_AWBURST;
                        axi_awready     <= 1'b0;
                        
                        W_Aligned_Address     <= W_Start_Address & ~(W_Number_Bytes - 1);
                        case (S_AXI_AWBURST)
                            2'b00: begin    // FIXED
                                W_Address_N     <= (W_Start_Address & ~(W_Number_Bytes - 1));
                            end 
                            2'b01: begin    // INCR
                                W_Address_N     <= (W_Start_Address & ~(W_Number_Bytes - 1)) + W_Number_Bytes;
                            end 
                            2'b10: begin    // WRAP
                                W_Address_N     <= ((W_Start_Address & ~(W_Number_Bytes - 1)) + W_Number_Bytes >= (W_Start_Address & ~(W_Total_Bytes - 1) + W_Total_Bytes)) ? (W_Start_Address & ~(W_Total_Bytes - 1)) : (W_Start_Address & ~(W_Number_Bytes - 1)) + W_Number_Bytes;
                            end 
                            default: begin  // Reserved
                                W_Address_N     <= (W_Start_Address & ~(W_Number_Bytes - 1));
                            end 
                        endcase
                        W_Lower_Wrap_Boundary <= W_Start_Address & ~(W_Total_Bytes - 1);
                        W_Upper_Wrap_Boundary <= W_Start_Address & ~(W_Total_Bytes - 1) + W_Total_Bytes;
                        W_Number_Bytes_R      <= W_Number_Bytes;

                        w_cnt           <= w_cnt + 8'b1;
                        paddr_write({32'b0, W_Start_Address & ~(W_Number_Bytes - 1)}, axi_wdata, axi_wstrb);
                        //$display("Write: addr = %X, size = %d, strb = %X, data = %X\n", (W_Start_Address & ~(W_Number_Bytes - 1)), S_AXI_AWSIZE, axi_wstrb, axi_wdata);
                    end
                end

                FSM_BR : begin
                    if(S_AXI_BREADY)   begin 
                        w_state         <= FSM_IDLE;
                        w_cnt           <= 8'b0;
                        axi_awready     <= 1'b1;
                        axi_wready      <= 1'b1;
                        axi_bvalid      <= 1'b0;
                    end
                end

                default     : begin 
                    w_state         <= FSM_IDLE;
                    w_cnt           <= 8'b0;
                    axi_awready     <= 1'b1;
                    axi_wready      <= 1'b1;
                    axi_bvalid      <= 1'b0;
                end

            endcase
        end
    end

    
    //-------------------------------------------- Read FSM-Moore ------------------------------------------------
    parameter [2:0]
        //FSM_IDLE      =   3'b000 ,    // idle
        FSM_R           =   3'b001 ,    // addr read
        FSM_MR          =   3'b010 ,    // read
        FSM_AR          =   3'b011 ,    // multi read
        FSM_RD          =   3'b011 ;    // read done

    reg [2 : 0] r_state;
    reg [7 : 0] r_cnt;

    wire [  AXI_ADDR_WIDTH-1:0] R_Start_Address       = S_AXI_ARADDR;
    wire [  AXI_ADDR_WIDTH-1:0] R_Number_Bytes        = 1 << S_AXI_ARSIZE;
    wire [  AXI_ADDR_WIDTH-1:0] R_Burst_Length        = {{(AXI_ADDR_WIDTH - 8){1'b0}}, S_AXI_ARLEN} + 1;
    wire [  AXI_ADDR_WIDTH-1:0] R_Total_Bytes         = R_Burst_Length << S_AXI_ARSIZE;
    
    reg  [  AXI_ADDR_WIDTH-1:0] R_Number_Bytes_R      ;
    reg  [  AXI_ADDR_WIDTH-1:0] R_Aligned_Address     ;
    reg  [  AXI_ADDR_WIDTH-1:0] R_Address_N           ;
    reg  [  AXI_ADDR_WIDTH-1:0] R_Lower_Wrap_Boundary ;
    reg  [  AXI_ADDR_WIDTH-1:0] R_Upper_Wrap_Boundary ;

    always @(posedge clk) begin
        if (rst) begin
            r_state         <= FSM_IDLE;
            r_cnt           <= 8'b0;
            axi_arready     <= 1'b1;
            axi_rlast       <= 1'b0;
            axi_rvalid      <= 1'b0;
        end else begin
            case(r_state)
                FSM_IDLE    : begin
                    if (S_AXI_ARVALID) begin
                        r_state         <= FSM_MR;
                        axi_araddr      <= S_AXI_ARADDR;
                        axi_arlen       <= S_AXI_ARLEN;
                        axi_arsize      <= S_AXI_ARSIZE;
                        axi_arburst     <= S_AXI_ARBURST;
                        axi_arready     <= 1'b0;

                        R_Aligned_Address     <= R_Start_Address & ~(R_Number_Bytes - 1);
                        case (S_AXI_ARBURST)
                            2'b00: begin    // FIXED
                                R_Address_N     <= (R_Start_Address & ~(R_Number_Bytes - 1));
                            end 
                            2'b01: begin    // INCR
                                R_Address_N     <= (R_Start_Address & ~(R_Number_Bytes - 1)) + R_Number_Bytes;
                            end 
                            2'b10: begin    // WRAP
                                R_Address_N     <= ((R_Start_Address & ~(R_Number_Bytes - 1)) + R_Number_Bytes >= ((R_Start_Address & ~(R_Total_Bytes - 1)) + R_Total_Bytes)) ? (R_Start_Address & ~(R_Total_Bytes - 1)) : (R_Start_Address & ~(R_Number_Bytes - 1)) + R_Number_Bytes;
                            end 
                            default: begin  // Reserved
                                R_Address_N     <= (R_Start_Address & ~(R_Number_Bytes - 1));
                            end 
                        endcase
                        R_Lower_Wrap_Boundary <= R_Start_Address & ~(R_Total_Bytes - 1);
                        R_Upper_Wrap_Boundary <= (R_Start_Address & ~(R_Total_Bytes - 1)) + R_Total_Bytes;
                        R_Number_Bytes_R      <= R_Number_Bytes;
                        
                        r_cnt           <= r_cnt + 8'b1;
                        inst_fetch({32'b0, (R_Start_Address & ~(R_Number_Bytes - 1))}, axi_rdata);
                        //$display("Read : addr = %X, size = %d, cnt = %d\n", (R_Start_Address & ~(R_Number_Bytes - 1)), S_AXI_ARSIZE, r_cnt);
                        axi_rvalid      <= 1'b1;
                        if (S_AXI_ARLEN == 8'b0) begin
                            axi_rlast       <= 1'b1;
                        end 
                    end
                end

                FSM_MR      : begin
                    if (S_AXI_RREADY) begin
                        if(axi_arlen == r_cnt)   begin 
                            axi_rlast       <= 1'b1;
                        end
                        if(axi_rlast) begin
                            r_state         <= FSM_IDLE;
                            r_cnt           <= 8'b0;
                            axi_arready     <= 1'b1;
                            axi_rlast       <= 1'b0;
                            axi_rvalid      <= 1'b0;
                        end else begin
                            r_state         <= FSM_MR;
                            r_cnt           <= r_cnt + 8'b1;
                            axi_rvalid      <= 1'b1;
                            case (axi_arburst)
                                2'b00: begin    // FIXED
                                    R_Address_N     <= R_Address_N;
                                end 
                                2'b01: begin    // INCR
                                    R_Address_N     <= R_Address_N + R_Number_Bytes_R;
                                end 
                                2'b10: begin    // WRAP
                                    R_Address_N     <= (R_Address_N + R_Number_Bytes_R >= R_Upper_Wrap_Boundary) ? R_Lower_Wrap_Boundary : R_Address_N + R_Number_Bytes_R;
                                end 
                                default: begin  // Reserved
                                    R_Address_N     <= R_Address_N;
                                end 
                            endcase
                            inst_fetch({32'b0, R_Address_N}, axi_rdata);
                        end
                    end
                end

                default     : begin 
                    r_state         <= FSM_IDLE;
                    r_cnt           <= 8'b0;
                    axi_arready     <= 1'b1;
                    axi_rlast       <= 1'b0;
                    axi_rvalid      <= 1'b0;
                end

            endcase
        end
    end

endmodule //slave_axi_4

`endif