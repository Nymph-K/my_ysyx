/*************************************************************
 * @ name           : pcu.v
 * @ description    : Program Counter Unit
 * @ use module     : Reg, MuxKeyWithDefault
 * @ author         : K
 * @ date modified  : 2023-3-10
*************************************************************/
`ifndef PCU_V
`define PCU_V

`include "common.v"

module pcu (
	input  clk,
	input  rst,
    input  pc_src1,
	input  pc_src2,
	input  inst_sys_jump,
	input  inst_jalr,
	input  [`XLEN-1:0] x_rs1,
	input  [`XLEN-1:0] imm,
	input  [`XLEN-1:0] csr_r_data,
	input  execute_over,
	`ifdef CLINT_ENABLE
		input  interrupt,
		input  [`XLEN-1:0] csr_mtvec,
	`endif
	output [`XLEN-1:0] pc,
	output [`XLEN-1:0] dnpc
);

	Reg #(`XLEN, `START_ADDR) u_pc (
		.clk(clk), 
		.rst(rst), 
		.din(dnpc), 
		.dout(pc), 
		.wen(execute_over)
	);

	wire [`XLEN-1:0] npc_base, npc_offs, npc_sum, npc;
	assign npc_sum = npc_base + npc_offs;
		
	assign npc_base = (pc_src1 == `PC_SRC1_PC) ? pc : x_rs1;
	assign npc_offs = (pc_src2 == `PC_SRC2_4) ? `XLEN'd4 : imm;
	assign npc_sum = npc_base + npc_offs;
	assign npc = inst_sys_jump ? csr_r_data : 
					(inst_jalr ? {npc_sum[`XLEN-1:1], 1'b0} : npc_sum);

	`ifdef CLINT_ENABLE
		assign dnpc = interrupt ? csr_mtvec : npc;
	`else
		assign dnpc = npc;
	`endif

endmodule //pcu

`endif