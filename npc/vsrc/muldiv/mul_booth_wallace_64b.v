/*************************************************************
 * @ name           : mul_booth_wallace_64b.v
 * @ description    : Booth-Wallace-Multiplier
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-24
*************************************************************/
`ifndef MUL_BOOTH_WALLACE_64B_V
`define MUL_BOOTH_WALLACE_64B_V

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

module mul_booth_wallace_64b (
    input                   clk          ,  
    input                   rst          ,  
    input                   mul_valid    ,
    input                   flush        ,  // cancel
    input                   mulw         ,  // 32 bit mul
    input       [ 1:0]      mul_signed   ,  // 2'b11 (signed x signed ) ;2’b10 (signed x unsigned ) ;2’b00 (unsigned x unsigned ) ;
    input       [63:0]      multiplicand ,  // multiplicand
    input       [63:0]      multiplier   ,  // multiplier
    output reg              mul_ready    ,  // ready for receive
    output                  out_valid    ,  // result valid
    output      [63:0]      result_hi    ,  // high 64 bit result
    output      [63:0]      result_lo       // high 64 bit result
);

    reg                     multiplicand_s; // AR sign
    reg                     multiplier_s;   // BR sign
    reg  [131:0]            multiplicand_r; // AR
    reg  [66:0]             multiplier_r;   // BR, b-1
    reg  [1:0]              mul_signed_r;
    wire [131:0]            adder_out;

    reg                     in_add_valid;
    reg                     in_add_ready;
    reg                     add_out_valid;
    wire                    add_out_ready;
    reg  [131:0]            adder_a, adder_b;
    reg                     adder_c;

    wire [131:0]            pp_x[0:32];
    wire [2:0]              pp_y[0:32];
    wire [131:0]            pp_p[0:32];
    wire [32:0]             pp_c;

    assign pp_x[ 0] = {`AR[131:0]       };
    assign pp_x[ 1] = {`AR[129:0],  2'b0};
    assign pp_x[ 2] = {`AR[127:0],  4'b0};
    assign pp_x[ 3] = {`AR[125:0],  6'b0};
    assign pp_x[ 4] = {`AR[123:0],  8'b0};
    assign pp_x[ 5] = {`AR[121:0], 10'b0};
    assign pp_x[ 6] = {`AR[119:0], 12'b0};
    assign pp_x[ 7] = {`AR[117:0], 14'b0};
    assign pp_x[ 8] = {`AR[115:0], 16'b0};
    assign pp_x[ 9] = {`AR[113:0], 18'b0};
    assign pp_x[10] = {`AR[111:0], 20'b0};
    assign pp_x[11] = {`AR[109:0], 22'b0};
    assign pp_x[12] = {`AR[107:0], 24'b0};
    assign pp_x[13] = {`AR[105:0], 26'b0};
    assign pp_x[14] = {`AR[103:0], 28'b0};
    assign pp_x[15] = {`AR[101:0], 30'b0};
    assign pp_x[16] = {`AR[ 99:0], 32'b0};
    assign pp_x[17] = {`AR[ 97:0], 34'b0};
    assign pp_x[18] = {`AR[ 95:0], 36'b0};
    assign pp_x[19] = {`AR[ 93:0], 38'b0};
    assign pp_x[20] = {`AR[ 91:0], 40'b0};
    assign pp_x[21] = {`AR[ 89:0], 42'b0};
    assign pp_x[22] = {`AR[ 87:0], 44'b0};
    assign pp_x[23] = {`AR[ 85:0], 46'b0};
    assign pp_x[24] = {`AR[ 83:0], 48'b0};
    assign pp_x[25] = {`AR[ 81:0], 50'b0};
    assign pp_x[26] = {`AR[ 79:0], 52'b0};
    assign pp_x[27] = {`AR[ 77:0], 54'b0};
    assign pp_x[28] = {`AR[ 75:0], 56'b0};
    assign pp_x[29] = {`AR[ 73:0], 58'b0};
    assign pp_x[30] = {`AR[ 71:0], 60'b0};
    assign pp_x[31] = {`AR[ 69:0], 62'b0};
    assign pp_x[32] = {`AR[ 67:0], 64'b0};
    
    assign pp_y[ 0] = `BR[ 2: 0];
    assign pp_y[ 1] = `BR[ 4: 2];
    assign pp_y[ 2] = `BR[ 6: 4];
    assign pp_y[ 3] = `BR[ 8: 6];
    assign pp_y[ 4] = `BR[10: 8];
    assign pp_y[ 5] = `BR[12:10];
    assign pp_y[ 6] = `BR[14:12];
    assign pp_y[ 7] = `BR[16:14];
    assign pp_y[ 8] = `BR[18:16];
    assign pp_y[ 9] = `BR[20:18];
    assign pp_y[10] = `BR[22:20];
    assign pp_y[11] = `BR[24:22];
    assign pp_y[12] = `BR[26:24];
    assign pp_y[13] = `BR[28:26];
    assign pp_y[14] = `BR[30:28];
    assign pp_y[15] = `BR[32:30];
    assign pp_y[16] = `BR[34:32];
    assign pp_y[17] = `BR[36:34];
    assign pp_y[18] = `BR[38:36];
    assign pp_y[19] = `BR[40:38];
    assign pp_y[20] = `BR[42:40];
    assign pp_y[21] = `BR[44:42];
    assign pp_y[22] = `BR[46:44];
    assign pp_y[23] = `BR[48:46];
    assign pp_y[24] = `BR[50:48];
    assign pp_y[25] = `BR[52:50];
    assign pp_y[26] = `BR[54:52];
    assign pp_y[27] = `BR[56:54];
    assign pp_y[28] = `BR[58:56];
    assign pp_y[29] = `BR[60:58];
    assign pp_y[30] = `BR[62:60];
    assign pp_y[31] = `BR[64:62];
    assign pp_y[32] = `BR[66:64];

	generate
		for (genvar n = 0; n < 33; n = n + 1) begin: pp_gen
            mul_partial_product #(.WIDTH(132)) u_mul_partial_product(
                .multiplicand (pp_x[n]),
                .multiplier   (pp_y[n]),
                .p            (pp_p[n]),
                .c            (pp_c[n]) 
            );
		end
	endgenerate
        
    wire [131:0] pp_p_tmp0  = pp_p[ 0];
    wire [131:0] pp_p_tmp1  = pp_p[ 1];
    wire [131:0] pp_p_tmp2  = pp_p[ 2];
    wire [131:0] pp_p_tmp3  = pp_p[ 3];
    wire [131:0] pp_p_tmp4  = pp_p[ 4];
    wire [131:0] pp_p_tmp5  = pp_p[ 5];
    wire [131:0] pp_p_tmp6  = pp_p[ 6];
    wire [131:0] pp_p_tmp7  = pp_p[ 7];
    wire [131:0] pp_p_tmp8  = pp_p[ 8];
    wire [131:0] pp_p_tmp9  = pp_p[ 9];
    wire [131:0] pp_p_tmp10 = pp_p[10];
    wire [131:0] pp_p_tmp11 = pp_p[11];
    wire [131:0] pp_p_tmp12 = pp_p[12];
    wire [131:0] pp_p_tmp13 = pp_p[13];
    wire [131:0] pp_p_tmp14 = pp_p[14];
    wire [131:0] pp_p_tmp15 = pp_p[15];
    wire [131:0] pp_p_tmp16 = pp_p[16];
    wire [131:0] pp_p_tmp17 = pp_p[17];
    wire [131:0] pp_p_tmp18 = pp_p[18];
    wire [131:0] pp_p_tmp19 = pp_p[19];
    wire [131:0] pp_p_tmp20 = pp_p[20];
    wire [131:0] pp_p_tmp21 = pp_p[21];
    wire [131:0] pp_p_tmp22 = pp_p[22];
    wire [131:0] pp_p_tmp23 = pp_p[23];
    wire [131:0] pp_p_tmp24 = pp_p[24];
    wire [131:0] pp_p_tmp25 = pp_p[25];
    wire [131:0] pp_p_tmp26 = pp_p[26];
    wire [131:0] pp_p_tmp27 = pp_p[27];
    wire [131:0] pp_p_tmp28 = pp_p[28];
    wire [131:0] pp_p_tmp29 = pp_p[29];
    wire [131:0] pp_p_tmp30 = pp_p[30];
    wire [131:0] pp_p_tmp31 = pp_p[31];
    wire [131:0] pp_p_tmp32 = pp_p[32];

    reg  [32:0]          wt_n[0:131];
    reg  [29:0]          wt_c_pre[0:131];
    wire [29:0]          wt_c_nxt[0:131];
    wire [131:0]         wt_c;
    wire [131:0]         wt_s;

    integer i;
    always @(*) begin
		for ( i = 0; i < 132; i = i + 1) begin
            wt_n[i] = { pp_p_tmp32[i], 
                        pp_p_tmp31[i], 
                        pp_p_tmp30[i], 
                        pp_p_tmp29[i], 
                        pp_p_tmp28[i], 
                        pp_p_tmp27[i], 
                        pp_p_tmp26[i], 
                        pp_p_tmp25[i], 
                        pp_p_tmp24[i], 
                        pp_p_tmp23[i], 
                        pp_p_tmp22[i], 
                        pp_p_tmp21[i], 
                        pp_p_tmp20[i], 
                        pp_p_tmp19[i], 
                        pp_p_tmp18[i], 
                        pp_p_tmp17[i], 
                        pp_p_tmp16[i], 
                        pp_p_tmp15[i], 
                        pp_p_tmp14[i], 
                        pp_p_tmp13[i], 
                        pp_p_tmp12[i], 
                        pp_p_tmp11[i], 
                        pp_p_tmp10[i], 
                        pp_p_tmp9[i], 
                        pp_p_tmp8[i], 
                        pp_p_tmp7[i], 
                        pp_p_tmp6[i], 
                        pp_p_tmp5[i], 
                        pp_p_tmp4[i], 
                        pp_p_tmp3[i], 
                        pp_p_tmp2[i], 
                        pp_p_tmp1[i], 
                        pp_p_tmp0[i]};
            if(i != 0) wt_c_pre[i] = wt_c_nxt[i-1];
            else wt_c_pre[0] = pp_c[29:0];
		end
    end
	generate
		for (genvar n = 0; n < 132; n = n + 1) begin: wt_gen
            wallace_tree_33 u_wallace_tree_33(
                .n       (wt_n[n]),
                .c_pre   (wt_c_pre[n]),
                .c_nxt   (wt_c_nxt[n]),
                .c       (wt_c[n]),
                .s       (wt_s[n])
            );
		end
	endgenerate

    assign adder_out = adder_a + adder_b + adder_c;
    assign {result_hi, result_lo} = adder_out[127:0];

    assign add_out_ready = 1'b1;
    assign out_valid = add_out_valid;

    always @(posedge clk ) begin
        if (rst | flush) begin
            multiplicand_r  <= 0;
            multiplier_r    <= 0;
            multiplicand_s  <= 1'b0;
            multiplier_s    <= 1'b0;
            mul_signed_r    <= 2'b0;
            mul_ready       <= 1'b0;
            in_add_valid    <= 1'b0;
            in_add_ready    <= 1'b0;
            add_out_valid   <= 1'b0;
            adder_a         <= 0;
            adder_b         <= 0;
            adder_c         <= 0;
        end else begin
            if (mul_valid && mul_ready) begin
                multiplicand_r  <= mulw ? {(`A_SIGN ? {(100){`A[31]}} : 100'b0), `A[31:0]} : {(`A_SIGN ? {(68){`A[63]}} : 68'b0), `A};
                multiplier_r    <= mulw ? {(`B_SIGN ? {(34){`B[31]}} : 34'b0), `B[31:0], 1'b0} : {(`B_SIGN ? {(2){`B[63]}} : 2'b0), `B, 1'b0};
                multiplicand_s  <= mulw ? `A[31] : `A[63];
                multiplier_s    <= mulw ? `B[31] : `B[63];
                mul_signed_r    <= mul_signed;
                in_add_valid    <= 1'b1;
            end else begin
                in_add_valid    <= 1'b0;
            end

            if(in_add_valid && in_add_ready)begin
                adder_a         <= {wt_c[130:0], pp_c[30]};
                adder_b         <= wt_s;
                adder_c         <= pp_c[31];
                add_out_valid   <= 1'b1;
            end else begin
                add_out_valid   <= 1'b0;
            end

            mul_ready       <= in_add_ready ? 1'b1 : 1'b0;
            in_add_ready    <= add_out_ready ? 1'b1 : 1'b0;
        end
    end

endmodule //mul_booth_wallace

`endif