/*************************************************************
 * @ name           : lsu.v
 * @ description    : Load and Sotre Unit
 * @ use module     : 
 * @ author         : K
 * @ chnge date     : 2023-3-13
*************************************************************/
`ifndef LSU_V
`define LSU_V

`include "common.v"

module lsu (
    input 						clk,
	input 						rst,
	`ifdef USE_AXI_IFU
		input   				inst_valid,
		output  reg 			inst_ready,
	`endif
	input 						inst_load,
	input 						inst_store,
	input [2:0] 				funct3,
    input [`XLEN-1:0] 			mem_addr,
	input [`XLEN-1:0] 			mem_w_data,
	`ifdef CLINT_ENABLE
		output msip,
		output mtip,
	`endif
	`ifdef USE_IF_CASE
		output reg [`XLEN-1:0] mem_r_data
	`else
		output 	   [`XLEN-1:0] mem_r_data
	`endif
);

	reg [`XLEN-1:0] mem_rdata;

	`ifdef USE_IF_CASE
	
		`ifdef ADDR_ALIGN

			reg [7:0] mem_r8bit;
			always @(*) begin
				case (mem_addr[2:0])
					3'b000	: mem_r8bit = mem_rdata[7:0];
					3'b001	: mem_r8bit = mem_rdata[15:8];
					3'b010	: mem_r8bit = mem_rdata[23:16];
					3'b011	: mem_r8bit = mem_rdata[31:24];
					3'b100	: mem_r8bit = mem_rdata[39:32];
					3'b101	: mem_r8bit = mem_rdata[47:40];
					3'b110	: mem_r8bit = mem_rdata[55:48];
					3'b111	: mem_r8bit = mem_rdata[63:56];
				endcase
			end
			
			reg [15:0] mem_r16bit;
			always @(*) begin
				case (mem_addr[2:0])
					3'b000	: mem_r16bit = mem_rdata[15:0];
					3'b001	: mem_r16bit = mem_rdata[23:8];
					3'b010	: mem_r16bit = mem_rdata[31:16];
					3'b011	: mem_r16bit = mem_rdata[39:24];
					3'b100	: mem_r16bit = mem_rdata[47:32];
					3'b101	: mem_r16bit = mem_rdata[55:40];
					3'b110	: mem_r16bit = mem_rdata[63:48];
					default : mem_r16bit = 16'b0;
				endcase
			end
			
			reg [31:0] mem_r32bit;
			always @(*) begin
				case (mem_addr[2:0])
					3'b000	: mem_r32bit = mem_rdata[31:0];
					3'b001	: mem_r32bit = mem_rdata[39:8];
					3'b010	: mem_r32bit = mem_rdata[47:16];
					3'b011	: mem_r32bit = mem_rdata[55:24];
					3'b100	: mem_r32bit = mem_rdata[63:32];
					default : mem_r32bit = 32'b0;
				endcase
			end
			
			always @(*) begin
				case (funct3)
					`LB		: mem_r_data = {{(`XLEN-8){mem_r8bit[7]}}, mem_r8bit[7:0]};
					`LH		: mem_r_data = {{(`XLEN-16){mem_r16bit[15]}}, mem_r16bit[15:0]};
					`LW		: mem_r_data = {{(`XLEN-32){mem_r32bit[31]}}, mem_r32bit[31:0]};
					`LBU	: mem_r_data = {{(`XLEN-8){1'b0}}, mem_r8bit[7:0]};
					`LHU	: mem_r_data = {{(`XLEN-16){1'b0}}, mem_r16bit[15:0]};
					`LWU	: mem_r_data = {{(`XLEN-32){1'b0}}, mem_r32bit[31:0]};
					`LD		: mem_r_data = mem_rdata;
					default : mem_r_data = `XLEN'b0;
				endcase
			end
			
			reg [7:0] wmask;
			always @(*) begin
				case (funct3)
					`SB		: wmask = 8'b0000_0001 << mem_addr[2:0];
					`SH		: wmask = 8'b0000_0011 << mem_addr[2:0];
					`SW		: wmask = 8'b0000_1111 << mem_addr[2:0];
					`SD		: wmask = 8'b1111_1111;
					default : wmask = 8'b0;
				endcase
			end

		`else//ADDR_ALIGN
			
			wire [7:0] wmask = 8'b1 << funct3[1:0];

			always @(*) begin
				case (funct3)
					`LB		: mem_r_data = {{(`XLEN-8){mem_rdata[7]}}, mem_rdata[7:0]};
					`LH		: mem_r_data = {{(`XLEN-16){mem_rdata[15]}}, mem_rdata[15:0]};
					`LW		: mem_r_data = {{(`XLEN-32){mem_rdata[31]}}, mem_rdata[31:0]};
					`LBU	: mem_r_data = {{(`XLEN-8){1'b0}}, mem_rdata[7:0]};
					`LHU	: mem_r_data = {{(`XLEN-16){1'b0}}, mem_rdata[15:0]};
					`LWU	: mem_r_data = {{(`XLEN-32){1'b0}}, mem_rdata[31:0]};
					`LD		: mem_r_data = mem_rdata;
					default : mem_r_data = `XLEN'b0;
				endcase
			end
			
		`endif//ADDR_ALIGN

			/****************************************************************************************************************************************/
	`else	/****************************************************************************************************************************************/
			/****************************************************************************************************************************************/

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

			MuxKeyWithDefault #(7, 3, `XLEN) u_read_data (
				.out(mem_r_data),
				.key(funct3),
				.default_out(`XLEN'b0),
				.lut({
					`LB, 	{{(`XLEN-8){mem_r8bit[7]}}, mem_r8bit[7:0]},
					`LH,	{{(`XLEN-16){mem_r16bit[15]}}, mem_r16bit[15:0]},
					`LW,	{{(`XLEN-32){mem_r32bit[31]}}, mem_r32bit[31:0]},
					`LBU,	{{(`XLEN-8){1'b0}}, mem_r8bit[7:0]},
					`LHU,	{{(`XLEN-16){1'b0}}, mem_r16bit[15:0]},
					`LWU,	{{(`XLEN-32){1'b0}}, mem_r32bit[31:0]},
					`LD,	mem_rdata
				})
			);

			wire [7:0] wmask;
			MuxKeyWithDefault #(4, 3, 8) u_wmask (
				.out(wmask),
				.key(funct3),
				.default_out(8'b0),
				.lut({
					`SB, 8'b0000_0001 << mem_addr[2:0],
					`SH, 8'b0000_0011 << mem_addr[2:0],
					`SW, 8'b0000_1111 << mem_addr[2:0],
					`SD, 8'b1111_1111
				})
			);

		`else//ADDR_ALIGN

			wire [7:0] wmask = 8'b1 << funct3[1:0];

			MuxKeyWithDefault #(7, 3, `XLEN) u_read_data (
				.out(mem_r_data),
				.key(funct3),
				.default_out(`XLEN'b0),
				.lut({
					`LB, 	{{(`XLEN-8){mem_rdata[7]}}, mem_rdata[7:0]},
					`LH,	{{(`XLEN-16){mem_rdata[15]}}, mem_rdata[15:0]},
					`LW,	{{(`XLEN-32){mem_rdata[31]}}, mem_rdata[31:0]},
					`LBU,	{{(`XLEN-8){1'b0}}, mem_rdata[7:0]},
					`LHU,	{{(`XLEN-16){1'b0}}, mem_rdata[15:0]},
					`LWU,	{{(`XLEN-32){1'b0}}, mem_rdata[31:0]},
					`LD,	mem_rdata
				})
			);

		`endif//ADDR_ALIGN
	
	`endif //USE_IF_CASE

	`ifdef CLINT_ENABLE
			wire [`XLEN-1:0] mtime, mtimecmp;
			CLINT u_clint(
				.clk(clk),
				.rst(rst),
				.inst_store(inst_store),
				.mem_w_data(mem_w_data),
				.mem_addr(mem_addr),
				.msip(msip),
				.mtip(mtip),
				.mtime(mtime),
				.mtimecmp(mtimecmp)
			);
	`endif //CLINT_ENABLE

	`ifdef USE_AXI_IFU
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
	`endif

import "DPI-C" function void paddr_read(input longint raddr, output longint mem_r_data);
import "DPI-C" function void paddr_write(input longint waddr, input longint mem_w_data, input byte wmask);
	always_latch @(negedge clk) begin
		if (inst_load) begin
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
		if (inst_store) begin
			paddr_write(mem_addr, mem_w_data, wmask);
		end
	end

endmodule //lsu

`endif