`ifndef TOP_V
`define TOP_V

`define XLEN 64
`define DXLEN 128//double XLEN
`define HXLEN 32//half XLEN
`define START_ADDR `XLEN'h80000000
`define EXTENSION_M 1

module top(
	input clk,
	input rst,
	output [`XLEN-1:0] pc,
	output [`XLEN-1:0] dnpc,
	output [31:0] inst
);

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
		.pc(pc),
		.dnpc(dnpc));

	IFU u_ifu (
	  	.clk(clk),
	  	.rst(rst),
		.pc(pc),
		.inst(inst)
	);
	
endmodule

`endif /* TOP_V */