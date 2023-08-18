/*************************************************************
 * @ name           : lsu.v
 * @ description    : Load and Sotre Unit
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-7-31
*************************************************************/
`ifndef LSU_V
`define LSU_V

`include "common.v"

module lsu (
    input 						clk,
    input 						rst,
    input         [ 2:0] 		funct3,
    input         [31:0]        lsu_addr,
    input                       lsu_r_ready,
    output  reg   [63:0]        lsu_r_data,     // not align
    output  reg                 lsu_r_valid,
    input                       lsu_w_valid,
    input         [63:0]        lsu_w_data,     // not align
    output  reg                 lsu_w_ready
);

    always @(posedge clk) begin
        if(rst) begin
            lsu_r_valid <= 0; 
            lsu_w_ready <= 0; 
        end else begin
            lsu_r_valid <= lsu_r_ready;
            lsu_w_ready <= lsu_w_valid;
        end
    end
    //assign lsu_r_valid = lsu_r_ready;
    //assign lsu_w_ready = lsu_w_valid;

    reg           [ 7:0]        lsu_w_strb;     // 8 Byte align, 8 Byte strobe
    wire          [31:0]        lsu_addr_a = lsu_addr & 32'hFFFFFFF8;     // 8 Byte align
    reg           [63:0]        mem_rdata;   // 8 Byte align
    
    wire [2:0]                  shift_n_byte = lsu_addr[2:0];
    wire [5:0]                  shift_n_bit  = {shift_n_byte, 3'b000}; // *8

    wire                        device_access = lsu_addr[31:28] == 4'hA;

    wire [63:0]            lsu_rdata_shift = mem_rdata >> shift_n_bit;

    wire [63:0]            lsu_w_data_a = lsu_w_data << shift_n_bit;

    import "DPI-C" function void paddr_read(input longint raddr, output longint mem_r_data);
    import "DPI-C" function void paddr_write(input longint waddr, input longint mem_w_data, input byte wmask);

    always @(negedge clk ) begin
        if (rst) begin
            mem_rdata = 0;
        end else begin
            if (lsu_r_ready && lsu_r_valid) begin
                paddr_read({32'b0, lsu_addr_a}, mem_rdata);
            end
            if (lsu_w_valid && lsu_w_ready) begin
                paddr_write({32'b0, lsu_addr_a}, lsu_w_data_a, lsu_w_strb);
            end
        end
    end

    always @(*) begin
        if(lsu_r_ready) begin
            case (funct3)
                `LB		: lsu_r_data = {{(64-8){lsu_rdata_shift[7]}}, lsu_rdata_shift[7:0]};
                `LH		: lsu_r_data = {{(64-16){lsu_rdata_shift[15]}}, lsu_rdata_shift[15:0]};
                `LW		: lsu_r_data = {{(64-32){lsu_rdata_shift[31]}}, lsu_rdata_shift[31:0]};
                `LBU	: lsu_r_data = {{(64-8){1'b0}}, lsu_rdata_shift[7:0]};
                `LHU	: lsu_r_data = {{(64-16){1'b0}}, lsu_rdata_shift[15:0]};
                `LWU	: lsu_r_data = {{(64-32){1'b0}}, lsu_rdata_shift[31:0]};
                `LD		: lsu_r_data = lsu_rdata_shift;
                default : lsu_r_data = 64'b0;
            endcase
        end else begin
            lsu_r_data = 64'b0;
        end
    end
    
    always @(*) begin
        if(lsu_w_valid) begin
            case (funct3)
                `SB		: lsu_w_strb = 8'b0000_0001 << shift_n_byte;
                `SH		: lsu_w_strb = 8'b0000_0011 << shift_n_byte;
                `SW		: lsu_w_strb = 8'b0000_1111 << shift_n_byte;
                `SD		: lsu_w_strb = 8'b1111_1111;
                default : lsu_w_strb = 8'b0000_0000;
            endcase
        end else begin
            lsu_w_strb = 8'b0;
        end
    end
    
endmodule //lsu

`endif