/*************************************************************
 * @ name           : top.v
 * @ description    : Top
 * @ use module     : ifu, pcu, gpr, csr, idu, 
 * @ author         : K
 * @ chnge date     : 2023-3-10
*************************************************************/
`ifndef TOP_V
`define TOP_V

`include "common.v"

module top(
	input clk,
	input rst,
	output [`XLEN-1:0] pc,
	output [`XLEN-1:0] dnpc,
	output [31:0] inst
);

	wire pc_src1, pc_src2;
	wire inst_sys_jump, inst_jalr;
	wire [`XLEN-1:0] csr_r_data;
	wire [`XLEN-1:0] x_rs1, x_rs2, imm;
	reg [`XLEN-1:0] x_rd;

	`ifdef CLINT_ENABLE
		wire interrupt, msip, mtip;
		wire [`XLEN-1:0] csr_mtvec;
	`endif

	wire [4:0] rs1, rs2, rd;
	wire rd_w_en, mdu_en;
	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [1:0] rd_w_src, alu_src1, alu_src2;
	wire [4:0] alu_ctrl;//[4] = inst_32, [3] = alu_sub_sra, [2:0] = funct3
	wire csr_r_en, csr_w_en;
	wire [11:0] csr_addr;
	wire mem_r_en, mem_w_en;
	wire inst_sys, inst_sys_jump, inst_jalr, inst_32, inst_sys_ecall, inst_sys_mret, inst_sys_ebreak;
	wire [`XLEN-1:0] alu_result, mdu_result;
	wire smaller, equal;
	wire [`XLEN-1:0] mem_r_data;

	/********************* pcu *********************/
	pcu u_pcu (
		.clk(clk),
		.rst(rst),
    	.pc_src1(pc_src1),
		.pc_src2(pc_src2),
		.inst_sys_jump(inst_sys_jump),
		.inst_jalr(inst_jalr),
		.x_rs1(x_rs1),
		.imm(imm),
		.csr_r_data(csr_r_data),
		`ifdef CLINT_ENABLE
			.interrupt(interrupt),
			.csr_mtvec(csr_mtvec),
		`endif
		.pc(pc),
		.dnpc(dnpc)
	);

	/********************* ifu *********************/
	ifu u_ifu (
	  	.clk(clk),
	  	.rst(rst),
		.pc(pc),
		.inst(inst)
	);

	/********************* idu *********************/
	idu u_idu(
		.inst(inst),
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.imm(imm),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd)
	);

	/********************* csgu *********************/
	csgu u_csgu(
		.inst(inst),
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.rs1(rs1),
		.rd(rd),
		.rd_w_en(rd_w_en),
		.rd_w_src(rd_w_src),
		.alu_src1(alu_src1),
		.alu_src2(alu_src2),
		.alu_ctrl(alu_ctrl),
		.csr_r_en(csr_r_en),
		.csr_w_en(csr_w_en),
		.csr_addr(csr_addr),
		.mem_r_en(mem_r_en),
		.mem_w_en(mem_w_en),
		`ifdef EXTENSION_M
			.mdu_en(mdu_en),
		`endif
		.inst_sys(inst_sys),
		.inst_sys_jump(inst_sys_jump),
		.inst_sys_ecall(inst_sys_ecall),
		.inst_sys_mret(inst_sys_mret),
		.inst_sys_ebreak(inst_sys_ebreak),
		.inst_jalr(inst_jalr),
		.inst_32(inst_32)
	);

	/********************* gpr *********************/
	gpr u_gpr(
		.clk(clk),
		.rst(rst),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.rd_w_en(rd_w_en),
		.x_rd(x_rd),
		.x_rs1(x_rs1),
		.x_rs2(x_rs2)
	);
	
	/********************* csr *********************/
	csr u_csr(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.inst_sys_ecall(inst_sys_ecall),
		.inst_sys_ebreak(inst_sys_ebreak),
		.csr_r_en(csr_r_en),
		.csr_w_en(csr_w_en),
		.csr_addr(csr_addr),
		.csr_w_data(alu_result),
		`ifdef CLINT_ENABLE
			.msip(msip),
			.mtip(mtip),
			.interrupt(interrupt),
			.csr_mtvec(csr_mtvec),
		`endif
		.csr_r_data(csr_r_data)
	);

	/********************* exu *********************/
	exu u_exu (
		.funct3(funct3),
		.alu_src1(alu_src1),
		.alu_src2(alu_src2),
		.alu_ctrl(alu_ctrl),
		.rs1(rs1),
		.x_rs1(x_rs1),
		.x_rs2(x_rs2),
		.imm(imm),
		.pc(pc),
		.csr_r_data(csr_r_data),
		.alu_result(alu_result),
		.smaller(smaller),
		.equal(equal)
	);
	
	/********************* mdu *********************/
	`ifdef FAST_SIMULATION
		mdu_sim
	`else
		mdu
	`endif
		u_mdu(
			.en_mdu(mdu_en), 
			.x_rs1(x_rs1),
			.x_rs2(x_rs2),
			.funct3(funct3),
			.inst_32(inst_32),
			.mdu_result(mdu_result)
		);

	/********************* mau *********************/
	mau u_mau(
		.clk(clk),
		.rst(rst),
		.mem_r_en(mem_r_en),
		.mem_w_en(mem_w_en),
		.funct3(funct3),
		`ifdef CLINT_ENABLE
			.msip(msip),
			.mtip(mtip),
		`endif
		.mem_addr(alu_result),
		.mem_w_data(x_rs2),
		.mem_r_data(mem_r_data)
	);
	
	/********************* bcu *********************/
	bcu u_bcu(
		.opcode(opcode),
		.funct3(funct3),
		.smaller(smaller),
		.equal(equal),
    	.pc_src1(pc_src1),
		.pc_src2(pc_src2)
	);

	/********************* x_rd *********************/
	`ifdef USE_IF_CASE

		always @(*) begin
			case (rd_w_src)
				`RD_SRC_ALU: x_rd = alu_result;
				`RD_SRC_MEM: x_rd = mem_r_data;
				`RD_SRC_MDU: x_rd = mdu_result;
				`RD_SRC_CSR: x_rd = csr_r_data;
			endcase
		end

	`else

		MuxKeyWithDefault #(4, 2, `XLEN) u_x_rd (
			.out(x_rd),
			.key(rd_w_src),
			.default_out(`XLEN'b0),
			.lut({
				`RD_SRC_ALU,	alu_result,
				`RD_SRC_MEM,	mem_r_data,
				`RD_SRC_MDU,	mdu_result,
				`RD_SRC_CSR,	csr_r_data
			})
		);
	`endif

endmodule

`endif /* TOP_V */