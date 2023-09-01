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
    input  if_busy,
    input  [31:0] dnpc,
    output [31:0] pc,
    input       inst_r_valid,
    output reg  inst_r_ready
);

    wire pc_wen = if_id_handshake | pc_b_j;

    Reg #(32, 32'h80000000) u_pc (
        .clk(clk), 
        .rst(rst), 
        .din(npc), 
        .dout(pc), 
        .wen(pc_wen)
    );

    wire [31:0] npc = pc_b_j ? dnpc : pc + 4;

    reg  discard_inst;
    reg  wait_valid;

    always @(posedge clk) begin
        if(rst) begin
            inst_r_ready <= 'b1;
            discard_inst <= 'b0;
            wait_valid   <= 'b0;
        end else begin
            if (discard_inst & wait_valid) begin // if discard inst & wait valid
                if(inst_r_valid) begin // wait pre-inst fetch over
                    inst_r_ready <= 'b1; // fetch inst
                    discard_inst <= 'b0;
                    wait_valid   <= 'b0;
                end
            end else begin // else not discard inst
                if(inst_r_ready) begin // if fetching inst
                    if(pc_b_j) begin // if branch or jump, discard inst
                        if(wait_valid | ~if_busy) begin // if wait valid
                            inst_r_ready <= 'b0;
                            discard_inst <= 'b1;
                        end
                        wait_valid   <= wait_valid | ~if_busy; // if idle, wait valid
                    end else if(inst_r_valid) begin // fetch over
                        inst_r_ready <= pc_wen; // if pc update, fetch inst
                        discard_inst <= 'b0;
                        wait_valid   <= 'b0;
                    end else begin
                        wait_valid   <= wait_valid | ~if_busy; // if idle, wait valid
                    end
                end else begin // else not fetching inst
                    inst_r_ready <= pc_wen;// if pc update, fetch inst
                end
            end

        end
    end

endmodule //pcu

`endif

