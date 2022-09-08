module seg(
  input [2:0] num,
  output reg [7:0] seg_out
);

always @(num) begin
	case(num)
		0: seg_out = ~8'b11111101;
		1: seg_out = ~8'b01100000;
		2: seg_out = ~8'b11011010;
		3: seg_out = ~8'b11110010;
		4: seg_out = ~8'b01100110;
		5: seg_out = ~8'b10110110;
		6: seg_out = ~8'b10111110;
		7: seg_out = ~8'b11100000;
	endcase
end
endmodule
