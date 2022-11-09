module ps2key (
	input clk,
	input rstn,
	input ps2_clk,
	input ps2_dat,
	input read_next,
	output reg ready,
	output reg overflow,
	output [7:0] data
);

	reg [2:0] ps2_clk_sync;
	reg [9:0] buffer;
	wire sampling;
	reg [3:0] cnt;
	reg [7:0] fifo [7:0];
	reg [2:0] r_ptr, w_ptr;

    always @(posedge clk) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (rstn == 0) begin // reset
            cnt <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready<= 0;
        end
        else begin
            if ( ready ) begin // read to output next data
                if(read_next == 1'b1) //read next data
                begin
                    r_ptr <= r_ptr + 3'b1;
                    if(w_ptr==(r_ptr+1'b1)) //empty
                        ready <= 1'b0;
                end
            end
            if (sampling) begin
              if (cnt == 4'd10) begin
                if ((buffer[0] == 0) &&  // start bit
                    (ps2_dat)       &&  // stop bit
                    (^buffer[9:1])) begin      // odd  parity
                    fifo[w_ptr] <= buffer[8:1];  // kbd scan code
				    // $display("===================");
                    // $display("%H", buffer[8:1]);
                    w_ptr <= w_ptr+3'b1;
                    ready <= 1'b1;
                    overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
                end
                cnt <= 0;     // for next
              end else begin
                buffer[cnt] <= ps2_dat;  // store ps2_dat
                cnt <= cnt + 3'b1;
              end
            end
        end
    end
    assign data = fifo[r_ptr]; //always set output data



endmodule //ps2key_plus