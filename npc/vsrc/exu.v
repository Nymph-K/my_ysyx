/*************************************************************
 * @ name           : exu.v
 * @ description    : EXecution Unit
 * @ use module     : alu, mdu
 * @ author         : K
 * @ date modified  : 2023-3-13
*************************************************************/
`ifndef EXU_V
`define EXU_V

`include "common.v"

module exu (
	input [2:0] funct3,
	input [1:0] alu_src1,
	input [1:0] alu_src2,
	input [4:0] alu_ctrl,//[4] = inst_32, [3] = alu_sub_sra, [2:0] = funct3
	input [4:0] rs1,
	input [`XLEN-1:0] x_rs1,
	input [`XLEN-1:0] x_rs2,
	input [`XLEN-1:0] imm,
	input [`XLEN-1:0] pc,
	input [`XLEN-1:0] csr_r_data,
	output [`XLEN-1:0] alu_result,
	output smaller,
	output equal
);

	/********************* alu *********************/
	`ifdef FAST_SIMULATION
		alu_sim
	`else
		alu
	`endif
		u_alu (
			.alu_ctrl(alu_ctrl),
			.a(alu_a),
			.b(alu_b),
			.result(alu_result),
			.smaller(smaller),
			.equal(equal)
		);

	reg [`XLEN-1:0] alu_a, alu_b;
	reg [`XLEN-1:0] csr_alu_a, csr_alu_b;

	always @(*) begin
		case (alu_src1)
			`ALU_SRC1_0 	: alu_a = `XLEN'b0;
			`ALU_SRC1_XRS1 	: alu_a = x_rs1;
			`ALU_SRC1_PC 	: alu_a = pc;
			`ALU_SRC1_CSR 	: alu_a = csr_alu_a;
			default			: alu_a = `XLEN'b0;
		endcase
	end
	
	always @(*) begin
		case (alu_src2)
			`ALU_SRC2_XRS2 	: alu_b = x_rs2;
			`ALU_SRC2_IMM 	: alu_b = imm;
			`ALU_SRC2_4   	: alu_b = `XLEN'd4;
			`ALU_SRC2_CSR 	: alu_b = csr_alu_b;
			default			: alu_b = `XLEN'b0;
		endcase
	end

	always @(*) begin
		case (funct3)
			`CSRRW			: csr_alu_a = x_rs1;
			`CSRRS			: csr_alu_a = x_rs1;
			`CSRRC			: csr_alu_a = ~x_rs1;
			`CSRRWI			: csr_alu_a = {{(`XLEN-5){1'b0}}, rs1};
			`CSRRSI			: csr_alu_a = {{(`XLEN-5){1'b0}}, rs1};
			`CSRRCI			: csr_alu_a = ~{{(`XLEN-5){1'b0}}, rs1};
			default			: csr_alu_a = `XLEN'b0;
		endcase
	end

	always @(*) begin
		case (funct3)
			`CSRRW			: csr_alu_b = `XLEN'b0;
			`CSRRS			: csr_alu_b = csr_r_data;
			`CSRRC			: csr_alu_b = csr_r_data;
			`CSRRWI			: csr_alu_b = `XLEN'b0;
			`CSRRSI			: csr_alu_b = csr_r_data;
			`CSRRCI			: csr_alu_b = csr_r_data;
			default			: csr_alu_b = `XLEN'b0;
		endcase
	end


endmodule //exu

`endif /* EXU_V */