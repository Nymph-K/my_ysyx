//Core Local Interrupt

`ifndef CLINT_V
`define CLINT_V

`include "top.v"

`define CLINT_MSIP_ADDR     `XLEN'h2000000
`define CLINT_MTIMECMP_ADDR `XLEN'h2004000
`define CLINT_MTIME_ADDR    `XLEN'h200BFF8

module CLINT (
	input  clk,
	input  rst,
    input  mem_w,
	input  [`XLEN-1:0] mem_wdata,
	input  [`XLEN-1:0] mem_addr,
    output msip,
    output mtip,
    output [`XLEN-1:0] mtime,
    output [`XLEN-1:0] mtimecmp
);

    localparam tick_count = `XLEN'h1000;

	wire [`XLEN-1:0] tick;

    wire [`XLEN-1:0] tick_in = ((tick == tick_count) || mtime_wen) ? `XLEN'b0 : tick + 1;
    Reg #(`XLEN, `XLEN'b0) u_tick (
        .clk(clk),
        .rst(rst),
        .din(tick_in),
        .dout(tick),
        .wen(1'b1));

    wire mtime_wen = (mem_addr == `CLINT_MTIME_ADDR) && mem_w;
    wire [`XLEN-1:0] mtime_in = mtime_wen ? mem_wdata : mtime + 1;
    Reg #(`XLEN, `XLEN'b0) u_mtime (
        .clk(clk),
        .rst(rst),
        .din(mtime_in),
        .dout(mtime),
        .wen((tick == tick_count) || mtime_wen));

    wire mtimecmp_wen = (mem_addr == `CLINT_MTIMECMP_ADDR) && mem_w;
    Reg #(`XLEN, `XLEN'hffffffff) u_mtimecmp (
        .clk(clk),
        .rst(rst),
        .din(mem_wdata),
        .dout(mtimecmp),
        .wen(mtimecmp_wen));

    wire mtip_in = (($unsigned(mtime) < $unsigned(mtimecmp)) || mtimecmp_wen) ? 1'b0 : 1'b1;
    Reg #(1, 1'b0) u_mtip (
        .clk(clk),
        .rst(rst),
        .din(mtip_in),
        .dout(mtip),
        .wen(1'b1));

    wire msip_wen = (mem_addr == `CLINT_MSIP_ADDR) && mem_w;
    Reg #(1, 1'h0) u_msip (
        .clk(clk),
        .rst(rst),
        .din(mem_wdata[0]),
        .dout(msip),
        .wen(msip_wen));

endmodule //CLINT

`endif /* CLINT_V */