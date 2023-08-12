
module data_hazard_ctrl (
    input  [4:0]    id_rs1                  ,
    input  [4:0]    id_rs2                  ,
    input  [4:0]    ex_rs1                  ,
    input  [4:0]    ex_rs2                  ,
    input           ex_exu_src1_xrs1        ,
    input           ex_exu_src2_xrs2        ,
    input           ex_exu_src2_csr         ,
    input  [11:0]   ex_csr_addr             ,
    input  [4:0]    ex_rd                   ,
    input           ex_lsu_r_ready          ,
    input  [11:0]   mem_csr_addr            ,
    input           mem_csr_w_en            ,
    input           mem_rd_w_en             ,
    input           mem_rd_idx_0            ,
    input  [4:0]    mem_rd                  ,
    input           wb_rd_w_en              ,
    input           wb_rd_idx_0             ,
    input  [4:0]    wb_rd                   ,
    output          ex_x_rs1_forward_ex    ,
    output          ex_x_rs2_forward_ex    ,
    output          ex_x_rs1_forward_mem   ,
    output          ex_x_rs2_forward_mem   ,
    output          exu_src1_forward_ex     ,
    output          exu_src2_forward_ex     ,
    output          exu_src2_forward_ex_csr ,
    output          exu_src1_forward_mem    ,
    output          exu_src2_forward_mem    ,
    output          if_id_stall             
);
    // wire        rs1_id_equ_rd_ex        = ex_rs1 == mem_rd;
    // wire        rs2_id_equ_rd_ex        = ex_rs2 == mem_rd;
    // wire        rs1_id_equ_rd_mem       = ex_rs1 == wb_rd;
    // wire        rs2_id_equ_rd_mem       = ex_rs2 == wb_rd;

    assign      ex_x_rs1_forward_ex    = mem_rd_w_en && ~mem_rd_idx_0 && (ex_rs1 == mem_rd);
    assign      ex_x_rs2_forward_ex    = mem_rd_w_en && ~mem_rd_idx_0 && (ex_rs2 == mem_rd);

    assign      ex_x_rs1_forward_mem   = wb_rd_w_en && ~wb_rd_idx_0 && (ex_rs1 == wb_rd);
    assign      ex_x_rs2_forward_mem   = wb_rd_w_en && ~wb_rd_idx_0 && (ex_rs2 == wb_rd);

    assign      exu_src1_forward_ex     = ex_exu_src1_xrs1 && ex_x_rs1_forward_ex;
    assign      exu_src2_forward_ex     = ex_exu_src2_xrs2 && ex_x_rs2_forward_ex;
    assign      exu_src2_forward_ex_csr = ex_exu_src2_csr  && mem_csr_w_en && (ex_csr_addr == mem_csr_addr);

    assign      exu_src1_forward_mem    = ex_exu_src1_xrs1 && ~ex_x_rs1_forward_ex && ex_x_rs1_forward_mem;
    assign      exu_src2_forward_mem    = ex_exu_src2_xrs2 && ~ex_x_rs2_forward_ex && ex_x_rs2_forward_mem;

    assign      if_id_stall             = ex_lsu_r_ready && ((ex_rd == id_rs1) || (ex_rd == id_rs2));

endmodule //data_hazard_ctrl

