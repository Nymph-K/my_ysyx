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
    input  if_busy,
    input           if_id_stall,
    input           if_id_ready,
    input  [31:0] dnpc,
    output [31:0] pc,
    input       inst_r_valid,
    output      inst_r_ready
);

    wire pc_wen = (inst_r_ready && ~if_busy && ~if_id_stall && if_id_ready) || pc_b_j;
    reg [31:0] pc_;
    
    assign inst_r_ready = 1'b1;// & ~pc_b_j;
    assign pc = pc_b_j ? dnpc : pc_;//

    always @(posedge clk) begin
        if(rst)
            pc_ <= 32'h80000000;
        else begin
            if(pc_wen) 
                pc_ <= pc + 4; 
        end
    end
    
endmodule //pcu

`endif

