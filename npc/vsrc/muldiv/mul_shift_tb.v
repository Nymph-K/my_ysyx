`timescale  1ns / 1ps

`define TEST_BOOTH

module tb_mul_shift;

// mul_shift Parameters
parameter PERIOD  = 10;


// mul_shift Inputs
reg   clk                                  = 0 ;
reg   rst                                  = 0 ;
reg   mul_valid                            = 0 ;
reg   flush                                = 0 ;
reg   mulw                                 = 0 ;
reg   [ 1:0]  mul_signed                   = 0 ;
reg   [63:0]  multiplicand                 = 0 ;
reg   [63:0]  multiplier                   = 0 ;

// mul_shift Outputs
wire  mul_ready                            ;
wire  out_valid                            ;
wire  [63:0]  result_hi                    ;
wire  [63:0]  result_lo                    ;

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

`ifdef TEST_BOOTH

mul_booth  u_mul_booth 

`else

mul_shift_0term  u_mul_shift 

`endif
(
    .clk                     ( clk                  ),
    .rst                     ( rst                  ),
    .mul_valid               ( mul_valid            ),
    .flush                   ( flush                ),
    .mulw                    ( mulw                 ),
    .mul_signed              ( mul_signed    [ 1:0] ),
    .multiplicand            ( multiplicand  [63:0] ),
    .multiplier              ( multiplier    [63:0] ),

    .mul_ready               ( mul_ready            ),
    .out_valid               ( out_valid            ),
    .result_hi               ( result_hi     [63:0] ),
    .result_lo               ( result_lo     [63:0] )
);

integer i,j;
initial
begin
    #(PERIOD*4) ;
    for (i = 1; i <= 16; i = i + 1) begin
        for (j = 1; j <= 16; j = j + 1) begin
            multiply(test_data[i],test_data[j]);
        end
    end
    multiply($random($time),$random());
    repeat (20) begin 
        multiply($random(),$random());
    end
    $stop();
end

reg [127:0] c_uu;
reg [127:0] c_us;
reg [127:0] c_su;
reg [127:0] c_ss;

reg [63:0] c_uuw;
reg [63:0] c_usw;
reg [63:0] c_suw;
reg [63:0] c_ssw;

reg [127:0] mul_uu;
reg [127:0] mul_us;
reg [127:0] mul_su;
reg [127:0] mul_ss;

reg [63:0] mul_uuw;
reg [63:0] mul_usw;
reg [63:0] mul_suw;
reg [63:0] mul_ssw;

task multiply;
    input [63:0] a;
    input [63:0] b;
    begin
        //input [1:0]  si;// 00-uu, 01-us, 10-su, 11-ss
        c_uu =       {64'b0, a} *       {64'b0, b};
        c_us =       {64'b0, a} * {{64{b[63]}}, b};
        c_su = {{64{a[63]}}, a} *       {64'b0, b};
        c_ss = {{64{a[63]}}, a} * {{64{b[63]}}, b};

        multiplicand = a;
        multiplier = b;

        mulw = 0;

        mul_valid = 1;
        mul_signed = 2'b00;
        wait(mul_ready) @(posedge clk) mul_valid = 0;
        wait(out_valid) @(posedge clk);
        mul_uu = {result_hi, result_lo};

        mul_valid = 1;
        mul_signed = 2'b01;
        wait(mul_ready) @(posedge clk) mul_valid = 0;
        wait(out_valid) @(posedge clk);
        mul_us = {result_hi, result_lo};

        mul_valid = 1;
        mul_signed = 2'b10;
        wait(mul_ready) @(posedge clk) mul_valid = 0;
        wait(out_valid) @(posedge clk);
        mul_su = {result_hi, result_lo};

        mul_valid = 1;
        mul_signed = 2'b11;
        wait(mul_ready) @(posedge clk) mul_valid = 0;
        wait(out_valid) @(posedge clk);
        mul_ss = {result_hi, result_lo};

        $write("%h * %h", a, b);
        if(c_uu != mul_uu) $write("uu %h != %h ", c_uu, mul_uu); else $write("\t\t\t\t\t");
        if(c_us != mul_us) $write("us %h != %h ", c_us, mul_us); else $write("\t\t\t\t\t");
        if(c_su != mul_su) $write("su %h != %h ", c_su, mul_su); else $write("\t\t\t\t\t");
        if(c_ss != mul_ss) $write("ss %h != %h ", c_ss, mul_ss); else $write("\t\t\t\t\t");

        c_uuw =       {32'b0, a[31:0]} *       {32'b0, b[31:0]};
        c_usw =       {32'b0, a[31:0]} * {{32{b[31]}}, b[31:0]};
        c_suw = {{32{a[31]}}, a[31:0]} *       {32'b0, b[31:0]};
        c_ssw = {{32{a[31]}}, a[31:0]} * {{32{b[31]}}, b[31:0]};

        mulw = 1;

        mul_valid = 1;
        mul_signed = 2'b00;
        wait(mul_ready) @(posedge clk) mul_valid = 0;
        wait(out_valid) @(posedge clk);
        mul_uuw = result_lo;

        mul_valid = 1;
        mul_signed = 2'b01;
        wait(mul_ready) @(posedge clk) mul_valid = 0;
        wait(out_valid) @(posedge clk);
        mul_usw = result_lo;

        mul_valid = 1;
        mul_signed = 2'b10;
        wait(mul_ready) @(posedge clk) mul_valid = 0;
        wait(out_valid) @(posedge clk);
        mul_suw = result_lo;

        mul_valid = 1;
        mul_signed = 2'b11;
        wait(mul_ready) @(posedge clk) mul_valid = 0;
        wait(out_valid) @(posedge clk);
        mul_ssw = result_lo;

        $write("\n%h * %h", a[31:0], b[31:0]);
        if(c_uuw != mul_uuw) $write("uuw %h != %h ", c_uuw, mul_uuw); else $write("\t\t\t\t\t");
        if(c_usw != mul_usw) $write("usw %h != %h ", c_usw, mul_usw); else $write("\t\t\t\t\t");
        if(c_suw != mul_suw) $write("suw %h != %h ", c_suw, mul_suw); else $write("\t\t\t\t\t");
        if(c_ssw != mul_ssw) $write("ssw %h != %h ", c_ssw, mul_ssw); else $write("\t\t\t\t\t");

        $write("\n");
    end
endtask

endmodule