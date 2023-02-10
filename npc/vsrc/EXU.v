//EXecution Unit

`ifndef EXU_V
`define EXU_V

`include "top.v"
`include "ALU.v"
`include "IDU.v"

module EXU (
	input  clk,
	input  rst,

	input  [31:0] inst,
	input  [6:0] opcode,
	input  [2:0] funct3,
	input  [6:0] funct7,
	input  [4:0] rs1,
	input  [4:0] rs2,
	output [4:0] rd,
	input  [`XLEN-1:0] src1,
	input  [`XLEN-1:0] src2,
	input  [`XLEN-1:0] imm,
	output rd_wen,
	output [`XLEN-1:0] x_rd,

	input  [`XLEN-1:0] pc,
	output [`XLEN-1:0] dnpc
);
	//BRANCH
	localparam BEQ		= 3'b000;
	localparam BNE		= 3'b001;
	localparam BLT		= 3'b100;
	localparam BGE		= 3'b101;
	localparam BLTU		= 3'b110;
	localparam BGEU		= 3'b111;
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
	//OP-IMM
	localparam ADDI		= 3'b000;
	localparam SLTI		= 3'b010;
	localparam SLTIU	= 3'b011;
	localparam XORI		= 3'b100;
	localparam ORI		= 3'b110;
	localparam ANDI		= 3'b111;
	localparam SLLI		= 3'b001;
	localparam SRLI		= 3'b101;//same0
	localparam SRAI		= 3'b101;//same0
	//OP_IMM_32
	localparam ADDIW	= 3'b000;
	localparam SLLIW	= 3'b001;
	localparam SRLIW	= 3'b101;//same1
	localparam SRAIW	= 3'b101;//same1
	//OP_32
	localparam ADDW		= 3'b000;//same2
	localparam SUBW		= 3'b000;//same2
	localparam SLLW		= 3'b001;
	localparam SRLW		= 3'b101;//same3
	localparam SRAW		= 3'b101;//same3
	//OP
	localparam ADD		= 3'b000;//same4
	localparam SUB		= 3'b000;//same4
	localparam SLL		= 3'b001;
	localparam SLT		= 3'b010;
	localparam SLTU		= 3'b011;
	localparam XOR		= 3'b100;
	localparam SRL		= 3'b101;//same5
	localparam SRA		= 3'b101;//same5
	localparam OR		= 3'b110;
	localparam AND		= 3'b111;
	//MISC-MEM
	localparam FENCE	= 3'b000;
	localparam FENCEI	= 3'b001;
	//SYSTEM
	localparam ECALL	= 3'b000;
	localparam EBREAK	= 3'b000;
	localparam MRET		= 3'b000;
	localparam CSRRW	= 3'b001;
	localparam CSRRS	= 3'b010;
	localparam CSRRC	= 3'b011;
	localparam CSRRWI	= 3'b101;
	localparam CSRRSI	= 3'b110;
	localparam CSRRCI	= 3'b111;
	localparam ebreak = 32'b00000000000100000000000001110011;
	localparam ecall  = 32'b00000000000000000000000001110011;
	localparam mret   = 32'b00110000001000000000000001110011;

`ifdef EXTENSION_M
	//OP
	localparam MUL		= 3'b000;
	localparam MULH		= 3'b001;
	localparam MULHSU	= 3'b010;
	localparam MULHU	= 3'b011;
	localparam DIV		= 3'b100;
	localparam DIVU		= 3'b101;
	localparam REM		= 3'b110;
	localparam REMU		= 3'b111;
	//OP_32
	localparam MULW		= 3'b000;
	localparam DIVW		= 3'b100;
	localparam DIVUW	= 3'b101;
	localparam REMW		= 3'b110;
	localparam REMUW	= 3'b111;

	localparam funct7_md = 7'b0000001;

`endif

	wire [`LEN_SEL-1:0] alu_sel;
	MuxKeyWithDefault #(12, 7, `LEN_SEL) u_alu_sel (
		.out(alu_sel),
		.key(opcode),
		.default_out(`SEL_AOS),
		.lut({
			`LUI,		`SEL_AOS,//x[rd] = imm
			`AUIPC,		`SEL_AOS,//x[rd] = pc + imm;
			`JAL,		`SEL_AOS,//x[rd] = pc + 4; pc += imm;
			`JALR,		`SEL_AOS,//x[rd] = pc + 4; pc = (x[rs1] + imm) & ~1;
			`BRANCH,	`SEL_AOS,//xxx = x[rs1]-x[rs2]; if(xxx) pc += imm;
			`LOAD,		`SEL_AOS,//x[rd] = M[x[rs1] + imm]
			`STORE,		`SEL_AOS,//M[x[rs1] + imm] = x[rs2]
			`OP_IMM,	funct3,  //x[rd] = x[rs1] op imm;
			`OP,		funct3,  //x[rd] = x[rs1] op x[rs2];
			//MISC_MEM
			`SYSTEM,	csr_alu_sel,//csr |= rs1, csr &= rs1
			`OP_IMM_32,	funct3,  //x[rd] = sext(x[rs1] op imm);
			`OP_32,		funct3   //x[rd] = sext(x[rs1] op x[rs2]);
		})
	);

	wire [`XLEN-1:0] alu_a, alu_b;
	wire [`XLEN-1:0] alu_result;
	wire alu_sub_sra;
	MuxKeyWithDefault #(12, 7, `XLEN) u_alu_a (
		.out(alu_a),
		.key(opcode),
		.default_out(`XLEN'b0),
		.lut({
			`LUI,		`XLEN'b0,
			`AUIPC,		pc,
			`JAL,		pc,
			`JALR,		pc,
			`BRANCH,	src1,
			`LOAD,		src1,
			`STORE,		src1,
			`OP_IMM,	src1,
			`OP,		src1,
			//MISC_MEM
			`SYSTEM,	csr_alu_a,// I ? imm : x[rs1]
			`OP_IMM_32,	{`HXLEN'b0, src1[`HXLEN-1:0]},
			`OP_32,		{`HXLEN'b0, src1[`HXLEN-1:0]}
		})
	);
	MuxKeyWithDefault #(12, 7, `XLEN) u_alu_b (
		.out(alu_b),
		.key(opcode),
		.default_out(`XLEN'b0),
		.lut({
			`LUI,		`XLEN'b0,
			`AUIPC,		imm,
			`JAL,		`XLEN'd4,
			`JALR,		`XLEN'd4,
			`BRANCH,	src2,
			`LOAD,		imm,
			`STORE,		imm,
			`OP_IMM,	imm,
			`OP,		src2,
			//MISC_MEM
			`SYSTEM,	csr_alu_b,
			`OP_IMM_32,	{`HXLEN'b0, imm[`HXLEN-1:0]},
			`OP_32,		{`HXLEN'b0, src2[`HXLEN-1:0]}
		})
	);
	MuxKeyWithDefault #(12, 7, 1) u_alu_sub_sra (
		.out(alu_sub_sra),
		.key(opcode),
		.default_out(1'b0),
		.lut({
			`LUI,		1'b0,
			`AUIPC,		1'b0,
			`JAL,		1'b0,
			`JALR,		1'b0,
			`BRANCH,	1'b1,
			`LOAD,		1'b0,
			`STORE,		1'b0,
			`OP_IMM,	funct3 == (SRAI | SRLI) ? funct7[5] : 1'b0,
			`OP,		funct7[5],
			//MISC_MEM
			`SYSTEM,	1'b0,
			`OP_IMM_32,	funct3 == (SRAIW | SRLIW) ? funct7[5] : 1'b0,
			`OP_32,		funct7[5]
		})
	);
	wire alu_cout, alu_zero, alu_smaller_s, alu_smaller_u, alu_overflow, alu_equal;
	wire is_op_x_32 = (opcode == `OP_32) || (opcode == `OP_IMM_32);
	ALU u_alu (
		.sel(alu_sel),
		.a(alu_a),
		.b(alu_b),
		.sub_sra(alu_sub_sra),
		.is_op_x_32(is_op_x_32),
		.result(alu_result),
		.cout(alu_cout),
		.zero(alu_zero),
		.overflow(alu_overflow),
		.smaller_s(alu_smaller_s),
		.smaller_u(alu_smaller_u),
		.equal(alu_equal)
	);

	wire [`XLEN-1:0] dnpc_base, dnpc_offs, dnpc_sum;
	assign dnpc_sum = dnpc_base + dnpc_offs;
	assign dnpc = interrupt ? csr_mtvec : (opcode != `JALR) ? dnpc_sum : {dnpc_sum[`XLEN-1:1], 1'b0};
	wire branch_con;//branch condition is true or false
	MuxKeyWithDefault #(12, 7, `XLEN) u_dnpc_base (
		.out(dnpc_base),
		.key(opcode),
		.default_out(pc),
		.lut({
			`LUI,		pc,
			`AUIPC,		pc,
			`JAL,		pc,
			`JALR,		src1,
			`BRANCH,	pc,
			`LOAD,		pc,
			`STORE,		pc,
			`OP_IMM,	pc,
			`OP,		pc,
			//MISC_MEM
			`SYSTEM,	sys_dnpc_base,//ecall, mret
			`OP_IMM_32,	pc,
			`OP_32,		pc
		})
	);
	MuxKeyWithDefault #(12, 7, `XLEN) u_dnpc_offs (
		.out(dnpc_offs),
		.key(opcode),
		.default_out(`XLEN'd4),
		.lut({
			`LUI,		`XLEN'd4,
			`AUIPC,		`XLEN'd4,
			`JAL,		imm,//pc += imm;
			`JALR,		imm,//pc = (x[rs1] + imm) & ~1;
			`BRANCH,	branch_con ? imm : `XLEN'd4,//if(xxx) pc += imm;
			`LOAD,		`XLEN'd4,
			`STORE,		`XLEN'd4,
			`OP_IMM,	`XLEN'd4,
			`OP,		`XLEN'd4,
			//MISC_MEM
			`SYSTEM,	 sys_dnpc_offs,//ecall, mret
			`OP_IMM_32,	`XLEN'd4,
			`OP_32,		`XLEN'd4
		})
	);
	MuxKeyWithDefault #(6, 3, 1) u_branch_con (
		.out(branch_con),
		.key(funct3),
		.default_out(1'b0),
		.lut({
			BEQ	, alu_equal,
			BNE	, ~alu_equal,
			BLT	, alu_smaller_s,
			BGE	, ~alu_smaller_s,
			BLTU, alu_smaller_u,	//result: -255 to 255
			BGEU, ~alu_smaller_u 	//result: -255 to 255
		})
	);

	wire [`XLEN-1:0] ld_data;
    wire msip, mtip;
	MAU u_mau(
		.clk(clk),
		.rst(rst),
		.funct3(funct3),
		.opcode(opcode),
		.src2(src2),
		.alu_result(alu_result),
		.ld_data(ld_data),
		.msip(msip),
		.mtip(mtip)
	);

	MuxKeyWithDefault #(12, 7, 1) u_rd_wen (
		.out(rd_wen),
		.key(opcode),
		.default_out(1'b0),
		.lut({
			`LUI,		1'b1,
			`AUIPC,		1'b1,
			`JAL,		1'b1,
			`JALR,		1'b1,
			`BRANCH,	1'b0,
			`LOAD,		1'b1,
			`STORE,		1'b0,
			`OP_IMM,	1'b1,
			`OP,		1'b1,
			//MISC_MEM
			`SYSTEM,	inst_is_x == 3'b000 ? csr_rd_en : 1'b0,// except ecall, ebreak, mret
			`OP_IMM_32,	1'b1,
			`OP_32,		1'b1
		})
	);
	MuxKeyWithDefault #(12, 7, `XLEN) u_rd_data (
		.out(x_rd),
		.key(opcode),
		.default_out(`XLEN'b0),
		.lut({
			`LUI,		imm,
			`AUIPC,		alu_result,
			`JAL,		alu_result,
			`JALR,		alu_result,
			`BRANCH,	`XLEN'b0,
			`LOAD,		ld_data,
			`STORE,		`XLEN'b0,
			`OP_IMM,	alu_result,
			`OP,		op_result,
			//MISC_MEM
			`SYSTEM,	csr,
			`OP_IMM_32,	{{(`XLEN-32){alu_result[31]}}, alu_result[31:0]},
			`OP_32,		{{(`XLEN-32){op_32_result[31]}}, op_32_result[31:0]}
		})
	);

	wire [`XLEN-1:0] csr, csr_mtvec;
	wire op_is_system = opcode == `SYSTEM ? 1'b1 : 1'b0;
	wire inst_is_ebreak = inst == ebreak ? 1'b1 : 1'b0;
	wire inst_is_ecall = inst == ecall ? 1'b1 : 1'b0;
	wire inst_is_mret = inst == mret ? 1'b1 : 1'b0;
	wire [2:0] inst_is_x = {inst_is_mret, inst_is_ecall, inst_is_ebreak};	//001: ebreak, 010: ecall, 100: mret
	wire interrupt;
	CSR u_csr(
		.clk(clk),
		.rst(rst),
		.inst_is_x(inst_is_x),
		.pc(pc),
		.rd_en(csr_rd_en & op_is_system), 
		.wt_en(csr_wt_en & op_is_system),
		.csr_idx(csr_idx),
		.source(alu_result),
		.msip(msip),
		.mtip(mtip),
		.interrupt(interrupt),
		.csr(csr),
		.csr_mtvec(csr_mtvec)
	);

	wire [`LEN_SEL-1:0] csr_alu_sel;
	wire [`XLEN-1:0] csr_alu_a, csr_alu_b;
	MuxKeyWithDefault #(6, 3, `LEN_SEL) u_csr_alu_sel (
		.out(csr_alu_sel),
		.key(funct3),
		.default_out(`SEL_AOS),
		.lut({
			//ECALL | EBREAK | MRET
			CSRRW	,	`SEL_AOS,
			CSRRS	,	OR,
			CSRRC	,	AND,
			CSRRWI	,	`SEL_AOS,
			CSRRSI	,	OR,
			CSRRCI	,	AND
		})
	);
	MuxKeyWithDefault #(6, 3, `XLEN) u_csr_alu_a (
		.out(csr_alu_a),
		.key(funct3),
		.default_out(`XLEN'b0),
		.lut({
			//ECALL | EBREAK | MRET
			CSRRW	,	src1,
			CSRRS	,	src1,
			CSRRC	,	~src1,
			CSRRWI	,	{{(`XLEN-5){1'b0}}, rs1},
			CSRRSI	,	{{(`XLEN-5){1'b0}}, rs1},
			CSRRCI	,	~{{(`XLEN-5){1'b0}}, rs1}
		})
	);
	MuxKeyWithDefault #(6, 3, `XLEN) u_csr_alu_b (
		.out(csr_alu_b),
		.key(funct3),
		.default_out(`XLEN'b0),
		.lut({
			//ECALL | EBREAK | MRET
			CSRRW	,	`XLEN'b0,
			CSRRS	,	csr,
			CSRRC	,	csr,
			CSRRWI	,	`XLEN'b0,
			CSRRSI	,	csr,
			CSRRCI	,	csr
		})
	);

	wire csr_rd_en, csr_wt_en;
	MuxKeyWithDefault #(7, 3, 1) u_csr_rd_en (
		.out(csr_rd_en),
		.key(funct3),
		.default_out(1'b0),
		.lut({
			ECALL | EBREAK | MRET	,	1'b1,
			CSRRW					,	rd == 5'd0 ? 1'b0 : 1'b1,
			CSRRS					,	1'b1,
			CSRRC					,	1'b1,
			CSRRWI					,	rd == 5'd0 ? 1'b0 : 1'b1,
			CSRRSI					,	1'b1,
			CSRRCI					,	1'b1
		})
	);
	MuxKeyWithDefault #(6, 3, 1) u_csr_wt_en (
		.out(csr_wt_en),
		.key(funct3),
		.default_out(1'b0),
		.lut({
			//ECALL | EBREAK | MRET
			CSRRW	,	1'b1,
			CSRRS	,	rs1 == 5'd0 ? 1'b0 : 1'b1,
			CSRRC	,	rs1 == 5'd0 ? 1'b0 : 1'b1,
			CSRRWI	,	1'b1,
			CSRRSI	,	rs1 == 5'd0 ? 1'b0 : 1'b1,
			CSRRCI	,	rs1 == 5'd0 ? 1'b0 : 1'b1
		})
	);
	
	wire [11:0] csr_idx;
	localparam addr_mtvec		= 12'h305;
	localparam addr_mepc		= 12'h341;
	MuxKeyWithDefault #(2, 3, 12) u_csr_idx (
		.out(csr_idx),
		.key(inst_is_x),
		.default_out(imm[11:0]),
		.lut({
			//3'b001, addr_mtvec, //ebreak: dnpc = csr[mtvec]
			3'b010, addr_mtvec,	//ecall:dnpc = csr[mtvec]
			3'b100, addr_mepc	//mret: dnpc = csr[mepc]
		})
	);
	wire [`XLEN-1:0] sys_dnpc_base, sys_dnpc_offs;
	MuxKeyWithDefault #(2, 3, `XLEN) u_sys_dnpc_base (
		.out(sys_dnpc_base),
		.key(inst_is_x),
		.default_out(pc),
		.lut({
			//3'b001, csr,	//ebreak: dnpc = pc + 4
			3'b010, csr,//ecall:dnpc = csr[mtvec]
			3'b100, csr	//mret: dnpc = csr[mepc]
		})
	);
	MuxKeyWithDefault #(2, 3, `XLEN) u_sys_dnpc_offs (
		.out(sys_dnpc_offs),
		.key(inst_is_x),
		.default_out(`XLEN'd4),
		.lut({
			//3'b001, `XLEN'd0,	//ebreak: dnpc = pc + 4
			3'b010, `XLEN'd0,	//ecall:dnpc = csr[mtvec]
			3'b100, `XLEN'd0	//mret: dnpc = csr[mepc]
		})
	);

import "DPI-C" function void stopCPU();
	always @(*) begin
		if(inst_is_ebreak) begin
			stopCPU();
		end
	end

	wire [`XLEN-1:0] op_result, op_32_result;
`ifdef EXTENSION_M
	wire [`XLEN-1:0] mdu_x_rd;
	MDU u_mdu(
			.src1(src1),
			.src2(src2),
			.funct3(funct3),
			.opcode_is_w(opcode[3]),
			.x_rd(mdu_x_rd));

    wire en_mdu = (opcode == `OP | opcode == `OP_32) && (funct7 == funct7_md);
	assign op_result = en_mdu ? mdu_x_rd : alu_result;
	assign op_32_result = en_mdu ? mdu_x_rd : alu_result;
`else
	assign op_result = alu_result;
	assign op_32_result = alu_result;
`endif

endmodule //EXU

`endif /* EXU_V */