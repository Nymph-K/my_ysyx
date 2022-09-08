module coder83(
	input [7:0] sw_in,
	input sw_en,
	output reg  [2:0] led,
	output led_flag,
	output [7:0] seg_out
);

assign led_flag = | sw_in;

always @(*) begin
	if (sw_en) begin
		casez (sw_in)
			8'b1???_????: led = 7;
			8'b01??_????: led = 6;
			8'b001?_????: led = 5;
			8'b0001_????: led = 4;
			8'b0000_1???: led = 3;
			8'b0000_01??: led = 2;
			8'b0000_001?: led = 1;
			8'b0000_0001: led = 0;
			default: led = 0;
		endcase	
	end else begin
		led = 0;
	end
end

seg i0(
	.num(led),
	.seg_out(seg_out)
);

endmodule