//Mul Div Unit

`ifndef MDU_V
`define MDU_V

`include "top.v"
`include "IDU.v"

module MDU (
	input  [`XLEN-1:0] src1,
	input  [`XLEN-1:0] src2,
	input  [2:0] funct3,
	input  opcode_is_w,
	output [`XLEN-1:0] x_rd
);

	//OP
	localparam MUL		= 4'b0000;
	localparam MULH		= 4'b0001;
	localparam MULHSU	= 4'b0010;
	localparam MULHU	= 4'b0011;
	localparam DIV		= 4'b0100;
	localparam DIVU		= 4'b0101;
	localparam REM		= 4'b0110;
	localparam REMU		= 4'b0111;
	//OP_32
	localparam MULW		= 4'b1000;
	localparam DIVW		= 4'b1100;
	localparam DIVUW	= 4'b1101;
	localparam REMW		= 4'b1110;
	localparam REMUW	= 4'b1111;

	localparam funct7_md = 7'b0000001;

	wire [`XLEN-1:0] src1_abs, src2_abs;
	assign src1_abs = (src1[`XLEN-1] == 1'b1) ? (~src1 + `XLEN'b1) : src1;
	assign src2_abs = (src2[`XLEN-1] == 1'b1) ? (~src2 + `XLEN'b1) : src2;
	wire [`HXLEN-1:0] src1_32b_abs, src2_32b_abs;
	assign src1_32b_abs = (src1[`HXLEN-1] == 1'b1) ? (~src1[`HXLEN-1:0] + `HXLEN'b1) : src1[`HXLEN-1:0];
	assign src2_32b_abs = (src2[`HXLEN-1] == 1'b1) ? (~src2[`HXLEN-1:0] + `HXLEN'b1) : src2[`HXLEN-1:0];

	wire [`XLEN-1:0] op_a, op_b;
	wire [`DXLEN-1:0] fast_mul_out, fast_mul_out_abs;
	assign fast_mul_out = out_sign ? (~fast_mul_out_abs + `DXLEN'b1) : fast_mul_out_abs;
	fast_multiplier u_fast_multiplier(
				.a(op_a),
				.b(op_b),
				.out(fast_mul_out_abs));
	MuxKeyWithDefault #(13, 4, `XLEN) u_op_a (
		.out(op_a),
		.key({opcode_is_w, funct3}),
		.default_out(`XLEN'b0),
		.lut({
			MUL				, src1_abs,
			MULH			, src1_abs,
			MULHSU			, src1_abs,
			MULHU			, src1,
			DIV 			, src1_abs,
			DIVU			, src1,
			REM 			, src1_abs,
			REMU			, src1,
			MULW			, {`HXLEN'b0, src1_32b_abs},
			DIVW			, {`HXLEN'b0, src1_32b_abs},
			DIVUW			, {`HXLEN'b0, src1[`HXLEN-1:0]},
			REMW			, {`HXLEN'b0, src1_32b_abs},
			REMUW			, {`HXLEN'b0, src1[`HXLEN-1:0]}
		})
	);
	MuxKeyWithDefault #(13, 4, `XLEN) u_op_b (
		.out(op_b),
		.key({opcode_is_w, funct3}),
		.default_out(`XLEN'b0),
		.lut({
			MUL				, src2_abs,
			MULH			, src2_abs,
			MULHSU			, src2,
			MULHU			, src2,
			DIV 			, src2_abs,
			DIVU			, src2,
			REM 			, src2_abs,
			REMU			, src2,
			MULW			, {`HXLEN'b0, src2_32b_abs},
			DIVW			, {`HXLEN'b0, src2_32b_abs},
			DIVUW			, {`HXLEN'b0, src2[`HXLEN-1:0]},
			REMW			, {`HXLEN'b0, src2_32b_abs},
			REMUW			, {`HXLEN'b0, src2[`HXLEN-1:0]}
		})
	);

	wire out_sign;// 1 negtive,  0 posetive
	MuxKeyWithDefault #(13, 4, 1) u_out_sign (
		.out(out_sign),
		.key({opcode_is_w, funct3}),
		.default_out(1'b0),
		.lut({
			MUL				, src1[`XLEN-1] ^ src2[`XLEN-1],
			MULH			, src1[`XLEN-1] ^ src2[`XLEN-1],
			MULHSU			, src1[`XLEN-1],
			MULHU			, 1'b0,
			DIV 			, src1[`XLEN-1] ^ src2[`XLEN-1],
			DIVU			, 1'b0,
			REM 			, src1[`XLEN-1] ^ src2[`XLEN-1],
			REMU			, 1'b0,
			MULW			, src1[`HXLEN-1] ^ src2[`HXLEN-1],
			DIVW			, src1[`HXLEN-1] ^ src2[`HXLEN-1],
			DIVUW			, 1'b0,
			REMW			, src1[`HXLEN-1] ^ src2[`HXLEN-1],
			REMUW			, 1'b0
		})
	);

	wire remainder_sign;// 1 negtive,  0 posetive
	MuxKeyWithDefault #(4, 4, 1) u_remainder_sign (
		.out(remainder_sign),
		.key({opcode_is_w, funct3}),
		.default_out(1'b0),
		.lut({
			REM 			, src1[`XLEN-1],
			REMU			, 1'b0,
			REMW			, src1[`HXLEN-1],
			REMUW			, 1'b0
		})
	);

	wire div_zero = op_b == `XLEN'b0 ? 1'b1 : 1'b0;
	wire [`XLEN-1:0] quotient_abs = div_zero ? `XLEN'b0 : $unsigned(op_a) / $unsigned(op_b);
	wire [`XLEN-1:0] remainder_abs = div_zero ? `XLEN'b0 : $unsigned(op_a) % $unsigned(op_b);

	wire [`XLEN-1:0] quotient = div_zero ? (~`XLEN'b0) : (out_sign ? (~quotient_abs + `XLEN'b1) : quotient_abs);
	wire [`XLEN-1:0] remainder = div_zero ? op_a : (remainder_sign ? (~remainder_abs + `XLEN'b1) : remainder_abs);
	MuxKeyWithDefault #(13, 4, `XLEN) u_x_rd_data (
		.out(x_rd),
		.key({opcode_is_w, funct3}),
		.default_out(`XLEN'b0),
		.lut({
			MUL				, fast_mul_out[`XLEN-1:0],
			MULH			, fast_mul_out[`DXLEN-1:`XLEN],
			MULHSU			, fast_mul_out[`DXLEN-1:`XLEN],
			MULHU			, fast_mul_out[`DXLEN-1:`XLEN],
			DIV 			, quotient,
			DIVU			, quotient,
			REM 			, remainder,
			REMU			, remainder,
			MULW			, {{(`HXLEN){fast_mul_out[`HXLEN-1]}}, fast_mul_out[`HXLEN-1:0]},
			DIVW			, {{(`HXLEN){quotient[`HXLEN-1]}}, quotient[`HXLEN-1:0]},
			DIVUW			, {{(`HXLEN){quotient[`HXLEN-1]}}, quotient[`HXLEN-1:0]},
			REMW			, {{(`HXLEN){remainder[`HXLEN-1]}}, remainder[`HXLEN-1:0]},
			REMUW			, {{(`HXLEN){remainder[`HXLEN-1]}}, remainder[`HXLEN-1:0]}
		})
	);

endmodule //MDU

`endif