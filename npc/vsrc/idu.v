/*************************************************************
 * @ name           : idu.v
 * @ description    : Instruction Decode Unit
 * @ use module     : MuxKeyWithDefault
 * @ author         : K
 * @ date modified  : 2023-8-9
*************************************************************/
`ifndef IDU_V
`define IDU_V

`include "common.v"

module idu (
    input  [31:0]               inst                ,
    output [ 2:0]               funct3              ,
    output [63:0]               imm                 ,
    output [4:0]                rs1                 ,
    output [4:0]                rs2                 ,
    output [4:0]                rd                  ,
    output                      rd_idx_0            ,
    output                      rs1_idx_0           ,
    output                      rs2_idx_0           ,
    output                      rd_w_en             ,
    output                      rd_w_src_exu        ,
    output                      rd_w_src_mem        ,
    output                      rd_w_src_csr        ,
    output                      csr_r_en            ,
    output                      csr_w_en            ,
    output [11:0]               csr_addr            ,
    output                      exu_src1_xrs1       ,
    output                      exu_src1_pc         ,
    output                      exu_src1_xrs1_i     ,
    output                      exu_src1_rs1        ,
    output                      exu_src1_rs1_i      ,
    output                      exu_src2_xrs2       ,
    output                      exu_src2_imm        ,
    output                      exu_src2_csr        ,
    output                      exu_src2_4          ,
    output                      exu_sel_add_sub     ,
    output                      exu_sel_sub         ,
    output                      exu_sel_slt         ,
    output                      exu_sel_sltu        ,
    output                      exu_sel_and         ,
    output                      exu_sel_or          ,
    output                      exu_sel_xor         ,
    output                      exu_sel_sll         ,
    output                      exu_sel_srl         ,
    output                      exu_sel_sra         ,
    output                      mul_valid           ,
    output  [ 1:0]              mul_signed          ,
    output                      mul_res_lo          ,
    output                      div_valid           ,
    output  [ 1:0]              div_signed          ,
    output                      div_quotient        ,
    output                      inst_load           ,
    output                      inst_store          ,
    output                      inst_system         ,
    output                      inst_jal            ,
    output                      inst_jalr           ,
    output                      inst_branch         ,
    output                      inst_branch_beq     ,
    output                      inst_branch_bne     ,
    output                      inst_branch_blt     ,
    output                      inst_branch_bge     ,
    output                      inst_branch_bltu    ,
    output                      inst_branch_bgeu    ,
    output                      inst_32             ,
    output                      inst_system_ecall   ,
    output                      inst_system_mret    ,
    output                      inst_system_ebreak
);
    wire    [ 6:0]  opcode = inst[6:0];
    assign          funct3 = inst[14:12];
    wire    [ 6:0]  funct7 = inst[31:25];
    assign          rd  = inst[11:7];
    assign          rs1 = inst[19:15];
    assign          rs2 = inst[24:20];

    assign rd_idx_0 = rd == 5'b0;
    assign rs1_idx_0 = rs1 == 5'b0;
    assign rs2_idx_0 = rs2 == 5'b0;

    wire    opcode_1_0_11   = opcode[1:0] == 2'b11;

    wire    opcode_4_2_000  = opcode[4:2] == 3'b000;
    wire    opcode_4_2_001  = opcode[4:2] == 3'b001;
    wire    opcode_4_2_010  = opcode[4:2] == 3'b010;
    wire    opcode_4_2_011  = opcode[4:2] == 3'b011;
    wire    opcode_4_2_100  = opcode[4:2] == 3'b100;
    wire    opcode_4_2_101  = opcode[4:2] == 3'b101;
    wire    opcode_4_2_110  = opcode[4:2] == 3'b110;
    wire    opcode_4_2_111  = opcode[4:2] == 3'b111;

    wire    opcode_6_5_00   = opcode[6:5] == 2'b00;
    wire    opcode_6_5_01   = opcode[6:5] == 2'b01;
    wire    opcode_6_5_10   = opcode[6:5] == 2'b10;
    wire    opcode_6_5_11   = opcode[6:5] == 2'b11;

    wire    funct3_000      = funct3 == 3'b000;
    wire    funct3_001      = funct3 == 3'b001;
    wire    funct3_010      = funct3 == 3'b010;
    wire    funct3_011      = funct3 == 3'b011;
    wire    funct3_100      = funct3 == 3'b100;
    wire    funct3_101      = funct3 == 3'b101;
    wire    funct3_110      = funct3 == 3'b110;
    wire    funct3_111      = funct3 == 3'b111;

    wire    imm_sign        = funct7[6];
    wire    funct7_5        = funct7[5];
    wire    funct7_0000001  = funct7 == 7'b0000001;

    assign  inst_load       = opcode_6_5_00 & opcode_4_2_000 & opcode_1_0_11;   //LOAD                //    x[rd] = M[x[rs1] + imm]
    wire    inst_load_fp    = opcode_6_5_00 & opcode_4_2_001 & opcode_1_0_11;   //LOAD-FP             
    wire    inst_misc_mem   = opcode_6_5_00 & opcode_4_2_011 & opcode_1_0_11;   //MISC-MEM            
    wire    inst_op_imm     = opcode_6_5_00 & opcode_4_2_100 & opcode_1_0_11;   //OP-IMM              //    x[rd] = x[rs1] op imm;
    wire    inst_auipc      = opcode_6_5_00 & opcode_4_2_101 & opcode_1_0_11;   //AUIPC               //    x[rd] = pc + imm;
    wire    inst_op_imm_32  = opcode_6_5_00 & opcode_4_2_110 & opcode_1_0_11;   //OP-IMM-32           //    x[rd] = sext(x[rs1] op imm);
    assign  inst_store      = opcode_6_5_01 & opcode_4_2_000 & opcode_1_0_11;   //STORE               //    M[x[rs1] + imm] = x[rs2]
    wire    inst_store_fp   = opcode_6_5_01 & opcode_4_2_001 & opcode_1_0_11;   //STORE-FP            
    wire    inst_amo        = opcode_6_5_01 & opcode_4_2_011 & opcode_1_0_11;   //AMO                 
    wire    inst_op         = opcode_6_5_01 & opcode_4_2_100 & opcode_1_0_11;   //OP                  //    x[rd] = x[rs1] op x[rs2];
    wire    inst_lui        = opcode_6_5_01 & opcode_4_2_101 & opcode_1_0_11;   //LUI                 //    x[rd] = imm
    wire    inst_op_32      = opcode_6_5_01 & opcode_4_2_110 & opcode_1_0_11;   //OP-32               //    x[rd] = sext(x[rs1] op x[rs2]);
    wire    inst_op_fp      = opcode_6_5_10 & opcode_4_2_100 & opcode_1_0_11;   //OP-FP               
    assign  inst_branch     = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11;   //BRANCH              //    xxx = x[rs1]-x[rs2]; if(xxx) pc += imm;
    assign  inst_jalr       = opcode_6_5_11 & opcode_4_2_001 & opcode_1_0_11;   //JALR                //    x[rd] = pc + 4; pc = (x[rs1] + imm) & ~1;
    assign  inst_jal        = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11;   //JAL                 //    x[rd] = pc + 4; pc += imm;
    assign  inst_system     = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11;   //SYSTEM              //    rd = zext(csr); csr |= rs1; csr &= ~rs1
//  wire    inst_custom_0   = opcode_6_5_00 & opcode_4_2_010 & opcode_1_0_11;   //custom-0            
//  wire    inst_custom_1   = opcode_6_5_01 & opcode_4_2_010 & opcode_1_0_11;   //custom-1            
//  wire    inst_madd       = opcode_6_5_10 & opcode_4_2_000 & opcode_1_0_11;   //MADD                
//  wire    inst_msub       = opcode_6_5_10 & opcode_4_2_001 & opcode_1_0_11;   //MSUB                
//  wire    inst_nmsub      = opcode_6_5_10 & opcode_4_2_010 & opcode_1_0_11;   //NMSUB               
//  wire    inst_nmadd      = opcode_6_5_10 & opcode_4_2_011 & opcode_1_0_11;   //NMADD               
//  wire    inst_reserved_0 = opcode_6_5_10 & opcode_4_2_101 & opcode_1_0_11;   //reserved            
//  wire    inst_custom_2   = opcode_6_5_10 & opcode_4_2_110 & opcode_1_0_11;   //custom-2/rv128      
//  wire    inst_reserved_1 = opcode_6_5_11 & opcode_4_2_010 & opcode_1_0_11;   //reserved            
//  wire    inst_reserved_2 = opcode_6_5_11 & opcode_4_2_101 & opcode_1_0_11;   //reserved            
//  wire    inst_custom_3   = opcode_6_5_11 & opcode_4_2_110 & opcode_1_0_11;   //custom-3/rv128      

    wire    inst_type_r     = inst_amo | inst_op | inst_op_32 | inst_op_fp;
    wire    inst_type_i     = inst_load | inst_load_fp | inst_misc_mem | inst_op_imm | inst_op_imm_32 | inst_jalr | inst_system;
    wire    inst_type_s     = inst_store | inst_store_fp;
    wire    inst_type_b     = inst_branch;
    wire    inst_type_u     = inst_auipc | inst_lui;
    wire    inst_type_j     = inst_jal;
//  wire    inst_type_r4    = inst_madd | inst_msub | inst_nmsub | inst_nmadd;

    assign  imm =   inst_type_i ? {{(64-12){imm_sign}}, inst[31:20]}                                         :
                    inst_type_s ? {{(64-12){imm_sign}}, inst[31:25], inst[11:7]}                             :
                    inst_type_b ? {{(64-13){imm_sign}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}    :
                    inst_type_u ? {{(64-32){imm_sign}}, inst[31:12], 12'b0}                                  :
                    inst_type_j ? {{(64-21){imm_sign}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}  : 64'b0;
                  //inst_type_r ? 64'b0                                                                      : 64'b0;

    assign  inst_32             = inst_op_32 | inst_op_imm_32;
    wire    inst_op_op_imm      = inst_op | inst_op_imm;
    wire    inst_op_op_32       = inst_op | inst_op_32;
    wire    inst_op_x           = inst_op_op_imm | inst_32;
    // assign  inst_system_jump    = inst_system & funct3_000;
    // assign  inst_system_csr     = inst_system & ~funct3_000;
    assign  inst_system_ecall   = inst == `INST_ECALL;
    assign  inst_system_mret    = inst == `INST_MRET;
    assign  inst_system_ebreak  = inst == `INST_EBREAK;

    assign  inst_branch_beq     = inst_branch & funct3_000;
    assign  inst_branch_bne     = inst_branch & funct3_001;
    assign  inst_branch_blt     = inst_branch & funct3_100;
    assign  inst_branch_bge     = inst_branch & funct3_101;
    assign  inst_branch_bltu    = inst_branch & funct3_110;
    assign  inst_branch_bgeu    = inst_branch & funct3_111;

    assign  rd_w_src_exu = inst_auipc | inst_lui | inst_jal | inst_jalr | inst_op_x;
    assign  rd_w_src_mem = inst_load;
    assign  rd_w_src_csr = inst_system;
    assign  rd_w_en      = rd_w_src_exu | rd_w_src_mem | rd_w_src_csr;
    
    wire    exu_src1_csr_xrs1   = inst_system & (funct3_001 | funct3_010);  // CSRRW | CSRRS
    wire    exu_src1_csr_xrs1_i = inst_system & funct3_011;                 // CSRRC
    wire    exu_src1_csr_rs1    = inst_system & (funct3_101 | funct3_110);  // CSRRWI | CSRRSI
    wire    exu_src1_csr_rs1_i  = inst_system & funct3_111;                 // CSRRCI

    assign  exu_src1_xrs1   = inst_op_x | inst_load | inst_store | inst_branch | exu_src1_csr_xrs1;
    assign  exu_src1_pc     = inst_auipc | inst_jal | inst_jalr;
    assign  exu_src1_xrs1_i = exu_src1_csr_xrs1_i;
    assign  exu_src1_rs1    = exu_src1_csr_rs1   ;
    assign  exu_src1_rs1_i  = exu_src1_csr_rs1_i ;

    assign  exu_src2_xrs2   = inst_branch | inst_op_op_32;
    assign  exu_src2_imm    = inst_auipc | inst_lui | inst_load | inst_store | inst_op_imm | inst_op_imm_32;
    assign  exu_src2_csr    = inst_system & (funct3_010 | funct3_011 | funct3_110 | funct3_111); // CSRRS | CSRRC | CSRRSI | CSRRCI
    assign  exu_src2_4      = inst_jal | inst_jalr;

    assign  exu_sel_add_sub = inst_lui | inst_auipc | inst_jal | inst_jalr | inst_load | inst_store | 
                              (inst_op_x & funct3_000) |                // ADD SUB
                              (inst_system & (funct3_001 | funct3_101));// CSRRW CSRRWI
    assign  exu_sel_sub     = (inst_op_op_32 & funct3_000 & funct7_5);  // SUB
    assign  exu_sel_slt     = (inst_op_op_imm & funct3_010);            // SLT SLTI
    assign  exu_sel_sltu    = (inst_op_op_imm & funct3_011);            // SLTU SLTUI
    assign  exu_sel_and     = (inst_op_op_imm & funct3_111) |           // AND ANDI
                              (inst_system & (funct3_011 | funct3_111));// CSRRC CSRRCI
    assign  exu_sel_or      = (inst_op_op_imm & funct3_110) |           // OR ORI
                              (inst_system & (funct3_010 | funct3_110));// CSRRS CSRRSI
    assign  exu_sel_xor     = (inst_op_op_imm & funct3_100);            // XOR XORI
    assign  exu_sel_sll     = (inst_op_x & funct3_001);                 // SLL SLLI SLLW SLLIW
    assign  exu_sel_srl     = (inst_op_x & funct3_101 & ~funct7_5);     // SRL SRLI SRLW SRLIW
    assign  exu_sel_sra     = (inst_op_x & funct3_101 & funct7_5);      // SRA SRAI SRAW SRAIW
    
    wire    mul_div_valid   = inst_op_op_32 & funct7_0000001;
    assign  mul_valid       = mul_div_valid & ~funct3[2];
    wire    mul_signed_1    = ~funct3_011;
    wire    mul_signed_0    = funct3_000 | funct3_001;
    assign  mul_signed      = {mul_signed_1, mul_signed_0};
    assign  mul_res_lo      = funct3_000;
    assign  div_valid       = mul_div_valid &  funct3[2];
    assign  div_signed      = {2{~funct3[0]}};
    assign  div_quotient    = ~funct3[1];
    
    assign  csr_r_en        = inst_system & ((funct3_010 | funct3_011 | funct3_110 | funct3_111) | ((funct3_001 | funct3_101) & ~rd_idx_0));
    assign  csr_w_en        = inst_system & (((funct3_010 | funct3_011 | funct3_110 | funct3_111) & ~rs1_idx_0) | (funct3_001 | funct3_101));

    localparam CSR_ADDR_MTVEC        = 12'h305;
    localparam CSR_ADDR_MEPC        = 12'h341;
    assign      csr_addr = (inst_system_ebreak | inst_system_ecall) ? CSR_ADDR_MTVEC :   //ebreak, ecall
                          inst_system_mret ? CSR_ADDR_MEPC :                            //mret                
                          inst[31:20];                                                  //CSRRW

endmodule //idu

`endif /* IDU_V */