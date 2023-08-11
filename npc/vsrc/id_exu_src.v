module id_exu_src (
    input  [63:0]   x_rs1               ,
    input  [63:0]   x_rs2               ,
    input  [31:0]   pc                  ,
    input  [63:0]   imm                 ,
    input  [63:0]   csr_r_data          ,
    input  [4:0]    rs1                 ,
    input           exu_src1_xrs1       ,
    input           exu_src1_pc         ,
    input           exu_src1_xrs1_i     ,
    input           exu_src1_rs1        ,
    input           exu_src1_rs1_i      ,
    input           exu_src2_xrs2       ,
    input           exu_src2_imm        ,
    input           exu_src2_csr        ,
    input           exu_src2_4          ,
	output  [63:0]  exu_src1            ,
	output  [63:0]  exu_src2            
);

    assign exu_src1 =   exu_src1_xrs1       ?  x_rs1        : 
                        exu_src1_pc         ?  {32'b0, pc}  : 
                        exu_src1_xrs1_i     ? ~x_rs1        : 
                        exu_src1_rs1        ?  {59'b0, rs1} : 
                        exu_src1_rs1_i      ? ~{59'b0, rs1} : 0;

    assign exu_src2 =   exu_src2_xrs2       ? x_rs2         : 
                        exu_src2_imm        ? imm           : 
                        exu_src2_csr        ? csr_r_data    : 
                        exu_src2_4          ? 64'd4         : 0;

endmodule //id_exu_src