module id_ex_reg (
	input           clk                 ,
	input           rst                 ,
    input           if_id_stall         ,
    input           exu_idle            ,

    input           in_valid            ,
    input           in_ready            ,
	input  [31:0]   in_pc               ,
	input  [31:0]   in_inst             ,
    input  [ 2:0]   in_funct3           ,
    input  [ 4:0]   in_rs1              ,
    input  [ 4:0]   in_rs2              ,
	input  [63:0]   in_x_rs2            ,
    input  [ 4:0]   in_rd               ,
    input           in_rd_idx_0         ,
	input 	        in_rd_w_en          ,
	input 	        in_rd_w_src_exu     ,
    input 	        in_rd_w_src_mem     ,
    input 	        in_rd_w_src_csr     ,
    input           in_csr_w_en         ,
    input  [11:0]   in_csr_addr         ,
	input  [63:0]   in_csr_r_data       ,
    input           in_exu_src1_xrs1    ,
    input           in_exu_src2_xrs2    ,
    input           in_exu_src2_csr     ,
	input  [63:0]   in_exu_src1         ,
	input  [63:0]   in_exu_src2         ,
    input           in_exu_sel_add_sub  ,
    input           in_exu_sel_sub      ,
    input           in_exu_sel_slt      ,
    input           in_exu_sel_sltu     ,
    input           in_exu_sel_and      ,
    input           in_exu_sel_or       ,
    input           in_exu_sel_xor      ,
    input           in_exu_sel_sll      ,
    input           in_exu_sel_srl      ,
    input           in_exu_sel_sra      ,
    input           in_mul_valid        ,
    input  [ 1:0]   in_mul_signed       ,
    input           in_mul_res_lo       ,
    input           in_div_valid        ,
    input  [ 1:0]   in_div_signed       ,
    input           in_div_quotient     ,
    input           in_inst_system_ebreak,
    input           in_inst_load        ,
    input           in_inst_store       ,
    input           in_inst_32          ,

    output          out_valid           ,
    output          out_ready           ,
	output [31:0]   out_pc              ,
	output [31:0]   out_inst            ,
    output [ 2:0]   out_funct3          ,
    output [ 4:0]   out_rs1             ,
    output [ 4:0]   out_rs2             ,
	output [63:0]   out_x_rs2           ,
    output [ 4:0]   out_rd              ,
    output          out_rd_idx_0        ,
	output	        out_rd_w_en         ,
	output	        out_rd_w_src_exu    ,
    output	        out_rd_w_src_mem    ,
    output	        out_rd_w_src_csr    ,
    output          out_csr_w_en        ,
    output [11:0]   out_csr_addr        ,
	output [63:0]   out_csr_r_data      ,
    output          out_exu_src1_xrs1   ,
    output          out_exu_src2_xrs2   ,
    output          out_exu_src2_csr    ,
	output [63:0]   out_exu_src1        ,
	output [63:0]   out_exu_src2        ,
    output          out_exu_sel_add_sub ,
    output          out_exu_sel_sub     ,
    output          out_exu_sel_slt     ,
    output          out_exu_sel_sltu    ,
    output          out_exu_sel_and     ,
    output          out_exu_sel_or      ,
    output          out_exu_sel_xor     ,
    output          out_exu_sel_sll     ,
    output          out_exu_sel_srl     ,
    output          out_exu_sel_sra     ,
    output          out_mul_valid       ,
    output [ 1:0]   out_mul_signed      ,
    output          out_mul_res_lo      ,
    output          out_div_valid       ,
    output [ 1:0]   out_div_signed      ,
    output          out_div_quotient    ,
    output          out_inst_system_ebreak,
    output          out_inst_load       ,
    output          out_inst_store      ,
    output          out_inst_32         
);

    wire stall = (~in_ready && out_valid) || ~exu_idle;
    wire wen = in_valid && ~stall;
    wire flush = rst || (if_id_stall && ~stall);
    wire ctrl_flush = flush || (~in_valid && ~stall);
    assign out_ready = wen;
    
    Reg #(1, 'b0) u_id_ex_valid (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_valid), 
        .dout(out_valid), 
        .wen(wen)
    );

    Reg #(32, 'b0) u_id_ex_pc (
        .clk(clk), 
        .rst(flush), 
        .din(in_pc), 
        .dout(out_pc), 
        .wen(wen)
    );

    Reg #(32, 'b0) u_id_ex_inst (
        .clk(clk), 
        .rst(flush), 
        .din(in_inst), 
        .dout(out_inst), 
        .wen(wen)
    );

    Reg #(3, 'b0) u_id_ex_funct3 (
        .clk(clk), 
        .rst(flush), 
        .din(in_funct3), 
        .dout(out_funct3), 
        .wen(wen)
    );

    Reg #(5, 'b0) u_id_ex_rs1 (
        .clk(clk), 
        .rst(flush), 
        .din(in_rs1), 
        .dout(out_rs1), 
        .wen(wen)
    );
    Reg #(5, 'b0) u_id_ex_rs2 (
        .clk(clk), 
        .rst(flush), 
        .din(in_rs2), 
        .dout(out_rs2), 
        .wen(wen)
    );
    Reg #(64, 'b0) u_id_ex_x_rs2 (
        .clk(clk), 
        .rst(flush), 
        .din(in_x_rs2), 
        .dout(out_x_rs2), 
        .wen(wen)
    );
    Reg #(5, 'b0) u_id_ex_rd (
        .clk(clk), 
        .rst(flush), 
        .din(in_rd), 
        .dout(out_rd), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_rd_idx_0 (
        .clk(clk), 
        .rst(flush), 
        .din(in_rd_idx_0), 
        .dout(out_rd_idx_0), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_rd_w_en (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_rd_w_en), 
        .dout(out_rd_w_en), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_rd_w_src_exu (
        .clk(clk), 
        .rst(flush), 
        .din(in_rd_w_src_exu), 
        .dout(out_rd_w_src_exu), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_rd_w_src_mem (
        .clk(clk), 
        .rst(flush), 
        .din(in_rd_w_src_mem), 
        .dout(out_rd_w_src_mem), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_rd_w_src_csr (
        .clk(clk), 
        .rst(flush), 
        .din(in_rd_w_src_csr), 
        .dout(out_rd_w_src_csr), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_csr_w_en (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_csr_w_en), 
        .dout(out_csr_w_en), 
        .wen(wen)
    );
    Reg #(12, 'b0) u_id_ex_csr_addr (
        .clk(clk), 
        .rst(flush), 
        .din(in_csr_addr), 
        .dout(out_csr_addr), 
        .wen(wen)
    );
    Reg #(64, 'b0) u_id_ex_csr_r_data (
        .clk(clk), 
        .rst(flush), 
        .din(in_csr_r_data), 
        .dout(out_csr_r_data), 
        .wen(wen)
    );

    Reg #(1, 'b0) u_id_ex_exu_src1_xrs1 (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_src1_xrs1), 
        .dout(out_exu_src1_xrs1), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_exu_src2_xrs2 (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_src2_xrs2), 
        .dout(out_exu_src2_xrs2), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_exu_src2_csr (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_src2_csr), 
        .dout(out_exu_src2_csr), 
        .wen(wen)
    );
    Reg #(64, 'b0) u_id_ex_exu_src1 (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_src1), 
        .dout(out_exu_src1), 
        .wen(wen)
    );
    Reg #(64, 'b0) u_id_ex_exu_src2 (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_src2), 
        .dout(out_exu_src2), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_exu_sel_add_sub (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_sel_add_sub), 
        .dout(out_exu_sel_add_sub), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_exu_sel_sub (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_sel_sub), 
        .dout(out_exu_sel_sub), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_exu_sel_slt (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_sel_slt), 
        .dout(out_exu_sel_slt), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_exu_sel_sltu (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_sel_sltu), 
        .dout(out_exu_sel_sltu), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_exu_sel_and (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_sel_and), 
        .dout(out_exu_sel_and), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_exu_sel_or (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_sel_or), 
        .dout(out_exu_sel_or), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_exu_sel_xor (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_sel_xor), 
        .dout(out_exu_sel_xor), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_exu_sel_sll (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_sel_sll), 
        .dout(out_exu_sel_sll), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_exu_sel_srl (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_sel_srl), 
        .dout(out_exu_sel_srl), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_exu_sel_sra (
        .clk(clk), 
        .rst(flush), 
        .din(in_exu_sel_sra), 
        .dout(out_exu_sel_sra), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_mul_valid (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_mul_valid), 
        .dout(out_mul_valid), 
        .wen(wen)
    );
    
    Reg #(2, 'b0) u_id_ex_mul_signed (
        .clk(clk), 
        .rst(flush), 
        .din(in_mul_signed), 
        .dout(out_mul_signed), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_mul_res_lo (
        .clk(clk), 
        .rst(flush), 
        .din(in_mul_res_lo), 
        .dout(out_mul_res_lo), 
        .wen(wen)
    );
    
    Reg #(1, 'b0) u_id_ex_div_valid (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_div_valid), 
        .dout(out_div_valid), 
        .wen(wen)
    );

    Reg #(2, 'b0) u_id_ex_div_signed (
        .clk(clk), 
        .rst(flush), 
        .din(in_div_signed), 
        .dout(out_div_signed), 
        .wen(wen)
    );

    Reg #(1, 'b0) u_id_ex_div_quotient (
        .clk(clk), 
        .rst(flush), 
        .din(in_div_quotient), 
        .dout(out_div_quotient), 
        .wen(wen)
    );

    Reg #(1, 'b0) u_id_ex_inst_system_ebreak (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_inst_system_ebreak), 
        .dout(out_inst_system_ebreak), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_inst_load (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_inst_load), 
        .dout(out_inst_load), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_inst_store (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_inst_store), 
        .dout(out_inst_store), 
        .wen(wen)
    );
    Reg #(1, 'b0) u_id_ex_inst_32 (
        .clk(clk), 
        .rst(ctrl_flush), 
        .din(in_inst_32), 
        .dout(out_inst_32), 
        .wen(wen)
    );

endmodule //id_ex_reg
