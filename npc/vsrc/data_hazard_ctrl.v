
module data_hazard_ctrl (
    input           id_inst_branch          ,
    input           id_inst_jalr            ,
    input  [4:0]    id_rs1                  ,
    input  [4:0]    id_rs2                  ,
    input  [4:0]    ex_rs1                  ,
    input  [4:0]    ex_rs2                  ,
    input           ex_exu_src1_xrs1        ,
    input           ex_exu_src2_xrs2        ,
    input           ex_exu_src2_csr         ,
    input  [11:0]   ex_csr_addr             ,
    input           ex_rd_w_en              ,
    input           ex_rd_idx_0             ,
    input  [4:0]    ex_rd                   ,
    input           ex_lsu_r_ready          ,
    input  [11:0]   mem_csr_addr            ,
    input           mem_csr_w_en            ,
    input           mem_rd_w_en             ,
    input           mem_rd_idx_0            ,
    input  [4:0]    mem_rd                  ,
    input           mem_lsu_r_ready         ,
    input           mem_lsu_r_valid         ,
    input           wb_rd_w_en              ,
    input           wb_rd_idx_0             ,
    input  [4:0]    wb_rd                   ,
    output          ex_x_rs1_forward_mem    ,
    output          ex_x_rs2_forward_mem    ,
    output          ex_x_rs1_forward_wb     ,
    output          ex_x_rs2_forward_wb     ,
    output          exu_src1_forward_mem    ,
    output          exu_src2_forward_mem    ,
    output          exu_src2_forward_mem_csr,
    output          exu_src1_forward_wb     ,
    output          exu_src2_forward_wb     ,
    output          bju_x_rs1_forward_mem   ,
    output          bju_x_rs2_forward_mem   ,
    output          bju_x_rs1_forward_wb    ,
    output          bju_x_rs2_forward_wb    ,
    output          if_id_stall             
);

    assign      ex_x_rs1_forward_mem     = mem_rd_w_en & ~mem_rd_idx_0 & (ex_rs1 == mem_rd);
    assign      ex_x_rs2_forward_mem     = mem_rd_w_en & ~mem_rd_idx_0 & (ex_rs2 == mem_rd);

    assign      ex_x_rs1_forward_wb     = wb_rd_w_en & ~wb_rd_idx_0 & (ex_rs1 == wb_rd);
    assign      ex_x_rs2_forward_wb     = wb_rd_w_en & ~wb_rd_idx_0 & (ex_rs2 == wb_rd);

    assign      exu_src1_forward_mem     = ex_exu_src1_xrs1 & ex_x_rs1_forward_mem;
    assign      exu_src2_forward_mem     = ex_exu_src2_xrs2 & ex_x_rs2_forward_mem;
    assign      exu_src2_forward_mem_csr = ex_exu_src2_csr  & mem_csr_w_en & (ex_csr_addr == mem_csr_addr);

    assign      exu_src1_forward_wb     = ex_exu_src1_xrs1 & ~ex_x_rs1_forward_mem & ex_x_rs1_forward_wb;
    assign      exu_src2_forward_wb     = ex_exu_src2_xrs2 & ~ex_x_rs2_forward_mem & ex_x_rs2_forward_wb;

    wire        if_id_stall_exu         = ex_lsu_r_ready & ((ex_rd == id_rs1) | (ex_rd == id_rs2));
    
    wire        if_id_stall_lsu         = mem_lsu_r_ready & ((mem_rd == id_rs1) | (mem_rd == id_rs2)) & ~mem_lsu_r_valid;
    
    wire        id_x_rs1_forward_ex     = ex_rd_w_en & ~ex_rd_idx_0 & (id_rs1 == ex_rd);
    wire        id_x_rs2_forward_ex     = ex_rd_w_en & ~ex_rd_idx_0 & (id_rs2 == ex_rd);

    wire        id_x_rs1_forward_mem    = mem_rd_w_en & ~mem_rd_idx_0 & (id_rs1 == mem_rd);
    wire        id_x_rs2_forward_mem    = mem_rd_w_en & ~mem_rd_idx_0 & (id_rs2 == mem_rd);

    wire        id_x_rs1_forward_wb     = wb_rd_w_en & ~wb_rd_idx_0 & (id_rs1 == wb_rd);
    wire        id_x_rs2_forward_wb     = wb_rd_w_en & ~wb_rd_idx_0 & (id_rs2 == wb_rd);

    assign      bju_x_rs1_forward_mem   = id_x_rs1_forward_mem  & (id_inst_branch | id_inst_jalr);
    assign      bju_x_rs2_forward_mem   = id_x_rs2_forward_mem  & id_inst_branch;

    assign      bju_x_rs1_forward_wb    = ~id_x_rs1_forward_mem & id_x_rs1_forward_wb & (id_inst_branch | id_inst_jalr);
    assign      bju_x_rs2_forward_wb    = ~id_x_rs2_forward_mem & id_x_rs2_forward_wb & id_inst_branch;

    wire        if_id_stall_bju         = (id_inst_branch & ((id_x_rs1_forward_ex | id_x_rs2_forward_ex) | (mem_lsu_r_ready & (id_x_rs1_forward_mem | id_x_rs2_forward_mem)))) | 
                                          (id_inst_jalr & (id_x_rs1_forward_ex | (mem_lsu_r_ready & id_x_rs1_forward_mem)));

    assign      if_id_stall             = if_id_stall_exu | if_id_stall_lsu | if_id_stall_bju;

endmodule //data_hazard_ctrl


