module if_id_reg (
	input           clk,
	input           rst,
    input           if_id_stall,
    input           pc_b_j,
    input           in_ready,
	input  [31:0]   in_pc,
    output          out_valid,
    output          out_ready,
	output [31:0]   out_pc,
	output [31:0]   out_inst,
    input               inst_r_ready,
    output              if_busy,

    //AW
    output [ 3:0]               IFU_AXI_AWID,
    output [31:0]               IFU_AXI_AWADDR,
    output [ 7:0]               IFU_AXI_AWLEN,
    output [ 2:0]               IFU_AXI_AWSIZE,
    output [ 1:0]               IFU_AXI_AWBURST,
    output                      IFU_AXI_AWLOCK,
    output [ 3:0]               IFU_AXI_AWCACHE,
    output [ 2:0]               IFU_AXI_AWPROT,
    output [ 3:0]               IFU_AXI_AWQOS,
    output [ 3:0]               IFU_AXI_AWREGION,
    output                      IFU_AXI_AWUSER,
    output                      IFU_AXI_AWVALID,
    input                       IFU_AXI_AWREADY,
    //W 
    output [63:0]               IFU_AXI_WDATA,
    output [ 7:0]               IFU_AXI_WSTRB,
    output                      IFU_AXI_WLAST,
    output                      IFU_AXI_WUSER,
    output                      IFU_AXI_WVALID,
    input                       IFU_AXI_WREADY,
    //BR
    input  [ 3:0]               IFU_AXI_BID,
    input  [ 1:0]               IFU_AXI_BRESP,
    input                       IFU_AXI_BUSER,
    input                       IFU_AXI_BVALID,
    output                      IFU_AXI_BREADY,
    //AR
    output [ 3:0]               IFU_AXI_ARID,
    output [31:0]               IFU_AXI_ARADDR,
    output [ 7:0]               IFU_AXI_ARLEN,
    output [ 2:0]               IFU_AXI_ARSIZE,
    output [ 1:0]               IFU_AXI_ARBURST,
    output                      IFU_AXI_ARLOCK,
    output [ 3:0]               IFU_AXI_ARCACHE,
    output [ 2:0]               IFU_AXI_ARPROT,
    output [ 3:0]               IFU_AXI_ARQOS,
    output [ 3:0]               IFU_AXI_ARREGION,
    output                      IFU_AXI_ARUSER,
    output                      IFU_AXI_ARVALID,
    input                       IFU_AXI_ARREADY,
    //R
    input  [ 3:0]               IFU_AXI_RID,
    input  [63:0]               IFU_AXI_RDATA,
    input  [ 1:0]               IFU_AXI_RRESP,
    input                       IFU_AXI_RLAST,
    input                       IFU_AXI_RUSER,
    input                       IFU_AXI_RVALID,
    output                      IFU_AXI_RREADY
);

    wire stall = (~in_ready && out_valid) || if_id_stall;
    wire wen = ((inst_r_ready && ~if_busy) && ~stall) || pc_b_j;
    wire ctrl_flush = rst;    // || (pc_b_j && ~stall)

    wire [63:0] inst;
    wire inst_r_valid;
    reg out_valid_r;

    assign out_inst = out_pc[2] ? inst[63:32] : inst[31:0];
    
    assign out_valid = out_valid_r | inst_r_valid;

    assign out_ready = in_ready;

    always @(posedge clk) begin
        if (ctrl_flush) begin
            out_valid_r <= 0;
        end else begin
            if(out_valid_r) begin
                if(in_ready) begin
                    if(inst_r_valid)
                        out_valid_r   <= 1;
                    else
                        out_valid_r   <= 0;
                end
            end else begin
                if(inst_r_valid) begin
                    if(in_ready)
                        out_valid_r   <= 0;
                    else
                        out_valid_r   <= 1;
                end
            end
        end
    end

    Reg #(32, 32'b0) u_if_id_pc (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_pc), 
        .dout(out_pc), 
        .wen(wen)
    );
    
    ifu u_ifu(
        .clk                    (clk),
        .rst                    (rst),
        .pc                     (in_pc),
        .inst                   (inst),
        .if_busy                (if_busy),
        .inst_r_ready           (inst_r_ready),
        .inst_r_valid           (inst_r_valid),

        .IFU_AXI_AWID			(IFU_AXI_AWID),
        .IFU_AXI_AWADDR			(IFU_AXI_AWADDR),
        .IFU_AXI_AWLEN			(IFU_AXI_AWLEN),
        .IFU_AXI_AWSIZE			(IFU_AXI_AWSIZE),
        .IFU_AXI_AWBURST		(IFU_AXI_AWBURST),
        .IFU_AXI_AWLOCK			(IFU_AXI_AWLOCK),
        .IFU_AXI_AWCACHE		(IFU_AXI_AWCACHE),
        .IFU_AXI_AWPROT			(IFU_AXI_AWPROT),
        .IFU_AXI_AWQOS			(IFU_AXI_AWQOS),
        .IFU_AXI_AWREGION		(IFU_AXI_AWREGION),
        .IFU_AXI_AWUSER			(IFU_AXI_AWUSER),
        .IFU_AXI_AWVALID		(IFU_AXI_AWVALID),
        .IFU_AXI_AWREADY		(IFU_AXI_AWREADY),

        .IFU_AXI_WDATA			(IFU_AXI_WDATA),
        .IFU_AXI_WSTRB			(IFU_AXI_WSTRB),
        .IFU_AXI_WLAST			(IFU_AXI_WLAST),
        .IFU_AXI_WUSER			(IFU_AXI_WUSER),
        .IFU_AXI_WVALID			(IFU_AXI_WVALID),
        .IFU_AXI_WREADY			(IFU_AXI_WREADY),

        .IFU_AXI_BID			(IFU_AXI_BID),
        .IFU_AXI_BRESP			(IFU_AXI_BRESP),
        .IFU_AXI_BUSER			(IFU_AXI_BUSER),
        .IFU_AXI_BVALID			(IFU_AXI_BVALID),
        .IFU_AXI_BREADY			(IFU_AXI_BREADY),

        .IFU_AXI_ARID			(IFU_AXI_ARID),
        .IFU_AXI_ARADDR			(IFU_AXI_ARADDR),
        .IFU_AXI_ARLEN			(IFU_AXI_ARLEN),
        .IFU_AXI_ARSIZE			(IFU_AXI_ARSIZE),
        .IFU_AXI_ARBURST		(IFU_AXI_ARBURST),
        .IFU_AXI_ARLOCK			(IFU_AXI_ARLOCK),
        .IFU_AXI_ARCACHE		(IFU_AXI_ARCACHE),
        .IFU_AXI_ARPROT			(IFU_AXI_ARPROT),
        .IFU_AXI_ARQOS			(IFU_AXI_ARQOS),
        .IFU_AXI_ARREGION		(IFU_AXI_ARREGION),
        .IFU_AXI_ARUSER			(IFU_AXI_ARUSER),
        .IFU_AXI_ARVALID		(IFU_AXI_ARVALID),
        .IFU_AXI_ARREADY		(IFU_AXI_ARREADY),

        .IFU_AXI_RID			(IFU_AXI_RID),
        .IFU_AXI_RDATA			(IFU_AXI_RDATA),
        .IFU_AXI_RRESP			(IFU_AXI_RRESP),
        .IFU_AXI_RLAST			(IFU_AXI_RLAST),
        .IFU_AXI_RUSER			(IFU_AXI_RUSER),
        .IFU_AXI_RVALID			(IFU_AXI_RVALID),
        .IFU_AXI_RREADY			(IFU_AXI_RREADY)
    );


endmodule //if_id_reg
