module add2xy (
    input clk,
    input rst,
	input [9:0]  h_addr,
	input [9:0]  v_addr,
	output reg [6:0] x_axis,//0-70
	output [4:0] y_axis,//0-29
	output [3:0] line,//0-15
	output [3:0] col//0-8
);
	assign y_axis = v_addr[8:4];	// y_axis = v_addr/16

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			x_axis <= 0;
		end else begin
			if (h_addr >= 638) begin
				x_axis <= 0;
			end else begin
				if(({x_axis, 3'b000} + {3'b000, x_axis} + 8) <= h_addr) begin 	// (x_axis+1)*9 <= (h_addr + 1)
					x_axis <= x_axis + 1;
				end
			end
		end
	end
	/* verilator lint_off WIDTH */
	assign line = v_addr - {1'b0, y_axis, 4'd0};
	assign col = h_addr - {x_axis, 3'd0} - {3'b0, x_axis};
	/* verilator lint_off WIDTH */
endmodule //add2xy