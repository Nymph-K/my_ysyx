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
    input  msip,
    input  mtip,
	output interrupt,
	output [`XLEN-1:0] csr,
	output [`XLEN-1:0] csr_mtvec
);
	//Machine Trap Setup
	localparam addr_mstatus		= 12'h300;	//Machine status register.
	localparam addr_misa		= 12'h301;	//ISA and extensions
	localparam addr_medeleg		= 12'h302;	//Machine exception delegation register.
	localparam addr_mideleg		= 12'h303;	//Machine interrupt delegation register.
	localparam addr_mie			= 12'h304;	//Machine interrupt-enable register.
	localparam addr_mtvec		= 12'h305;	//Machine trap-handler base address.
	localparam addr_mcounteren	= 12'h306;	//Machine counter enable.
	localparam addr_mstatush	= 12'h310;	//Additional machine status register, RV32 only.
	//Machine Trap Handling
	localparam addr_mscratch	= 12'h340;	//Scratch register for machine trap handlers.
	localparam addr_mepc		= 12'h341;	//Machine exception program counter.
	localparam addr_mcause		= 12'h342;	//Machine trap cause.
	localparam addr_mtval		= 12'h343;	//Machine bad address or instruction.
	localparam addr_mip			= 12'h344;	//Machine interrupt pending.
	localparam addr_mtinst		= 12'h34A;	//Machine trap instruction (transformed).
	localparam addr_mtval2		= 12'h34B;	//Machine bad guest physical address.
	//indx
	localparam idx_mstatus		= 0;
	localparam idx_misa			= 1;
	localparam idx_medeleg		= 2;
	localparam idx_mideleg		= 3;
	localparam idx_mie			= 4;
	localparam idx_mtvec		= 5;
	localparam idx_mcounteren	= 6;
	localparam idx_mstatush		= 7;
	localparam idx_mscratch		= 8;
	localparam idx_mepc			= 9;
	localparam idx_mcause		= 10;
	localparam idx_mtval		= 11;
	localparam idx_mip			= 12;
	localparam idx_mtinst		= 13;
	localparam idx_mtval2		= 14;
	//mask
	localparam mask_mstatus_mie = `XLEN'h8;
	localparam mask_mip_msip 	= `XLEN'h8;
	localparam mask_mip_mtip 	= `XLEN'h80;
	localparam mask_mip_meip 	= `XLEN'h800;
	localparam mask_mie_msie 	= `XLEN'h8;
	localparam mask_mie_mtie 	= `XLEN'h80;
	localparam mask_mie_meie 	= `XLEN'h800;
	localparam mask_mcause_msi = `XLEN'h8000_0000_0000_0003;
	localparam mask_mcause_mti = `XLEN'h8000_0000_0000_0007;
	localparam mask_mcause_mei = `XLEN'h8000_0000_0000_000B;
	//SYSTEM
	localparam CSRRW	= 3'b001;
	localparam CSRRS	= 3'b010;
	localparam CSRRC	= 3'b011;
	localparam CSRRWI	= 3'b101;
	localparam CSRRSI	= 3'b110;
	localparam CSRRCI	= 3'b111;
	//inst_is
	localparam INST_EBREAK	= 4'b0001;
	localparam INST_ECALL	= 4'b0010;
	localparam INST_MRET	= 4'b0100;
	localparam INST_INTR	= 4'b1000;

	wire [`XLEN-1:0] mcsr[15:0];
	wire [`XLEN-1:0] mip_dout;
	assign mcsr[idx_mip] = mip_dout | (msip ? mask_mip_msip : `XLEN'b0) | (mtip ? mask_mip_mtip : `XLEN'b0);
	generate
		for (genvar n = 0; n < 15; n = n + 1) begin: csr_gen
			if (n == 0) //mstatus
				Reg #(`XLEN, `XLEN'ha00001800) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(mstatus_source), 
					.dout(mcsr[n]), 
					.wen(((mcsr_idx == n && wt_en == 1'b1) || interrupt) ? 1'b1 : 1'b0));
			else if (n == 9) //mepc
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(mepc_source), 
					.dout(mcsr[n]), 
					.wen(((mcsr_idx == n && wt_en == 1'b1) || exception == 1'b1) ? 1'b1 : 1'b0));
			else if (n == 10) //mcause
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(mcause_source), 
					.dout(mcsr[n]), 
					.wen(((mcsr_idx == n && wt_en == 1'b1) || exception == 1'b1) ? 1'b1 : 1'b0));
			else if (n == 12) //mip
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(source), 
					.dout(mip_dout), 
					.wen((mcsr_idx == n && wt_en == 1'b1) ? 1'b1 : 1'b0));
			else
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(source), 
					.dout(mcsr[n]), 
					.wen((mcsr_idx == n && wt_en == 1'b1) ? 1'b1 : 1'b0));
		end
	endgenerate

	assign csr_mtvec = mcsr[idx_mtvec];
	assign csr = (rd_en == 1'b1) ? mcsr[mcsr_idx] : `XLEN'b0;

	wire [3:0] mcsr_idx;
	MuxKeyWithDefault #(15, 12, 4) u_mcsr_idx (
		.out(mcsr_idx),
		.key(csr_idx),
		.default_out(4'd0),
		.lut({
			addr_mstatus	, 4'd0,
			addr_misa		, 4'd1,
			addr_medeleg	, 4'd2,
			addr_mideleg	, 4'd3,
			addr_mie		, 4'd4,
			addr_mtvec		, 4'd5,
			addr_mcounteren	, 4'd6,
			addr_mstatush	, 4'd7,
			addr_mscratch	, 4'd8,
			addr_mepc		, 4'd9,
			addr_mcause		, 4'd10,
			addr_mtval		, 4'd11,
			addr_mip		, 4'd12,
			addr_mtinst		, 4'd13,
			addr_mtval2		, 4'd14
		})
	);

	wire [3:0] inst_is = {interrupt, inst_is_x};
	assign interrupt = ((mcsr[idx_mstatus] & mask_mstatus_mie) != 0) && ((mcsr[idx_mie] & mcsr[idx_mip]) != 0);
	wire exception = (inst_is & ~INST_MRET) != 0;

	wire [`XLEN-1:0] mstatus_source = interrupt ? (mcsr[idx_mstatus] & ~mask_mstatus_mie) : source;

	wire [`XLEN-1:0] mepc_source = exception ? pc : source;

	wire [`XLEN-1:0] mcause_source = 	((inst_is & INST_EBREAK) != 0) ? `XLEN'd3 : 
										((inst_is & INST_ECALL) != 0) ? `XLEN'd11 : 
										(interrupt) ? (((mcsr[idx_mip] & mask_mip_msip) != 0) ? mask_mcause_msi : 
													   ((mcsr[idx_mip] & mask_mip_mtip) != 0) ? mask_mcause_mti : source) : source;

endmodule //CSR

`endif /* CSR_V */