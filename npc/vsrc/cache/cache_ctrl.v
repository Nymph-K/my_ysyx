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

    input         [31:0]        lsu_addr,       // [2:0] not use
	input                       lsu_r_ready,
	output        [63:0]        lsu_r_data,
	output  reg                 lsu_r_valid,
	input                       lsu_w_valid,
	input         [ 7:0]        lsu_w_strb,     // 8 Byte strobe, 8 Byte align
	input         [63:0]        lsu_w_data,     // already 8 Byte align
	output  reg                 lsu_w_ready,

    output  reg                 tag_w_en,
    output  reg   [23:0]        tag_w_data,
    input         [23:0]        tag0,
    input         [23:0]        tag1,
    input         [23:0]        tag2,
    input         [23:0]        tag3,

    output  reg   [ 1:0]        way,
    output        [ 3:0]        index,
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
    input         [63:0]        mem_r_data
);
    wire [21:0] tag;
    wire [5:0] offset_addr;
    reg [31:0] lsu_addr_r;
    reg [5:0] offset_inc;
    reg [1:0] tag_valid_dirty;
    reg [7:0] lfsr;

    reg [2:0] cache_state;
    localparam  C_IDLE   = 3'b000,  // Cache idle
                C_W_HIT  = 3'b001,  // Cache write hit
                C_W_MISS = 3'b010,  // Cache write miss
                C_W_MEM  = 3'b011,  // Cache write memory
                C_R_HIT  = 3'b100,  // Cache read hit
                C_R_MISS = 3'b101,  // Cache read miss
                C_R_MEM  = 3'b110;  // Cache read memory

    assign {tag, index, offset_addr} = (cache_state == C_IDLE) ? lsu_addr : lsu_addr_r;

    // generate random number LFSR 8 bit: x^8 + x^6 + x^5 + x^4 + 1
    wire xor_in = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];
    // always @(posedge clk) begin
    //     if (rst) begin
    //         lfsr <= 1;
    //     end else begin
    //         if ((cache_state == C_R_MEM) && (r_cnt == 8'd7) && mem_r_valid) begin
    //             lfsr <= {lfsr[6:0], xor_in};
    //         end
    //     end
    // end

    wire [23:0] tag_ [0:3];
    assign tag_[0] = tag0;
    assign tag_[1] = tag1;
    assign tag_[2] = tag2;
    assign tag_[3] = tag3;

    wire [1:0] way_random = lfsr[1:0];
    
    reg [2:0] way_hit;      // [2] miss , [1:0] hit way
    always @(*) begin
        if ((tag == tag0[21:0]) && (`valid(tag0) == 1'b1)) begin
            way_hit = 3'b000;
        end else if ((tag == tag1[21:0]) && (`valid(tag1) == 1'b1)) begin
            way_hit = 3'b001;
        end else if ((tag == tag2[21:0]) && (`valid(tag2) == 1'b1)) begin
            way_hit = 3'b010;
        end else if ((tag == tag3[21:0]) && (`valid(tag3) == 1'b1)) begin
            way_hit = 3'b011;
        end else begin
            way_hit = 3'b100;
        end
    end

    reg [2:0] way_empty;    // [2] full, [1:0] empty way
    always @(*) begin
        if (~`valid(tag0)) begin
            way_empty = 3'b000;
        end else if (~`valid(tag1)) begin
            way_empty = 3'b001;
        end else if (~`valid(tag2)) begin
            way_empty = 3'b010;
        end else if (~`valid(tag3)) begin
            way_empty = 3'b011;
        end else begin
            way_empty = 3'b100;
        end
    end

    reg [7:0] r_cnt, w_cnt;

    always @(posedge clk) begin
        if (rst) begin
            cache_state     <= C_IDLE;
        end else begin
            case (cache_state)
                C_IDLE: begin
                    if (lsu_w_valid | lsu_r_ready) begin // write | read
                        if(way_hit[2]) begin // miss
                            if (way_empty[2]) begin // full
                                if (`dirty(tag_[way_random])) begin // dirty
                                    cache_state     <= C_W_MEM;
                                end else begin  // not dirty
                                    cache_state     <= C_R_MEM;
                                end
                            end else begin // not full
                                cache_state     <= C_R_MEM;
                            end
                        end else begin // hit
                            if (lsu_w_valid) begin
                                cache_state     <= C_W_HIT;
                            end else if (lsu_r_ready) begin // read
                                cache_state     <= C_R_HIT;
                            end
                        end
                    end
                end

                C_R_HIT: begin
                    if (lsu_r_valid) begin
                        cache_state     <= C_IDLE;
                    end
                end

                C_W_HIT: begin
                    if (lsu_w_ready) begin
                        cache_state     <= C_IDLE;
                    end
                end

                C_W_MEM: begin
                    if (mem_w_ready && w_cnt == 8'd7) begin // last Byte
                            cache_state     <= C_R_MEM;
                        end
                    end

                C_R_MEM: begin
                    if (mem_r_valid) begin
                        if (r_cnt == 8'd0) begin // first Byte
                            if (lsu_w_valid) begin
                                cache_state     <= C_W_MISS;
                            end else begin
                                cache_state     <= C_R_MISS;
                            end
                        end else if (r_cnt == 8'd7) begin // last Byte
                            cache_state     <= C_IDLE;
                        end
                    end
                end

                C_W_MISS: begin
                    if (lsu_w_ready) begin
                        cache_state     <= C_R_MEM;
                    end
                end

                C_R_MISS: begin
                    if (lsu_r_valid) begin
                        cache_state     <= C_R_MEM;
                    end
                end

                default: begin
                    cache_state     <= C_IDLE;
                end
            endcase
        end
    end

    assign lsu_r_data      = sram_r_data;
    assign mem_w_addr      = {tag_[way][21:0], index, offset_addr} & ~32'h07; // 8 Byte align
    assign mem_w_size      = 3'b011;   // 8 Byte
    assign mem_w_burst     = 2'b10;    // WRAP
    assign mem_w_len       = 8'd7;     // 8 times
    assign mem_w_strb      = 8'hFF;    // all bytes
    assign mem_w_data      = sram_r_data;
    assign mem_r_addr      = lsu_addr & ~32'h07; // 8 Byte align
    assign mem_r_size      = 3'b011;   // 8 Byte
    assign mem_r_burst     = 2'b10;    // WRAP
    assign mem_r_len       = 8'd7;     // 8 times

    always @(*) begin
        if (rst) begin
            lsu_w_ready     = 1'b0;
            tag_w_en        = 1'b0;
            tag_w_data      = 24'b0;
            way             = 2'b00;
            offset          = 6'b0;
            sram_r_en       = 1'b0;
            sram_w_en       = 1'b0;
            sram_w_data     = 64'b0;
            sram_w_strb     = 8'b0;
            mem_r_ready     = 1'b0;

        end else begin
            case (cache_state)
                C_IDLE: begin
                    lsu_w_ready     = 1'b0;
                    tag_w_en        = 1'b0;
                    tag_w_data      = 24'b0;
                    way             = way_hit[1:0];
                    offset          = 6'b0;
                    sram_r_en       = 1'b0;
                    sram_w_en       = 1'b0;
                    sram_w_data     = 64'b0;
                    sram_w_strb     = 8'b0;
                    mem_r_ready     = 1'b0;
                end

                C_W_HIT: begin
                    lsu_w_ready     = 1'b1;
                    tag_w_en        = 1'b1;
                    tag_w_data      = {2'b11, tag};
                    way             = way_hit[1:0];
                    offset          = offset_addr;
                    sram_r_en       = 1'b0;
                    sram_w_en       = 1'b1;
                    sram_w_data     = lsu_w_data;
                    sram_w_strb     = lsu_w_strb;
                    mem_r_ready     = 1'b0;
                end

                C_R_HIT: begin
                    lsu_w_ready     = 1'b0;
                    tag_w_en        = 1'b0;
                    tag_w_data      = 24'b0;
                    way             = way_hit[1:0];
                    offset          = offset_addr;
                    sram_r_en       = 1'b1;
                    sram_w_en       = 1'b0;
                    sram_w_data     = 64'b0;
                    sram_w_strb     = 8'b0;
                    mem_r_ready     = 1'b0;
                end

                C_W_MEM: begin
                    lsu_w_ready     = 1'b0;
                    if (w_cnt == 8'd7 && mem_w_ready) begin
                        tag_w_en        = 1'b1;
                    end else begin
                        tag_w_en        = 1'b0;
                    end
                    tag_w_data      = 24'b0;
                    way             = way_random;
                    offset          = offset_inc;
                    sram_r_en       = 1'b1;
                    sram_w_en       = 1'b0;
                    sram_w_data     = 64'b0;
                    sram_w_strb     = 8'b0;
                    mem_r_ready     = 1'b0;
                end

                C_R_MEM: begin
                    lsu_w_ready     = 1'b0;
                    if (r_cnt == 8'd7 && mem_r_valid) begin
                        tag_w_en        = 1'b1;
                    end else begin
                        tag_w_en        = 1'b0;
                    end
                    tag_w_data      = {tag_valid_dirty, tag};
                    way             = way_empty[1:0];
                    offset          = offset_inc;
                    sram_r_en       = 1'b0;
                    sram_w_en       = mem_r_valid;
                    sram_w_data     = mem_r_data;
                    sram_w_strb     = 8'hFF;
                    mem_r_ready     = 1'b1;
                end

                C_W_MISS: begin
                    lsu_w_ready     = 1'b1;
                    tag_w_en        = 1'b0;
                    tag_w_data      = 24'b0;
                    way             = way_empty[1:0];
                    offset          = offset_addr;
                    sram_r_en       = 1'b0;
                    sram_w_en       = 1'b1;
                    sram_w_data     = lsu_w_data;
                    sram_w_strb     = lsu_w_strb;
                    mem_r_ready     = 1'b0;
                end

                C_R_MISS: begin
                    lsu_w_ready     = 1'b0;
                    tag_w_en        = 1'b0;
                    tag_w_data      = 24'b0;
                    way             = way_empty[1:0];
                    offset          = offset_addr;
                    sram_r_en       = 1'b1;
                    sram_w_en       = 1'b0;
                    sram_w_data     = 64'b0;
                    sram_w_strb     = 8'b0;
                    mem_r_ready     = 1'b0;
                end

                default: begin
                    lsu_w_ready     = 1'b0;
                    tag_w_en        = 1'b0;
                    tag_w_data      = 24'b0;
                    way             = 2'b00;
                    offset          = 6'b0;
                    sram_r_en       = 1'b0;
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
            lsu_addr_r      <= 32'b0;
            lsu_r_valid     <= 1'b0;
            r_cnt           <= 1'b0;
            w_cnt           <= 1'b0;
            offset_inc      <= 6'b0;
            mem_w_valid     <= 1'b0;
            lfsr            <= 8'd1;
            tag_valid_dirty <= 2'b00;
        end else begin
            case (cache_state)
                C_IDLE: begin
                    if (lsu_r_ready | lsu_w_valid) begin
                        lsu_addr_r      <= lsu_addr;
                    end
                    lsu_r_valid     <= 1'b0;
                    r_cnt           <= 1'b0;
                    w_cnt           <= 1'b0;
                    offset_inc      <= offset_addr;
                    mem_w_valid     <= 1'b0;
                end

                C_R_HIT: begin
                    lsu_r_valid     <= ~lsu_r_valid;
                    r_cnt           <= 1'b0;
                    w_cnt           <= 1'b0;
                    offset_inc      <= offset_addr;
                    mem_w_valid     <= 1'b0;
                end

                C_W_MEM: begin
                    lsu_r_valid     <= 1'b0;
                    r_cnt           <= 1'b0;
                    if(mem_w_ready) begin
                        w_cnt <= w_cnt + 1;
                        offset_inc <= offset_inc + 6'd8;
                    end
                    if (w_cnt == 8'd7 && mem_w_ready) begin
                        mem_w_valid     <= 1'b0;
                        lfsr <= {lfsr[6:0], xor_in};
                    end else begin
                        mem_w_valid     <= 1'b1;    // cache first read delay 1 cycle
                    end
                end

                C_R_MEM: begin
                    lsu_r_valid     <= 1'b0;
                    if(mem_r_valid) begin
                        r_cnt <= r_cnt + 1;
                        offset_inc <= offset_inc + 6'd8;
                    end
                    w_cnt           <= 1'b0;
                    mem_w_valid     <= 1'b0;
                end

                C_W_MISS: begin
                    lsu_r_valid     <= 1'b0;
                    //r_cnt           <= r_cnt;
                    w_cnt           <= 1'b0;
                    //offset_inc      <= offset_inc;
                    mem_w_valid     <= 1'b0;
                    tag_valid_dirty <= 2'b11;
                end

                C_R_MISS: begin
                    lsu_r_valid     <= ~lsu_r_valid;
                    //r_cnt           <= r_cnt;
                    w_cnt           <= 1'b0;
                    //offset_inc      <= offset_inc;
                    mem_w_valid     <= 1'b0;
                    tag_valid_dirty <= 2'b10;
                end

                default: begin
                    lsu_r_valid     <= 1'b0;
                    r_cnt           <= 1'b0;
                    w_cnt           <= 1'b0;
                    offset_inc      <= 6'b0;
                    mem_w_valid     <= 1'b0;
                end
            endcase
        end
    end

endmodule //cache_ctrl

`endif// CACHE_CTRL_V