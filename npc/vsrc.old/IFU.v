module IFU (
	input  clk,
	input  rst,
	input [`XLEN-1:0] pc,
	output [31:0] inst
);

import "DPI-C" function void instruction_fetch(input longint pc, output int inst);
	always_latch @(*) begin
		if (~rst) begin
			instruction_fetch(pc, inst);
		end
	end

endmodule //IFU