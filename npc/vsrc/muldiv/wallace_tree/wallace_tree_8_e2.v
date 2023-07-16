/*************************************************************
 * @ name           : wallace_tree_8_e2.v
 * @ description    : 
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-5-25
*************************************************************/
`ifndef WALLACE_TREE_8_E2_V
`define WALLACE_TREE_8_E2_V

module wallace_tree_8_e2 (
    input       [7:0]     n,
    input       [4:0]     c_pre,
    output      [4:0]     c_nxt,
    output                c,
    output                s
);
    wire [5:0] csa_a;
    wire [5:0] csa_b;
    wire [5:0] csa_c;
    wire [5:0] csa_s;
    wire [5:0] csa_cout;

	generate
		for (genvar i = 0; i < 6; i = i + 1) begin: csa_gen
			csa u_csa(
                .a(csa_a[i]),
                .b(csa_b[i]),
                .c(csa_c[i]),
                .s(csa_s[i]),
                .cout(csa_cout[i])
            );
		end
	endgenerate

    assign s = csa_s[5];
    assign c = csa_cout[5];
    assign c_nxt = csa_cout[4:0];

    assign csa_a[0] = n[0];
    assign csa_b[0] = n[1];
    assign csa_c[0] = n[2];

    assign csa_a[1] = n[3];
    assign csa_b[1] = n[4];
    assign csa_c[1] = n[5];

    assign csa_a[2] = csa_s[0];
    assign csa_b[2] = csa_s[1];
    assign csa_c[2] = n[6];

    assign csa_a[3] = n[7];
    assign csa_b[3] = c_pre[0];
    assign csa_c[3] = c_pre[1];

    assign csa_a[4] = csa_s[2];
    assign csa_b[4] = csa_s[3];
    assign csa_c[4] = c_pre[2];

    assign csa_a[5] = csa_s[4];
    assign csa_b[5] = c_pre[3];
    assign csa_c[5] = c_pre[4];
    
endmodule

`endif