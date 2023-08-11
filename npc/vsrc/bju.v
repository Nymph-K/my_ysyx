/*************************************************************
 * @ name           : bju.v
 * @ description    : Branch and Jump Unit
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-7-29
*************************************************************/
module bju (
	input   [63:0]  pc,
	input   [63:0]  imm,
	input   [63:0]  x_rs1,
	input   [63:0]  x_rs2,
	input           inst_jalr,      //    x[rd] = pc + 4; pc = (x[rs1] + imm) & ~1;
	input           inst_jal,       //    x[rd] = pc + 4; pc += imm;
    input           inst_branch_beq,//    xxx = x[rs1]-x[rs2]; if(xxx) pc += imm;
    input           inst_branch_bne,
    input           inst_branch_blt,
    input           inst_branch_bge,
    input           inst_branch_bltu,
    input           inst_branch_bgeu,
    input           inst_system_ecall,
    input           inst_system_mret,
	input   [63:0]  csr_r_data,
    output  [63:0]  dnpc,
    output          pc_b_j
);
    // wire            cout;
    // wire    [63:0]  sub_result;
    
    // assign          {cout, sub_result} = x_rs1 - x_rs2;
	// wire            overflow = (x_rs1[63] != x_rs2[63]) && (x_rs1[63] != sub_result[63]);//signed
    // wire            equal = ~(| sub_result);
	// wire            smaller_s = sub_result[63] ^ overflow;
	// wire            smaller_u = ~cout;
    
    wire            equal = x_rs1 == x_rs2;
	wire            smaller_s = $signed(x_rs1) < $signed(x_rs2);
	wire            smaller_u = $unsigned(x_rs1) < $unsigned(x_rs2);

    wire            branch_true =   (inst_branch_beq    &&  equal    ) ||
                                    (inst_branch_bne    && ~equal    ) ||
                                    (inst_branch_blt    &&  smaller_s) ||
                                    (inst_branch_bge    && ~smaller_s) ||
                                    (inst_branch_bltu   &&  smaller_u) ||
                                    (inst_branch_bgeu   && ~smaller_u) ;

    assign          dnpc =  inst_jal | branch_true                  ? pc + imm              : 
                            inst_jalr                               ? (x_rs1 + imm) & ~1    : 
                            inst_system_ecall | inst_system_mret    ? csr_r_data            : 0;

    assign          pc_b_j = inst_jal || inst_jalr || branch_true || inst_system_ecall || inst_system_mret;

endmodule //bju