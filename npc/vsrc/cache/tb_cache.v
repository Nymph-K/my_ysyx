`timescale  1ns / 1ns

module tb_cache;

// cache_ctrl Parameters
parameter PERIOD  = 2;


// cache_ctrl Inputs
reg   clk                                  ;
reg   rst                                  ;
reg   [31:0]  lsu_addr                     ;
reg   lsu_r_ready                          ;
reg   lsu_w_valid                          ;
reg   [ 7:0]  lsu_w_strb                   ;
reg   [63:0]  lsu_w_data                   ;

wire  [23:0]  tag0                         ;
wire  [23:0]  tag1                         ;
wire  [23:0]  tag2                         ;
wire  [23:0]  tag3                         ;
wire  [63:0]  sram_r_data                  ;
wire  mem_w_ready                          ;
wire  mem_r_valid                          ;
wire  [63:0]  mem_r_data                   ;

// cache_ctrl Outputs
wire  [63:0]  lsu_r_data                   ;
wire  lsu_r_valid                          ;
wire  lsu_w_ready                          ;
wire  tag_w_en                             ;
wire  [23:0]  tag_w_data                   ;
wire  [ 1:0]  way                          ;
wire  [ 3:0]  index                        ;
wire  [ 5:0]  offset                       ;
wire  sram_r_en                            ;
wire  sram_w_en                            ;
wire  [63:0]  sram_w_data                  ;
wire  [ 7:0]  sram_w_strb                  ;
wire  [31:0]  mem_w_addr                   ;
wire  mem_w_valid                          ;
wire  [ 2:0]  mem_w_size                   ;
wire  [ 1:0]  mem_w_burst                  ;
wire  [ 7:0]  mem_w_len                    ;
wire  [ 7:0]  mem_w_strb                   ;
wire  [63:0]  mem_w_data                   ;
wire  [31:0]  mem_r_addr                   ;
wire  mem_r_ready                          ;
wire  [ 2:0]  mem_r_size                   ;
wire  [ 1:0]  mem_r_burst                  ;
wire  [ 7:0]  mem_r_len                    ;


    initial begin
        clk = 1'b1;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial
    begin
        rst  =  1;
        #(PERIOD*5);
        rst  =  0;
    end

    initial begin
        lsu_r_ready = 0;
        lsu_w_valid = 0;
       repeat(5)  @(posedge clk);
        lsu_w_data  = 64'h1;
        lsu_w_strb  = 8'h01;
        lsu_addr    = 32'h8000_0000;
        write_data();
        repeat(1)  @(posedge clk);

        lsu_w_data  = 64'd2 << 8;
        lsu_w_strb  = 8'd1 << 1;
        lsu_addr    = 32'h8100_0000;
        write_data();
        repeat(1)  @(posedge clk);
        
        lsu_w_data  = 64'd3 << 16;
        lsu_w_strb  = 8'd1 << 2;
        lsu_addr    = 32'h8200_0000;
        write_data();
        repeat(1)  @(posedge clk);

        lsu_w_data  = 64'd4 << 24;
        lsu_w_strb  = 8'd1 << 3;
        lsu_addr    = 32'h8300_0000;
        write_data();
        repeat(1)  @(posedge clk);

        lsu_w_data  = 64'd5 << 32;
        lsu_w_strb  = 8'd1 << 4;
        lsu_addr    = 32'h8400_0000;
        write_data();
        repeat(1)  @(posedge clk);

        lsu_w_data  = 64'd6 << 40;
        lsu_w_strb  = 8'd1 << 5;
        lsu_addr    = 32'h8500_0000;
        write_data();
        repeat(1)  @(posedge clk);

        lsu_addr    = 32'h8000_0000;
        read_data();
        repeat(1)  @(posedge clk);

        lsu_addr    = 32'h8600_0030;
        read_data();
        repeat(1)  @(posedge clk);

        lsu_addr    = 32'h8700_0020;
        read_data();
        repeat(1)  @(posedge clk);
    end

    task write_data;
    begin
        lsu_w_valid = 1;
        @(posedge clk);
        wait(lsu_w_ready);
        @(posedge clk);
        lsu_w_valid = 0;
    end
    endtask

    task read_data;
    begin
        lsu_r_ready = 1;
        @(posedge clk);
        wait(lsu_r_valid);
        @(posedge clk);
        lsu_r_ready = 0;
    end
    endtask

/********************************** instant ************************************/
cache_ctrl  u_cache_ctrl (
    .clk                     ( clk           ),
    .rst                     ( rst           ),
    .lsu_addr                ( lsu_addr      ),
    .lsu_r_ready             ( lsu_r_ready   ),
    .lsu_w_valid             ( lsu_w_valid   ),
    .lsu_w_strb              ( lsu_w_strb    ),
    .lsu_w_data              ( lsu_w_data    ),
    .tag0                    ( tag0          ),
    .tag1                    ( tag1          ),
    .tag2                    ( tag2          ),
    .tag3                    ( tag3          ),
    .sram_r_data             ( sram_r_data   ),
    .mem_w_ready             ( mem_w_ready   ),
    .mem_r_valid             ( mem_r_valid   ),
    .mem_r_data              ( mem_r_data    ),

    .lsu_r_data              ( lsu_r_data    ),
    .lsu_r_valid             ( lsu_r_valid   ),
    .lsu_w_ready             ( lsu_w_ready   ),
    .tag_w_en                ( tag_w_en      ),
    .tag_w_data              ( tag_w_data    ),
    .way                     ( way           ),
    .index                   ( index         ),
    .offset                  ( offset        ),
    .sram_r_en               ( sram_r_en     ),
    .sram_w_en               ( sram_w_en     ),
    .sram_w_data             ( sram_w_data   ),
    .sram_w_strb             ( sram_w_strb   ),
    .mem_w_addr              ( mem_w_addr    ),
    .mem_w_valid             ( mem_w_valid   ),
    .mem_w_size              ( mem_w_size    ),
    .mem_w_burst             ( mem_w_burst   ),
    .mem_w_len               ( mem_w_len     ),
    .mem_w_strb              ( mem_w_strb    ),
    .mem_w_data              ( mem_w_data    ),
    .mem_r_addr              ( mem_r_addr    ),
    .mem_r_ready             ( mem_r_ready   ),
    .mem_r_size              ( mem_r_size    ),
    .mem_r_burst             ( mem_r_burst   ),
    .mem_r_len               ( mem_r_len     )
);

cache_sram  u_cache_sram (
    .clk                     ( clk           ),
    .rst                     ( rst           ),
    .way                     ( way           ),
    .index                   ( index         ),
    .offset                  ( offset        ),
    .sram_r_en               ( sram_r_en     ),
    .sram_w_en               ( sram_w_en     ),
    .sram_w_data             ( sram_w_data   ),
    .sram_w_strb             ( sram_w_strb   ),

    .sram_r_data             ( sram_r_data   )
);

cache_tag  u_cache_tag (
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

    //AW
    wire   [ 3:0]       AXI_AWID;
    wire   [31:0]       AXI_AWADDR;
    wire   [ 7:0]       AXI_AWLEN;
    wire   [ 2:0]       AXI_AWSIZE;
    wire   [ 1:0]       AXI_AWBURST;
    wire                AXI_AWLOCK;
    wire   [ 3:0]       AXI_AWCACHE;
    wire   [ 2:0]       AXI_AWPROT;
    wire   [ 3:0]       AXI_AWQOS;
    wire   [ 3:0]       AXI_AWREGION;
    wire                AXI_AWUSER;
    wire                AXI_AWVALID;
    wire                AXI_AWREADY;
    //W 
    wire   [63:0]       AXI_WDATA;
    wire   [ 7:0]       AXI_WSTRB;
    wire                AXI_WLAST;
    wire                AXI_WUSER;
    wire                AXI_WVALID;
    wire                AXI_WREADY;
    //BR    
    wire   [ 3:0]       AXI_BID;
    wire   [ 1:0]       AXI_BRESP;
    wire                AXI_BUSER;
    wire                AXI_BVALID;
    wire                AXI_BREADY;
    //AR    
    wire   [ 3:0]       AXI_ARID;
    wire   [31:0]       AXI_ARADDR;
    wire   [ 7:0]       AXI_ARLEN;
    wire   [ 2:0]       AXI_ARSIZE;
    wire   [ 1:0]       AXI_ARBURST;
    wire                AXI_ARLOCK;
    wire   [ 3:0]       AXI_ARCACHE;
    wire   [ 2:0]       AXI_ARPROT;
    wire   [ 3:0]       AXI_ARQOS;
    wire   [ 3:0]       AXI_ARREGION;
    wire                AXI_ARUSER;
    wire                AXI_ARVALID;
    wire                AXI_ARREADY;
    //R     
    wire   [ 3:0]       AXI_RID;
    wire   [63:0]       AXI_RDATA;
    wire   [ 1:0]       AXI_RRESP;
    wire                AXI_RLAST;
    wire                AXI_RUSER;
    wire                AXI_RVALID;
    wire                AXI_RREADY;

    master_axi_4 u_master_axi_4 (
        .clk                (clk),
        .rst                (rst),
        .w_addr             (mem_w_addr),
        .w_valid            (mem_w_valid),
        .w_size             (mem_w_size),
        .w_burst            (mem_w_burst),
        .w_len              (mem_w_len),
        .w_strb             (mem_w_strb),
        .w_data             (mem_w_data),
        .w_ready            (mem_w_ready),
        .r_addr             (mem_r_addr),
        .r_ready            (mem_r_ready),
        .r_size             (mem_r_size),
        .r_burst            (mem_r_burst),
        .r_len              (mem_r_len),
        .r_valid            (mem_r_valid),
        .r_data             (mem_r_data),
        .M_AXI_AWID         (AXI_AWID),
        .M_AXI_AWADDR       (AXI_AWADDR),
        .M_AXI_AWLEN        (AXI_AWLEN),
        .M_AXI_AWSIZE       (AXI_AWSIZE),
        .M_AXI_AWBURST      (AXI_AWBURST),
        .M_AXI_AWLOCK       (AXI_AWLOCK),
        .M_AXI_AWCACHE      (AXI_AWCACHE),
        .M_AXI_AWPROT       (AXI_AWPROT),
        .M_AXI_AWQOS        (AXI_AWQOS),
        .M_AXI_AWREGION     (AXI_AWREGION),
        .M_AXI_AWUSER       (AXI_AWUSER),
        .M_AXI_AWVALID      (AXI_AWVALID),
        .M_AXI_AWREADY      (AXI_AWREADY),
        .M_AXI_WDATA        (AXI_WDATA),
        .M_AXI_WSTRB        (AXI_WSTRB),
        .M_AXI_WLAST        (AXI_WLAST),
        .M_AXI_WUSER        (AXI_WUSER),
        .M_AXI_WVALID       (AXI_WVALID),
        .M_AXI_WREADY       (AXI_WREADY),
        .M_AXI_BID          (AXI_BID),
        .M_AXI_BRESP        (AXI_BRESP),
        .M_AXI_BUSER        (AXI_BUSER),
        .M_AXI_BVALID       (AXI_BVALID),
        .M_AXI_BREADY       (AXI_BREADY),
        .M_AXI_ARID         (AXI_ARID),
        .M_AXI_ARADDR       (AXI_ARADDR),
        .M_AXI_ARLEN        (AXI_ARLEN),
        .M_AXI_ARSIZE       (AXI_ARSIZE),
        .M_AXI_ARBURST      (AXI_ARBURST),
        .M_AXI_ARLOCK       (AXI_ARLOCK),
        .M_AXI_ARCACHE      (AXI_ARCACHE),
        .M_AXI_ARPROT       (AXI_ARPROT),
        .M_AXI_ARQOS        (AXI_ARQOS),
        .M_AXI_ARREGION     (AXI_ARREGION),
        .M_AXI_ARUSER       (AXI_ARUSER),
        .M_AXI_ARVALID      (AXI_ARVALID),
        .M_AXI_ARREADY      (AXI_ARREADY),
        .M_AXI_RID          (AXI_RID),
        .M_AXI_RDATA        (AXI_RDATA),
        .M_AXI_RRESP        (AXI_RRESP),
        .M_AXI_RLAST        (AXI_RLAST),
        .M_AXI_RUSER        (AXI_RUSER),
        .M_AXI_RVALID       (AXI_RVALID),
        .M_AXI_RREADY       (AXI_RREADY)
    );
    
    slave_axi_4 u_slave_axi_4 (
        .clk(clk),
        .rst(rst),

        .S_AXI_AWID         (AXI_AWID),
        .S_AXI_AWADDR       (AXI_AWADDR),
        .S_AXI_AWLEN        (AXI_AWLEN),
        .S_AXI_AWSIZE       (AXI_AWSIZE),
        .S_AXI_AWBURST      (AXI_AWBURST),
        .S_AXI_AWLOCK       (AXI_AWLOCK),
        .S_AXI_AWCACHE      (AXI_AWCACHE),
        .S_AXI_AWPROT       (AXI_AWPROT),
        .S_AXI_AWQOS        (AXI_AWQOS),
        .S_AXI_AWREGION     (AXI_AWREGION),
        .S_AXI_AWUSER       (AXI_AWUSER),
        .S_AXI_AWVALID      (AXI_AWVALID),
        .S_AXI_AWREADY      (AXI_AWREADY),
        .S_AXI_WDATA        (AXI_WDATA),
        .S_AXI_WSTRB        (AXI_WSTRB),
        .S_AXI_WLAST        (AXI_WLAST),
        .S_AXI_WUSER        (AXI_WUSER),
        .S_AXI_WVALID       (AXI_WVALID),
        .S_AXI_WREADY       (AXI_WREADY),
        .S_AXI_BID          (AXI_BID),
        .S_AXI_BRESP        (AXI_BRESP),
        .S_AXI_BUSER        (AXI_BUSER),
        .S_AXI_BVALID       (AXI_BVALID),
        .S_AXI_BREADY       (AXI_BREADY),
        .S_AXI_ARID         (AXI_ARID),
        .S_AXI_ARADDR       (AXI_ARADDR),
        .S_AXI_ARLEN        (AXI_ARLEN),
        .S_AXI_ARSIZE       (AXI_ARSIZE),
        .S_AXI_ARBURST      (AXI_ARBURST),
        .S_AXI_ARLOCK       (AXI_ARLOCK),
        .S_AXI_ARCACHE      (AXI_ARCACHE),
        .S_AXI_ARPROT       (AXI_ARPROT),
        .S_AXI_ARQOS        (AXI_ARQOS),
        .S_AXI_ARREGION     (AXI_ARREGION),
        .S_AXI_ARUSER       (AXI_ARUSER),
        .S_AXI_ARVALID      (AXI_ARVALID),
        .S_AXI_ARREADY      (AXI_ARREADY),
        .S_AXI_RID          (AXI_RID),
        .S_AXI_RDATA        (AXI_RDATA),
        .S_AXI_RRESP        (AXI_RRESP),
        .S_AXI_RLAST        (AXI_RLAST),
        .S_AXI_RUSER        (AXI_RUSER),
        .S_AXI_RVALID       (AXI_RVALID),
        .S_AXI_RREADY       (AXI_RREADY)
    );


endmodule