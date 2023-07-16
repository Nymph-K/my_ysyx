/*************************************************************
 * @ name           : mul_booth_32clk.v
 * @ description    : Shift-Multiplier 32/64 clock
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-25
*************************************************************/
`ifndef MUL_BOOTH_32CLK_V
`define MUL_BOOTH_32CLK_V

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

// `define RADIX_2         2
`define RADIX_4         4

`ifdef RADIX_4
    `define RADIX       4
    `define   POSITION  63
`else //RADIX_2
    `define RADIX       2
    `define   POSITION  63
`endif

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

module mul_booth_32clk (
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

    reg                             multiplicand_s; // A sign
    reg                             multiplier_s;   // B sign
    reg  [64:0]                     multiplier_r;   // bn-1, ... , b0, b-1
    reg  [1:0]                      mul_signed_r;
    reg  [127 + $clog2(`RADIX):0]   p;              // 128 bit p
    reg                             state;          // FSM state
    reg  [6:0]                      mul_cnt;
    reg                             mulw_r;
    reg  [63 + $clog2(`RADIX):0]    alu_a;          // [sign] a << n
    reg  [63 + $clog2(`RADIX):0]    a_signex;       // [sign] a << n
    wire [63 + $clog2(`RADIX):0]    alu_b;          // [sign] b << n
    wire [64:0]                     alu_bw;
    wire [63 + $clog2(`RADIX):0]    alu_out;
    wire                            mul_handshake;
    wire                            cnt_max;
    reg                             alu_c;

    localparam MUL_CNT_MAX = 7'd64;
    localparam FSM_IDLE = 1'd0,
               FSM_MUL = 1'd1;
               
    assign alu_bw = {32'b0, `AR_SIGN ? p[63] : 1'b0, p[63:32]};
`ifdef RADIX_4
    wire [63 + $clog2(`RADIX):0]    a_signex_2 = a_signex << 1;          // a_signex * 2
`endif

    always @(*) begin
        case (`BR[$clog2(`RADIX):0])
`ifdef RADIX_4
            3'b000: begin alu_c = 0; alu_a =   0; end
            3'b001: begin alu_c = 0; alu_a =   a_signex; end
            3'b010: begin alu_c = 0; alu_a =   a_signex; end
            3'b011: begin alu_c = 0; alu_a =   a_signex_2; end
            3'b100: begin alu_c = 1; alu_a = ~ a_signex_2; end
            3'b101: begin alu_c = 1; alu_a = ~ a_signex; end
            3'b110: begin alu_c = 1; alu_a = ~ a_signex; end
            3'b111: begin alu_c = 0; alu_a =   0; end
`else //(`RADIX == `RADIX_2)
            2'b00: begin alu_c = 0; alu_a =   0; end
            2'b01: begin alu_c = 0; alu_a =   a_signex; end
            2'b10: begin alu_c = 1; alu_a = ~ a_signex; end
            2'b11: begin alu_c = 0; alu_a =   0; end
`endif
        endcase
    end

    assign alu_b  = mulw_r ? {{(32 + $clog2(`RADIX)){p[63 + $clog2(`RADIX)]}}, p[63 + $clog2(`RADIX):32 + $clog2(`RADIX)]} : {{($clog2(`RADIX)){p[127 + $clog2(`RADIX)]}}, p[127 + $clog2(`RADIX):64 + $clog2(`RADIX)]};
    assign alu_out = alu_a + alu_b + alu_c;
    assign mul_handshake = mul_valid & mul_ready;
    assign {result_hi, result_lo} = p[127:0];
    assign cnt_max = mul_cnt >= MUL_CNT_MAX;

    always @(posedge clk ) begin
        if (rst | flush) begin
            state <= FSM_IDLE;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if(mul_handshake) state <= FSM_MUL;
                end
                FSM_MUL: begin
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
            p               <= 128'b0;
            multiplicand_s  <= 1'b0;
            multiplier_s    <= 1'b0;
            mul_cnt         <= 7'b0;
            mul_ready       <= 1'b0;
            out_valid       <= 1'b0;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if (mul_handshake) begin
                        p               <= 128'b0;
                        a_signex        <= mulw ? {(`A_SIGN ? {(32 + $clog2(`RADIX)){`A[31]}}: {(32 + $clog2(`RADIX)){1'b0}}), `A[31:0]} :                         {(`A_SIGN ? {($clog2(`RADIX)){`A[63]}} : {($clog2(`RADIX)){1'b0}}), `A};
                        multiplicand_s  <= mulw ? `A[31] : `A[63];
                        multiplier_s    <= mulw ? `B[31] : `B[63];
                        mul_signed_r    <= mul_signed;
                        mul_cnt         <= mulw ? 7'd32 : 7'd0;
                        mul_ready       <= 1'b0;
                        mulw_r          <= mulw;
                        multiplier_r    <= {mulw ? {(`B_SIGN ? {(32){`B[31]}} : 32'b0), `B[31:0]} : `B, 1'b0};// bn-1, ... , b0, b-1
                    end else begin
                        mul_ready       <= 1'b1;
                    end
                    out_valid       <= 1'b0;
                end
                
                FSM_MUL: begin
                    p               <= mulw_r ? {{(32){alu_out[63 + $clog2(`RADIX)]}}, alu_out, p[31 + $clog2(`RADIX):$clog2(`RADIX)]} : {alu_out, p[63 + $clog2(`RADIX):$clog2(`RADIX)]};
                    mul_cnt         <= mul_cnt + $clog2(`RADIX);
                    multiplier_r    <= {({($clog2(`RADIX)){(`BR_SIGN ? `BR[64] : 1'b0)}}), `BR[64:$clog2(`RADIX)]};
                    if (cnt_max) begin
                        out_valid       <= 1'b1;
                    end
                end

                default: begin
                    p               <= 128'b0;
                    multiplicand_s  <= 1'b0;
                    multiplier_s    <= 1'b0;
                    mul_cnt         <= 7'b0;
                    mul_ready       <= 1'b0;
                    out_valid       <= 1'b0;
                end
            endcase
        end
    end

    // function integer clog2;
    //     input integer value;
    //           integer temp;
    //     begin
    //         temp = value - 1;
    //         for (clog2 = 0; temp > 0; clog2 = clog2 + 1) begin
    //             temp = temp >> 1;
    //         end
    //     end
    // endfunction

    // function integer power2;
    //     input integer value;
    //     begin
    //         power2 = 1 << value;
    //     end
    // endfunction


endmodule //mul_booth_32clk

`endif