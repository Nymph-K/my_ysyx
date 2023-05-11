/*************************************************************
 * @ name           : bcu.v
 * @ description    : Branch Condition Unit
 * @ use module     : MuxKeyWithDefault
 * @ author         : K
 * @ date modified  : 2023-3-12
*************************************************************/
`ifndef BCU_V
`define BCU_V

`include "common.v"

module bcu (
	input [6:0] opcode,
	input [2:0] funct3,
	input smaller,
	input equal,
	output reg pc_src1,
	output reg pc_src2
);

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

endmodule //bcu

`endif /* BCU_V */