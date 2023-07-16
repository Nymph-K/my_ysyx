`timescale  1ns / 1ps

module mul_booth_wallace_tb;

// mul_shift Parameters
parameter PERIOD  = 10;


// mul_shift Inputs
reg   clk                                  = 0 ;
reg   rst                                  = 0 ;
reg   mul_valid                            = 0 ;
reg   flush                                = 0 ;
reg   mulw                                 = 0 ;
reg   [ 1:0]  mul_signed                   = 0 ;
reg   [15:0]  multiplicand                 = 0 ;
reg   [15:0]  multiplier                   = 0 ;

// mul_shift Outputs
wire  mul_ready                            ;
wire  out_valid                            ;
wire  [15:0]  result_hi                    ;
wire  [15:0]  result_lo                    ;

wire  [15:0] test_data[1:16]              ;

    assign test_data[1]  =  16'h0;
    assign test_data[2]  =  16'h1;
    assign test_data[3]  =  16'h2;
    assign test_data[4]  =  16'h5;
    assign test_data[5]  = -16'h1;
    assign test_data[6]  =  16'h80;
    assign test_data[7]  =  16'h7F;
    assign test_data[8]  =  16'hFF;
    assign test_data[9]  =  16'h0F;
    assign test_data[10] =  16'h08;
    assign test_data[11] =  16'h07;
    assign test_data[12] = -16'h2;
    assign test_data[13] = -16'h5;
    assign test_data[14] =  16'h8F;
    assign test_data[15] = -16'h07;
    assign test_data[16] = -16'h08;

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

mul_booth_wallace_16b  u_mul_booth_wallace_16b
(
    .clk                     ( clk                  ),
    .rst                     ( rst                  ),
    .mul_valid               ( mul_valid            ),
    .flush                   ( flush                ),
    .mulw                    ( mulw                 ),
    .mul_signed              ( mul_signed     ),
    .multiplicand            ( multiplicand   ),
    .multiplier              ( multiplier     ),

    .mul_ready               ( mul_ready      ),
    .out_valid               ( out_valid      ),
    .result_hi               ( result_hi      ),
    .result_lo               ( result_lo      )
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

//`define SUPPORT_UNSIGNED
`ifdef SUPPORT_UNSIGNED
reg [31:0] c_uu;
reg [31:0] c_us;
reg [31:0] c_su;

reg [31:0] mul_uu;
reg [31:0] mul_us;
reg [31:0] mul_su;
`endif

reg [31:0] c_ss;
reg [31:0] mul_ss;

task multiply;
    input [15:0] a;
    input [15:0] b;
    begin
        //input [1:0]  si;// 00-uu, 01-us, 10-su, 11-ss
`ifdef SUPPORT_UNSIGNED
        c_uu =       {16'b0, a} *       {16'b0, b};
        c_us =       {16'b0, a} * {{16{b[15]}}, b};
        c_su = {{16{a[15]}}, a} *       {16'b0, b};
`endif
        c_ss = {{16{a[15]}}, a} * {{16{b[15]}}, b};

        multiplicand = a;
        multiplier = b;

        mulw = 0;

`ifdef SUPPORT_UNSIGNED
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
`endif
        mul_valid = 1;
        mul_signed = 2'b11;
        wait(mul_ready) @(posedge clk) mul_valid = 0;
        wait(out_valid) @(posedge clk);
        mul_ss = {result_hi, result_lo};

        $write("%h * %h", a, b);
`ifdef SUPPORT_UNSIGNED
        if(c_uu != mul_uu) $write("uu %h != %h ", c_uu, mul_uu); else $write("\t uu %h\t\t\t\t", c_uu);
        if(c_us != mul_us) $write("us %h != %h ", c_us, mul_us); else $write("\t us %h\t\t\t\t", c_us);
        if(c_su != mul_su) $write("su %h != %h ", c_su, mul_su); else $write("\t su %h\t\t\t\t", c_su);
`endif
        if(c_ss != mul_ss) $write("ss %h != %h ", c_ss, mul_ss); else $write("\t ss %h\t\t\t\t", c_ss);

        $write("\n");
    end
endtask

endmodule