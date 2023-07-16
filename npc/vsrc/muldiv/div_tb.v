`timescale  1ns / 1ps
module tb_div_shift_64clk;

// div_shift_64clk Parameters
parameter PERIOD  = 10;

// div_shift_64clk Inputs
reg   clk                                  = 0 ;
reg   rst                                  = 0 ;
reg   div_valid                            = 0 ;
reg   flush                                = 0 ;
reg   divw                                 = 0 ;
reg   [ 1:0]  div_signed                   = 0 ;
reg   [63:0]  dividend                     = 0 ;
reg   [63:0]  divisor                      = 0 ;

// div_shift_64clk Outputs
wire  div_ready                            ;
wire  out_valid                            ;
wire  [63:0]  quotient                     ;
wire  [63:0]  remainder                    ;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    rst  =  1;
    #(PERIOD*3);
    rst  =  0;
end

wire     [63:0] test_data[1:16]              ;

    assign test_data[1]  =  64'h0;
    assign test_data[2]  =  64'h1;
    assign test_data[3]  =  64'h2;
    assign test_data[4]  =  64'h5;
    assign test_data[5]  = -64'h1;
    assign test_data[6]  =  64'h80000000_00000000;
    assign test_data[7]  =  64'h7FFFFFFF_FFFFFFFF;
    assign test_data[8]  =  64'hFFFFFFFF_FFFFFFFF;
    assign test_data[9]  =  64'h00000000_7FFFFFFF;
    assign test_data[10] =  64'h00000000_FFFFFFFF;
    assign test_data[11] =  64'h00000000_80000000;
    assign test_data[12] = -64'h2;
    assign test_data[13] = -64'h5;
    assign test_data[14] =  64'h8FFFFFFF_FFFFFFFF;
    assign test_data[15] =  64'h00000000_8FFFFFFF;
    assign test_data[16] =  64'h0000FFFF_FFFFFFFF;

div_nonrestoring  u_div_shift_64clk (
    .clk                     ( clk                ),
    .rst                     ( rst                ),
    .div_valid               ( div_valid          ),
    .flush                   ( flush              ),
    .divw                    ( divw               ),
    .div_signed              ( div_signed  [ 1:0] ),
    .dividend                ( dividend    [63:0] ),
    .divisor                 ( divisor     [63:0] ),

    .div_ready               ( div_ready          ),
    .out_valid               ( out_valid          ),
    .quotient                ( quotient    [63:0] ),
    .remainder               ( remainder   [63:0] )
);

integer i,j;
initial
begin
    #(PERIOD*4) ;
    for (i = 1; i <= 16; i = i + 1) begin
        for (j = 1; j <= 16; j = j + 1) begin
            divide(test_data[i],test_data[j]);
        end
    end
    divide($random($time),$random());
    repeat (20) begin 
        divide($random(),$random());
    end
    $stop();
end

reg [63:0] a_abs;
reg [63:0] b_abs;

reg [63:0] quo_uu;
reg [63:0] quo_us;
reg [63:0] quo_su;
reg [63:0] quo_ss;
reg [63:0] rem_uu;
reg [63:0] rem_us;
reg [63:0] rem_su;
reg [63:0] rem_ss;

reg [31:0] a_absw;
reg [31:0] b_absw;

reg [31:0] quo_uuw;
reg [31:0] quo_usw;
reg [31:0] quo_suw;
reg [31:0] quo_ssw;
reg [31:0] rem_uuw;
reg [31:0] rem_usw;
reg [31:0] rem_suw;
reg [31:0] rem_ssw;

reg [64:0] q_div_uu;
reg [64:0] q_div_us;
reg [64:0] q_div_su;
reg [64:0] q_div_ss;

reg [64:0] r_div_uu;
reg [64:0] r_div_us;
reg [64:0] r_div_su;
reg [64:0] r_div_ss;

/*  dividend      divisor     quotient    remainder
 *      +           +             +           +
 *      +           -             -           +
 *      -           +             -           -
 *      -           -             +           -
*/

task divide;
    input [63:0] a;
    input [63:0] b;
    begin
        //input [1:0]  si;// 00-uu, 01-us, 10-su, 11-ss
        a_abs = a[63] ? -a : a;
        b_abs = b[63] ? -b : b;
        
        quo_uu = $unsigned(a    ) / $unsigned(b    );
        quo_us = $unsigned(a    ) / $unsigned(b_abs); quo_us = b[63] ? -quo_us : quo_us;
        quo_su = $unsigned(a_abs) / $unsigned(b    ); quo_su = a[63] ? -quo_su : quo_su;
        quo_ss = $unsigned(a_abs) / $unsigned(b_abs); quo_ss = (a[63] ^ b[63]) ? -quo_ss : quo_ss;
        
        rem_uu = $unsigned(a    ) % $unsigned(b    ); 
        rem_us = $unsigned(a    ) % $unsigned(b_abs);
        rem_su = $unsigned(a_abs) % $unsigned(b    ); rem_su = a[63] ? -rem_su : rem_su;
        rem_ss = $unsigned(a_abs) % $unsigned(b_abs); rem_ss = a[63] ? -rem_ss : rem_ss;
        

        dividend = a;
        divisor = b;

        divw = 0;

        div_valid = 1;
        div_signed = 2'b00;
        wait(div_ready) @(posedge clk) div_valid = 0;
        wait(out_valid) @(posedge clk);
        q_div_uu = quotient;
        r_div_uu = remainder;

        div_valid = 1;
        div_signed = 2'b01;
        wait(div_ready) @(posedge clk) div_valid = 0;
        wait(out_valid) @(posedge clk);
        q_div_us = quotient;
        r_div_us = remainder;

        div_valid = 1;
        div_signed = 2'b10;
        wait(div_ready) @(posedge clk) div_valid = 0;
        wait(out_valid) @(posedge clk);
        q_div_su = quotient;
        r_div_su = remainder;

        div_valid = 1;
        div_signed = 2'b11;
        wait(div_ready) @(posedge clk) div_valid = 0;
        wait(out_valid) @(posedge clk);
        q_div_ss = quotient;
        r_div_ss = remainder;

        $write("%h / %h\t", a, b);
        if(q_div_uu != quo_uu) $write("q uu %h != %h ", q_div_uu, quo_uu);// else $write("\t q uu %h\t", quo_uu);
        if(r_div_uu != rem_uu) $write("r uu %h != %h ", r_div_uu, rem_uu);// else $write("\t r uu %h\t", rem_uu);
        if(q_div_us != quo_us) $write("q us %h != %h ", q_div_us, quo_us);// else $write("\t q us %h\t", quo_us);
        if(r_div_us != rem_us) $write("r us %h != %h ", r_div_us, rem_us);// else $write("\t r us %h\t", rem_us);
        if(q_div_su != quo_su) $write("q su %h != %h ", q_div_su, quo_su);// else $write("\t q su %h\t", quo_su);
        if(r_div_su != rem_su) $write("r su %h != %h ", r_div_su, rem_su);// else $write("\t r su %h\t", rem_su);
        if(q_div_ss != quo_ss) $write("q ss %h != %h ", q_div_ss, quo_ss);// else $write("\t q ss %h\t", quo_ss);
        if(r_div_ss != rem_ss) $write("r ss %h != %h ", r_div_ss, rem_ss);// else $write("\t r ss %h\t", rem_ss);

        
        a_absw = a[31] ? -(a[31:0]) : a[31:0];
        b_absw = b[31] ? -(b[31:0]) : b[31:0];

        quo_uuw = $unsigned(a[31:0]) / $unsigned(b[31:0]);
        quo_usw = $unsigned(a[31:0]) / $unsigned(b_absw ); quo_usw = b[31] ? -quo_usw : quo_usw;
        quo_suw = $unsigned(a_absw ) / $unsigned(b[31:0]); quo_suw = a[31] ? -quo_suw : quo_suw;
        quo_ssw = $unsigned(a_absw ) / $unsigned(b_absw ); quo_ssw = (a[31] ^ b[31]) ? -quo_ssw : quo_ssw;
        
        rem_uuw = $unsigned(a[31:0]) % $unsigned(b[31:0]); 
        rem_usw = $unsigned(a[31:0]) % $unsigned(b_absw );
        rem_suw = $unsigned(a_absw ) % $unsigned(b[31:0]); rem_suw = a[31] ? -rem_suw : rem_suw;
        rem_ssw = $unsigned(a_absw ) % $unsigned(b_absw ); rem_ssw = a[31] ? -rem_ssw : rem_ssw;
        
        divw = 1;

        div_valid = 1;
        div_signed = 2'b00;
        wait(div_ready) @(posedge clk) div_valid = 0;
        wait(out_valid) @(posedge clk);
        q_div_uu = quotient;
        r_div_uu = remainder;

        div_valid = 1;
        div_signed = 2'b01;
        wait(div_ready) @(posedge clk) div_valid = 0;
        wait(out_valid) @(posedge clk);
        q_div_us = quotient;
        r_div_us = remainder;

        div_valid = 1;
        div_signed = 2'b10;
        wait(div_ready) @(posedge clk) div_valid = 0;
        wait(out_valid) @(posedge clk);
        q_div_su = quotient;
        r_div_su = remainder;

        div_valid = 1;
        div_signed = 2'b11;
        wait(div_ready) @(posedge clk) div_valid = 0;
        wait(out_valid) @(posedge clk);
        q_div_ss = quotient;
        r_div_ss = remainder;

        $write("\n%h / %h\t", a[31:0], b[31:0]);
        if(q_div_uu[31:0] != quo_uuw) $write("q uuw %h != %h ", q_div_uu[31:0], quo_uuw);// else $write("\t q uuw %h\t", quo_uuw);
        if(r_div_uu[31:0] != rem_uuw) $write("r uuw %h != %h ", r_div_uu[31:0], rem_uuw);// else $write("\t r uuw %h\t", rem_uuw);
        if(q_div_us[31:0] != quo_usw) $write("q usw %h != %h ", q_div_us[31:0], quo_usw);// else $write("\t q usw %h\t", quo_usw);
        if(r_div_us[31:0] != rem_usw) $write("r usw %h != %h ", r_div_us[31:0], rem_usw);// else $write("\t r usw %h\t", rem_usw);
        if(q_div_su[31:0] != quo_suw) $write("q suw %h != %h ", q_div_su[31:0], quo_suw);// else $write("\t q suw %h\t", quo_suw);
        if(r_div_su[31:0] != rem_suw) $write("r suw %h != %h ", r_div_su[31:0], rem_suw);// else $write("\t r suw %h\t", rem_suw);
        if(q_div_ss[31:0] != quo_ssw) $write("q ssw %h != %h ", q_div_ss[31:0], quo_ssw);// else $write("\t q ssw %h\t", quo_ssw);
        if(r_div_ss[31:0] != rem_ssw) $write("r ssw %h != %h ", r_div_ss[31:0], rem_ssw);// else $write("\t r ssw %h\t", rem_ssw);

        $write("\n");
    end
endtask

endmodule