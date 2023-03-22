/*************************************************************
 * @ name           : alu_sim.v
 * @ description    : Arithmetic Logic Unit
 * @ use module     : MuxKeyWithDefault
 * @ author         : K
 * @ chnge date     : 2023-3-12
*************************************************************/
`ifndef ALU_SIM_V
`define ALU_SIM_V

`include "common.v"

module alu_sim (
	input  [4:0] alu_ctrl,
	input  [`XLEN-1:0] a,
	input  [`XLEN-1:0] b,
	output [`XLEN-1:0] result,
	output smaller,
	output equal
);

	wire sub_sra, inst_32;//0: ADD,SRL		1: SUB,SRA
	wire [2:0] sel;
	assign {inst_32, sub_sra, sel} = alu_ctrl;
	wire unsign = alu_ctrl[0];

	wire [`XLEN-1:0] adder_out, cmp_b;
	wire sub;

	assign sub = (sub_sra == 1'b1) || (sel == `ALU_CTRL_SLT) || (sel == `ALU_CTRL_SLTU);
	assign adder_out = sub ? (a - b) : (a + b);
	assign equal = (adder_out == `XLEN'b0);
	assign smaller = unsign ? ($unsigned(a) < $unsigned(b)) : ($signed(a) < $signed(b));

	wire [`XLEN-1:0] out_srl, out_sra, out_sll;
	assign out_sll = inst_32 ? ({`HXLEN'b0, a[`HXLEN-1:0] << b[4:0]}) : (a << b[5:0]);
	assign out_srl = inst_32 ? ({`HXLEN'b0, a[`HXLEN-1:0]} >> b[4:0]) : (a >> b[5:0]);
	assign out_sra = inst_32 ? ({`HXLEN'b0, $signed(($signed(a[`HXLEN-1:0])) >>> b[4:0])}) : $signed(($signed(a[`XLEN-1:0])) >>> b[5:0]);

	reg [`XLEN-1:0] alu_out;
	assign result = inst_32 ? {{(`HXLEN){alu_out[`HXLEN-1]}}, alu_out[`HXLEN-1:0]} : alu_out;
	always @(*) begin
		case (sel)
				`ALU_CTRL_AOS	: alu_out = adder_out;
				`ALU_CTRL_SLT	: alu_out = {{(`XLEN-1){1'b0}}, smaller};
				`ALU_CTRL_SLTU	: alu_out = {{(`XLEN-1){1'b0}}, smaller};
				`ALU_CTRL_AND	: alu_out = a & b;
				`ALU_CTRL_OR	: alu_out = a | b;
				`ALU_CTRL_XOR	: alu_out = a ^ b;
				`ALU_CTRL_SLL	: alu_out = out_sll;
				`ALU_CTRL_SR	: alu_out = sub_sra == 1'b1 ? out_sra : out_srl;
				default			: alu_out = `XLEN'b0;
		endcase
	end

endmodule //alu_sim

`endif /* ALU_SIM_V */