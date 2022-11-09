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
	wire read_next = 1'b1;
	reg [7:0] data_buffer [3:0];
	wire ready;
	reg	ready_delay;
	wire overflow;
	wire [7:0] data;

	reg en_key_cnt, en_key_ascii, en_key_code;
	reg [7:0] key_cnt;
	reg [7:0] key_ascii;
	reg [7:0] key_code;

	reg [5: 0] CS, NS;
	parameter [5:0] //one hot
		ERROR = 	6'b000000,
		IDLE = 		6'b000001,
		ARROW = 	6'b000010,
		RELEASE = 	6'b000100,
		SINGLE = 	6'b001000,
		MULTIPLE = 	6'b010000,
		MUL_RLS = 	6'b100000;

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
			// if(NS != CS) begin
			// 	case (CS)
			// 		ERROR:	 $write("CS = ERROR\t");
			// 		IDLE:	 $write("CS = IDLE\t");
			// 		ARROW:	 $write("CS = ARROW\t");
			// 		RELEASE: $write("CS = RELEASE\t");
			// 		SINGLE:  $write("CS = SINGLE\t");
			// 		MULTIPLE:$write("CS = MULTIPLE\t");
			// 		default: $write("default\t");
			// 	endcase
			// 	case (NS)
			// 		ERROR:	 $write("NS = ERROR\t");
			// 		IDLE:	 $write("NS = IDLE\t");
			// 		ARROW:	 $write("NS = ARROW\t");
			// 		RELEASE: $write("NS = RELEASE\t");
			// 		SINGLE:  $write("NS = SINGLE\t");
			// 		MULTIPLE:$write("NS = MULTIPLE\t");
			// 		default: $write("default\t");
			// 	endcase
			// 	$display("buff = %H %H %H < %H", data_buffer[2], data_buffer[1], data_buffer[0], data);
			// 	$display("w_ptr = %d, ascii_ready = %b, ascii = %c", w_ptr, ascii_ready, ascii_fifo[w_ptr]);
			// end
	end

	always @(*) begin
		NS = 6'bxxx;
		case (CS)
			IDLE:begin
				if (ready)
					if (data == 8'hE0) NS = ARROW;	//push arrow key
					else NS = SINGLE;//push other key
				else NS = IDLE;
			end

			ARROW:begin
				if (ready) begin
					if (data == 8'hF0) NS = RELEASE;		//release arrow key
					else begin
						if (data == 8'h75 || data == 8'h72 || data == 8'h6B || data == 8'h74) NS = SINGLE;	//push arrow key
						else NS = IDLE;
					end
				end
				else NS = ARROW;
			end

			RELEASE:begin
				if (ready) begin
					if (data_buffer[1] == 8'hE0 && data == data_buffer[2]) begin		//release arrow key
						NS = IDLE;
					end else if (data == data_buffer[1]) begin		//release normal key
						NS = IDLE;
					end else NS = RELEASE;
				end else begin
					NS = RELEASE;
				end
			end

			SINGLE:begin
				if (ready) begin
					if (data != data_buffer[0]) begin	//push other key, prevent long push
						if (data != 8'hF0) begin
							if(data == 8'hE0) NS = ARROW;
							else NS = MULTIPLE;//push other key
						end
						else NS = RELEASE;
					end
					else NS = SINGLE;
				end
				else NS = SINGLE;
			end

			MULTIPLE:begin
				if (ready) begin
					if (data == 8'hF0) NS = MUL_RLS;
					else NS = MULTIPLE;
				end
				else NS = MULTIPLE;
			end
			
			MUL_RLS:begin
				if (ready) begin
					if (data == data_buffer[1] || data == data_buffer[2]) NS = SINGLE;
					else NS = MULTIPLE;
				end
				else NS = MUL_RLS;
			end

			ERROR: NS = IDLE;

			default:begin
				NS = IDLE;
			end
		endcase
	end

	always @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			ready_delay <= 0;
			data_buffer[0] <= 0;
			data_buffer[1] <= 0;
			data_buffer[2] <= 0;
		end else begin
			ready_delay <= ready;
			if (ready == 1'b1) begin
				case (CS)
					IDLE:begin
						//if (data != data_buffer[0]) begin	//prevent long push
							{data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[2], data_buffer[1], data_buffer[0], data};
						//end
					end

					ARROW:begin
						if (data != data_buffer[0]) begin	//prevent long push
							{data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[2], data_buffer[1], data_buffer[0], data};
						end
					end

					RELEASE:begin
						if (data != data_buffer[0]) begin	//prevent long push
							{data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[2], data_buffer[1], data_buffer[0], data};
						end
					end

					SINGLE:begin
						if (data != data_buffer[0]) begin	//prevent long push
							{data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[2], data_buffer[1], data_buffer[0], data};
						end
					end

					MULTIPLE:begin
						if (data != data_buffer[0]) begin	//prevent long push
							{data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[2], data_buffer[1], data_buffer[0], data};
						end
					end

					MUL_RLS:begin
						if (data != data_buffer[0]) begin	//prevent long push
							if (data == data_buffer[1]) begin
								{data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data_buffer[3], data_buffer[2]};//release second key
							end else if (data == data_buffer[2]) begin
								{data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[2], data_buffer[0], data_buffer[3], data_buffer[1]};//release first key
							end else begin
								{data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[3], data_buffer[0], data_buffer[2], data_buffer[1]};//release third key
							end
						end
					end

					ERROR:begin
						data_buffer[0] <= 0;
						data_buffer[1] <= 0;
						data_buffer[2] <= 0;
					end

					default:begin
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
				
				ARROW:begin
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
				
				RELEASE:begin
					en_key_cnt <= 1;
					en_key_ascii <= 0;
					en_key_code <= 0;
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
				
				MUL_RLS:begin
					en_key_cnt <= 1;
					en_key_ascii <= 0;
					en_key_code <= 0;
					key_ascii <= 0;
					key_code <= 0;
					led_alt <= 0;
					led_ctrl <= 0;
					led_shift <= 0;
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
			if (ready_delay) begin
				if (CS==SINGLE) begin
					if (data_buffer[1] == 8'hE0) begin
						if ({data_buffer[1],data_buffer[0]} == `KEY_UP) begin
							ascii_fifo[w_ptr] <= `ASCII_KEY_UP;
							$display("KEY = ↑");
							w_ptr <= w_ptr+3'b1;
							ascii_ready <= 1'b1;
						end
						if ({data_buffer[1],data_buffer[0]} == `KEY_DOWN) begin
							ascii_fifo[w_ptr] <= `ASCII_KEY_DOWN;
							$display("KEY = ↓");
							w_ptr <= w_ptr+3'b1;
							ascii_ready <= 1'b1;
						end
						if ({data_buffer[1],data_buffer[0]} == `KEY_LEFT) begin
							ascii_fifo[w_ptr] <= `ASCII_KEY_LEFT;
							$display("KEY = ←");
							w_ptr <= w_ptr+3'b1;
							ascii_ready <= 1'b1;
						end
						if ({data_buffer[1],data_buffer[0]} == `KEY_RIGHT) begin
							ascii_fifo[w_ptr] <= `ASCII_KEY_RIGHT;
							$display("KEY = →");
							w_ptr <= w_ptr+3'b1;
							ascii_ready <= 1'b1;
						end
					end else if(data_buffer[0] != `KEY_LALT &&
								data_buffer[0] != `KEY_LCTRL &&
								data_buffer[0] != `KEY_LSHIFT &&
								data_buffer[0] != `KEY_RSHIFT &&
								data_buffer[0] != 8'hE0) begin
						ascii_fifo[w_ptr] <=  ascii_code[15:8];
						$display("KEY = %c", ascii_code[15:8]);
                    	w_ptr <= w_ptr+3'b1;
                    	ascii_ready <= 1'b1;
					end
				end else if (CS==MULTIPLE)begin
					ascii_fifo[w_ptr] <= shift_push ? ascii_code[7:0] : ascii_code[15:8];
					$display("KEY = %c", shift_push ? ascii_code[7:0] : ascii_code[15:8]);
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