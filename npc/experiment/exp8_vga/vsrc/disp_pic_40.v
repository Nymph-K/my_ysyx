module disp_pic_40 (
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
	wire signed [9:0] tmp_h_addr;
	wire [9:0] v_addr;
	wire signed [9:0] tmp_v_addr;
	wire [23:0] vga_data, tmp_vga_data;

	reg [9:0] x_position;
	reg x_direction;//0-right -, 1-left +
	reg [8:0] y_position;
	reg y_direction;//0-down +, 1-up -

	always @(posedge clk or negedge rst) begin
		if (rst) begin
			x_position <= 0;
			y_position <= 0;
			x_direction <= 0;
			y_direction <= 0;
		end else begin
			if (h_addr == 639 && v_addr == 479) begin

				x_position <= x_direction ? (x_position - 1) : (x_position + 1);
				if (x_position + 1 + 256 >= 639) x_direction <= 1;
				if (x_position - 1 <= 0) x_direction <= 0;

				y_position <= y_direction ? (y_position - 1) : (y_position + 1);
				if (y_position + 1 + 192 >= 479) y_direction <= 1;
				if (y_position - 1 <= 0) y_direction <= 0;
			end
		end
	end

	wire tmp_h_addr = h_addr - x_position;
	wire tmp_v_addr = v_addr - y_position;
	wire tmp_vga_data = (tmp_h_addr >= 0 && tmp_h_addr <= 255) && (tmp_v_addr >= 0 && tmp_v_addr <= 191) ? vga_data : 24'b0;

	vga_ctrl i0(
		.pclk(clk),
		.reset(rst),
		.vga_data(tmp_vga_data),
		.h_addr(h_addr),
		.v_addr(v_addr),
		.hsync(VGA_HSYNC),
		.vsync(VGA_VSYNC),
		.valid(VGA_BLANK_N),
		.vga_r(VGA_R),
		.vga_g(VGA_G),
		.vga_b(VGA_B)
	);

	read_bmp_40 i1(
		.h_addr(tmp_h_addr),
		.v_addr(tmp_v_addr[8:0]),
		.vga_data(vga_data)
	);
endmodule //disp_pic_40