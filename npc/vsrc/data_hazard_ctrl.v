
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

    reg  [1:0]  if_id_stall_lsu_r;

    /***** rd = rs *****/
    assign      ex_x_rs1_forward_mem     = mem_rd_w_en & ~mem_rd_idx_0 & (ex_rs1 == mem_rd);    // ex <- mem
    assign      ex_x_rs2_forward_mem     = mem_rd_w_en & ~mem_rd_idx_0 & (ex_rs2 == mem_rd);    // ex <- mem

    assign      ex_x_rs1_forward_wb     = wb_rd_w_en & ~wb_rd_idx_0 & (ex_rs1 == wb_rd);        // ex <- wb
    assign      ex_x_rs2_forward_wb     = wb_rd_w_en & ~wb_rd_idx_0 & (ex_rs2 == wb_rd);        // ex <- wb
    
    wire        id_x_rs1_forward_ex     = ex_rd_w_en & ~ex_rd_idx_0 & (id_rs1 == ex_rd);        // id <- ex
    wire        id_x_rs2_forward_ex     = ex_rd_w_en & ~ex_rd_idx_0 & (id_rs2 == ex_rd);        // id <- ex

    wire        id_x_rs1_forward_mem    = mem_rd_w_en & ~mem_rd_idx_0 & (id_rs1 == mem_rd);     // id <- mem
    wire        id_x_rs2_forward_mem    = mem_rd_w_en & ~mem_rd_idx_0 & (id_rs2 == mem_rd);     // id <- mem

    wire        id_x_rs1_forward_wb     = wb_rd_w_en & ~wb_rd_idx_0 & (id_rs1 == wb_rd);        // id <- wb
    wire        id_x_rs2_forward_wb     = wb_rd_w_en & ~wb_rd_idx_0 & (id_rs2 == wb_rd);        // id <- wb

    /***** data forward *****/
    assign      exu_src1_forward_mem     = ex_exu_src1_xrs1 & ex_x_rs1_forward_mem;             // ex <- mem
    assign      exu_src2_forward_mem     = ex_exu_src2_xrs2 & ex_x_rs2_forward_mem;             // ex <- mem
    assign      exu_src2_forward_mem_csr = ex_exu_src2_csr  & mem_csr_w_en & (ex_csr_addr == mem_csr_addr);

    assign      exu_src1_forward_wb     = ex_exu_src1_xrs1 & ~ex_x_rs1_forward_mem & ex_x_rs1_forward_wb;// ex <- wb
    assign      exu_src2_forward_wb     = ex_exu_src2_xrs2 & ~ex_x_rs2_forward_mem & ex_x_rs2_forward_wb;// ex <- wb

    assign      bju_x_rs1_forward_mem   = id_x_rs1_forward_mem  & (id_inst_branch | id_inst_jalr);  // id <- mem
    assign      bju_x_rs2_forward_mem   = id_x_rs2_forward_mem  & id_inst_branch;                   // id <- mem

    assign      bju_x_rs1_forward_wb    = ~id_x_rs1_forward_mem & id_x_rs1_forward_wb & (id_inst_branch | id_inst_jalr);// id <- wb
    assign      bju_x_rs2_forward_wb    = ~id_x_rs2_forward_mem & id_x_rs2_forward_wb & id_inst_branch;                 // id <- wb

    /***** pipeline stall *****/
    // |--if--|--id--|--ex--|--ls--|--wb--|
    // |------|--FW--|-READ-|------|------|
    wire        if_id_stall_exu         = ex_lsu_r_ready & (id_x_rs1_forward_ex | id_x_rs2_forward_ex);
    
    // |--if--|--id--|--ex--|--ls--|--wb--|
    // |------|--FW--|------|-READ-|------|
    wire        if_id_stall_lsu_        = mem_lsu_r_ready & (id_x_rs1_forward_mem | id_x_rs2_forward_mem);

    /* ld rs1
     * ld rs2
     * be rs1 rs2
     * 以上情况需要两次阻塞流水线, 故采用计数
     */
    always @(posedge clk ) begin
        if (rst) begin
            if_id_stall_lsu_r <= 0;
        end else begin
            case (if_id_stall_lsu_r)
                2'b00: begin
                    if(if_id_stall_lsu_) 
                        if_id_stall_lsu_r <= if_id_stall_lsu_r + 1;
                end
                2'b01: begin
                    if(if_id_stall_lsu_ & ~mem_lsu_r_valid)
                        if_id_stall_lsu_r <= if_id_stall_lsu_r + 1;
                    else if(~if_id_stall_lsu_ & mem_lsu_r_valid)
                        if_id_stall_lsu_r <= if_id_stall_lsu_r - 1;
                end
                2'b10, 2'b11: begin
                    if(mem_lsu_r_valid)
                        if_id_stall_lsu_r <= if_id_stall_lsu_r + 1;
                end
                default: if_id_stall_lsu_r <= 0;
            endcase
        end
    end

    wire        if_id_stall_lsu         = if_id_stall_lsu_ | (if_id_stall_lsu_r[0] & ~mem_lsu_r_valid);

    // |--if--|--id--|--ex--|--ls--|--wb--|
    // |------|--B---|--EX--|------|------|
    // |------|--B---|------|-READ-|------|
    // |------|---J--|--EX--|------|------|
    // |------|---J--|------|-READ-|------|
    wire        if_id_stall_bju         = (id_inst_branch & (id_x_rs1_forward_ex | id_x_rs2_forward_ex)) | 
                                          (id_inst_jalr   & (id_x_rs1_forward_ex));

    assign      if_id_stall             = if_id_stall_exu | if_id_stall_lsu | if_id_stall_bju;

endmodule //data_hazard_ctrl


