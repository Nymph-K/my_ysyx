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
    input  if_idle,
    input           if_id_stall,
    input           if_id_ready,
    input  [31:0] dnpc,
    output [31:0] pc,
    input       inst_r_valid,
    output      inst_r_ready
);

    wire        pc_wen;
    reg [31:0]  pc_;
    
    assign pc_wen = (if_id_ready & ~if_id_stall);
    assign pc = pc_b_j ? dnpc : pc_;//
    assign inst_r_ready = 1;

    always @(posedge clk) begin
        if(rst)
            pc_             <= 32'h80000000;
        else begin
            if(pc_wen) begin
                pc_             <= pc + 4; 
            end
        end
    end

    
endmodule //pcu

`endif

