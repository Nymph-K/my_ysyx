module ifu (
	input               clk,
	input               rst,
	input       [31:0]  pc,
	output      [63:0]  inst,
    input               inst_r_ready,
    output              inst_r_valid,
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
    
    /********************************** instant ************************************/

    wire                ifu_w_valid = 1'b0;
    wire  [ 7:0]        ifu_w_strb = 8'b0;
    wire  [63:0]        ifu_w_data = 64'b0;
    wire                ifu_w_ready;

    wire                tag_w_en;
    wire  [23:0]        tag_w_data;
    wire  [23:0]        tag0;
    wire  [23:0]        tag1;
    wire  [23:0]        tag2;
    wire  [23:0]        tag3;

    wire  [ 1:0]        way;
    wire  [ 3:0]        index;
    wire  [ 5:0]        offset;
    wire  [ 5:0]        offset_r;

    wire                sram_r_en;
    wire                sram_w_en;
    wire  [63:0]        sram_w_data;
    wire  [ 7:0]        sram_w_strb;
    wire  [63:0]        sram_r_data;

    wire  [31:0]        mem_w_addr;
    wire                mem_w_valid;
    wire  [ 2:0]        mem_w_size;
    wire  [ 1:0]        mem_w_burst;
    wire  [ 7:0]        mem_w_len;
    wire  [ 7:0]        mem_w_strb;
    wire  [63:0]        mem_w_data;
    wire                mem_w_ready;

    wire  [31:0]        mem_r_addr;
    wire                mem_r_ready;
    wire  [ 2:0]        mem_r_size;
    wire  [ 1:0]        mem_r_burst;
    wire  [ 7:0]        mem_r_len;
    wire                mem_r_valid;
    wire  [63:0]        mem_r_data;

    cache_ctrl  u_icache_ctrl (
        .clk                     ( clk          ),
        .rst                     ( rst          ),
        .cpu_addr                ( pc           ),
        .cpu_r_ready             ( inst_r_ready ),
        .cpu_r_data              ( inst         ),
        .cpu_r_valid             ( inst_r_valid ),
        .cpu_w_valid             ( ifu_w_valid  ),
        .cpu_w_strb              ( ifu_w_strb   ),
        .cpu_w_data              ( ifu_w_data   ),
        .cpu_w_ready             ( ifu_w_ready  ),
        .tag_w_en                ( tag_w_en     ),
        .tag_w_data              ( tag_w_data   ),
        .tag0                    ( tag0         ),
        .tag1                    ( tag1         ),
        .tag2                    ( tag2         ),
        .tag3                    ( tag3         ),
        .way                     ( way          ),
        .index                   ( index        ),
        .offset                  ( offset       ),
        .offset_r                ( offset_r     ),
        .sram_r_en               ( sram_r_en    ),
        .sram_w_en               ( sram_w_en    ),
        .sram_w_data             ( sram_w_data  ),
        .sram_w_strb             ( sram_w_strb  ),
        .sram_r_data             ( sram_r_data  ),
        .mem_w_addr              ( mem_w_addr   ),
        .mem_w_valid             ( mem_w_valid  ),
        .mem_w_size              ( mem_w_size   ),
        .mem_w_burst             ( mem_w_burst  ),
        .mem_w_len               ( mem_w_len    ),
        .mem_w_strb              ( mem_w_strb   ),
        .mem_w_data              ( mem_w_data   ),
        .mem_w_ready             ( mem_w_ready  ),
        .mem_r_addr              ( mem_r_addr   ),
        .mem_r_ready             ( mem_r_ready  ),
        .mem_r_size              ( mem_r_size   ),
        .mem_r_burst             ( mem_r_burst  ),
        .mem_r_len               ( mem_r_len    ),
        .mem_r_valid             ( mem_r_valid  ),
        .mem_r_data              ( mem_r_data   ),
        .cache_busy              ( if_busy      )
    );

    cache_sram  u_icache_sram (
        .clk                     ( clk           ),
        .rst                     ( rst           ),
        .way                     ( way           ),
        .index                   ( index         ),
        .offset                  ( offset        ),
        .offset_r                ( offset_r      ),
        .sram_r_en               ( sram_r_en     ),
        .sram_w_en               ( sram_w_en     ),
        .sram_w_data             ( sram_w_data   ),
        .sram_w_strb             ( sram_w_strb   ),
        .sram_r_data             ( sram_r_data   )
    );

    cache_tag  u_icache_tag (
        .clk                     ( clk          ),
        .rst                     ( rst          ),
        .way                     ( way          ),
        .index                   ( index        ),
        .tag_w_en                ( tag_w_en     ),
        .tag_w_data              ( tag_w_data   ),
        .tag0                    ( tag0         ),
        .tag1                    ( tag1         ),
        .tag2                    ( tag2         ),
        .tag3                    ( tag3         )
    );

    master_axi_4 u_icache_master_axi_4 (
        .clk                     (clk),
        .rst                     (rst),
        .w_addr                  (mem_w_addr),
        .w_valid                 (mem_w_valid),
        .w_size                  (mem_w_size),
        .w_burst                 (mem_w_burst),
        .w_len                   (mem_w_len),
        .w_strb                  (mem_w_strb),
        .w_data                  (mem_w_data),
        .w_ready                 (mem_w_ready),
        .r_addr                  (mem_r_addr),
        .r_ready                 (mem_r_ready),
        .r_size                  (mem_r_size),
        .r_burst                 (mem_r_burst),
        .r_len                   (mem_r_len),
        .r_valid                 (mem_r_valid),
        .r_data                  (mem_r_data),
        .M_AXI_AWID              (IFU_AXI_AWID),
        .M_AXI_AWADDR            (IFU_AXI_AWADDR),
        .M_AXI_AWLEN             (IFU_AXI_AWLEN),
        .M_AXI_AWSIZE            (IFU_AXI_AWSIZE),
        .M_AXI_AWBURST           (IFU_AXI_AWBURST),
        .M_AXI_AWLOCK            (IFU_AXI_AWLOCK),
        .M_AXI_AWCACHE           (IFU_AXI_AWCACHE),
        .M_AXI_AWPROT            (IFU_AXI_AWPROT),
        .M_AXI_AWQOS             (IFU_AXI_AWQOS),
        .M_AXI_AWREGION          (IFU_AXI_AWREGION),
        .M_AXI_AWUSER            (IFU_AXI_AWUSER),
        .M_AXI_AWVALID           (IFU_AXI_AWVALID),
        .M_AXI_AWREADY           (IFU_AXI_AWREADY),
        .M_AXI_WDATA             (IFU_AXI_WDATA),
        .M_AXI_WSTRB             (IFU_AXI_WSTRB),
        .M_AXI_WLAST             (IFU_AXI_WLAST),
        .M_AXI_WUSER             (IFU_AXI_WUSER),
        .M_AXI_WVALID            (IFU_AXI_WVALID),
        .M_AXI_WREADY            (IFU_AXI_WREADY),
        .M_AXI_BID               (IFU_AXI_BID),
        .M_AXI_BRESP             (IFU_AXI_BRESP),
        .M_AXI_BUSER             (IFU_AXI_BUSER),
        .M_AXI_BVALID            (IFU_AXI_BVALID),
        .M_AXI_BREADY            (IFU_AXI_BREADY),
        .M_AXI_ARID              (IFU_AXI_ARID),
        .M_AXI_ARADDR            (IFU_AXI_ARADDR),
        .M_AXI_ARLEN             (IFU_AXI_ARLEN),
        .M_AXI_ARSIZE            (IFU_AXI_ARSIZE),
        .M_AXI_ARBURST           (IFU_AXI_ARBURST),
        .M_AXI_ARLOCK            (IFU_AXI_ARLOCK),
        .M_AXI_ARCACHE           (IFU_AXI_ARCACHE),
        .M_AXI_ARPROT            (IFU_AXI_ARPROT),
        .M_AXI_ARQOS             (IFU_AXI_ARQOS),
        .M_AXI_ARREGION          (IFU_AXI_ARREGION),
        .M_AXI_ARUSER            (IFU_AXI_ARUSER),
        .M_AXI_ARVALID           (IFU_AXI_ARVALID),
        .M_AXI_ARREADY           (IFU_AXI_ARREADY),
        .M_AXI_RID               (IFU_AXI_RID),
        .M_AXI_RDATA             (IFU_AXI_RDATA),
        .M_AXI_RRESP             (IFU_AXI_RRESP),
        .M_AXI_RLAST             (IFU_AXI_RLAST),
        .M_AXI_RUSER             (IFU_AXI_RUSER),
        .M_AXI_RVALID            (IFU_AXI_RVALID),
        .M_AXI_RREADY            (IFU_AXI_RREADY)
    );

endmodule //ifu
