/*************************************************************
 * @ name           : div_shift_64clk.v
 * @ description    : Shift-Divider 64 clock
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-6-4
*************************************************************/
`ifndef DIV_SHIFT_64_CLK_V
`define DIV_SHIFT_64_CLK_V

`define A_SIGN  div_signed[1]
`define B_SIGN  div_signed[0]
`define A_NEGA  (`A_SIGN & (divw ? dividend[31] : dividend[63]))
`define B_NEGA  (`B_SIGN & (divw ? divisor[31] : divisor[63]))

`define A_SIGNR  div_signed_r[1]
`define B_SIGNR  div_signed_r[0]
`define A_NEGAR  (`A_SIGNR & dividend_s )
`define B_NEGAR  (`B_SIGNR & divisor_s )

/*  dividend      divisor     quotient    remainder
 *      +           +             +           +
 *      +           -             -           +
 *      -           +             -           -
 *      -           -             +           -
*/

module div_shift_64clk (
    input                   clk          ,  
    input                   rst          ,  
    input                   div_valid    ,
    input                   flush        ,  // cancel
    input                   divw         ,  // 32 bit div
    input       [ 1:0]      div_signed   ,  // 2'b11 (signed x signed ) ;2’b10 (signed x unsigned ) ;2’b00 (unsigned x unsigned ) ;
    input       [63:0]      dividend     ,  // dividend
    input       [63:0]      divisor      ,  // divisor
    output reg              div_ready    ,  // ready for receive
    output reg              out_valid    ,  // result valid
    output      [63:0]      quotient     ,  // 
    output      [63:0]      remainder       // 
);

    wire [63:0]         dividend_abs;
    wire [63:0]         divisor_abs;
    reg                 dividend_s;  // A
    reg                 divisor_s;   // B sign
    reg [1:0]           div_signed_r;
    reg [127:0]         shifter;        // 128 bit shifter
    reg  [63:0]         divisor_r;
    reg [0:0]           state;          // FSM state
    reg [6:0]           div_cnt;
    reg                 divw_r;
    wire [64:0]         alu_a;
    wire [64:0]         alu_b;
    wire [64:0]         alu_out;
    wire                div_handshake;
    wire                cnt_max;
    wire    [63:0]      quotient_abs;
    wire    [63:0]      remainder_abs;

    localparam DIV_CNT_MAX = 6'd63;
    localparam FSM_IDLE = 1'd0,
               FSM_DIV = 1'd1;

    assign div_handshake = div_valid & div_ready;
    assign cnt_max = (div_cnt == DIV_CNT_MAX);

    assign dividend_abs = `A_NEGA ? - dividend : dividend;
    assign divisor_abs = `B_NEGA ? - divisor : divisor;

    assign alu_a = divw_r ? shifter[95:31] : shifter[127:63];
    assign alu_b  = {1'b0, divisor_r};
    assign alu_out = alu_a - alu_b;
    assign quotient_abs = divw_r ? {32'b0, shifter[31:0]} : shifter[63:0];
    assign remainder_abs = divw_r ? {32'b0, shifter[63:32]} : shifter[127:64];

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
            divisor_r       <= 64'b0;
            dividend_s      <= 1'b0;
            divisor_s       <= 1'b0;
            div_cnt         <= 6'b0;
            div_ready       <= 1'b0;
            out_valid       <= 1'b0;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if (div_handshake) begin
                        shifter         <= divw ? {96'b0, dividend_abs[31:0]} : {64'b0, dividend_abs};
                        divisor_r       <= divw ? {32'b0, divisor_abs[31:0]} : divisor_abs;
                        dividend_s      <= divw ? dividend[31] : dividend[63];
                        divisor_s       <= divw ? divisor[31] : divisor[63];
                        div_signed_r    <= div_signed;
                        div_cnt         <= divw ? 6'd32 : 6'd0;
                        div_ready       <= 1'b0;
                        divw_r          <= divw;
                    end else begin
                        div_ready       <= 1'b1;
                    end
                    out_valid       <= 1'b0;
                end
                
                FSM_DIV: begin
                    shifter         <= divw_r ? {shifter[126:63], (alu_out[64] ? {shifter[62:0], 1'b0} : {alu_out[31:0], shifter[30:0], 1'b1})}
                                              : (alu_out[64] ? {shifter[126:0], 1'b0} : {alu_out[63:0], shifter[62:0], 1'b1});
                    div_cnt <= div_cnt + 1;
                    if (cnt_max) begin
                        out_valid       <= 1'b1;
                    end
                end

                default: begin
                    shifter         <= 128'b0;
                    divisor_r       <= 64'b0;
                    dividend_s      <= 1'b0;
                    divisor_s       <= 1'b0;
                    div_cnt         <= 6'b0;
                    div_ready       <= 1'b0;
                    out_valid       <= 1'b0;
                end
            endcase
        end
    end

endmodule //div_shift

`endif