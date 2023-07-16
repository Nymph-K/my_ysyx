/*************************************************************
 * @ name           : csa.v
 * @ description    : 
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-24
*************************************************************/
`ifndef CSA_V
`define CSA_V
module csa (
    input   a,
    input   b,
    input   c,
    output  s,
    output  cout
);
`define CSA_SIM

`ifdef CSA_SIM
    assign {cout,s} = a + b + c;
`else
    assign s = a ^ b ^ c; // (a & ~b & ~c) | (~a & b & ~c) | (~a & ~b & c) | (a & b & c)
    assign cout = (a & b) | (a & c) | (b & c);
`endif
`endif
endmodule