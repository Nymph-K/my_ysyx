/*************************************************************
 * @ name           : lsu_axi_4_lite.v
 * @ description    : Load and Sotre Unit
 * @ use module     : 
 * @ author         : K
 * @ chnge date     : 2023-3-13
*************************************************************/
`ifndef LSU_AXI_4_LITE_V
`define LSU_AXI_4_LITE_V

`include "common.v"

module lsu_axi_4_lite (
    input 						clk,
	input 						rst,
	input   				    inst_valid,
	output reg   			    inst_ready,
	input 						mem_r_en,
	input 						mem_w_en,
	input [2:0] 				funct3,
    input [`XLEN-1:0] 			mem_addr,
	input [`XLEN-1:0] 			mem_w_data,

	`ifdef CLINT_ENABLE
		output 					msip,
		output 					mtip,
	`endif

	`ifdef USE_IF_CASE
		output reg [`XLEN-1:0] 	mem_r_data
	`else
		output 	   [`XLEN-1:0] 	mem_r_data
	`endif
);

	wire [`XLEN-1:0]             mem_rdata;

	`ifdef USE_IF_CASE
	
		`ifdef ADDR_ALIGN

			reg [7:0] mem_r8bit;
			always @(*) begin
				case (mem_addr[2:0])
					3'b000	: mem_r8bit = mem_rdata[7:0];
					3'b001	: mem_r8bit = mem_rdata[15:8];
					3'b010	: mem_r8bit = mem_rdata[23:16];
					3'b011	: mem_r8bit = mem_rdata[31:24];
					3'b100	: mem_r8bit = mem_rdata[39:32];
					3'b101	: mem_r8bit = mem_rdata[47:40];
					3'b110	: mem_r8bit = mem_rdata[55:48];
					3'b111	: mem_r8bit = mem_rdata[63:56];
				endcase
			end
			
			reg [15:0] mem_r16bit;
			always @(*) begin
				case (mem_addr[2:0])
					3'b000	: mem_r16bit = mem_rdata[15:0];
					3'b001	: mem_r16bit = mem_rdata[23:8];
					3'b010	: mem_r16bit = mem_rdata[31:16];
					3'b011	: mem_r16bit = mem_rdata[39:24];
					3'b100	: mem_r16bit = mem_rdata[47:32];
					3'b101	: mem_r16bit = mem_rdata[55:40];
					3'b110	: mem_r16bit = mem_rdata[63:48];
					default : mem_r16bit = 16'b0;
				endcase
			end
			
			reg [31:0] mem_r32bit;
			always @(*) begin
				case (mem_addr[2:0])
					3'b000	: mem_r32bit = mem_rdata[31:0];
					3'b001	: mem_r32bit = mem_rdata[39:8];
					3'b010	: mem_r32bit = mem_rdata[47:16];
					3'b011	: mem_r32bit = mem_rdata[55:24];
					3'b100	: mem_r32bit = mem_rdata[63:32];
					default : mem_r32bit = 32'b0;
				endcase
			end
			
			always @(*) begin
				case (funct3)
					`LB		: mem_r_data = {{(`XLEN-8){mem_r8bit[7]}}, mem_r8bit[7:0]};
					`LH		: mem_r_data = {{(`XLEN-16){mem_r16bit[15]}}, mem_r16bit[15:0]};
					`LW		: mem_r_data = {{(`XLEN-32){mem_r32bit[31]}}, mem_r32bit[31:0]};
					`LBU	: mem_r_data = {{(`XLEN-8){1'b0}}, mem_r8bit[7:0]};
					`LHU	: mem_r_data = {{(`XLEN-16){1'b0}}, mem_r16bit[15:0]};
					`LWU	: mem_r_data = {{(`XLEN-32){1'b0}}, mem_r32bit[31:0]};
					`LD		: mem_r_data = mem_rdata;
					default : mem_r_data = `XLEN'b0;
				endcase
			end
			
			reg [7:0] wmask;
			always @(*) begin
				case (funct3)
					`SB		: wmask = 8'b0000_0001 << mem_addr[2:0];
					`SH		: wmask = 8'b0000_0011 << mem_addr[2:0];
					`SW		: wmask = 8'b0000_1111 << mem_addr[2:0];
					`SD		: wmask = 8'b1111_1111;
					default : wmask = 8'b0;
				endcase
			end

		`else//ADDR_ALIGN
			
			wire [7:0] wmask = 8'b1 << funct3[1:0];

			always @(*) begin
				case (funct3)
					`LB		: mem_r_data = {{(`XLEN-8){mem_rdata[7]}}, mem_rdata[7:0]};
					`LH		: mem_r_data = {{(`XLEN-16){mem_rdata[15]}}, mem_rdata[15:0]};
					`LW		: mem_r_data = {{(`XLEN-32){mem_rdata[31]}}, mem_rdata[31:0]};
					`LBU	: mem_r_data = {{(`XLEN-8){1'b0}}, mem_rdata[7:0]};
					`LHU	: mem_r_data = {{(`XLEN-16){1'b0}}, mem_rdata[15:0]};
					`LWU	: mem_r_data = {{(`XLEN-32){1'b0}}, mem_rdata[31:0]};
					`LD		: mem_r_data = mem_rdata;
					default : mem_r_data = `XLEN'b0;
				endcase
			end
			
		`endif//ADDR_ALIGN

			/****************************************************************************************************************************************/
	`else	/****************************************************************************************************************************************/
			/****************************************************************************************************************************************/

		`ifdef ADDR_ALIGN

			wire [7:0] mem_r8bit;
			MuxKeyWithDefault #(8, 3, 8) u_mem_r8bit (
				.out(mem_r8bit),
				.key(mem_addr[2:0]),
				.default_out(8'b0),
				.lut({
					3'b000, mem_rdata[7:0],
					3'b001, mem_rdata[15:8],
					3'b010, mem_rdata[23:16],
					3'b011, mem_rdata[31:24],
					3'b100, mem_rdata[39:32],
					3'b101, mem_rdata[47:40],
					3'b110, mem_rdata[55:48],
					3'b111, mem_rdata[63:56]
				})
			);

			wire [15:0] mem_r16bit;
			MuxKeyWithDefault #(7, 3, 16) u_mem_r16bit (
				.out(mem_r16bit),
				.key(mem_addr[2:0]),
				.default_out(16'b0),
				.lut({
					3'b000, mem_rdata[15:0],
					3'b001, mem_rdata[23:8],
					3'b010, mem_rdata[31:16],
					3'b011, mem_rdata[39:24],
					3'b100, mem_rdata[47:32],
					3'b101, mem_rdata[55:40],
					3'b110, mem_rdata[63:48]
				})
			);

			wire [31:0] mem_r32bit;
			MuxKeyWithDefault #(5, 3, 32) u_mem_r32bit (
				.out(mem_r32bit),
				.key(mem_addr[2:0]),
				.default_out(32'b0),
				.lut({
					3'b000, mem_rdata[31:0],
					3'b001, mem_rdata[39:8],
					3'b010, mem_rdata[47:16],
					3'b011, mem_rdata[55:24],
					3'b100, mem_rdata[63:32]
				})
			);

			MuxKeyWithDefault #(7, 3, `XLEN) u_read_data (
				.out(mem_r_data),
				.key(funct3),
				.default_out(`XLEN'b0),
				.lut({
					`LB, 	{{(`XLEN-8){mem_r8bit[7]}}, mem_r8bit[7:0]},
					`LH,	{{(`XLEN-16){mem_r16bit[15]}}, mem_r16bit[15:0]},
					`LW,	{{(`XLEN-32){mem_r32bit[31]}}, mem_r32bit[31:0]},
					`LBU,	{{(`XLEN-8){1'b0}}, mem_r8bit[7:0]},
					`LHU,	{{(`XLEN-16){1'b0}}, mem_r16bit[15:0]},
					`LWU,	{{(`XLEN-32){1'b0}}, mem_r32bit[31:0]},
					`LD,	mem_rdata
				})
			);

			wire [7:0] wmask;
			MuxKeyWithDefault #(4, 3, 8) u_wmask (
				.out(wmask),
				.key(funct3),
				.default_out(8'b0),
				.lut({
					`SB, 8'b0000_0001 << mem_addr[2:0],
					`SH, 8'b0000_0011 << mem_addr[2:0],
					`SW, 8'b0000_1111 << mem_addr[2:0],
					`SD, 8'b1111_1111
				})
			);

		`else//ADDR_ALIGN

			wire [7:0] wmask = 8'b1 << funct3[1:0];

			MuxKeyWithDefault #(7, 3, `XLEN) u_read_data (
				.out(mem_r_data),
				.key(funct3),
				.default_out(`XLEN'b0),
				.lut({
					`LB, 	{{(`XLEN-8){mem_rdata[7]}}, mem_rdata[7:0]},
					`LH,	{{(`XLEN-16){mem_rdata[15]}}, mem_rdata[15:0]},
					`LW,	{{(`XLEN-32){mem_rdata[31]}}, mem_rdata[31:0]},
					`LBU,	{{(`XLEN-8){1'b0}}, mem_rdata[7:0]},
					`LHU,	{{(`XLEN-16){1'b0}}, mem_rdata[15:0]},
					`LWU,	{{(`XLEN-32){1'b0}}, mem_rdata[31:0]},
					`LD,	mem_rdata
				})
			);

		`endif//ADDR_ALIGN
	
	`endif //USE_IF_CASE

	`ifdef CLINT_ENABLE
			wire [`XLEN-1:0] mtime, mtimecmp;
			CLINT u_clint(
				.clk(clk),
				.rst(rst),
				.mem_w_en(mem_w_en),
				.mem_w_data(mem_w_data),
				.mem_addr(mem_addr),
				.msip(msip),
				.mtip(mtip),
				.mtime(mtime),
				.mtimecmp(mtimecmp)
			);
	`endif //CLINT_ENABLE

    always @(*) begin
        if (rst) begin
            inst_ready = 1'b0;
        end else begin
			inst_ready = mem_r_en ? AXI_RVALID : (mem_w_en ? AXI_BVALID : inst_valid);
        end
    end

    mem_axi_4_lite #(64, 32) u_mem_axi_4_lite_1(
    //Global
        .AXI_ACLK(clk),
        .AXI_ARESETN(~rst),
    //AW    
        .AXI_AWADDR(AXI_AWADDR),
        .AXI_AWPROT(AXI_AWPROT),
        .AXI_AWVALID(AXI_AWVALID),
        .AXI_AWREADY(AXI_AWREADY),
    //W 
        .AXI_WDATA(AXI_WDATA),
        .AXI_WSTRB(AXI_WSTRB),
        .AXI_WVALID(AXI_WVALID),
        .AXI_WREADY(AXI_WREADY),
    //BR    
        .AXI_BRESP(AXI_BRESP),
        .AXI_BVALID(AXI_BVALID),
        .AXI_BREADY(AXI_BREADY),
    //AR    
        .AXI_ARADDR(AXI_ARADDR),
        .AXI_ARVALID(AXI_ARVALID),
        .AXI_ARPROT(AXI_ARPROT),
        .AXI_ARREADY(AXI_ARREADY),
    //R 
        .AXI_RDATA(AXI_RDATA),
        .AXI_RRESP(AXI_RRESP),
        .AXI_RVALID(AXI_RVALID),
        .AXI_RREADY(AXI_RREADY)
    );

    wire [31:0] AXI_AWADDR, AXI_ARADDR;
    wire [2:0] AXI_AWPROT, AXI_ARPROT;
    wire [63:0] AXI_WDATA, AXI_RDATA;
    wire [7:0] AXI_WSTRB;
    reg AXI_AWVALID, AXI_WVALID, AXI_ARVALID;
	wire AXI_BREADY, AXI_RREADY;
    wire AXI_AWREADY, AXI_WREADY, AXI_BVALID, AXI_ARREADY, AXI_RVALID;
    wire [1:0] AXI_BRESP, AXI_RRESP;
	
    //-----------------------------------------register---------------------------------------------------
    reg                                           axi_awvalid;
    reg                                           axi_wvalid;
    reg                                           axi_bready;
    reg                                           axi_arvalid;
    reg                                           axi_rready;

    assign AXI_AWADDR       = mem_addr[31:0];
    assign AXI_AWPROT       = 3'b000;

    assign AXI_WDATA        = mem_w_data;
    assign AXI_WSTRB        = wmask;

    assign AXI_BREADY       = axi_bready;

    assign AXI_ARADDR       = mem_addr[31:0];
    assign AXI_ARPROT	    = 3'b000;
	assign mem_rdata		= AXI_RDATA;

    assign AXI_RREADY       = axi_rready;

	always @(*) begin
		if(state == FSM_IDLE)begin
    		AXI_AWVALID      = mem_w_en;
    		AXI_WVALID       = mem_w_en;
    		AXI_ARVALID      = mem_r_en;
		end else begin
    		AXI_AWVALID      = axi_awvalid;
    		AXI_WVALID       = axi_wvalid ;
    		AXI_ARVALID      = axi_arvalid;
		end
	end
    
    //--------------------------------------------FSM-Moore------------------------------------------------
    reg [2: 0] state;
    parameter [2:0]
        FSM_IDLE    	= 3'b000 ,
        FSM_WVALID     	= 3'b001 ,
        FSM_AWREADY 	= 3'b010 ,
        FSM_WREADY  	= 3'b011 ,
        FSM_BVALID  	= 3'b100 ,
        FSM_RREADY     	= 3'b101 ,
        FSM_ARREADY  	= 3'b110 ,
        FSM_WAIT	   	= 3'b111 ;

    always @(posedge clk)
    begin
        if (rst)
        begin
            state           <= FSM_IDLE;
            axi_awvalid     <= 1'b0;
            axi_wvalid      <= 1'b0;
            axi_bready      <= 1'b1;
            axi_arvalid     <= 1'b0;
            axi_rready      <= 1'b1;
        end else begin
            case(state)
                FSM_IDLE    : begin
                    if(mem_w_en)   begin 
						if(AXI_AWREADY && AXI_WREADY)   begin 
							state           <= FSM_BVALID;
							axi_awvalid     <= 1'b0;
							axi_wvalid      <= 1'b0;
						end
						else if(AXI_AWREADY)   begin 
							state           <= FSM_AWREADY;
							axi_awvalid     <= 1'b0;
						end
						else if(AXI_WREADY)   begin 
							state           <= FSM_WREADY;
							axi_wvalid      <= 1'b0;
						end
                    end
                    else if(mem_r_en)   begin 
						if(AXI_ARREADY)   begin 
							state           <= FSM_ARREADY;
							axi_arvalid     <= 1'b0;
						end
                    end
                end

                FSM_WVALID :
                    if(AXI_AWREADY && AXI_WREADY)   begin 
                        state           <= FSM_BVALID;
                        axi_awvalid     <= 1'b0;
                        axi_wvalid      <= 1'b0;
                    end
                    else if(AXI_AWREADY)   begin 
                        state           <= FSM_AWREADY;
                        axi_awvalid     <= 1'b0;
                    end
                    else if(AXI_WREADY)   begin 
                        state           <= FSM_WREADY;
                        axi_wvalid      <= 1'b0;
                    end
    
                FSM_AWREADY  :
                    if(AXI_WREADY)   begin 
                        state           <= FSM_BVALID;
                        axi_wvalid      <= 1'b0;
                    end
    
                FSM_WREADY  :
                    if(AXI_AWREADY)   begin 
                        state           <= FSM_BVALID;
                        axi_awvalid     <= 1'b0;
                    end

                FSM_BVALID  : 
                    if(AXI_BVALID)   begin 
                        state           <= FSM_WAIT;
                        axi_bready      <= 1'b0;
                    end

                FSM_RREADY : 
                    if(AXI_ARREADY)   begin 
                        state           <= FSM_ARREADY;
                        axi_arvalid     <= 1'b0;
                    end

                FSM_ARREADY : 
                    if(AXI_RVALID)   begin 
                        state           <= FSM_WAIT;
                        axi_rready      <= 1'b0;
                    end

                FSM_WAIT : // wait for next inst
                    begin 
                        state           <= FSM_IDLE;
						axi_bready      <= 1'b1;
						axi_rready      <= 1'b1;
                    end

                default     : begin 
                    state           <= FSM_IDLE;
                    axi_awvalid     <= 1'b0;
                    axi_wvalid      <= 1'b0;
                    axi_bready      <= 1'b1;
                    axi_arvalid     <= 1'b0;
                    axi_rready      <= 1'b1;
                    end
            endcase
        end
    end

endmodule //lsu_axi_4_lite

`endif