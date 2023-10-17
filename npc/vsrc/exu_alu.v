/*************************************************************
 * @ name           : exu_alu.v
 * @ description    : Arithmetic Logic Unit
 * @ use module     : MuxKeyWithDefault
 * @ author         : K
 * @ date modified  : 2023-7-30
*************************************************************/
`ifndef EXU_ALU_V
`define EXU_ALU_V

`include "common.v"

module exu_alu (
    input           inst_32         ,
	input  [63:0]   a               ,
	input  [63:0]   b               ,
    input           alu_sel_add_sub ,
    input           alu_sel_sub     ,
    input           alu_sel_slt     ,
    input           alu_sel_sltu    ,
    input           alu_sel_and     ,
    input           alu_sel_or      ,
    input           alu_sel_xor     ,
    input           alu_sel_sll     ,
    input           alu_sel_srl     ,
    input           alu_sel_sra     ,
	output [63:0]   result
);

	wire [63:0] adder_out, cmp_b;
	wire sub, overflow, cout, equal;

	assign sub = alu_sel_sub | alu_sel_slt | alu_sel_sltu;
	assign cmp_b = sub ? ~b : b;
	assign {cout, adder_out} = a + cmp_b + (sub ? 1 : 0);
	assign equal = ~(| adder_out);
	assign overflow = (a[63] == cmp_b[63]) & (a[63] != adder_out[63]);//signed
	wire smaller_s = adder_out[63] ^ overflow;
	wire smaller_u = sub ^ cout;

	wire [63:0] out_srl, out_sra, out_sll;
	assign out_sll = inst_32 ? ({32'b0, a[31:0] << b[4:0]}) : (a << b[5:0]);
	assign out_srl = inst_32 ? ({32'b0, a[31:0]} >> b[4:0]) : (a >> b[5:0]);
	assign out_sra = inst_32 ? ({32'b0, $signed(($signed(a[31:0])) >>> b[4:0])}) : $signed(($signed(a[63:0])) >>> b[5:0]);

    assign result =     alu_sel_add_sub ? adder_out          : 
                        alu_sel_slt     ? {63'b0, smaller_s} : 
                        alu_sel_sltu    ? {63'b0, smaller_u} : 
                        alu_sel_and     ? a & b              : 
                        alu_sel_or      ? a | b              : 
                        alu_sel_xor     ? a ^ b              : 
                        alu_sel_sll     ? out_sll            : 
                        alu_sel_srl     ? out_srl            : 
                        alu_sel_sra     ? out_sra            : 0;

endmodule //EXU_ALU

`endif /* EXU_ALU_V */