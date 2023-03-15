/*************************************************************
 * @ name           : csr.v
 * @ description    : Control and Status Register
 * @ use module     : MuxKeyWithDefault
 * @ author         : K
 * @ chnge date     : 2023-3-13
*************************************************************/
`ifndef CSR_V
`define CSR_V

`include "common.v"

module csr (
	input  clk,
	input  rst,
	input  [`XLEN-1:0] pc,
	input  inst_sys_ecall,
	input  inst_sys_ebreak,
	input  csr_r_en, 
	input  csr_w_en,
	input  [11:0] csr_addr,
	input  [`XLEN-1:0] csr_w_data,
`ifdef CLINT_ENABLE
    input  msip,
    input  mtip,
	output interrupt,
	output [`XLEN-1:0] csr_mtvec,
`endif
	output [`XLEN-1:0] csr_r_data
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
	localparam idx_mstatus		= 4'd0;
	localparam idx_misa			= 4'd1;
	localparam idx_medeleg		= 4'd2;
	localparam idx_mideleg		= 4'd3;
	localparam idx_mie			= 4'd4;
	localparam idx_mtvec		= 4'd5;
	localparam idx_mcounteren	= 4'd6;
	localparam idx_mstatush		= 4'd7;
	localparam idx_mscratch		= 4'd8;
	localparam idx_mepc			= 4'd9;
	localparam idx_mcause		= 4'd10;
	localparam idx_mtval		= 4'd11;
	localparam idx_mip			= 4'd12;
	localparam idx_mtinst		= 4'd13;
	localparam idx_mtval2		= 4'd14;
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

	wire [`XLEN-1:0] mcsr[15:0];
`ifdef CLINT_ENABLE
	wire [`XLEN-1:0] mip_dout;
	assign mcsr[idx_mip] = mip_dout | (msip ? mask_mip_msip : `XLEN'b0) | (mtip ? mask_mip_mtip : `XLEN'b0);
`endif
	generate
		for (genvar n = 0; n < 15; n = n + 1) begin: csr_gen
			if (n == idx_mstatus) //mstatus
				Reg #(`XLEN, `XLEN'ha00001800) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(mstatus_source), 
					.dout(mcsr[n]), 
					.wen(((csr_idx == n && csr_w_en == 1'b1) || exception) ? 1'b1 : 1'b0));
			else if (n == idx_mepc) //mepc
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(mepc_source), 
					.dout(mcsr[n]), 
					.wen(((csr_idx == n && csr_w_en == 1'b1) || exception == 1'b1) ? 1'b1 : 1'b0));
			else if (n == idx_mcause) //mcause
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(mcause_source), 
					.dout(mcsr[n]), 
					.wen(((csr_idx == n && csr_w_en == 1'b1) || exception == 1'b1) ? 1'b1 : 1'b0));
					
`ifdef CLINT_ENABLE
			else if (n == idx_mip) //mip
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(csr_w_data), 
					.dout(mip_dout), 
					.wen((csr_idx == n && csr_w_en == 1'b1) ? 1'b1 : 1'b0));
`endif
			else
				Reg #(`XLEN, `XLEN'b0) u_csr (
					.clk(clk), 
					.rst(rst), 
					.din(csr_w_data), 
					.dout(mcsr[n]), 
					.wen((csr_idx == n && csr_w_en == 1'b1) ? 1'b1 : 1'b0));
		end
	endgenerate

	assign csr_r_data = (csr_r_en == 1'b1) ? mcsr[csr_idx] : `XLEN'b0;

	wire [3:0] csr_idx;
	MuxKeyWithDefault #(15, 12, 4) u_mcsr_idx (
		.out(csr_idx),
		.key(csr_addr),
		.default_out(4'd0),
		.lut({
			addr_mstatus	, idx_mstatus		,
			addr_misa		, idx_misa			,
			addr_medeleg	, idx_medeleg		,
			addr_mideleg	, idx_mideleg		,
			addr_mie		, idx_mie			,
			addr_mtvec		, idx_mtvec			,
			addr_mcounteren	, idx_mcounteren	,
			addr_mstatush	, idx_mstatush		,
			addr_mscratch	, idx_mscratch		,
			addr_mepc		, idx_mepc			,
			addr_mcause		, idx_mcause		,
			addr_mtval		, idx_mtval			,
			addr_mip		, idx_mip			,
			addr_mtinst		, idx_mtinst		,
			addr_mtval2		, idx_mtval2		
		})
	);

`ifdef CLINT_ENABLE
	wire exception = inst_sys_ecall || inst_sys_ebreak || interrupt;
	assign csr_mtvec = mcsr[idx_mtvec];
	assign interrupt = ((mcsr[idx_mstatus] & mask_mstatus_mie) != 0) && ((mcsr[idx_mie] & mcsr[idx_mip]) != 0);
	wire [`XLEN-1:0] mcause_source = 	inst_sys_ecall ? `XLEN'd11 : inst_sys_ebreak ? `XLEN'd3 : 
										interrupt ? (((mcsr[idx_mip] & mask_mip_msip) != 0) ? mask_mcause_msi : 
													   ((mcsr[idx_mip] & mask_mip_mtip) != 0) ? mask_mcause_mti : csr_w_data) : csr_w_data;
`else
	wire exception = inst_sys_ecall || inst_sys_ebreak;
	wire [`XLEN-1:0] mcause_source = 	inst_sys_ecall ? `XLEN'd11 : (inst_sys_ebreak ? `XLEN'd3 : csr_w_data);
`endif

	wire [`XLEN-1:0] mstatus_source = exception ? (mcsr[idx_mstatus] & ~mask_mstatus_mie) : csr_w_data;

	wire [`XLEN-1:0] mepc_source = exception ? pc : csr_w_data;

endmodule //csr

`endif /* CSR_V */