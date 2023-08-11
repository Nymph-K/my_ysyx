/*************************************************************
 * @ name           : div.v
 * @ description    : Divider Unit
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-8-3
*************************************************************/
`ifndef DIV_V
`define DIV_V

`include "common.v"

module exu_div (
    input                   clk          ,  
    input                   rst          ,  
    input                   div_valid    ,
    input                   flush        ,  // cancel
    input                   divw         ,  // 32 bit div
    input       [ 1:0]      div_signed   ,  // 2'b11 (signed / signed ) ;2’b10 (signed / unsigned ) ;2’b00 (unsigned / unsigned ) ;
    input       [63:0]      dividend     ,  // dividend
    input       [63:0]      divisor      ,  // divisor
    output                  div_ready    ,  // ready for receive
    output                  out_valid    ,  // result valid
    output      [63:0]      quotient     ,  // 
    output      [63:0]      remainder       // 
);

    wire    [63:0]  x_1 = div_valid ? (divw ? {{32{div_signed[1] ? dividend[31] : 1'b0}}, dividend[31:0]} : dividend) : 0;
    wire    [63:0]  x_2 = div_valid ? (divw ? {{32{div_signed[0] ? divisor[31] : 1'b0}}, divisor[31:0]} : divisor) : 1;
    
    assign quotient  = div_valid ? (x_1 / x_2) : 0;
    assign remainder = div_valid ? (x_1 % x_2) : 0;

    assign div_ready = div_valid;
    assign out_valid = div_valid;

endmodule //exu_div

`endif