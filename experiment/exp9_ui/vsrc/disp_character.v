module disp_character (
    input clk,
    input rst,
    input ps2_clk,
    input ps2_dat,
    output VGA_CLK,
    output VGA_HSYNC,
    output VGA_VSYNC,
    output VGA_BLANK_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B
);


	wire [9:0] h_addr;
	wire [9:0] v_addr;
	reg [23:0] vga_data;

	localparam SCREEN_WIDTH = 640;
	localparam SCREEN_HEIGHT = 480;
	localparam SCREEN_HISTORY = 3;//keep 2 pages of history
	localparam SCREEN_COL = 70;
	localparam SCREEN_LIN = 30;

	localparam KEY_UP = 	8'h01;
	localparam KEY_DOWN = 	8'h02;
	localparam KEY_LEFT = 	8'h03;
	localparam KEY_RIGHT = 	8'h04;
	localparam KEY_BACKSPACE = 8'h08;
	localparam KEY_ENTER = 8'h0D;

	reg [7:0] disp_ram [SCREEN_COL * SCREEN_LIN * SCREEN_HISTORY - 1 : 0];//display ram fifo[6300-1:0]
	wire [7:0] disp_ascii;
	reg	[6:0] start_line, end_line;//0-89
	wire [6:0] x_axis;//0-69
	wire [4:0] y_axis;//0-29
	reg [6:0] x_cursor;//0-69
	reg [4:0] y_cursor;//0-29
	reg [3:0] blink_cnt;//0-31
	reg blink;
	wire [3:0] line;//0-15
	wire [3:0] col;//0-8
	wire [11:0] matrix;

	wire refresh = (h_addr == 639) && (v_addr == 479);

	always @(*) begin
		if (x_cursor == x_axis && y_cursor == y_axis) begin
			if (blink) begin
				vga_data = matrix[col] ? 24'hFFFFFF : 24'h000000;
			end else begin
				vga_data = matrix[col] ? 24'h000000 : 24'hFFFFFF;
			end
			
		end else begin
			vga_data = matrix[col] ? 24'hFFFFFF : 24'h000000;
		end
	end

/******************************
*		cursor blink control
******************************/
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			blink <= 0;
			blink_cnt <= 0;
		end else begin
			if(refresh) begin
				blink_cnt <= blink_cnt + 1;
				if(blink_cnt == 0) begin
					blink <= ~blink;
				end
			end
		end
	end

/******************************
*		display ram read/write control
******************************/
	wire [12:0] rd_ram_addr;//0-629: read
	xy2ramadd xy2ramadd_rd(
		.x_axis(x_axis),
		.y_axis(y_axis),
		.start_line(start_line),
		.ram_addr(rd_ram_addr)
	);
	assign disp_ascii = disp_ram[rd_ram_addr];

	wire [12:0] wt_ram_addr;//0-629: write
	xy2ramadd xy2ramadd_wt(
		.x_axis(x_cursor),
		.y_axis(y_cursor),
		.start_line(start_line),
		.ram_addr(wt_ram_addr)
	);

	wire [12:0] cl_ram_addr;//0-629: clean ram line of end_line
	xy2ramadd xy2ramadd_cl(
		.x_axis(x_axis),//same x with scanning
		.y_axis(0),
		.start_line(end_line),
		.ram_addr(cl_ram_addr)
	);

	wire direction_key = key_ascii == KEY_UP || key_ascii == KEY_DOWN || key_ascii == KEY_LEFT || key_ascii == KEY_RIGHT;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			read_next <= 0;
		end else begin
			if (refresh & ready) begin
				if(~direction_key) begin
					if (key_ascii == KEY_BACKSPACE) begin//backspace
						disp_ram[wt_ram_addr] <= 0;
						read_next <= 1;
					end else begin
						if(x_cursor == 69) begin//auto enter
							disp_ram[wt_ram_addr] <= KEY_ENTER;
							read_next <= 0;
						end else begin
							disp_ram[wt_ram_addr] <= key_ascii;
							read_next <= 1;
						end
					end
				end else begin
					read_next <= 1;
				end
			end else begin
				disp_ram[cl_ram_addr] <= 0;//clean end line
				read_next <= 0;
			end
		end
	end

