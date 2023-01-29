//fast multiplier

`ifndef FAST_MUL_V
`define FAST_MUL_V

`include "top.v"


module fast_multiplier (
	input  [`XLEN-1:0] a,
	input  [`XLEN-1:0] b,
	output [`DXLEN-1:0] out
);
    wire [`DXLEN-1:0] muln [63:0];
    wire [`DXLEN-1:0] store1 [31:0];
    wire [`DXLEN-1:0] store2 [15:0];
    wire [`DXLEN-1:0] store3 [7:0];
    wire [`DXLEN-1:0] store4 [3:0];
    wire [`DXLEN-1:0] store5 [1:0];

	generate
		for (genvar n = 0; n < 64; n = n + 1) begin: muln_gen
			assign muln[n] = (b[n] == 1'b1) ? {{(64-n){1'b0}}, a, {n{1'b0}}} : `DXLEN'b0;
		end

		for (genvar n = 0; n < 32; n = n + 1) begin: store1_gen
			assign store1[n] = muln[2*n] + muln[2*n + 1];
		end

		for (genvar n = 0; n < 16; n = n + 1) begin: store2_gen
			assign store2[n] = store1[2*n] + store1[2*n + 1];
		end

		for (genvar n = 0; n < 8; n = n + 1) begin: store3_gen
			assign store3[n] = store2[2*n] + store2[2*n + 1];
		end

		for (genvar n = 0; n < 4; n = n + 1) begin: store4_gen
			assign store4[n] = store3[2*n] + store3[2*n + 1];
		end

		for (genvar n = 0; n < 2; n = n + 1) begin: store5_gen
			assign store5[n] = store4[2*n] + store4[2*n + 1];
		end
	endgenerate

    assign out = store5[0] + store5[1];

endmodule //FAST_MUL_V

`endif