/*************************************************************
 * @ name           : ifu_axi_4_lite.v
 * @ description    : IFU using AXI4-lite bus interface
 * @ use module     : None
 * @ author         : K
 * @ chnge date     : 2023-3-18
 *************************************************************/
`ifndef IFU_AXI_4_LITE_V
`define IFU_AXI_4_LITE_V

module ifu_axi_4_lite (
	input                               clk,
	input                               rst,
    input                               pc_valid,
    output                              pc_ready,
	input   [`XLEN-1:0]                 pc,
    input                               inst_ready,
    output                              inst_valid,
	output  [31:0]                      inst
);

    wire AXI_AWREADY, AXI_WREADY, AXI_BVALID;
    wire [1:0] AXI_BRESP, AXI_RRESP;
    wire [31:0] inst_63_32;

    inst_mem_axi_4_lite #(64, 32) u_inst_mem_axi_4_lite_0(
    //Global
        .AXI_ACLK(clk),
        .AXI_ARESETN(~rst),
    //AW    
        .AXI_AWADDR(0),
        .AXI_AWPROT(0),
        .AXI_AWVALID(0),
        .AXI_AWREADY(AXI_AWREADY),
    //W 
        .AXI_WDATA(0),
        .AXI_WSTRB(0),
        .AXI_WVALID(0),
        .AXI_WREADY(AXI_WREADY),
    //BR    
        .AXI_BRESP(AXI_BRESP),
        .AXI_BVALID(AXI_BVALID),
        .AXI_BREADY(0),
    //AR    
        .AXI_ARADDR(pc[31:0]),
        .AXI_ARVALID(pc_valid),
        .AXI_ARPROT(3'b0),
        .AXI_ARREADY(pc_ready),
    //R 
        .AXI_RDATA({inst_63_32, inst}),
        .AXI_RRESP(AXI_RRESP),
        .AXI_RVALID(inst_valid),
        .AXI_RREADY(inst_ready)
    );
    
    
    
endmodule //ifu_axi_4_lite

`endif
