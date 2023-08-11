/*************************************************************
 * @ name           : mdu.v
 * @ description    : Multiply Unit
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-8-3
*************************************************************/
`ifndef MDU_V
`define MDU_V

`include "common.v"

module exu_mul (
    input                   clk          ,  
    input                   rst          ,  
    input                   mul_valid    ,
    input                   flush        ,  // cancel
    input                   mulw         ,  // 32 bit mul
    input       [ 1:0]      mul_signed   ,  // 2'b11 (signed x signed ) ;2’b10 (signed x unsigned ) ;2’b00 (unsigned x unsigned ) ;
    input       [63:0]      multiplicand ,  // multiplicand
    input       [63:0]      multiplier   ,  // multiplier
    output                  mul_ready    ,  // ready for receive
    output                  out_valid    ,  // result valid
    output      [63:0]      result_hi    ,  // high 64 bit result
    output      [63:0]      result_lo       // high 64 bit result
);

    wire    [63:0]  x_1 = mul_valid ? (mulw ? {{32{mul_signed[1] ? multiplicand[31] : 1'b0}}, multiplicand[31:0]} : multiplicand) : 0;
    wire    [63:0]  x_2 = mul_valid ? (mulw ? {{32{mul_signed[0] ? multiplier[31] : 1'b0}}, multiplier[31:0]} : multiplier) : 0;
    wire   [127:0]  res = mul_valid ? (x_1 * x_2) : 0;

    assign mul_ready = mul_valid;
    assign out_valid = mul_valid;

    assign result_hi = res[127:64];
    assign result_lo = res[ 63: 0];

endmodule //exu_mul

`endif