/*************************************************************
 * @ name           : cache_tag.v
 * @ description    : Cache tag
 * @ use module     : 
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
`ifndef CACHE_TAG_V
`define CACHE_TAG_V



module cache_tag (
    input               clk,
    input               rst,
    input       [1:0]   way,
    input       [3:0]   index,
    input               tag_w_en,
    input      [23:0]   tag_w_data,
    output     [23:0]   tag0,
    output     [23:0]   tag1,
    output     [23:0]   tag2,
    output     [23:0]   tag3
);

    reg [23:0]  tag [0:3][0:15];    // tag[way][index]

    assign tag0 = tag[0][index];
    assign tag1 = tag[1][index];
    assign tag2 = tag[2][index];
    assign tag3 = tag[3][index];

    integer i,j;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 4; i=i+1) begin
                for (j = 0; j < 16; j=j+1) begin
                    tag[i][j] <= 0;
                end
            end
        end else begin
            if(tag_w_en) begin
                tag[way][index] <= tag_w_data;
            end
        end
    end

endmodule //cache_tag

`endif //CACHE_TAG_V