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
	input  [`XLEN-1:0] src1,
	input  [`XLEN-1:0] src2,
	input  [`XLEN-1:0] imm,
	output rd_wen,
	output [`XLEN-1:0] rd_data,

	output mem_r,
	output mem_w,
	output [`XLEN-1:0] mem_addr,
	input  [`XLEN-1:0] rdata, //ld_data
	output [`XLEN-1:0] wdata, //st_data

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
	localparam CSRRW	= 3'b001;
	localparam CSRRS	= 3'b010;
	localparam CSRRC	= 3'b011;
	localparam CSRRWI	= 3'b101;
	localparam CSRRSI	= 3'b110;
	localparam CSRRCI	= 3'b111;

	wire [`LEN_SEL-1:0] alu_sel;
	MuxKeyWithDefault #(11, 7, `LEN_SEL) i_alu_sel (
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
			//SYSTEM
			`OP_IMM_32,	funct3,  //x[rd] = sext(x[rs1] op imm);
			`OP_32,		funct3   //x[rd] = sext(x[rs1] op x[rs2]);
		})
	);

	wire [`XLEN-1:0] alu_a, alu_b;
	wire [`XLEN-1:0] alu_result;
	wire alu_sub_sra;
	MuxKeyWithDefault #(11, 7, `XLEN) i_alu_a (
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
			//SYSTEM
			`OP_IMM_32,	src1,
			`OP_32,		src1
		})
	);
	MuxKeyWithDefault #(11, 7, `XLEN) i_alu_b (
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
			`OP_IMM,	(funct3 != SLLI && funct3 != (SRAI & SRLI)) ? imm : {{(`XLEN-6){1'b0}}, imm[5:0]},
			`OP,		(funct3 != SLL && funct3 != (SRA & SRL)) ? src2 : {{(`XLEN-6){1'b0}}, src2[5:0]},
			//MISC_MEM
			//SYSTEM
			`OP_IMM_32,	(funct3 != SLLIW && funct3 != (SRAIW & SRLIW)) ? imm : {{(`XLEN-5){1'b0}}, imm[4:0]},
			`OP_32,		(funct3 != SLLW && funct3 != (SRAW & SRLW)) ? src2 : {{(`XLEN-5){1'b0}}, src2[4:0]}
		})
	);
	MuxKeyWithDefault #(11, 7, 1) i_alu_sub_sra (
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
			`OP_IMM,	funct3 == (SRAI | SRLI) ? inst[30] : 1'b0,
			`OP,		inst[30],
			//MISC_MEM
			//SYSTEM
			`OP_IMM_32,	funct3 == (SRAIW | SRLIW) ? inst[30] : 1'b0,
			`OP_32,		inst[30]
		})
	);
	wire alu_cout, alu_zero, alu_smaller, alu_overflow, alu_equal;
	ALU i_alu (
		.sel(alu_sel),
		.a(alu_a),
		.b(alu_b),
		.sub_sra(alu_sub_sra),
		.result(alu_result),
		.cout(alu_cout),
		.zero(alu_zero),
		.overflow(alu_overflow),
		.smaller(alu_smaller),
		.equal(alu_equal)
	);

	wire [`XLEN-1:0] dnpc_base, dnpc_offs, dnpc_sum;
	assign dnpc_sum = dnpc_base + dnpc_offs;
	assign dnpc = opcode != `JALR ? dnpc_sum : {dnpc_sum[`XLEN-1:1], 1'b0};
	wire branch_con;//branch condition is true or false
	MuxKeyWithDefault #(11, 7, `XLEN) i_dnpc_base (
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
			//SYSTEM
			`OP_IMM_32,	pc,
			`OP_32,		pc
		})
	);
	MuxKeyWithDefault #(11, 7, `XLEN) i_dnpc_offs (
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
			//SYSTEM
			`OP_IMM_32,	`XLEN'd4,
			`OP_32,		`XLEN'd4
		})
	);
	MuxKeyWithDefault #(6, 3, 1) i_branch_con (
		.out(branch_con),
		.key(funct3),
		.default_out(1'b0),
		.lut({
			BEQ	, alu_equal,
			BNE	, ~alu_equal,
			BLT	, alu_smaller,
			BGE	, ~alu_smaller,
			BLTU, alu_cout,	//result: -255 to 255
			BGEU, ~alu_cout //result: -255 to 255
		})
	);

	assign mem_w = opcode == `STORE;
	assign mem_r = opcode == `LOAD;
	assign wdata = mem_w ? src2 : `XLEN'b0;
	assign mem_addr = mem_w || mem_r ? alu_result : `XLEN'b0;
	wire [`XLEN-1:0] ld_data;
	MuxKeyWithDefault #(7, 3, `XLEN) i_ld_data (
		.out(ld_data),
		.key(funct3),
		.default_out(`XLEN'b0),
		.lut({
			LB, {{(`XLEN-8){rdata[7]}}, rdata[7:0]},
			LH,	{{(`XLEN-16){rdata[15]}}, rdata[15:0]},
			LW,	{{(`XLEN-32){rdata[31]}}, rdata[31:0]},
			LBU,{{(`XLEN-8){1'b0}}, rdata[7:0]},
			LHU,{{(`XLEN-16){1'b0}}, rdata[15:0]},
			LWU,{{(`XLEN-32){1'b0}}, rdata[31:0]},
			LD,	{{(`XLEN-64){rdata[63]}}, rdata[63:0]}
		})
	);

	MuxKeyWithDefault #(11, 7, 1) i_rd_wen (
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
			//SYSTEM
			`OP_IMM_32,	1'b1,
			`OP_32,		1'b1
		})
	);
	MuxKeyWithDefault #(11, 7, `XLEN) i_rd_data (
		.out(rd_data),
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
			`OP,		alu_result,
			//MISC_MEM
			//SYSTEM
			`OP_IMM_32,	alu_result,
			`OP_32,		alu_result
		})
	);

endmodule //EXU

`endif /* EXU_V */