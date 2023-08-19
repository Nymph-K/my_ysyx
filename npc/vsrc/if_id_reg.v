module if_id_reg (
	input           clk,
	input           rst,
    input           if_id_stall,
    input           pc_b_j,
    input           in_valid,
    input           in_ready,
	input  [31:0]   in_pc,
	input  [31:0]   in_inst,
    output          out_valid,
    output          out_ready,
	output [31:0]   out_pc,
	output [31:0]   out_inst
);

    wire stall = (~in_ready && out_valid) || if_id_stall;
    wire wen = in_valid && ~stall;
    wire ctrl_flush = rst || ((pc_b_j || ~in_valid) && ~stall);    // if branch or jump, not regist pre-inst
    assign out_ready = wen;
    
    Reg #(1, 1'b0) u_if_id_valid (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_valid),
        .dout(out_valid), 
        .wen(wen)
    );

    Reg #(32, 32'b0) u_if_id_pc (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_pc), 
        .dout(out_pc), 
        .wen(wen)
    );
    
    Reg #(32, 32'b0) u_if_id_inst (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_inst), 
        .dout(out_inst), 
        .wen(wen)
    );


endmodule //if_id_reg
