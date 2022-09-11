module num2seg (
	input en,
	input [7:0] num,
	output [15:0] seg
);
	wire [7:0] segs[15:0];
	assign segs[0]  = 8'b00000011;//0
	assign segs[1]  = 8'b10011111;//1
	assign segs[2]  = 8'b00100101;//2
	assign segs[3]  = 8'b00001101;//3
	assign segs[4]  = 8'b10011001;//4
	assign segs[5]  = 8'b01001001;//5
	assign segs[6]  = 8'b01000001;//6
	assign segs[7]  = 8'b00011111;//7
	assign segs[8]  = 8'b00000001;//8
	assign segs[9]  = 8'b00001001;//9
	assign segs[10] = 8'b00010001;//A
	assign segs[11] = 8'b11000001;//B
	assign segs[12] = 8'b01100011;//C
	assign segs[13] = 8'b10000101;//D
	assign segs[14] = 8'b01100001;//E
	assign segs[15] = 8'b01110001;//F

	assign seg[7:0] = en ? segs[num[3:0]] : 8'hFF;
	assign seg[15:8] = en ? segs[num[7:4]] : 8'hFF;

endmodule //num2seg