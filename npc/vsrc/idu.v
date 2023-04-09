/*************************************************************
 * @ name           : idu.v
 * @ description    : Instruction Decode Unit
 * @ use module     : MuxKeyWithDefault
 * @ author         : K
 * @ date modified  : 2023-3-10
*************************************************************/
`ifndef IDU_V
`define IDU_V

`include "common.v"

module idu (
	input  [31:0] 				inst,
	output [6:0] 				opcode,
	output [2:0] 				funct3,
	output [6:0] 				funct7,
	`ifdef USE_IF_CASE
		output reg [`XLEN-1:0] 	imm,
	`else
		output     [`XLEN-1:0] 	imm,
	`endif
	output [4:0] rs1,
	output [4:0] rs2,
	output [4:0] rd
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

	`ifdef USE_IF_CASE

		reg [2:0] inst_type;

		always @(*) begin
			case (opcode)
				`LOAD		: inst_type = TYPE_I;	//LOAD
				`LOAD_FP	: inst_type = TYPE_I;	//LOAD-FP
				`CUSTOM_0	: inst_type = 3'd7;		//custom-0
				`MISC_MEM	: inst_type = TYPE_I;	//MISC-MEM
				`OP_IMM		: inst_type = TYPE_I;	//OP-IMM
				`AUIPC		: inst_type = TYPE_U;	//AUIPC
				`OP_IMM_32	: inst_type = TYPE_I;	//OP-IMM-32
				`STORE		: inst_type = TYPE_S;	//STORE
				`STORE_FP	: inst_type = TYPE_S;	//STORE-FP
				`CUSTOM_1	: inst_type = 3'd7;		//custom-1
				`AMO		: inst_type = TYPE_R;	//AMO
				`OP			: inst_type = TYPE_R;	//OP
				`LUI		: inst_type = TYPE_U;	//LUI
				`OP_32		: inst_type = TYPE_R;	//OP-32
				`MADD		: inst_type = TYPE_R4;	//MADD
				`MSUB		: inst_type = TYPE_R4;	//MSUB
				`NMSUB		: inst_type = TYPE_R4;	//NMSUB
				`NMADD		: inst_type = TYPE_R4;	//NMADD
				`OP_FP		: inst_type = TYPE_R;	//OP-FP
				`RESERVED_0	: inst_type = 3'd7;		//reserved
				`CUSTOM_2	: inst_type = 3'd7;		//custom-2/rv128
				`BRANCH		: inst_type = TYPE_B;	//BRANCH
				`JALR		: inst_type = TYPE_I;	//JALR
				`RESERVED_1	: inst_type = 3'd7;		//reserved
				`JAL		: inst_type = TYPE_J;	//JAL
				`SYSTEM		: inst_type = TYPE_I;	//SYSTEM
				`RESERVED_2	: inst_type = 3'd7;		//reserved
				`CUSTOM_3	: inst_type = 3'd7;		//custom-3/rv128
				default: inst_type = 3'd0;
			endcase
		end
		
		always @(*) begin
			case (inst_type)
				TYPE_R: imm = `XLEN'b0;
				TYPE_I: imm = {{(`XLEN-12){inst[31]}}, inst[31:20]};
				TYPE_S: imm = {{(`XLEN-12){inst[31]}}, inst[31:25], inst[11:7]};
				TYPE_B: imm = {{(`XLEN-13){inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
				TYPE_U: imm = {{(`XLEN-32){inst[31]}}, inst[31:12], 12'b0};
				TYPE_J: imm = {{(`XLEN-21){inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
				default: imm = `XLEN'b0;
			endcase
		end

	`else

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
	`endif

endmodule //idu

`endif /* IDU_V */