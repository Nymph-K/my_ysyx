/*************************************************************
 * @ name           : lsu.v
 * @ description    : Load and Sotre Unit
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-10
*************************************************************/
`ifndef LSU_V
`define LSU_V

`include "common.v"

module lsu (
    input 						clk,
    input 						rst,
    input         [ 2:0] 		funct3,
    input         [31:0]        lsu_addr,
    input                       lsu_r_ready,
    output  reg   [63:0]        lsu_r_data,     // not align
    output                      lsu_r_valid,
    input                       lsu_w_valid,
    input         [63:0]        lsu_w_data,     // not align
    output                      lsu_w_ready,

    `ifdef CLINT_ENABLE
        output 					msip,
        output 					mtip,
    `endif

    //AW
    output [ 3:0]               LSU_AXI_AWID,
    output [31:0]               LSU_AXI_AWADDR,
    output [ 7:0]               LSU_AXI_AWLEN,
    output [ 2:0]               LSU_AXI_AWSIZE,
    output [ 1:0]               LSU_AXI_AWBURST,
    output                      LSU_AXI_AWLOCK,
    output [ 3:0]               LSU_AXI_AWCACHE,
    output [ 2:0]               LSU_AXI_AWPROT,
    output [ 3:0]               LSU_AXI_AWQOS,
    output [ 3:0]               LSU_AXI_AWREGION,
    output                      LSU_AXI_AWUSER,
    output                      LSU_AXI_AWVALID,
    input                       LSU_AXI_AWREADY,
    //W 
    output [63:0]               LSU_AXI_WDATA,
    output [ 7:0]               LSU_AXI_WSTRB,
    output                      LSU_AXI_WLAST,
    output                      LSU_AXI_WUSER,
    output                      LSU_AXI_WVALID,
    input                       LSU_AXI_WREADY,
    //BR
    input  [ 3:0]               LSU_AXI_BID,
    input  [ 1:0]               LSU_AXI_BRESP,
    input                       LSU_AXI_BUSER,
    input                       LSU_AXI_BVALID,
    output                      LSU_AXI_BREADY,
    //AR
    output [ 3:0]               LSU_AXI_ARID,
    output [31:0]               LSU_AXI_ARADDR,
    output [ 7:0]               LSU_AXI_ARLEN,
    output [ 2:0]               LSU_AXI_ARSIZE,
    output [ 1:0]               LSU_AXI_ARBURST,
    output                      LSU_AXI_ARLOCK,
    output [ 3:0]               LSU_AXI_ARCACHE,
    output [ 2:0]               LSU_AXI_ARPROT,
    output [ 3:0]               LSU_AXI_ARQOS,
    output [ 3:0]               LSU_AXI_ARREGION,
    output                      LSU_AXI_ARUSER,
    output                      LSU_AXI_ARVALID,
    input                       LSU_AXI_ARREADY,
    //R
    input  [ 3:0]               LSU_AXI_RID,
    input  [63:0]               LSU_AXI_RDATA,
    input  [ 1:0]               LSU_AXI_RRESP,
    input                       LSU_AXI_RLAST,
    input                       LSU_AXI_RUSER,
    input                       LSU_AXI_RVALID,
    output                      LSU_AXI_RREADY
);

    reg           [ 7:0]        lsu_w_strb;     // 8 Byte align, 8 Byte strobe
    wire          [31:0]        lsu_addr_a = lsu_addr & 32'hFFFFFFF8;     // 8 Byte align
    wire          [63:0]        cache_r_data;   // 8 Byte align
    reg           [63:0]        device_r_data;   // 8 Byte align
    wire                        cache_r_valid, cache_w_ready;
    reg                         device_r_valid, device_w_ready;
    
    wire [2:0]                  shift_n_byte = lsu_addr[2:0];
    wire [5:0]                  shift_n_bit  = {shift_n_byte, 3'b000}; // *8

    wire [`XLEN-1:0]            lsu_rdata_shift = (device_access ? device_r_data : cache_r_data) >> shift_n_bit;

    wire [`XLEN-1:0]            lsu_w_data_a = lsu_w_data << shift_n_bit;

    wire                        device_access = lsu_addr[31:28] == 4'hA;

    wire                        cache_r_ready = lsu_r_ready & ~device_access;
    wire                        cache_w_valid = lsu_w_valid & ~device_access;
    assign                      lsu_r_valid = cache_r_ready ? cache_r_valid : device_r_valid;
    assign                      lsu_w_ready = cache_w_valid ? cache_w_ready : device_w_ready;

import "DPI-C" function void paddr_read(input longint raddr, output longint mem_r_data);
import "DPI-C" function void paddr_write(input longint waddr, input longint mem_w_data, input byte wmask);

    always @(posedge clk ) begin
        if (rst) begin
            device_r_valid <= 1'b0;
        end else begin
            if (lsu_r_ready & device_access) begin
                if (device_r_valid) begin
                    device_r_valid <= 1'b0;
                end else begin
                    device_r_valid <= 1'b1;
                    paddr_read({32'b0, lsu_addr_a}, device_r_data);
                end
            end
            // if (lsu_r_ready && lsu_r_valid && ((lsu_addr & 32'hFFFFFFF0) == 32'ha0000060)) begin
            //     $display("Read : addr = %X, data = %X\n", lsu_addr, lsu_r_data);
            // end
            // if (lsu_w_ready && lsu_w_valid && ((lsu_addr & 32'hFFFFFFF0) == 32'ha0000060)) begin
            //     $display("Write: addr = %X, data = %X\n", lsu_addr, lsu_w_data);
            // end
        end
    end

    always @(posedge clk ) begin
        if (rst) begin
            device_w_ready <= 1'b0;
        end else begin
            if (lsu_w_valid & device_access) begin
                if (device_w_ready) begin
                    device_w_ready <= 1'b0;
                end else begin
                    device_w_ready <= 1'b1;
                    paddr_write({32'b0, lsu_addr_a}, lsu_w_data_a, lsu_w_strb);
                end
            end
        end
    end

    always @(*) begin
        if(lsu_r_ready) begin
            case (funct3)
                `LB		: lsu_r_data = {{(`XLEN-8){lsu_rdata_shift[7]}}, lsu_rdata_shift[7:0]};
                `LH		: lsu_r_data = {{(`XLEN-16){lsu_rdata_shift[15]}}, lsu_rdata_shift[15:0]};
                `LW		: lsu_r_data = {{(`XLEN-32){lsu_rdata_shift[31]}}, lsu_rdata_shift[31:0]};
                `LBU	: lsu_r_data = {{(`XLEN-8){1'b0}}, lsu_rdata_shift[7:0]};
                `LHU	: lsu_r_data = {{(`XLEN-16){1'b0}}, lsu_rdata_shift[15:0]};
                `LWU	: lsu_r_data = {{(`XLEN-32){1'b0}}, lsu_rdata_shift[31:0]};
                `LD		: lsu_r_data = lsu_rdata_shift;
                default : lsu_r_data = `XLEN'b0;
            endcase
        end else begin
            lsu_r_data = `XLEN'b0;
        end
    end
    
    always @(*) begin
        if(lsu_w_valid) begin
            case (funct3)
                `SB		: lsu_w_strb = 8'b0000_0001 << shift_n_byte;
                `SH		: lsu_w_strb = 8'b0000_0011 << shift_n_byte;
                `SW		: lsu_w_strb = 8'b0000_1111 << shift_n_byte;
                `SD		: lsu_w_strb = 8'b1111_1111;
                default : lsu_w_strb = 8'b0000_0000;
            endcase
        end else begin
            lsu_w_strb = 8'b0;
        end
    end


    /********************************** instant ************************************/
    `ifdef CLINT_ENABLE
            wire [`XLEN-1:0] mtime, mtimecmp;
            CLINT u_clint(
                .clk(clk),
                .rst(rst),
                .lsu_w_valid(lsu_w_valid),
                .lsu_w_data_a(lsu_w_data_a),
                .lsu_addr(lsu_addr),
                .msip(msip),
                .mtip(mtip),
                .mtime(mtime),
                .mtimecmp(mtimecmp)
            );
    `endif //CLINT_ENABLE

    wire                tag_w_en;
    wire  [23:0]        tag_w_data;
    wire  [23:0]        tag0;
    wire  [23:0]        tag1;
    wire  [23:0]        tag2;
    wire  [23:0]        tag3;

    wire  [ 1:0]        way;
    wire  [ 3:0]        index;
    wire  [ 5:0]        offset;

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

    cache_ctrl  u_dcache_ctrl (
        .clk                     ( clk          ),
        .rst                     ( rst          ),
        .cpu_addr                ( lsu_addr_a   ),
        .cpu_r_ready             ( cache_r_ready),
        .cpu_r_data              ( cache_r_data ),
        .cpu_r_valid             ( cache_r_valid),
        .cpu_w_valid             ( cache_w_valid),
        .cpu_w_strb              ( lsu_w_strb   ),
        .cpu_w_data              ( lsu_w_data_a ),
        .cpu_w_ready             ( cache_w_ready),
        .tag_w_en                ( tag_w_en     ),
        .tag_w_data              ( tag_w_data   ),
        .tag0                    ( tag0         ),
        .tag1                    ( tag1         ),
        .tag2                    ( tag2         ),
        .tag3                    ( tag3         ),
        .way                     ( way          ),
        .index                   ( index        ),
        .offset                  ( offset       ),
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
        .mem_r_data              ( mem_r_data   )
    );

    cache_sram  u_dcache_sram (
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

    cache_tag  u_dcache_tag (
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

    master_axi_4 u_dcache_master_axi_4 (
        .clk                     ( clk),
        .rst                     ( rst),
        .w_addr                  ( mem_w_addr),
        .w_valid                 ( mem_w_valid),
        .w_size                  ( mem_w_size),
        .w_burst                 ( mem_w_burst),
        .w_len                   ( mem_w_len),
        .w_strb                  ( mem_w_strb),
        .w_data                  ( mem_w_data),
        .w_ready                 ( mem_w_ready),
        .r_addr                  ( mem_r_addr),
        .r_ready                 ( mem_r_ready),
        .r_size                  ( mem_r_size),
        .r_burst                 ( mem_r_burst),
        .r_len                   ( mem_r_len),
        .r_valid                 ( mem_r_valid),
        .r_data                  ( mem_r_data),
        .M_AXI_AWID              ( LSU_AXI_AWID),
        .M_AXI_AWADDR            ( LSU_AXI_AWADDR),
        .M_AXI_AWLEN             ( LSU_AXI_AWLEN),
        .M_AXI_AWSIZE            ( LSU_AXI_AWSIZE),
        .M_AXI_AWBURST           ( LSU_AXI_AWBURST),
        .M_AXI_AWLOCK            ( LSU_AXI_AWLOCK),
        .M_AXI_AWCACHE           ( LSU_AXI_AWCACHE),
        .M_AXI_AWPROT            ( LSU_AXI_AWPROT),
        .M_AXI_AWQOS             ( LSU_AXI_AWQOS),
        .M_AXI_AWREGION          ( LSU_AXI_AWREGION),
        .M_AXI_AWUSER            ( LSU_AXI_AWUSER),
        .M_AXI_AWVALID           ( LSU_AXI_AWVALID),
        .M_AXI_AWREADY           ( LSU_AXI_AWREADY),
        .M_AXI_WDATA             ( LSU_AXI_WDATA),
        .M_AXI_WSTRB             ( LSU_AXI_WSTRB),
        .M_AXI_WLAST             ( LSU_AXI_WLAST),
        .M_AXI_WUSER             ( LSU_AXI_WUSER),
        .M_AXI_WVALID            ( LSU_AXI_WVALID),
        .M_AXI_WREADY            ( LSU_AXI_WREADY),
        .M_AXI_BID               ( LSU_AXI_BID),
        .M_AXI_BRESP             ( LSU_AXI_BRESP),
        .M_AXI_BUSER             ( LSU_AXI_BUSER),
        .M_AXI_BVALID            ( LSU_AXI_BVALID),
        .M_AXI_BREADY            ( LSU_AXI_BREADY),
        .M_AXI_ARID              ( LSU_AXI_ARID),
        .M_AXI_ARADDR            ( LSU_AXI_ARADDR),
        .M_AXI_ARLEN             ( LSU_AXI_ARLEN),
        .M_AXI_ARSIZE            ( LSU_AXI_ARSIZE),
        .M_AXI_ARBURST           ( LSU_AXI_ARBURST),
        .M_AXI_ARLOCK            ( LSU_AXI_ARLOCK),
        .M_AXI_ARCACHE           ( LSU_AXI_ARCACHE),
        .M_AXI_ARPROT            ( LSU_AXI_ARPROT),
        .M_AXI_ARQOS             ( LSU_AXI_ARQOS),
        .M_AXI_ARREGION          ( LSU_AXI_ARREGION),
        .M_AXI_ARUSER            ( LSU_AXI_ARUSER),
        .M_AXI_ARVALID           ( LSU_AXI_ARVALID),
        .M_AXI_ARREADY           ( LSU_AXI_ARREADY),
        .M_AXI_RID               ( LSU_AXI_RID),
        .M_AXI_RDATA             ( LSU_AXI_RDATA),
        .M_AXI_RRESP             ( LSU_AXI_RRESP),
        .M_AXI_RLAST             ( LSU_AXI_RLAST),
        .M_AXI_RUSER             ( LSU_AXI_RUSER),
        .M_AXI_RVALID            ( LSU_AXI_RVALID),
        .M_AXI_RREADY            ( LSU_AXI_RREADY)
    );

endmodule //lsu

`endif