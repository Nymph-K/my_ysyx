/*************************************************************
 * @ name           : mul_booth_0term.v
 * @ description    : Shift-Multiplier
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-24
*************************************************************/
`ifndef MUL_BOOTH_0TERM_V
`define MUL_BOOTH_0TERM_V

`define A       multiplicand
`define B       multiplier
`define A_SIGN  mul_signed[1]
`define B_SIGN  mul_signed[0]

`define AR       multiplicand_r
`define BR       multiplier_r
`define AR_SIGN  mul_signed_r[1]
`define BR_SIGN  mul_signed_r[0]
`define AR_NEGA  (`AR_SIGN & multiplicand_s )
`define BR_NEGA  (`BR_SIGN & multiplier_s )

//          Radix-2                     Radix-4                     Radix-8
//
// bi,bi-1              op      bi+1,bi,bi-1         op     bi+2,bi+1,bi,bi-1    op 
// 00                  +0 S     000                 +0 S    0000                +0 S
// 01                  +1 S     001                 +1 S    0001                +1 S
// 10                  -1 S     010                 +1 S    0010                +1 S
// 11                  -0 S     011                 +2 S    0011                +2 S
//                              100                 -2 S    0100                +2 S
//                              101                 -1 S    0101                +3 S
//                              110                 -1 S    0110                +3 S
//                              111                 -0 S    0111                +4 S
//                                                          1000                -4 S
//                                                          1001                -3 S
//                                                          1010                -3 S
//                                                          1011                -2 S
//                                                          1100                -2 S
//                                                          1101                -1 S
//                                                          1110                -1 S
//                                                          1111                -0 S

module mul_booth_0term (
    input                   clk          ,  
    input                   rst          ,  
    input                   mul_valid    ,
    input                   flush        ,  // cancel
    input                   mulw         ,  // 32 bit mul
    input       [ 1:0]      mul_signed   ,  // 2'b11 (signed x signed ) ;2’b10 (signed x unsigned ) ;2’b00 (unsigned x unsigned ) ;
    input       [63:0]      multiplicand ,  // multiplicand
    input       [63:0]      multiplier   ,  // multiplier
    output reg              mul_ready    ,  // ready for receive
    output reg              out_valid    ,  // result valid
    output      [63:0]      result_hi    ,  // high 64 bit result
    output      [63:0]      result_lo       // high 64 bit result
);

    reg                     multiplicand_s; // AR sign
    reg                     multiplier_s;   // BR sign
    reg  [127:0]            multiplicand_r; // AR
    reg  [64:0]             multiplier_r;   // BR, b-1
    reg  [127:0]            result;
    reg  [1:0]              mul_signed_r;
    reg                     state;          // FSM state
    reg  [6:0]              mul_cnt;
    reg                     mulw_r;
    wire [127:0]            p;
    wire [127:0]            adder_out;
    wire                    mul_handshake;
    wire                    cnt_max;
    wire                    mul_zero;
    wire                    c;

    mul_partial_product #(.WIDTH(128)) u_mul_partial_product (
        .multiplicand (multiplicand_r),
        .multiplier   (multiplier_r[2:0]),
        .p            (p),
        .c            (c) 
    );

    localparam MUL_CNT_MAX = 7'd64;
    localparam FSM_IDLE = 1'd0,
               FSM_MUL = 1'd1;

    assign adder_out = result + p + c;
    assign mul_handshake = mul_valid & mul_ready;
    assign {result_hi, result_lo} = result[127:0];
    assign cnt_max = mul_cnt >= MUL_CNT_MAX;
    assign mul_zero = (multiplier_r == 0);

    always @(posedge clk ) begin
        if (rst | flush) begin
            state <= FSM_IDLE;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if(mul_handshake) state <= FSM_MUL;
                end
                FSM_MUL: begin
                    if (cnt_max | mul_zero) begin
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
            result          <= 128'b0;
            multiplicand_s  <= 1'b0;
            multiplier_s    <= 1'b0;
            mul_cnt         <= 7'b0;
            mul_ready       <= 1'b0;
            out_valid       <= 1'b0;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if (mul_handshake) begin
                        multiplicand_r  <= mulw ? {(`A_SIGN ? {(96){`A[31]}} : 96'b0), `A[31:0]} 
                                                : {(`A_SIGN ? {(64){`A[63]}} : 64'b0), `A};
                        multiplier_r    <= {mulw ? {(`B_SIGN ? {(32){`B[31]}} : 32'b0), `B[31:0]} : `B, 1'b0};
                        result          <= 128'b0;
                        multiplicand_s  <= mulw ? `A[31] : `A[63];
                        multiplier_s    <= mulw ? `B[31] : `B[63];
                        mul_signed_r    <= mul_signed;
                        mul_cnt         <= mulw ? 7'd32 : 7'd0;
                        mul_ready       <= 1'b0;
                        mulw_r          <= mulw;
                    end else begin
                        mul_ready       <= 1'b1;
                    end
                    out_valid       <= 1'b0;
                end
                
                FSM_MUL: begin
                    multiplicand_r  <= `AR << 2;
                    multiplier_r    <= {({2{(`BR_SIGN ? `BR[64] : 1'b0)}}), `BR[64:2]};
                    result          <= adder_out;
                    mul_cnt         <= mul_cnt + 2;
                    if (cnt_max | mul_zero) begin
                        out_valid       <= 1'b1;
                    end
                end

                default: begin
                    result          <=   128'b0;
                    multiplicand_s  <= 1'b0;
                    multiplier_s    <= 1'b0;
                    mul_cnt         <= 7'b0;
                    mul_ready       <= 1'b0;
                    out_valid       <= 1'b0;
                end
            endcase
        end
    end

endmodule //mul_booth_0term

`endif