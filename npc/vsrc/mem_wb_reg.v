module mem_wb_reg (
	input           clk                     ,
	input           rst                     ,
    input           in_valid                ,
    input  [31:0]   in_pc                   ,
    input  [31:0]   in_inst                 ,
    input  [ 4:0]   in_rs1                  ,
    input  [ 4:0]   in_rs2                  ,
    input  [63:0]   in_x_rs2                ,
    input  [63:0]   in_x_rd                 ,
    input  [ 4:0]   in_rd                   ,
    input           in_rd_idx_0             ,
    input           in_rd_w_en              ,
    input           in_rd_w_src_exu         ,
    input           in_rd_w_src_mem         ,
    input           in_rd_w_src_csr         ,
    input           in_csr_w_en             ,
    input  [11:0]   in_csr_addr             ,
    input  [63:0]   in_csr_r_data           ,
    input  [63:0]   in_exu_result           ,
    input  [63:0]   in_lsu_r_data           ,
    input           in_inst_system_ebreak   ,

    output          out_valid               ,
    output          out_ready               ,
    output [31:0]   out_pc                  ,
    output [31:0]   out_inst                ,
    output [ 4:0]   out_rs1                 ,
    output [ 4:0]   out_rs2                 ,
    output [63:0]   out_x_rs2               ,
    output [63:0]   out_x_rd                ,
    output [ 4:0]   out_rd                  ,
    output          out_rd_idx_0            ,
    output          out_rd_w_en             ,
    output          out_rd_w_src_exu        ,
    output          out_rd_w_src_mem        ,
    output          out_rd_w_src_csr        ,
    output          out_csr_w_en            ,
    output [11:0]   out_csr_addr            ,
    output [63:0]   out_csr_r_data          ,
    output [63:0]   out_exu_result          ,
    output [63:0]   out_lsu_r_data          ,
    output          out_inst_system_ebreak   
);
    assign out_ready = 1;
    wire wen = in_valid;
    wire ctrl_flush = rst | ~in_valid;

    Reg #(1, 1'b0) u_mem_wb_valid (
        .clk(clk), 
        .rst(rst), 
        .din(in_valid), 
        .dout(out_valid), 
        .wen(1)
    );

    Reg #(32, 'b0) u_mem_wb_pc (
        .clk(clk), 
        .rst(rst), 
        .din(in_pc), 
        .dout(out_pc), 
        .wen(wen)
    );

    Reg #(32, 'b0) u_mem_wb_inst (
        .clk(clk), 
        .rst(rst), 
        .din(in_inst), 
        .dout(out_inst), 
        .wen(wen)
    );


    Reg #(5, 'b0) u_mem_wb_rs1 (
        .clk(clk), 
        .rst(rst), 
        .din(in_rs1), 
        .dout(out_rs1), 
        .wen(wen)
    );

    Reg #(5, 'b0) u_mem_wb_rs2 (
        .clk(clk), 
        .rst(rst), 
        .din(in_rs2), 
        .dout(out_rs2), 
        .wen(wen)
    );

    Reg #(64, 'b0) u_mem_wb_x_rs2 (
        .clk(clk), 
        .rst(rst), 
        .din(in_x_rs2), 
        .dout(out_x_rs2), 
        .wen(wen)
    );

    Reg #(64, 'b0) u_mem_wb_x_rd (
        .clk(clk), 
        .rst(rst), 
        .din(in_x_rd), 
        .dout(out_x_rd), 
        .wen(wen)
    );

    Reg #(5, 5'b0) u_mem_wb_rd (
        .clk(clk), 
        .rst(rst), 
        .din(in_rd), 
        .dout(out_rd), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_mem_wb_rd_idx_0 (
        .clk(clk), 
        .rst(rst), 
        .din(in_rd_idx_0), 
        .dout(out_rd_idx_0), 
        .wen(wen)
    );

    Reg #(1, 1'b0) u_mem_wb_rd_w_en (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_rd_w_en), 
        .dout(out_rd_w_en), 
        .wen(wen)
    );

    Reg #(1, 1'b0) u_mem_wb_rd_w_src_exu (
        .clk(clk), 
        .rst(rst), 
        .din(in_rd_w_src_exu), 
        .dout(out_rd_w_src_exu), 
        .wen(wen)
    );

    Reg #(1, 1'b0) u_mem_wb_rd_w_src_mem (
        .clk(clk), 
        .rst(rst), 
        .din(in_rd_w_src_mem), 
        .dout(out_rd_w_src_mem), 
        .wen(wen)
    );

    Reg #(1, 1'b0) u_mem_wb_rd_w_src_csr (
        .clk(clk), 
        .rst(rst), 
        .din(in_rd_w_src_csr), 
        .dout(out_rd_w_src_csr), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_mem_wb_csr_w_en (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_csr_w_en), 
        .dout(out_csr_w_en), 
        .wen(wen)
    );
    
    Reg #(12, 'b0) u_mem_wb_csr_addr (
        .clk(clk), 
        .rst(rst), 
        .din(in_csr_addr), 
        .dout(out_csr_addr), 
        .wen(wen)
    );
    
    Reg #(64, 'b0) u_mem_wb_csr_r_data (
        .clk(clk), 
        .rst(rst), 
        .din(in_csr_r_data), 
        .dout(out_csr_r_data), 
        .wen(wen)
    );
    
    Reg #(64, 'b0) u_mem_wb_exu_result (
        .clk(clk), 
        .rst(rst), 
        .din(in_exu_result), 
        .dout(out_exu_result), 
        .wen(wen)
    );
    
    Reg #(64, 'b0) u_mem_wb_lsu_r_data (
        .clk(clk), 
        .rst(rst), 
        .din(in_lsu_r_data), 
        .dout(out_lsu_r_data), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_mem_wb_inst_system_ebreak (
        .clk(clk), 
        .rst(rst), 
        .din(in_inst_system_ebreak), 
        .dout(out_inst_system_ebreak), 
        .wen(wen)
    );




endmodule //mem_wb_reg