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

    output reg          out_valid           ,
    output              out_ready           ,
	output reg [31:0]   out_pc              ,
	output reg [31:0]   out_inst            ,
    output reg [ 2:0]   out_funct3          ,
    output reg [ 4:0]   out_rs1             ,
    output reg [ 4:0]   out_rs2             ,
	output reg [63:0]   out_x_rs2           ,
    output reg [ 4:0]   out_rd              ,
    output reg          out_rd_idx_0        ,
	output reg	        out_rd_w_en         ,
	output reg	        out_rd_w_src_exu    ,
    output reg	        out_rd_w_src_mem    ,
    output reg	        out_rd_w_src_csr    ,
    output reg          out_csr_w_en        ,
    output reg [11:0]   out_csr_addr        ,
	output reg [63:0]   out_csr_r_data      ,
    output reg          out_exu_src1_xrs1   ,
    output reg          out_exu_src2_xrs2   ,
    output reg          out_exu_src2_csr    ,
	output reg [63:0]   out_exu_src1        ,
	output reg [63:0]   out_exu_src2        ,
    output reg          out_exu_sel_add_sub ,
    output reg          out_exu_sel_sub     ,
    output reg          out_exu_sel_slt     ,
    output reg          out_exu_sel_sltu    ,
    output reg          out_exu_sel_and     ,
    output reg          out_exu_sel_or      ,
    output reg          out_exu_sel_xor     ,
    output reg          out_exu_sel_sll     ,
    output reg          out_exu_sel_srl     ,
    output reg          out_exu_sel_sra     ,
    output reg          out_mul_valid       ,
    output reg [ 1:0]   out_mul_signed      ,
    output reg          out_mul_res_lo      ,
    output reg          out_div_valid       ,
    output reg [ 1:0]   out_div_signed      ,
    output reg          out_div_quotient    ,
    output reg          out_inst_system_ebreak,
    output reg          out_inst_load       ,
    output reg          out_inst_store      ,
    output reg          out_inst_32         
);

    wire stall = (~in_ready & out_valid) | ~exu_idle;
    wire wen = in_valid & ~stall;
    wire flush = rst | (if_id_stall & ~stall);
    wire ctrl_flush = flush | (~in_valid & ~stall);
    assign out_ready = exu_idle & !(in_valid & ~in_ready & out_valid);
    
    always @(posedge clk ) begin
        if (ctrl_flush) begin
                out_valid               <= 0;
                out_rd_w_en             <= 0;
                out_csr_w_en            <= 0;
                out_mul_valid           <= 0;
                out_div_valid           <= 0;
                out_inst_system_ebreak  <= 0;
                out_inst_load           <= 0;
                out_inst_store          <= 0;
                out_inst_32             <= 0;
        end else begin
            if(wen) begin
                out_valid               <= in_valid; 
                out_rd_w_en             <= in_rd_w_en; 
                out_csr_w_en            <= in_csr_w_en; 
                out_mul_valid           <= in_mul_valid; 
                out_div_valid           <= in_div_valid; 
                out_inst_system_ebreak  <= in_inst_system_ebreak; 
                out_inst_load           <= in_inst_load; 
                out_inst_store          <= in_inst_store; 
                out_inst_32             <= in_inst_32; 
            end
        end
    end
    
    always @(posedge clk ) begin
        if (flush) begin
                out_pc              <= 0;
                out_inst            <= 0;
                out_funct3          <= 0;
                out_rs1             <= 0;
                out_rs2             <= 0;
                out_x_rs2           <= 0;
                out_rd              <= 0;
                out_rd_idx_0        <= 0;
                out_rd_w_src_exu    <= 0;
                out_rd_w_src_mem    <= 0;
                out_rd_w_src_csr    <= 0;
                out_csr_addr        <= 0;
                out_csr_r_data      <= 0;
                out_exu_src1_xrs1   <= 0;
                out_exu_src2_xrs2   <= 0;
                out_exu_src2_csr    <= 0;
                out_exu_src1        <= 0;
                out_exu_src2        <= 0;
                out_exu_sel_add_sub <= 0;
                out_exu_sel_sub     <= 0;
                out_exu_sel_slt     <= 0;
                out_exu_sel_sltu    <= 0;
                out_exu_sel_and     <= 0;
                out_exu_sel_or      <= 0;
                out_exu_sel_xor     <= 0;
                out_exu_sel_sll     <= 0;
                out_exu_sel_srl     <= 0;
                out_exu_sel_sra     <= 0;
                out_mul_signed      <= 0;
                out_mul_res_lo      <= 0;
                out_div_signed      <= 0;
                out_div_quotient    <= 0;
        end else begin
            if(wen) begin
                out_pc              <= in_pc; 
                out_inst            <= in_inst; 
                out_funct3          <= in_funct3; 
                out_rs1             <= in_rs1; 
                out_rs2             <= in_rs2; 
                out_x_rs2           <= in_x_rs2; 
                out_rd              <= in_rd; 
                out_rd_idx_0        <= in_rd_idx_0; 
                out_rd_w_src_exu    <= in_rd_w_src_exu; 
                out_rd_w_src_mem    <= in_rd_w_src_mem; 
                out_rd_w_src_csr    <= in_rd_w_src_csr; 
                out_csr_addr        <= in_csr_addr; 
                out_csr_r_data      <= in_csr_r_data; 
                out_exu_src1_xrs1   <= in_exu_src1_xrs1; 
                out_exu_src2_xrs2   <= in_exu_src2_xrs2; 
                out_exu_src2_csr    <= in_exu_src2_csr; 
                out_exu_src1        <= in_exu_src1; 
                out_exu_src2        <= in_exu_src2; 
                out_exu_sel_add_sub <= in_exu_sel_add_sub; 
                out_exu_sel_sub     <= in_exu_sel_sub; 
                out_exu_sel_slt     <= in_exu_sel_slt; 
                out_exu_sel_sltu    <= in_exu_sel_sltu; 
                out_exu_sel_and     <= in_exu_sel_and; 
                out_exu_sel_or      <= in_exu_sel_or; 
                out_exu_sel_xor     <= in_exu_sel_xor; 
                out_exu_sel_sll     <= in_exu_sel_sll; 
                out_exu_sel_srl     <= in_exu_sel_srl; 
                out_exu_sel_sra     <= in_exu_sel_sra; 
                out_mul_signed      <= in_mul_signed; 
                out_mul_res_lo      <= in_mul_res_lo; 
                out_div_signed      <= in_div_signed; 
                out_div_quotient    <= in_div_quotient; 
            end
        end
    end

endmodule //id_ex_reg
