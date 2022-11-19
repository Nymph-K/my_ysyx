//Instruction Decode Unit

`ifndef IDU_V
`define IDU_V

import "DPI-C" function void stopCPU();

`include "top.v"

`define LOAD			7'b0000011		//LOAD
`define LOAD_FP			7'b0000111		//LOAD-FP
`define CUSTOM_0		7'b0001011		//custom-0
`define MISC_MEM		7'b0001111		//MISC-MEM
`define OP_IMM			7'b0010011		//OP-IMM
`define AUIPC			7'b0010111		//AUIPC
`define OP_IMM_32		7'b0011011		//OP-IMM-32
`define STORE			7'b0100011		//STORE
`define STORE_FP		7'b0100111		//STORE-FP
`define CUSTOM_1		7'b0101011		//custom-1
`define AMO				7'b0101111		//AMO
`define OP				7'b0110011		//OP
`define LUI				7'b0110111		//LUI
`define OP_32			7'b0111011		//OP-32
`define MADD			7'b1000011		//MADD
`define MSUB			7'b1000111		//MSUB
`define NMSUB			7'b1001011		//NMSUB
`define NMADD			7'b1001111		//NMADD
`define OP_FP			7'b1010011		//OP-FP
`define RESERVED_0		7'b1010111		//reserved
`define CUSTOM_2		7'b1011011		//custom-2/rv128
`define BRANCH			7'b1100011		//BRANCH
`define JALR			7'b1100111		//JALR
`define RESERVED_1		7'b1101011		//reserved
`define JAL				7'b1101111		//JAL
`define SYSTEM			7'b1110011		//SYSTEM
`define RESERVED_2		7'b1110111		//reserved
`define CUSTOM_3		7'b1111011		//custom-3/rv128


module IDU (
	input  clk,
	input  rst,
	input  [31:0] inst,
	output [6:0] opcode,
	output [2:0] funct3,
	output [6:0] funct7,
	output [`XLEN-1:0] src1,
	output [`XLEN-1:0] src2,
	output [`XLEN-1:0] imm,
	output [4:0] rs1,
	output [4:0] rs2,
	output [4:0] rd,
	input  [`XLEN-1:0] x_rs1,
	input  [`XLEN-1:0] x_rs2
);
	localparam TYPE_R  = 3'd0;
	localparam TYPE_I  = 3'd1;
	localparam TYPE_S  = 3'd2;
	localparam TYPE_B  = 3'd3;
	localparam TYPE_U  = 3'd4;
	localparam TYPE_J  = 3'd5;
	localparam TYPE_R4 = 3'd6;

	assign opcode = inst[6:0];
	assign funct3 = inst[14:12];
	assign funct7 = inst[31:25];
	assign rd  = inst[11:7];
	assign rs1 = inst[19:15];
	assign rs2 = inst[24:20];

	wire [2:0] inst_type;
	
	MuxKeyWithDefault #(28, 7, 3) u_inst_type (
		.out(inst_type),
		.key(opcode),
		.default_out(3'd0),
		.lut({
			`LOAD		, TYPE_I,	//LOAD
			`LOAD_FP	, TYPE_I,	//LOAD-FP
			`CUSTOM_0	, 3'd7,		//custom-0
			`MISC_MEM	, TYPE_I,	//MISC-MEM
			`OP_IMM		, TYPE_I,	//OP-IMM
			`AUIPC		, TYPE_U,	//AUIPC
			`OP_IMM_32	, TYPE_I,	//OP-IMM-32
			`STORE		, TYPE_S,	//STORE
			`STORE_FP	, TYPE_S,	//STORE-FP
			`CUSTOM_1	, 3'd7,		//custom-1
			`AMO		, TYPE_R,	//AMO
			`OP			, TYPE_R,	//OP
			`LUI		, TYPE_U,	//LUI
			`OP_32		, TYPE_R,	//OP-32
			`MADD		, TYPE_R4,	//MADD
			`MSUB		, TYPE_R4,	//MSUB
			`NMSUB		, TYPE_R4,	//NMSUB
			`NMADD		, TYPE_R4,	//NMADD
			`OP_FP		, TYPE_R,	//OP-FP
			`RESERVED_0	, 3'd7,		//reserved
			`CUSTOM_2	, 3'd7,		//custom-2/rv128
			`BRANCH		, TYPE_B,	//BRANCH
			`JALR		, TYPE_I,	//JALR
			`RESERVED_1	, 3'd7,		//reserved
			`JAL		, TYPE_J,	//JAL
			`SYSTEM		, TYPE_I,	//SYSTEM
			`RESERVED_2	, 3'd7,		//reserved
			`CUSTOM_3	, 3'd7		//custom-3/rv128
		})
	);

	MuxKeyWithDefault #(6, 3, `XLEN) u_imm (
		.out(imm),
		.key(inst_type),
		.default_out(`XLEN'b0),
		.lut({
			TYPE_R, `XLEN'b0, 
			TYPE_I, {{(`XLEN-12){inst[31]}}, inst[31:20]}, 
			TYPE_S, {{(`XLEN-12){inst[31]}}, inst[31:25], inst[11:7]}, 
			TYPE_B, {{(`XLEN-13){inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}, 
			TYPE_U, {{(`XLEN-32){inst[31]}}, inst[31:12], 12'b0}, 
			TYPE_J, {{(`XLEN-21){inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}
		})
	);

	MuxKeyWithDefault #(6, 3, `XLEN) u_src1 (
		.out(src1),
		.key(inst_type),
		.default_out(`XLEN'b0),
		.lut({
			TYPE_R, x_rs1, 
			TYPE_I, x_rs1, 
			TYPE_S, x_rs1, 
			TYPE_B, x_rs1, 
			TYPE_U, `XLEN'b0, 
			TYPE_J, `XLEN'b0
		})
	);

	MuxKeyWithDefault #(6, 3, `XLEN) u_src2 (
		.out(src2),
		.key(inst_type),
		.default_out(`XLEN'b0),
		.lut({
			TYPE_R, x_rs2, 
			TYPE_I, `XLEN'b0, 
			TYPE_S, x_rs2, 
			TYPE_B, x_rs2, 
			TYPE_U, `XLEN'b0, 
			TYPE_J, `XLEN'b0
		})
	);

	localparam ebreak = 32'b00000000000100000000000001110011;
	always @(*) begin
		if(inst == ebreak) begin
			stopCPU();
		end
	end

endmodule //IDU

`endif /* IDU_V */