/*************************************************************
 * @ name           : top.v
 * @ description    : Top
 * @ use module     : ifu, pcu, gpr, csr, idu, 
 * @ author         : K
 * @ chnge date     : 2023-3-10
*************************************************************/
`ifndef TOP_V
`define TOP_V

`include "common.v"

module top(
	input clk,
	input rst,
	output [`XLEN-1:0] pc,
	output [`XLEN-1:0] dnpc,
	output [31:0] inst
);

	wire pc_src1, pc_src2;
	wire [`XLEN-1:0] csr_r_data;
	wire [`XLEN-1:0] x_rs1, x_rs2, imm;
	reg [`XLEN-1:0] x_rd;

	`ifdef CLINT_ENABLE
		wire interrupt, msip, mtip;
		wire [`XLEN-1:0] csr_mtvec;
	`endif

	`ifdef USE_AXI_IFU
		wire pc_valid, pc_ready, inst_valid;
		reg inst_ready;
		wire inst_ready_valid = inst_ready & inst_valid;
	`endif

	wire [4:0] rs1, rs2, rd;
	wire rd_w_en, mdu_en;
	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [1:0] rd_w_src, alu_src1, alu_src2;
	wire [4:0] alu_ctrl;//[4] = inst_32, [3] = alu_sub_sra, [2:0] = funct3
	wire csr_r_en, csr_w_en;
	wire [11:0] csr_addr;
	wire inst_load, inst_store;
	wire inst_sys, inst_sys_jump, inst_jalr, inst_32, inst_sys_ecall, inst_sys_mret, inst_sys_ebreak;
	wire [`XLEN-1:0] alu_result, mdu_result;
	wire smaller, equal;
	wire [`XLEN-1:0] mem_r_data;

	/********************* pcu *********************/
	pcu u_pcu (
		.clk(clk),
		.rst(rst),
    	.pc_src1(pc_src1),
		.pc_src2(pc_src2),
		.inst_sys_jump(inst_sys_jump),
		.inst_jalr(inst_jalr),
		.x_rs1(x_rs1),
		.imm(imm),
		.csr_r_data(csr_r_data),
		`ifdef CLINT_ENABLE
			.interrupt(interrupt),
			.csr_mtvec(csr_mtvec),
		`endif
		`ifdef USE_AXI_IFU
			.pc_ready(pc_ready),
			.pc_valid(pc_valid),
			.pc_en(inst_ready_valid),
		`else
			.pc_en(1'b1),
		`endif
		.pc(pc),
		.dnpc(dnpc)
	);

	/********************* ifu *********************/
	`ifdef USE_AXI_IFU

		wire [31 : 0]  	        IFU_AXI_AWADDR;
		wire [2 : 0]   	        IFU_AXI_AWPROT;
		wire           	        IFU_AXI_AWVALID;
		wire           	        IFU_AXI_AWREADY;

		wire [63 : 0]  	        IFU_AXI_WDATA;
		wire [7 : 0]   	        IFU_AXI_WSTRB;
		wire           	        IFU_AXI_WVALID;
		wire           	        IFU_AXI_WREADY;
			
		wire [1 : 0]   	        IFU_AXI_BRESP;
		wire           	        IFU_AXI_BVALID;
		wire           	        IFU_AXI_BREADY;
			
		wire [31 : 0]  	        IFU_AXI_ARADDR;
		wire           	        IFU_AXI_ARVALID;
		wire [2 : 0]   	        IFU_AXI_ARPROT;
		wire           	        IFU_AXI_ARREADY;

		wire [63 : 0]  	        IFU_AXI_RDATA;
		wire [1 : 0]   	        IFU_AXI_RRESP;
		wire           	        IFU_AXI_RVALID;
		wire           	        IFU_AXI_RREADY;

		ifu_axi_4_lite u_ifu_axi_4_lite(
			.clk(clk),
			.rst(rst),
			.pc_valid(pc_valid),
			.pc_ready(pc_ready),
			.pc(pc),
			.inst_ready(inst_ready),
			.inst_valid(inst_valid),
			.inst(inst),
			.IFU_AXI_AWADDR(IFU_AXI_AWADDR),
			.IFU_AXI_AWPROT(IFU_AXI_AWPROT),
			.IFU_AXI_AWVALID(IFU_AXI_AWVALID),
			.IFU_AXI_AWREADY(IFU_AXI_AWREADY),
			.IFU_AXI_WDATA(IFU_AXI_WDATA),
			.IFU_AXI_WSTRB(IFU_AXI_WSTRB),
			.IFU_AXI_WVALID(IFU_AXI_WVALID),
			.IFU_AXI_WREADY(IFU_AXI_WREADY),
			.IFU_AXI_BRESP(IFU_AXI_BRESP),
			.IFU_AXI_BVALID(IFU_AXI_BVALID),
			.IFU_AXI_BREADY(IFU_AXI_BREADY),
			.IFU_AXI_ARADDR(IFU_AXI_ARADDR),
			.IFU_AXI_ARVALID(IFU_AXI_ARVALID),
			.IFU_AXI_ARPROT(IFU_AXI_ARPROT),
			.IFU_AXI_ARREADY(IFU_AXI_ARREADY),
			.IFU_AXI_RDATA(IFU_AXI_RDATA),
			.IFU_AXI_RRESP(IFU_AXI_RRESP),
			.IFU_AXI_RVALID(IFU_AXI_RVALID),
			.IFU_AXI_RREADY(IFU_AXI_RREADY)
		);

		mem_axi_4_lite #(64, 32) u_mem_axi_4_lite_ifu(
		//Global
			.AXI_ACLK(clk),
			.AXI_ARESETN(~rst),
		//AW
			.AXI_AWADDR(IFU_AXI_AWADDR),
			.AXI_AWPROT(IFU_AXI_AWPROT),
			.AXI_AWVALID(IFU_AXI_AWVALID),
			.AXI_AWREADY(IFU_AXI_AWREADY),
		//W
			.AXI_WDATA(IFU_AXI_WDATA),
			.AXI_WSTRB(IFU_AXI_WSTRB),
			.AXI_WVALID(IFU_AXI_WVALID),
			.AXI_WREADY(IFU_AXI_WREADY),
		//BR
			.AXI_BRESP(IFU_AXI_BRESP),
			.AXI_BVALID(IFU_AXI_BVALID),
			.AXI_BREADY(IFU_AXI_BREADY),
		//AR
			.AXI_ARADDR(IFU_AXI_ARADDR),
			.AXI_ARVALID(IFU_AXI_ARVALID),
			.AXI_ARPROT(IFU_AXI_ARPROT),
			.AXI_ARREADY(IFU_AXI_ARREADY),
		//R
			.AXI_RDATA(IFU_AXI_RDATA),
			.AXI_RRESP(IFU_AXI_RRESP),
			.AXI_RVALID(IFU_AXI_RVALID),
			.AXI_RREADY(IFU_AXI_RREADY)
		);

	`else

		ifu u_ifu (
			.clk(clk),
			.rst(rst),
			.pc(pc),
			.inst(inst)
		);
	`endif

	/********************* idu *********************/
	idu u_idu(
		.inst(inst),
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.imm(imm),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd)
	);

	/********************* csgu *********************/
	csgu u_csgu(
		.inst(inst),
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.rs1(rs1),
		.rd(rd),
		.rd_w_en(rd_w_en),
		.rd_w_src(rd_w_src),
		.alu_src1(alu_src1),
		.alu_src2(alu_src2),
		.alu_ctrl(alu_ctrl),
		.csr_r_en(csr_r_en),
		.csr_w_en(csr_w_en),
		.csr_addr(csr_addr),
		.inst_load(inst_load),
		.inst_store(inst_store),
		`ifdef EXTENSION_M
			.mdu_en(mdu_en),
		`endif
		.inst_sys(inst_sys),
		.inst_sys_jump(inst_sys_jump),
		.inst_sys_ecall(inst_sys_ecall),
		.inst_sys_mret(inst_sys_mret),
		.inst_sys_ebreak(inst_sys_ebreak),
		.inst_jalr(inst_jalr),
		.inst_32(inst_32)
	);

	/********************* gpr *********************/
	gpr u_gpr(
		.clk(clk),
		.rst(rst),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		`ifdef USE_AXI_IFU
			.rd_w_en(inst_ready_valid && rd_w_en),
		`else
			.rd_w_en(rd_w_en),
		`endif
		.x_rd(x_rd),
		.x_rs1(x_rs1),
		.x_rs2(x_rs2)
	);
	
	/********************* csr *********************/
	csr u_csr(
		.clk(clk),
		.rst(rst),
		.pc(pc),
		.inst_sys_ecall(inst_sys_ecall),
		.inst_sys_ebreak(inst_sys_ebreak),
		.csr_r_en(csr_r_en),
		`ifdef USE_AXI_IFU
			.inst_ready_valid(inst_ready_valid),
		`endif
		.csr_w_en(csr_w_en),
		.csr_addr(csr_addr),
		.csr_w_data(alu_result),
		`ifdef CLINT_ENABLE
			.msip(msip),
			.mtip(mtip),
			.interrupt(interrupt),
			.csr_mtvec(csr_mtvec),
		`endif
		.csr_r_data(csr_r_data)
	);

	/********************* exu *********************/
	exu u_exu (
		.funct3(funct3),
		.alu_src1(alu_src1),
		.alu_src2(alu_src2),
		.alu_ctrl(alu_ctrl),
		.rs1(rs1),
		.x_rs1(x_rs1),
		.x_rs2(x_rs2),
		.imm(imm),
		.pc(pc),
		.csr_r_data(csr_r_data),
		.alu_result(alu_result),
		.smaller(smaller),
		.equal(equal)
	);
	
	/********************* mdu *********************/
	`ifdef FAST_SIMULATION
		mdu_sim
	`else
		mdu
	`endif
		u_mdu(
			.en_mdu(mdu_en), 
			.x_rs1(x_rs1),
			.x_rs2(x_rs2),
			.funct3(funct3),
			.inst_32(inst_32),
			.mdu_result(mdu_result)
		);

	/********************* lsu *********************/
	`ifdef USE_AXI_LSU

		wire [31 : 0]  	LSU_AXI_AWADDR;
		wire [2 : 0]   	LSU_AXI_AWPROT;
		wire           	LSU_AXI_AWVALID;
		wire           	LSU_AXI_AWREADY;
		wire [63 : 0]  	LSU_AXI_WDATA;
		wire [7 : 0]   	LSU_AXI_WSTRB;
		wire           	LSU_AXI_WVALID;
		wire           	LSU_AXI_WREADY;
		wire [1 : 0]   	LSU_AXI_BRESP;
		wire           	LSU_AXI_BVALID;
		wire           	LSU_AXI_BREADY;
		wire [31 : 0]  	LSU_AXI_ARADDR;
		wire           	LSU_AXI_ARVALID;
		wire [2 : 0]   	LSU_AXI_ARPROT;
		wire           	LSU_AXI_ARREADY;
		wire [63 : 0]  	LSU_AXI_RDATA;
		wire [1 : 0]   	LSU_AXI_RRESP;
		wire           	LSU_AXI_RVALID;
		wire           	LSU_AXI_RREADY;

		lsu_axi_4_lite u_lsu_axi_4_lite(
			.clk(clk),
			.rst(rst),
			.inst_load(inst_load),
			.inst_store(inst_store),
			.funct3(funct3),
			.mem_addr(alu_result),
			.mem_w_data(x_rs2),
			`ifdef CLINT_ENABLE
				.msip(msip),
				.mtip(mtip),
			`endif
			.mem_r_data(mem_r_data),
			.LSU_AXI_AWADDR(LSU_AXI_AWADDR),
			.LSU_AXI_AWPROT(LSU_AXI_AWPROT),
			.LSU_AXI_AWVALID(LSU_AXI_AWVALID),
			.LSU_AXI_AWREADY(LSU_AXI_AWREADY),
			.LSU_AXI_WDATA(LSU_AXI_WDATA),
			.LSU_AXI_WSTRB(LSU_AXI_WSTRB),
			.LSU_AXI_WVALID(LSU_AXI_WVALID),
			.LSU_AXI_WREADY(LSU_AXI_WREADY),
			.LSU_AXI_BRESP(LSU_AXI_BRESP),
			.LSU_AXI_BVALID(LSU_AXI_BVALID),
			.LSU_AXI_BREADY(LSU_AXI_BREADY),
			.LSU_AXI_ARADDR(LSU_AXI_ARADDR),
			.LSU_AXI_ARVALID(LSU_AXI_ARVALID),
			.LSU_AXI_ARPROT(LSU_AXI_ARPROT),
			.LSU_AXI_ARREADY(LSU_AXI_ARREADY),
			.LSU_AXI_RDATA(LSU_AXI_RDATA),
			.LSU_AXI_RRESP(LSU_AXI_RRESP),
			.LSU_AXI_RVALID(LSU_AXI_RVALID),
			.LSU_AXI_RREADY(LSU_AXI_RREADY)
		);

		mem_axi_4_lite #(64, 32) u_mem_axi_4_lite_lsu(
		//Global
			.AXI_ACLK(clk),
			.AXI_ARESETN(~rst),
		//AW    
			.AXI_AWADDR(LSU_AXI_AWADDR),
			.AXI_AWPROT(LSU_AXI_AWPROT),
			.AXI_AWVALID(LSU_AXI_AWVALID),
			.AXI_AWREADY(LSU_AXI_AWREADY),
		//W 
			.AXI_WDATA(LSU_AXI_WDATA),
			.AXI_WSTRB(LSU_AXI_WSTRB),
			.AXI_WVALID(LSU_AXI_WVALID),
			.AXI_WREADY(LSU_AXI_WREADY),
		//BR    
			.AXI_BRESP(LSU_AXI_BRESP),
			.AXI_BVALID(LSU_AXI_BVALID),
			.AXI_BREADY(LSU_AXI_BREADY),
		//AR    
			.AXI_ARADDR(LSU_AXI_ARADDR),
			.AXI_ARVALID(LSU_AXI_ARVALID),
			.AXI_ARPROT(LSU_AXI_ARPROT),
			.AXI_ARREADY(LSU_AXI_ARREADY),
		//R 
			.AXI_RDATA(LSU_AXI_RDATA),
			.AXI_RRESP(LSU_AXI_RRESP),
			.AXI_RVALID(LSU_AXI_RVALID),
			.AXI_RREADY(LSU_AXI_RREADY)
		);

		always @(*) begin
			if (rst) begin
				inst_ready = 1'b0;
			end else begin
				inst_ready = inst_load ? LSU_AXI_RVALID : (inst_store ? LSU_AXI_BVALID : inst_valid);
			end
		end

	`else
		lsu u_lsu(
			.clk(clk),
			.rst(rst),
			`ifdef USE_AXI_IFU
				.inst_valid(inst_valid),
				.inst_ready(inst_ready),
			`endif
			.inst_load(inst_load & inst_ready_valid),
			.inst_store(inst_store & inst_ready_valid),
			.funct3(funct3),
			.mem_addr(alu_result),
			.mem_w_data(x_rs2),
			`ifdef CLINT_ENABLE
				.msip(msip),
				.mtip(mtip),
			`endif
			.mem_r_data(mem_r_data)
		);
	`endif
	
	/********************* bcu *********************/
	bcu u_bcu(
		.opcode(opcode),
		.funct3(funct3),
		.smaller(smaller),
		.equal(equal),
    	.pc_src1(pc_src1),
		.pc_src2(pc_src2)
	);

	/********************* x_rd *********************/
	`ifdef USE_IF_CASE

		always @(*) begin
			case (rd_w_src)
				`RD_SRC_ALU: x_rd = alu_result;
				`RD_SRC_MEM: x_rd = mem_r_data;
				`RD_SRC_MDU: x_rd = mdu_result;
				`RD_SRC_CSR: x_rd = csr_r_data;
			endcase
		end

	`else

		MuxKeyWithDefault #(4, 2, `XLEN) u_x_rd (
			.out(x_rd),
			.key(rd_w_src),
			.default_out(`XLEN'b0),
			.lut({
				`RD_SRC_ALU,	alu_result,
				`RD_SRC_MEM,	mem_r_data,
				`RD_SRC_MDU,	mdu_result,
				`RD_SRC_CSR,	csr_r_data
			})
		);
	`endif

endmodule

`endif /* TOP_V */