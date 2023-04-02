/*************************************************************
 * @ name           : csgu.v
 * @ description    : CSGo(×) Control Signal Generating Unit(√)
 * @ use module     : MuxKeyWithDefault
 * @ author         : K
 * @ chnge date     : 2023-3-10
*************************************************************/
`ifndef CSGU_V
`define CSGU_V

`include "common.v"

module csgu (
	input  [31:0] 		inst,
	input  [6:0] 		opcode,
	input  [2:0] 		funct3,
	input  [6:0] 		funct7,
	input  [4:0] 		rs1,
	input  [4:0] 		rd,
	`ifdef USE_IF_CASE
		output reg 			rd_w_en,
		output reg [1:0] 	rd_w_src,
		output reg [1:0] 	alu_src1,
		output reg [1:0] 	alu_src2,
		output reg [4:0] 	alu_ctrl,//[4] = inst_32, [3] = alu_sub_sra, [2:0] = funct3
	`else
		output 				rd_w_en,
		output [1:0] 		rd_w_src,
		output [1:0] 		alu_src1,
		output [1:0] 		alu_src2,
		output [4:0] 		alu_ctrl,//[4] = inst_32, [3] = alu_sub_sra, [2:0] = funct3
	`endif
	output 				csr_r_en,
	output 				csr_w_en,
	output [11:0] 		csr_addr, 
	output 				inst_load,
	output 				inst_store,
	`ifdef EXTENSION_M
		output 			mdu_en,
	`endif
	output 				inst_sys,
	output 				inst_sys_jump,
	output 				inst_sys_ecall,
	output 				inst_sys_mret,
	output 				inst_sys_ebreak,
	output 				inst_jalr,
	output 				inst_32
);

	localparam FUNCT7_MD = 7'b0000001;

	assign alu_ctrl[4:3] = {inst_32, alu_sub_sra};
	assign inst_32 = (opcode == `OP_IMM_32 ) || (opcode == `OP_32);
	assign inst_jalr = (opcode == `JALR );
	assign inst_sys = (opcode == `SYSTEM);//ecall, ebreak, mret
	assign inst_sys_jump = inst_sys && (funct3 == (`MRET | `ECALL | `EBREAK));//ecall, ebreak, mret
	assign inst_sys_ecall = inst_sys_jump && (inst == `INST_ECALL);
	assign inst_sys_mret = inst_sys_jump && (inst == `INST_MRET);
	assign inst_sys_ebreak = inst_sys_jump && (inst == `INST_EBREAK);
	assign inst_load = (opcode == `LOAD);
	assign inst_store = (opcode == `STORE);
	assign csr_r_en = inst_sys & csr_rd_en;
	assign csr_w_en = inst_sys & csr_wt_en;
	
	`ifdef EXTENSION_M
		assign mdu_en = ((opcode == `OP ) || (opcode == `OP_32)) && (funct7 == FUNCT7_MD);
	`endif

	`ifdef USE_IF_CASE

		reg alu_sub_sra;//0: ADD,SRL		1: SUB,SRA
		reg csr_rd_en, csr_wt_en;
		reg [2:0] csr_alu_ctrl;
		reg [2:0] branch_alu_ctrl;

		always @(*) begin
			case (opcode)
				`LUI		: rd_w_en = 1'b1;
				`AUIPC		: rd_w_en = 1'b1;
				`JAL		: rd_w_en = 1'b1;
				`JALR		: rd_w_en = 1'b1;
				`BRANCH		: rd_w_en = 1'b0;
				`LOAD		: rd_w_en = 1'b1;
				`STORE		: rd_w_en = 1'b0;
				`OP_IMM		: rd_w_en = 1'b1;
				`OP			: rd_w_en = 1'b1;
				//MISC_MEM
				`SYSTEM		: rd_w_en = inst_sys_jump ? 1'b0 : 1'b1;// if(inst == ecall | ebreak | mret) rd_w_en = 0;
				`OP_IMM_32	: rd_w_en = 1'b1;
				`OP_32		: rd_w_en = 1'b1;
				default		: rd_w_en = 1'b0;
			endcase
		end

		always @(*) begin
			case (opcode)
				`LUI		: rd_w_src = `RD_SRC_ALU;
				`AUIPC		: rd_w_src = `RD_SRC_ALU;
				`JAL		: rd_w_src = `RD_SRC_ALU;
				`JALR		: rd_w_src = `RD_SRC_ALU;
				`BRANCH		: rd_w_src = 2'b0;
				`LOAD		: rd_w_src = `RD_SRC_MEM;
				`STORE		: rd_w_src = 2'b0;
				`OP_IMM		: rd_w_src = `RD_SRC_ALU;
				//MISC_MEM
				`SYSTEM		: rd_w_src = `RD_SRC_CSR;
				`OP_IMM_32	: rd_w_src = `RD_SRC_ALU;
				`ifdef EXTENSION_M
					`OP		: rd_w_src = mdu_en ? `RD_SRC_MDU : `RD_SRC_ALU;
					`OP_32	: rd_w_src = mdu_en ? `RD_SRC_MDU : `RD_SRC_ALU;
				`else
					`OP		: rd_w_src = `RD_SRC_ALU;
					`OP_32	: rd_w_src = `RD_SRC_ALU;
				`endif
				default		: rd_w_src = 2'b0;
			endcase
		end

		always @(*) begin
			case (opcode)
				`LUI		: alu_src1 = `ALU_SRC1_0;
				`AUIPC		: alu_src1 = `ALU_SRC1_PC;
				`JAL		: alu_src1 = `ALU_SRC1_PC;
				`JALR		: alu_src1 = `ALU_SRC1_PC;
				`BRANCH		: alu_src1 = `ALU_SRC1_XRS1;
				`LOAD		: alu_src1 = `ALU_SRC1_XRS1;
				`STORE		: alu_src1 = `ALU_SRC1_XRS1;
				`OP_IMM		: alu_src1 = `ALU_SRC1_XRS1;
				`OP			: alu_src1 = `ALU_SRC1_XRS1;
				//MISC_MEM
				`SYSTEM		: alu_src1 = `ALU_SRC1_CSR;
				`OP_IMM_32	: alu_src1 = `ALU_SRC1_XRS1;
				`OP_32		: alu_src1 = `ALU_SRC1_XRS1;
				default		: alu_src1 = `ALU_SRC1_0;
			endcase
		end

		always @(*) begin
			case (opcode)
				`LUI		: alu_src2 = `ALU_SRC2_IMM;
				`AUIPC		: alu_src2 = `ALU_SRC2_IMM;
				`JAL		: alu_src2 = `ALU_SRC2_4;
				`JALR		: alu_src2 = `ALU_SRC2_4;
				`BRANCH		: alu_src2 = `ALU_SRC2_XRS2;
				`LOAD		: alu_src2 = `ALU_SRC2_IMM;
				`STORE		: alu_src2 = `ALU_SRC2_IMM;
				`OP_IMM		: alu_src2 = `ALU_SRC2_IMM;
				`OP			: alu_src2 = `ALU_SRC2_XRS2;
				//MISC_MEM
				`SYSTEM		: alu_src2 = `ALU_SRC2_CSR;
				`OP_IMM_32	: alu_src2 = `ALU_SRC2_IMM;
				`OP_32		: alu_src2 = `ALU_SRC2_XRS2;
				default		: alu_src2 = `ALU_SRC2_4;
			endcase
		end

		always @(*) begin
			case (opcode)
				`LUI		: alu_ctrl[2:0] = `ALU_CTRL_AOS;//x[rd] = imm
				`AUIPC		: alu_ctrl[2:0] = `ALU_CTRL_AOS;//x[rd] = pc + imm;
				`JAL		: alu_ctrl[2:0] = `ALU_CTRL_AOS;//x[rd] = pc + 4; pc += imm;
				`JALR		: alu_ctrl[2:0] = `ALU_CTRL_AOS;//x[rd] = pc + 4; pc = (x[rs1] + imm) & ~1;
				`BRANCH		: alu_ctrl[2:0] = branch_alu_ctrl;//xxx = x[rs1]-x[rs2]; if(xxx) pc += imm;
				`LOAD		: alu_ctrl[2:0] = `ALU_CTRL_AOS;//x[rd] = M[x[rs1] + imm]
				`STORE		: alu_ctrl[2:0] = `ALU_CTRL_AOS;//M[x[rs1] + imm] = x[rs2]
				`OP_IMM		: alu_ctrl[2:0] = funct3;  //x[rd] = x[rs1] op imm;
				`OP			: alu_ctrl[2:0] = funct3;  //x[rd] = x[rs1] op x[rs2];
				//MISC_MEM
				`SYSTEM		: alu_ctrl[2:0] = csr_alu_ctrl;//csr |= rs1, csr &= rs1
				`OP_IMM_32	: alu_ctrl[2:0] = funct3;  //x[rd] = sext(x[rs1] op imm);
				`OP_32		: alu_ctrl[2:0] = funct3;  //x[rd] = sext(x[rs1] op x[rs2]);
				default		: alu_ctrl[2:0] = `ALU_CTRL_AOS;
			endcase
		end

		always @(*) begin
			case (opcode)
				`LUI		: alu_sub_sra = 1'b0;
				`AUIPC		: alu_sub_sra = 1'b0;
				`JAL		: alu_sub_sra = 1'b0;
				`JALR		: alu_sub_sra = 1'b0;
				`BRANCH		: alu_sub_sra = 1'b1;
				`LOAD		: alu_sub_sra = 1'b0;
				`STORE		: alu_sub_sra = 1'b0;
				`OP_IMM		: alu_sub_sra = funct3 == (`SRAI | `SRLI) ? funct7[5] : 1'b0;
				`OP			: alu_sub_sra = funct7[5];
				//MISC_MEM
				`SYSTEM		: alu_sub_sra = 1'b0;
				`OP_IMM_32	: alu_sub_sra = funct3 == (`SRAIW | `SRLIW) ? funct7[5] : 1'b0;
				`OP_32		: alu_sub_sra = funct7[5];
				default		: alu_sub_sra = 1'b0;
			endcase
		end

		always @(*) begin
			case (funct3)
				`BEQ		: branch_alu_ctrl = `ALU_CTRL_AOS;
				`BNE		: branch_alu_ctrl = `ALU_CTRL_AOS;
				`BLT		: branch_alu_ctrl = `ALU_CTRL_SLT;
				`BGE		: branch_alu_ctrl = `ALU_CTRL_SLT;
				`BLTU		: branch_alu_ctrl = `ALU_CTRL_SLTU;
				`BGEU		: branch_alu_ctrl = `ALU_CTRL_SLTU;
				default		: branch_alu_ctrl = `ALU_CTRL_AOS;
			endcase
		end

		always @(*) begin
			case (funct3)
				`ECALL | `MRET | `EBREAK	: csr_rd_en = 1'b1;
				`CSRRW						: csr_rd_en = rd == 5'd0 ? 1'b0 : 1'b1;
				`CSRRS						: csr_rd_en = 1'b1;
				`CSRRC						: csr_rd_en = 1'b1;
				`CSRRWI						: csr_rd_en = rd == 5'd0 ? 1'b0 : 1'b1;
				`CSRRSI						: csr_rd_en = 1'b1;
				`CSRRCI						: csr_rd_en = 1'b1;
				default						: csr_rd_en = 1'b0;
			endcase
		end

		always @(*) begin
			case (funct3)
				`ECALL | `MRET | `EBREAK	: csr_wt_en = 1'b0;
				`CSRRW						: csr_wt_en = 1'b1;
				`CSRRS						: csr_wt_en = rs1 == 5'd0 ? 1'b0 : 1'b1;
				`CSRRC						: csr_wt_en = rs1 == 5'd0 ? 1'b0 : 1'b1;
				`CSRRWI						: csr_wt_en = 1'b1;
				`CSRRSI						: csr_wt_en = rs1 == 5'd0 ? 1'b0 : 1'b1;
				`CSRRCI						: csr_wt_en = rs1 == 5'd0 ? 1'b0 : 1'b1;
				default						: csr_wt_en = 1'b0;
			endcase
		end

		always @(*) begin
			case (funct3)
				`ECALL | `MRET | `EBREAK	: csr_alu_ctrl = `ALU_CTRL_AOS;
				`CSRRW						: csr_alu_ctrl = `ALU_CTRL_AOS;
				`CSRRS						: csr_alu_ctrl = `ALU_CTRL_OR;
				`CSRRC						: csr_alu_ctrl = `ALU_CTRL_AND;
				`CSRRWI						: csr_alu_ctrl = `ALU_CTRL_AOS;
				`CSRRSI						: csr_alu_ctrl = `ALU_CTRL_OR;
				`CSRRCI						: csr_alu_ctrl = `ALU_CTRL_AND;
				default						: csr_alu_ctrl = `ALU_CTRL_AOS;
			endcase
		end

			/****************************************************************************************************************************************/
	`else	/****************************************************************************************************************************************/
			/****************************************************************************************************************************************/

		wire alu_sub_sra;//0: ADD,SRL		1: SUB,SRA
		wire csr_rd_en, csr_wt_en;
		wire [2:0] csr_alu_ctrl;
		wire [2:0] branch_alu_ctrl;

		MuxKeyWithDefault #(12, 7, 1) u_rd_w_en (
			.out(rd_w_en),
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
				`SYSTEM,	inst_sys_jump ? 1'b0 : 1'b1,// if(inst == ecall | ebreak | mret) rd_w_en = 0;
				`OP_IMM_32,	1'b1,
				`OP_32,		1'b1
			})
		);

		MuxKeyWithDefault #(12, 7, 2) u_rd_w_src (
			.out(rd_w_src),
			.key(opcode),
			.default_out(2'b0),
			.lut({
				`LUI,		`RD_SRC_ALU,
				`AUIPC,		`RD_SRC_ALU,
				`JAL,		`RD_SRC_ALU,
				`JALR,		`RD_SRC_ALU,
				`BRANCH,	2'b0,
				`LOAD,		`RD_SRC_MEM,
				`STORE,		2'b0,
				`OP_IMM,	`RD_SRC_ALU,
				//MISC_MEM
				`SYSTEM,	`RD_SRC_CSR,
				`OP_IMM_32,	`RD_SRC_ALU,
				`ifdef EXTENSION_M
					`OP,	mdu_en ? `RD_SRC_MDU : `RD_SRC_ALU,
					`OP_32,	mdu_en ? `RD_SRC_MDU : `RD_SRC_ALU
				`else
					`OP,	`RD_SRC_ALU,
					`OP_32,	`RD_SRC_ALU
				`endif
			})
		);

		MuxKeyWithDefault #(12, 7, 2) u_alu_src1 (
			.out(alu_src1),
			.key(opcode),
			.default_out(`ALU_SRC1_0),
			.lut({
				`LUI,		`ALU_SRC1_0,
				`AUIPC,		`ALU_SRC1_PC,
				`JAL,		`ALU_SRC1_PC,
				`JALR,		`ALU_SRC1_PC,
				`BRANCH,	`ALU_SRC1_XRS1,
				`LOAD,		`ALU_SRC1_XRS1,
				`STORE,		`ALU_SRC1_XRS1,
				`OP_IMM,	`ALU_SRC1_XRS1,
				`OP,		`ALU_SRC1_XRS1,
				//MISC_MEM
				`SYSTEM,	`ALU_SRC1_CSR,
				`OP_IMM_32,	`ALU_SRC1_XRS1,
				`OP_32,		`ALU_SRC1_XRS1
			})
		);

		MuxKeyWithDefault #(12, 7, 2) u_alu_src2 (
			.out(alu_src2),
			.key(opcode),
			.default_out(`ALU_SRC2_4),
			.lut({
				`LUI,		`ALU_SRC2_IMM,
				`AUIPC,		`ALU_SRC2_IMM,
				`JAL,		`ALU_SRC2_4,
				`JALR,		`ALU_SRC2_4,
				`BRANCH,	`ALU_SRC2_XRS2,
				`LOAD,		`ALU_SRC2_IMM,
				`STORE,		`ALU_SRC2_IMM,
				`OP_IMM,	`ALU_SRC2_IMM,
				`OP,		`ALU_SRC2_XRS2,
				//MISC_MEM
				`SYSTEM,	`ALU_SRC2_CSR,
				`OP_IMM_32,	`ALU_SRC2_IMM,
				`OP_32,		`ALU_SRC2_XRS2
			})
		);

		MuxKeyWithDefault #(12, 7, 3) u_alu_ctrl_2_0 (
			.out(alu_ctrl[2:0]),
			.key(opcode),
			.default_out(`ALU_CTRL_AOS),
			.lut({
				`LUI,		`ALU_CTRL_AOS,//x[rd] = imm
				`AUIPC,		`ALU_CTRL_AOS,//x[rd] = pc + imm;
				`JAL,		`ALU_CTRL_AOS,//x[rd] = pc + 4; pc += imm;
				`JALR,		`ALU_CTRL_AOS,//x[rd] = pc + 4; pc = (x[rs1] + imm) & ~1;
				`BRANCH,	branch_alu_ctrl,//xxx = x[rs1]-x[rs2]; if(xxx) pc += imm;
				`LOAD,		`ALU_CTRL_AOS,//x[rd] = M[x[rs1] + imm]
				`STORE,		`ALU_CTRL_AOS,//M[x[rs1] + imm] = x[rs2]
				`OP_IMM,	funct3,  //x[rd] = x[rs1] op imm;
				`OP,		funct3,  //x[rd] = x[rs1] op x[rs2];
				//MISC_MEM
				`SYSTEM,	csr_alu_ctrl,//csr |= rs1, csr &= rs1
				`OP_IMM_32,	funct3,  //x[rd] = sext(x[rs1] op imm);
				`OP_32,		funct3   //x[rd] = sext(x[rs1] op x[rs2]);
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
				`OP_IMM,	funct3 == (`SRAI | `SRLI) ? funct7[5] : 1'b0,
				`OP,		funct7[5],
				//MISC_MEM
				`SYSTEM,	1'b0,
				`OP_IMM_32,	funct3 == (`SRAIW | `SRLIW) ? funct7[5] : 1'b0,
				`OP_32,		funct7[5]
			})
		);

		MuxKeyWithDefault #(6, 3, 3) u_branch_alu_ctrl (
			.out(branch_alu_ctrl),
			.key(funct3),
			.default_out(`ALU_CTRL_AOS),
			.lut({
				`BEQ	, `ALU_CTRL_AOS,
				`BNE	, `ALU_CTRL_AOS,
				`BLT	, `ALU_CTRL_SLT,
				`BGE	, `ALU_CTRL_SLT,
				`BLTU	, `ALU_CTRL_SLTU,
				`BGEU	, `ALU_CTRL_SLTU
			})
		);

		MuxKeyWithDefault #(7, 3, 1) u_csr_rd_en (
			.out(csr_rd_en),
			.key(funct3),
			.default_out(1'b0),
			.lut({
				`ECALL | `MRET | `EBREAK,	1'b1,
				`CSRRW					,	rd == 5'd0 ? 1'b0 : 1'b1,
				`CSRRS					,	1'b1,
				`CSRRC					,	1'b1,
				`CSRRWI					,	rd == 5'd0 ? 1'b0 : 1'b1,
				`CSRRSI					,	1'b1,
				`CSRRCI					,	1'b1
			})
		);

		MuxKeyWithDefault #(7, 3, 1) u_csr_wt_en (
			.out(csr_wt_en),
			.key(funct3),
			.default_out(1'b0),
			.lut({
				`ECALL | `EBREAK | `MRET,	1'b0,
				`CSRRW					,	1'b1,
				`CSRRS					,	rs1 == 5'd0 ? 1'b0 : 1'b1,
				`CSRRC					,	rs1 == 5'd0 ? 1'b0 : 1'b1,
				`CSRRWI					,	1'b1,
				`CSRRSI					,	rs1 == 5'd0 ? 1'b0 : 1'b1,
				`CSRRCI					,	rs1 == 5'd0 ? 1'b0 : 1'b1
			})
		);

		MuxKeyWithDefault #(7, 3, 3) u_csr_alu_ctrl (
			.out(csr_alu_ctrl),
			.key(funct3),
			.default_out(`ALU_CTRL_AOS),
			.lut({
				`ECALL | `EBREAK | `MRET,	`ALU_CTRL_AOS,
				`CSRRW					,	`ALU_CTRL_AOS,
				`CSRRS					,	`ALU_CTRL_OR,
				`CSRRC					,	`ALU_CTRL_AND,
				`CSRRWI					,	`ALU_CTRL_AOS,
				`CSRRSI					,	`ALU_CTRL_OR,
				`CSRRCI					,	`ALU_CTRL_AND
			})
		);


	`endif

	localparam CSR_ADDR_MTVEC		= 12'h305;
	localparam CSR_ADDR_MEPC		= 12'h341;
		assign csr_addr = inst_sys_jump ? (
					      inst_sys_ecall ? CSR_ADDR_MTVEC : 	//ecall
					     (inst_sys_mret ? CSR_ADDR_MEPC : 		//mret
					      CSR_ADDR_MTVEC)) : 					//ebreak
					      inst[31:20];							//CSRRW

import "DPI-C" function void stopCPU();
	always @(*) begin
		if(inst_sys_ebreak) begin
			stopCPU();
		end
	end

endmodule //csgu

`endif /* CSGU_V */