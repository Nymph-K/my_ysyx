/*************************************************************
 * @ name           : alu.v
 * @ description    : Arithmetic Logic Unit
 * @ use module     : MuxKeyWithDefault
 * @ author         : K
 * @ chnge date     : 2023-3-12
*************************************************************/
`ifndef ALU_V
`define ALU_V

`include "common.v"

module alu (
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
	wire sub, overflow, cout;

	assign sub = (sub_sra == 1'b1) || (sel == `ALU_CTRL_SLT) || (sel == `ALU_CTRL_SLTU);
	assign cmp_b = sub ? ~b : b;
	assign {cout, adder_out} = a + cmp_b + (sub ? 1 : 0);
	assign equal = ~(| adder_out);
	assign overflow = (a[`XLEN-1] == cmp_b[`XLEN-1]) && (a[`XLEN-1] != adder_out[`XLEN-1]);//signed
	wire smaller_s = adder_out[`XLEN-1] ^ overflow;
	wire smaller_u = sub ^ cout;
	assign smaller = unsign ? smaller_u : smaller_s;

	wire [`XLEN-1:0] out_srl, out_sra, out_sll;
	assign out_sll = inst_32 ? ({`HXLEN'b0, a[`HXLEN-1:0] << b[4:0]}) : (a << b[5:0]);
	assign out_srl = inst_32 ? ({`HXLEN'b0, a[`HXLEN-1:0]} >> b[4:0]) : (a >> b[5:0]);
	assign out_sra = inst_32 ? ({`HXLEN'b0, $signed(($signed(a[`HXLEN-1:0])) >>> b[4:0])}) : $signed(($signed(a[`XLEN-1:0])) >>> b[5:0]);

	wire [`XLEN-1:0] alu_out;
	assign result = inst_32 ? {{(`HXLEN){alu_out[`HXLEN-1]}}, alu_out[`HXLEN-1:0]} : alu_out;
	MuxKeyWithDefault #(8, 3, `XLEN) u_alu_out (
		.out(alu_out),
		.key(sel),
		.default_out(`XLEN'b0),
		.lut({
			`ALU_CTRL_AOS,	adder_out,
			`ALU_CTRL_SLT,	{{(`XLEN-1){1'b0}}, smaller_s},
			`ALU_CTRL_SLTU,	{{(`XLEN-1){1'b0}}, smaller_u},
			`ALU_CTRL_AND,	a & b,
			`ALU_CTRL_OR,	a | b,
			`ALU_CTRL_XOR,	a ^ b,
			`ALU_CTRL_SLL,	out_sll,
			`ALU_CTRL_SR,	sub_sra == 1'b1 ? out_sra : out_srl
		})
	);

endmodule //ALU

`endif /* ALU_V */