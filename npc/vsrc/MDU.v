//Mul Div Unit

`ifndef MDU_V
`define MDU_V

`include "top.v"
`include "IDU.v"

module MDU (
	input  [`XLEN-1:0] src1,
	input  [`XLEN-1:0] src2,
	input  [2:0] funct3,
	output [`XLEN-1:0] x_rd
);

	//OP
	localparam MUL		= 3'b000;
	localparam MULH		= 3'b001;
	localparam MULHSU	= 3'b010;
	localparam MULHU	= 3'b011;
	localparam DIV		= 3'b100;
	localparam DIVU		= 3'b101;
	localparam REM		= 3'b110;
	localparam REMU		= 3'b111;
	//OP_32
	localparam MULW		= 3'b000;
	localparam DIVW		= 3'b100;
	localparam DIVUW	= 3'b101;
	localparam REMW		= 3'b110;
	localparam REMUW	= 3'b111;

	localparam funct7_md = 7'b0000001;

	wire [`XLEN-1:0] src1_abs, src2_abs;
	assign src1_abs = (src1[`XLEN-1] == 1'b1) ? (~src1 + `XLEN'b1) : src1;
	assign src2_abs = (src2[`XLEN-1] == 1'b1) ? (~src2 + `XLEN'b1) : src2;

	wire [`XLEN-1:0] op_a, op_b;
	wire [`DXLEN-1:0] fast_mul_out, fast_mul_out_abs;
	fast_multiplier u_fast_multiplier(
				.a(op_a),
				.b(op_b),
				.out(fast_mul_out_abs));
	MuxKeyWithDefault #(8, 3, `XLEN) u_op_a (
		.out(op_a),
		.key(funct3),
		.default_out(`XLEN'b0),
		.lut({
			MUL | MULW		, src1_abs,
			MULH			, src1_abs,
			MULHSU			, src1_abs,
			MULHU			, src1,
			DIV | DIVW		, src1_abs,
			DIVU | DIVUW	, src1,
			REM | REMW		, src1_abs,
			REMU | REMUW	, src1
		})
	);
	MuxKeyWithDefault #(8, 3, `XLEN) u_op_b (
		.out(op_b),
		.key(funct3),
		.default_out(`XLEN'b0),
		.lut({
			MUL | MULW		, src2_abs,
			MULH			, src2_abs,
			MULHSU			, src2,
			MULHU			, src2,
			DIV | DIVW		, src2_abs,
			DIVU | DIVUW	, src2,
			REM | REMW		, src2_abs,
			REMU | REMUW	, src2
		})
	);

	wire out_sign;// 1 negtive,  0 posetive
	MuxKeyWithDefault #(8, 3, 1) u_out_sign (
		.out(out_sign),
		.key(funct3),
		.default_out(1'b0),
		.lut({
			MUL | MULW		, src1[`XLEN-1] ^ src2[`XLEN-1],
			MULH			, src1[`XLEN-1] ^ src2[`XLEN-1],
			MULHSU			, src1[`XLEN-1],
			MULHU			, 1'b0,
			DIV | DIVW		, src1[`XLEN-1] ^ src2[`XLEN-1],
			DIVU | DIVUW	, 1'b0,
			REM | REMW		, src1[`XLEN-1] ^ src2[`XLEN-1],
			REMU | REMUW	, 1'b0
		})
	);
	assign fast_mul_out = out_sign ? (~fast_mul_out_abs + `DXLEN'b1) : fast_mul_out_abs;
	wire [`XLEN-1:0] quotient_abs = $unsigned(op_a) / $unsigned(op_b);
	wire [`XLEN-1:0] remainder_abs = $unsigned(op_a) % $unsigned(op_b);
	wire [`XLEN-1:0] quotient = out_sign ? (~quotient_abs + `XLEN'b1) : quotient_abs;
	wire [`XLEN-1:0] remainder = src1[`XLEN-1] ? (~remainder_abs + `XLEN'b1) : remainder_abs;
	MuxKeyWithDefault #(8, 3, `XLEN) u_x_rd_data (
		.out(x_rd),
		.key(funct3),
		.default_out(`XLEN'b0),
		.lut({
			MUL | MULW		, fast_mul_out[`XLEN-1:0],
			MULH			, fast_mul_out[`DXLEN-1:`XLEN],
			MULHSU			, fast_mul_out[`DXLEN-1:`XLEN],
			MULHU			, fast_mul_out[`DXLEN-1:`XLEN],
			DIV | DIVW		, quotient,
			DIVU | DIVUW	, quotient_abs,
			REM | REMW		, remainder,
			REMU | REMUW	, remainder_abs
		})
	);

endmodule //MDU

`endif