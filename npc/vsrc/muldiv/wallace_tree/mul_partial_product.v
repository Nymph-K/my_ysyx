/*************************************************************
 * @ name           : mul_partial_product.v
 * @ description    : 
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-24
*************************************************************/
`ifndef MUL_PARTIAL_PRODUCT_V
`define MUL_PARTIAL_PRODUCT_V

module mul_partial_product #(
    parameter WIDTH = 128
)(
    input       [WIDTH - 1:0]     multiplicand ,  // A multiplicand
    input       [        2:0]     multiplier   ,  // B multiplier
    output reg  [WIDTH - 1:0]     p            ,  // partial product
    output reg                    c               // cin
);

    wire [WIDTH - 1:0]    a_x_1 = multiplicand;           // a * 1
    wire [WIDTH - 1:0]    a_x_2 = {multiplicand[WIDTH - 2:0], 1'b0};             // a * 2

    always @(*) begin
        case (multiplier)
            3'b000: begin c = 0;    p =   0    ; end
            3'b001: begin c = 0;    p =   a_x_1; end
            3'b010: begin c = 0;    p =   a_x_1; end
            3'b011: begin c = 0;    p =   a_x_2; end
            3'b100: begin c = 1;    p = ~ a_x_2; end
            3'b101: begin c = 1;    p = ~ a_x_1; end
            3'b110: begin c = 1;    p = ~ a_x_1; end
            3'b111: begin c = 0;    p = 0      ; end
        endcase
    end

endmodule

`endif