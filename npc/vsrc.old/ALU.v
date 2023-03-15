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
	input  is_op_x_32,
	output [`XLEN-1:0] result,
	output cout,
	output zero,
	output overflow, 
	output smaller_s,
	output smaller_u,
	output equal
);

	wire [`XLEN-1:0] adder_out, tmp_b;
	wire sub;

	assign sub = (sub_sra == 1'b1) || (sel == `SEL_SLT) || (sel == `SEL_SLTU);
	assign tmp_b = {`XLEN{sub}} ^ b;
	assign zero = ~(| result);
	assign equal = ~(| adder_out);
	assign overflow = (a[`XLEN-1] == tmp_b[`XLEN-1]) && (a[`XLEN-1] != adder_out[`XLEN-1]);//signed
	assign smaller_s = adder_out[`XLEN-1] ^ overflow;
	assign smaller_u = sub ^ cout;//~cout?
	//assign smaller = (sel == `SEL_SLT) ? smaller_s : smaller_u;

	full_adder u_full_adder (
		.a(a),
		.b(tmp_b),
		.cin(sub),
		.s(adder_out),
		.cout(cout)
	);

	wire [`XLEN-1:0] out_srl, out_sra, out_sll;
	wire [`HXLEN-1:0] out_sra_32;
	assign out_sll = is_op_x_32 ? (a << b[4:0]) : (a << b[5:0]);
	assign out_srl = is_op_x_32 ? (a >> b[4:0]) : (a >> b[5:0]);
	assign out_sra_32 = $signed(($signed(a[`HXLEN-1:0])) >>> b[4:0]);
	assign out_sra = is_op_x_32 ? ({`HXLEN'b0, out_sra_32}) : $signed(($signed(a[`XLEN-1:0])) >>> b[5:0]);

	MuxKeyWithDefault #(8, `LEN_SEL, `XLEN) u_result (
		.out(result),
		.key(sel),
		.default_out(`XLEN'b0),
		.lut({
			`SEL_AOS,	adder_out,
			`SEL_SLT,	{{(`XLEN-1){1'b0}}, smaller_s},
			`SEL_SLTU,	{{(`XLEN-1){1'b0}}, smaller_u},
			`SEL_AND,	a & b,
			`SEL_OR,	a | b,
			`SEL_XOR,	a ^ b,
			`SEL_SLL,	out_sll,
			`SEL_SR,	sub_sra == 1'b1 ? out_sra : out_srl
		})
	);

endmodule //ALU

`endif /* ALU_V */