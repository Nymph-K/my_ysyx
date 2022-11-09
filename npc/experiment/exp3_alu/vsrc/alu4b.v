module alu4b (
	input [2:0]sel,
	input [3:0] a,
	input [3:0] b,
	output reg [3:0] result,
	output reg c,
	output reg zero,
	output reg overflow,
	output reg smaller,
	output reg equal
);
	wire [3:0] tmp_b, tmp_s;
	wire tmp_cin, tmp_cout;
	assign tmp_b = (sel == 0) ? b : ~b;
	assign tmp_cin = (sel == 0) ? 0 : 1;

	fa4b i0(
		.a(a),
		.b(tmp_b),
		.cin(tmp_cin),
		.s(tmp_s),
		.cout(tmp_cout)
	);

always @(*) begin
	case (sel)
	0: begin
		result = tmp_s;
		c = tmp_cout;
		zero = ~(| tmp_s);
		overflow = (a[3] == b[3]) && (a[3] != result[3]);
		smaller = 0;
		equal = 0;
	end

	1,6,7: begin
		result = tmp_s;
		c = tmp_cout;
		zero = ~(| tmp_s);
		overflow = (a[3] == b[3]) && (a[3] != result[3]);
		smaller = result[3] ^ overflow;
		equal = zero;
	end
	
	2: begin
		result = ~a;
		c = 0;
		zero = 0;
		overflow = 0;
		smaller = 0;
		equal = 0;
	end
	
	3: begin
		result = a & b;
		c = 0;
		zero = 0;
		overflow = 0;
		smaller = 0;
		equal = 0;
	end
	
	4: begin
		result = a | b;
		c = 0;
		zero = 0;
		overflow = 0;
		smaller = 0;
		equal = 0;
	end
	
	5: begin
		result = a ^ b;
		c = 0;
		zero = 0;
		overflow = 0;
		smaller = 0;
		equal = 0;
	end
	
	endcase
end


endmodule //adder_suber4b