module data_hazard_ctrl (
    input           clk                     ,
    input           rst                     ,
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
    input           wb_lsu_r_ready          ,
    input           wb_lsu_r_valid          ,
    output          ex_rs1_eq_mem_rd        ,
    output          ex_rs2_eq_mem_rd        ,
    output          ex_rs1_eq_wb_rd         ,
    output          ex_rs2_eq_wb_rd         ,
    output          exu_src1_forward_mem    ,
    output          exu_src2_forward_mem    ,
    output          exu_src2_forward_mem_csr,
    output          exu_src1_forward_wb     ,
    output          exu_src2_forward_wb     ,
    output          bju_x_rs1_forward_mem   ,
    output          bju_x_rs2_forward_mem   ,
    // output          bju_x_rs1_forward_wb    ,
    // output          bju_x_rs2_forward_wb    ,
    output          if_id_stall             
);


    reg  [1:0]  if_id_stall_lsu_r;

    /***** rs = rd *****/
    assign      ex_rs1_eq_mem_rd     = mem_rd_w_en & ~mem_rd_idx_0 & (ex_rs1 == mem_rd);    // ex <- mem
    assign      ex_rs2_eq_mem_rd     = mem_rd_w_en & ~mem_rd_idx_0 & (ex_rs2 == mem_rd);    // ex <- mem

    assign      ex_rs1_eq_wb_rd     = wb_rd_w_en & ~wb_rd_idx_0 & (ex_rs1 == wb_rd);        // ex <- wb
    assign      ex_rs2_eq_wb_rd     = wb_rd_w_en & ~wb_rd_idx_0 & (ex_rs2 == wb_rd);        // ex <- wb
    
    wire        id_rs1_eq_ex_rd     = ex_rd_w_en & ~ex_rd_idx_0 & (id_rs1 == ex_rd);        // id <- ex
    wire        id_rs2_eq_ex_rd     = ex_rd_w_en & ~ex_rd_idx_0 & (id_rs2 == ex_rd);        // id <- ex

    wire        id_rs1_eq_mem_rd    = mem_rd_w_en & ~mem_rd_idx_0 & (id_rs1 == mem_rd);     // id <- mem
    wire        id_rs2_eq_mem_rd    = mem_rd_w_en & ~mem_rd_idx_0 & (id_rs2 == mem_rd);     // id <- mem

    wire        id_rs1_eq_wb_rd     = wb_rd_w_en & ~wb_rd_idx_0 & (id_rs1 == wb_rd);        // id <- wb
    wire        id_rs2_eq_wb_rd     = wb_rd_w_en & ~wb_rd_idx_0 & (id_rs2 == wb_rd);        // id <- wb

/*
    流水线前递情况
    |--if--|--id--|--ex--|-mem--|--wb--|

    |------|------|--RS--|--RD--|------|
    |------|------|--RS--|-N-RD-|--RD--|
    |------|--BJ--|------|N-LOAD|------|
*/
    /***** data forward *****/
    assign      exu_src1_forward_mem     = ex_exu_src1_xrs1 & ex_rs1_eq_mem_rd;             // ex <- mem
    assign      exu_src2_forward_mem     = ex_exu_src2_xrs2 & ex_rs2_eq_mem_rd;             // ex <- mem
    
    assign      exu_src2_forward_mem_csr = ex_exu_src2_csr  & mem_csr_w_en & (ex_csr_addr == mem_csr_addr);

    assign      exu_src1_forward_wb     = ex_exu_src1_xrs1 & ~ex_rs1_eq_mem_rd & ex_rs1_eq_wb_rd;// ex <- wb
    assign      exu_src2_forward_wb     = ex_exu_src2_xrs2 & ~ex_rs2_eq_mem_rd & ex_rs2_eq_wb_rd;// ex <- wb

    assign      bju_x_rs1_forward_mem   = id_rs1_eq_mem_rd & ~mem_lsu_r_ready & (id_inst_branch | id_inst_jalr);  // id <- mem
    assign      bju_x_rs2_forward_mem   = id_rs2_eq_mem_rd & ~mem_lsu_r_ready & id_inst_branch;                   // id <- mem

    // assign      bju_x_rs1_forward_wb    = ~id_rs1_eq_mem_rd & id_rs1_eq_wb_rd & (id_inst_branch | id_inst_jalr);// id <- wb
    // assign      bju_x_rs2_forward_wb    = ~id_rs2_eq_mem_rd & id_rs2_eq_wb_rd & id_inst_branch;                 // id <- wb

/*
    流水线阻塞情况
    |--if--|--id--|--ex--|-mem--|--wb--|

    |------|-N-BJ-|-LOAD-|------|------|
    |------|-N-BJ-|------|-LOAD-|------|
    |------|-N-BJ-|------|------|-LOAD-| not-valid
    |------|--B---|--EX--|------|------|
    |------|--B---|------|-LOAD-|------|
    |------|--B---|------|------|-LOAD-| not-valid
    |------|---J--|--EX--|------|------|
    |------|---J--|------|-LOAD-|------|
    |------|---J--|------|------|-LOAD-| not-valid
*/
    /***** pipeline stall *****/
    // |--if--|--id--|--ex--|-mem--|--wb--|
    // |------|--RS--|-LOAD-|------|------|
    wire        if_id_stall_ex          = ex_lsu_r_ready & (id_rs1_eq_ex_rd | id_rs2_eq_ex_rd);
    
    // |--if--|--id--|--ex--|-mem--|--wb--|
    // |------|--RS--|------|-LOAD-|------|
    wire        if_id_stall_mem         = mem_lsu_r_ready & (id_rs1_eq_mem_rd | id_rs2_eq_mem_rd);

    // |--if--|--id--|--ex--|-mem--|--wb--|
    // |------|--RS--|------|------|-LOAD-| not-valid
    wire        if_id_stall_wb          = wb_lsu_r_ready & (id_rs1_eq_wb_rd | id_rs2_eq_wb_rd) & ~wb_lsu_r_valid;

    // |--if--|--id--|--ex--|-mem--|--wb--|
    // |------|--BJ--|--EX--|------|------|
    wire        if_id_stall_bj          = (id_inst_branch | id_inst_jalr) & (id_rs1_eq_ex_rd | id_rs2_eq_ex_rd);

    assign      if_id_stall             = if_id_stall_ex | if_id_stall_mem | if_id_stall_wb | if_id_stall_bj;

endmodule //data_hazard_ctrl


