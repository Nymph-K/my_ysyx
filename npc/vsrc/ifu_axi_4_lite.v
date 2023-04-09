/*************************************************************
 * @ name           : ifu_axi_4_lite.v
 * @ description    : IFU using AXI4-lite bus interface
 * @ use module     : None
 * @ author         : K
 * @ date modified  : 2023-3-18
 *************************************************************/
`ifndef IFU_AXI_4_LITE_V
`define IFU_AXI_4_LITE_V

module ifu_axi_4_lite (
	input                               clk,
	input                               rst,
    input                               pc_valid,
    output                              pc_ready,
	input   [`XLEN-1:0]                 pc,
    output   reg                        inst_ready,
    output                              inst_valid,
	output  [31:0]                      inst,
    //AW    
    output      wire [31 : 0]  	        IFU_AXI_AWADDR,
    output      wire [2 : 0]   	        IFU_AXI_AWPROT,
    output      wire           	        IFU_AXI_AWVALID,
    input       wire           	        IFU_AXI_AWREADY,
    //W         
    output      wire [63 : 0]  	        IFU_AXI_WDATA,
    output      wire [7 : 0]   	        IFU_AXI_WSTRB,
    output      wire           	        IFU_AXI_WVALID,
    input       wire           	        IFU_AXI_WREADY,
    //BR            
    input       wire [1 : 0]   	        IFU_AXI_BRESP,
    input       wire           	        IFU_AXI_BVALID,
    output      wire           	        IFU_AXI_BREADY,
    //AR            
    output      wire [31 : 0]  	        IFU_AXI_ARADDR,
    output      wire           	        IFU_AXI_ARVALID,
    output      wire [2 : 0]   	        IFU_AXI_ARPROT,
    input       wire           	        IFU_AXI_ARREADY,
    //R         
    input       wire [63 : 0]  	        IFU_AXI_RDATA,
    input       wire [1 : 0]   	        IFU_AXI_RRESP,
    input       wire           	        IFU_AXI_RVALID,
    output      wire           	        IFU_AXI_RREADY
);
    
    //AW
    assign  IFU_AXI_AWADDR = 0;
    assign  IFU_AXI_AWPROT = 0;
    assign  IFU_AXI_AWVALID = 0;
    //      IFU_AXI_AWREADY

    //W
    assign  IFU_AXI_WDATA = 0;
    assign  IFU_AXI_WSTRB = 0;
    assign  IFU_AXI_WVALID = 0;
    //      IFU_AXI_WREADY

    //BR
    //      IFU_AXI_BRESP
    //      IFU_AXI_BVALID
    assign  IFU_AXI_BREADY = 0;
    
    //AR
    assign  IFU_AXI_ARADDR = pc[31:0];
    assign  IFU_AXI_ARVALID = pc_valid;
    assign  IFU_AXI_ARPROT = 0;
    assign  pc_ready = IFU_AXI_ARREADY;

    //R
    assign  inst = IFU_AXI_RDATA[31:0];
    //      IFU_AXI_RRESP
    assign  inst_valid = IFU_AXI_RVALID;
    assign  IFU_AXI_RREADY = inst_ready;
    
    always @(posedge clk ) begin
        if (rst) begin
            inst_ready <= 1'b0;
        end else begin
            if (inst_valid && inst_ready) begin
                inst_ready <= 1'b0;
            end else begin
                inst_ready <= 1'b1;
            end
        end
    end
    
    
endmodule //ifu_axi_4_lite

`endif
