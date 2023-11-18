/*************************************************************
 * @ name           : gpr.v
 * @ description    : General Purpose Register
 * @ use module     : 
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
	reg [63:0] gpr[31:0];

	assign x_rs1 = (rs1 == rd & ~rd_idx_0 & rd_w_en) ? x_rd : gpr[rs1];
	assign x_rs2 = (rs2 == rd & ~rd_idx_0 & rd_w_en) ? x_rd : gpr[rs2];
	
    always @(posedge clk) begin
        if (rst) begin
            gpr[ 0]         <= 0;
            gpr[ 1]         <= 0;
            gpr[ 2]         <= 0;
            gpr[ 3]         <= 0;
            gpr[ 4]         <= 0;
            gpr[ 5]         <= 0;
            gpr[ 6]         <= 0;
            gpr[ 7]         <= 0;
            gpr[ 8]         <= 0;
            gpr[ 9]         <= 0;
            gpr[10]         <= 0;
            gpr[11]         <= 0;
            gpr[12]         <= 0;
            gpr[13]         <= 0;
            gpr[14]         <= 0;
            gpr[15]         <= 0;
            gpr[16]         <= 0;
            gpr[17]         <= 0;
            gpr[18]         <= 0;
            gpr[19]         <= 0;
            gpr[20]         <= 0;
            gpr[21]         <= 0;
            gpr[22]         <= 0;
            gpr[23]         <= 0;
            gpr[24]         <= 0;
            gpr[25]         <= 0;
            gpr[26]         <= 0;
            gpr[27]         <= 0;
            gpr[28]         <= 0;
            gpr[29]         <= 0;
            gpr[30]         <= 0;
            gpr[31]         <= 0;
        end else begin
            if(rd_w_en) begin
				gpr[rd]         <= ~rd_idx_0 ? x_rd : 0;
            end
        end
    end

`ifdef DPI_C_SET_GPR_PTR
import "DPI-C" function void set_gpr_ptr(input logic [63:0] gpr []);
	initial set_gpr_ptr(gpr);  // gir为通用寄存器的二维数组变量
`endif

endmodule //gpr

`endif /* GPR_V */
