/*************************************************************
 * @ name           : wallace_tree_33.v
 * @ description    : 
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-28
*************************************************************/
`ifndef WALLACE_TREE_33_V
`define WALLACE_TREE_33_V

module wallace_tree_33 (
    input       [32:0]     n,
    input       [29:0]     c_pre,
    output      [29:0]     c_nxt,
    output                 c,
    output                 s
    );


    wire [30:0] csa_a;
    wire [30:0] csa_b;
    wire [30:0] csa_c;
    wire [30:0] csa_s;
    wire [30:0] csa_cout;


        generate
                for (genvar i = 0; i < 31; i = i + 1) begin: csa_gen
                        csa u_csa(
                .a(csa_a[i]),
                .b(csa_b[i]),
                .c(csa_c[i]),
                .s(csa_s[i]),
                .cout(csa_cout[i])
            );
                end
        endgenerate


    assign s = csa_s[30];
    assign c = csa_cout[30];
    assign c_nxt = csa_cout[29:0];

    assign csa_a[0] = n[0];
    assign csa_b[0] = n[1];
    assign csa_c[0] = n[2];
    assign csa_a[1] = n[3];
    assign csa_b[1] = n[4];
    assign csa_c[1] = n[5];
    assign csa_a[2] = n[6];
    assign csa_b[2] = n[7];
    assign csa_c[2] = n[8];
    assign csa_a[3] = n[9];
    assign csa_b[3] = n[10];
    assign csa_c[3] = n[11];
    assign csa_a[4] = n[12];
    assign csa_b[4] = n[13];
    assign csa_c[4] = n[14];
    assign csa_a[5] = n[15];
    assign csa_b[5] = n[16];
    assign csa_c[5] = n[17];
    assign csa_a[6] = n[18];
    assign csa_b[6] = n[19];
    assign csa_c[6] = n[20];
    assign csa_a[7] = n[21];
    assign csa_b[7] = n[22];
    assign csa_c[7] = n[23];
    assign csa_a[8] = n[24];
    assign csa_b[8] = n[25];
    assign csa_c[8] = n[26];
    assign csa_a[9] = n[27];
    assign csa_b[9] = n[28];
    assign csa_c[9] = n[29];
    assign csa_a[10] = n[30];
    assign csa_b[10] = n[31];
    assign csa_c[10] = n[32];
    assign csa_a[11] = csa_s[0];
    assign csa_b[11] = csa_s[1];
    assign csa_c[11] = csa_s[2];
    assign csa_a[12] = csa_s[3];
    assign csa_b[12] = csa_s[4];
    assign csa_c[12] = csa_s[5];
    assign csa_a[13] = csa_s[6];
    assign csa_b[13] = csa_s[7];
    assign csa_c[13] = csa_s[8];
    assign csa_a[14] = csa_s[9];
    assign csa_b[14] = csa_s[10];
    assign csa_c[14] = c_pre[0];
    assign csa_a[15] = c_pre[1];
    assign csa_b[15] = c_pre[2];
    assign csa_c[15] = c_pre[3];
    assign csa_a[16] = c_pre[4];
    assign csa_b[16] = c_pre[5];
    assign csa_c[16] = c_pre[6];
    assign csa_a[17] = c_pre[7];
    assign csa_b[17] = c_pre[8];
    assign csa_c[17] = c_pre[9];
    assign csa_a[18] = csa_s[11];
    assign csa_b[18] = csa_s[12];
    assign csa_c[18] = csa_s[13];
    assign csa_a[19] = csa_s[14];
    assign csa_b[19] = csa_s[15];
    assign csa_c[19] = csa_s[16];
    assign csa_a[20] = csa_s[17];
    assign csa_b[20] = c_pre[10];
    assign csa_c[20] = c_pre[11];
    assign csa_a[21] = c_pre[12];
    assign csa_b[21] = c_pre[13];
    assign csa_c[21] = c_pre[14];
    assign csa_a[22] = c_pre[15];
    assign csa_b[22] = c_pre[16];
    assign csa_c[22] = c_pre[17];
    assign csa_a[23] = csa_s[18];
    assign csa_b[23] = csa_s[19];
    assign csa_c[23] = csa_s[20];
    assign csa_a[24] = csa_s[21];
    assign csa_b[24] = csa_s[22];
    assign csa_c[24] = c_pre[18];
    assign csa_a[25] = c_pre[19];
    assign csa_b[25] = c_pre[20];
    assign csa_c[25] = c_pre[21];
    assign csa_a[26] = csa_s[23];
    assign csa_b[26] = csa_s[24];
    assign csa_c[26] = csa_s[25];
    assign csa_a[27] = c_pre[22];
    assign csa_b[27] = c_pre[23];
    assign csa_c[27] = c_pre[24];
    assign csa_a[28] = csa_s[26];
    assign csa_b[28] = csa_s[27];
    assign csa_c[28] = c_pre[25];
    assign csa_a[29] = csa_s[28];
    assign csa_b[29] = c_pre[26];
    assign csa_c[29] = c_pre[27];
    assign csa_a[30] = csa_s[29];
    assign csa_b[30] = c_pre[28];
    assign csa_c[30] = c_pre[29];

endmodule
`endif