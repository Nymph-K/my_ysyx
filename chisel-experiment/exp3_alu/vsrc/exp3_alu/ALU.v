module ALU(
  input        clock,
  input        reset,
  input  [2:0] io_sel,
  input  [3:0] io_a,
  input  [3:0] io_b,
  output [3:0] io_out,
  output       io_zero,
  output       io_overflow,
  output       io_carry
);
  wire [4:0] _result_T = $signed(io_a) + $signed(io_b); // @[ALU.scala 27:28]
  wire [4:0] _result_T_1 = $signed(io_a) - $signed(io_b); // @[ALU.scala 30:28]
  wire [3:0] _result_T_3 = ~io_a; // @[ALU.scala 33:23]
  wire [3:0] _result_T_5 = $signed(io_a) & $signed(io_b); // @[ALU.scala 36:28]
  wire [3:0] _result_T_7 = $signed(io_a) | $signed(io_b); // @[ALU.scala 39:28]
  wire [3:0] _result_T_9 = $signed(io_a) ^ $signed(io_b); // @[ALU.scala 42:28]
  wire [1:0] _result_T_11 = $signed(io_a) < $signed(io_b) ? $signed(2'sh1) : $signed(2'sh0); // @[ALU.scala 45:26]
  wire [1:0] _result_T_13 = $signed(io_a) == $signed(io_b) ? $signed(2'sh1) : $signed(2'sh0); // @[ALU.scala 48:26]
  wire [1:0] _GEN_0 = 3'h7 == io_sel ? $signed(_result_T_13) : $signed(2'sh0); // @[ALU.scala 19:12 25:20 48:20]
  wire [1:0] _GEN_1 = 3'h6 == io_sel ? $signed(_result_T_11) : $signed(_GEN_0); // @[ALU.scala 25:20 45:20]
  wire [3:0] _GEN_2 = 3'h5 == io_sel ? $signed(_result_T_9) : $signed({{2{_GEN_1[1]}},_GEN_1}); // @[ALU.scala 25:20 42:20]
  wire [3:0] _GEN_3 = 3'h4 == io_sel ? $signed(_result_T_7) : $signed(_GEN_2); // @[ALU.scala 25:20 39:20]
  wire [3:0] _GEN_4 = 3'h3 == io_sel ? $signed(_result_T_5) : $signed(_GEN_3); // @[ALU.scala 25:20 36:20]
  wire [3:0] _GEN_5 = 3'h2 == io_sel ? $signed(_result_T_3) : $signed(_GEN_4); // @[ALU.scala 25:20 33:20]
  wire [4:0] _GEN_6 = 3'h1 == io_sel ? $signed(_result_T_1) : $signed({{1{_GEN_5[3]}},_GEN_5}); // @[ALU.scala 25:20 30:20]
  wire [4:0] result = 3'h0 == io_sel ? $signed(_result_T) : $signed(_GEN_6); // @[ALU.scala 25:20 27:20]
  assign io_out = result[3:0]; // @[ALU.scala 20:12]
  assign io_zero = $signed(result) == 5'sh0; // @[ALU.scala 22:28]
  assign io_overflow = result[2] != result[3]; // @[ALU.scala 23:43]
  assign io_carry = result[4]; // @[ALU.scala 21:23]
endmodule
