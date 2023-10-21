/*************************************************************
 * @ name           : cache_ctrl.v
 * @ description    : Cache control
 * @ use module     : 
 * @ author         : K
 * @ date modified  : 2023-4-16

 * @ Cache Size     : 4 KB
 * @ Cache Type     : 4 - way set associative cache
 * @ allocation     : write allocation
 * @ update         : write back
 * @ replace        : Random (LFSR 8 bit)
 * @ block size     : 64 Byte
 * @ set   num      : 16 lines
 
 * @ data width     : 64
 * @ addr width     : 32
 * @ tag  width     : 24

 * @ addr format    : [ 31                   addr                      0 ]
 * @ addr format    : [ 31  tag[21:0]  10 ][ 9  index  6 ][ 5  offset  0 ]

 * @ tag  format    :     [ 23   22  21     tag      0]
 * @ tag  format    :     [ v ][ d ][   addr[31:10]   ]
*************************************************************/
`ifndef CACHE_CTRL_V
`define CACHE_CTRL_V

`define valid(tag) tag[23]
`define dirty(tag) tag[22]

module cache_ctrl (
    input                       clk,
    input                       rst,

    input         [31:0]        cpu_addr,       // [2:0] not use
	input                       cpu_r_ready,
	output        [63:0]        cpu_r_data,     // 8 Byte align
	output  reg                 cpu_r_valid,
	input                       cpu_w_valid,
	input         [ 7:0]        cpu_w_strb,     // 8 Byte align, 8 Byte strobe
	input         [63:0]        cpu_w_data,     // 8 Byte align
	output  reg                 cpu_w_ready,

    output  reg                 tag_w_en,
    output  reg   [23:0]        tag_w_data,
    input         [23:0]        tag0,
    input         [23:0]        tag1,
    input         [23:0]        tag2,
    input         [23:0]        tag3,

    output  reg   [ 1:0]        way,
    output  reg   [ 3:0]        index,
    output  reg   [ 5:0]        offset,

    output  reg                 sram_r_en,
    output  reg                 sram_w_en,
    output  reg   [63:0]        sram_w_data,
    output  reg   [ 7:0]        sram_w_strb, // 8 Byte strobe
    input         [63:0]        sram_r_data,

    output        [31:0]        mem_w_addr,
    output  reg                 mem_w_valid,
    output        [ 2:0]        mem_w_size,     // 2^size Byte
    output        [ 1:0]        mem_w_burst,    // 0-FIXED, 1-INC, 2-WRAP
    output        [ 7:0]        mem_w_len,      // len+1 times
    output        [ 7:0]        mem_w_strb,
    output        [63:0]        mem_w_data,
    input                       mem_w_ready,

    output        [31:0]        mem_r_addr,
    output  reg                 mem_r_ready,
    output        [ 2:0]        mem_r_size,     // 2^size Byte
    output        [ 1:0]        mem_r_burst,    // 0-FIXED, 1-INC, 2-WRAP
    output        [ 7:0]        mem_r_len,      // len+1 times
    input                       mem_r_valid,
    input         [63:0]        mem_r_data,

    output                      cache_idle
);
    wire [21:0] tag, tag_r;
    wire [ 3:0] index_addr, index_r;
    wire [5:0] offset_addr;
    wire [5:0] offset_r;
    reg [31:0] cpu_addr_r;
    //wire [31:0] addr_actual;
    reg [5:0] offset_inc;
    reg [7:0] lfsr;
    reg [63:0] cpu_rdata, cpu_rdata_r;
    reg [63:0] cpu_w_data_r;
    reg [7:0] cpu_w_strb_r;
    reg cpu_r, cpu_w;

    reg [2:0] cache_state;
    localparam  C_IDLE   = 3'b000,  // Cache idle
                C_W_HIT  = 3'b001,  // Cache write hit
                C_W_MISS = 3'b010,  // Cache write miss
                C_W_MEM  = 3'b011,  // Cache write memory
                C_R_HIT  = 3'b100,  // Cache read hit
                C_R_MISS = 3'b101,  // Cache read miss
                C_R_MEM  = 3'b110;  // Cache read memory

    assign cache_idle   = (cache_state == C_IDLE) | (cache_state == C_W_HIT) | (cache_state == C_R_HIT);// | (cache_state == C_R_HIT & ~r_hit) | (cache_state == C_W_HIT & ~w_hit);

    //assign addr_actual  = (cache_state == C_IDLE) ? cpu_addr : cpu_addr_r;

    assign sram_r_en       = 1'b1;
    assign {tag, index_addr, offset_addr} = cpu_addr;
    assign {tag_r, index_r, offset_r} = cpu_addr_r;

    wire xor_in = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];    // generate random number LFSR 8 bit: x^8 + x^6 + x^5 + x^4 + 1

    wire [23:0] tag_ [0:3];
    assign tag_[0] = tag0;
    assign tag_[1] = tag1;
    assign tag_[2] = tag2;
    assign tag_[3] = tag3;

    wire [1:0] way_random = lfsr[1:0];
    
    reg [1:0] way_hit;      // [2] miss , [1:0] hit way
    reg hit_flag;
    always @(*) begin
        if ((tag == tag0[21:0]) & (`valid(tag0) == 1'b1)) begin
            way_hit  = 0;
            hit_flag = 1;
        end else if ((tag == tag1[21:0]) & (`valid(tag1) == 1'b1)) begin
            way_hit  = 1;
            hit_flag = 1;
        end else if ((tag == tag2[21:0]) & (`valid(tag2) == 1'b1)) begin
            way_hit  = 2;
            hit_flag = 1;
        end else if ((tag == tag3[21:0]) & (`valid(tag3) == 1'b1)) begin
            way_hit  = 3;
            hit_flag = 1;
        end else begin
            way_hit  = 0;
            hit_flag = 0;
        end
    end

    reg [1:0] way_empty;    // [2] full, [1:0] empty way
    reg  full_flag;
    always @(*) begin
        if (~`valid(tag0)) begin
            way_empty = 0;
            full_flag = 0;
        end else if (~`valid(tag1)) begin
            way_empty = 1;
            full_flag = 0;
        end else if (~`valid(tag2)) begin
            way_empty = 2;
            full_flag = 0;
        end else if (~`valid(tag3)) begin
            way_empty = 3;
            full_flag = 0;
        end else begin
            way_empty = 0;
            full_flag = 1;
        end
    end

    reg [7:0] r_cnt, w_cnt;
    wire w_hit, r_hit;
    
    assign w_hit = hit_flag & cpu_w_valid;
    assign r_hit = hit_flag & cpu_r_ready;

    always @(posedge clk) begin
        if (rst) begin
            cache_state     <= C_IDLE;
        end else begin
            case (cache_state)
                C_IDLE, C_R_HIT, C_W_HIT: begin
                    if (cpu_w_valid | cpu_r_ready) begin // write | read
                        if(hit_flag) begin // hit
                            if (cpu_w_valid) begin
                                cache_state     <= C_W_HIT;
                            end else if (cpu_r_ready) begin // read
                                cache_state     <= C_R_HIT;
                            end
                        end else begin // miss
                            if (full_flag) begin // full
                                if (`dirty(tag_[way_random])) begin // dirty
                                    cache_state     <= C_W_MEM;
                                end else begin  // not dirty
                                    cache_state     <= C_R_MEM;
                                end
                            end else begin // not full
                                cache_state     <= C_R_MEM;
                            end
                        end
                    end else begin
                        cache_state     <= C_IDLE;
                    end
                end

                C_W_MEM: begin
                    if (mem_w_ready & w_cnt == 8'd7) begin // last Byte
                            cache_state     <= C_R_MEM;
                        end
                    end

                C_R_MEM: begin
                    if (mem_r_valid) begin
                        if (r_cnt == 8'd0) begin // first Byte
                            if (cpu_w) begin
                                cache_state     <= C_W_MISS;
                            end
                        end else if (r_cnt == 8'd7) begin // last Byte
                            cache_state     <= C_IDLE;
                        end
                    end
                end

                C_W_MISS: begin
                    cache_state <= C_R_MEM;
                end

                default: begin
                    cache_state     <= C_IDLE;
                end
            endcase
        end
    end

    assign cpu_r_data      = cpu_r_valid ? cpu_rdata : cpu_rdata_r;
    assign mem_w_addr      = {tag_[way][21:0], index, offset} & ~32'h07; // 8 Byte align
    assign mem_w_size      = 3'b011;   // 8 Byte
    assign mem_w_burst     = 2'b10;    // WRAP
    assign mem_w_len       = 8'd7;     // 8 times
    assign mem_w_strb      = 8'hFF;    // all bytes
    assign mem_w_data      = sram_r_data;
    assign mem_r_addr      = cpu_addr_r & ~32'h07;
    assign mem_r_size      = 3'b011;   // 8 Byte
    assign mem_r_burst     = 2'b10;    // WRAP
    assign mem_r_len       = 8'd7;     // 8 times

    always @(*) begin
        if (rst) begin
            cpu_r_valid     = 1'b0;
            cpu_rdata       = 64'b0;
            cpu_w_ready     = 1'b0;
            tag_w_en        = 1'b0;
            tag_w_data      = 24'b0;
            way             = 2'b00;
            index           = 4'b0;
            offset          = 6'b0;
            sram_w_en       = 1'b0;
            sram_w_data     = 64'b0;
            sram_w_strb     = 8'b0;
            mem_r_ready     = 1'b0;
        end else begin
            case (cache_state)
                C_IDLE: begin
                    cpu_r_valid     = 1'b0;
                    cpu_rdata       = 64'b0;
                    cpu_w_ready     = 1'b0;
                    tag_w_en        = w_hit;
                    tag_w_data      = {2'b11, tag};
                    way             = way_hit;
                    index           = index_addr;
                    offset          = offset_addr;
                    sram_w_en       = w_hit;
                    sram_w_data     = cpu_w_data;
                    sram_w_strb     = cpu_w_strb;
                    mem_r_ready     = 1'b0;
                end

                C_W_HIT: begin
                    cpu_r_valid     = 1'b0;
                    cpu_rdata       = 64'b0;
                    cpu_w_ready     = 1'b1;
                    tag_w_en        = w_hit;
                    tag_w_data      = {2'b11, tag};
                    way             = way_hit;
                    index           = index_addr;
                    offset          = offset_addr;
                    sram_w_en       = w_hit;
                    sram_w_data     = cpu_w_data;
                    sram_w_strb     = cpu_w_strb;
                    mem_r_ready     = 1'b0;
                end

                C_R_HIT: begin
                    cpu_r_valid     = 1'b1;
                    cpu_rdata       = sram_r_data;
                    cpu_w_ready     = 1'b0;
                    tag_w_en        = w_hit;
                    tag_w_data      = {2'b11, tag};
                    way             = way_hit;
                    index           = index_addr;
                    offset          = offset_addr;
                    sram_w_en       = w_hit;
                    sram_w_data     = cpu_w_data;
                    sram_w_strb     = cpu_w_strb;
                    mem_r_ready     = 1'b0;
                end

                C_W_MEM: begin
                    cpu_r_valid     = 1'b0;
                    cpu_rdata       = 64'b0;
                    cpu_w_ready     = 1'b0;
                    if (w_cnt == 8'd7 & mem_w_ready) begin
                        tag_w_en        = 1'b1;
                    end else begin
                        tag_w_en        = 1'b0;
                    end
                    tag_w_data      = 24'b0;
                    way             = way_random;
                    index           = index_r;
                    offset          = offset_inc;
                    sram_w_en       = 1'b0;
                    sram_w_data     = 64'b0;
                    sram_w_strb     = 8'b0;
                    mem_r_ready     = 1'b0;
                end

                C_R_MEM: begin
                    cpu_r_valid     = cpu_r & r_cnt == 8'd0 & mem_r_valid;
                    cpu_rdata       = mem_r_data;
                    cpu_w_ready     = 1'b0;
                    if (r_cnt == 8'd7 & mem_r_valid) begin
                        tag_w_en        = 1'b1;
                    end else begin
                        tag_w_en        = 1'b0;
                    end
                    tag_w_data      = {1'b1, cpu_w, tag_r};
                    way             = full_flag ? way_random : way_empty;
                    index           = index_r;
                    offset          = offset_inc;
                    sram_w_en       = mem_r_valid;
                    sram_w_data     = mem_r_data;
                    sram_w_strb     = 8'hFF;
                    mem_r_ready     = 1'b1;
                end

                C_W_MISS: begin
                    cpu_r_valid     = 1'b0;
                    cpu_rdata       = 64'b0;
                    cpu_w_ready     = 1'b1;
                    tag_w_en        = 0;
                    tag_w_data      = 0;
                    way             = full_flag ? way_random : way_empty;
                    index           = index_r;
                    offset          = offset_r;
                    sram_w_en       = 1;
                    sram_w_data     = cpu_w_data_r;
                    sram_w_strb     = cpu_w_strb_r;
                    mem_r_ready     = 1'b0;
                end

                default: begin
                    cpu_r_valid     = 1'b0;
                    cpu_rdata       = 64'b0;
                    cpu_w_ready     = 1'b0;
                    tag_w_en        = 1'b0;
                    tag_w_data      = 24'b0;
                    way             = 2'b00;
                    index           = 4'b0;
                    offset          = 6'b0;
                    sram_w_en       = 1'b0;
                    sram_w_data     = 64'b0;
                    sram_w_strb     = 8'b0;
                    mem_r_ready     = 1'b0;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            cpu_r           <= 1'b0;
            cpu_rdata_r     <= 64'b0;
            cpu_w           <= 1'b0;
            cpu_w_strb_r    <= 0;
            cpu_w_data_r    <= 0;
            cpu_addr_r      <= 32'b0;
            r_cnt           <= 8'b0;
            w_cnt           <= 8'b0;
            offset_inc      <= 6'b0;
            lfsr            <= 8'd1;
            mem_w_valid     <= 1'b0;
        end else begin
            case (cache_state)
                C_IDLE, C_R_HIT, C_W_HIT: begin
                    if (cpu_r_ready | cpu_w_valid) begin
                        cpu_addr_r      <= cpu_addr;
                        cpu_w_strb_r    <= cpu_w_strb;
                        cpu_w_data_r    <= cpu_w_data;
                    end
                    cpu_r           <= cpu_r_ready;
                    cpu_w           <= cpu_w_valid;
                    r_cnt           <= 8'b0;
                    w_cnt           <= 8'b0;
                    offset_inc      <= offset_addr;
                    mem_w_valid     <= 1'b0;
                end

                C_W_MEM: begin
                    r_cnt           <= 8'b0;
                    if(mem_w_ready) begin
                        w_cnt <= w_cnt + 1;
                        offset_inc <= offset_inc + 6'd8;
                        if (w_cnt == 8'd7) begin
                            lfsr <= {lfsr[6:0], xor_in};
                        end
                    end
                    if(mem_w_valid & mem_w_ready)
                        mem_w_valid     <= 1'b0;
                    else
                        mem_w_valid     <= 1'b1;
                end

                C_R_MEM: begin
                    w_cnt           <= 8'b0;
                    if(mem_r_valid) begin
                        r_cnt <= r_cnt + 1;
                        offset_inc <= offset_inc + 6'd8;
                        if (r_cnt == 8'd7) begin
                            cpu_r           <= 1'b0;
                            cpu_w           <= 1'b0;
                            if(full_flag) lfsr <= {lfsr[6:0], xor_in}; // not dirty
                        end
                    end
                    mem_w_valid     <= 1'b0;
                end

                C_W_MISS: begin
                    cpu_r           <= 1'b0;
                    // cpu_w           <= 1'b0;
                    // r_cnt           <= 8'b0;
                    w_cnt           <= 8'b0;
                    // offset_inc      <= 6'b0;
                    mem_w_valid     <= 1'b0;
                end

                default: begin
                    cpu_r           <= 1'b0;
                    cpu_w           <= 1'b0;
                    r_cnt           <= 8'b0;
                    w_cnt           <= 8'b0;
                    offset_inc      <= 6'b0;
                    mem_w_valid     <= 1'b0;
                end
            endcase
            if(cpu_r_valid) begin
                cpu_rdata_r     <= cpu_rdata;
            end
        end
    end

endmodule //cache_ctrl

`endif// CACHE_CTRL_V


