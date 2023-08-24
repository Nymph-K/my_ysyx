/*************************************************************
 * @ name           : pcu.v
 * @ description    : Program Counter Unit
 * @ use module     : Reg, MuxKeyWithDefault
 * @ author         : K
 * @ date modified  : 2023-7-28
*************************************************************/
`ifndef PCU_V
`define PCU_V

`include "common.v"

module pcu (
    input  clk,
    input  rst,
    input  pc_b_j,	// 0: pc+4      1: dnpc
    input  if_id_handshake,
    input  [31:0] dnpc,
    output [31:0] pc
);

    Reg #(32, 32'h80000000) u_pc (
        .clk(clk), 
        .rst(rst), 
        .din(npc), 
        .dout(pc), 
        .wen(if_id_handshake | pc_b_j)
    );

    wire [31:0] npc = pc_b_j ? dnpc : pc + 4;

endmodule //pcu

`endif
