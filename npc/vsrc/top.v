`ifndef TOP_V
`define TOP_V

`define XLEN 64
`define START_ADDR `XLEN'h80000000

module top(
	input clk,
	input rst,
	input  [31:0] inst,
	output mem_r,
	output mem_w,
	output [1:0] mem_dlen,
	//inout  [`XLEN-1:0] mem_data,
	input  [`XLEN-1:0] mem_rdata,
	output [`XLEN-1:0] mem_wdata,
	output [`XLEN-1:0] mem_addr,
	output [`XLEN-1:0] pc,
	output [`XLEN-1:0] dnpc
);
	//wire [`XLEN-1:0] mem_rdata, mem_wdata;
	//assign mem_rdata = (mem_r) ? mem_data : `XLEN'b0;
	//assign mem_data = (mem_w) ? mem_wdata : `XLEN'bZ;
	assign mem_dlen = funct3[1:0];

	wire [4:0] rs1, rs2, rd;
	wire rd_wen;
	wire [`XLEN-1:0] x_rd, x_rs1, x_rs2;
	//wire [`XLEN-1:0] dnpc;
	GIR u_gir(
	  .clk(clk),
	  .rst(rst),
	  .rs1(rs1),
	  .rs2(rs2),
	  .rd(rd),
	  .rd_wen(rd_wen),
	  .x_rd(x_rd),
	  .x_rs1(x_rs1),
	  .x_rs2(x_rs2),
	  .dnpc(dnpc),
	  .pc(pc)
	);

	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [`XLEN-1:0] src1, src2, imm;
	IDU u_idu(
		.clk(clk),
		.rst(rst),
		.inst(inst),
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.src1(src1),
		.src2(src2),
		.imm(imm),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.x_rs1(x_rs1),
		.x_rs2(x_rs2)
	);


	EXU u_exu (
		.clk(clk),
		.rst(rst),
		.inst(inst),
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.src1(src1),
		.src2(src2),
		.imm(imm),
		.rd_wen(rd_wen),
		.x_rd(x_rd),
		.mem_r(mem_r),
		.mem_w(mem_w),
		.mem_addr(mem_addr),
		.mem_rdata(mem_rdata), //ld_data
		.mem_wdata(mem_wdata), //st_data
		.pc(pc),
		.dnpc(dnpc)
);
	
endmodule

`endif /* TOP_V */