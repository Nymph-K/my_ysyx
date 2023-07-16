/*************************************************************
 * @ name           : mul_booth_wallace_16b.v
 * @ description    : Booth-Wallace-Multiplier
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-24
*************************************************************/
`ifndef MUL_BOOTH_WALLACE_16B_V
`define MUL_BOOTH_WALLACE_16B_V

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

module mul_booth_wallace_16b (
    input                   clk          ,  
    input                   rst          ,  
    input                   mul_valid    ,
    input                   flush        ,  // cancel
    input                   mulw         ,  // 32 bit mul
    input       [ 1:0]      mul_signed   ,  // 2'b11 (signed x signed ) ;2’b10 (signed x unsigned ) ;2’b00 (unsigned x unsigned ) ;
    input       [15:0]      multiplicand ,  // multiplicand
    input       [15:0]      multiplier   ,  // multiplier
    output reg              mul_ready    ,  // ready for receive
    output reg              out_valid    ,  // result valid
    output      [15:0]      result_hi    ,  // high 16 bit result
    output      [15:0]      result_lo       // high 16 bit result
);

    reg                     multiplicand_s; // AR sign
    reg                     multiplier_s;   // BR sign
    reg  [31:0]             multiplicand_r; // AR
    reg  [16:0]             multiplier_r;   // BR, b-1
    reg  [1:0]              mul_signed_r;
    reg                     state;          // FSM state
    wire [31:0]             adder_out;
    wire                    mul_handshake;

    wire [31:0]             pp_x[0:7];
    wire [2:0]              pp_y[0:7];
    wire [31:0]             pp_p[0:7];
    wire [7:0]              pp_c;

    assign pp_x[0] = `AR;
    assign pp_x[1] = pp_x[0] << 2;
    assign pp_x[2] = pp_x[1] << 2;
    assign pp_x[3] = pp_x[2] << 2;
    assign pp_x[4] = pp_x[3] << 2;
    assign pp_x[5] = pp_x[4] << 2;
    assign pp_x[6] = pp_x[5] << 2;
    assign pp_x[7] = pp_x[6] << 2;

    assign pp_y[0] = `BR[ 2: 0];
    assign pp_y[1] = `BR[ 4: 2];
    assign pp_y[2] = `BR[ 6: 4];
    assign pp_y[3] = `BR[ 8: 6];
    assign pp_y[4] = `BR[10: 8];
    assign pp_y[5] = `BR[12:10];
    assign pp_y[6] = `BR[14:12];
    assign pp_y[7] = `BR[16:14];

	generate
		for (genvar n = 0; n < 8; n = n + 1) begin: pp_gen
            mul_partial_product #(.WIDTH(32)) u_mul_partial_product(
                .multiplicand (pp_x[n]),
                .multiplier   (pp_y[n]),
                .p            (pp_p[n]),
                .c            (pp_c[n]) 
            );
		end
	endgenerate

    wire [31:0]         pp_p_tmp0, pp_p_tmp1, pp_p_tmp2, pp_p_tmp3, pp_p_tmp4, pp_p_tmp5, pp_p_tmp6, pp_p_tmp7;
    assign pp_p_tmp0 = pp_p[0];
    assign pp_p_tmp1 = pp_p[1];
    assign pp_p_tmp2 = pp_p[2];
    assign pp_p_tmp3 = pp_p[3];
    assign pp_p_tmp4 = pp_p[4];
    assign pp_p_tmp5 = pp_p[5];
    assign pp_p_tmp6 = pp_p[6];
    assign pp_p_tmp7 = pp_p[7];

`define   WALLACE_TREE_E
    reg  [7:0]          wt_n[0:31];
`ifdef    WALLACE_TREE_E
    reg  [4:0]          wt_c_pre[0:31];
    wire [4:0]          wt_c_nxt[0:31];
`else
    reg  [5:0]          wt_c_pre[0:31];
    wire [5:0]          wt_c_nxt[0:31];
`endif
    wire [31:0]         wt_c;
    wire [31:0]         wt_s;

    integer i;
    always @(*) begin
		for ( i = 0; i < 32; i = i + 1) begin
            wt_n[i] = {pp_p_tmp7[i], pp_p_tmp6[i], pp_p_tmp5[i], pp_p_tmp4[i], pp_p_tmp3[i], pp_p_tmp2[i], pp_p_tmp1[i], pp_p_tmp0[i]};
            if(i != 0) wt_c_pre[i] = wt_c_nxt[i-1];
`ifdef    WALLACE_TREE_E
            else wt_c_pre[0] = pp_c[4:0];
`else
            else wt_c_pre[0] = pp_c[5:0];
`endif
		end
    end
	generate
		for (genvar n = 0; n < 32; n = n + 1) begin: wt_gen
`ifdef    WALLACE_TREE_E
            wallace_tree_8_e2
`else
            wallace_tree_8 
`endif
            u_wallace_tree_8(
                .n       (wt_n[n]),
                .c_pre   (wt_c_pre[n]),
                .c_nxt   (wt_c_nxt[n]),
                .c       (wt_c[n]),
                .s       (wt_s[n])
            );
		end
	endgenerate

`ifdef    WALLACE_TREE_E
    assign adder_out = {wt_c, pp_c[7]} + wt_s + pp_c[5] + pp_c[6];
`else
    assign adder_out = {wt_c, pp_c[7]} + wt_s + pp_c[6];
`endif

    localparam FSM_IDLE = 1'd0,
               FSM_MUL = 1'd1;

    assign mul_handshake = mul_valid & mul_ready;
    assign {result_hi, result_lo} = adder_out[31:0];

    always @(posedge clk ) begin
        if (rst | flush) begin
            state <= FSM_IDLE;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if(mul_handshake) state <= FSM_MUL;
                end
                FSM_MUL: begin
                    state <= FSM_IDLE;
                end
                default: begin
                    state <= FSM_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk ) begin
        if (rst | flush) begin
            multiplicand_s  <= 1'b0;
            multiplier_s    <= 1'b0;
            mul_ready       <= 1'b0;
            out_valid       <= 1'b0;
        end else begin
            case (state)
                FSM_IDLE: begin
                    if (mul_handshake) begin
                        multiplicand_r  <= {(`A_SIGN ? {(16){`A[15]}} : 16'b0), `A};
                        multiplier_r    <= {`B, 1'b0};
                        multiplicand_s  <= `A[15];
                        multiplier_s    <= `B[15];
                        mul_signed_r    <= mul_signed;
                        mul_ready       <= 1'b0;
                    end else begin
                        mul_ready       <= 1'b1;
                    end
                    out_valid       <= 1'b0;
                end
                
                FSM_MUL: begin
                    out_valid       <= 1'b1;
                end

                default: begin
                    multiplicand_s  <= 1'b0;
                    multiplier_s    <= 1'b0;
                    mul_ready       <= 1'b0;
                    out_valid       <= 1'b0;
                end
            endcase
        end
    end

endmodule //mul_booth_wallace

`endif