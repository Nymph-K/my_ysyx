/*************************************************************
 * @ name           : cache_sram.v
 * @ description    : Cache SRAM
 * @ use module     : S011HD1P_X32Y2D128_BW
 * @ author         : K
 * @ date modified  : 2023-4-9

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
`ifndef CACHE_SRAM_V
`define CACHE_SRAM_V

module cache_sram (
    input               clk,
    input               rst,
    input     [1:0]     way,
    input     [3:0]     index,
    input     [5:0]     offset,
    input     [5:0]     offset_r,
    input               sram_r_en,
    input               sram_w_en,
    input    [63:0]     sram_w_data,
    input     [7:0]     sram_w_strb, // 8 Byte strobe
    output   [63:0]     sram_r_data
);

    wire [3:0]      sram_cen = 4'hF;//{4{sram_w_en | sram_r_en}};
    wire [3:0]      sram_wen = (4'b1 << offset[5:4]) & {4{sram_w_en}};
    wire [127:0]    sram_wdata = {2{sram_w_data}};
    wire [63:0]     sram_w_strb_bit = {{8{sram_w_strb[7]}}, {8{sram_w_strb[6]}}, {8{sram_w_strb[5]}}, {8{sram_w_strb[4]}}, {8{sram_w_strb[3]}}, {8{sram_w_strb[2]}}, {8{sram_w_strb[1]}}, {8{sram_w_strb[0]}}};
    wire [127:0]    sram_bwen = offset[3] ? {sram_w_strb_bit, 64'b0} : {64'b0, sram_w_strb_bit};
    wire [127:0]    sram_rdata[0:3];
    assign          sram_r_data = offset_r[3] ? sram_rdata[offset_r[5:4]][127:64] : sram_rdata[offset_r[5:4]][63:0];

    S011HD1P_X32Y2D128_BW u_sram_0(
        .Q              (sram_rdata[0]),
        .CLK            (clk),
        .CEN            (sram_cen[0]),//~ TODO
        .WEN            (sram_wen[0]),//~ TODO
        .BWEN           (sram_bwen),//~ TODO
        .A              ({way, index}),
        .D              (sram_wdata)
    );

    S011HD1P_X32Y2D128_BW u_sram_1(
        .Q              (sram_rdata[1]),
        .CLK            (clk),
        .CEN            (sram_cen[1]),//~ TODO
        .WEN            (sram_wen[1]),//~ TODO
        .BWEN           (sram_bwen),//~ TODO
        .A              ({way, index}),
        .D              (sram_wdata)
    );

    S011HD1P_X32Y2D128_BW u_sram_2(
        .Q              (sram_rdata[2]),
        .CLK            (clk),
        .CEN            (sram_cen[2]),//~ TODO
        .WEN            (sram_wen[2]),//~ TODO
        .BWEN           (sram_bwen),//~ TODO
        .A              ({way, index}),
        .D              (sram_wdata)
    );

    S011HD1P_X32Y2D128_BW u_sram_3(
        .Q              (sram_rdata[3]),
        .CLK            (clk),
        .CEN            (sram_cen[3]),//~ TODO
        .WEN            (sram_wen[3]),//~ TODO
        .BWEN           (sram_bwen),//~ TODO
        .A              ({way, index}),
        .D              (sram_wdata)
    );

endmodule //cache_sram

`endif //CACHE_SRAM_V