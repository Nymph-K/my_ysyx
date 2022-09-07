module top(
  input clk,
  input rst_n,
  output reg [15:0] led
);
  reg [31:0] cnt;

  always@(posedge clk) begin
	if(~rst_n) begin
		led <= 16'b0001_0001_0001_0001;
		cnt <= 0;
	end
	else begin
		if(cnt >= 5000000) begin
			cnt <= 0;
			led <= {led[14:0], led[15]};
		end
		else cnt <= cnt + 1;
	end
  end
endmodule
