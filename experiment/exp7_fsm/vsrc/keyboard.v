module keyboard (
	input clk,
	input rst,
	input ps2_clk,
	input ps2_dat,
	output [15:0] seg_cnt,
	output [15:0] seg_close,
	output [15:0] seg_ascii,
	output [15:0] seg_code,
	output reg led_shift,
	output reg led_ctrl,
	output reg led_alt
);
	wire rstn = ~rst;
	wire read_next = ready;
	reg [7:0] data_buffer [2:0];
	wire ready;
	wire overflow;
	wire [7:0] data;

	reg en_key_cnt, en_key_ascii, en_key_code;
	reg [7:0] key_cnt;
	reg [7:0] key_ascii;
	reg [7:0] key_code;

	reg [4: 0] CS, NS;
	parameter [4:0] //one hot
		ERROR = 	5'b00000,
		IDLE = 		5'b00001,
		ARROW = 	5'b00010,
		RELEASE = 	5'b00100,
		SINGLE = 	5'b01000,
		MULTIPLE = 	5'b10000;

	//key scan code
	`define KEY_LSHIFT	8'h12
	`define KEY_RSHIFT	8'h59
	`define KEY_LCTRL	8'h14
	`define KEY_RCTRL	16'hE014
	`define KEY_LALT	8'h11
	`define KEY_RALT	16'hE011
	`define KEY_UP		16'hE075
	`define KEY_DOWN	16'hE072
	`define KEY_LEFT	16'hE06B
	`define KEY_RIGHT	16'hE074

	`define ASCII_KEY_UP	8'h01
	`define ASCII_KEY_DOWN	8'h02
	`define ASCII_KEY_LEFT	8'h03
	`define ASCII_KEY_RIGHT	8'h04

	always @(posedge clk or negedge rstn) begin
		if(~rstn)
			CS <= IDLE;
		else 
			CS <= NS;
			if(NS != CS) begin
				case (CS)
					ERROR:	 $write("CS = ERROR\t");
					IDLE:	 $write("CS = IDLE\t");
					ARROW:	 $write("CS = ARROW\t");
					RELEASE: $write("CS = RELEASE\t");
					SINGLE:  $write("CS = SINGLE\t");
					MULTIPLE:$write("CS = MULTIPLE\t");
					default: $write("default\t");
				endcase
				case (NS)
					ERROR:	 $write("NS = ERROR\t");
					IDLE:	 $write("NS = IDLE\t");
					ARROW:	 $write("NS = ARROW\t");
					RELEASE: $write("NS = RELEASE\t");
					SINGLE:  $write("NS = SINGLE\t");
					MULTIPLE:$write("NS = MULTIPLE\t");
					default: $write("default\t");
				endcase
				$display("buff = %H %H %H < %H", data_buffer[2], data_buffer[1], data_buffer[0], data);
			end
	end

	always @(*) begin
		NS = 5'bxxx;
		case (CS)
			IDLE:begin
				if (read_next == 1'b1)
					if (data == 8'hE0) NS = ARROW;	//push arrow key
					else NS = SINGLE;//push other key
				else NS = IDLE;
			end

			ARROW:begin
				if (read_next == 1'b1) begin
					if (data == 8'h75 || data == 8'h72 || data == 8'h6B || data == 8'h74)
						if (data_buffer[1] != 8'hF0) NS = SINGLE;	//push arrow key
						else NS = IDLE;		//release arrow key
					else NS = IDLE;
				end
				else NS = IDLE;
			end

			RELEASE:begin
				if (read_next == 1'b1) begin
					if (data == 8'hE0) begin
						NS = ARROW;
					end else if (data == data_buffer[1]) begin
						NS = IDLE;
					end else NS = RELEASE;
				end else begin
					NS = RELEASE;
				end
			end

			SINGLE:begin
				if (read_next == 1'b1) begin
					if (data != data_buffer[0]) begin	//push other key, prevent long push
						if (data != 8'hF0) begin
							if(data == 8'hE0 || data_buffer[0] == 8'hE0) NS = SINGLE;
							else NS = MULTIPLE;//push other key
						end
						else NS = RELEASE;
					end
					else NS = SINGLE;
				end
				else NS = SINGLE;
			end

			MULTIPLE:begin
				if (read_next == 1'b1) begin
					if (data_buffer[0] == 8'hF0) begin
						if( data == data_buffer[2] || data == data_buffer[1])
							NS = SINGLE;	//release one of 2 key
						else NS = MULTIPLE;	//release one of 3 or more key
					end
					else NS = MULTIPLE;
				end
				else NS = MULTIPLE;
			end

			ERROR: NS = IDLE;

			default:begin
				NS = IDLE;
			end
		endcase
	end

	always @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			//read_next <= 0;
			data_buffer[0] <= 0;
			data_buffer[1] <= 0;
			data_buffer[2] <= 0;
		end else begin
			//read_next <= ready;
			if (read_next == 1'b1) begin
				case (CS)
					IDLE:begin
						//if (data != data_buffer[0]) begin	//prevent long push
							{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data};
						//end
					end

					ARROW:begin
						if (data != data_buffer[0]) begin	//prevent long push
							{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data};
						end
					end

					RELEASE:begin
						if (data != data_buffer[0]) begin	//prevent long push
							{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data};
						end
					end

					SINGLE:begin
						if (data != data_buffer[0]) begin	//prevent long push
							{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data};
						end
					end

					MULTIPLE:begin
						if (data != data_buffer[0]) begin	//prevent long push
							if (data_buffer[0] == 8'hF0) begin
								if (data == data_buffer[1]) begin
									{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data_buffer[2]};//release second key
								end else if (data == data_buffer[2]) begin
									{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data_buffer[1]};//release first key
								end else begin
									{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data, data_buffer[2], data_buffer[1]};//release third key
								end
							end else
								{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data};
						end
					end

					ERROR:begin
						//read_next <= 0;
						data_buffer[0] <= 0;
						data_buffer[1] <= 0;
						data_buffer[2] <= 0;
					end

					default:begin
						//read_next <= 0;
						data_buffer[0] <= 0;
						data_buffer[1] <= 0;
						data_buffer[2] <= 0;
					end
				endcase
			end
		end
	end

	always @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			en_key_cnt <= 0;
			en_key_ascii <= 0;
			en_key_code <= 0;
			key_cnt <= 0;
			key_ascii <= 0;
			key_code <= 0;
			led_alt <= 0;
			led_ctrl <= 0;
			led_shift <= 0;
		end else begin
			case (CS)
				IDLE:begin
					en_key_cnt <= 1;
					en_key_ascii <= 0;
					en_key_code <= 0;
					if(NS == SINGLE) key_cnt <= key_cnt + 1;
					key_ascii <= 0;
					key_code <= 0;
					led_alt <= 0;
					led_ctrl <= 0;
					led_shift <= 0;
				end

				SINGLE:begin
					en_key_cnt <= 1;
					en_key_ascii <= 1;
					en_key_code <= 1;
					if(NS == MULTIPLE) key_cnt <= key_cnt + 1;
					key_ascii <= ascii_code[15:8];
					key_code <= data_buffer[0];
					if(data_buffer[0] == `KEY_LALT) 	led_alt <= 1; 	else led_alt <= 0;
					if(data_buffer[0] == `KEY_LCTRL) 	led_ctrl <= 1; 	else led_ctrl <= 0;
					if(data_buffer[0] == `KEY_LSHIFT) 	led_shift <= 1; else led_shift <= 0;
				end

				MULTIPLE:begin
					en_key_cnt <= 1;
					en_key_ascii <= 1;
					en_key_code <= 1;
					if (data_buffer[1] == `KEY_LSHIFT) begin//waste time!
						key_ascii <= ascii_code[7:0];
					end else begin
						key_ascii <= ascii_code[15:8];
					end
					key_code <= data_buffer[0];
					if(data_buffer[1] == `KEY_LALT  || data_buffer[0] == `KEY_LALT) 	led_alt <= 1; 	else led_alt <= 0;
					if(data_buffer[1] == `KEY_LCTRL || data_buffer[0] == `KEY_LCTRL) 	led_ctrl <= 1; 	else led_ctrl <= 0;
					if(data_buffer[1] == `KEY_LSHIFT || data_buffer[0] == `KEY_LSHIFT) 	led_shift <= 1; else led_shift <= 0;
				end

				ERROR:begin
					en_key_cnt <= 0;
					en_key_ascii <= 0;
					en_key_code <= 0;
					led_alt <= 0;
					led_ctrl <= 0;
					led_shift <= 0;
					
				end

				default:begin
					en_key_cnt <= 1;
					en_key_ascii <= 1;
					en_key_code <= 1;
					led_alt <= 0;
					led_ctrl <= 0;
					led_shift <= 0;
				end
			endcase
		end
	end

    reg [15:0] code_table [255:0];
    initial begin
        $readmemh("resource/table.hex", code_table);
    end

	reg [7:0] ascii_fifo [7:0];
	reg [2:0] r_ptr, w_ptr;
	reg ascii_ready;
	wire ascii_read_next;
	wire shift_push = (data_buffer[1] == `KEY_LSHIFT) || (data_buffer[1] == `KEY_RSHIFT);
    wire [15:0] ascii_code = code_table[data_buffer[0]];
	always @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			r_ptr <= 0;
			w_ptr <= 0;
			ascii_ready <= 0;
		end else begin
			if (ascii_ready) begin
				if(ascii_read_next == 1'b1) //read next data
                begin
                    r_ptr <= r_ptr + 3'b1;
                    if(w_ptr==(r_ptr+1'b1)) //empty
                        ascii_ready <= 1'b0;
                end
			end
			if (read_next == 1'b1) begin
				if (CS==SINGLE) begin
					if (data_buffer[1] == 8'hE0) begin
						if ({data_buffer[1],data_buffer[0]} == `KEY_UP) begin
							ascii_fifo[w_ptr] <= `ASCII_KEY_UP;
							$display("↑");
							w_ptr <= w_ptr+3'b1;
							ascii_ready <= 1'b1;
						end
						if ({data_buffer[1],data_buffer[0]} == `KEY_DOWN) begin
							ascii_fifo[w_ptr] <= `ASCII_KEY_DOWN;
							$display("↓");
							w_ptr <= w_ptr+3'b1;
							ascii_ready <= 1'b1;
						end
						if ({data_buffer[1],data_buffer[0]} == `KEY_LEFT) begin
							ascii_fifo[w_ptr] <= `ASCII_KEY_LEFT;
							$display("←");
							w_ptr <= w_ptr+3'b1;
							ascii_ready <= 1'b1;
						end
						if ({data_buffer[1],data_buffer[0]} == `KEY_RIGHT) begin
							ascii_fifo[w_ptr] <= `ASCII_KEY_RIGHT;
							$display("→");
							w_ptr <= w_ptr+3'b1;
							ascii_ready <= 1'b1;
						end
					// 	if ({data_buffer[1],data_buffer[0]} == `KEY_RALT) ascii_fifo[w_ptr] <= 0;//not write
					// 	if ({data_buffer[1],data_buffer[0]} == `KEY_RCTRL) ascii_fifo[w_ptr] <= 0;//not write
					// end else begin
					// 	if(data_buffer[0] == `KEY_LALT) ascii_fifo[w_ptr] <= 0;//not write
					// 	if(data_buffer[0] == `KEY_LCTRL) ascii_fifo[w_ptr] <= 0;//not write
					// 	if(data_buffer[0] == `KEY_LSHIFT) ascii_fifo[w_ptr] <= 0;//not write
					// 	if(data_buffer[0] == `KEY_RSHIFT) ascii_fifo[w_ptr] <= 0;//not write
					end else if(data_buffer[0] != `KEY_LALT &&
								data_buffer[0] != `KEY_LCTRL &&
								data_buffer[0] != `KEY_LSHIFT &&
								data_buffer[0] != `KEY_RSHIFT) begin
						ascii_fifo[w_ptr] <=  ascii_code[15:8];
						$display("%c",ascii_fifo[w_ptr]);
                    	w_ptr <= w_ptr+3'b1;
                    	ascii_ready <= 1'b1;
					end
				end else if (CS==MULTIPLE)begin
					ascii_fifo[w_ptr] <= shift_push ? ascii_code[7:0] : ascii_code[15:8];
					$display("%c",ascii_fifo[w_ptr]);
					w_ptr <= w_ptr+3'b1;
					ascii_ready <= 1'b1;
				end
			end
		end
	end

	ps2key i0(
	.clk(clk),
	.rstn(rstn),
	.ps2_clk(ps2_clk),
	.ps2_dat(ps2_dat),
	.read_next(read_next),
	.ready(ready),
	.overflow(overflow),
	.data(data)
	);

	num2seg i1(
		.en(en_key_cnt),
		.num(key_cnt),
		.seg(seg_cnt)
	);
	num2seg i2(
		.en(en_key_ascii),
		.num(key_ascii),
		.seg(seg_ascii)
	);
	num2seg i3(
		.en(en_key_code),
		.num(key_code),
		.seg(seg_code)
	);

	assign seg_close = 16'hFFFF;
endmodule //keyboard