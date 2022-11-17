//full adder

`include "top.v"

module full_adder (
	input  [`XLEN-1:0] a,
	input  [`XLEN-1:0] b,
	input  cin,
	output [`XLEN-1:0] s,
	output cout
);
	assign {cout, s} = a + b + (cin ? 1 : 0);

endmodule //full_adder