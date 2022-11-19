//general integer register

`ifndef GIR_V
`define GIR_V

`include "top.v"

module GIR (
	input  clk,
	input  rst,
	input  [4:0] rs1,
	input  [4:0] rs2,
	input  [4:0] rd,
	input  rd_wen,
	input  [`XLEN-1:0] x_rd,
	output [`XLEN-1:0] x_rs1,
	output [`XLEN-1:0] x_rs2,
	input  [`XLEN-1:0] dnpc,
	output [`XLEN-1:0] pc
);
	wire [`XLEN-1:0] gir[31:0];

	assign x_rs1 = gir[rs1];
	assign x_rs2 = gir[rs2];

	generate
		for (genvar n = 0; n < 32; n = n + 1) begin: gir_gen
			if (n == 0)
				Reg #(`XLEN, `XLEN'b0) u_gir (
					.clk(clk), 
					.rst(rst), 
					.din(0), 
					.dout(gir[n]), 
					.wen((rd_wen == 1'b1 && rd == n) ? 1'b1 : 1'b0));
			else
				Reg #(`XLEN, `XLEN'b0) u_gir (
					.clk(clk), 
					.rst(rst), 
					.din(x_rd), 
					.dout(gir[n]), 
					.wen((rd_wen == 1'b1 && rd == n) ? 1'b1 : 1'b0));
		end
	endgenerate

	Reg #(`XLEN, `START_ADDR) u_pc (
		.clk(clk), 
		.rst(rst), 
		.din(dnpc), 
		.dout(pc), 
		.wen(1'b1));

	

endmodule //GIR

`endif /* GIR_V */