/******************************
*		cursor start_line control
******************************/
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			y_cursor <= 0;
			x_cursor <= 0;
			start_line <= 0;
			end_line <= 30;
		end else begin
			if (ready & refresh) begin
				case (key_ascii)
					KEY_UP:begin
						if (y_cursor != 0) begin
							y_cursor <= y_cursor - 1;
						end else begin
							if (start_line != 0) begin
								if((start_line - 1) != end_line) start_line <= start_line - 1;
							end else begin
								if(end_line != 89) start_line <= 89;
							end
						end
					end

					KEY_DOWN:begin
						if (y_cursor != 29) begin
							y_cursor <= y_cursor + 1;
						end else begin
							if (start_line != 89) begin
								if ((start_line + 29) < 90 && (start_line + 29) != end_line) start_line <= start_line + 1;
								if ((start_line + 29) >= 90 && (start_line - 61) != end_line) start_line <= start_line + 1;
							end else begin
								if(end_line != 29) start_line <= 0;
							end
						end
					end

					KEY_LEFT, KEY_BACKSPACE:begin
						if (x_cursor != 0) begin
							x_cursor <= x_cursor - 1;
						end else begin
							x_cursor <= 69;
							if (y_cursor != 0) begin
								y_cursor <= y_cursor - 1;
							end else begin
								if (start_line != 0) begin
									if((start_line - 1) != end_line) start_line <= start_line - 1;
								end else begin
									if(end_line != 89) start_line <= 89;
								end
							end
						end
					end

					KEY_RIGHT:begin
						if (x_cursor != 69) begin
							x_cursor <= x_cursor + 1;
						end else begin
							x_cursor <= 0;
							if (y_cursor != 29) begin
								y_cursor <= y_cursor + 1;
							end else begin
								if (start_line != 89) begin
									if ((start_line + 29) < 90 && (start_line + 29) != end_line) start_line <= start_line + 1;
									if ((start_line + 29) >= 90 && (start_line - 61) != end_line) start_line <= start_line + 1;
								end else begin
									if(end_line != 29) start_line <= 0;
								end
							end
						end
					end

					KEY_ENTER:begin
						x_cursor <= 0;
						if (y_cursor != 29) begin
							y_cursor <= y_cursor + 1;
						end else begin
							if (start_line != 89) begin
								start_line <= start_line + 1;
								if ((start_line + 29) < 90 && (start_line + 29) == end_line) end_line <= end_line + 1;
								if ((start_line + 29) >= 90 && (start_line - 61) == end_line) end_line <= end_line + 1;
							end else begin
								start_line <= 0;
								if(end_line != 29) end_line <= end_line + 1;
							end
						end
					end

					default:begin
						if (x_cursor != 69) begin
							x_cursor <= x_cursor + 1;
						end else begin
							x_cursor <= 0;
							if (y_cursor != 29) begin
								y_cursor <= y_cursor + 1;
							end else begin
								if (start_line != 89) begin
									start_line <= start_line + 1;
									if ((start_line + 29) < 90 && (start_line + 29) == end_line) end_line <= end_line + 1;
									if ((start_line + 29) >= 90 && (start_line - 61) == end_line) end_line <= end_line + 1;
								end else begin
									start_line <= 0;
									if(end_line != 29) end_line <= end_line + 1;
								end
							end
						end
					end
				endcase		
			end
		end
	end

/******************************
*		mudule
******************************/

	assign VGA_CLK = clk;

	vga_ctrl my_vga_ctrl(
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
	
	wire ready;
	reg read_next;
	wire [7:0] key_ascii;

	keyboard my_keyboard(
		.clk(clk),
		.rst(rst),
		.ps2_clk(ps2_clk),
		.ps2_dat(ps2_dat),
		.ascii_read_next(read_next),
		.ascii_ready(ready),
		.key_code(key_ascii)
	);

	ascii2matrix my_ascii2matrix(
		.ascii(disp_ascii),
		.line(line),
		.matrix(matrix)
	);

	add2xy my_add2xy(
    	.clk(clk),
    	.rst(rst),
		.h_addr(h_addr),
		.v_addr(v_addr),
		.x_axis(x_axis),
		.y_axis(y_axis),
		.line(line),
		.col(col)
	);

endmodule //disp_character