/*************************************************************
 * @ name           : csr.v
 * @ description    : Control and Status Register
 * @ use module     : MuxKeyWithDefault
 * @ author         : K
 * @ date modified  : 2023-3-13
*************************************************************/
`ifndef CSR_V
`define CSR_V

`include "common.v"

module csr (
    input  clk,
    input  rst,
    input  [63:0] pc,
    input  inst_system_ecall,
    input  inst_system_ebreak,
    input  csr_r_en, 
    input  csr_w_en,
    input  [11:0] csr_r_addr,
    input  [11:0] csr_w_addr,
    input  [63:0] csr_w_data,
`ifdef CLINT_ENABLE
    input  msip,
    input  mtip,
    output interrupt,
    output [63:0] csr_mtvec,
`endif
    output [63:0] csr_r_data
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
    localparam mask_mstatus_mie = 64'h8;
    localparam mask_mip_msip 	= 64'h8;
    localparam mask_mip_mtip 	= 64'h80;
    localparam mask_mip_meip 	= 64'h800;
    localparam mask_mie_msie 	= 64'h8;
    localparam mask_mie_mtie 	= 64'h80;
    localparam mask_mie_meie 	= 64'h800;
    localparam mask_mcause_msi  = 64'h8000_0000_0000_0003;
    localparam mask_mcause_mti  = 64'h8000_0000_0000_0007;
    localparam mask_mcause_mei  = 64'h8000_0000_0000_000B;

    wire [63:0] mcsr[15:0];
    wire [15:0] mcsr_w_en;

`ifdef CLINT_ENABLE
    wire [63:0] mip_dout;
    assign mcsr[idx_mip] = mip_dout | (msip ? mask_mip_msip : 64'b0) | (mtip ? mask_mip_mtip : 64'b0);
`endif

    generate
        for (genvar n = 0; n < 15; n = n + 1) begin: csr_gen
            if (n == idx_mstatus) //mstatus
                Reg #(64, 64'ha00001800) u_csr (
                    .clk(clk), 
                    .rst(rst), 
                    .din(mstatus_source), 
                    .dout(mcsr[n]), 
                    .wen(mcsr_w_en[n] | exception));
            else if (n == idx_mepc) //mepc
                Reg #(64, 64'b0) u_csr (
                    .clk(clk), 
                    .rst(rst), 
                    .din(mepc_source), 
                    .dout(mcsr[n]), 
                    .wen(mcsr_w_en[n] | exception));
            else if (n == idx_mcause) //mcause
                Reg #(64, 64'b0) u_csr (
                    .clk(clk), 
                    .rst(rst), 
                    .din(mcause_source), 
                    .dout(mcsr[n]), 
                    .wen(mcsr_w_en[n] | exception));
                    
            `ifdef CLINT_ENABLE
                else if (n == idx_mip) //mip
                    Reg #(64, 64'b0) u_csr (
                        .clk(clk), 
                        .rst(rst), 
                        .din(csr_w_data), 
                        .dout(mip_dout), 
                        .wen(mcsr_w_en[n]));
            `endif
            else
                Reg #(64, 64'b0) u_csr (
                    .clk(clk), 
                    .rst(rst), 
                    .din(csr_w_data), 
                    .dout(mcsr[n]), 
                    .wen(mcsr_w_en[n]));
        end
    endgenerate

    wire [3:0] csr_r_idx, csr_w_idx;
    assign csr_r_idx =     csr_r_en ? 
                           ((csr_r_addr == addr_mstatus   ) ? idx_mstatus     : 
                            (csr_r_addr == addr_misa      ) ? idx_misa        : 
                            (csr_r_addr == addr_medeleg   ) ? idx_medeleg     : 
                            (csr_r_addr == addr_mideleg   ) ? idx_mideleg     : 
                            (csr_r_addr == addr_mie       ) ? idx_mie         : 
                            (csr_r_addr == addr_mtvec     ) ? idx_mtvec       : 
                            (csr_r_addr == addr_mcounteren) ? idx_mcounteren  : 
                            (csr_r_addr == addr_mstatush  ) ? idx_mstatush    : 
                            (csr_r_addr == addr_mscratch  ) ? idx_mscratch    : 
                            (csr_r_addr == addr_mepc      ) ? idx_mepc        : 
                            (csr_r_addr == addr_mcause    ) ? idx_mcause      : 
                            (csr_r_addr == addr_mtval     ) ? idx_mtval       : 
                            (csr_r_addr == addr_mip       ) ? idx_mip         : 
                            (csr_r_addr == addr_mtinst    ) ? idx_mtinst      : 
                            (csr_r_addr == addr_mtval2    ) ? idx_mtval2      : 0): 0;

    assign csr_w_idx =     csr_w_en ? 
                           ((csr_w_addr == addr_mstatus   ) ? idx_mstatus     : 
                            (csr_w_addr == addr_misa      ) ? idx_misa        : 
                            (csr_w_addr == addr_medeleg   ) ? idx_medeleg     : 
                            (csr_w_addr == addr_mideleg   ) ? idx_mideleg     : 
                            (csr_w_addr == addr_mie       ) ? idx_mie         : 
                            (csr_w_addr == addr_mtvec     ) ? idx_mtvec       : 
                            (csr_w_addr == addr_mcounteren) ? idx_mcounteren  : 
                            (csr_w_addr == addr_mstatush  ) ? idx_mstatush    : 
                            (csr_w_addr == addr_mscratch  ) ? idx_mscratch    : 
                            (csr_w_addr == addr_mepc      ) ? idx_mepc        : 
                            (csr_w_addr == addr_mcause    ) ? idx_mcause      : 
                            (csr_w_addr == addr_mtval     ) ? idx_mtval       : 
                            (csr_w_addr == addr_mip       ) ? idx_mip         : 
                            (csr_w_addr == addr_mtinst    ) ? idx_mtinst      : 
                            (csr_w_addr == addr_mtval2    ) ? idx_mtval2      : 0): 0;

    assign mcsr_w_en = {16{csr_w_en}} & (1 << csr_w_idx);

    assign csr_r_data = (csr_w_en && (csr_w_idx == csr_r_idx)) ? csr_w_data : mcsr[csr_r_idx];

`ifdef CLINT_ENABLE
    wire exception = inst_system_ecall | inst_system_ebreak | interrupt;
    assign csr_mtvec = mcsr[idx_mtvec];
    assign interrupt = ((mcsr[idx_mstatus] & mask_mstatus_mie) != 0) && ((mcsr[idx_mie] & mcsr[idx_mip]) != 0);
    wire [63:0] mcause_source = 	inst_system_ecall ? 64'd11 : inst_system_ebreak ? 64'd3 : 
                                        interrupt ? (((mcsr[idx_mip] & mask_mip_msip) != 0) ? mask_mcause_msi : 
                                                       ((mcsr[idx_mip] & mask_mip_mtip) != 0) ? mask_mcause_mti : csr_w_data) : csr_w_data;
`else
    wire exception = inst_system_ecall | inst_system_ebreak;
    wire [63:0] mcause_source = 	inst_system_ecall ? 64'd11 : (inst_system_ebreak ? 64'd3 : csr_w_data);
`endif

    wire [63:0] mstatus_source = exception ? (mcsr[idx_mstatus] & ~mask_mstatus_mie) : csr_w_data;

    wire [63:0] mepc_source = exception ? pc : csr_w_data;

endmodule //csr

`endif /* CSR_V */