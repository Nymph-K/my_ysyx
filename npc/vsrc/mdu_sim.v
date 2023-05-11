/*************************************************************
 * @ name           : mdu_sim.v
 * @ description    : Multiply Divide Unit
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-3-13
*************************************************************/
`ifndef MDU_SIM_V
`define MDU_SIM_V

`include "common.v"

module mdu_sim (
	input  en_mdu, 
	input  [`XLEN-1:0] x_rs1,
	input  [`XLEN-1:0] x_rs2,
	input  [2:0] funct3,
	input  inst_32,
	output [`XLEN-1:0] mdu_result
);

	//OP
	localparam OP_MUL		= 4'b0000;
	localparam OP_MULH		= 4'b0001;
	localparam OP_MULHSU	= 4'b0010;
	localparam OP_MULHU		= 4'b0011;
	localparam OP_DIV		= 4'b0100;
	localparam OP_DIVU		= 4'b0101;
	localparam OP_REM		= 4'b0110;
	localparam OP_REMU		= 4'b0111;
	//OP_32
	localparam OP_MULW		= 4'b1000;
	localparam OP_DIVW		= 4'b1100;
	localparam OP_DIVUW		= 4'b1101;
	localparam OP_REMW		= 4'b1110;
	localparam OP_REMUW		= 4'b1111;
	
	wire [3:0] op_sel = {inst_32, funct3};

	assign mdu_result = en_mdu ? (inst_32 ? {{(`HXLEN){mul_div_result[`HXLEN-1]}}, mul_div_result[`HXLEN-1:0]} : mul_div_result) : `XLEN'b0;

	reg [`XLEN-1:0] mul_div_result;

	always @(*) begin
		if (en_mdu) begin
			case (op_sel)
				OP_MUL	: mul_div_result = {($signed($signed(x_rs1) * $signed(x_rs2)))}[`XLEN-1:0];
				OP_MULH	: mul_div_result = {($signed($signed({{(`XLEN){x_rs1[`XLEN-1]}}, x_rs1}) * $signed({{(`XLEN){x_rs2[`XLEN-1]}}, x_rs2})))}[`DXLEN-1:`XLEN];
				OP_MULHSU	: mul_div_result = {($signed($signed({{(`XLEN){x_rs1[`XLEN-1]}}, x_rs1}) * $unsigned({`XLEN'h0, x_rs2})))}[`DXLEN-1:`XLEN];
				OP_MULHU	: mul_div_result = {($unsigned($unsigned({`XLEN'h0, x_rs1}) * $unsigned({`XLEN'h0, x_rs2})))}[`DXLEN-1:`XLEN];
				OP_DIV 	: mul_div_result = (x_rs2 == `XLEN'b0) ? (-`XLEN'd1) : 
												((x_rs1 == `XLEN'h8000000000000000 && x_rs2 == (-`XLEN'd1)) ? `XLEN'h8000000000000000 : 
												{($signed($signed(x_rs1) / $signed(x_rs2)))}[`XLEN-1:0]);
				OP_DIVU	: mul_div_result = (x_rs2 == `XLEN'b0) ? (-`XLEN'd1) : 
												{($unsigned($unsigned(x_rs1) / $unsigned(x_rs2)))}[`XLEN-1:0];
				OP_REM 	: mul_div_result = (x_rs2 == `XLEN'b0) ? (x_rs1) : 
												((x_rs1 == `XLEN'h8000000000000000 && x_rs2 == (-`XLEN'd1)) ? `XLEN'h0 : 
												{($signed($signed(x_rs1) % $signed(x_rs2)))}[`XLEN-1:0]);
				OP_REMU	: mul_div_result = (x_rs2 == `XLEN'b0) ? (x_rs1) : 
												({($unsigned($unsigned(x_rs1) % $unsigned(x_rs2)))}[`XLEN-1:0]);
				OP_MULW	: mul_div_result = {($signed($signed(x_rs1) * $signed(x_rs2)))}[`XLEN-1:0];
				OP_DIVW	: mul_div_result = (x_rs2 == `XLEN'b0) ? (-`XLEN'd1) : 
												((x_rs1[`HXLEN-1:0] == `HXLEN'h80000000 && x_rs2[`HXLEN-1:0] == (-`HXLEN'd1)) ? `XLEN'h0000000080000000 : 
												{($signed($signed({{(`HXLEN){x_rs1[`HXLEN-1]}}, x_rs1[`HXLEN-1:0]}) / $signed({{(`HXLEN){x_rs2[`HXLEN-1]}}, x_rs2[`HXLEN-1:0]})))}[`XLEN-1:0]);
				OP_DIVUW	: mul_div_result = (x_rs2 == `XLEN'b0) ? (-`XLEN'd1) : 
												({($unsigned($unsigned({`HXLEN'h0, x_rs1[`HXLEN-1:0]}) / $unsigned({`HXLEN'h0, x_rs2[`HXLEN-1:0]})))}[`XLEN-1:0]);
				OP_REMW	: mul_div_result = (x_rs2 == `XLEN'b0) ? (x_rs1) : 
												((x_rs1[`HXLEN-1:0] == `HXLEN'h80000000 && x_rs2[`HXLEN-1:0] == (-`HXLEN'd1)) ? `XLEN'h0 : 
												{($signed($signed({{(`HXLEN){x_rs1[`HXLEN-1]}}, x_rs1[`HXLEN-1:0]}) % $signed({{(`HXLEN){x_rs2[`HXLEN-1]}}, x_rs2[`HXLEN-1:0]})))}[`XLEN-1:0]);
				OP_REMUW	: mul_div_result = (x_rs2 == `XLEN'b0) ? (x_rs1) : 
												({($unsigned($unsigned({`HXLEN'h0, x_rs1[`HXLEN-1:0]}) % $unsigned({`HXLEN'h0, x_rs2[`HXLEN-1:0]})))}[`XLEN-1:0]);
				default : mul_div_result = `XLEN'b0;
			endcase
		end else begin
			mul_div_result = `XLEN'b0;
		end
	end

endmodule //mdu_sim

`endif