module keyboard (
	input clk,
	input rst,
	input ps2_clk,
	input ps2_dat,
	output [15:0] seg_cnt,
	output [15:0] seg_ascii,
	output [15:0] seg_code,
	output reg led_shift,
	output reg led_ctrl,
	output reg led_alt
);
	wire rstn = ~rst;
	reg read_next;
	reg [7:0] data_buffer [2:0];
	wire ready;
	wire overflow;
	wire [7:0] data;

	reg en_key_cnt, en_key_ascii, en_key_code;
	reg [7:0] key_cnt;
	reg [7:0] key_ascii;//waste time! to be solved
	reg [7:0] key_code;

	reg [2: 0] CS, NS;
	parameter [2:0] //one hot
		ERROR = 3'b000,
		IDLE = 3'b001,
		SINGLE = 3'b010,
		MULTIPLE = 3'b100;

	parameter [7:0] //KEY_CODE
		KEY_SHIFT = 8'h12,
		KEY_CTRL = 8'h14,
		KEY_ALT = 8'h11;

	always @(posedge clk or negedge rstn) begin
		if(~rstn)
			CS <= IDLE;
		else 
			CS <= NS;
			if(CS != NS)
				$display("cs=%d\tNS=%d",CS, NS);
	end

	always @(*) begin
		NS = 3'bxxx;
		case (CS)
			IDLE:begin
				if (ready == 1'b1 && data != 8'hF0) NS = SINGLE;	//push one key
				else NS = IDLE;
			end

			SINGLE:begin
				if (ready == 1'b1) begin
					if (data != data_buffer[0]) begin	//push other key
						if (data != 8'hF0) begin	//is not release the key
							if(data_buffer[0] != 8'hF0) NS = MULTIPLE;
							else NS = IDLE;
						end
						else NS = SINGLE;
					end
					else NS = SINGLE;
				end
				else NS = SINGLE;
			end

			MULTIPLE:begin
				if (ready == 1'b1) begin
					if (data_buffer[0] == 8'hF0) begin
						if( data == data_buffer[2] || data == data_buffer[1])
							NS = SINGLE;	//release a key
						else NS = ERROR;
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
			read_next <= 0;
			data_buffer[0] <= 0;
			data_buffer[1] <= 0;
			data_buffer[2] <= 0;
		end else begin
			read_next <= ready;
			if (ready == 1) begin
				case (CS)
					IDLE:begin
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
							if (data == data_buffer[1]) begin
								{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data_buffer[2]};//release second key
							end else if (data == data_buffer[2]) begin
								{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data_buffer[1]};//release first key
							end else
								{data_buffer[2], data_buffer[1], data_buffer[0]} <= {data_buffer[1], data_buffer[0], data};
						end
					end

					ERROR:begin
						read_next <= 0;
						data_buffer[0] <= 0;
						data_buffer[1] <= 0;
						data_buffer[2] <= 0;
					end

					default:begin
						read_next <= 0;
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
					key_ascii <= ~data_buffer[0];
					key_code <= data_buffer[0];
					if(data_buffer[0] == KEY_ALT) led_alt <= 1;
					if(data_buffer[0] == KEY_CTRL) led_ctrl <= 1;
					if(data_buffer[0] == KEY_SHIFT) led_shift <= 1;
				end

				MULTIPLE:begin
					en_key_cnt <= 1;
					en_key_ascii <= 1;
					en_key_code <= 1;
					if (data_buffer[1] == KEY_SHIFT) begin//waste time!
						key_code <= data_buffer[0] + 1;
						key_ascii <= ~(data_buffer[0] + 1);
					end else begin
						key_code <= data_buffer[0];
						key_ascii <= ~data_buffer[0];
					end
					if(data_buffer[0] == KEY_ALT) led_alt <= 1;
					if(data_buffer[0] == KEY_CTRL) led_ctrl <= 1;
					if(data_buffer[0] == KEY_SHIFT) led_shift <= 1;
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

endmodule //keyboard