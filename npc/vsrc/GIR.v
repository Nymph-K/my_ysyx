//general integer register

`ifndef GIR_V
`define GIR_V

`include "top.v"

module GIR (
	input  clk,
	input  rst,
	input  [4:0] rd1_index,
	input  [4:0] rd2_index,
	input  [4:0] wt_index,
	input  wen,
	input  [`XLEN-1:0] wdata,
	output [`XLEN-1:0] rdata1,
	output [`XLEN-1:0] rdata2,
	input  [`XLEN-1:0] dnpc,
	output [`XLEN-1:0] pc
);
	wire [`XLEN-1:0] gir[31:0];

	assign rdata1 = gir[rd1_index];
	assign rdata2 = gir[rd2_index];

	generate
		for (genvar n = 0; n < 32; n = n + 1) begin: gir_gen
			if (n == 0)
				Reg #(`XLEN, `XLEN'b0) i_gir (
					.clk(clk), 
					.rst(rst), 
					.din(0), 
					.dout(gir[n]), 
					.wen( wen == 1'b1 && wt_index == n ));
			else
				Reg #(`XLEN, `XLEN'b0) i_gir (
					.clk(clk), 
					.rst(rst), 
					.din(wdata), 
					.dout(gir[n]), 
					.wen( wen == 1'b1 && wt_index == n ));
		end
	endgenerate

	Reg #(`XLEN, `START_ADDR) i_pc (
		.clk(clk), 
		.rst(rst), 
		.din(dnpc), 
		.dout(pc), 
		.wen(1'b1));

	

endmodule //GIR

`endif /* GIR_V */