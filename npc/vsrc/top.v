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
	output [2:0] mem_dlen,
	inout  [`XLEN-1:0] mem_data,
	output [`XLEN-1:0] mem_addr,
	output [`XLEN-1:0] pc
);
	wire [`XLEN-1:0] rdata, wdata;
	assign rdata = (mem_r) ? mem_data : `XLEN'b0;
	assign mem_data = (mem_w) ? wdata : `XLEN'bZ;
	assign mem_dlen = funct3;

	wire [4:0] rd1_index, rd2_index, wt_index;
	wire wen;
	wire [`XLEN-1:0] wt_data, rdata1, rdata2;
	wire [`XLEN-1:0] dnpc;
	GIR i_gir(
	  .clk(clk),
	  .rst(rst),
	  .rd1_index(rd1_index),
	  .rd2_index(rd2_index),
	  .wt_index(wt_index),
	  .wen(wen),
	  .wdata(wt_data),
	  .rdata1(rdata1),
	  .rdata2(rdata2),
	  .dnpc(dnpc),
	  .pc(pc)
	);

	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [`XLEN-1:0] src1, src2, imm;
	wire [4:0] rs1, rs2, rd;
	IDU i_idu(
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
		.rdata1(rdata1),
		.rdata2(rdata2)
	);


	EXU i_exu (
		.clk(clk),
		.rst(rst),
		.inst(inst),
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.src1(src1),
		.src2(src2),
		.imm(imm),
		.rd_wen(wen),
		.rd_data(wt_data),
		.mem_r(mem_r),
		.mem_w(mem_w),
		.mem_addr(mem_addr),
		.rdata(rdata), //ld_data
		.wdata(wdata), //st_data
		.pc(pc),
		.dnpc(dnpc)
);
	
endmodule

`endif /* TOP_V */