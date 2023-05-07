`timescale 1ns/1ns

`include "master_axi_4.v"
`include "slave_axi_4.v"

module tb_axi_4_full;

    reg                 clk;
    reg                 rst;

    reg    [31:0]       w_addr;
    reg                 w_valid;
    wire   [ 2:0]       w_size;
    reg    [ 1:0]       w_burst;
    reg    [ 7:0]       w_len;
    wire   [ 7:0]       w_strb;
    reg    [63:0]       w_data;
    wire                w_ready;

    reg    [31:0]       r_addr;
    reg                 r_ready;
    wire   [ 2:0]       r_size;
    reg    [ 1:0]       r_burst;
    reg    [ 7:0]       r_len;
    wire                r_valid;
    wire   [63:0]       r_data;

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
        .clk(clk),
        .rst(rst),
        .w_addr(w_addr),
        .w_valid(w_valid),
        .w_size(w_size),
        .w_burst(w_burst),
        .w_len(w_len),
        .w_strb(w_strb),
        .w_data(w_data),
        .w_ready(w_ready),
        .r_addr(r_addr),
        .r_ready(r_ready),
        .r_size(r_size),
        .r_burst(r_burst),
        .r_len(r_len),
        .r_valid(r_valid),
        .r_data(r_data),
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

    localparam CLK_PERIOD = 2;
    //always #(CLK_PERIOD/2) clk=~clk;
    initial begin
        clk = 1'b1;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        rst = 1'b0;
        repeat(3)  @(posedge clk);
        rst = 1'b1;
        repeat(5)  @(posedge clk);
        rst = 1'b0;
    end

    assign w_size = 3'b011; // 8 Byte
    assign w_strb = 8'hFF;
    assign r_size = 3'b011; // 8 Byte

    initial begin
        w_valid = 0;
        r_ready = 0;
        repeat(10)  @(posedge clk);
        
        w_len = 0;
        w_addr = 32'h8000_0000;
        w_burst = 2'b00;
        write_data();
        repeat(5)  @(posedge clk);

        w_len = 2;
        w_addr = 32'h8000_0002;
        w_burst = 2'b00;
        write_data();
        repeat(5)  @(posedge clk);
        
        w_len = 8;
        w_addr = 32'h8000_0010;
        w_burst = 2'b01;
        write_data();
        repeat(5)  @(posedge clk);
        
        w_len = 7;
        w_addr = 32'h8000_0030;
        w_burst = 2'b10;
        write_data();
        repeat(5)  @(posedge clk);

        r_burst = 2'b10;
        r_len = 0;
        read_data();
        repeat(5)  @(posedge clk);

        r_len = 3;
        read_data();
        repeat(5)  @(posedge clk);
        
        r_len = 8;
        read_data();
        repeat(5)  @(posedge clk);

        $stop;
    end

    task write_data;
    begin
        w_valid = 1;
        repeat(w_len + 1) begin
            w_data  = {$random(), $random()};
            @(posedge clk);
            wait(w_ready) @(posedge clk);
        end
        w_valid = 0;
    end
    endtask

    task read_data;
    begin
        r_ready = 1;
        repeat(r_len + 1) begin
            @(posedge clk);
            wait(r_valid) @(posedge clk);
        end
        r_ready = 0;
    end
    endtask

endmodule