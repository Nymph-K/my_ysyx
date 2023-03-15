//Memory Access Unit

`ifndef MAU_V
`define MAU_V

`include "top.v"
`include "IDU.v"
`include "CLINT.v"

module MAU (
    input clk,
	input rst,
	input  [2:0] funct3,
	input  [6:0] opcode,
	input  [`XLEN-1:0] src2,
    input  [`XLEN-1:0] alu_result,
	output [`XLEN-1:0] ld_data
`ifdef CLINT_ENABLE
	,
    output msip,
    output mtip
`endif
);
	//LOAD
	localparam LB		= 3'b000;
	localparam LH		= 3'b001;
	localparam LW		= 3'b010;
	localparam LBU		= 3'b100;
	localparam LHU		= 3'b101;
	localparam LWU		= 3'b110;
	localparam LD		= 3'b011;
	//STORE
	localparam SB		= 3'b000;
	localparam SH		= 3'b001;
	localparam SW		= 3'b010;
	localparam SD		= 3'b011;

	wire mem_r;
	wire mem_w;
	reg [`XLEN-1:0] mem_rdata;
	wire [`XLEN-1:0] mem_wdata;
	wire [`XLEN-1:0] mem_addr;

	assign mem_w = (opcode == `STORE) ? 1'b1 : 1'b0;
	assign mem_r = (opcode == `LOAD) ? 1'b1 : 1'b0;;
	assign mem_wdata = (mem_w == 1'b1) ? src2 : `XLEN'b0;
	assign mem_addr = mem_w || mem_r ? alu_result : `XLEN'b0;


	`ifdef ADDR_ALIGN

	wire [7:0] mem_r8bit;
	MuxKeyWithDefault #(8, 3, 8) u_mem_r8bit (
		.out(mem_r8bit),
		.key(mem_addr[2:0]),
		.default_out(8'b0),
		.lut({
			3'b000, mem_rdata[7:0],
			3'b001, mem_rdata[15:8],
			3'b010, mem_rdata[23:16],
			3'b011, mem_rdata[31:24],
			3'b100, mem_rdata[39:32],
			3'b101, mem_rdata[47:40],
			3'b110, mem_rdata[55:48],
			3'b111, mem_rdata[63:56]
		})
	);

	wire [15:0] mem_r16bit;
	MuxKeyWithDefault #(7, 3, 16) u_mem_r16bit (
		.out(mem_r16bit),
		.key(mem_addr[2:0]),
		.default_out(16'b0),
		.lut({
			3'b000, mem_rdata[15:0],
			3'b001, mem_rdata[23:8],
			3'b010, mem_rdata[31:16],
			3'b011, mem_rdata[39:24],
			3'b100, mem_rdata[47:32],
			3'b101, mem_rdata[55:40],
			3'b110, mem_rdata[63:48]
		})
	);

	wire [31:0] mem_r32bit;
	MuxKeyWithDefault #(5, 3, 32) u_mem_r32bit (
		.out(mem_r32bit),
		.key(mem_addr[2:0]),
		.default_out(32'b0),
		.lut({
			3'b000, mem_rdata[31:0],
			3'b001, mem_rdata[39:8],
			3'b010, mem_rdata[47:16],
			3'b011, mem_rdata[55:24],
			3'b100, mem_rdata[63:32]
		})
	);

	MuxKeyWithDefault #(7, 3, `XLEN) u_ld_data (
		.out(ld_data),
		.key(funct3),
		.default_out(`XLEN'b0),
		.lut({
			LB, {{(`XLEN-8){mem_r8bit[7]}}, mem_r8bit[7:0]},
			LH,	{{(`XLEN-16){mem_r16bit[15]}}, mem_r16bit[15:0]},
			LW,	{{(`XLEN-32){mem_r32bit[31]}}, mem_r32bit[31:0]},
			LBU,{{(`XLEN-8){1'b0}}, mem_r8bit[7:0]},
			LHU,{{(`XLEN-16){1'b0}}, mem_r16bit[15:0]},
			LWU,{{(`XLEN-32){1'b0}}, mem_r32bit[31:0]},
			LD,	mem_rdata
		})
	);

	wire [7:0] wmask;
	MuxKeyWithDefault #(4, 3, 8) u_wmask (
		.out(wmask),
		.key(funct3),
		.default_out(8'b0),
		.lut({
			SB, 8'b0000_0001 << mem_addr[2:0],
			SH, 8'b0000_0011 << mem_addr[2:0],
			SW, 8'b0000_1111 << mem_addr[2:0],
			SD, 8'b1111_1111
		})
	);
	`else//ADDR_ALIGN


	wire [7:0] wmask = 8'b1 << funct3[1:0];

	MuxKeyWithDefault #(7, 3, `XLEN) u_ld_data (
		.out(ld_data),
		.key(funct3),
		.default_out(`XLEN'b0),
		.lut({
			LB, {{(`XLEN-8){mem_rdata[7]}}, mem_rdata[7:0]},
			LH,	{{(`XLEN-16){mem_rdata[15]}}, mem_rdata[15:0]},
			LW,	{{(`XLEN-32){mem_rdata[31]}}, mem_rdata[31:0]},
			LBU,{{(`XLEN-8){1'b0}}, mem_rdata[7:0]},
			LHU,{{(`XLEN-16){1'b0}}, mem_rdata[15:0]},
			LWU,{{(`XLEN-32){1'b0}}, mem_rdata[31:0]},
			LD,	mem_rdata
		})
	);
	`endif//ADDR_ALIGN
	
	`ifdef CLINT_ENABLE
		wire [`XLEN-1:0] mtime, mtimecmp;
		CLINT u_clint(
			.clk(clk),
			.rst(rst),
			.mem_w(mem_w),
			.mem_wdata(mem_wdata),
			.mem_addr(mem_addr),
			.msip(msip),
			.mtip(mtip),
			.mtime(mtime),
			.mtimecmp(mtimecmp)
		);
	`endif //CLINT_ENABLE

import "DPI-C" function void paddr_read(input longint raddr, output longint rdata);
import "DPI-C" function void paddr_write(input longint waddr, input longint wdata, input byte wmask);
	always_latch @(negedge clk) begin
		if (mem_r) begin
				`ifdef CLINT_ENABLE
				if (mem_addr == `CLINT_MTIME_ADDR) begin
					mem_rdata = mtime;
				end else if (mem_addr == `CLINT_MTIMECMP_ADDR) begin
					mem_rdata = mtimecmp;
				end else if (mem_addr == `CLINT_MSIP_ADDR) begin
					mem_rdata = {{(`XLEN-1){1'b0}}, msip};
				end
				`endif
			paddr_read(mem_addr, mem_rdata);
		end
		if (mem_w) begin
			paddr_write(mem_addr, mem_wdata, wmask);
		end
	end

endmodule //MAU

`endif