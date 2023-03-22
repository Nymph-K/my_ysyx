/*************************************************************
 * @ name           : gpr.v
 * @ description    : General Purpose Register
 * @ use module     : Reg
 * @ author         : K
 * @ chnge date     : 2023-3-10
*************************************************************/
`ifndef GPR_V
`define GPR_V

`include "common.v"

module gpr (
	input  clk,
	input  rst,
	input  [4:0] rs1,
	input  [4:0] rs2,
	input  [4:0] rd,
	input  rd_w_en,
	input  [`XLEN-1:0] x_rd,
	output [`XLEN-1:0] x_rs1,
	output [`XLEN-1:0] x_rs2
);
	wire [`XLEN-1:0] gpr[31:0];

	assign x_rs1 = gpr[rs1];
	assign x_rs2 = gpr[rs2];

	generate
		for (genvar n = 0; n < 32; n = n + 1) begin: gir_gen
			if (n == 0)
				Reg #(`XLEN, `XLEN'b0) u_gir (
					.clk(clk), 
					.rst(rst), 
					.din(`XLEN'b0), 
					.dout(gpr[n]), 
					.wen((rd_w_en == 1'b1 && rd == n) ? 1'b1 : 1'b0));
			else
				Reg #(`XLEN, `XLEN'b0) u_gir (
					.clk(clk), 
					.rst(rst), 
					.din(x_rd), 
					.dout(gpr[n]), 
					.wen((rd_w_en == 1'b1 && rd == n) ? 1'b1 : 1'b0));
		end
	endgenerate

`ifdef DPI_C_SET_GPR_PTR
import "DPI-C" function void set_gpr_ptr(input logic [63:0] gpr []);
	initial set_gpr_ptr(gpr);  // gir为通用寄存器的二维数组变量
`endif

endmodule //gpr

`endif /* GPR_V */