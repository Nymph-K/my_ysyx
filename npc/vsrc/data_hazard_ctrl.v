
module data_hazard_ctrl (
    input  [4:0]    id_rs1                  ,
    input  [4:0]    id_rs2                  ,
    input  [4:0]    ex_rs1                  ,
    input  [4:0]    ex_rs2                  ,
    input  [4:0]    ex_rd                   ,
    input           mem_lsu_r_ready         ,
    input           mem_rd_w_en             ,
    input           mem_rd_idx_0            ,
    input  [4:0]    mem_rd                  ,
    input           wb_rd_w_en              ,
    input           wb_rd_idx_0             ,
    input  [4:0]    wb_rd                   ,
    output          exu_src1_forward_ex     ,
    output          exu_src2_forward_ex     ,
    output          exu_src1_forward_mem    ,
    output          exu_src2_forward_mem    ,
    output          if_id_stall             
);
    // wire        rs1_id_equ_rd_ex        = ex_rs1 == mem_rd;
    // wire        rs2_id_equ_rd_ex        = ex_rs2 == mem_rd;
    // wire        rs1_id_equ_rd_mem       = ex_rs1 == wb_rd;
    // wire        rs2_id_equ_rd_mem       = ex_rs2 == wb_rd;

    assign      exu_src1_forward_ex     = mem_rd_w_en && ~mem_rd_idx_0 && (ex_rs1 == mem_rd);
    assign      exu_src2_forward_ex     = mem_rd_w_en && ~mem_rd_idx_0 && (ex_rs2 == mem_rd);

    assign      exu_src1_forward_mem    = ~exu_src1_forward_ex && wb_rd_w_en && ~wb_rd_idx_0 && (ex_rs1 == wb_rd);
    assign      exu_src2_forward_mem    = ~exu_src2_forward_ex && wb_rd_w_en && ~wb_rd_idx_0 && (ex_rs2 == wb_rd);

    assign      if_id_stall             = mem_lsu_r_ready && ((ex_rd == id_rs1) || (ex_rd == id_rs2));

endmodule //data_hazard_ctrl