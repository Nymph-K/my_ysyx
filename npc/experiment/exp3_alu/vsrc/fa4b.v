module fa4b (
	input [3:0] a,
	input [3:0] b,
	input cin,
	output [3:0] s,
	output cout
);

	assign {cout, s} = a + b + (cin ? 1 : 0);

endmodule //fa4b