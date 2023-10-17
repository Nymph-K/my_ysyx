/*************************************************************
 * @ name           : gpr.v
 * @ description    : General Purpose Register
 * @ use module     : Reg
 * @ author         : K
 * @ date modified  : 2023-3-10
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
	input  rd_idx_0,
	input  [63:0] x_rd,
	output [63:0] x_rs1,
	output [63:0] x_rs2
);
	wire [63:0] gpr[31:0];
	wire [31:0] gpr_w_en;

	assign gpr[0] = 0;
	assign x_rs1 = (rs1 == rd & ~rd_idx_0 & rd_w_en) ? x_rd : gpr[rs1];
	assign x_rs2 = (rs2 == rd & ~rd_idx_0 & rd_w_en) ? x_rd : gpr[rs2];

	assign gpr_w_en = {32{rd_w_en}} & (1 << rd);

	generate
		for (genvar n = 1; n < 32; n = n + 1) begin: gir_gen
				Reg #(64, 64'b0) u_gir (
					.clk(clk), 
					.rst(rst), 
					.din(x_rd), 
					.dout(gpr[n]), 
					.wen(gpr_w_en[n])
				);
		end
	endgenerate

`ifdef DPI_C_SET_GPR_PTR
import "DPI-C" function void set_gpr_ptr(input logic [63:0] gpr []);
	initial set_gpr_ptr(gpr);  // gir为通用寄存器的二维数组变量
`endif

endmodule //gpr

`endif /* GPR_V */
