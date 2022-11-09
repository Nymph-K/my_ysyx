module num2seg (
	input [7:0] num,
	output [23:0] seg
);
	wire [7:0] segs [9:0];
	assign segs[0] = ~8'b11111100;
	assign segs[1] = ~8'b01100000;
	assign segs[2] = ~8'b11011010;
	assign segs[3] = ~8'b11110010;
	assign segs[4] = ~8'b01100110;
	assign segs[5] = ~8'b10110110;
	assign segs[6] = ~8'b10111110;
	assign segs[7] = ~8'b11100000;
	assign segs[8] = ~8'b11111110;
	assign segs[9] = ~8'b11110110;

	assign seg[7:0] = segs[num%10];
	assign seg[15:8] = segs[num/10%10];
	assign seg[23:16] = segs[num/100];

endmodule //num2seg