/*************************************************************
 * @ name           : master_axi_4.v
 * @ description    : 
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-4-21
*************************************************************/
`ifndef M_AXI_4_V
`define M_AXI_4_V

module master_axi_4 #(
    parameter AXI_DATA_WIDTH = 64,
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8,
    parameter AXI_ID_WIDTH   = 4,
    parameter AXI_USER_WIDTH = 1
) (
    input                               clk,
    input                               rst,

    input  [  AXI_ADDR_WIDTH-1:0]       w_addr,
    input                               w_valid,
    input  [                 2:0]       w_size,     // 2^size Byte
    input  [                 1:0]       w_burst,    // 0-FIXED, 1-INC, 2-WRAP
    input  [                 7:0]       w_len,      // len+1 Byte
    input  [  AXI_STRB_WIDTH-1:0]       w_strb,
    input  [  AXI_DATA_WIDTH-1:0]       w_data,
    output                              w_ready,

    input  [  AXI_ADDR_WIDTH-1:0]       r_addr,
    input                               r_ready,
    input  [                 2:0]       r_size,     // 2^size Byte
    input  [                 1:0]       r_burst,    // 0-FIXED, 1-INC, 2-WRAP
    input  [                 7:0]       r_len,      // len+1 Byte
    output                              r_valid,
    output [  AXI_DATA_WIDTH-1:0]       r_data,

    //AW
    output [    AXI_ID_WIDTH-1:0]       M_AXI_AWID,
    output [  AXI_ADDR_WIDTH-1:0]       M_AXI_AWADDR,
    output [                 7:0]       M_AXI_AWLEN,
    output [                 2:0]       M_AXI_AWSIZE,
    output [                 1:0]       M_AXI_AWBURST,
    output                              M_AXI_AWLOCK,
    output [                 3:0]       M_AXI_AWCACHE,
    output [                 2:0]       M_AXI_AWPROT,
    output [                 3:0]       M_AXI_AWQOS,
    output [                 3:0]       M_AXI_AWREGION,
    output [  AXI_USER_WIDTH-1:0]       M_AXI_AWUSER,
    output                              M_AXI_AWVALID,
    input                               M_AXI_AWREADY,
    //W 
    output [  AXI_DATA_WIDTH-1:0]       M_AXI_WDATA,
    output [  AXI_STRB_WIDTH-1:0]       M_AXI_WSTRB,
    output                              M_AXI_WLAST,
    output [  AXI_USER_WIDTH-1:0]       M_AXI_WUSER,
    output                              M_AXI_WVALID,
    input                               M_AXI_WREADY,
    //BR            
    input  [    AXI_ID_WIDTH-1:0]       M_AXI_BID,
    input  [                 1:0]       M_AXI_BRESP,
    input  [  AXI_USER_WIDTH-1:0]       M_AXI_BUSER,
    input                               M_AXI_BVALID,
    output                              M_AXI_BREADY,
    //AR         
    output [    AXI_ID_WIDTH-1:0]       M_AXI_ARID,
    output [  AXI_ADDR_WIDTH-1:0]       M_AXI_ARADDR,
    output [                 7:0]       M_AXI_ARLEN,
    output [                 2:0]       M_AXI_ARSIZE,
    output [                 1:0]       M_AXI_ARBURST,
    output                              M_AXI_ARLOCK,
    output [                 3:0]       M_AXI_ARCACHE,
    output [                 2:0]       M_AXI_ARPROT,
    output [                 3:0]       M_AXI_ARQOS,
    output [                 3:0]       M_AXI_ARREGION,
    output [  AXI_USER_WIDTH-1:0]       M_AXI_ARUSER,
    output                              M_AXI_ARVALID,
    input                               M_AXI_ARREADY,
    //R      
    input  [    AXI_ID_WIDTH-1:0]       M_AXI_RID,
    input  [  AXI_DATA_WIDTH-1:0]       M_AXI_RDATA,
    input  [                 1:0]       M_AXI_RRESP,
    input                               M_AXI_RLAST,
    input  [  AXI_USER_WIDTH-1:0]       M_AXI_RUSER,
    input                               M_AXI_RVALID,
    output                              M_AXI_RREADY
);

    //-----------------------------------------register---------------------------------------------------
    //AW
    reg    [  AXI_ADDR_WIDTH-1:0]       axi_awaddr;
    reg    [                 7:0]       axi_awlen;
    reg    [                 2:0]       axi_awsize;
    reg    [                 1:0]       axi_awburst;
    reg                                 axi_awvalid;
    //W
    reg    [  AXI_DATA_WIDTH-1:0]       axi_wdata;
    reg    [  AXI_STRB_WIDTH-1:0]       axi_wstrb;
    reg                                 axi_wlast;
    reg                                 axi_wvalid;
    //BR
    reg                                 axi_bready;
    //AR
    reg    [  AXI_ADDR_WIDTH-1:0]       axi_araddr;
    reg    [                 7:0]       axi_arlen;
    reg    [                 2:0]       axi_arsize;
    reg    [                 1:0]       axi_arburst;
    reg                                 axi_arvalid;
    //R
    reg                                 axi_rready;

    assign  w_ready             =   M_AXI_WVALID & M_AXI_WREADY;
    assign  r_valid             =   M_AXI_RVALID & M_AXI_RREADY;
    assign  r_data              =   M_AXI_RDATA;
    //AW
    assign  M_AXI_AWID          =   0;          // meaningless
    assign  M_AXI_AWADDR        =   axi_awaddr;
    assign  M_AXI_AWLEN         =   axi_awlen;
    assign  M_AXI_AWSIZE        =   axi_awsize;
    assign  M_AXI_AWBURST       =   axi_awburst;
    assign  M_AXI_AWLOCK        =   1'b0;       // meaningless
    assign  M_AXI_AWCACHE       =   4'b0010;    // Normal Non-cacheable Non-bufferable
    assign  M_AXI_AWPROT        =   3'b000;     // Unprivileged | Secure | Data access
    assign  M_AXI_AWQOS         =   4'b0000;    // meaningless
    assign  M_AXI_AWREGION      =   4'b0000;    // meaningless
    assign  M_AXI_AWUSER        =   0;          // meaningless
    assign  M_AXI_AWVALID       =   axi_awvalid;
    //W
    assign  M_AXI_WDATA         =   axi_wdata;
    assign  M_AXI_WSTRB         =   axi_wstrb;
    assign  M_AXI_WLAST         =   axi_wlast;
    assign  M_AXI_WUSER         =   0;          // meaningless
    assign  M_AXI_WVALID        =   axi_wvalid;
    //BR
    assign  M_AXI_BREADY        =   axi_bready;
    //AR
    assign  M_AXI_ARID          =   0;
    assign  M_AXI_ARADDR        =   axi_araddr;
    assign  M_AXI_ARLEN         =   axi_arlen;
    assign  M_AXI_ARSIZE        =   axi_arsize;
    assign  M_AXI_ARBURST       =   axi_arburst;
    assign  M_AXI_ARLOCK        =   1'b0;       // meaningless
    assign  M_AXI_ARCACHE       =   4'b0010;    // Normal Non-cacheable Non-bufferable
    assign  M_AXI_ARPROT        =   3'b000;     // Unprivileged | Secure | Data access
    assign  M_AXI_ARQOS         =   4'b0000;    // meaningless
    assign  M_AXI_ARREGION      =   4'b0000;    // meaningless
    assign  M_AXI_ARUSER        =   0;          // meaningless
    assign  M_AXI_ARVALID       =   axi_arvalid;
    //R
    assign  M_AXI_RREADY        =   axi_rready;
    
    //-------------------------------------------- Write FSM-Moore ------------------------------------------------
    parameter [2:0]
        FSM_IDLE        =   3'b000 ,    // idle
        FSM_AW_W        =   3'b001 ,    // addr write / write
        FSM_W           =   3'b010 ,    // write
        FSM_AW          =   3'b011 ,    // addr write
        FSM_MW          =   3'b100 ,    // multi write
        FSM_BR          =   3'b101 ,    // BR
        FSM_WD          =   3'b110 ;    // write done

    reg [2 : 0] w_state;
    reg [7 : 0] w_cnt;

    always @(posedge clk) begin
        if (rst) begin
            w_state         <= FSM_IDLE;
            w_cnt           <= 8'b0;
            axi_awvalid     <= 1'b0;
            axi_wvalid      <= 1'b0;
            axi_wlast       <= 1'b0;
            axi_bready      <= 1'b0;
        end else begin
            case(w_state)
                FSM_IDLE    : begin
                    if(w_valid)   begin 
                        w_state         <= FSM_AW_W;
                        axi_awaddr      <= w_addr;
                        axi_awlen       <= w_len;
                        axi_awsize      <= w_size;
                        axi_awburst     <= w_burst;
                        axi_wdata       <= w_data;
                        axi_wstrb       <= w_strb;
                        axi_awvalid     <= 1'b1;
                        axi_wvalid      <= 1'b1;
                        if (w_len == 8'b0) begin
                            axi_wlast       <= 1'b1;
                            axi_bready      <= 1'b1;
                        end else begin
                            axi_wlast       <= 1'b0;
                        end
                    end
                end

                FSM_AW_W      : begin
                    if (M_AXI_AWREADY & M_AXI_WREADY) begin
                        if (axi_wlast) begin
                            w_state         <= FSM_BR;
                            w_cnt           <= 8'b0;
                        end else begin
                            w_state         <= FSM_MW;
                            w_cnt           <= w_cnt + 1;
                        end
                        axi_awvalid     <= 1'b0;
                        axi_wvalid      <= 1'b0;
                    end else if (M_AXI_AWREADY) begin
                        w_state         <= FSM_W;
                        axi_awvalid     <= 1'b0;
                    end else if (M_AXI_WREADY) begin
                        w_state         <= FSM_AW;
                        axi_wvalid      <= 1'b0;
                    end
                end

                FSM_W      : begin
                    if (M_AXI_WREADY) begin
                        if (axi_wlast) begin
                            w_state         <= FSM_BR;
                            w_cnt           <= 8'b0;
                        end else begin
                            w_state         <= FSM_MW;
                            w_cnt           <= w_cnt + 1;
                        end
                        axi_wvalid      <= 1'b0;
                    end
                end

                FSM_AW      : begin
                    if (M_AXI_AWREADY) begin
                        if (axi_wlast) begin
                            w_state         <= FSM_BR;
                            w_cnt           <= 8'b0;
                        end else begin
                            w_state         <= FSM_MW;
                            w_cnt           <= w_cnt + 1;
                        end
                        axi_awvalid     <= 1'b0;
                    end
                end

                FSM_BR : begin
                    if (M_AXI_BVALID) begin
                        w_state         <= FSM_IDLE;
                        axi_wlast       <= 1'b0;
                        axi_bready      <= 1'b0;
                    end
                end

                FSM_MW    : begin
                    if(w_valid)   begin 
                        w_state         <= FSM_W;
                        axi_wdata       <= w_data;
                        axi_wstrb       <= w_strb;
                        axi_wvalid      <= 1'b1;
                        if (axi_awlen == w_cnt) begin
                            axi_wlast       <= 1'b1;
                            axi_bready      <= 1'b1;
                        end else begin
                            axi_wlast       <= 1'b0;
                        end
                    end
                end

                FSM_WD     : begin 
                        w_state         <= FSM_IDLE;
                end

                default     : begin 
                    w_state         <= FSM_IDLE;
                    w_cnt           <= 8'b0;
                    axi_awvalid     <= 1'b0;
                    axi_wvalid      <= 1'b0;
                    axi_wlast       <= 1'b0;
                    axi_bready      <= 1'b0;
                end

            endcase
        end
    end

    
    //-------------------------------------------- Read FSM-Moore ------------------------------------------------
    parameter [2:0]
        //FSM_IDLE      =   3'b000 ,    // idle
        FSM_AR          =   3'b001 ,    // addr read
        FSM_R           =   3'b010 ,    // read
        FSM_MR          =   3'b011 ,    // multi read
        FSM_RD          =   3'b100 ;    // read done

    reg [2 : 0] r_state;
    reg [7 : 0] r_cnt;

    always @(posedge clk) begin
        if (rst) begin
            r_state         <= FSM_IDLE;
            r_cnt           <= 8'b0;
            axi_arvalid     <= 1'b0;
            axi_rready      <= 1'b0;
        end else begin
            case(r_state)
                FSM_IDLE    : begin
                    if(r_ready)   begin 
                        r_state         <= FSM_AR;
                        axi_araddr      <= r_addr;
                        axi_arlen       <= r_len;
                        axi_arsize      <= r_size;
                        axi_arburst     <= r_burst;
                        axi_arvalid     <= 1'b1;
                    end
                end

                FSM_AR      : begin
                    if (M_AXI_ARREADY) begin
                        r_state         <= FSM_R;
                        axi_arvalid     <= 1'b0;
                        axi_rready      <= 1'b1;
                    end
                end

                FSM_R      : begin
                    if (M_AXI_RVALID) begin
                        if (M_AXI_RLAST) begin
                            r_state         <= FSM_IDLE;
                            r_cnt           <= 8'b0;
                        end else begin
                            r_state         <= FSM_MR;
                            r_cnt           <= r_cnt + 1;
                        end
                        axi_rready      <= 1'b0;
                    end
                end

                FSM_MR    : begin
                    if(r_ready)   begin
                        r_state         <= FSM_R;
                        axi_rready      <= 1'b1;
                    end
                end

                default     : begin 
                    r_state         <= FSM_IDLE;
                    r_cnt           <= 8'b0;
                    axi_arvalid     <= 1'b0;
                    axi_rready      <= 1'b0;
                end

            endcase
        end
    end

endmodule //master_axi_4

`endif