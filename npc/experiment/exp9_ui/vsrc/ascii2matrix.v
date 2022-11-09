module ascii2matrix (
	input [7:0] ascii,
	input [3:0] line,//0-15
	output [11:0] matrix
);
	reg [11:0] vga_font [4095:0];

	initial begin
		$readmemh("resource/vga_font.txt", vga_font);
	end

	assign matrix = vga_font[{ascii, 4'b0000} + {8'b0, line}];

endmodule //ascii2matrix