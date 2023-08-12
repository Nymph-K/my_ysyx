/*************************************************************
 * @ name           : exu.v
 * @ description    : EXecution Unit
 * @ use module     : alu, mdu
 * @ author         : K
 * @ date modified  : 2023-7-30
*************************************************************/
`ifndef EXU_V
`define EXU_V

`include "common.v"

module exu (
    input           clk             ,
    input           rst             ,
    input           inst_32         ,
    input           flush           ,
    input           exu_in_valid    ,
    input  [63:0]   exu_src1        ,
    input  [63:0]   exu_src2        ,
    input           exu_sel_add_sub ,
    input           exu_sel_sub     ,
    input           exu_sel_slt     ,
    input           exu_sel_sltu    ,
    input           exu_sel_and     ,
    input           exu_sel_or      ,
    input           exu_sel_xor     ,
    input           exu_sel_sll     ,
    input           exu_sel_srl     ,
    input           exu_sel_sra     ,
    output [63:0]   exu_result      ,
    output          exu_out_valid   ,
    /* MUL */
    input           mul_valid       ,
    input  [ 1:0]   mul_signed      ,
    input           mul_res_lo      ,
    /* DIV */
    input           div_valid       ,
    input  [ 1:0]   div_signed      ,
    input           div_quotient    
);

    assign exu_result = mul_valid ? (mul_res_lo     ? mul_result_lo : mul_result_hi) : 
                        div_valid ? (div_quotient   ? quotient      : remainder)     : (inst_32 ? {{32{alu_result[31]}}, alu_result[31:0]} : alu_result);
    assign exu_out_valid =  mul_valid ? mul_out_valid : 
                            div_valid ? div_out_valid : 1;

    /********************* alu *********************/
    wire [63:0]   alu_result;
    exu_alu u_exu_alu (
        .inst_32         (inst_32        ),
        .a               (exu_src1       ),
        .b               (exu_src2       ),
        .alu_sel_add_sub (exu_sel_add_sub),
        .alu_sel_sub     (exu_sel_sub    ),
        .alu_sel_slt     (exu_sel_slt    ),
        .alu_sel_sltu    (exu_sel_sltu   ),
        .alu_sel_and     (exu_sel_and    ),
        .alu_sel_or      (exu_sel_or     ),
        .alu_sel_xor     (exu_sel_xor    ),
        .alu_sel_sll     (exu_sel_sll    ),
        .alu_sel_srl     (exu_sel_srl    ),
        .alu_sel_sra     (exu_sel_sra    ),
        .result          (alu_result     )
    );

    /********************* mul *********************/
    wire mul_out_valid, mul_ready;
    wire [63:0]   mul_result_hi;
    wire [63:0]   mul_result_lo;
    exu_mul u_exu_mul(
        .clk          (clk          ),
        .rst          (rst          ),
        .mul_valid    (mul_valid    ),
        .flush        (flush        ),
        .mulw         (inst_32      ),
        .mul_signed   (mul_signed   ),
        .multiplicand (exu_src1     ),
        .multiplier   (exu_src2     ),
        .mul_ready    (mul_ready    ),
        .out_valid    (mul_out_valid),
        .result_hi    (mul_result_hi),
        .result_lo    (mul_result_lo) 
    );

    /********************* div *********************/
    wire div_ready, div_out_valid;
    wire [63:0]   quotient;
    wire [63:0]   remainder;
    exu_div u_exu_div(
        .clk          (clk          ),
        .rst          (rst          ),
        .div_valid    (div_valid    ),
        .flush        (flush        ),
        .divw         (inst_32      ),
        .div_signed   (div_signed   ),
        .dividend     (exu_src1     ),
        .divisor      (exu_src2     ),
        .div_ready    (div_ready    ),
        .out_valid    (div_out_valid),
        .quotient     (quotient     ),
        .remainder    (remainder    ) 
);


endmodule //exu

`endif /* EXU_V */
