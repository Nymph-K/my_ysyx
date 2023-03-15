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

	wire [3:0] op_sel = {opcode_is_w, funct3};
	wire [`XLEN-1:0] mul_div_result;

	MuxKeyWithDefault #(13, 4, `XLEN) u_mul_div_result (
		.out(mul_div_result),
		.key(op_sel),
		.default_out(`XLEN'b0),
		.lut({
			MUL			, {($signed($signed(src1) * $signed(src2)))}[`XLEN-1:0],
			MULH		, {($signed($signed({{(`XLEN){src1[`XLEN-1]}}, src1}) * $signed({{(`XLEN){src2[`XLEN-1]}}, src2})))}[`DXLEN-1:`XLEN],
			MULHSU		, {($signed($signed({{(`XLEN){src1[`XLEN-1]}}, src1}) * $unsigned({`XLEN'h0, src2})))}[`DXLEN-1:`XLEN],
			MULHU		, {($unsigned($unsigned({`XLEN'h0, src1}) * $unsigned({`XLEN'h0, src2})))}[`DXLEN-1:`XLEN],
			DIV 		, (src2 == `XLEN'b0) ? (-`XLEN'd1) : 
											((src1 == `XLEN'h8000000000000000 && src2 == (-`XLEN'd1)) ? `XLEN'h8000000000000000 : 
											{($signed($signed(src1) / $signed(src2)))}[`XLEN-1:0]),
			DIVU		, (src2 == `XLEN'b0) ? (-`XLEN'd1) : 
											{($unsigned($unsigned(src1) / $unsigned(src2)))}[`XLEN-1:0],
			REM 		, (src2 == `XLEN'b0) ? (src1) : 
											((src1 == `XLEN'h8000000000000000 && src2 == (-`XLEN'd1)) ? `XLEN'h0 : 
											{($signed($signed(src1) % $signed(src2)))}[`XLEN-1:0]),
			REMU		, (src2 == `XLEN'b0) ? (src1) : 
											({($unsigned($unsigned(src1) % $unsigned(src2)))}[`XLEN-1:0]),
			MULW		, {($signed($signed(src1) * $signed(src2)))}[`XLEN-1:0],
			DIVW		, (src2 == `XLEN'b0) ? (-`XLEN'd1) : 
											((src1[`HXLEN-1:0] == `HXLEN'h80000000 && src2[`HXLEN-1:0] == (-`HXLEN'd1)) ? `XLEN'h0000000080000000 : 
											{($signed($signed({{(`HXLEN){src1[`HXLEN-1]}}, src1[`HXLEN-1:0]}) / $signed({{(`HXLEN){src2[`HXLEN-1]}}, src2[`HXLEN-1:0]})))}[`XLEN-1:0]),
			DIVUW		, (src2 == `XLEN'b0) ? (-`XLEN'd1) : 
											({($unsigned($unsigned({`HXLEN'h0, src1[`HXLEN-1:0]}) / $unsigned({`HXLEN'h0, src2[`HXLEN-1:0]})))}[`XLEN-1:0]),
			REMW		, (src2 == `XLEN'b0) ? (src1) : 
											((src1[`HXLEN-1:0] == `HXLEN'h80000000 && src2[`HXLEN-1:0] == (-`HXLEN'd1)) ? `XLEN'h0 : 
											{($signed($signed({{(`HXLEN){src1[`HXLEN-1]}}, src1[`HXLEN-1:0]}) % $signed({{(`HXLEN){src2[`HXLEN-1]}}, src2[`HXLEN-1:0]})))}[`XLEN-1:0]),
			REMUW		, (src2 == `XLEN'b0) ? (src1) : 
											({($unsigned($unsigned({`HXLEN'h0, src1[`HXLEN-1:0]}) % $unsigned({`HXLEN'h0, src2[`HXLEN-1:0]})))}[`XLEN-1:0])
		})
	);

	assign x_rd = opcode_is_w ? {{(`HXLEN){mul_div_result[`HXLEN-1]}}, mul_div_result[`HXLEN-1:0]} : mul_div_result;

endmodule //MDU

`endif