module ex_exu_src_forward (
    input  [63:0]   ex_exu_src1             ,
    input  [63:0]   ex_exu_src2             ,
    input  [63:0]   mem_x_rd                ,
    input  [63:0]   mem_exu_result          ,
    input           exu_src1_forward_mem     ,
    input           exu_src2_forward_mem     ,
    input  [63:0]   wb_x_rd                 ,
    input           exu_src1_forward_wb    ,
    input           exu_src2_forward_wb    ,
	output  [63:0]  exu_src1_forward        ,
	output  [63:0]  exu_src2_forward        
);

    assign exu_src1_forward =   exu_src1_forward_mem  ? mem_x_rd : 
                                exu_src1_forward_wb ? wb_x_rd  : ex_exu_src1;

    assign exu_src2_forward =   exu_src2_forward_mem     ? mem_x_rd          : 
                                exu_src2_forward_wb    ? wb_x_rd           : ex_exu_src2;

endmodule //ex_exu_src_forward