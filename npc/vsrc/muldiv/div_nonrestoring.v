/*************************************************************
 * @ name           : div_nonrestoring.v
 * @ description    : Shift-Divider 64 clock
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-6-4
*************************************************************/
`ifndef DIV_NONRESTORING_V
`define DIV_NONRESTORING_V

`define A_SIGN  div_signed[1]
`define B_SIGN  div_signed[0]
`define A_NEGA  (`A_SIGN & (divw ? dividend[31] : dividend[63]))
`define B_NEGA  (`B_SIGN & (divw ? divisor[31] : divisor[63]))
`define A_NEGAW (`A_SIGN & dividend[31])
`define B_NEGAW (`B_SIGN & divisor[31])
`define A_NEGAD (`A_SIGN & dividend[63])
`define B_NEGAD (`B_SIGN & divisor[63])

`define A_NEGAR  dividend_n
`define B_NEGAR  divisor_n

/*  dividend      divisor     quotient    remainder
 *      +           +             +           +
 *      +           -             -           +
 *      -           +             -           -
 *      -           -             +           -
*/

module div_nonrestoring (
    input                   clk          ,  
    input                   rst          ,  
    input                   div_valid    ,
    input                   flush        ,  // cancel
    input                   divw         ,  // 32 bit div
    input       [ 1:0]      div_signed   ,  // 2'b11 (signed / signed ) ;2’b10 (signed / unsigned ) ;2’b00 (unsigned / unsigned ) ;
    input       [63:0]      dividend     ,  // dividend
    input       [63:0]      divisor      ,  // divisor
    output reg              div_ready    ,  // ready for receive
    output reg              out_valid    ,  // result valid
    output      [63:0]      quotient     ,  // 
    output      [63:0]      remainder       // 
);

    reg  [127:0]        shifter;        // {0,A} {rem, quo}
    reg  [64:0]         divisor_abs;    // abs(B)
    reg                 dividend_n;     // A negative
    reg                 divisor_n;      // B negative
    reg  [1:0]          state;          // FSM state
    reg  [6:0]          div_cnt;
    reg                 divw_r;
    
    wire [64:0]         alu_a;
    wire [64:0]         alu_b;
    wire [64:0]         alu_out;
    reg                 alu_out_sign;   // alu out negative
    wire                div_handshake;
    wire                cnt_max;
    wire [63:0]         quotient_abs;
    wire [63:0]         remainder_abs;

    localparam DIV_CNT_MAX = 6'd63;
    localparam FSM_IDLE = 2'd0,
               FSM_DIV = 2'd1,
               FSM_REM = 2'd2;

    assign div_handshake = div_valid & div_ready;
    assign cnt_max = (div_cnt == DIV_CNT_MAX);

    assign dividend_r = `A_NEGA ? - dividend : dividend;

    assign alu_a = shifter[127:63];
    assign alu_b  = divisor_abs;
    assign alu_out = alu_out_sign ? alu_a + alu_b : alu_a - alu_b;

    assign quotient_abs = shifter[63:0];
    assign remainder_abs = alu_out_sign ? shifter[127:64] + divisor_abs : shifter[127:64] ;

    assign quotient = (`A_NEGAR ^ `B_NEGAR) ? -quotient_abs : quotient_abs;
    assign remainder = `A_NEGAR ? -remainder_abs : remainder_abs;

    always @(posedge clk ) begin
        if (rst | flush) begin
            state <= FSM_IDLE;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if(div_handshake) state <= FSM_DIV;
                end
                FSM_DIV: begin
                    if (cnt_max) begin
                        state <= FSM_IDLE;
                    end
                end
                default: begin
                    state <= FSM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk ) begin
        if (rst | flush) begin
            shifter         <= 128'b0;
            divisor_abs     <= 65'b0;
            dividend_n      <= 1'b0;
            divisor_n       <= 1'b0;
            div_cnt         <= 6'b0;
            div_ready       <= 1'b0;
            out_valid       <= 1'b0;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if (div_handshake) begin
                        shifter         <= {64'b0, divw ? {`A_NEGAW ? -dividend[31:0] : dividend[31:0], 32'b0} : (`A_NEGAD ? -dividend[63:0] : dividend[63:0])};
                        divisor_abs     <= divw ? {33'b0, (`B_NEGAW ? -divisor[31:0] : divisor[31:0])} : {(`B_NEGAD ? -{divisor[63], divisor[63:0]} : {1'b0, divisor[63:0]})};
                        dividend_n      <= `A_SIGN & (divw ? dividend[31] : dividend[63]);
                        divisor_n       <= `B_SIGN & (divw ? divisor[31] : divisor[63]);
                        alu_out_sign    <= 1'b0;
                        div_cnt         <= divw ? 6'd32 : 6'd0;
                        div_ready       <= 1'b0;
                        divw_r          <= divw;
                    end else begin
                        div_ready       <= 1'b1;
                    end
                    out_valid       <= 1'b0;
                end
                
                FSM_DIV: begin
                    alu_out_sign    <= divw_r ? alu_out[32] : alu_out[64];
                    shifter         <= {alu_out[63:0], shifter[62:0], ~(divw_r ? alu_out[32] : alu_out[64])};
                    div_cnt         <= div_cnt + 1;
                    if (cnt_max) begin
                        out_valid       <= 1'b1;
                    end
                end

                default: begin
                    shifter         <= 128'b0;
                    divisor_abs     <= 65'b0;
                    dividend_n      <= 1'b0;
                    divisor_n       <= 1'b0;
                    div_cnt         <= 6'b0;
                    div_ready       <= 1'b0;
                    out_valid       <= 1'b0;
                end
            endcase
        end
    end

endmodule //div_shift

`endif