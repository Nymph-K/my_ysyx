//Control and Status Register

`ifndef CSR_V
`define CSR_V

`include "top.v"

module CSR (
	input  clk,
	input  rst,
	input  [2:0] inst_is_x, //001: ebreak, 010: ecall, 100: mret
	input  [`XLEN-1:0] pc,
	input  rd_en, 
	input  wt_en,
	input  [11:0] csr_idx,
	input  [`XLEN-1:0] source,
	output [`XLEN-1:0] csr
);
	//Machine Trap Setup
	localparam mstatus		= 12'h300;	//Machine status register.
	localparam misa			= 12'h301;	//ISA and extensions
	localparam medeleg		= 12'h302;	//Machine exception delegation register.
	localparam mideleg		= 12'h303;	//Machine interrupt delegation register.
	localparam mie			= 12'h304;	//Machine interrupt-enable register.
	localparam mtvec		= 12'h305;	//Machine trap-handler base address.
	localparam mcounteren	= 12'h306;	//Machine counter enable.
	localparam mstatush		= 12'h310;	//Additional machine status register, RV32 only.
	//Machine Trap Handling
	localparam mscratch		= 12'h340;	//Scratch register for machine trap handlers.
	localparam mepc			= 12'h341;	//Machine exception program counter.
	localparam mcause		= 12'h342;	//Machine trap cause.
	localparam mtval		= 12'h343;	//Machine bad address or instruction.
	localparam mip			= 12'h344;	//Machine interrupt pending.
	localparam mtinst		= 12'h34A;	//Machine trap instruction (transformed).
	localparam mtval2		= 12'h34B;	//Machine bad guest physical address.
	//SYSTEM
	localparam CSRRW	= 3'b001;
	localparam CSRRS	= 3'b010;
	localparam CSRRC	= 3'b011;
	localparam CSRRWI	= 3'b101;
	localparam CSRRSI	= 3'b110;
	localparam CSRRCI	= 3'b111;

	wire [`XLEN-1:0] mcsr[15:0];
	generate
		for (genvar n = 0; n < 15; n = n + 1) begin: csr_gen
			if (n == 0) //mstatus
				Reg #(`XLEN, `XLEN'ha00001800) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(source), 
					.dout(mcsr[n]), 
					.wen((mcsr_idx == n && wt_en == 1'b1) ? 1'b1 : 1'b0));
			else if (n == 9) //mepc
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(mepc_source), 
					.dout(mcsr[n]), 
					.wen(((mcsr_idx == n && wt_en == 1'b1) || mepc_wt_en == 1'b1) ? 1'b1 : 1'b0));
			else if (n == 10) //mcause
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(mcause_source), 
					.dout(mcsr[n]), 
					.wen(((mcsr_idx == n && wt_en == 1'b1) || mcause_wt_en == 1'b1) ? 1'b1 : 1'b0));
			else
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(source), 
					.dout(mcsr[n]), 
					.wen((mcsr_idx == n && wt_en == 1'b1) ? 1'b1 : 1'b0));
		end
	endgenerate

	assign csr = (rd_en == 1'b1) ? mcsr[mcsr_idx] : `XLEN'b0;

	wire [3:0] mcsr_idx;
	MuxKeyWithDefault #(15, 12, 4) u_mcsr_idx (
		.out(mcsr_idx),
		.key(csr_idx),
		.default_out(4'd0),
		.lut({
			mstatus		, 4'd0,
			misa		, 4'd1,
			medeleg		, 4'd2,
			mideleg		, 4'd3,
			mie			, 4'd4,
			mtvec		, 4'd5,
			mcounteren	, 4'd6,
			mstatush	, 4'd7,
			mscratch	, 4'd8,
			mepc		, 4'd9,
			mcause		, 4'd10,
			mtval		, 4'd11,
			mip			, 4'd12,
			mtinst		, 4'd13,
			mtval2		, 4'd14
		})
	);

	wire [`XLEN-1:0] mepc_source;
	wire mepc_wt_en;
	MuxKeyWithDefault #(2, 3, `XLEN) u_mepc_source (
		.out(mepc_source),
		.key(inst_is_x),
		.default_out(source),
		.lut({
			3'b001, pc,	//ebreak
			3'b010, pc	//ecall
		})
	);
	MuxKeyWithDefault #(2, 3, 1) u_mepc_wt_en (
		.out(mepc_wt_en),
		.key(inst_is_x),
		.default_out(1'b0),
		.lut({
			3'b001, 1'b1,		//ebreak
			3'b010, 1'b1		//ecall
		})
	);

	wire [`XLEN-1:0] mcause_source;
	wire mcause_wt_en;
	MuxKeyWithDefault #(2, 3, `XLEN) u_mcause_source (
		.out(mcause_source),
		.key(inst_is_x),
		.default_out(source),
		.lut({
			3'b001, `XLEN'd3,	//ebreak
			3'b010, `XLEN'd11	//ecall
		})
	);
	MuxKeyWithDefault #(2, 3, 1) u_mcause_wt_en (
		.out(mcause_wt_en),
		.key(inst_is_x),
		.default_out(1'b0),
		.lut({
			3'b001, 1'b1,		//ebreak
			3'b010, 1'b1		//ecall
		})
	);


endmodule //CSR

`endif /* CSR_V */