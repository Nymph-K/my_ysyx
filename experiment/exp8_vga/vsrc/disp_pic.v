module disp_pic (
    input clk,
    input rst,
    output VGA_CLK,
    output VGA_HSYNC,
    output VGA_VSYNC,
    output VGA_BLANK_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B
);

	assign VGA_CLK = clk;

	wire [9:0] h_addr;
	wire [9:0] v_addr;
	wire [23:0] vga_data;

	vga_ctrl i0(
		.pclk(clk),
		.reset(rst),
		.vga_data(vga_data),
		.h_addr(h_addr),
		.v_addr(v_addr),
		.hsync(VGA_HSYNC),
		.vsync(VGA_VSYNC),
		.valid(VGA_BLANK_N),
		.vga_r(VGA_R),
		.vga_g(VGA_G),
		.vga_b(VGA_B)
	);

	read_bmp i1(
		.h_addr(h_addr),
		.v_addr(v_addr[8:0]),
		.vga_data(vga_data)
	);
endmodule //disp_pic