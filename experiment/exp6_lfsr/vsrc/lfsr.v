module lfsr (
	input clk,
	input rstn,
	output reg [7:0] x,
	output [23:0] seg
);
	wire x8;
	assign x8 = ^ {x[4], x[3], x[2], x[0]};

	always @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			x <= 1;
		end
		else begin
			x <= {x8, x[7:1]};
		end
	end

	num2seg i0(
		.num(x),
		.seg(seg)
	);

endmodule //lfsr