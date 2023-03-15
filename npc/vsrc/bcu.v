/*************************************************************
 * @ name           : bcu.v
 * @ description    : Branch Condition Unit
 * @ use module     : MuxKeyWithDefault
 * @ author         : K
 * @ chnge date     : 2023-3-12
*************************************************************/
`ifndef BCU_V
`define BCU_V

`include "common.v"

module bcu (
	input [6:0] opcode,
	input [2:0] funct3,
	input smaller,
	input equal,
	`ifdef USE_IF_CASE
		output reg pc_src1,
		output reg pc_src2
	`else
		output 	   pc_src1,
		output 	   pc_src2
	`endif
);

	`ifdef USE_IF_CASE

		reg branch_cond;

		always @(*) begin
			case (funct3)
				`BEQ	: branch_cond = equal;
				`BNE	: branch_cond = ~equal;
				`BLT	: branch_cond = smaller;
				`BGE	: branch_cond = ~smaller;
				`BLTU	: branch_cond = smaller;	//result: -255 to 255
				`BGEU	: branch_cond = ~smaller; 	//result: -255 to 255
				default: branch_cond = 1'b0;
			endcase
		end
		
		always @(*) begin
			if (opcode == `JALR) begin
				pc_src1 = `PC_SRC1_XRS1;
			end else begin
				pc_src1 = `PC_SRC1_PC;
			end
		end
		
		always @(*) begin
			if (opcode == `JAL || opcode == `JALR) begin
				pc_src2 = `PC_SRC2_IMM;
			end else  if (opcode == `BRANCH) begin
				pc_src2 = branch_cond ? `PC_SRC2_IMM : `PC_SRC2_4;
			end else begin
				pc_src2 = `PC_SRC2_4;
			end
		end

	`else

		wire branch_cond;

		MuxKeyWithDefault #(6, 3, 1) u_branch_cond (
			.out(branch_cond),
			.key(funct3),
			.default_out(1'b0),
			.lut({
				`BEQ	, equal,
				`BNE	, ~equal,
				`BLT	, smaller,
				`BGE	, ~smaller,
				`BLTU	, smaller,	//result: -255 to 255
				`BGEU	, ~smaller 	//result: -255 to 255
			})
		);

		MuxKeyWithDefault #(12, 7, 1) u_pc_src1 (
			.out(pc_src1),
			.key(opcode),
			.default_out(`PC_SRC1_PC),
			.lut({
				`LUI,		`PC_SRC1_PC,
				`AUIPC,		`PC_SRC1_PC,
				`JAL,		`PC_SRC1_PC,
				`JALR,		`PC_SRC1_XRS1,
				`BRANCH,	`PC_SRC1_PC,
				`LOAD,		`PC_SRC1_PC,
				`STORE,		`PC_SRC1_PC,
				`OP_IMM,	`PC_SRC1_PC,
				`OP,		`PC_SRC1_PC,
				//MISC_MEM
				`SYSTEM,	`PC_SRC1_PC,//ecall, mret
				`OP_IMM_32,	`PC_SRC1_PC,
				`OP_32,		`PC_SRC1_PC
			})
		);
		MuxKeyWithDefault #(12, 7, 1) u_pc_src2 (
			.out(pc_src2),
			.key(opcode),
			.default_out(`PC_SRC2_4),
			.lut({
				`LUI,		`PC_SRC2_4,
				`AUIPC,		`PC_SRC2_4,
				`JAL,		`PC_SRC2_IMM,//pc += imm;
				`JALR,		`PC_SRC2_IMM,//pc = (x[rs1] + imm) & ~1;
				`BRANCH,	branch_cond ? `PC_SRC2_IMM : `PC_SRC2_4,//if(b) pc += imm;
				`LOAD,		`PC_SRC2_4,
				`STORE,		`PC_SRC2_4,
				`OP_IMM,	`PC_SRC2_4,
				`OP,		`PC_SRC2_4,
				//MISC_MEM
				`SYSTEM,	`PC_SRC2_4,//ecall, mret
				`OP_IMM_32,	`PC_SRC2_4,
				`OP_32,		`PC_SRC2_4
			})
		);

	`endif

endmodule //bcu

`endif /* BCU_V */