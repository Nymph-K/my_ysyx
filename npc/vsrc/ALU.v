//Arithmetic Logic Unit
`ifndef ALU_V
`define ALU_V

`include "top.v"

`define LEN_SEL 3

`define SEL_AOS		 `LEN_SEL'b000//ADD or SUB
`define SEL_SLL		 `LEN_SEL'b001
`define SEL_SLT		 `LEN_SEL'b010
`define SEL_SLTU	 `LEN_SEL'b011
`define SEL_XOR		 `LEN_SEL'b100
`define SEL_SR		 `LEN_SEL'b101
`define SEL_OR		 `LEN_SEL'b110
`define SEL_AND		 `LEN_SEL'b111

module ALU (
	input  [`LEN_SEL-1:0] sel,
	input  [`XLEN-1:0] a,
	input  [`XLEN-1:0] b,
	input  sub_sra, //0: ADD,SRL		1: SUB,SRA
	output [`XLEN-1:0] result,
	output cout,
	output zero,
	output overflow, 
	output smaller,
	output equal
);

	wire [`XLEN-1:0] adder_out, tmp_b;
	wire sub;

	assign sub = (sub_sra == 1'b1) || (sel == `SEL_SLT) || (sel == `SEL_SLTU);
	assign tmp_b = {`XLEN{sub}} ^ b;
	assign zero = ~(| result);
	assign equal = ~(| adder_out);
	assign overflow = (a[`XLEN-1] == b[`XLEN-1]) && (a[`XLEN-1] != adder_out[`XLEN-1]);
	assign smaller = adder_out[`XLEN-1] ^ overflow;

	full_adder u_full_adder (
		.a(a),
		.b(tmp_b),
		.cin(sub),
		.s(adder_out),
		.cout(cout)
	);

	MuxKeyWithDefault #(8, `LEN_SEL, `XLEN) u_result (
		.out(result),
		.key(sel),
		.default_out(`XLEN'b0),
		.lut({
			`SEL_AOS,	adder_out,
			`SEL_SLT,	adder_out,
			`SEL_SLTU,	adder_out,
			`SEL_AND,	a & b,
			`SEL_OR,	a | b,
			`SEL_XOR,	a ^ b,
			`SEL_SLL,	{a << b}[`XLEN-1:0],
			`SEL_SR,	sub_sra == 1'b1 ? {($signed(a)) >>> b}[`XLEN-1:0] : {a >> b}[`XLEN-1:0]
		})
	);

endmodule //ALU

`endif /* ALU_V */