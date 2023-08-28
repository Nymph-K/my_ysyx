/*************************************************************
 * @ name           : top.v
 * @ description    : Top
 * @ use module     : ifu, pcu, gpr, csr, idu, 
 * @ author         : K
 * @ date modified  : 2023-3-10
*************************************************************/
`ifndef TOP_V
`define TOP_V

`include "common.v"

module top(
    input clk,
    input rst,
    output [31:0] pc,
    output [31:0] dnpc,
    output        pc_valid,
    output        dnpc_valid,
    output [31:0] inst
);
    assign pc = wb_pc;
    assign pc_valid = mem_wb_valid;
    assign inst = wb_inst;
    assign dnpc = ex_mem_valid ? mem_pc : ex_pc;
    assign dnpc_valid = ex_mem_valid ? 1 : id_ex_valid;

    /********************* pcu *********************/
    wire            pc_b_j, if_id_ready;
    wire [31:0]     id_dnpc, _;
    wire [31:0]     if_pc;
    wire            inst_r_valid, inst_r_ready;

    pcu u_pcu (
        .clk                    (clk),
        .rst                    (rst),
        .pc_b_j                 (pc_b_j),
        .if_id_handshake        (if_id_ready & if_valid),
        .dnpc                   (id_dnpc),
        .pc                     (if_pc),
        .inst_r_valid           (inst_r_valid),
        .inst_r_ready           (inst_r_ready)
    );

    /********************* ifu *********************/
    wire [31:0]     if_inst;
    wire            if_valid;
    //AW
    wire [ 3:0]               IFU_AXI_AWID;
    wire [31:0]               IFU_AXI_AWADDR;
    wire [ 7:0]               IFU_AXI_AWLEN;
    wire [ 2:0]               IFU_AXI_AWSIZE;
    wire [ 1:0]               IFU_AXI_AWBURST;
    wire                      IFU_AXI_AWLOCK;
    wire [ 3:0]               IFU_AXI_AWCACHE;
    wire [ 2:0]               IFU_AXI_AWPROT;
    wire [ 3:0]               IFU_AXI_AWQOS;
    wire [ 3:0]               IFU_AXI_AWREGION;
    wire                      IFU_AXI_AWUSER;
    wire                      IFU_AXI_AWVALID;
    wire                      IFU_AXI_AWREADY;
    //W 
    wire [63:0]               IFU_AXI_WDATA;
    wire [ 7:0]               IFU_AXI_WSTRB;
    wire                      IFU_AXI_WLAST;
    wire                      IFU_AXI_WUSER;
    wire                      IFU_AXI_WVALID;
    wire                      IFU_AXI_WREADY;
    //BR
    wire [ 3:0]               IFU_AXI_BID;
    wire [ 1:0]               IFU_AXI_BRESP;
    wire                      IFU_AXI_BUSER;
    wire                      IFU_AXI_BVALID;
    wire                      IFU_AXI_BREADY;
    //AR
    wire [ 3:0]               IFU_AXI_ARID;
    wire [31:0]               IFU_AXI_ARADDR;
    wire [ 7:0]               IFU_AXI_ARLEN;
    wire [ 2:0]               IFU_AXI_ARSIZE;
    wire [ 1:0]               IFU_AXI_ARBURST;
    wire                      IFU_AXI_ARLOCK;
    wire [ 3:0]               IFU_AXI_ARCACHE;
    wire [ 2:0]               IFU_AXI_ARPROT;
    wire [ 3:0]               IFU_AXI_ARQOS;
    wire [ 3:0]               IFU_AXI_ARREGION;
    wire                      IFU_AXI_ARUSER;
    wire                      IFU_AXI_ARVALID;
    wire                      IFU_AXI_ARREADY;
    //R
    wire [ 3:0]               IFU_AXI_RID;
    wire [63:0]               IFU_AXI_RDATA;
    wire [ 1:0]               IFU_AXI_RRESP;
    wire                      IFU_AXI_RLAST;
    wire                      IFU_AXI_RUSER;
    wire                      IFU_AXI_RVALID;
    wire                      IFU_AXI_RREADY;


    ifu u_ifu(
        .clk                    (clk),
        .rst                    (rst),
        .pc                     (if_pc),
        .inst                   (if_inst),
        .if_valid               (if_valid),
        .if_id_ready            (if_id_ready),
        .inst_r_ready           (inst_r_ready),
        .inst_r_valid           (inst_r_valid),

        .IFU_AXI_AWID			(IFU_AXI_AWID),
        .IFU_AXI_AWADDR			(IFU_AXI_AWADDR),
        .IFU_AXI_AWLEN			(IFU_AXI_AWLEN),
        .IFU_AXI_AWSIZE			(IFU_AXI_AWSIZE),
        .IFU_AXI_AWBURST		(IFU_AXI_AWBURST),
        .IFU_AXI_AWLOCK			(IFU_AXI_AWLOCK),
        .IFU_AXI_AWCACHE		(IFU_AXI_AWCACHE),
        .IFU_AXI_AWPROT			(IFU_AXI_AWPROT),
        .IFU_AXI_AWQOS			(IFU_AXI_AWQOS),
        .IFU_AXI_AWREGION		(IFU_AXI_AWREGION),
        .IFU_AXI_AWUSER			(IFU_AXI_AWUSER),
        .IFU_AXI_AWVALID		(IFU_AXI_AWVALID),
        .IFU_AXI_AWREADY		(IFU_AXI_AWREADY),

        .IFU_AXI_WDATA			(IFU_AXI_WDATA),
        .IFU_AXI_WSTRB			(IFU_AXI_WSTRB),
        .IFU_AXI_WLAST			(IFU_AXI_WLAST),
        .IFU_AXI_WUSER			(IFU_AXI_WUSER),
        .IFU_AXI_WVALID			(IFU_AXI_WVALID),
        .IFU_AXI_WREADY			(IFU_AXI_WREADY),

        .IFU_AXI_BID			(IFU_AXI_BID),
        .IFU_AXI_BRESP			(IFU_AXI_BRESP),
        .IFU_AXI_BUSER			(IFU_AXI_BUSER),
        .IFU_AXI_BVALID			(IFU_AXI_BVALID),
        .IFU_AXI_BREADY			(IFU_AXI_BREADY),

        .IFU_AXI_ARID			(IFU_AXI_ARID),
        .IFU_AXI_ARADDR			(IFU_AXI_ARADDR),
        .IFU_AXI_ARLEN			(IFU_AXI_ARLEN),
        .IFU_AXI_ARSIZE			(IFU_AXI_ARSIZE),
        .IFU_AXI_ARBURST		(IFU_AXI_ARBURST),
        .IFU_AXI_ARLOCK			(IFU_AXI_ARLOCK),
        .IFU_AXI_ARCACHE		(IFU_AXI_ARCACHE),
        .IFU_AXI_ARPROT			(IFU_AXI_ARPROT),
        .IFU_AXI_ARQOS			(IFU_AXI_ARQOS),
        .IFU_AXI_ARREGION		(IFU_AXI_ARREGION),
        .IFU_AXI_ARUSER			(IFU_AXI_ARUSER),
        .IFU_AXI_ARVALID		(IFU_AXI_ARVALID),
        .IFU_AXI_ARREADY		(IFU_AXI_ARREADY),

        .IFU_AXI_RID			(IFU_AXI_RID),
        .IFU_AXI_RDATA			(IFU_AXI_RDATA),
        .IFU_AXI_RRESP			(IFU_AXI_RRESP),
        .IFU_AXI_RLAST			(IFU_AXI_RLAST),
        .IFU_AXI_RUSER			(IFU_AXI_RUSER),
        .IFU_AXI_RVALID			(IFU_AXI_RVALID),
        .IFU_AXI_RREADY			(IFU_AXI_RREADY)
    );

    slave_axi_4 u_ifu_slave_axi_4 (
        .clk(clk),
        .rst(rst),

        .S_AXI_AWID         (IFU_AXI_AWID),
        .S_AXI_AWADDR       (IFU_AXI_AWADDR),
        .S_AXI_AWLEN        (IFU_AXI_AWLEN),
        .S_AXI_AWSIZE       (IFU_AXI_AWSIZE),
        .S_AXI_AWBURST      (IFU_AXI_AWBURST),
        .S_AXI_AWLOCK       (IFU_AXI_AWLOCK),
        .S_AXI_AWCACHE      (IFU_AXI_AWCACHE),
        .S_AXI_AWPROT       (IFU_AXI_AWPROT),
        .S_AXI_AWQOS        (IFU_AXI_AWQOS),
        .S_AXI_AWREGION     (IFU_AXI_AWREGION),
        .S_AXI_AWUSER       (IFU_AXI_AWUSER),
        .S_AXI_AWVALID      (IFU_AXI_AWVALID),
        .S_AXI_AWREADY      (IFU_AXI_AWREADY),
        .S_AXI_WDATA        (IFU_AXI_WDATA),
        .S_AXI_WSTRB        (IFU_AXI_WSTRB),
        .S_AXI_WLAST        (IFU_AXI_WLAST),
        .S_AXI_WUSER        (IFU_AXI_WUSER),
        .S_AXI_WVALID       (IFU_AXI_WVALID),
        .S_AXI_WREADY       (IFU_AXI_WREADY),
        .S_AXI_BID          (IFU_AXI_BID),
        .S_AXI_BRESP        (IFU_AXI_BRESP),
        .S_AXI_BUSER        (IFU_AXI_BUSER),
        .S_AXI_BVALID       (IFU_AXI_BVALID),
        .S_AXI_BREADY       (IFU_AXI_BREADY),
        .S_AXI_ARID         (IFU_AXI_ARID),
        .S_AXI_ARADDR       (IFU_AXI_ARADDR),
        .S_AXI_ARLEN        (IFU_AXI_ARLEN),
        .S_AXI_ARSIZE       (IFU_AXI_ARSIZE),
        .S_AXI_ARBURST      (IFU_AXI_ARBURST),
        .S_AXI_ARLOCK       (IFU_AXI_ARLOCK),
        .S_AXI_ARCACHE      (IFU_AXI_ARCACHE),
        .S_AXI_ARPROT       (IFU_AXI_ARPROT),
        .S_AXI_ARQOS        (IFU_AXI_ARQOS),
        .S_AXI_ARREGION     (IFU_AXI_ARREGION),
        .S_AXI_ARUSER       (IFU_AXI_ARUSER),
        .S_AXI_ARVALID      (IFU_AXI_ARVALID),
        .S_AXI_ARREADY      (IFU_AXI_ARREADY),
        .S_AXI_RID          (IFU_AXI_RID),
        .S_AXI_RDATA        (IFU_AXI_RDATA),
        .S_AXI_RRESP        (IFU_AXI_RRESP),
        .S_AXI_RLAST        (IFU_AXI_RLAST),
        .S_AXI_RUSER        (IFU_AXI_RUSER),
        .S_AXI_RVALID       (IFU_AXI_RVALID),
        .S_AXI_RREADY       (IFU_AXI_RREADY)
    );
    /********************* if_id_reg *********************/
    wire            if_id_stall, id_ex_ready, if_id_valid;
    wire [31:0]     id_pc, id_inst;

    if_id_reg u_if_id_reg(
        .clk                    (clk),
        .rst                    (rst),
        .if_id_stall            (if_id_stall),
        .pc_b_j                 (pc_b_j),
        .in_valid               (if_valid),
        .in_ready               (id_ex_ready),
        .in_pc                  (if_pc),
        .in_inst                (if_inst),
        .out_valid              (if_id_valid),
        .out_ready              (if_id_ready),
        .out_pc                 (id_pc),
        .out_inst               (id_inst)
    );
    
    /********************* idu *********************/
    wire [63:0]     id_imm;
    wire [ 2:0]     id_funct3;
    wire [ 4:0]     id_rs1, id_rs2, id_rd;
    wire            id_rd_idx_0          ;
    wire            id_rs1_idx_0         ;
    wire            id_rs2_idx_0         ;
    wire            id_rd_w_en           ;
    wire            id_rd_w_src_exu      ;
    wire            id_rd_w_src_mem      ;
    wire            id_rd_w_src_csr      ;
    wire            id_csr_r_en          ;
    wire            id_csr_w_en          ;
    wire [11:0]     id_csr_addr          ;
    wire            id_exu_src1_xrs1     ;
    wire            id_exu_src1_pc       ;
    wire            id_exu_src1_xrs1_i   ;
    wire            id_exu_src1_rs1      ;
    wire            id_exu_src1_rs1_i    ;
    wire            id_exu_src2_xrs2     ;
    wire            id_exu_src2_imm      ;
    wire            id_exu_src2_csr      ;
    wire            id_exu_src2_4        ;
    wire            id_exu_sel_add_sub   ;
    wire            id_exu_sel_sub       ;
    wire            id_exu_sel_slt       ;
    wire            id_exu_sel_sltu      ;
    wire            id_exu_sel_and       ;
    wire            id_exu_sel_or        ;
    wire            id_exu_sel_xor       ;
    wire            id_exu_sel_sll       ;
    wire            id_exu_sel_srl       ;
    wire            id_exu_sel_sra       ;
    wire            id_mul_valid         ;
    wire [ 1:0]     id_mul_signed        ;
    wire            id_mul_res_lo        ;
    wire            id_div_valid         ;
    wire [ 1:0]     id_div_signed        ;
    wire            id_div_quotient      ;
    wire            id_inst_load         ;
    wire            id_inst_store        ;
    wire            id_inst_system       ;
    wire            id_inst_jal          ;
    wire            id_inst_jalr         ;
    wire            id_inst_branch       ;
    wire            id_inst_branch_beq   ;
    wire            id_inst_branch_bne   ;
    wire            id_inst_branch_blt   ;
    wire            id_inst_branch_bge   ;
    wire            id_inst_branch_bltu  ;
    wire            id_inst_branch_bgeu  ;
    wire            id_inst_32           ;
    wire            id_inst_system_ecall ;
    wire            id_inst_system_mret  ;
    wire            id_inst_system_ebreak;

    idu u_idu(
        .inst                   (id_inst              ),
        .funct3                 (id_funct3            ),
        .imm                    (id_imm               ),
        .rs1                    (id_rs1               ),
        .rs2                    (id_rs2               ),
        .rd                     (id_rd                ),
        .rd_idx_0               (id_rd_idx_0          ),
        .rs1_idx_0              (id_rs1_idx_0         ),
        .rs2_idx_0              (id_rs2_idx_0         ),
        .rd_w_en                (id_rd_w_en           ),
        .rd_w_src_exu           (id_rd_w_src_exu      ),
        .rd_w_src_mem           (id_rd_w_src_mem      ),
        .rd_w_src_csr           (id_rd_w_src_csr      ),
        .csr_r_en               (id_csr_r_en          ),
        .csr_w_en               (id_csr_w_en          ),
        .csr_addr               (id_csr_addr          ),
        .exu_src1_xrs1          (id_exu_src1_xrs1     ),
        .exu_src1_pc            (id_exu_src1_pc       ),
        .exu_src1_xrs1_i        (id_exu_src1_xrs1_i   ),
        .exu_src1_rs1           (id_exu_src1_rs1      ),
        .exu_src1_rs1_i         (id_exu_src1_rs1_i    ),
        .exu_src2_xrs2          (id_exu_src2_xrs2     ),
        .exu_src2_imm           (id_exu_src2_imm      ),
        .exu_src2_csr           (id_exu_src2_csr      ),
        .exu_src2_4             (id_exu_src2_4        ),
        .exu_sel_add_sub        (id_exu_sel_add_sub   ),
        .exu_sel_sub            (id_exu_sel_sub       ),
        .exu_sel_slt            (id_exu_sel_slt       ),
        .exu_sel_sltu           (id_exu_sel_sltu      ),
        .exu_sel_and            (id_exu_sel_and       ),
        .exu_sel_or             (id_exu_sel_or        ),
        .exu_sel_xor            (id_exu_sel_xor       ),
        .exu_sel_sll            (id_exu_sel_sll       ),
        .exu_sel_srl            (id_exu_sel_srl       ),
        .exu_sel_sra            (id_exu_sel_sra       ),
        .mul_valid              (id_mul_valid         ),
        .mul_signed             (id_mul_signed        ),
        .mul_res_lo             (id_mul_res_lo        ),
        .div_valid              (id_div_valid         ),
        .div_signed             (id_div_signed        ),
        .div_quotient           (id_div_quotient      ),
        .inst_load              (id_inst_load         ),
        .inst_store             (id_inst_store        ),
        .inst_system            (id_inst_system       ),
        .inst_jal               (id_inst_jal          ),
        .inst_jalr              (id_inst_jalr         ),
        .inst_branch            (id_inst_branch       ),
        .inst_branch_beq        (id_inst_branch_beq   ),
        .inst_branch_bne        (id_inst_branch_bne   ),
        .inst_branch_blt        (id_inst_branch_blt   ),
        .inst_branch_bge        (id_inst_branch_bge   ),
        .inst_branch_bltu       (id_inst_branch_bltu  ),
        .inst_branch_bgeu       (id_inst_branch_bgeu  ),
        .inst_32                (id_inst_32           ),
        .inst_system_ecall      (id_inst_system_ecall ),
        .inst_system_mret       (id_inst_system_mret  ),
        .inst_system_ebreak     (id_inst_system_ebreak)
    );

    /********************* gpr *********************/
    //wire [63:0]     wb_x_rd =   wb_rd_w_src_exu ? wb_exu_result : 
    //                            wb_rd_w_src_mem ? wb_lsu_r_data :
    //                            wb_rd_w_src_csr ? wb_csr_r_data : 0;
    wire [63:0]     id_x_rs1, id_x_rs2;
    gpr u_gpr(
        .clk                    (clk        ),
        .rst                    (rst        ),
        .rs1                    (id_rs1     ),
        .rs2                    (id_rs2     ),
        .rd                     (wb_rd      ),
        .rd_w_en                (wb_rd_w_en ),
        .rd_idx_0               (wb_rd_idx_0),
        .x_rd                   (wb_x_rd    ),
        .x_rs1                  (id_x_rs1   ),
        .x_rs2                  (id_x_rs2   )
    );
    
    /********************* csr *********************/
    wire   [63:0]    id_csr_r_data;
    csr u_csr(
        .clk                    (clk),
        .rst                    (rst),
        .pc                     ({32'b0, id_pc} ),
        .inst_system_ecall      (id_inst_system_ecall),
        .inst_system_ebreak     (id_inst_system_ebreak),
        .csr_r_en               (id_csr_r_en),
        .csr_r_addr             (id_csr_addr),
        .csr_w_en               (mem_csr_w_en),
        .csr_w_addr             (mem_csr_addr),
        .csr_w_data             (mem_exu_result),
        .csr_r_data             (id_csr_r_data)
    );
    
    /********************* bju *********************/
    wire [63:0]     id_x_rs1_forward;
    wire [63:0]     id_x_rs2_forward;
    bju u_bju(
	    .pc                  ({32'b0, id_pc}         ),
	    .imm                 (id_imm                 ),
	    .x_rs1               (id_x_rs1_forward       ),
	    .x_rs2               (id_x_rs2_forward       ),
	    .inst_jalr           (id_inst_jalr           ),      
	    .inst_jal            (id_inst_jal            ),       
        .inst_branch_beq     (id_inst_branch_beq     ),
        .inst_branch_bne     (id_inst_branch_bne     ),
        .inst_branch_blt     (id_inst_branch_blt     ),
        .inst_branch_bge     (id_inst_branch_bge     ),
        .inst_branch_bltu    (id_inst_branch_bltu    ),
        .inst_branch_bgeu    (id_inst_branch_bgeu    ),
        .inst_system_ecall   (id_inst_system_ecall   ),
        .inst_system_mret    (id_inst_system_mret    ),
        .if_id_stall         (if_id_stall            ),
	    .csr_r_data          (id_csr_r_data          ),
        .dnpc                ({_, id_dnpc}           ),
        .pc_b_j              (pc_b_j                 )
    );
    
    /********************* id_exu_src *********************/
    wire   [63:0]    id_exu_src1;
    wire   [63:0]    id_exu_src2;
    id_exu_src u_id_exu_src(
        .x_rs1               (id_x_rs1            ),
        .x_rs2               (id_x_rs2            ),
        .pc                  (id_pc               ),
        .imm                 (id_imm              ),
        .csr_r_data          (id_csr_r_data       ),
        .rs1                 (id_rs1              ),
        .exu_src1_xrs1       (id_exu_src1_xrs1    ),
        .exu_src1_pc         (id_exu_src1_pc      ),
        .exu_src1_xrs1_i     (id_exu_src1_xrs1_i  ),
        .exu_src1_rs1        (id_exu_src1_rs1     ),
        .exu_src1_rs1_i      (id_exu_src1_rs1_i   ),
        .exu_src2_xrs2       (id_exu_src2_xrs2    ),
        .exu_src2_imm        (id_exu_src2_imm     ),
        .exu_src2_csr        (id_exu_src2_csr     ),
        .exu_src2_4          (id_exu_src2_4       ),
        .exu_src1            (id_exu_src1         ),
        .exu_src2            (id_exu_src2         )
    );

    /********************* id_ex_reg *********************/
    wire            exu_over, exu_idle;
    wire            ex_mem_ready;
    wire            id_ex_valid, id_ex_ready;         
    wire   [31:0]   ex_pc               ;
    wire   [31:0]   ex_inst             ;
    wire   [ 2:0]   ex_funct3           ;
    wire   [ 4:0]   ex_rs1              ;
    wire   [ 4:0]   ex_rs2              ;
    wire   [63:0]   ex_x_rs2            ;
    wire   [ 4:0]   ex_rd               ;
    wire            ex_rd_idx_0         ;
    wire            ex_rd_w_en          ;
    wire            ex_rd_w_src_exu     ;
    wire            ex_rd_w_src_mem     ;
    wire            ex_rd_w_src_csr     ;
    wire            ex_csr_w_en         ;
    wire   [11:0]   ex_csr_addr         ;
    wire   [63:0]   ex_csr_r_data       ;
    wire            ex_exu_src1_xrs1    ;
    wire            ex_exu_src2_xrs2    ;
    wire            ex_exu_src2_csr     ;
    wire   [63:0]   ex_exu_src1         ;
    wire   [63:0]   ex_exu_src2         ;
    wire            ex_exu_sel_add_sub  ;
    wire            ex_exu_sel_sub      ;
    wire            ex_exu_sel_slt      ;
    wire            ex_exu_sel_sltu     ;
    wire            ex_exu_sel_and      ;
    wire            ex_exu_sel_or       ;
    wire            ex_exu_sel_xor      ;
    wire            ex_exu_sel_sll      ;
    wire            ex_exu_sel_srl      ;
    wire            ex_exu_sel_sra      ;
    wire            ex_mul_valid        ;
    wire   [ 1:0]   ex_mul_signed       ;
    wire            ex_mul_res_lo       ;
    wire            ex_div_valid        ;
    wire   [ 1:0]   ex_div_signed       ;
    wire            ex_div_quotient     ;
    wire            ex_inst_system_ebreak;
    wire            ex_inst_load        ;
    wire            ex_inst_store       ;
    wire            ex_inst_32          ;

    id_ex_reg u_id_ex_reg(
        .clk                     (clk                   ),
        .rst                     (rst                   ),
        .if_id_stall             (if_id_stall           ),
        .exu_idle                (exu_idle              ),

        .in_valid                (if_id_valid           ),
        .in_ready                (ex_mem_ready          ),
        .in_pc                   (id_pc                 ),
        .in_inst                 (id_inst               ),
        .in_funct3               (id_funct3             ),
        .in_rs1                  (id_rs1                ),
        .in_rs2                  (id_rs2                ),
        .in_x_rs2                (id_x_rs2              ),
        .in_rd                   (id_rd                 ),
        .in_rd_idx_0             (id_rd_idx_0           ),
        .in_rd_w_en              (id_rd_w_en            ),
        .in_rd_w_src_exu         (id_rd_w_src_exu       ),
        .in_rd_w_src_mem         (id_rd_w_src_mem       ),
        .in_rd_w_src_csr         (id_rd_w_src_csr       ),
        .in_csr_w_en             (id_csr_w_en           ),
        .in_csr_addr             (id_csr_addr           ),
        .in_csr_r_data           (id_csr_r_data         ),
        .in_exu_src1_xrs1        (id_exu_src1_xrs1      ),
        .in_exu_src2_xrs2        (id_exu_src2_xrs2      ),
        .in_exu_src2_csr         (id_exu_src2_csr       ),
        .in_exu_src1             (id_exu_src1           ),
        .in_exu_src2             (id_exu_src2           ),
        .in_exu_sel_add_sub      (id_exu_sel_add_sub    ),
        .in_exu_sel_sub          (id_exu_sel_sub        ),
        .in_exu_sel_slt          (id_exu_sel_slt        ),
        .in_exu_sel_sltu         (id_exu_sel_sltu       ),
        .in_exu_sel_and          (id_exu_sel_and        ),
        .in_exu_sel_or           (id_exu_sel_or         ),
        .in_exu_sel_xor          (id_exu_sel_xor        ),
        .in_exu_sel_sll          (id_exu_sel_sll        ),
        .in_exu_sel_srl          (id_exu_sel_srl        ),
        .in_exu_sel_sra          (id_exu_sel_sra        ),
        .in_mul_valid            (id_mul_valid          ),
        .in_mul_signed           (id_mul_signed         ),
        .in_mul_res_lo           (id_mul_res_lo         ),
        .in_div_valid            (id_div_valid          ),
        .in_div_signed           (id_div_signed         ),
        .in_div_quotient         (id_div_quotient       ),
        .in_inst_system_ebreak   (id_inst_system_ebreak ),
        .in_inst_load            (id_inst_load          ),
        .in_inst_store           (id_inst_store         ),
        .in_inst_32              (id_inst_32            ),

        .out_valid               (id_ex_valid           ),
        .out_ready               (id_ex_ready           ),
        .out_pc                  (ex_pc                 ),
        .out_inst                (ex_inst               ),
        .out_funct3              (ex_funct3             ),
        .out_rs1                 (ex_rs1                ),
        .out_rs2                 (ex_rs2                ),
        .out_x_rs2               (ex_x_rs2              ),
        .out_rd                  (ex_rd                 ),
        .out_rd_idx_0            (ex_rd_idx_0           ),
        .out_rd_w_en             (ex_rd_w_en            ),
        .out_rd_w_src_exu        (ex_rd_w_src_exu       ),
        .out_rd_w_src_mem        (ex_rd_w_src_mem       ),
        .out_rd_w_src_csr        (ex_rd_w_src_csr       ),
        .out_csr_w_en            (ex_csr_w_en           ),
        .out_csr_addr            (ex_csr_addr           ),
        .out_csr_r_data          (ex_csr_r_data         ),
        .out_exu_src1_xrs1       (ex_exu_src1_xrs1      ),
        .out_exu_src2_xrs2       (ex_exu_src2_xrs2      ),
        .out_exu_src2_csr        (ex_exu_src2_csr       ),
        .out_exu_src1            (ex_exu_src1           ),
        .out_exu_src2            (ex_exu_src2           ),
        .out_exu_sel_add_sub     (ex_exu_sel_add_sub    ),
        .out_exu_sel_sub         (ex_exu_sel_sub        ),
        .out_exu_sel_slt         (ex_exu_sel_slt        ),
        .out_exu_sel_sltu        (ex_exu_sel_sltu       ),
        .out_exu_sel_and         (ex_exu_sel_and        ),
        .out_exu_sel_or          (ex_exu_sel_or         ),
        .out_exu_sel_xor         (ex_exu_sel_xor        ),
        .out_exu_sel_sll         (ex_exu_sel_sll        ),
        .out_exu_sel_srl         (ex_exu_sel_srl        ),
        .out_exu_sel_sra         (ex_exu_sel_sra        ),
        .out_mul_valid           (ex_mul_valid          ),
        .out_mul_signed          (ex_mul_signed         ),
        .out_mul_res_lo          (ex_mul_res_lo         ),
        .out_div_valid           (ex_div_valid          ),
        .out_div_signed          (ex_div_signed         ),
        .out_div_quotient        (ex_div_quotient       ),
        .out_inst_system_ebreak  (ex_inst_system_ebreak ),
        .out_inst_load           (ex_inst_load          ),
        .out_inst_store          (ex_inst_store         ),
        .out_inst_32             (ex_inst_32            )
    );

    /********************* exu *********************/
    wire            ex_flush = 0;
    wire  [63:0]    ex_exu_result;
    wire            exu_out_valid;
    assign          exu_over = (id_ex_valid & exu_out_valid);
    assign          exu_idle = ~(id_ex_valid & ~exu_out_valid);// ~exu_busy
    wire  [63:0]    exu_src1_forward;
    wire  [63:0]    exu_src2_forward;
    exu u_exu (
        .clk                 (clk                   ),
        .rst                 (rst                   ),
        .inst_32             (ex_inst_32            ),
        .flush               (ex_flush              ),
        .exu_in_valid        (id_ex_valid           ),
        .exu_src1            (exu_src1_forward      ),
        .exu_src2            (exu_src2_forward      ),
        .exu_sel_add_sub     (ex_exu_sel_add_sub    ),
        .exu_sel_sub         (ex_exu_sel_sub        ),
        .exu_sel_slt         (ex_exu_sel_slt        ),
        .exu_sel_sltu        (ex_exu_sel_sltu       ),
        .exu_sel_and         (ex_exu_sel_and        ),
        .exu_sel_or          (ex_exu_sel_or         ),
        .exu_sel_xor         (ex_exu_sel_xor        ),
        .exu_sel_sll         (ex_exu_sel_sll        ),
        .exu_sel_srl         (ex_exu_sel_srl        ),
        .exu_sel_sra         (ex_exu_sel_sra        ),
        .exu_result          (ex_exu_result         ),
        .exu_out_valid       (exu_out_valid         ),
        .mul_valid           (ex_mul_valid          ),
        .mul_signed          (ex_mul_signed         ),
        .mul_res_lo          (ex_mul_res_lo         ),
        .div_valid           (ex_div_valid          ),
        .div_signed          (ex_div_signed         ),
        .div_quotient        (ex_div_quotient       )
    );

    /********************* ex_mem_reg *********************/
    wire [63:0]     ex_x_rd =   ex_rd_w_src_exu ? ex_exu_result : 
                                ex_rd_w_src_csr ? ex_csr_r_data : 0;
    wire            mem_idle;
    wire            mem_wb_ready;
    wire            ex_mem_valid;
    wire [ 2:0]     mem_funct3              ;
    wire [31:0]     mem_pc                  ;
    wire [31:0]     mem_inst                ;
    wire [ 4:0]     mem_rs1                 ;
    wire [ 4:0]     mem_rs2                 ;
    wire [63:0]     mem_x_rs2               ;
    wire [63:0]     mem_x_rd                ;
    wire [ 4:0]     mem_rd                  ;
    wire            mem_rd_idx_0            ;
    wire            mem_rd_w_en             ;
    wire            mem_rd_w_src_exu        ;
    wire            mem_rd_w_src_mem        ;
    wire            mem_rd_w_src_csr        ;
    wire            mem_csr_w_en            ;
    wire [11:0]     mem_csr_addr            ;
    wire [63:0]     mem_csr_r_data          ;
    wire [63:0]     mem_exu_result          ;
    wire            mem_inst_system_ebreak  ;
    wire            mem_inst_load           ;
    wire            mem_inst_store          ;
    wire [63:0]     ex_x_rs2_forward    =   ex_x_rs2_forward_mem  ? mem_x_rd : 
                                            ex_x_rs2_forward_wb ? wb_x_rd  : ex_x_rs2;

    ex_mem_reg u_ex_mem_reg(
        .clk                    (clk                    ),
        .rst                    (rst                    ),
        .mem_idle               (mem_idle               ),
        .in_valid               (exu_over               ),
        .in_ready               (mem_wb_ready           ),
        .in_funct3              (ex_funct3              ),
        .in_pc                  (ex_pc                  ),
        .in_inst                (ex_inst                ),
        .in_rs1                 (ex_rs1                 ),
        .in_rs2                 (ex_rs2                 ),
        .in_x_rs2               (ex_x_rs2_forward       ),
        .in_x_rd                (ex_x_rd                ),
        .in_rd                  (ex_rd                  ),
        .in_rd_idx_0            (ex_rd_idx_0            ),
        .in_rd_w_en             (ex_rd_w_en             ),
        .in_rd_w_src_exu        (ex_rd_w_src_exu        ),
        .in_rd_w_src_mem        (ex_rd_w_src_mem        ),
        .in_rd_w_src_csr        (ex_rd_w_src_csr        ),
        .in_csr_w_en            (ex_csr_w_en            ),
        .in_csr_addr            (ex_csr_addr            ),
        .in_csr_r_data          (ex_csr_r_data          ),
        .in_exu_result          (ex_exu_result          ),
        .in_inst_system_ebreak  (ex_inst_system_ebreak  ),
        .in_inst_load           (ex_inst_load           ),
        .in_inst_store          (ex_inst_store          ),
        .out_valid              (ex_mem_valid           ),
        .out_ready              (ex_mem_ready           ),
        .out_funct3             (mem_funct3             ),
        .out_pc                 (mem_pc                 ),
        .out_inst               (mem_inst               ),
        .out_rs1                (mem_rs1                ),
        .out_rs2                (mem_rs2                ),
        .out_x_rs2              (mem_x_rs2              ),
        .out_x_rd               (mem_x_rd               ),
        .out_rd                 (mem_rd                 ),
        .out_rd_idx_0           (mem_rd_idx_0           ),
        .out_rd_w_en            (mem_rd_w_en            ),
        .out_rd_w_src_exu       (mem_rd_w_src_exu       ),
        .out_rd_w_src_mem       (mem_rd_w_src_mem       ),
        .out_rd_w_src_csr       (mem_rd_w_src_csr       ),
        .out_csr_w_en           (mem_csr_w_en           ),
        .out_csr_addr           (mem_csr_addr           ),
        .out_csr_r_data         (mem_csr_r_data         ),
        .out_exu_result         (mem_exu_result         ),
        .out_inst_system_ebreak (mem_inst_system_ebreak ),
        .out_inst_load          (mem_inst_load          ),
        .out_inst_store         (mem_inst_store         )
    );

    /********************* lsu *********************/
    wire            mem_lsu_r_ready = mem_inst_load;
    wire            mem_lsu_r_valid;
    wire            mem_lsu_w_valid = mem_inst_store;
    wire            mem_lsu_w_ready;
    wire  [63:0]    mem_lsu_r_data;
    wire            mem_busy = (mem_lsu_r_ready && ~mem_lsu_r_valid) || (mem_lsu_w_valid && ~mem_lsu_w_ready);
    assign          mem_idle = ~mem_busy;
    
    //AW
    wire [ 3:0]               LSU_AXI_AWID;
    wire [31:0]               LSU_AXI_AWADDR;
    wire [ 7:0]               LSU_AXI_AWLEN;
    wire [ 2:0]               LSU_AXI_AWSIZE;
    wire [ 1:0]               LSU_AXI_AWBURST;
    wire                      LSU_AXI_AWLOCK;
    wire [ 3:0]               LSU_AXI_AWCACHE;
    wire [ 2:0]               LSU_AXI_AWPROT;
    wire [ 3:0]               LSU_AXI_AWQOS;
    wire [ 3:0]               LSU_AXI_AWREGION;
    wire                      LSU_AXI_AWUSER;
    wire                      LSU_AXI_AWVALID;
    wire                      LSU_AXI_AWREADY;
    //W 
    wire [63:0]               LSU_AXI_WDATA;
    wire [ 7:0]               LSU_AXI_WSTRB;
    wire                      LSU_AXI_WLAST;
    wire                      LSU_AXI_WUSER;
    wire                      LSU_AXI_WVALID;
    wire                      LSU_AXI_WREADY;
    //BR
    wire [ 3:0]               LSU_AXI_BID;
    wire [ 1:0]               LSU_AXI_BRESP;
    wire                      LSU_AXI_BUSER;
    wire                      LSU_AXI_BVALID;
    wire                      LSU_AXI_BREADY;
    //AR
    wire [ 3:0]               LSU_AXI_ARID;
    wire [31:0]               LSU_AXI_ARADDR;
    wire [ 7:0]               LSU_AXI_ARLEN;
    wire [ 2:0]               LSU_AXI_ARSIZE;
    wire [ 1:0]               LSU_AXI_ARBURST;
    wire                      LSU_AXI_ARLOCK;
    wire [ 3:0]               LSU_AXI_ARCACHE;
    wire [ 2:0]               LSU_AXI_ARPROT;
    wire [ 3:0]               LSU_AXI_ARQOS;
    wire [ 3:0]               LSU_AXI_ARREGION;
    wire                      LSU_AXI_ARUSER;
    wire                      LSU_AXI_ARVALID;
    wire                      LSU_AXI_ARREADY;
    //R
    wire [ 3:0]               LSU_AXI_RID;
    wire [63:0]               LSU_AXI_RDATA;
    wire [ 1:0]               LSU_AXI_RRESP;
    wire                      LSU_AXI_RLAST;
    wire                      LSU_AXI_RUSER;
    wire                      LSU_AXI_RVALID;
    wire                      LSU_AXI_RREADY;

    lsu u_lsu(
        .clk                (clk                ),
        .rst                (rst                ),
        .funct3             (mem_funct3         ),
        .lsu_addr           (mem_exu_result[31:0]),
        .lsu_r_ready        (mem_lsu_r_ready    ),
        .lsu_r_data         (mem_lsu_r_data     ),
        .lsu_r_valid        (mem_lsu_r_valid    ),
        .lsu_w_valid        (mem_lsu_w_valid    ),
        .lsu_w_data         (mem_x_rs2          ),
        .lsu_w_ready        (mem_lsu_w_ready    ),
            
        .LSU_AXI_AWID           (LSU_AXI_AWID),
        .LSU_AXI_AWADDR         (LSU_AXI_AWADDR),
        .LSU_AXI_AWLEN          (LSU_AXI_AWLEN),
        .LSU_AXI_AWSIZE         (LSU_AXI_AWSIZE),
        .LSU_AXI_AWBURST        (LSU_AXI_AWBURST),
        .LSU_AXI_AWLOCK         (LSU_AXI_AWLOCK),
        .LSU_AXI_AWCACHE        (LSU_AXI_AWCACHE),
        .LSU_AXI_AWPROT         (LSU_AXI_AWPROT),
        .LSU_AXI_AWQOS          (LSU_AXI_AWQOS),
        .LSU_AXI_AWREGION       (LSU_AXI_AWREGION),
        .LSU_AXI_AWUSER         (LSU_AXI_AWUSER),
        .LSU_AXI_AWVALID        (LSU_AXI_AWVALID),
        .LSU_AXI_AWREADY        (LSU_AXI_AWREADY),

        .LSU_AXI_WDATA          (LSU_AXI_WDATA),
        .LSU_AXI_WSTRB          (LSU_AXI_WSTRB),
        .LSU_AXI_WLAST          (LSU_AXI_WLAST),
        .LSU_AXI_WUSER          (LSU_AXI_WUSER),
        .LSU_AXI_WVALID         (LSU_AXI_WVALID),
        .LSU_AXI_WREADY         (LSU_AXI_WREADY),
        
        .LSU_AXI_BID            (LSU_AXI_BID),
        .LSU_AXI_BRESP          (LSU_AXI_BRESP),
        .LSU_AXI_BUSER          (LSU_AXI_BUSER),
        .LSU_AXI_BVALID         (LSU_AXI_BVALID),
        .LSU_AXI_BREADY         (LSU_AXI_BREADY),
        
        .LSU_AXI_ARID           (LSU_AXI_ARID),
        .LSU_AXI_ARADDR         (LSU_AXI_ARADDR),
        .LSU_AXI_ARLEN          (LSU_AXI_ARLEN),
        .LSU_AXI_ARSIZE         (LSU_AXI_ARSIZE),
        .LSU_AXI_ARBURST        (LSU_AXI_ARBURST),
        .LSU_AXI_ARLOCK         (LSU_AXI_ARLOCK),
        .LSU_AXI_ARCACHE        (LSU_AXI_ARCACHE),
        .LSU_AXI_ARPROT         (LSU_AXI_ARPROT),
        .LSU_AXI_ARQOS          (LSU_AXI_ARQOS),
        .LSU_AXI_ARREGION       (LSU_AXI_ARREGION),
        .LSU_AXI_ARUSER         (LSU_AXI_ARUSER),
        .LSU_AXI_ARVALID        (LSU_AXI_ARVALID),
        .LSU_AXI_ARREADY        (LSU_AXI_ARREADY),
        
        .LSU_AXI_RID            (LSU_AXI_RID),
        .LSU_AXI_RDATA          (LSU_AXI_RDATA),
        .LSU_AXI_RRESP          (LSU_AXI_RRESP),
        .LSU_AXI_RLAST          (LSU_AXI_RLAST),
        .LSU_AXI_RUSER          (LSU_AXI_RUSER),
        .LSU_AXI_RVALID         (LSU_AXI_RVALID),
        .LSU_AXI_RREADY         (LSU_AXI_RREADY)
    );
    
    slave_axi_4 u_lsu_slave_axi_4 (
        .clk(clk),
        .rst(rst),

        .S_AXI_AWID         (LSU_AXI_AWID),
        .S_AXI_AWADDR       (LSU_AXI_AWADDR),
        .S_AXI_AWLEN        (LSU_AXI_AWLEN),
        .S_AXI_AWSIZE       (LSU_AXI_AWSIZE),
        .S_AXI_AWBURST      (LSU_AXI_AWBURST),
        .S_AXI_AWLOCK       (LSU_AXI_AWLOCK),
        .S_AXI_AWCACHE      (LSU_AXI_AWCACHE),
        .S_AXI_AWPROT       (LSU_AXI_AWPROT),
        .S_AXI_AWQOS        (LSU_AXI_AWQOS),
        .S_AXI_AWREGION     (LSU_AXI_AWREGION),
        .S_AXI_AWUSER       (LSU_AXI_AWUSER),
        .S_AXI_AWVALID      (LSU_AXI_AWVALID),
        .S_AXI_AWREADY      (LSU_AXI_AWREADY),
        .S_AXI_WDATA        (LSU_AXI_WDATA),
        .S_AXI_WSTRB        (LSU_AXI_WSTRB),
        .S_AXI_WLAST        (LSU_AXI_WLAST),
        .S_AXI_WUSER        (LSU_AXI_WUSER),
        .S_AXI_WVALID       (LSU_AXI_WVALID),
        .S_AXI_WREADY       (LSU_AXI_WREADY),
        .S_AXI_BID          (LSU_AXI_BID),
        .S_AXI_BRESP        (LSU_AXI_BRESP),
        .S_AXI_BUSER        (LSU_AXI_BUSER),
        .S_AXI_BVALID       (LSU_AXI_BVALID),
        .S_AXI_BREADY       (LSU_AXI_BREADY),
        .S_AXI_ARID         (LSU_AXI_ARID),
        .S_AXI_ARADDR       (LSU_AXI_ARADDR),
        .S_AXI_ARLEN        (LSU_AXI_ARLEN),
        .S_AXI_ARSIZE       (LSU_AXI_ARSIZE),
        .S_AXI_ARBURST      (LSU_AXI_ARBURST),
        .S_AXI_ARLOCK       (LSU_AXI_ARLOCK),
        .S_AXI_ARCACHE      (LSU_AXI_ARCACHE),
        .S_AXI_ARPROT       (LSU_AXI_ARPROT),
        .S_AXI_ARQOS        (LSU_AXI_ARQOS),
        .S_AXI_ARREGION     (LSU_AXI_ARREGION),
        .S_AXI_ARUSER       (LSU_AXI_ARUSER),
        .S_AXI_ARVALID      (LSU_AXI_ARVALID),
        .S_AXI_ARREADY      (LSU_AXI_ARREADY),
        .S_AXI_RID          (LSU_AXI_RID),
        .S_AXI_RDATA        (LSU_AXI_RDATA),
        .S_AXI_RRESP        (LSU_AXI_RRESP),
        .S_AXI_RLAST        (LSU_AXI_RLAST),
        .S_AXI_RUSER        (LSU_AXI_RUSER),
        .S_AXI_RVALID       (LSU_AXI_RVALID),
        .S_AXI_RREADY       (LSU_AXI_RREADY)
    );

    /********************* mem_wb_reg *********************/
    wire            mem_wb_valid            ;
    wire  [31:0]    wb_pc                   ;
    wire  [31:0]    wb_inst                 ;
    wire  [ 4:0]    wb_rs1                  ;
    wire  [ 4:0]    wb_rs2                  ;
    wire  [63:0]    wb_x_rs2                ;
    wire  [63:0]    wb_x_rd                 ;
    wire  [ 4:0]    wb_rd                   ;
    wire            wb_rd_idx_0             ;
    wire            wb_rd_w_en              ;
    wire            wb_rd_w_src_exu         ;
    wire            wb_rd_w_src_mem         ;
    wire            wb_rd_w_src_csr         ;
    wire            wb_csr_w_en             ;
    wire  [11:0]    wb_csr_addr             ;
    wire  [63:0]    wb_csr_r_data           ;
    wire  [63:0]    wb_exu_result           ;
    wire  [63:0]    wb_lsu_r_data           ;
    wire            wb_inst_system_ebreak   ;
    wire  [63:0]    mem_x_rd_       = mem_rd_w_src_mem ? mem_lsu_r_data : mem_x_rd;
    mem_wb_reg u_mem_wb_reg(
	    .clk                    (clk                    ),
	    .rst                    (rst                    ),
        .in_valid               (ex_mem_valid & mem_idle),
        .in_pc                  (mem_pc                 ),
        .in_inst                (mem_inst               ),
        .in_rs1                 (mem_rs1                ),
        .in_rs2                 (mem_rs2                ),
        .in_x_rs2               (mem_x_rs2              ),
        .in_x_rd                (mem_x_rd_              ),
        .in_rd                  (mem_rd                 ),
        .in_rd_idx_0            (mem_rd_idx_0           ),
        .in_rd_w_en             (mem_rd_w_en            ),
        .in_rd_w_src_exu        (mem_rd_w_src_exu       ),
        .in_rd_w_src_mem        (mem_rd_w_src_mem       ),
        .in_rd_w_src_csr        (mem_rd_w_src_csr       ),
        .in_csr_w_en            (mem_csr_w_en           ),
        .in_csr_addr            (mem_csr_addr           ),
        .in_csr_r_data          (mem_csr_r_data         ),
        .in_exu_result          (mem_exu_result         ),
        .in_lsu_r_data          (mem_lsu_r_data         ),
        .in_inst_system_ebreak  (mem_inst_system_ebreak ),

        .out_valid              (mem_wb_valid           ),
        .out_ready              (mem_wb_ready           ),
        .out_pc                 (wb_pc                  ),
        .out_inst               (wb_inst                ),
        .out_rs1                (wb_rs1                 ),
        .out_rs2                (wb_rs2                 ),
        .out_x_rs2              (wb_x_rs2               ),
        .out_x_rd               (wb_x_rd                ),
        .out_rd                 (wb_rd                  ),
        .out_rd_idx_0           (wb_rd_idx_0            ),
        .out_rd_w_en            (wb_rd_w_en             ),
        .out_rd_w_src_exu       (wb_rd_w_src_exu        ),
        .out_rd_w_src_mem       (wb_rd_w_src_mem        ),
        .out_rd_w_src_csr       (wb_rd_w_src_csr        ),
        .out_csr_w_en           (wb_csr_w_en            ),
        .out_csr_addr           (wb_csr_addr            ),
        .out_csr_r_data         (wb_csr_r_data          ),
        .out_exu_result         (wb_exu_result          ),
        .out_lsu_r_data         (wb_lsu_r_data          ),
        .out_inst_system_ebreak (wb_inst_system_ebreak  )
    );
    
    /********************* data_hazard_ctrl *********************/
    wire          ex_lsu_r_ready = ex_inst_load;
    wire          ex_x_rs1_forward_mem ;
    wire          ex_x_rs2_forward_mem ;
    wire          ex_x_rs1_forward_wb;
    wire          ex_x_rs2_forward_wb;
    wire          exu_src1_forward_mem ;
    wire          exu_src2_forward_mem ;
    wire          exu_src2_forward_mem_csr ;
    wire          exu_src1_forward_wb;
    wire          exu_src2_forward_wb;
    wire          bju_x_rs1_forward_mem  ;
    wire          bju_x_rs2_forward_mem  ;
    wire          bju_x_rs1_forward_wb   ;
    wire          bju_x_rs2_forward_wb   ;
    data_hazard_ctrl u_data_hazard_ctrl(
        .id_inst_branch             (id_inst_branch             ),
        .id_inst_jalr               (id_inst_jalr               ),
        .id_rs1                     (id_rs1                     ),
        .id_rs2                     (id_rs2                     ),
        .ex_rs1                     (ex_rs1                     ),
        .ex_rs2                     (ex_rs2                     ),
        .ex_exu_src1_xrs1           (ex_exu_src1_xrs1           ),
        .ex_exu_src2_xrs2           (ex_exu_src2_xrs2           ),
        .ex_exu_src2_csr            (ex_exu_src2_csr            ),
        .ex_csr_addr                (ex_csr_addr                ),
        .ex_rd_w_en                 (ex_rd_w_en                 ),
        .ex_rd_idx_0                (ex_rd_idx_0                ),
        .ex_rd                      (ex_rd                      ),
        .ex_lsu_r_ready             (ex_lsu_r_ready             ),
        .mem_csr_addr               (mem_csr_addr               ),
        .mem_csr_w_en               (mem_csr_w_en               ),
        .mem_rd_w_en                (mem_rd_w_en                ),
        .mem_rd_idx_0               (mem_rd_idx_0               ),
        .mem_rd                     (mem_rd                     ),
        .mem_lsu_r_ready            (mem_lsu_r_ready            ),
        .mem_lsu_r_valid            (mem_lsu_r_valid            ),
        .wb_rd_w_en                 (wb_rd_w_en                 ),
        .wb_rd_idx_0                (wb_rd_idx_0                ),
        .wb_rd                      (wb_rd                      ),
        .ex_x_rs1_forward_mem       (ex_x_rs1_forward_mem       ),
        .ex_x_rs2_forward_mem       (ex_x_rs2_forward_mem       ),
        .ex_x_rs1_forward_wb        (ex_x_rs1_forward_wb        ),
        .ex_x_rs2_forward_wb        (ex_x_rs2_forward_wb        ),
        .exu_src1_forward_mem       (exu_src1_forward_mem       ),
        .exu_src2_forward_mem       (exu_src2_forward_mem       ),
        .exu_src2_forward_mem_csr   (exu_src2_forward_mem_csr   ),
        .exu_src1_forward_wb        (exu_src1_forward_wb        ),
        .exu_src2_forward_wb        (exu_src2_forward_wb        ),
        .bju_x_rs1_forward_mem      (bju_x_rs1_forward_mem      ),
        .bju_x_rs2_forward_mem      (bju_x_rs2_forward_mem      ),
        .bju_x_rs1_forward_wb       (bju_x_rs1_forward_wb       ),
        .bju_x_rs2_forward_wb       (bju_x_rs2_forward_wb       ),
        .if_id_stall                (if_id_stall                )
    );

    /********************* id_bju_x_rs_forward *********************/
    assign id_x_rs1_forward =   bju_x_rs1_forward_mem   ? mem_x_rd : 
                                bju_x_rs1_forward_wb    ?  wb_x_rd : id_x_rs1;
    assign id_x_rs2_forward =   bju_x_rs2_forward_mem   ? mem_x_rd : 
                                bju_x_rs2_forward_wb    ?  wb_x_rd : id_x_rs2;

    /********************* ex_exu_src_forward *********************/
    ex_exu_src_forward u_ex_exu_src_forward(
        .ex_exu_src1                (ex_exu_src1                ),
        .ex_exu_src2                (ex_exu_src2                ),
        .mem_x_rd                   (mem_x_rd                   ),
        .mem_exu_result             (mem_exu_result             ),
        .exu_src1_forward_mem       (exu_src1_forward_mem       ),
        .exu_src2_forward_mem       (exu_src2_forward_mem       ),
        .exu_src2_forward_mem_csr   (exu_src2_forward_mem_csr   ),
        .wb_x_rd                    (wb_x_rd                    ),
        .exu_src1_forward_wb        (exu_src1_forward_wb        ),
        .exu_src2_forward_wb        (exu_src2_forward_wb        ),
	    .exu_src1_forward           (exu_src1_forward           ),
	    .exu_src2_forward           (exu_src2_forward           )
    );

import "DPI-C" function void stopCPU();
	always @(posedge clk) begin
		if(wb_inst_system_ebreak) begin
			stopCPU();
		end
	end

endmodule

`endif /* TOP_V */


