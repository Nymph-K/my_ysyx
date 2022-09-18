module xy2ramadd (
	input [6:0] x_axis,//0-70
	input [4:0] y_axis,//0-29
	input [6:0] start_line,//0-89
	output [12:0] ram_addr//0-6299
);
	wire [6:0] ram_line = ({2'b0, y_axis} + start_line) >= 90 ? ({2'b0, y_axis} + start_line - 90) : ({2'b0, y_axis} + start_line);
	assign ram_addr = {ram_line, 6'b0} + {4'b0, ram_line, 2'b0} + {5'b0, ram_line, 1'b0} + {6'b0, ram_line} + {6'b0, x_axis};

endmodule //xy2ramadd